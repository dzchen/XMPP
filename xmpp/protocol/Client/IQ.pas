unit IQ;

interface
uses
  Stanza,NativeXml,jid,Element,error,vcard,bind,session,XmppUri,XMPPConst;
const
  IqType:array[0..3] of string=('get',
		'set',
		'result',
		'error');
type
  TIQ=class(TStanza)
  private
    procedure FSetIqType(value:string);
    function FGetIqType:string;
    function FGetQuery:TElement;
    procedure FSetError(value:TError);
    function FGetError:TError;
    procedure FSetVcard(value:TVcard);
    function FGetVcard:TVcard;
    procedure FSetBind(value:TBind);
    function FGetBind:TBind;
    procedure FSetSession(value:TSession);
    function FGetSession:TSession;
  protected
    procedure FSetQuery(value:TElement);
  public
    constructor Create();override;
    constructor Create(iqtype:string);overload;
    constructor Create(fromjid:TJID;tojid:TJID);overload;
    constructor Create(iqtype:string;fromjid:TJID;tojid:TJID);overload;
    property IqType: string read FGetIqType write FSetIqType;
    property Query:TElement read FGetQuery write FSetQuery;
    property Error:TError read FGetError write FSetError;
    property Vcard:TVcard read FGetVcard write FSetVcard;
    property Bind:TBind read FGetBind write FSetBind;
    property Session:TSession read FGetSession write FSetSession;

  end;
implementation

{ TIQ }

constructor TIQ.Create(fromjid, tojid: TJID);
begin
  Self.Create();
  self.FromJid:=fromjid;
  self.ToJid:=tojid;
end;

constructor TIQ.Create(iqtype: string);
begin
  self.Create();
  self.IqType:=iqtype;
end;

constructor TIQ.Create();
begin
  inherited Create();
  Name:='iq';
  Namespace:=XMLNS_CLIENT;
end;

constructor TIQ.Create(iqtype: string; fromjid,
  tojid: TJID);
begin
  Self.Create();
  self.FromJid:=fromjid;
  self.ToJid:=tojid;
  self.IqType:=iqtype;
end;

function TIQ.FGetBind: TBind;
begin
  Result:=TBind(findnode('bind'));
end;

function TIQ.FGetError: TError;
begin
  Result:=TError(findnode('error'));
end;

function TIQ.FGetIqType: string;
begin
  Result:=AttributeValueByName['type'];
end;

function TIQ.FGetQuery: TElement;
begin
  Result:=TElement(findnode('query'));
end;

function TIQ.FGetSession: TSession;
begin
  Result:=TSession(findnode('session'));
end;

function TIQ.FGetVcard: TVcard;
begin
  Result:=TVcard(findnode('vCard'));
end;

procedure TIQ.FSetBind(value: TBind);
begin
  RemoveTag('bind');
  if(value<>nil)then
    NodeAdd(value);
end;

procedure TIQ.FSetError(value: TError);
begin
  RemoveTag('error');
  if(value<>nil)then
    NodeAdd(value);
end;

procedure TIQ.FSetIqType(value: string);
begin
  SetAttribute('type',value);
end;

procedure TIQ.FSetQuery(value: TElement);
begin
  RemoveTag('query');
  if(value<>nil)then
    NodeAdd(value);
end;

procedure TIQ.FSetSession(value: TSession);
begin
  RemoveTag('session');
  if(value<>nil)then
    NodeAdd(value);
end;

procedure TIQ.FSetVcard(value: TVcard);
begin
  RemoveTag('vCard');
  if(value<>nil)then
    NodeAdd(value);
end;

end.
