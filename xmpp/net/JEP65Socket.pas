unit JEP65Socket;

interface
uses
  Net.BaseSocket,Jid,Classes,Forms,blcksock,SyncObjs,SysUtils,SecHash,Generics.Collections,protocol.extensions.bytestreams,IQ,Element;
type
  TJEP65Socket=class;
  TTCPThread=class(TThread)
  const
    BUFFERSIZE=1024;
  private
    sock:TTCPBlockSocket;
    FOwner:TJEP65Socket;
    FData:string;
    FErrMsg:string;
    _readbuffer:TBytes;
    _lock:TCriticalSection;
    _bytesTransmitted:Int64;
    procedure SendAuth();
    procedure AuthReceive();
    procedure RequestProxyConnection();
    procedure OnReadVariableResponseReceive();
    procedure Receve();
    procedure AuthReceiveServer;
    procedure RequestProxyConnectionReceiveServer;
    procedure SendRequestProxyConnectionReply;
  protected
    procedure Execute;override;
    procedure DoAfterConnect(Sender:TObject);
    procedure SyncOnConnect;
    procedure SyncOnDisconnect;
    procedure SyncOnData;
    procedure SyncOnError;
    procedure SyncOnProgress;
    procedure SockCallback(Sender: TObject; Reason: THookSocketReason;
        const Value: string);
  public
    constructor Create(AOwner:TJEP65Socket);
    destructor Destroy;override;
  end;
  TJEP65Socket=class(TBaseSocket)
  private
    FTCPHandle,
    FCommands:TList;
    _bTimeout,_socksconnected,_supportsstarttls,_ssl:Boolean;
    _sid:string;
    _id:string;
    _direct:integer;
    _initiator,_target:TJID;
    _lock:TCriticalSection;
    _bs: protocol.extensions.bytestreams.Tbytestream;
    _host:protocol.extensions.bytestreams.TStreamHost;
    function BuildHash():string;

  protected
    procedure CreateTCPThread;
    procedure FreeTCPThread;
    procedure PushCommand(Value:TTCPCommand);
    function  PopCommand:TTCPCommand;
  public
    property SID:string read _sid write _sid;
    property ID:string read _id write _id;
    property Initiator:TJID read _initiator write _initiator;
    property Target:TJID read _target write _target;
    property BytesStream:protocol.extensions.bytestreams.Tbytestream read _bs write _bs;
    property ByteHost:protocol.extensions.bytestreams.TStreamHost read _host;
    constructor Create();overload;
    constructor Create(dir:integer);overload;
    destructor Destroy;override;
    property SSL:Boolean read _ssl;
    property SupportsStartTls:Boolean read _supportsstarttls;
    property Connected:Boolean read _socksconnected;
    procedure Listen(port:Integer);
    procedure Connect();override;
    procedure DisConnect();override;
    procedure Send(data:string);overload;override;
    procedure Send(bdata:TBytes);overload;override;

    procedure SendFile(fs:TFileStream);
  end;

implementation

{ TJEP65Socket }

function TJEP65Socket.BuildHash: string;
begin
  result:=TSecHash.Sha1Hash(_sid+_initiator.ToString+_target.ToString);
end;

procedure TJEP65Socket.Connect;
var C:TTCPCommand;
begin
  if Connected then
    Exit;
  C := TTCPCommand.Create;
  C.Info.Host := address;
  C.Info.Port := port;
  C.Status := tsConnect;
  PushCommand(C);
end;

constructor TJEP65Socket.Create;
begin
  _bTimeout:=False;
  _socksconnected:=false;
  _ssl:=false;
  _supportsstarttls:=false;
  _lock:=TCriticalSection.Create;
  FTCPHandle := TList.Create;
  FCommands := TList.Create;
end;

constructor TJEP65Socket.Create(dir: integer);
begin
  Self.Create;
  _direct:=dir;
end;

procedure TJEP65Socket.CreateTCPThread;
var FThread:TTCPThread;
begin
  FThread := TTCPThread.Create(Self);
  FThread.Resume;
  FTCPHandle.Add(FThread);
