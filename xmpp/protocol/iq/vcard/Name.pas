unit Name;

interface
uses
  NativeXml,Element,XmppUri;
type
  TName=class(TElement)
  private
    procedure FSetFamily(value:string);
    function FGetFamily:string;
    procedure FSetGiven(value:string);
    function FGetGiven:string;
    procedure FSetMiddle(value:string);
    function FGetMiddle:string;
  public
    constructor Create();override;
    constructor Create(family:string;given:string;middle:string);overload;
    property Family:string read FGetFamily write FSetFamily;
    property Given:string read FGetGiven write FSetGiven;
    property Middle:string read FGetMiddle write FSetMiddle;
  end;
var
  TagName:string='N';
implementation

{ TName }

constructor TName.Create();
begin
  inherited Create();
  Name:='N';
  Namespace:=XMLNS_VCARD;
end;

constructor TName.Create(family, given, middle: string);
begin
  Self.Create();
  Self.Family:=family;
  Self.Given:=given;
  Self.Middle:=middle;
end;

function TName.FGetFamily: string;
begin
  Result:=GetTag('FAMILY');
end;

function TName.FGetGiven: string;
begin
  Result:=GetTag('GIVEN');
end;

function TName.FGetMiddle: string;
begin
  Result:=GetTag('MIDDLE');
end;

procedure TName.FSetFamily(value: string);
begin
  NodeFindOrCreate('FAMILY').Value:=value;
end;

procedure TName.FSetGiven(value: string);
begin
  NodeFindOrCreate('GIVEN').Value:=value;
end;

procedure TName.FSetMiddle(value: string);
begin
  NodeFindOrCreate('MIDDLE').Value:=value;
end;

end.
