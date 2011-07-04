unit Address;

interface
uses
  Element,NativeXml,XmppUri;
/// <remarks>
/// ttttt
/// </remarks>
const AddressLocation:array[0..2] of string=('NONE',
		'HOME',
		'WORK');
type
  TAddress=class(TElement)
  private
    function FGetLocation():string;
    procedure FSetLocation(value:string);
    function FGetIsPrefered():Boolean;
    procedure FSetIsPrefered(value:Boolean);
    function FGetExtraAddress():string;
    procedure FSetExtraAddress(value:string);
    function FGetStreet():string;
    procedure FSetStreet(value:string);
    function FGetLocality():string;
    procedure FSetLocality(value:string);
    function FGetRegion():string;
    procedure FSetRegion(value:string);
    function FGetPostalCode():string;
    procedure FSetPostalCode(value:string);
    function FGetCountry():string;
    procedure FSetCountry(value:string);
  public
    constructor Create();override;
    constructor CreateAddress(loc:string;extra,street,locality,region,postalcode,country:string;prefered:Boolean);
    property Location:string read FGetLocation write FSetLocation;
    property IsPrefered:Boolean read FGetIsPrefered write FSetIsPrefered;
    property ExtraAddress:string read FGetExtraAddress write FSetExtraAddress;
    property Street:string read FGetStreet write FSetStreet;
    property Locality:string read FGetLocality write FSetLocality;
    property Region:string read FGetRegion write FSetRegion;
    property PostalCode:string read FGetPostalCode write FSetPostalCode;
    property Country:string read FGetCountry write FSetCountry;
  end;
var
  TagName:string='ADR';

implementation

{ TAddress }

constructor TAddress.Create();
begin
  inherited Create();
  Name:='ADR';
  Namespace:=XMLNS_VCARD;
end;

constructor TAddress.CreateAddress(loc: string;
  extra, street, locality, region, postalcode, country: string;prefered:Boolean);
begin
  self.Create();
  Location:=loc;
  ExtraAddress:=extra;
  Self.Street:=Street;
  Self.Locality:=locality;
  Self.Region:=region;
  Self.PostalCode:=postalcode;
  Self.Country:=country;
  Self.IsPrefered:=prefered;
end;

function TAddress.FGetCountry: string;
begin
  result:=GetTag('CTRY');
end;

function TAddress.FGetExtraAddress: string;
begin
  result:=GetTag('EXTADD');
end;

function TAddress.FGetIsPrefered: Boolean;
begin
  result:=HasTag('PREF');
end;

function TAddress.FGetLocality: string;
begin
  result:=GetTag('LOCALITY');
end;

function TAddress.FGetLocation: string;
begin
result:=HasTagArray(AddressLocation);

end;

function TAddress.FGetPostalCode: string;
begin
  result:=GetTag('PCODE');
end;

function TAddress.FGetRegion: string;
begin
  result:=GetTag('REGION');
end;

function TAddress.FGetStreet: string;
begin
  result:=GetTag('STREET');
end;

procedure TAddress.FSetCountry(value: string);
begin
  NodeFindOrCreate('CTRY').Value:=value;
end;

procedure TAddress.FSetExtraAddress(value: string);
begin
  NodeFindOrCreate('EXTADD').Value:=value;
end;

procedure TAddress.FSetIsPrefered(value: Boolean);
begin
  if value then
    NodeFindOrCreate('PREF')
  else
    NodeRemove(FindNode('PREF'));
end;

procedure TAddress.FSetLocality(value: string);
begin
  NodeFindOrCreate('LOCALITY').Value:=value;
end;

procedure TAddress.FSetLocation(value: string);
begin
  NodeFindOrCreate(value);
end;

procedure TAddress.FSetPostalCode(value: string);
begin
  NodeFindOrCreate('PCODE').Value:=value;
end;

procedure TAddress.FSetRegion(value: string);
begin
  NodeFindOrCreate('REGION').Value:=value;
end;

procedure TAddress.FSetStreet(value: string);
begin
  NodeFindOrCreate('STREET').Value:=value;
end;

end.
