unit protocol.iq.disco.DiscoManager;

interface
uses
  XmppClientConnection,IQ,protocol.iq.disco.DiscoInfo,protocol.iq.disco.DiscoItemsIq,Jid,XMPPEvent,protocol.iq.disco.DiscoInfoIq,Element;
type
  TDiscoManager=class
  private
    _autoanswerdiscoinforequests:Boolean;
    _connection:TXmppClientConnection;
    procedure OnIq(sender:TObject;iq:TIQ);
    procedure ProcessDiscoInfo(iq:TIQ);

  public
    constructor Create(conn:TXmppClientConnection);
    property AutoAnswerDiscoInfoRequests:Boolean read _autoanswerdiscoinforequests write _autoanswerdiscoinforequests;

    procedure DiscoverInformation(tojid:TJID);overload;
    procedure DiscoverInformation(tojid,fromjid:TJID);overload;
    procedure DiscoverInformation(tojid:TJID;cb:IqCBElement);overload;
    procedure DiscoverInformation(tojid,fromjid:TJID;cb:IqCBElement);overload;
    procedure DiscoverInformation(tojid:TJID;cb:IqCBElement;cbargs:TElement);overload;
    procedure DiscoverInformation(tojid,fromjid:TJID;cb:IqCBElement;cbargs:TElement);overload;
    procedure DiscoverInformation(tojid:TJID;node:string);overload;
    procedure DiscoverInformation(tojid,fromjid:TJID;node:string);overload;
    procedure DiscoverInformation(tojid:TJID;node:string;cb:IqCBElement);overload;
    procedure DiscoverInformation(tojid,fromjid:TJID;node:string;cb:IqCBElement);overload;
    procedure DiscoverInformation(tojid:TJID;node:string;cb:IqCBElement;cbargs:TElement);overload;
    procedure DiscoverInformation(tojid,fromjid:TJID;node:string;cb:IqCBElement;cbargs:TElement);overload;

    procedure DiscoverItems(tojid:TJID);overload;
    procedure DiscoverItems(tojid,fromjid:TJID);overload;
    procedure DiscoverItems(tojid:TJID;cb:IqCBElement);overload;
    procedure DiscoverItems(tojid,fromjid:TJID;cb:IqCBElement);overload;
    procedure DiscoverItems(tojid:TJID;cb:IqCBElement;cbargs:TElement);overload;
    procedure DiscoverItems(tojid,fromjid:TJID;cb:IqCBElement;cbargs:TElement);overload;
    procedure DiscoverItems(tojid:TJID;node:string);overload;
    procedure DiscoverItems(tojid,fromjid:TJID;node:string);overload;
    procedure DiscoverItems(tojid:TJID;node:string;cb:IqCBElement);overload;
    procedure DiscoverItems(tojid,fromjid:TJID;node:string;cb:IqCBElement);overload;
    procedure DiscoverItems(tojid:TJID;node:string;cb:IqCBElement;cbargs:TElement);overload;
    procedure DiscoverItems(tojid,fromjid:TJID;node:string;cb:IqCBElement;cbargs:TElement);overload;

  end;

implementation


{ TDiscoManager }

constructor TDiscoManager.Create(conn:TXmppClientConnection);
begin
  _autoanswerdiscoinforequests:=true;
  _connection:=conn;
  _connection.OnIq.Add(oniq);
end;

procedure TDiscoManager.DiscoverInformation(tojid: TJID; cb: IqCBElement;
  cbargs: TElement);
begin
  DiscoverInformation(tojid,nil,'',cb,cbargs);
end;

procedure TDiscoManager.DiscoverInformation(tojid, fromjid: TJID; cb: IqCBElement;
  cbargs: TElement);
begin
  DiscoverInformation(tojid,fromjid,'',cb,cbargs);
end;

procedure TDiscoManager.DiscoverInformation(tojid: TJID; node: string);
begin
  DiscoverInformation(tojid,nil,node,IqCBElement(nil),TElement(nil));
end;

procedure TDiscoManager.DiscoverInformation(tojid, fromjid: TJID; cb: IqCBElement);
begin
  DiscoverInformation(tojid,fromjid,'',cb,TElement(nil));
end;

procedure TDiscoManager.DiscoverInformation(tojid: TJID);
begin
  DiscoverInformation(tojid,nil,'',IqCBElement(nil),TElement(nil));
end;

procedure TDiscoManager.DiscoverInformation(tojid, fromjid: TJID);
begin
  DiscoverInformation(tojid,fromjid,'',IqCBElement(nil),TElement(nil));
end;

procedure TDiscoManager.DiscoverInformation(tojid: TJID; cb: IqCBElement);
begin
  DiscoverInformation(tojid,nil,'',cb,TElement(nil));
end;

