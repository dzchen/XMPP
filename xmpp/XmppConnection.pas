unit XmppConnection;

interface
uses
SysUtils ,
//{$ifdef linux}
    //QExtCtrls, IdSSLIntercept,
    //{$else}
    windows, ExtCtrls,StrUtils,NativeXml,
    //{endif}
    IdTCPConnection, IdTCPClient, IdException, IdThread, IdSocks,ClientSocket,stringprep,Element,XMPPEvent,XMPPConst,protocol.Stream
    ,ElementFactory,Xml.StreamParser,SyncObjs,Xml.XmppStreamParser,SynapseSocket;
type
  TXmppConnection=class
  private
    _keepalivetimer:TTimer;
    _port:integer;
    _server,_connectserver,_streamid,_streamversion:string;
    _connectionstate:TXmppConnectionState;
    _clientsocket:TSynapseSocket;
    _SocketConnectionType:TSocketConnectionType;
    _autoresolveconnectserver:Boolean;
    _keepaliveinterval:integer;
    _keepalive:Boolean;
    _streamparse:TStreamParser;
    _lock:TCriticalSection;

    FOnXmppConnectionStateChanged:XmppConnectionStateHandler;
    FOnReadXml:XmlHandler;
    FOnWriteXml:XmlHandler;
    FOnError:ErrorHandler;
    FOnReadSocketData:OnSocketDataHandler;
    FOnWriteSocketData:OnSocketDataHandler;
    procedure FSetServer(value:string);
    procedure FSetSocketConnectionType(value:TSocketConnectionType);
    procedure KeepAliveTick(state:TObject);
    procedure InitSocket();
  protected
    procedure CreateKeepAliveTimer();
    procedure DestroyKeepAliveTimer();
    procedure FireOnReadXml(sender:TObject;xml:string);
    procedure FireOnWriteXml(sender:TObject;xml:string);
    procedure FireOnError(sender:TObject;ex:Exception);
  public
    procedure DoChangeXmppConnectionState(state:TXmppConnectionState);
    constructor Create();overload;virtual;
    constructor Create(contype:TSocketConnectionType);overload;virtual;
    destructor Destroy;override;
    property Port:Integer read _port write _port;
    property Server:string read _server write FSetServer;
    property ConnectServer:string read _connectserver write _connectserver;
    property StreamId:string read _streamid write _streamid;
    property StreamVersion:string read _streamversion write _streamversion;
    property XmppConnectionState:TXmppConnectionState read _connectionstate;
    property ClientSocket:TSynapseSocket read _clientsocket;
    property SocketConnectionType:TSocketConnectionType read _SocketConnectionType write FSetSocketConnectionType;
    property AutoResolveConnectServer:Boolean read _autoresolveconnectserver write _autoresolveconnectserver;
    property KeepAliveInterval:Integer read _keepaliveinterval write _keepaliveinterval;
    property KeepAlive:Boolean read _keepalive write _keepalive;
    property StreamParser:TStreamParser read _streamparse;

    property OnXmppConnectionStateChanged:XmppConnectionStateHandler read FOnXmppConnectionStateChanged write FOnXmppConnectionStateChanged;
    property OnReadXml:XmlHandler read FOnReadXml write FOnReadXml;
    property OnWriteXml:XmlHandler read FOnWriteXml write FOnWriteXml;
    property OnError:ErrorHandler read FOnError write FOnError;
    property OnReadSocketData:OnSocketDataHandler read FOnReadSocketData write FOnReadSocketData;
    property OnWriteSocketData:OnSocketDataHandler read FOnWriteSocketData write FOnWriteSocketData;


    procedure SocketOnConnect(sender:TObject);virtual;
    procedure SocketOnDisconnect(sender:TObject);virtual;
    procedure SocketOnReceive(sender:TObject; xml:string);virtual;
    procedure SocketOnBufferReceive(sender:TObject; bt:TBytes;len:Integer);virtual;
    procedure SocketOnError(sender:TObject;ex:Exception);virtual;
    procedure StreamParserOnStreamStart(sender:TObject;e:TElement);virtual;
    procedure StreamParserOnStreamEnd(sender:TObject;e:TElement);virtual;
    procedure StreamParserOnStreamElement(sender:TObject;e:TElement);virtual;
    procedure StreamParserOnStreamError(sender:TObject;e:Exception);virtual;
    procedure StreamParserOnError(sender:TObject;e:Exception);virtual;
    procedure SocketConnect(); overload;virtual;
    procedure SocketConnect(server:string;port:Integer);overload;
    procedure SocketDisconnect();
    procedure Send(xml:string);overload;
    procedure Send(el:telement);overload;virtual;
    procedure Open(xml:string);
    procedure Close();virtual;
  end;
  
