unit protocol.x.data.item;

interface
uses
  FieldContainer,XmppUri;
type
  TItem=class(TFieldcontainer)
  public
    constructor Create;override;
  end;
implementation

{ TItem }

constructor TItem.Create;
begin
  Name:='item';
  namespace:=XMLNS_X_DATA;
end;

end.
