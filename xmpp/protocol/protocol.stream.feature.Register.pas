unit protocol.stream.feature.Register;

interface
uses
  Element,XmppUri;
type
  TRegister=class(TElement)
  public
    constructor Create;override;
  end;

implementation

{ TRegister }

constructor TRegister.Create;
begin
  inherited Create;
  Name:='register';
  Namespace:=XMLNS_FEATURE_IQ_REGISTER;
end;

end.
