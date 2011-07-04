unit Stanza;

interface
uses
  DirectionalElement,NativeXml,id;
type
  TStanza=class(TDirectionalElement)
  private
    procedure FSetId(value:string);
    function FGetId:string;
    procedure FSetLanguage(value:string);
    function FGetLanguage:string;
  public
    constructor Create(tag,ns:string);overload;
    constructor Create(tag,txt,ns:string);overload;override;
    property Id: string read FGetId write FSetId;
    property Language: string read FGetLanguage write FSetLanguage;
    procedure GenerateId();
  end;

implementation

{ TStanza }

constructor TStanza.Create(tag, ns: string);
begin
  inherited Create(tag);
  Namespace:=ns;
end;

constructor TStanza.Create(tag, txt, ns: string);
begin
  inherited Create(tag,txt);
  Namespace:=ns;
end;

function TStanza.FGetId: string;
begin
  Result:=AttributeValueByName['id'];
end;

function TStanza.FGetLanguage: string;
begin
  Result:=AttributeValueByName['xml:lang'];
end;

procedure TStanza.FSetId(value: string);
begin
  SetAttribute('id',value);
end;

procedure TStanza.FSetLanguage(value: string);
begin
  SetAttribute('xml:lang',value);
end;

procedure TStanza.GenerateId;
begin
  id:=tid.GetNextID;
end;

end.
