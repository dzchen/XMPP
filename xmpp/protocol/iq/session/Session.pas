unit Session;

interface
uses
  Element,NativeXml,XmppUri;
type
  TSession=class(TElement)
  public
    constructor Create();override;
  end;
var
  TagName:string='session';
implementation

{ TSession }

constructor TSession.Create();
begin
  inherited Create;
  Name:='session';
  Namespace:=XMLNS_SESSION;
end;

end.
