unit protocol.extensions.featureneg;

interface
uses
  XmppUri,Element,protocol.x.data.Data,iq;
type
  TFeatureNeg=class(TElement)
  private
    function FGetData:TData;
    procedure FSetData(value:TData);
  public
    constructor Create;override;
    property Data:TData read FGetData write FSetData;
  end;
  TFeatureNegIq=class(TIQ)
  private
    _featureneg:TFeatureNeg;
  public
    constructor Create;overload;override;
    constructor Create(iqtype:string);overload;
    property FeatureNeg:TFeatureNeg read _featureneg;
  end;

implementation

{ TFeatureNeg }

constructor TFeatureNeg.Create;
begin
  inherited;
  Name:='feature';
  Namespace:=XMLNS_FEATURE_NEG;
end;

function TFeatureNeg.FGetData: TData;
begin
  Result:=TData(selectsingleelement(TData.ClassInfo));
end;

procedure TFeatureNeg.FSetData(value: TData);
begin
  if HasTag(TData.ClassInfo) then
    RemoveTag(Tdata.ClassInfo);
  NodeAdd(value);
end;

{ TFeatureNegIq }

constructor TFeatureNegIq.Create;
begin
  inherited;
  _featureneg:=TFeatureNeg.Create;
  NodeAdd(_featureneg);
  GenerateId;
end;

constructor TFeatureNegIq.Create(iqtype: string);
begin
  Self.Create;
  self.IqType:=iqtype;
end;

end.