end;

destructor TJEP65Socket.Destroy;
var i:integer;
begin
  FreeTCPThread;
  FTCPHandle.Free;
  for i:=0 to FCommands.Count-1 do
    TTCPCommand(FCommands[i]).Free;
  FCommands.Free;
  _lock.Free;
  inherited;
end;

procedure TJEP65Socket.DisConnect;
var C:TTCPCommand;
begin
  if not Connected then
    Exit;
  C := TTCPCommand.Create;
  C.Status := tsDisconnect;
  PushCommand(C);
end;

procedure TJEP65Socket.FreeTCPThread;
var i:integer;
begin
  for i:=0 to FTCPHandle.Count-1 do
  begin
    TTCPThread(FTCPHandle[i]).Terminate;
    // TODO
    {$IFDEF WIN32}
    TTCPThread(FTCPHandle[i]).WaitFor;
    {$ENDIF}
    TTCPThread(FTCPHandle[i]).Free;
  end;
end;

procedure TJEP65Socket.Listen(port: Integer);
var C:TTCPCommand;
begin
  if not Connected then
    Exit;
  C := TTCPCommand.Create;
  C.Status := tsListen;
  c.Data:=IntToStr(port);
  PushCommand(C);
end;

function TJEP65Socket.PopCommand: TTCPCommand;
begin
  _lock.Enter;
  if FCommands.Count>0 then
  begin
    Result := TTCPCommand(FCommands[0]);
    FCommands.Delete(0);
  end else
  Result := nil;
  _lock.Leave;
end;

procedure TJEP65Socket.PushCommand(Value: TTCPCommand);
begin
  if FTCPHandle.Count < 1 then
    CreateTCPThread;
  _lock.Enter;
  FCommands.Add(Value);
  _lock.Leave;
end;

procedure TJEP65Socket.Send(data: string);
var C:TTCPCommand;
begin
  if not Connected then
    Exit;
  inherited;
  C := TTCPCommand.Create;
  C.Status := tsData;
  C.Data := Data;
  PushCommand(C);
end;

procedure TJEP65Socket.Send(bdata: TBytes);
var C:TTCPCommand;
begin
  if not Connected then
    Exit;
  inherited;
  C := TTCPCommand.Create;
  C.Status := tsBufData;
  C.BData := bdata;
  PushCommand(C);
end;


procedure TJEP65Socket.SendFile(fs: TFileStream);
var C:TTCPCommand;
begin
  if not Connected then
    Exit;
  inherited;
  C := TTCPCommand.Create;
  C.Status := tsBufData;
  C.FileStream := fs;
  PushCommand(C);
end;

{ TTCPThread }

procedure TTCPThread.AuthReceive;
var
  x:Integer;
begin
  if sock.CanRead(1000) then
  begin
    x:=sock.WaitingData;
    if x>0 then
    begin
      SetLength(_readbuffer,x);
      x:=sock.RecvBuffer(_readbuffer,x);
      if x<>2 then
        raise Exception.Create('Bad response received from proxy server.');
      SetLength(_readbuffer,x);
      if _readbuffer[1]=$FF then
      begin
        sock.CloseSocket;
        raise Exception.Create('None of the authentication method was accepted by proxy server.');
      end;
      if _readbuffer[1]=$02 then
      begin

      end;
      RequestProxyConnection;
    end;
  end;
end;

procedure TTCPThread.AuthReceiveServer;
var
  bt:TBytes;
  x,i,nmethods:integer;
  methods:TDictionary<integer,Integer>;
begin
  SetLength(bt,BUFFERSIZE);
  x:=sock.RecvBuffer(bt,BUFFERSIZE);
  SetLength(bt,x);
  if bt[0]<>$05 then
    raise Exception.Create('wrong proxy version');
  nmethods:=bt[1];
  methods:=TDictionary<integer,Integer>.create;
  for i := 2 to nmethods+2 do
    methods.Add(Integer(bt[i]),Integer(bt[i]));
  SetLength(bt,2);
  bt[0]:=5;
  if(methods.ContainsKey(0))then
    bt[1]:=0
  else
    bt[1]:=$FF;
  sock.SendBuffer(bt,2);
  RequestProxyConnectionReceiveServer;
