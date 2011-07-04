unit PresenceManager;

interface
uses
XmppConnection,Jid,Presence;
type
  TPresenceManager=class
  private
    _connection:TXmppConnection;
  public
    constructor Create(con:TXmppConnection);
    procedure Subscribe(tojid:TJID);overload;
    procedure Subscribe(tojid:TJID;msg:string);overload;
    procedure Unsubscribe(tojid:TJID);
    procedure ApproveSubscriptionRequest(tojid:TJID);
    procedure RefuseSubscriptionRequest(tojid:TJID);

  end;

implementation
uses
  XmppClientConnection;

{ TPresenceManager }




{ TPresenceManager }

procedure TPresenceManager.ApproveSubscriptionRequest(tojid: TJID);
var
  pres:TPresence;
begin
  pres:=TPresence.Create();
  pres.PresenceType:='subscribed';
  pres.ToJid:=tojid;
  _connection.Send(pres);
end;

constructor TPresenceManager.Create(con: TXmppConnection);
begin
  _connection:=TXmppClientConnection(con);
end;

procedure TPresenceManager.RefuseSubscriptionRequest(tojid: TJID);
var
  pres:TPresence;
begin
  pres:=TPresence.Create();
  pres.PresenceType:='unsubscribed';
  pres.ToJid:=tojid;
  _connection.Send(pres);
end;

procedure TPresenceManager.Subscribe(tojid: TJID);
var
  pres:TPresence;
begin
  pres:=TPresence.Create();
  pres.PresenceType:='subscribe';
  pres.ToJid:=tojid;
  _connection.Send(pres);
end;

procedure TPresenceManager.Subscribe(tojid: TJID; msg: string);
var
  pres:TPresence;
begin
  pres:=TPresence.Create();
  pres.PresenceType:='subscribe';
  pres.ToJid:=tojid;
  pres.Status:=msg;
  _connection.Send(pres);
end;

procedure TPresenceManager.Unsubscribe(tojid: TJID);
var
  pres:TPresence;
begin
  pres:=TPresence.Create();
  pres.PresenceType:='unsubscribe';
  pres.ToJid:=tojid;
  _connection.Send(pres);
end;

end.
