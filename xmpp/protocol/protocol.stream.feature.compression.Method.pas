unit protocol.stream.feature.compression.Method;

interface
uses
  Element,XmppUri;
type
  TMethod=class(TElement)
  private
    function FGetCompressionMethod:string;
    procedure FSetCompressionMethod(value:string);
  public
    constructor Create();override;
    constructor Create(md:string);overload;
    property CompressionMethod:string read FGetCompressionMethod write FSetCompressionMethod;
  end;

implementation

{ TMethod }

constructor TMethod.Create;
begin
  inherited Create;
  Name:='method';
  Namespace:=XMLNS_FEATURE_COMPRESS;
end;

constructor TMethod.Create(md: string);
begin
  self.Create;
  self.Value:=md;
end;

function TMethod.FGetCompressionMethod: string;
begin
  Result:=value;
end;

procedure TMethod.FSetCompressionMethod(value: string);
begin
  self.Value:=value;
end;

end.
