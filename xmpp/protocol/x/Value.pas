unit Value;

interface
uses
  Element,XmppUri,NativeXml;
type
  TValue=class(TElement)
  public
    constructor Create();override;

    constructor Create(val:string);overload;
    constructor Create(val:Boolean);overload;
  end;

implementation

{ TValue }



constructor TValue.Create;
begin
  inherited Create;
  Name:='value';
  Namespace:=XMLNS_X_DATA;
end;

constructor TValue.Create(val: Boolean);
begin
  self.Create;
  if val then
    Value:='1'
  else
    Value:='0';
end;

constructor TValue.Create(val: string);
begin
  self.Create;
  Value:=val;
end;

end.
