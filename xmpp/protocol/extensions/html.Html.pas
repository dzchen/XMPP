unit html.Html;

interface
uses
  Element,XmppUri,html.body,NativeXml;
type
  THtml=class(TElement)
  private
    function FGetBody:TBody;
    procedure FSetBody(value:TBody);
  public
    constructor Create();override;
    property Body:TBody read FGetBody write FSetBody;
  end;

implementation

{ THtml }

constructor THtml.Create();
begin
  inherited Create();
  name:='html';
  Namespace:=XMLNS_XHTML_IM;
end;

function THtml.FGetBody: TBody;
begin
  Result:=TBody(selectsingleelement(TBody.ClassInfo));
end;

procedure THtml.FSetBody(value: TBody);
begin
  if HasTag(TBody.ClassInfo) then
    RemoveTag(TBody.ClassInfo);
  if value<>nil then
    NodeAdd(value);
end;

end.
