unit protocol.iq.roster.RosterManager;

interface
uses
  Jid,protocol.iq.roster.RosterIq,protocol.iq.roster.RosterItem,XmppConnection;
type
  TRosterManager=class

  public
    constructor Create(con:TXmppConnection);
    procedure RemoveRosterItem(jid:TJID);
    procedure AddRosterItem(jid:TJID);overload;
    procedure UpdateRosterItem(jid:TJID);overload;
    procedure AddRosterItem(jid:TJID;nickname:string);overload;
    procedure UpdateRosterItem(jid:TJID;nickname:string);overload;
    procedure AddRosterItem(jid:TJID;nickname,group:string);overload;
    procedure UpdateRosterItem(jid:TJID;nickname,group:string);overload;
    procedure AddRosterItem(jid:TJID;nickname:string;group:array of string);overload;
    procedure UpdateRosterItem(jid:TJID;nickname:string;group:array of string);overload;
  end;
implementation
uses
  XmppClientConnection;
var
  _connection:TXmppClientConnection;
{ TRosterManager }

procedure TRosterManager.AddRosterItem(jid: TJID; nickname, group: string);
var
  s:array of string;
begin
  SetLength(s,1);
  s[0]:=group;
  AddRosterItem(jid,nickname,s);
end;

procedure TRosterManager.AddRosterItem(jid: TJID;nickname:string; group: array of string);
var
  rid:TRosterIq;
  ri:TRosterItem;
  s:string;
begin
  rid:=TRosterIq.Create;
  rid.IqType:='set';
  ri:=TRosterItem.Create;
  ri.Jid:=jid;
  if nickname<>'' then
    ri.ItemName:=nickname;
  for s in group do
      ri.AddGroup(s);
  rid.Query.AddRosterItem(ri);
  _connection.Send(rid);
end;

procedure TRosterManager.AddRosterItem(jid: TJID; nickname: string);
var
  s:array of string;
begin
  SetLength(s,0);
  AddRosterItem(jid,nickname,s);
end;

procedure TRosterManager.AddRosterItem(jid: TJID);
var
  s:array of string;
begin
  SetLength(s,0);
  AddRosterItem(jid,'',s);
end;

constructor TRosterManager.Create(con: TXmppConnection);
begin
  _connection:=TXmppClientConnection(con);
end;

procedure TRosterManager.RemoveRosterItem(jid: TJID);
var
  riq:TRosterIq;
  ri:TRosterItem;
begin
  riq:=TRosterIq.Create;
  riq.IqType:='set';
  ri:=TRosterItem.Create;
  ri.Jid:=jid;
  ri.Subscription:='remove';
  riq.Query.AddRosterItem(ri);
  _connection.Send(riq);
end;

procedure TRosterManager.UpdateRosterItem(jid: TJID; nickname, group: string);
var
  s:array of string;
begin
  SetLength(s,1);
  s[0]:=group;
  AddRosterItem(jid,nickname,s);
end;

procedure TRosterManager.UpdateRosterItem(jid: TJID;nickname:string; group: array of string);
begin
  AddRosterItem(jid,nickname,group);
end;

procedure TRosterManager.UpdateRosterItem(jid: TJID);
var
  s:array of string;
begin
  SetLength(s,0);
  AddRosterItem(jid,'',s);
end;

procedure TRosterManager.UpdateRosterItem(jid: TJID; nickname: string);
var
  s:array of string;
begin
  SetLength(s,0);
  AddRosterItem(jid,nickname,s);
end;

end.
