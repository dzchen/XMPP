unit StringUtils;

interface
uses
  classes,SysUtils;

procedure Split(const str: string; const c: Char; var List: TStrings);
function ToHex(buf:TBytes;start:Integer=0;count:integer=0):string;

implementation
procedure Split(const str: string; const c: Char; var List: TStrings);
begin
  List.Clear;
  List.Delimiter := c;
  List.DelimitedText := str;
end;
function ToHex(buf:TBytes;start:Integer=0;count:integer=0):string;
var
  s:string;
  i:integer;
begin
  s:='';
  if count=0 then
    count:=Length(buf);
  for i := start to count-1 do
    s:=s+Format('%.2x',[buf[i]]);
  Result:=s;
end;
end.
