unit Xml.Dom.Comment;

interface
uses
  NativeXml,XMPPConst;
type
  TComment=class(TsdComment)
  public
    constructor Create();overload;
    constructor Create(txt:string);overload;
  end;

implementation

{ TComment }

constructor TComment.Create;
begin
  inherited Create(xmldoc);
end;

constructor TComment.Create(txt: string);
begin
  Self.Create;
  Value:=txt;
end;

end.
