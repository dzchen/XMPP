unit protocol.extensions.compression.Compress;

interface
uses
  Element,XmppUri;
type
  TCompress=class(TElement)
  private
    function FGetMethod:string;
    procedure FSetMethod(value:string);
  public
    constructor Create;override;
    constructor Create(md:string);overload;
    property Method:string read FGetMethod write FSetMethod;
  end;
  TCompressed=class(TElement)
  public
    constructor Create;overload;
  end;

implementation

{ TCompress }

constructor TCompress.Create;
begin
  inherited Create;
  Name:='compress';
  Namespace:=XMLNS_COMPRESS;
end;

constructor TCompress.Create(md: string);
begin
  self.Create;
  Self.Method:=md;
end;

function TCompress.FGetMethod: string;
begin
  Result:=GetTag('method');
end;

procedure TCompress.FSetMethod(value: string);
begin
  if value<>'Unknown' then
    SetTag('method',value);
end;

{ TCompressed }

constructor TCompressed.Create;
begin
  inherited Create;
  Name:='compressed';
  Namespace:=XMLNS_COMPRESS;
end;

end.
