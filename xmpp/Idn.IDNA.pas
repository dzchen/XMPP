unit Idn.IDNA;

interface
uses
  stringprep,Exceptions,StrUtils,Idn.punycode,SysUtils;
const
  ACE_PREFIX = 'xn--';
type
  TIDNA=class
  public
    class function ToASCII(input:string):string;overload;
    class function ToASCII(input:string;allowunassigned,usestd3asciirules:Boolean):string;overload;
    class function ToUnicode(input:string):string;overload;
    class function ToUnicode(input:string;allowunassigned,usestd3asciirules:Boolean):string;overload;
  end;
implementation

{ TIDNA }

class function TIDNA.ToASCII(input: string; allowunassigned,
  usestd3asciirules: Boolean): string;
var
  nonascii:Boolean;
  i,c:integer;
  output:string;
begin
  nonascii:=false;
  for i := 1 to Length(input) do
  begin
    if ord(input[i])>$7f then
    begin
      nonascii:=true;
      break;
    end;
  end;
  if nonascii then
  begin
    try
      input:=xmpp_nameprep(input);
    except
      on e:TIDNAException do
        raise e;
    end;
  end;
  if usestd3asciirules then
  begin
    for i := 1 to Length(input) do
    begin
      c:=Ord(input[i]);
      if (c<=$2c)or(c>=$2e)or((c>=$3a)and(c<=$40))or((c>=$5b)and(c<=$60))or((c>=$7b)and(c<=$7f)) then
        raise TIDNAException.Create(TIDNAException.CONTAINS_NON_LDH);
    end;
    if StartsStr('-',input)or EndsStr('-',input) then
     raise TIDNAException.Create(TIDNAException.CONTAINS_HYPHEN);
  end;
  nonascii:=false;
  for i := 1 to Length(input) do
  begin
    if Ord(input[i])>$7f then
    begin
      nonascii:=true;
      break;
    end;
  end;
  output:=input;
  if nonascii then
  begin
    if StartsText(ACE_PREFIX,input) then
      raise TIDNAException.Create(TIDNAException.CONTAINS_ACE_PREFIX);
    try
      output:=TPunycode.Decode(input);
    except
      on e:TPunycodeException do
        raise TIDNAException.Create(e);
    end;
    output:=ACE_PREFIX+output;
  end;
  if (Length(output)<1) or (Length(output)>63) then
    raise TIDNAException.Create(TIDNAException.TOO_LONG);
  Result:=output;
end;

class function TIDNA.ToASCII(input: string): string;
var
  o,h:TStringBuilder;
  i:integer;
  c:char;
begin
  o:=TStringBuilder.Create;
  h:=TStringBuilder.Create;
  for i := 1 to Length(input) do
  begin
    c:=input[i];
    if (c='.') or (c=#$3002) or (c=#$ff0e) or (c=#$ff61) then
    begin
      o.Append(ToASCII(h.ToString,False,True));
      o.Append('.');
      h.Clear;
    end
    else
      h.Append(c);
  end;
  o.Append(ToASCII(h.ToString,False,true));
  Result:=o.ToString;
end;

class function TIDNA.ToUnicode(input: string; allowunassigned,
  usestd3asciirules: Boolean): string;
var
  original,stored,output,ascii:string;
  nonascii:Boolean;
  i:integer;
  c:char;
begin
  original:=input;
  nonascii:=false;
  for i := 1 to Length(input) do
  begin
    c:=input[i];
    if ord(c)>$7f then
    begin
      nonascii:=true;
      Break;
    end;
  end;
  if nonascii then
  begin
    try
      input:=xmpp_nameprep(input);
    except
      on e:TStringprepException do
      begin
        Result:=original;
        Exit;
      end;
    end;
  end;
  if not StartsText(ACE_PREFIX,input) then
  begin
    Result:=original;
    exit;
  end;
  stored:=input;
  input:=MidStr(input,1,Length(ACE_PREFIX));
  try
    output:=TPunycode.Encode(input);
  except
    on e:TPunycodeException do
    begin
      Result:=original;
      exit;
    end;
  end;
  try
    ascii:=ToASCII(output,allowunassigned,usestd3asciirules);
  except
    on e:TIDNAException do
    begin
      Result:=original;
      exit;
    end;
  end;
  if UpperCase(ascii)<>UpperCase(stored) then
  begin
    Result:=original;
    exit;
  end;
  result:=output;
end;

class function TIDNA.ToUnicode(input: string): string;
var
  o,h:TStringBuilder;
  c:Char;
  i:integer;
begin
  input:=LowerCase(input);
  o:=TStringBuilder.Create;
  h:=TStringBuilder.Create;
  for i := 1 to Length(input) do
  begin
    c:=input[i];
    if (c='.')or(c=#$3002)or(c=#$ff0e)or(c=#$ff61) then
    begin
      o.Append(ToUnicode(h.ToString,false,true));
      o.Append(c);
      h.Clear;
    end
    else
      h.Append(c);
  end;
  o.Append(ToUnicode(h.ToString,False,true));
  Result:=o.ToString;
end;

end.
