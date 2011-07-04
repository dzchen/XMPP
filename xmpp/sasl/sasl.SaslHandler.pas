unit sasl.SaslHandler;

interface
uses
  XMPPEvent,XMPPConst,sasl.Mechanism,Classes,Element,IQ,Jid,SessionIq,Bind,BindIq,protocol.stream.Features,sasl.SaslEventArgs,SysUtils,SaslFactory
  ,protocol.sasl,protocol.sasl.Mechanism,XmppClientConnection;
type
  TSaslHandler=class
  private
    _mechanism:sasl.Mechanism.TMechanism;
    _connection:TXmppClientConnection;
    disposed:Boolean;

    FOnSaslStart:SaslEventHandler;
    FOnSaslEnd:tnotifyevent;
    procedure DoBind();
    procedure BindResult(sender:TObject;iq:TIQ;data:string);
    procedure SessionResult(sender:TObject;iq:TIQ;data:string);

  public
    property OnSaslStart:SaslEventHandler read FOnSaslStart write FOnSaslStart;
    property OnSaslEnd:TNotifyEvent read FOnSaslEnd write FOnSaslEnd;
    constructor Create(conn:TXmppClientConnection);
    destructor Destroy;override;
    procedure OnStreamElement(sender:TObject;e:TElement);

  end;

implementation

{ TSaslHandler }

procedure TSaslHandler.BindResult(sender: TObject; iq: TIQ; data: string);
var
  bind:TElement;
  jid:TJid;
  siq:TSessionIq;
begin
  if iq.IqType='result' then
  begin
    bind:=iq.SelectSingleElement(Tbind.ClassInfo);
    if Assigned(bind) then
    begin
      jid:=TBind(bind).Jid;
      _connection.Resource:=jid.resource;
      _connection.UserName:=jid.user;
    end;
    _connection.DoChangeXmppConnectionState(Binded);
    _connection.Binded:=true;
    _connection.DoRaiseEventBinded;
    _connection.DoChangeXmppConnectionState(StartSession);
    siq:=TSessionIq.Create('set',TJID.Create(_connection.Server));
    _connection.IqGrabber.SendIq(siq,sessionresult,'');
  end
  else if iq.IqType='error' then
  begin

  end;
end;

constructor TSaslHandler.Create(conn:TXmppClientConnection);
begin
  _connection:=conn;
  _connection.StreamParser.OnStreamElement.Add(OnStreamElement);
end;

destructor TSaslHandler.Destroy;
begin
  _connection.StreamParser.OnStreamElement.Remove(OnStreamElement);
  _mechanism.Free;
  _mechanism:=nil;
end;

procedure TSaslHandler.DoBind;
var
  biq:TBindIQ;
begin
  _connection.DoChangeXmppConnectionState(Binding);
  if (_connection.Resource='') then
    biq:=TBindIq.Create('set',TJID.Create(_connection.Server))
  else
    biq:=TBindIq.Create('set',tjid.Create(_connection.Server),_connection.Resource);
  _connection.IqGrabber.SendIq(biq,Bindresult,'');
end;

procedure TSaslHandler.OnStreamElement(sender: TObject; e: TElement);
var
  f:TFeatures;
  args:TSaslEventArgs;
  biq:TBindIq;
begin
  if (_connection.XmppConnectionState=Securing)or(_connection.XmppConnectionState=StartCompression) then
    exit;
  if e is TFeatures then
  begin
    f:=TFeatures(e);
    if not _connection.Authenticated then
    begin
      args:=TSaslEventArgs.Create(f.Mechanisms);
      if Assigned(FOnSaslStart) then
        FOnSaslStart(self,args);
      if args.Auto then
      begin
        if Assigned(f.Mechanisms) then
        begin
          if (_connection.UseStartTLS=False) and (_connection.UseSSL=False) and f.Mechanisms.SupportsMechanism(MTX_GOOGLE_TOKEN) then
            args.Mechanism:=TMechanism.GetMechanismName(MTX_GOOGLE_TOKEN)
          else if f.Mechanisms.SupportsMechanism(MTDIGEST_MD5) then
            args.Mechanism:=TMechanism.GetMechanismName(MTDIGEST_MD5)
          else if f.Mechanisms.SupportsMechanism(MTPLAIN) then
            args.Mechanism:=TMechanism.GetMechanismName(MTPLAIN)
          else
            args.Mechanism:='';
        end
        else
          args.Mechanism:='';
      end;
      if args.Mechanism<>'' then
      begin
        _mechanism:=TSaslFactory.GetMechanism(args.Mechanism);
        _mechanism.Username:=_connection.UserName;
        _mechanism.Password:=_connection.Password;
        _mechanism.Server:=_connection.Server;
        _mechanism.Init(_connection);
      end
      else
        _connection.RequestLoginInfo;
    end
    else if not _connection.Binded then
    begin
      if f.SupportsBind then
      begin
        _connection.DoChangeXmppConnectionState(Binding);
        if (_connection.Resource='') then
          biq:=TBindIq.Create('set',TJID.Create(_connection.Server))
        else
          biq:=TBindIq.Create('set',tjid.Create(_connection.Server),_connection.Resource);
        _connection.IqGrabber.SendIq(biq,BindResult);
      end;
    end;
  end
  else if e is TChallenge then
  begin
    if Assigned(_mechanism) and (not _connection.Authenticated) then
      _mechanism.Parse(e);
  end
  else if e is TSuccess then
  begin
    if Assigned(FOnSaslEnd) then
      FOnSaslEnd(Self);
    _connection.DoChangeXmppConnectionState(Authenticated);
    FreeAndNil(_mechanism);
    _connection.ReSet();
  end
  else if e is TFailure then
    _connection.FireOnAuthError(e);
end;

procedure TSaslHandler.SessionResult(sender: TObject; iq: TIQ; data: string);
begin
  if iq.IqType='result' then
  begin
    _connection.DoChangeXmppConnectionState(SessionStarted);;
    _connection.RaiseOnLogin();
  end;
end;

end.
