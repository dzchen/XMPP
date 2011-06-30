unit Text;

interface
uses
  NativeXml;
type
  TText=class(TsdCharData)
  public
    constructor Create();overload;
    constructor Create(text:string);overload;
  end;

implementation

{ TText }

constructor TText.Create;
begin

end;

constructor TText.Create(text: string);
begin

end;

end.
