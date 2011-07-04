unit Stream;

interface
uses
  Stanza,NativeXml;
type
  TStream=class(TStanza)
  private
    procedure FSetStreamId(value:string);
    function FGetStreamId():string;
    procedure FSetVersion(value:string);
    function FGetVersion():string;
  public

    constructor Create();override;
    property StreamId:string read FGetStreamId write FSetStreamId;
    property Version:string read FGetVersion write FSetVersion;
  end;

implementation

{ TStream }

constructor TStream.Create();
begin
  inherited Create();
  name:='stream';
end;

function TStream.FGetStreamId: string;
begin
  Result:=AttributeValueByName['id'];
end;

function TStream.FGetVersion: string;
begin
  Result:=AttributeValueByName['version'];
end;

procedure TStream.FSetStreamId(value: string);
begin
  SetAttribute('id',value);
end;

procedure TStream.FSetVersion(value: string);
begin
  SetAttribute('version',value);
end;

end.
