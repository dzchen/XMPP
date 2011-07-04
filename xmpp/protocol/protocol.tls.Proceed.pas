unit protocol.tls.Proceed;

interface
uses
  Element,XmppUri;
type
  TProceed=class(TElement)
  public
    constructor Create;override;
  end;

implementation

{ TProceed }

constructor TProceed.Create;
begin
  inherited Create;
  Name:='proceed';
  Namespace:=XMLNS_TLS;
end;

end.
