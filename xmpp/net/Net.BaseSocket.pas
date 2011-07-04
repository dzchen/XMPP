unit Net.BaseSocket;

interface
uses
  XMPPEvent,SysUtils,Classes;
type
  THostInfo = record
    Host: String;
    Port: integer;
    // TODO: Proxy
  end;

  TTCPStatus = (tsConnect, tsDisconnect, tsSSLConnect,{tsSSLDisconnect,}tsData,tsBufData,tsFileStream,tsListen);
  TTCPCommand = class
    Status:TTCPStatus;
    Info:THostInfo;
    Data:string;
    BData:TBytes;
    FileStream:TFileStream;
  end;
  TBaseSocket=class
  private
    _address:string;
    _port:integer;
    _connecttime:Integer;
    FOnReceive:OnSocketDataHandler;
    FOnReceiveXml:OnSocketXmlHandler;
    FOnSend:OnSocketDataHandler;
    FOnError:ErrorHandler;
    FOnDisconnect:TNotifyEvent;
    FOnConnect:TNotifyEvent;
    FOnBufferReceive:OnSocketDataHandler;
    FOnProgress:ProgressEventHandler;

    function FGetConnected:Boolean;virtual;
    function FGetSupportsStartTls:Boolean;virtual;
    function FGetConnectTimeout:Integer;virtual;
    procedure FSetConnectTimeout(value:Integer);virtual;
  protected
    procedure FireOnConnect();
    procedure FireOnDisconnect();
    procedure FireOnReceive(b:tbytes;len:Integer);overload;
    procedure FireOnReceive(xml:string);overload;
    procedure FireOnSend(b:TBytes;len:Integer);
    procedure FireOnError(ex:Exception);
    procedure FireOnProgress(len:Integer);
    //function FireOnValidateCertificate(sender:TObject;

  public
    constructor Create;
    property Address:string read _address write _address;
    property Port:Integer read _port write _port;
    property Connected:Boolean read FGetConnected;
    property SupportsStartTls:Boolean read FGetSupportsStartTls;
    property ConnectTimeout:integer read FGetConnectTimeout write FSetConnectTimeout;
    procedure Connect;virtual;
    procedure Disconnect;virtual;
    procedure StartTls;virtual;
    procedure StartCompression;virtual;
    procedure Reset;virtual;
    procedure Send(data:string);overload;virtual;
    procedure Send(bdata:TBytes);overload;virtual;
    property OnReceive:OnSocketDataHandler read FOnReceive write FOnReceive;
    property OnReceiveXml:OnSocketXmlHandler read FOnReceiveXml write FOnReceiveXml;
    property OnBufferReceive:OnSocketDataHandler read FOnBufferReceive write FOnBufferReceive;
    property OnSend:OnSocketDataHandler read FOnSend write FOnSend;
    property OnError:ErrorHandler read FOnError write FOnError;
    property OnDisconnect:TNotifyEvent read FOnDisconnect write FOnDisconnect;
    property OnConnect:TNotifyEvent read FOnConnect write FOnConnect;
    property OnProgress:ProgressEventHandler read FOnProgress write FOnProgress;
  end;

var
  utf8:TUTF8Encoding;
implementation

{ TBaseSocket }

procedure TBaseSocket.Connect;
begin
//
end;

constructor TBaseSocket.Create;
begin
  _port:=0;
  _connecttime:=10000;
end;

procedure TBaseSocket.Disconnect;
begin
//
end;

function TBaseSocket.FGetConnected: Boolean;
begin
  result:=false;
end;

function TBaseSocket.FGetConnectTimeout: Integer;
begin
  result:=_connecttime;
end;

function TBaseSocket.FGetSupportsStartTls: Boolean;
begin
  result:=false;
end;

procedure TBaseSocket.FireOnConnect;
begin
  if Assigned(FOnConnect) then
    FOnConnect(Self);
end;

procedure TBaseSocket.FireOnDisconnect;
begin
  if Assigned(FOnDisconnect) then
    FOnDisconnect(Self);
end;

procedure TBaseSocket.FireOnError(ex: Exception);
begin
  if Assigned(FOnError) then
    FOnError(Self,ex);
end;

procedure TBaseSocket.FireOnProgress(len: Integer);
begin
  if Assigned(FOnProgress) then
    FOnProgress(Self,len);
end;

procedure TBaseSocket.FireOnReceive(xml: string);
begin
   if Assigned(FOnReceiveXml) then
    FOnReceiveXml(Self,xml);
end;

procedure TBaseSocket.FireOnReceive(b: tbytes; len: Integer);
begin
  if Assigned(FOnReceive) then
    FOnReceive(Self,b,len);
end;

procedure TBaseSocket.FireOnSend(b: TBytes; len: Integer);
begin
  if Assigned(FOnSend) then
    FOnSend(Self,b,len);
end;

procedure TBaseSocket.FSetConnectTimeout(value: Integer);
begin
  _connecttime:=value;
end;

procedure TBaseSocket.Reset;
begin
//
end;

procedure TBaseSocket.Send(bdata: TBytes);
begin
//
end;

procedure TBaseSocket.Send(data: string);
begin
//
end;

procedure TBaseSocket.StartCompression;
begin
//
end;

procedure TBaseSocket.StartTls;
begin
//
end;
initialization
  utf8:=TUTF8Encoding.Create;

end.