implementation

{ TXmppConnection }

procedure TXmppConnection.Close;
begin
  Send('</stream:stream>');
end;

constructor TXmppConnection.Create;
var
  sock:TIdSocksInfo;
begin

  _port:=5222;
  _streamversion:='1.0';
  _connectionstate:=Disconnected;
  _SocketConnectionType:=Direct;
  _keepaliveinterval:=120;
  _keepalive:=true;
  _lock:=TCriticalSection.Create;
  InitSocket;
  _streamparse:=TStreamParser.Create;
  _streamparse.OnStreamStart:=StreamParserOnStreamStart;
  _streamparse.OnStreamEnd:= StreamParserOnStreamEnd;
  _streamparse.OnStreamElement.Add(StreamParserOnStreamElement);
  _streamparse.OnStreamError:=StreamParserOnStreamError;
  _streamparse.OnError:=StreamParserOnError;
end;

constructor TXmppConnection.Create(contype: TSocketConnectionType);
begin
  self.Create;
  _SocketConnectionType:=Direct;
end;

procedure TXmppConnection.CreateKeepAliveTimer;
begin
  if not Assigned(_keepalivetimer) then
  begin
    _keepalivetimer:=TTimer.Create(nil);
    _keepalivetimer.Interval:=_keepaliveinterval*1000;
    _keepalivetimer.OnTimer:=KeepAliveTick;
  end;
  _keepalivetimer.Enabled:=false;
  _keepalivetimer.Enabled:=true;
end;

destructor TXmppConnection.Destroy;
begin
  _lock.Free;
  DestroyKeepAliveTimer;
  Close;
  SocketDisconnect;
  
end;

procedure TXmppConnection.DestroyKeepAliveTimer;
begin
  if not Assigned(_keepalivetimer) then
    exit;
  _keepalivetimer.Enabled:=false;
  _keepalivetimer.Free;
  _keepalivetimer:=nil;
end;

procedure TXmppConnection.DoChangeXmppConnectionState(
  state: TXmppConnectionState);
begin
  _connectionstate:=state;
  if Assigned(FOnXmppConnectionStateChanged) then
    FOnXmppConnectionStateChanged(self,state);
end;

procedure TXmppConnection.FireOnError(sender: TObject; ex: Exception);
begin
  if Assigned(FOnError) then
    FOnError(sender,ex);
end;

procedure TXmppConnection.FireOnReadXml(sender: TObject; xml: string);
begin
  if Assigned(FOnReadXml) then
    FOnReadXml(sender,xml);
end;

procedure TXmppConnection.FireOnWriteXml(sender: TObject; xml: string);
begin
  if Assigned(FOnWriteXml) then
    FOnWriteXml(sender,xml);
end;

procedure TXmppConnection.FSetServer(value: string);
begin
  if value<>'' then
    _server:=xmpp_nameprep(value);
end;

procedure TXmppConnection.FSetSocketConnectionType(
  value: TSocketConnectionType);
begin
  _SocketConnectionType:=value;
  InitSocket;
end;

