unit protocol.Stream;

interface
uses
  Stream,XmppUri;
type
  TStream=class(Stream.TStream)
  public
    constructor Create;override;
  end;

implementation

{ TStream }

constructor TStream.Create;
begin
  inherited create;
  Namespace:=XMLNS_STREAM;
end;

end.
