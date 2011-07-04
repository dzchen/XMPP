unit primary.Primary;

interface
uses
  Element,NativeXml,XmppUri;
type
  TPrimary=class(TElement)
  public
    constructor Create();override;
  end;

implementation

{ TPrimary }

constructor TPrimary.Create();
begin
  inherited Create();
  Name:='p';
  Namespace:=XMLNS_PRIMARY;
end;

end.
