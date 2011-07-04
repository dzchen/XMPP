unit testinit;

interface
uses
  Generics.Collections;
type
  Ttestinit=class
  class function GetList():Integer;
  class procedure Add(s:string);
  end;

implementation
var
  ls:TList<string>;
{ Ttestinit }

class procedure Ttestinit.Add(s: string);
begin
  ls.Add(s);
end;

class function Ttestinit.GetList: Integer;
begin
  Result:=ls.Count;
end;

initialization
  ls:=tlist<string>.create;
  Ttestinit.Add('1');
  Ttestinit.Add('2');
finalization
  ls.Clear;
end.
