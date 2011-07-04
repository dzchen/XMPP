unit protocol.iq.disco.DiscoIdentity;

interface
uses
  Element,XmppUri;
type
  TDiscoIdentity=class(TElement)
  private
    function FGetDiscoType:string;
    procedure FSetDIscoType(value:string);
    function FGetDiscoName:string;
    procedure FSetDiscoName(value:string);
    function FGetCategory:string;
    procedure FSetCategory(value:string);
  public
    constructor Create;overload;override;
    constructor Create(discotype,disconame,category:string);overload;
    constructor Create(discotype,category:string);overload;
    property DiscoType:string read FGetDiscoType write FSetDiscoType;
    property DiscoName:string read FGetDiscoName write FSetDiscoName;
    property Category:string read FGetCategory write FSetCategory;
  end;

implementation

{ TDiscoIdentity }

constructor TDiscoIdentity.Create;
begin
  inherited Create;
  Name:='identity';
  Namespace:=XMLNS_DISCO_INFO;
end;

constructor TDiscoIdentity.Create(discotype, disconame, category: string);
begin
  self.Create;
  self.DiscoType:=discotype;
  self.DiscoName:=disconame;
  self.Category:=category;
end;

constructor TDiscoIdentity.Create(discotype, category: string);
begin
self.Create;
  self.DiscoType:=discotype;
  self.Category:=category;
end;

function TDiscoIdentity.FGetCategory: string;
begin
  Result:=AttributeValueByName['category'];
end;

function TDiscoIdentity.FGetDiscoName: string;
begin
  Result:=AttributeValueByName['name'];
end;

function TDiscoIdentity.FGetDiscoType: string;
begin
  Result:=AttributeValueByName['type'];
end;

procedure TDiscoIdentity.FSetCategory(value: string);
begin
  SetAttribute('category',value);
end;

procedure TDiscoIdentity.FSetDiscoName(value: string);
begin
   SetAttribute('name',value);
end;

procedure TDiscoIdentity.FSetDIscoType(value: string);
begin
  SetAttribute('type',value);
end;

end.
