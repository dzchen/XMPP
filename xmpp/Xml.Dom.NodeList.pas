unit Xml.Dom.NodeList;

interface
uses
  Classes,Xml.Dom.Node,Element,SysUtils;
type
  TNodeList=class(TList)
  private
    _owner:TNode;
    procedure RebuildIndex();overload;
    procedure RebuildIndex(start:Integer);overload;
  public
    constructor Create;overload;
    constructor Create(owner:TNode);overload;
    procedure Add(e:TNode);
    procedure Remove(index:Integer);overload;
    procedure Remove(e:TElement);overload;
    function Item(index:integer):TNode;
  end;

implementation

{ TNodeList }

procedure TNodeList.Add(e: TNode);
begin
  if e=nil then
    exit;
  if _owner<>nil then
  begin
    e.Parent=_owner;
    if e.Namespace='' then
      e.namespace:=_owner.namespace;
  end;
  e._index:=count;
  inherited Add(e);
end;

constructor TNodeList.Create;
begin

end;

constructor TNodeList.Create(owner: TNode);
begin
  _owner:=owner;
end;

function TNodeList.Item(index: integer): TNode;
begin
  Result:=Items[index];
end;

procedure TNodeList.RebuildIndex;
begin
  RebuildIndex(0);
end;

procedure TNodeList.RebuildIndex(start: Integer);
var
  i:integer;
begin
  for i := start to count-1 do
  begin
    Item(i)._index:=i;
  end;
end;

procedure TNodeList.Remove(index: Integer);
begin
  if (index>count-1) or (index<0) then
    raise Exception.Create('Index out of bounds');
  Delete(index);
  RebuildIndex(index);
end;

procedure TNodeList.Remove(e: TElement);
var
  idx:integer;
begin
  idx:=e.Index;
  Remove(e);
  RebuildIndex(idx);
end;

end.
