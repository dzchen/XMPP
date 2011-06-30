unit Group;

interface
uses
  Item,NativeXml;
type
  TGroup=class(TItem)
  private
    function fgetitemname:string;
    procedure fsetitemname(value:string);
  public
    constructor Create(AOwner:TNativeXML);overload;
    constructor Create(AOwner:TNativeXML;groupname:string);overload;
    property ItemName read FGetItemName write FSetItemName;
  end;

implementation

{ TGroup }

constructor TGroup.Create(AOwner: TNativeXML);
begin
  inherited Create(AOwner);
  Name:='group';
end;

constructor TGroup.Create(AOwner: TNativeXML; groupname: string);
begin
  inherited Create(AOwner);
  ItemName:=groupname;
end;

function TGroup.fgetitemname: string;
begin
  Result:=Value;
end;

procedure TGroup.fsetitemname(value: string);
begin
  Self.value:=value;
end;

end.
