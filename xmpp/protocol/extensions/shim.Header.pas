unit shim.Header;

interface
uses
  Element,NativeXml,XmppUri;
type
  THeader=class(TElement)
  private
    function FGetHeadName:string;
    procedure FSetHeadName(value:string);
  public
    constructor Create();override;
    constructor Create(nm,val:string);overload;
    property HeadName:string read FGetHeadName write FSetHeadName;
  end;

implementation

{ THeader }

constructor THeader.Create();
begin
  inherited Create();
  name:='header';
  Namespace:=XMLNS_SHIM;
end;

constructor THeader.Create(nm, val: string);
begin
  self.Create();
  HeadName:=nm;
  Value:=val;
end;

function THeader.FGetHeadName: string;
begin
  Result:=AttributeValueByName['name'];
end;

procedure THeader.FSetHeadName(value: string);
begin
  SetAttribute('name',value);
end;

end.
