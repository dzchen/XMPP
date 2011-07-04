unit DirectionalElement;

interface
uses
  NativeXml,jid,Element;
type
  TDirectionalElement=class(TElement)
  private
    doc:TNativeXml;
    procedure FSetToJid(jid:Tjid);
    function FGetToJid():TJID;
    procedure FSetFromJid(jid:Tjid);
    function fGetFromJid():TJID;

  public
    procedure SwitchDirection();
    property FromJid:TJid read fGetFromJid write FSetFromJid;
    property ToJid:Tjid read FGetToJid write FSetToJid;
  end;

implementation

{ TDirectionalElement }



function TDirectionalElement.fGetFromJid: TJID;
begin
  if HasAttribute('from') then
    Result:=TJID.Create(AttributeValueByName['from'])
  else
    Result:=nil;
end;

function TDirectionalElement.FGetToJid: TJID;
begin
  if HasAttribute('to') then
    Result:=TJID.Create(AttributeValueByName['to'])
  else
    Result:=nil;
end;

procedure TDirectionalElement.FSetFromJid(jid: Tjid);
begin
  if jid<>nil then
    SetAttribute('from',jid.ToString)
  else
    RemoveAttribute('from');
end;

procedure TDirectionalElement.FSetToJid(jid: Tjid);
begin
  if jid<>nil then
    SetAttribute('to',jid.ToString)
  else
    RemoveAttribute('to');
end;

procedure TDirectionalElement.SwitchDirection;
var
  jfrom,jto:TJID;
  helper:tjid;
begin
  jfrom:=FromJid;
  jto:=tojid;
  RemoveAttribute('from');
  RemoveAttribute('to');
  helper:=jfrom;
  jfrom:=jto;
  jto:=helper;
  fromjid:=jfrom;
  tojid:=jto;
 
end;



end.
