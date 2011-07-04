unit JidComparer;

interface
uses
  Generics.Defaults,jid,SysUtils;
type
  TBareJidComparer=class(TComparer<TJID>)
  public
    function Compare(x,y:TJID):integer;
  end;
  TFullJidComparer=class(TComparer<TJID>)
  public
    function Compare(x,y:TJID):integer;
  end;


implementation

{ TBareJidComparer }

function TBareJidComparer.Compare(x, y: TJID): integer;
var
  s1,s2:string;
begin
  if (x=nil) and (y=nil) then
  begin
    Result:=0;
    exit;
  end;
  if x=nil then
  begin
    Result:=1;
    exit;
  end;
  if y=nil then
  begin
    Result:=-1;
    exit;
  end;
  s1:=x.Bare;
  s2:=y.Bare;
  if s1=s2 then
    Result:=0
  else
  Result:=CompareText(s1,s2);
end;

{ TFullJidComparer }

function TFullJidComparer.Compare(x, y: TJID): integer;
var
  s1,s2:string;
begin
  if (x=nil) and (y=nil) then
  begin
    Result:=0;
    exit;
  end;
  if x=nil then
  begin
    Result:=1;
    exit;
  end;
  if y=nil then
  begin
    Result:=-1;
    exit;
  end;
  s1:=x.ToString;
  s2:=y.ToString;
  if s1=s2 then
    Result:=0
  else
  Result:=CompareText(s1,s2);

end;

end.
