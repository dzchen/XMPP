unit Element;

interface
uses
  NativeXml;
type
  TElement=class(TsdElement)
    private
      _prefix:string;
      _namespace:string;
      _value:TsdCharData;
      function  FGetIsRootElement:Boolean;
      function FGetValue:string;
      procedure FSetValue(value:string);
      function FGetNamespace:string;
      procedure FSetNamespace(value:string);
      function FGetPrefix:string;
      procedure FSetPrefix(value:string);
    public
      constructor Create(Aowner:TNativeXml);overload;
      constructor Create(Aowner:TNativeXml;tagname:string);overload;

      constructor Create(Aowner:TNativeXml;tagname:string;tagtext:Boolean);overload;
      constructor Create(Aowner:TNativeXml;tagname,tagtext,ns:string);overload;

      property IsRootElement:Boolean read FGetIsRootElement;
      property Prefix:string read FGetPrefix write FSetPrefix;
      property Value:string  read FGetValue write FSetValue;
      property Namespace:string read FGetNamespace write FSetNamespace;

  end;

implementation

{ TElement }


constructor TElement.Create(Aowner: TNativeXml; tagname: string);
begin
  Create(Aowner);
  Name:=tagname;
end;

constructor TElement.Create(Aowner: TNativeXml);
begin
  inherited Create(Aowner);
  _value:=TsdCharData.Create(Aowner);
  NodeAdd(_value);
end;

constructor TElement.Create(Aowner: TNativeXml; tagname, tagtext, ns: string);
begin
  Create(Aowner);
  Name:=tagname;
  Value:=tagtext;
  Namespace:=ns;

end;

constructor TElement.Create(Aowner: TNativeXml; tagname: string;
  tagtext: Boolean);
var
  t:string;
begin
  if(tagtext)then t:='true'else t:='false';
  Create(Aowner);
  Name:=tagname;
  Value:=t;
end;

function TElement.FGetIsRootElement: Boolean;
begin
  Result:=(Parent=nil);
end;

function TElement.FGetNamespace: string;
begin
  Result:=_namespace;
end;

function TElement.FGetPrefix: string;
begin

end;

function TElement.FGetValue: string;
begin
  Result:=_value.Value;
end;

procedure TElement.FSetNamespace(value: string);
begin
  _namespace:=value;
  AttributeAdd('xmlns',_namespace);
end;

procedure TElement.FSetPrefix(value: string);
begin
  _prefix:=value;
  if(_prefix<>'')then
  begin
    Name:=_prefix+':'+Name;
    if _namespace<>'' then
    begin
      AttributeDelete(AttributeIndexByName('xmlns'));
      AttributeAdd('xmlns:'+_prefix,_namespace);
    end;
  end;
end;

procedure TElement.FSetValue(value: string);
begin
  _value.Value:=value;
end;

end.
