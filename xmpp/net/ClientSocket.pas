unit ClientSocket;

interface
uses
  SysUtils,IdException,IdTCPClient,IdThread,Classes,XMPPEvent,XMPPConst,IdSSLOpenSSL,
  //{$ifdef linux}
    //QExtCtrls, IdSSLIntercept,
    //{$else}
    windows, ExtCtrls,IdSocks,Net.BaseSocket,
    //{endif}
    Generics.Collections,SyncObjs,IdTCPConnection,IdCompressorZLib,IdIOHandlerSocket;
type
  TParseThread = class;
  TConnectTimeoutException=class(EIdException)
  public
    constructor Create(msg:string);overload;
  end;

  TClientSocket=class(TBaseSocket)
  private
    _socket:TIdTCPClient;
    _ssl_int:TIdSSLIOHandlerSocketOpenSSL;
    _socks_info:TIdSocksInfo;
    //_iohandler:tid
    _compress:TIdCompressorZLib;
    _ssl:Boolean;
    _pendingsend:Boolean;
    _sendqueue:TQueue<tbytes>;
    _compressed:Boolean;
    _connecttimeout:integer;
    _connecttimeouttimer:ttimer;
    _sstls:Boolean;
    _address:string;
    _port:Integer;
    _receivethread:TIdThread;
    _lock:TCriticalSection;
    _thread:TParseThread;


    function FGetConnected:Boolean;

    procedure Receive;
    procedure connectTimeoutTimerDelegate(stateInfo:TObject);
    procedure InitSSL();overload;
    procedure InitSSL(protocol:TObject);overload;
    procedure DisplaySecurityLevel(stream:TObject);
    procedure DisplaySecurityServices(stream:TObject);
    procedure DisplayStreamProperties(stream:TObject);
    procedure DisplayCertificateInformation(stream:TObject);
    //function ValidateCertificate(sender:TObject;
    procedure InitCompression;
    function Compress(bin:TBytes):TBytes;
    function Decompress(bin:TBytes;len:Integer):TBytes;
  public

    constructor Create();virtual;
    property SSL:Boolean read _ssl write _ssl;
    property SupportsStartTls:Boolean read _sstls;
    property Connected:Boolean read FGetConnected;
    property Compressed:Boolean read _compressed write _compressed;
    property Address:string read _address write _address;
    property Port:integer read _port write _port;
    property ConnectTimeout:Integer read _connecttimeout write _connecttimeout;
    procedure Connect(address:string;port:Integer);overload;
    procedure Connect();overload;override;
    procedure Disconnect();override;
    procedure Send(xml:string);overload;override;
    procedure Send(bt:TBytes);overload;override;

    procedure StartTls();override;
    procedure StartCompression;override;
  end;
  TParseThread = class(TIdThread)
    _cs:TClientSocket;
  public
    constructor Create(cs:TClientSocket);
    procedure Run;override;
    procedure Receive;
  end;

implementation

{ TConnectTimeoutException }

constructor TConnectTimeoutException.Create(msg: string);
begin
  inherited Create(msg);
end;

{ TClientSocket }

procedure TClientSocket.Connect(address: string; port: Integer);
begin
  Self.Address:=address;
  self.Port:=port;
  Connect();
end;

function TClientSocket.Compress(bin: TBytes): TBytes;
begin

end;

procedure TClientSocket.Connect;
begin
  try
  _compressed:=False;

  _socket:=TIdTCPClient.Create(nil);
  _socket.UseNagle:=false;
  //_socket.Socket.WriteBufferFlush);
  _socket.Disconnect;
  _socket.Host:=Address;
  _socket.Port:=Port;
  _socket.ConnectTimeout:=_connecttimeout;
  //_thread:=TParseThread.Create(self);
  _socket.Connect;
  FireOnConnect();
  Receive;
  //_receivethread:=TIdThread.Create();
  //_receivethread.FreeOnTerminate:=true;
  //_receivethread.Synchronize(Receive);
  //_receivethread.Resume;
  //_thread.Start;
  except
    on E: Exception do FireOnError(e);

  end;

end;

procedure TClientSocket.connectTimeoutTimerDelegate(stateInfo: TObject);
begin

end;

constructor TClientSocket.Create;
begin
  _lock:=TCriticalSection.Create;
  _sendqueue:=TQueue<tbytes>.Create;
  _sstls:=True;
  _connecttimeout:=10000;

  //_socket.OnConnected:=SocketConnected;
end;

function TClientSocket.Decompress(bin: TBytes; len: Integer): TBytes;
begin

end;

procedure TClientSocket.Disconnect;
begin
  inherited;
  _lock.Acquire;
  _pendingsend:=False;
  _sendqueue.Clear;
  _lock.Release;
  if _socket<>nil then
  begin
    try
      _socket.CheckForGracefulDisconnect(False);
      //if _socket.Connected then
      _socket.Disconnect;
    except

    end;
    FreeAndNil(_socket);
    FireOnDisconnect;
  end;

            if (_thread <> nil) then
            begin
                _thread.Terminate;
                _thread.WaitFor;
                _thread:=nil;
            end;
end;

procedure TClientSocket.DisplayCertificateInformation(stream: TObject);
begin

end;

procedure TClientSocket.DisplaySecurityLevel(stream: TObject);
begin

end;

procedure TClientSocket.DisplaySecurityServices(stream: TObject);
begin

end;

procedure TClientSocket.DisplayStreamProperties(stream: TObject);
begin

end;

function TClientSocket.FGetConnected: Boolean;
begin
  if _socket=nil then
  begin
      Result:=False;
  end
  else
    Result:=_socket.Connected;

