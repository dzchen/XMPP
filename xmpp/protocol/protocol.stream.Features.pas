unit protocol.stream.Features;

interface
uses
  Element,XmppUri,Bind,protocol.stream.feature.compression.Compression,protocol.stream.feature.Register,protocol.tls.StartTls
  ,protocol.sasl.Mechanisms;
type
  TFeatures=class(TElement)
  private
    function FGetStartTls:TStartTls;
    procedure FSetStartTls(value:TStartTls);
    function FGetBind:TBind;
    procedure FSetBind(value:TBind);
    function FGetCompression:TCompression;
    procedure FSetCompression(value:TCompression);
    function FGetRegister:TRegister;
    procedure FSetRegister(value:TRegister);
    function FGetMechanisms:TMechanisms;
    procedure FSetMechanisms(value:TMechanisms);
    function FGetSupportsBind:Boolean;
    function FGetSupportsStartTls:Boolean;
    function FGetSupportsCompression:Boolean;
    function FGetSupportsRegistration:Boolean;
  public
    constructor Create;override;
    property StartTls:TStartTls read FGetStartTls write FSetStartTls;
    property Bind:TBind read FGetBind write FSetBind;
    property Compression:TCompression read FGetCompression write FSetCompression;
    property FeaturesRegister:TRegister read FGetRegister write FSetRegister;
    property Mechanisms:TMechanisms read FGetMechanisms write FSetMechanisms;
    property SupportsBind:Boolean read FGetSupportsBind;
    property SupportsStartTls:Boolean read FGetSupportsStartTls;
    property SupportsCompression:Boolean read FGetSupportsCompression;
    property SupportsRegistration:Boolean read FGetSupportsRegistration;
  end;
implementation

{ TFeatures }

constructor TFeatures.Create;
begin
  inherited Create;
  Name:='features';
  Namespace:=XMLNS_STREAM;
end;

function TFeatures.FGetBind: TBind;
begin
  Result:=TBind(selectsingleelement(TBind.ClassInfo));
end;

function TFeatures.FGetCompression: TCompression;
begin
  Result:=TCompression(selectsingleelement(TCompression.ClassInfo));
end;

function TFeatures.FGetMechanisms: TMechanisms;
begin
  Result:=TMechanisms(selectsingleelement(TMechanisms.ClassInfo));
end;

function TFeatures.FGetRegister: TRegister;
begin
  Result:=TRegister(selectsingleelement(TRegister.ClassInfo));
end;

function TFeatures.FGetStartTls: TStartTls;
begin
  Result:=TStartTls(selectsingleelement(TStartTls.ClassInfo));
end;

function TFeatures.FGetSupportsBind: Boolean;
begin
  result:=Bind<>nil;

end;

function TFeatures.FGetSupportsCompression: Boolean;
begin
  result:=Compression<>nil;
end;

function TFeatures.FGetSupportsRegistration: Boolean;
begin
  result:=FeaturesRegister<>nil;
end;

function TFeatures.FGetSupportsStartTls: Boolean;
begin
  result:=StartTls<>nil;
end;

procedure TFeatures.FSetBind(value: TBind);
begin
  RemoveTag(TBind.ClassInfo);
  if value<>nil then
    NodeAdd(value);
end;

procedure TFeatures.FSetCompression(value: TCompression);
begin
  RemoveTag(TCompression.ClassInfo);
  if value<>nil then
    NodeAdd(value);
end;

procedure TFeatures.FSetMechanisms(value: TMechanisms);
begin
  RemoveTag(TMechanisms.ClassInfo);
  if value<>nil then
    NodeAdd(value);
end;

procedure TFeatures.FSetRegister(value: TRegister);
begin
  RemoveTag(TRegister.ClassInfo);
  if value<>nil then
    NodeAdd(value);
end;

procedure TFeatures.FSetStartTls(value: TStartTls);
begin
  RemoveTag(TStartTls.ClassInfo);
  if value<>nil then
    NodeAdd(value);
end;

end.
