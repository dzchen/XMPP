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
    AttributeAdd('from',jid.ToString)
  else
    AttributeDelete(AttributeIndexByName('from'));
end;

procedure TDirectionalElement.FSetToJid(jid: Tjid);
begin
  if jid<>nil then
    AttributeAdd('to',jid.ToString)
  else
    AttributeDelete(AttributeIndexByName('to'));
end;

procedure TDirectionalElement.SwitchDirection;
var
  jfrom,jto:TJID;
begin
  jfrom:=FromJid;
  jto:=tojid;
  AttributeAdd('from',jto.ToString);
  AttributeAdd('to',jfrom.ToString);
end;



end.
