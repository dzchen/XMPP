unit RosterItem;

interface
uses
  Item,Classes,group;
type
  TRosterItem=class(TItem)
  public
    procedure GetGroups(const alist:TList);
    procedure AddGroup(groupname:string);
    function HasGroup(groupname:string):Boolean;
    procedure RemoveGroup(groupname:string);

  end;

implementation

{ TRosterItem }

procedure TRosterItem.AddGroup(groupname: string);
var
  g:TGroup;
begin
  g:=TGroup.Create(groupname);
  NodeAdd(g);
end;

procedure TRosterItem.GetGroups(const alist: TList);
begin
  FindNodes('group',alist);
end;

function TRosterItem.HasGroup(groupname: string): Boolean;
var
  alist:TList;
  i:Integer;
begin
  alist:=TList.Create;
  GetGroups(alist);
  for i := 1 to alist.Count do
  begin

    if(TGroup(alist[i]).ItemName=groupname) then
    begin
      Result:=true;
      exit;
    end;
  end;
  Result:=False;
end;

procedure TRosterItem.RemoveGroup(groupname: string);
var
  alist:TList;
  i:Integer;
begin
  alist:=TList.Create;
  GetGroups(alist);
  for i := 1 to alist.Count do
  begin
    if(TGroup(alist[i]).ItemName=groupname) then
    begin
      NodeRemove(alist[i]);
      exit;
    end;
  end;
end;

end.
