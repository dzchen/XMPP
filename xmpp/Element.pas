unit Element;

interface
uses
  NativeXml;
type
  TElement=class(TsdElement)
    private
      _tagname:string;
      _prefix:string;
    public
      constructor Create;
  end;

implementation

{ TElement }

constructor TElement.Create;
begin

end;

end.
