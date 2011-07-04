unit protocol.extensions.Rule;

interface
uses
  Element,XmppUri,XmppConst;
type
  TRule=class(TElement)
  private
    function FGetVal:string;
    procedure FSetVal(val:string);
    function FGetAction:string;
    procedure FSetAction(val:string);
    function FGetCondition:TAmpCondition;
    procedure FSetCondition(val:TAmpCondition);
  public
    constructor Create;override;
    constructor Create(cond:TAmpCondition;val,act:string);overload;
    property Val:string read FGetVal write FSetVal;
    property Action:string read FGetAction write FSetAction;
    property Condition:TAmpCondition read FGetCondition write FSetCondition;
  end;

implementation

{ TRule }

constructor TRule.Create;
begin
  inherited;
  Name:='rule';
  Namespace:=XMLNS_AMP;
end;

constructor TRule.Create(cond:TAmpCondition; val, act: string);
begin
  self.Condition:=cond;
  self.Val:=val;
  self.Action:=act;
end;

function TRule.FGetAction: string;
begin
  Result:=AttributeValueByName['action'];
end;

function TRule.FGetCondition: TAmpCondition;
var
  s:string;
begin
  s:= AttributeValueByName['condition'];
  if s='deliver' then
    Result:=TAmpCondition.ampDeliver
  else if s='expire-at' then
    Result:=TAmpCondition.ampExprireAt
  else if s='match-resource' then
    Result:=TAmpCondition.ampMatchResource
  else
    Result:=TAmpCondition.ampUnknown;
end;

function TRule.FGetVal: string;
begin
  Result:=AttributeValueByName['value'];
end;

procedure TRule.FSetAction(val: string);
begin
  if val='unknown' then
    RemoveAttribute('action')
  else
    SetAttribute('action',val);
end;

procedure TRule.FSetCondition(val: TAmpCondition);
begin
  case val of
    TAmpCondition.ampDeliver:SetAttribute('condition','deliver');
    TAmpCondition.ampExprireAt:SetAttribute('condition','expire-at');
    TAmpCondition.ampMatchResource:SetAttribute('condition','match-resource');
  end;
end;

procedure TRule.FSetVal(val: string);
begin
  SetAttribute('value',val);
end;

end.
