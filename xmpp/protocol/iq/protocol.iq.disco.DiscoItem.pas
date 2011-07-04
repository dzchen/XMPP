unit protocol.iq.disco.DiscoItem;

interface
uses
  XmppUri,Element,Jid;
type
  TDiscoItem=class(TElement)
  private
    function FGetJid:TJID;
    procedure FSetJid(value:TJID);
    function FGetDiscoName:string;
    procedure FSetDiscoName(value:string);
    function FGetNode:string;
    procedure FSetNode(value:string);
    function FGetAction:string;
    procedure FSetAction(value:string);
  public
    constructor Create;override;
    property Jid:TJID read FGetJid write FSetJId;
    property DiscoName:string read FGetDiscoName write FSetDiscoName;
    property Node:string read FGetNode write FSetNode;
    property Action:string read FGetAction write FSetAction;
  end;

implementation

{ TDiscoItem }

constructor TDiscoItem.Create;
begin
  inherited Create;
  Name:='item';
  Namespace:=XMLNS_DISCO_ITEMS;
end;

function TDiscoItem.FGetAction: string;
begin
  result:=AttributeValueByName['action'];
end;

function TDiscoItem.FGetDiscoName: string;
begin
  result:=AttributeValueByName['name'];
end;

function TDiscoItem.FGetJid: TJID;
begin
  result:=TJID.Create(AttributeValueByName['jid']);
end;

function TDiscoItem.FGetNode: string;
begin
  result:=AttributeValueByName['node'];
end;

procedure TDiscoItem.FSetAction(value: string);
begin
  if value='NONE' then
    RemoveAttribute('action')
  else
    SetAttribute('action',value);
end;

procedure TDiscoItem.FSetDiscoName(value: string);
begin
  SetAttribute('name',value);
end;

procedure TDiscoItem.FSetJid(value: TJID);
begin
  SetAttribute('jid',value.ToString);
end;

procedure TDiscoItem.FSetNode(value: string);
begin
  SetAttribute('node',value);
end;

end.
