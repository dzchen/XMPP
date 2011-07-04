unit MessageGrabber;

interface
uses
  XMPPEvent,PacketGrabber,Jid,XmppConnection,message,JidComparer,EventList;
type
  TMessageGrabber=class(TPacketGrabber)
  private
    procedure OnMessage(sender:TObject;msg:TMessage);
  public
    constructor Create(conn:TXmppConnection);overload;
    procedure Add(jid:TJid;cb:messagecb;cbarg:string);overload;
    procedure Add(jid:TJid;comparer:TBareJidComparer;cb:messagecb;cbarg:string);overload;
    procedure Remove(jid:TJID);

  end;

implementation
uses
  XmppClientConnection;
{ TMessageGrabber }

procedure TMessageGrabber.Add(jid: TJid; cb: messagecb; cbarg: string);
var
  td:TMethod;
  s:string;
  th:TrackerData;
begin
  _lock.Acquire;
  if _grabbing.ContainsKey(jid.tostring) then
    exit;
  _lock.Release;
  td:=ConvertToMethod(cb);
  th.cb:=td;
  th.data:=cbarg;
  th.comparer:=TBareJidComparer.create;
  s:=jid.ToString;
  _lock.Acquire;
  if _grabbing.ContainsKey(s) then
      _grabbing[s]:=th
    else
      _grabbing.Add(s,th);
  _lock.Release;
end;

procedure TMessageGrabber.Add(jid: TJid; comparer: TBareJidComparer;
  cb: messagecb; cbarg: string);
var
  td:TMethod;
  s:string;
  th:TrackerData;
begin
  _lock.Acquire;
  if _grabbing.ContainsKey(jid.tostring) then
    exit;
  _lock.Release;
  td:=ConvertToMethod(cb);
  th.cb:=td;
  th.data:=cbarg;
  th.comparer:=comparer;
  s:=jid.ToString;
  _lock.Acquire;
  if _grabbing.ContainsKey(s) then
      _grabbing[s]:=th
    else
      _grabbing.Add(s,th);
  _lock.Release;
end;

constructor TMessageGrabber.Create(conn: TXmppConnection);
begin
  inherited Create();
  _connection:=conn;
  TXmppClientConnection(_connection).OnMessage.Add(onmessage);
end;

procedure TMessageGrabber.OnMessage(sender: TObject; msg: TMessage);
var
  key:string;
  th:TrackerData;
  td:TMethod;
begin
  if msg=nil then
    exit;
  _lock.Acquire;
  for key in _grabbing.Keys do
  begin
    th:=_grabbing[key];
    if th.comparer.Compare(tjid.Create(''),msg.FromJid)=0 then
    begin
      td:=th.cb;
      if (td.Data<>nil) or (td.Code<>nil) then
      begin
        messagecb(td)(self,msg,th.Data);
      end;
    end;
  end;
 
  _lock.Release;

end;

procedure TMessageGrabber.Remove(jid: TJID);
var
  s:string;
begin
  s:=jid.ToString;
  _lock.Acquire;
  if _grabbing.ContainsKey(s) then
    _grabbing.Remove(s);
  _lock.Release;
end;

end.
