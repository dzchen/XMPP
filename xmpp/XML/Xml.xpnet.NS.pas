unit Xml.xpnet.NS;

interface
uses
  Generics.Collections,SysUtils;
type
  TNS=class
  private
    _stack:TobjectStack<TobjectDictionary<string,string>>;
    function FGetDefaultNamespace:string;
  public
    constructor Create();
    destructor Destory;
    procedure PushScope();
    procedure PopScope();
    procedure AddNamespace(prefix,uri:string);
    function LookupNamespace(prefix:string):string;
    property DefaultNamespace:string read FGetDefaultNamespace;
    function ToString():string;override;
    procedure Clear();
  end;

implementation

{ TNS }

procedure TNS.AddNamespace(prefix, uri: string);
begin
  _stack.Peek.Add(prefix,uri);
end;

procedure TNS.Clear;
begin
  _stack.Clear;
end;

constructor TNS.Create;
begin
  _stack:=TobjectStack<TobjectDictionary<string,string>>.create;
  PushScope;
  AddNamespace('xmlns','http://www.w3.org/2000/xmlns/');
  AddNamespace('xml','http://www.w3.org/XML/1998/namespace');
end;

destructor TNS.Destory;
begin
  _stack.Free;
end;

function TNS.FGetDefaultNamespace: string;
begin
  Result:=LookupNamespace('');
end;

function TNS.LookupNamespace(prefix: string): string;
var
  dic:TArray<TobjectDictionary<string,string>>;
  i:integer;
begin
  Result:='';
  dic:=_stack.ToArray;
  for i:=Length(dic)-1 downto 0 do
  begin
    if (dic[i].Count>0) and (dic[i].ContainsKey(prefix)) then
    begin
      Result:=dic[i][prefix];
      Exit;
    end;
  end;
end;

procedure TNS.PopScope;
begin
  _stack.Pop;
end;

procedure TNS.PushScope;
begin
  _stack.Push(TobjectDictionary<string,string>.Create);
end;

function TNS.ToString: string;
var
  sb:tstringbuilder;
  s:string;
  dic:TobjectDictionary<string,string>;
begin
  sb:=TStringBuilder.Create;
  for dic in _stack do
  begin
    sb.Append('---\n');
    for s in dic.Keys do
      sb.Append(s+'='+dic[s]+'\n');
  end;
  Result:=sb.ToString;
end;

end.