end;

constructor TTCPThread.Create(AOwner: TJEP65Socket);
begin
  inherited Create(True);
  _lock:=TCriticalSection.Create;
  FOwner := AOwner;
  sock := TTCPBlockSocket.Create;
  sock.OnStatus := SockCallback;
  sock.OnAfterConnect := DoAfterConnect;
end;

destructor TTCPThread.Destroy;
begin
  sock.Free;
  inherited;
end;

procedure TTCPThread.DoAfterConnect(Sender: TObject);
begin
  if FOwner._direct=1 then
  Synchronize(SyncOnConnect)
  else
  sendauth;
end;

procedure TTCPThread.Execute;
const
  YAHOO_DATA_MAX = 65535 +20;
var
  J,C:TTCPCommand;
  s:string;
  x:integer;
  shost:TStreamHost;
  el:TList<TElement>;
  i,n:integer;
begin
  while not Terminated do begin
    J := FOwner.PopCommand;
    if Assigned(J) then
    begin
      if (TTCPCommand(J).Status=tsConnect) then
      begin

        if FOwner._direct=1 then
        begin
          sock.Connect(J.Info.Host,inttostr(J.Info.Port));
        end
        else
        begin
          el:=FOwner._bs.GetStreamHost;
          n:=el.Count;
          for i := 0 to n-1 do
          begin
            shost:=TStreamHost(el[i]);
            FOwner.Address:=shost.Host;
            FOwner.Port := sHost.Port;
            FOwner._host:=shost;
            sock.Connect(shost.Host,inttostr(shost.Port));
            if FOwner.Connected then
            begin
              //FOwner.SendStreamHostUsedResponse(shost);

              Break;
            end;
          end;
        end;

        //sock.Connect(J.Info.Host,inttostr(J.Info.Port));
        //SendAuth();
        while (sock.LastError=0) and (not Terminated) do
        begin

          C := FOwner.PopCommand;
          if Assigned(C) then begin
            case TTCPCommand(C).Status of
              tsDisconnect:
                begin
                  sock.CloseSocket;
                  Break;
                end;
              tsData:
                sock.SendString(TTCPCommand(C).Data);
              tsListen:
              begin
                sock.Bind(cAnyHost,TTCPCommand(C).Data);
                sock.Listen;
                sock.Accept;

              end;
              tsFileStream:
              begin
                sock.SendMaxChunk:=BUFFERSIZE;
                _bytesTransmitted:=0;
                sock.SendStream(TTCPCommand(C).FileStream);
                sock.CloseSocket;
              end;
            end;
            C.Free;
          end;
          if sock.CanRead(20) then
          begin
            x:=sock.WaitingData;
            if x>0 then
            begin
              SetLength(_readbuffer,x);
              x:=sock.RecvBuffer(_readbuffer,x);
              SetLength(_readbuffer,x);
              if (sock.LastError=0) and (Length(_readbuffer)>0) then
              Synchronize(SyncOnData);
            end;

            {FData:= sock.RecvPacket(0);
            bt:=BytesOf(fdata);
            //FData:=AnsiToUtf8(fdata);
            FData:=utf8.GetString(BytesOf(fdata));
            if (sock.LastError=0) and (Length(FData)>0) then
              Synchronize(SyncOnData);   }
          end;
        end;
        sock.CloseSocket;
      end;
      J.Free;
    end else
    Sleep(200);
  end;
end;


procedure TTCPThread.Receve;
begin

end;

procedure TTCPThread.RequestProxyConnection;
var
  hash:string;
  len,i:integer;
  buffer:tbytes;
  temp:tbytes;
