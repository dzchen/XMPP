unit Element;

interface
uses
  NativeXml;
type
  TElement=class(TsdElement)
    private
      _prefix:string;

      function  FGetIsRootElement:Boolean;
    public
      constructor Create(Aowner:TNativeXml);overload;
      constructor Create(Aowner:TNativeXml;tagname:string);overload;

      constructor Create(Aowner:TNativeXml;tagname:string;tagtext:Boolean);overload;
      constructor Create(Aowner:TNativeXml;tagname,tagtext,ns:string);overload;

      property IsRootElement:Boolean read FGetIsRootElement;
      property Prefix:string read _prefix write _prefix;
  end;

implementation

{ TElement }


constructor TElement.Create(Aowner: TNativeXml; tagname: string);
begin
  inherited CreateName(Aowner,tagname);
end;

constructor TElement.Create(Aowner: TNativeXml);
begin
  inherited Create(Aowner);
end;

constructor TElement.Create(Aowner: TNativeXml; tagname, tagtext, ns: string);
begin
  inherited CreateNameValue(Aowner,tagname,tagtext);
  AttributeAdd('xmlns',ns);
end;

constructor TElement.Create(Aowner: TNativeXml; tagname: string;
  tagtext: Boolean);
var
  t:string;
begin
  if(tagtext)then t:='true'else t:='false';
   inherited CreateNameValue(Aowner,tagname,t);
end;

function TElement.FGetIsRootElement: Boolean;
begin
  Result:=(Parent=nil);

end;

end.
