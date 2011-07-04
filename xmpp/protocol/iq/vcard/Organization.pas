unit Organization;

interface
uses
  Element,NativeXml,XmppUri;
type
  TOrganization=class(TElement)
  private
    function FGetOrgName:string;
    procedure FSetOrgName(value:string);
    function FGetOrgUnit:string;
    procedure FSetOrgUnit(value:string);
  public
    constructor Create();override;
    constructor CreateOrganization(name,un:string);
    property OrgName:string read FGetOrgName write FSetOrgName;
    property OrgUnit:string read FGetOrgUnit write FSetOrgUnit;
  end;
var
  TagName:string='ORG';
implementation

{ TOrganization }

constructor TOrganization.Create();
begin
  inherited Create();
  name:='ORG';
  Namespace:=XMLNS_VCARD;
end;

constructor TOrganization.CreateOrganization(name, un: string);
begin
  self.Create();
  orgname:=name;
  orgunit:=un;
end;

function TOrganization.FGetOrgName: string;
begin
  Result:=GetTag('ORGNAME');

end;

function TOrganization.FGetOrgUnit: string;
begin
  Result:=GetTag('ORGUNIT');
end;

procedure TOrganization.FSetOrgName(value: string);
begin
  NodeFindOrCreate('ORGNAME').Value:=value;
end;

procedure TOrganization.FSetOrgUnit(value: string);
begin
  NodeFindOrCreate('ORGUNIT').Value:=value;
end;

end.
