unit testnode;

interface
uses
  Generics.Collections;
type
  TNode=class
  public
    txt:string;
    nodelist:TObjectList<TNode>;
    constructor Create;
    procedure Add(nd:TNode);

  end;

implementation

var
  sss:string;
{ TNode }

procedure TNode.Add(nd: TNode);
begin
  nodelist.Add(nd);
end;

constructor TNode.Create;
begin
  nodelist:=TObjectList<TNode>.Create;
end;

end.
