unit protocol.stream.feature.compression.Compression;

interface
uses
  Element,XmppUri,Generics.Collections,protocol.stream.feature.compression.Method;
type
  TCompression=class(TElement)
  private
    function FGetMethod:string;
    procedure FSetMethod(value:string);
  public
    constructor Create;override;
    property Method:string read FGetMethod write FSetMethod;
    procedure AddMethod(md:string);
    function SupportsMethod(md:string):Boolean;
    function GetMethods:TList<TElement>;
  end;

implementation

{ TCompression }

procedure TCompression.AddMethod(md: string);
begin
  if not SupportsMethod(md) then
    NodeAdd(TMethod.Create);
end;

constructor TCompression.Create;
begin
  inherited Create;
  Name:='compression';
  Namespace:=XMLNS_FEATURE_COMPRESS;
end;

function TCompression.FGetMethod: string;
begin
  Result:=GetTag('method');
end;

procedure TCompression.FSetMethod(value: string);
begin
  if value<>'Unknown' then
    SetTag('method',value);
end;

function TCompression.GetMethods: TList<TElement>;
begin
  Result:=SelectElements(TMethod.ClassInfo);
end;

function TCompression.SupportsMethod(md: string): Boolean;
var
  el:TList<TElement>;
  e:TElement;
begin
  el:=SelectElements(TMethod.ClassInfo);
  for e in el do
  begin
    if TMethod(e).CompressionMethod=md then
    begin
      Result:=true;
      exit;
    end;
  end;
  Result:=False;
end;

end.