procedure TDiscoManager.DiscoverInformation(tojid: TJID; node: string; cb: IqCBElement;
  cbargs: TElement);
begin
  DiscoverInformation(tojid,nil,node,cb,cbargs);
end;

procedure TDiscoManager.DiscoverInformation(tojid, fromjid: TJID; node: string;
  cb: IqCBElement; cbargs: TElement);
var
  discoiq:TDiscoInfoIq;
begin
  discoiq:=TDiscoInfoIq.Create('get');
  discoiq.ToJid:=tojid;
  if fromjid<>nil then
    discoiq.FromJid:=fromjid;
  if node<>'' then
    discoiq.Query.Node:=node;
  _connection.IqGrabber.SendIq(discoiq,cb,cbargs);
end;

procedure TDiscoManager.DiscoverInformation(tojid, fromjid: TJID; node: string;
  cb: IqCBElement);
begin
  DiscoverInformation(tojid,fromjid,node,cb,TElement(nil));
end;

procedure TDiscoManager.DiscoverInformation(tojid, fromjid: TJID; node: string);
begin
  DiscoverInformation(tojid,fromjid,node,IqCBElement(nil),TElement(nil));
end;

procedure TDiscoManager.DiscoverInformation(tojid: TJID; node: string;
  cb: IqCBElement);
begin
  DiscoverInformation(tojid,nil,node,cb,TElement(nil));
end;

procedure TDiscoManager.DiscoverItems(tojid: TJID; cb: IqCBElement; cbargs: TElement);
begin
  DiscoverItems(tojid,nil,'',cb,cbargs);
end;

procedure TDiscoManager.DiscoverItems(tojid, fromjid: TJID; cb: IqCBElement;
  cbargs: TElement);
begin
  DiscoverItems(tojid,fromjid,'',cb,cbargs);
end;

procedure TDiscoManager.DiscoverItems(tojid: TJID; node: string);
begin
  DiscoverItems(tojid,nil,node,IqCBElement(nil),TElement(nil));
end;

procedure TDiscoManager.DiscoverItems(tojid, fromjid: TJID; cb: IqCBElement);
begin
  DiscoverItems(tojid,fromjid,'',cb,TElement(nil));
end;

procedure TDiscoManager.DiscoverItems(tojid: TJID);
begin
  DiscoverItems(tojid,nil,'',IqCBElement(nil),TElement(nil));
end;

procedure TDiscoManager.DiscoverItems(tojid, fromjid: TJID);
begin
  DiscoverItems(tojid,fromjid,'',IqCBElement(nil),TElement(nil));
end;

procedure TDiscoManager.DiscoverItems(tojid: TJID; cb: IqCBElement);
begin
  DiscoverItems(tojid,nil,'',cb,TElement(nil));
end;

procedure TDiscoManager.DiscoverItems(tojid: TJID; node: string; cb: IqCBElement;
  cbargs: TElement);
begin
  DiscoverItems(tojid,nil,node,cb,cbargs);
end;

procedure TDiscoManager.DiscoverItems(tojid, fromjid: TJID; node: string;
  cb: IqCBElement; cbargs: TElement);
var
  discoiq:TDiscoItemsIq;
begin
  discoiq:=TDiscoItemsIq.Create('get');
  discoiq.ToJid:=tojid;
  if fromjid<>nil then
    discoiq.FromJid:=fromjid;
  if node<>'' then
    discoiq.Query.Node:=node;
  _connection.IqGrabber.SendIq(discoiq,cb,cbargs);
end;

procedure TDiscoManager.DiscoverItems(tojid, fromjid: TJID; node: string;
  cb: IqCBElement);
begin
  DiscoverItems(tojid,fromjid,node,cb,TElement(nil));
end;

procedure TDiscoManager.DiscoverItems(tojid, fromjid: TJID; node: string);
begin
  DiscoverItems(tojid,fromjid,node,IqCBElement(nil),TElement(nil));
end;

procedure TDiscoManager.DiscoverItems(tojid: TJID; node: string; cb: IqCBElement);
begin
  DiscoverItems(tojid,nil,node,cb,TElement(nil));
end;

procedure TDiscoManager.OnIq(sender: TObject; iq: TIQ);
begin
  if _autoanswerdiscoinforequests and (iq.Query is TDiscoInfo) and (iq.IqType='get') then
    ProcessDiscoInfo(iq);
end;

procedure TDiscoManager.ProcessDiscoInfo(iq: TIQ);
var
  diiq:TIQ;
begin
  diiq:=tiq.Create;
  diiq.ToJid:=iq.FromJid;
  diiq.Id:=iq.Id;
  diiq.IqType:='result';
  diiq.Query:=_connection.DiscoInfo;
  _connection.Send(diiq);

end;

end.
