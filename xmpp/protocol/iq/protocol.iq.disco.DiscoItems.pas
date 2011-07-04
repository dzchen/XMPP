unit protocol.iq.disco.DiscoItems;

interface
uses
  XmppUri,IQ,protocol.iq.disco.DiscoItem,Generics.Collections,Element;
type
  TDiscoItems=class(TIQ)
  private
    function FGetNode:string;
    procedure FSetNode(value:string);

  public
    constructor Create();override;
    property Node:string read FGetNode write FSetNode;
    function AddDiscoItem():TDiscoItem;overload;
    procedure AddDiscoItem(item:TDiscoItem);overload;
    function GetDiscoItems:TList<Telement>;
  end;

implementation

{ TDiscoItems }

procedure TDiscoItems.AddDiscoItem(item: TDiscoItem);

begin
  NodeAdd(item);

end;

function TDiscoItems.AddDiscoItem: TDiscoItem;
var
  i:TDiscoItem;
begin
  i:=TDiscoItem.Create;
  NodeAdd(i);
  Result:=i;
end;

constructor TDiscoItems.Create;
begin
  inherited Create;
  Name:='query';
  Namespace:=XMLNS_DISCO_ITEMS;
end;

function TDiscoItems.FGetNode: string;
begin
  result:=AttributeValueByName['node'];
end;

procedure TDiscoItems.FSetNode(value: string);
begin
  SetAttribute('node',value);
end;

function TDiscoItems.GetDiscoItems: TList<Telement>;
begin
  Result:=SelectElements(TDiscoItem.ClassInfo);
end;

end.
