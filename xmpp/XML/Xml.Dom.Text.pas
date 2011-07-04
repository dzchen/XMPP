unit Xml.Dom.Text;

interface
uses
  NativeXml,XMPPConst;
type
  TText=class(TsdCharData)
  public
    constructor Create();overload;
    constructor Create(txt:string);overload;
  end;

implementation

{ TText }

constructor TText.Create;
begin
  inherited Create(xmldoc);
end;

constructor TText.Create(txt: string);
begin
  self.Create;
  self.Value:=txt;
end;

end.
