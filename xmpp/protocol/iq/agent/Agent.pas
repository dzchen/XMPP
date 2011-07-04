unit Agent;

interface
uses
  Element,NativeXml,XmppUri,Jid;
type
  TAgent=class(TElement)
  private
    function FGetJid:TJID;
    procedure FSetJid(value:TJID);
    function FGetAgentName:string;
    procedure FSetAgentName(value:string);
    function FGetService:string;
    procedure FSetService(value:string);
    function FGetDescription:string;
    procedure FSetDescription(value:string);
    function FGetCanRegister:Boolean;
    procedure FSetCanRegister(value:Boolean);
    function FGetCanSearch:Boolean;
    procedure FSetCanSearch(value:Boolean);
    function FGetIsTransport:Boolean;
    procedure FSetIsTransport(value:Boolean);
    function FGetIsGroupchat:Boolean;
    procedure FSetIsGroupchat(value:Boolean);
  public
    constructor Create();override;

    property Jid:TJID read FGetJid write FSetJid;
    property AgentName:string read FGetAgentName write FSetAgentName;
    property Service:string read FGetService write FSetService;
    property Description:string read FGetDescription write FSetDescription;
    property CanRegister:Boolean read FGetCanRegister write FSetCanRegister;
    property CanSearch:Boolean read FGetCanSearch write FSetCanSearch;
    property IsTransport:Boolean read FGetIsTransport write FSetIsTransport;
    property IsGroupchat:Boolean read FGetIsGroupchat write FSetIsGroupchat;
  end;

implementation

{ TAgent }

constructor TAgent.Create();
begin
  inherited Create();
  Name:='agent';
  Namespace:=XMLNS_IQ_AGENTS;
end;



function TAgent.FGetAgentName: string;
begin
  Result:=GetTag('name');
end;

function TAgent.FGetCanRegister: Boolean;
begin
  Result:=HasTag('register');
end;

function TAgent.FGetCanSearch: Boolean;
begin
  Result:=HasTag('search');
end;

function TAgent.FGetDescription: string;
begin
  Result:=GetTag('description');
end;

function TAgent.FGetIsGroupchat: Boolean;
begin
  Result:=HasTag('groupchat');
end;

function TAgent.FGetIsTransport: Boolean;
begin
  Result:=HasTag('transport');
end;

function TAgent.FGetJid: TJID;
begin
  Result:=TJID.Create(AttributeValueByName['jid']);
end;

function TAgent.FGetService: string;
begin
  Result:=GetTag('service');
end;

procedure TAgent.FSetAgentName(value: string);
begin
  NodeFindOrCreate('name').Value:=value;
end;

procedure TAgent.FSetCanRegister(value: Boolean);
begin
  if Value then
    NodeFindOrCreate('register')
  else
    RemoveTag('register');
end;

procedure TAgent.FSetCanSearch(value: Boolean);
begin
  if Value then
    NodeFindOrCreate('search')
  else
    RemoveTag('search');
end;

procedure TAgent.FSetDescription(value: string);
begin
  NodeFindOrCreate('description').Value:=value;
end;

procedure TAgent.FSetIsGroupchat(value: Boolean);
begin
  if Value then
    NodeFindOrCreate('groupchat')
  else
    RemoveTag('groupchat');
end;

procedure TAgent.FSetIsTransport(value: Boolean);
begin
  if Value then
    NodeFindOrCreate('transport')
  else
    RemoveTag('transport');
end;

procedure TAgent.FSetJid(value: TJID);
begin
  SetAttribute('jid',value.ToString);
end;

procedure TAgent.FSetService(value: string);
begin
  NodeFindOrCreate('service').Value:=value;
end;

end.
