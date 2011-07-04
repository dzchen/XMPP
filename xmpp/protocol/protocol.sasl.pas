unit protocol.sasl;

interface
uses
  Element,XmppUri,XMPPConst,protocol.sasl.Mechanism;
type
  TChallenge=class(TElement)
  public
    constructor Create;override;
  end;
  TFailure=class(TElement)
  private
    function FGetFailureCondition:TFailureCondition;
    procedure FSetFailureCondition(value:TFailureCondition);
  public
    constructor Create;override;
    constructor Create(cond:TFailureCondition);overload;
    property Condition:TFailureCondition read FGetFailureCondition write FSetFailureCondition;
  end;
  TSuccess=class(TElement)
  public
    constructor Create;override;
  end;
  TResponse=class(TElement)
  public
    constructor Create;override;
    constructor Create(txt:string);overload;
  end;
  TAbort=class(TElement)
  public
    constructor Create;override;
  end;
  TAuth=class(TElement)
  private
    function FGetMechanismType:TMechanismType;
    procedure FSetMechanismType(value:TMechanismType);
  public
    constructor Create;override;
    constructor Create(tp:TMechanismType);overload;
    constructor Create(tp:TMechanismType;txt:string);overload;
    property MechanismType:TMechanismType read FGetMechanismType write FSetMechanismType;
  end;
implementation

{ TChallenge }

constructor TChallenge.Create;
begin
  inherited;
  Self.Name:='challenge';
  self.Namespace:=xmlns_sasl;
end;

{ TFailure }

constructor TFailure.Create;
begin
  inherited;
  self.Name:='failure';
  self.Namespace:=XMLNS_SASL;
end;

constructor TFailure.Create(cond: TFailureCondition);
begin
  self.Create;
  Condition:=cond;
end;

function TFailure.FGetFailureCondition: TFailureCondition;
begin
  if HasTag('aborted') then
    result:=fcaborted
  else if (HasTag('incorrect-encoding')) then
                    result:=fcincorrect_encoding
                else if (HasTag('invalid-authzid'))  then
                    result:=fcinvalid_authzid
                else if (HasTag('invalid-mechanism')) then
                    result:=fcinvalid_mechanism
                else if (HasTag('mechanism-too-weak')) then
                    result:=fcmechanism_too_weak
                else if (HasTag('not-authorized')) then
                    result:=fcnot_authorized
                else if (HasTag('temporary-auth-failure')) then
                    result:=fctemporary_auth_failure
                else
                    result:=fcUnknownCondition;
end;

procedure TFailure.FSetFailureCondition(value: TFailureCondition);
begin
  if value=fcaborted then
    SetTag('aborted')
  else if (value = fcincorrect_encoding)  then
                    SetTag('incorrect-encoding')
                else if (value = fcinvalid_authzid)   then
                    SetTag('invalid-authzid')
                else if (value = fcinvalid_mechanism)  then
                    SetTag('invalid-mechanism')
                else if (value = fcmechanism_too_weak)  then
                    SetTag('mechanism-too-weak')
                else if (value = fcnot_authorized) then
                    SetTag('not-authorized')
                else if (value = fctemporary_auth_failure)  then
                    SetTag('temporary-auth-failure');
end;

{ TSuccess }

constructor TSuccess.Create;
begin
  inherited;
  self.Name:='success';
  self.Namespace:=XMLNS_SASL;
end;

{ TResponse }

constructor TResponse.Create;
begin
  inherited;
  Self.Name:='response';
  self.Namespace:=XMLNS_SASL;
end;

constructor TResponse.Create(txt: string);
begin
  Self.Create;
  self.TextBase64:=txt;
end;

{ TAuth }

constructor TAuth.Create;
begin
  inherited;
  self.Name:='auth';
  self.Namespace:=XMLNS_SASL;
end;

constructor TAuth.Create(tp: TMechanismType);
begin
  self.Create;
  MechanismType:=tp;
end;

constructor TAuth.Create(tp: TMechanismType; txt: string);
begin
  self.Create;
  MechanismType:=tp;
  Self.Value:=txt;
end;

function TAuth.FGetMechanismType: TMechanismType;
begin
  result:=tmechanism.GetMechanismType(attributevaluebyname['mechanism']);
end;

procedure TAuth.FSetMechanismType(value: TMechanismType);
begin
  SetAttribute('mechanism',TMechanism.GetMechanismName(value));
end;

{ TAbort }

constructor TAbort.Create;
begin
  inherited;
  self.Name:='abort';
  self.NameSpace:=XMLNS_SASL;
end;

end.
