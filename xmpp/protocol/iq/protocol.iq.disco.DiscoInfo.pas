unit protocol.iq.disco.DiscoInfo;

interface
uses
  Element,XmppUri,protocol.iq.disco.DiscoIdentity,protocol.iq.disco.DiscoFeature,Generics.Collections;
type
  TDiscoInfo=class(TElement)
  private
    function FGetNode:string;
    procedure FSetNode(value:string);
  public
    constructor Create();overload;override;
    property Node:string read FGetNode write FSetNode;
    function AddIdentity():TDiscoIdentity;overload;
    procedure AddIdentity(id:TDiscoIdentity);overload;
    function AddFeature():TDiscoFeature;overload;
    procedure AddFeature(f:TDiscoFeature);overload;
    function GetIdentities():TList<TElement>;
    function GetFeatures():TList<TElement>;
    function HasFeature(v:string):Boolean;
  end;

implementation

{ TDiscoInfo }

procedure TDiscoInfo.AddFeature(f: TDiscoFeature);
begin
  NodeAdd(f);
end;

function TDiscoInfo.AddFeature: TDiscoFeature;
var
  f:TDiscoFeature;
begin
  f:=TDiscoFeature.Create;
  NodeAdd(f);
  Result:=f;
end;

procedure TDiscoInfo.AddIdentity(id: TDiscoIdentity);
begin
  NodeAdd(id);
end;

function TDiscoInfo.AddIdentity: TDiscoIdentity;
var
  f:TDiscoIdentity;
begin
  f:=TDiscoIdentity.Create;
  NodeAdd(f);
  Result:=f;
end;

constructor TDiscoInfo.Create;
begin
  inherited create;
  Name:='query';
  Namespace:=XMLNS_DISCO_INFO;
end;

function TDiscoInfo.FGetNode: string;
begin
  Result:=AttributeValueByName['node'];
end;

procedure TDiscoInfo.FSetNode(value: string);
begin
  SetAttribute('node',value);
end;

function TDiscoInfo.GetFeatures: TList<TElement>;
begin
  Result:=SelectElements(TDiscoFeature.ClassInfo);
end;

function TDiscoInfo.GetIdentities: TList<TElement>;
begin
  Result:=SelectElements(protocol.iq.disco.DiscoIdentity.TDiscoIdentity.ClassInfo);
end;

function TDiscoInfo.HasFeature(v: string): Boolean;
var
  el:Tlist<TElement>;
  e:TElement;
begin
  el:=tlist<TElement>.Create;
  el:=GetFeatures;
  for e in el do
    if TDiscoFeature(e).DiscoVar=v then
    begin
      Result:=true;
      exit;
    end;
  Result:=false;
end;

end.