begin
  hash:=FOwner.BuildHash;
  len:=Length(hash);
  SetLength(buffer,len+7);
   buffer[0] := 5; // protocol version.
   buffer[1] := 1; // connect
   buffer[2] := 0; // reserved.
   buffer[3] := 3; // DOMAINNAME
   buffer[4] := Byte(len);
   temp:=BytesOf(hash);
   for i := 0 to len-1 do
     buffer[i+5]:=temp[i];
   buffer[5 + len] := 0;
   buffer[6 + len] := 0;
   sock.SendBuffer(buffer,Length(buffer));
   OnReadVariableResponseReceive;
end;

procedure TTCPThread.RequestProxyConnectionReceiveServer;
var
  bt,temp:TBytes;
  x,i,lengthvariable:integer;
  hash,hash2:string;
begin
  SetLength(bt,BUFFERSIZE);
  x:=sock.RecvBuffer(bt,BUFFERSIZE);
  SetLength(bt,x);
  if bt[0]<>5 then
    raise Exception.Create('wrong proxy version');
  if bt[1]<>1 then
    raise Exception.Create('');
  if bt[2]<>0 then
    raise Exception.Create('');
  if bt[3]<>$03 then
    raise Exception.Create('');
  lengthvariable:=bt[4];
  for i := 5 to lengthvariable do
    temp[i-5]:=bt[i];
  hash:=StringOf(temp);
  hash2:=FOwner.BuildHash;
  if  LowerCase(hash)<>LowerCase(hash2) then
    raise Exception.Create('Hash does not match');
  SetLength(bt,lengthvariable+7);
  bt[0]:=5;
  bt[1]:=0;
  bt[2]:=0;
  bt[3]:=3;
  bt[4]:=Byte(lengthvariable);
  temp:=BytesOf(hash);
  for i := 0 to Length(temp)-1 do
     bt[i+5]:=temp[i];
  bt[5+lengthvariable]:=0;
  bt[6+lengthvariable]:=0;

  FOwner._socksconnected:=true;
  FOwner.FireOnConnect;

end;

procedure TTCPThread.OnReadVariableResponseReceive;
var
  x:Integer;
begin
  if sock.CanRead(1000) then
  begin
    x:=sock.WaitingData;
    if x>0 then
    begin
      SetLength(_readbuffer,x);
      x:=sock.RecvBuffer(_readbuffer,x);
      SetLength(_readbuffer,x);
      if _readbuffer[0]<>5 then
      begin
      //'bogus version in reply from proxy: ' + m_ReadBuffer[0]
      end;
      if _readbuffer[1]<>0 then
      begin
        //'request failed on proxy: ' + m_ReadBuffer[1])
      end;
      Synchronize(SyncOnConnect);
      
    end;
  end;
end;

procedure TTCPThread.SendAuth;
var
  buffer:TBytes;
begin
  SetLength(buffer,3);
  buffer[0]:=$05;
  buffer[1]:=$01;
  buffer[2]:=$00;
  sock.SendBuffer(buffer,3);
  AuthReceive;
end;

procedure TTCPThread.SendRequestProxyConnectionReply;
begin

end;

procedure TTCPThread.SockCallback(Sender: TObject; Reason: THookSocketReason;
  const Value: string);
begin
  case Reason of
  HR_Error,HR_SocketClose:
    begin
      if FOwner.Connected then
        Synchronize(SyncOnDisconnect)
      else begin
        FErrMsg := Value;
        if Length(FErrMsg)>0 then
          Synchronize(SyncOnError);
      end;
    end;
  HR_WriteCount:
  begin
    Inc(_bytesTransmitted,StrToInt64(value));
  end;
  end;
end;

procedure TTCPThread.SyncOnConnect;
begin
  FOwner._socksconnected := True;
  FOwner.FireOnConnect;
end;

procedure TTCPThread.SyncOnData;
begin
  FOwner.FireOnReceive(_readbuffer,Length(_readbuffer));
end;

procedure TTCPThread.SyncOnDisconnect;
begin
  FOwner._socksconnected := False;
  fowner.FireOnDisconnect;
end;

procedure TTCPThread.SyncOnError;
begin
  FOwner.FireOnError(Exception.Create(FErrMsg));
end;

procedure TTCPThread.SyncOnProgress;
begin
  FOwner.FireOnProgress(_bytesTransmitted);
end;

end.