procedure TXmppConnection.InitSocket;
begin
  if _SocketConnectionType=Direct then
    _clientsocket:=TSynapseSocket.Create;
  _clientsocket.OnConnect:=SocketOnConnect;
  _clientsocket.OnDisconnect:=socketondisconnect;
  //_clientsocket.OnReceive:=socketonreceive;
  _clientsocket.OnReceivexml:=socketonreceive;
  _clientsocket.OnBufferReceive:=SocketOnBufferReceive;
  _clientsocket.OnError:=socketonerror;

end;

procedure TXmppConnection.KeepAliveTick(state: TObject);
begin
  Send(' ');
end;

procedure TXmppConnection.Open(xml: string);
begin
  Send(xml);
end;

procedure TXmppConnection.SocketConnect;
begin
  DoChangeXmppConnectionState(Connecting);
  _clientsocket.Connect();
end;

procedure TXmppConnection.Send(el: telement);
begin
  Send(el.WriteToString);
end;

procedure TXmppConnection.Send(xml: string);
var
  bt:tbytes;
begin
  FireOnWriteXml(Self,xml);
  _clientsocket.Send(xml);
  if Assigned(FOnWriteSocketData) then
  begin
    bt:=BytesOf(UTF8Encode(xml));
    FOnWriteSocketData(self,bt,Length(bt));
  end;
  if _keepalive and (not Assigned(_keepalivetimer)) then
    CreateKeepAliveTimer;
end;

procedure TXmppConnection.SocketConnect(server: string; port: Integer);
begin
  _clientsocket.Address:=server;
  _clientsocket.Port:=port;
  SocketConnect;
end;

procedure TXmppConnection.SocketDisconnect;
begin
  _clientsocket.Disconnect;
end;

procedure TXmppConnection.SocketOnBufferReceive(sender: TObject; bt: TBytes;
  len: Integer);
begin
  //if Assigned(FOnReadSocketData) then
    //FOnReadSocketData(Self,bt,len);
end;

procedure TXmppConnection.SocketOnConnect(sender: TObject);
begin
  DoChangeXmppConnectionState(Connected);
end;

procedure TXmppConnection.SocketOnDisconnect(sender: TObject);
begin

end;

procedure TXmppConnection.SocketOnError(sender: TObject; ex: Exception);
begin

end;

procedure TXmppConnection.SocketOnReceive(sender: TObject; xml:string);
var
  el:TElement;
  bt:TBytes;
begin
  if Assigned(FOnReadSocketData) then
  begin
    bt:=BytesOf(xml);
    FOnReadSocketData(Self,bt,Length(bt));
  end;
  _lock.Acquire;
  try
  _streamparse.Push(xml);
  finally
  _lock.Release;
  end;

end;

procedure TXmppConnection.StreamParserOnError(sender: TObject; e: Exception);
begin
  FireOnError(self,e);
end;

procedure TXmppConnection.StreamParserOnStreamElement(sender: TObject;
  e: TElement);
begin
  FireOnReadXml(Self,e.WriteToString);
end;

procedure TXmppConnection.StreamParserOnStreamEnd(sender: TObject; e: TElement);
var
  tag:TElement;
  qname,xml:string;
begin
  tag:=TElement(e);
  if tag.Prefix='' then
    qname:=tag.Name
  else
    qname:=tag.Prefix+':'+tag.Name;
  xml:='</'+qname+'>';
  FireOnReadXml(self,xml);
end;

procedure TXmppConnection.StreamParserOnStreamError(sender: TObject;
  e: Exception);
begin

end;

procedure TXmppConnection.StreamParserOnStreamStart(sender: TObject;
  e: TElement);
var
  xml:string;
  st:protocol.stream.TStream;
begin
  xml:=e.WriteToString;
  xml:=AnsiMidStr(xml,1,Length(xml)-1)+'>';
  FireOnReadXml(self,xml);
  st:=protocol.Stream.TStream(e);
  if st<>nil then
  begin
    _streamid:=st.StreamId;
    _streamversion:=st.Version;
  end;
end;



end.
