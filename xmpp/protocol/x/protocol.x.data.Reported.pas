unit protocol.x.data.Reported;

interface
uses
  FieldContainer,XmppUri;
type
  TReported=class(TFieldcontainer)
  public
    constructor Create;override;
  end;
implementation

{ TReported }

constructor TReported.Create;
begin
  Name:='reported';
  Namespace:=XMLNS_X_DATA;
end;

end.