end;


procedure TClientSocket.InitCompression;
begin

end;

procedure TClientSocket.InitSSL;
begin

end;

procedure TClientSocket.InitSSL(protocol: TObject);
begin

end;

procedure TClientSocket.Receive;
var
  b:tbytes;
  n:integer;
  s:string;
begin
  inherited;
  while True do
  begin
    if (_socket = nil) then
      exit
    else
    begin
      _socket.CheckForGracefulDisconnect(false);
      if not Connected then begin
        //_cs._socket.CheckForGracefulDisconnect(false);
        _socket:=nil;
      end
      else
      begin
        b:=nil;
        s:=_socket.IOHandler.InputBufferAsString(TEncoding.UTF8);
        n:=Length(s);
        if(n>0)then
        begin
          FireOnReceive(s);
        end;
      end;
    end;
  end;
end;



procedure TClientSocket.Send(bt: TBytes);
var
  i:integer;
  temp:string;
begin
  try
    FireOnSend(bt,Length(bt));
    if _compressed then
    begin

    end;
    if _pendingsend then
      _sendqueue.Enqueue(bt)
    else
    begin
      _pendingsend:=true;
      try
        _socket.Socket.Write(bt);
        if _sendqueue.Count>0 then
          Send(_sendqueue.Dequeue)
        else
          _pendingsend:=False;
      except
        Disconnect;
      end;

    end;
  except

  end;

end;

procedure TClientSocket.StartCompression;
begin
  inherited;

end;

procedure TClientSocket.StartTls;
var
  fp,err:string;
begin
  inherited;
  //fp:=_socket.IOHandler.AllData();
  _ssl_int:=TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  _ssl_int.UseNagle:=False;
  //_ssl_int.SSLOptions:=false;
   with _ssl_int do begin
        SSLOptions.Mode := sslmClient;
        SSLOptions.Method :=  sslvSSLv3;

        // TODO: get certs from profile, that would be *cool*.
       // SSLOptions.CertFile := '';
        //SSLOptions.RootCertFile := '';

        if not DirectoryExists('d:\cer') then
          CreateDirectory('d:\cer',nil);
        //if (_ssl_cert <> '') then begin
            SSLOptions.CertFile := 'd:\cer\disha.com.cn.cer';
            //SSLOptions.KeyFile := 'd:\cer\disha.com.cn.key';
        //end;

        // TODO: Add verification options here!
    end;
    _ssl_int.SSLOptions.VerifyDepth:=2;
    //_ssl_int.Connected:=true;
  //_ssl_int.Host:=Address;
  //_ssl_int.Port:=port;
  //_ssl_int.Open;
  //_ssl_int.StartSSL;
  //_ssl_int.Open;
  //_ssl_int.SSLSocket:=TIdSSLSocket.Create(nil);
  //_ssl_int.
  _socket.IOHandler:=_ssl_int;
  _socket.Connect;
  _ssl_Int.PassThrough:=false;
  //_socket.
  //if (TIdSSLIOHandlerSocketOpenSSL(_socket.Socket).SSLSocket.PeerCert=nil) then
    //fp:=_ssl_int.SSLSocket.PeerCert.FingerprintAsString;
end;

procedure TClientSocket.Send(xml: string);
var
  i:integer;
  temp:string;
  bt:TBytes;
begin
  if _socket=nil then
  exit;
  _lock.Acquire;
  bt:=BytesOf(UTF8Encode(xml));
  try
    FireOnSend(bt,Length(bt));
    if _compressed then
    begin

    end;
    if _pendingsend then
      _sendqueue.Enqueue(bt)
    else
    begin
      _pendingsend:=true;
      try
        //_socket.IOHandler.WriteBufferOpen;
        _socket.IOHandler.Write(xml,TEncoding.UTF8);  //,TEncoding.UTF8
        //_socket.IOHandler.WriteBufferFlush;
        //_socket.IOHandler.WriteBufferClose;
        if _sendqueue.Count>0 then
          Send(_sendqueue.Dequeue)
        else
          _pendingsend:=False;
      except
        Disconnect;
      end;

    end;
  finally
    _lock.Release;

  end;

end;




{ TParseThread }

constructor TParseThread.Create(cs: TClientSocket);
begin
  inherited Create(true);
  _cs:=cs;
end;

procedure TParseThread.Receive;
var
  b:tbytes;
  n:integer;
  s:string;
begin
  inherited;
  if (Self.Terminated) then exit;
  if (_cs=nil)or(_cs._socket = nil) then
    Self.Terminate
  else
  begin
  _cs._socket.CheckForGracefulDisconnect(false);
  if not _cs.Connected then begin
    //_cs._socket.CheckForGracefulDisconnect(false);
    _cs._socket:=nil;
    Self.Terminate;
  end
  else
  begin
  b:=nil;
    //_cs._socket.IOHandler.InputBuffer.ExtractToBytes(b);
    //_cs._socket.IOHandler.CheckForDataOnSource(10);
    s:=_cs._socket.IOHandler.InputBufferAsString(TEncoding.UTF8);
    //n:=_cs._socket.IOHandler.InputBuffer.Size;
    n:=Length(s);
    if(n>0)then
    begin
      //_socket.IOHandler.ReadBytes(b,n);
      //s:=_cs._socket.IOHandler.ReadString(n,TEncoding.UTF8);

      //if (n=7) then
      //  if  (stringof(b)=#$15#3#1#0#2#2'P') then
      //     exit;
      _cs.FireOnReceive(s);

    end;
  end;
  end;

end;

procedure TParseThread.Run;
begin
  inherited;
  (receive);
end;


end.
