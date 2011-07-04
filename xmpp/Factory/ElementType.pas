unit ElementType;

interface
type
  TElementType=record
  private
    _tagname,_namespace:string;
  public
    constructor Create(tagname,namespace:string);
    function ToString():string;
  end;

implementation

{ TElementType }

constructor TElementType.Create(tagname, namespace: string);
begin
  _tagname:=tagname;
  _namespace:=namespace;
end;

function TElementType.ToString: string;
begin
  if(_namespace<>'')then
    Result:=_namespace+':'+_tagname
  else
    Result:=_tagname;
end;

end.
