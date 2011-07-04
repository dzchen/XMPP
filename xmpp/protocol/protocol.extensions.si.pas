unit protocol.extensions.si;

interface
uses
  Element,XmppUri,IQ,Jid,protocol.extensions.filetransfer,protocol.extensions.featureneg;
type
  TSI=class(TElement)
  private
    function FGetId:string;
    procedure FSetId(value:string);
    function FGetMimeType:string;
    procedure FSetMimeType(value:string);
    function FGetProfile:string;
    procedure FSetProfile(value:string);
    function FGetFeatureNeg:TFeatureNeg;
    procedure FSetFeatureNeg(value:TFeatureNeg);
    function FGetFile:TFile;
    procedure FSetFile(value:TFile);
  public
    constructor Create;override;
    property Id:string read FGetId write FSetId;
    property MimeType:string read FGetMimeType write FSetMimeType;
    property Profile:string read FGetProfile write FSetProfile;
    property FeatureNeg:TFeatureNeg read FGetFeatureNeg write FSetFeatureNeg;
    property SIFile:TFile read FGetFile write FSetFile;
  end;
  TSIIq=class(TIQ)
  private
    _si:TSI;
  public
    constructor Create;overload;override;
    constructor Create(iqtype:string);overload;
    constructor Create(iqtype:string;tojid:TJID);overload;
    constructor Create(iqtype:string;tojid,fromjid:TJID);overload;
    property SI:TSI read _si;
  end;

implementation

{ TSI }

constructor TSI.Create;
begin
  inherited;
  Name:='si';
  Namespace:=XMLNS_SI;
end;

function TSI.FGetFeatureNeg: TFeatureNeg;
begin
  Result:=TFeatureNeg(SelectSingleElement(TFeatureNeg.ClassInfo));
end;

function TSI.FGetFile: TFile;
begin
  Result:=TFile(SelectSingleElement(TFile.ClassInfo));
end;

function TSI.FGetId: string;
begin
  Result:=AttributeValueByName['id'];
end;

function TSI.FGetMimeType: string;
begin
  Result:=AttributeValueByName['mime-type'];
end;

function TSI.FGetProfile: string;
begin
  Result:=AttributeValueByName['profile'];
end;

procedure TSI.FSetFeatureNeg(value: TFeatureNeg);
begin
  if HasTag(TFeatureNeg.ClassInfo) then
    RemoveTag(TFeatureNeg.ClassInfo);
  if value<>nil then
    NodeAdd(value);
end;

procedure TSI.FSetFile(value: TFile);
begin
  if HasTag(TFile.ClassInfo) then
    RemoveTag(TFile.ClassInfo);
  if value<>nil then
    NodeAdd(value);
end;

procedure TSI.FSetId(value: string);
begin
  SetAttribute('id',value);
end;

procedure TSI.FSetMimeType(value: string);
begin
  SetAttribute('mime-type',value);
end;

procedure TSI.FSetProfile(value: string);
begin
  SetAttribute('profile',value);
end;

{ TSIIq }

constructor TSIIq.Create(iqtype: string);
begin
  self.Create;
  self.IqType:=iqtype;
end;

constructor TSIIq.Create;
begin
  inherited;
  _si:=TSI.Create;
  GenerateId;
  NodeAdd(_si);
end;

constructor TSIIq.Create(iqtype: string; tojid, fromjid: TJID);
begin
  Self.Create(iqtype);
  Self.ToJid:=tojid;
  self.FromJid:=fromjid;
end;

constructor TSIIq.Create(iqtype: string; tojid: TJID);
begin
  Self.Create(iqtype);
  Self.ToJid:=tojid;
end;

end.
