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
    constructor Create();overload;override;
    constructor Create(groupname:string);overload;
    property ItemName read FGetItemName write FSetItemName;
  end;

implementation

{ TGroup }

constructor TGroup.Create();
begin
  inherited Create();
  Name:='group';
end;

constructor TGroup.Create(groupname: string);
begin
  self.Create();
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
