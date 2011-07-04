unit protocol.extensions.amp;

interface
uses
  DirectionalElement,XmppUri,Element,protocol.extensions.Rule,Generics.Collections,SysUtils;
type
  TAmp=class(TDirectionalElement)
  private
    function FGetStatus:string;
    procedure FSetStatus(val:string);
    function FGetPerHop:Boolean;
    procedure FSetPerHop(val:Boolean);
  public
    constructor Create;override;
    property Status:string read FGetStatus write FSetStatus;
    property PerHop:Boolean read FGetPerHop write FSetPerHop;
    procedure AddRule(rule:TRule);overload;
    function AddRule():TRule;overload;
    function GetRules():TList<TElement>;
  end;

implementation

{ TAmp }

function TAmp.AddRule: TRule;
var
  rule:TRule;
begin
  rule:=TRule.Create;
  NodeAdd(rule);
  Result:=rule;
end;

procedure TAmp.AddRule(rule: TRule);
begin
  NodeAdd(rule);
end;

constructor TAmp.Create;
begin
  inherited;
  Name:='amp';
  Namespace:=XMLNS_AMP;
end;

function TAmp.FGetPerHop: Boolean;
begin
  if lowercase(AttributeValueByName['per-hop'])='true' then
    Result:=true
  else
    Result:=False;
end;

function TAmp.FGetStatus: string;
begin
  Result:=AttributeValueByName['status'];
end;

procedure TAmp.FSetPerHop(val: Boolean);
begin
  SetAttribute('per-hop',val);
end;

procedure TAmp.FSetStatus(val: string);
begin
  SetAttribute('status',val);
end;

function TAmp.GetRules: TList<TElement>;
begin
  Result:=SelectElements(trule.ClassInfo);

end;

end.
