unit Jid;

interface
uses
    SysUtils, StrUtils, Classes;

type
    TJID = class
    private
        _raw: string;
        _user: string;
        _domain: string;
        _resource: string;
        _valid: boolean;
        _bare:string;

        function BuildJid(user,server,resource:string):string; overload;
      procedure FSetDomain(value:string);
      procedure FSetResource(value:string);

    procedure fsetuser(value:string);
    public
        procedure BuildJid(); overload;
        constructor Create(jid: string; isEscaped: boolean = true); overload;
        constructor Create(user: string; domain: string; resource: string); overload;
        constructor Create(jid: TJID); overload;
      function ToString: string;override;




        function compare(sjid: widestring; resource: boolean): boolean;
class   function applyJEP106(unescapedUser: String): String;
class   function removeJEP106(escapedUser: string): string;



        procedure ParseJID(jid: string; isEscaped: boolean = true);

        property user: string read _user write fsetuser;
        property Bare:string read _bare;
        property domain: string read _domain write FSetDomain;
        property resource: string read _resource write FSetResource;

        property isValid: boolean read _valid;
end;
function lastIndexOf(const s :string; const substr: string): integer;
//function isValidJID(jid: string; isEscaped: boolean = false): boolean;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation
uses
    Stringprep;

{
    \brief Determines if the given string is a valid JID.

    This method determines if the supplied string is a valid JID.  The optional
    parameter indicates if the user portion has already been escaped. The
    default value of the optional parameter is false to match the assumptions
    made by the Create(widestring) method (assumes it's invalid by default).

    A false return value may indicate JEP106 escaping needs to be applied.

    \param jid The string representing the JID to check.
    \param isEscaped Defaulted to false - use true if JEP106 escaping has been applied.
    \return True if is a valid JID, False if invalid.
}
{function isValidJID(jid: string; isEscaped: boolean = false): boolean;
var
    curlen, part, i, p1, p2: integer;
    c: Cardinal;
    valid_char: boolean;
    tmps: widestring;
begin
    Result := false;

    tmps := jid;

    if (isEscaped) then begin
        // If escaped 1st / and @ are the resource and node separators
        p1 := WideTextPos('@', jid);
        p2 := WideTextPos('/', jid);
    end
    else begin
        // If not escaped then 1st / after last @ is the separator
        p1 := lastIndexOf(jid, '@');
        p2 := lastIndexOf(jid, '/');
    end;

    if (p1 >= 0) then part := 0 else part := 1;

    curlen := 0;
    for i := 1 to Length(jid) do begin
        c := Ord(jid[i]);
        valid_char := false;
        if ((i = p1) and (part = 0)) then begin
            part := 1;
            curlen := 0;
        end
        else if ((i = p2) and (p2 > p1) and (part < 2)) then begin
            part := 2;
            curlen := 0;
        end
        else begin
            inc(curlen);
            case part of
            0: begin
                if (isEscaped = true) then begin
                    // user or domain
                    case c of
                    $21, $23..$25, $28..$2E,
                    $30..$39, $3B, $3D, $3F,
                    $41..$7E, $80..$D7FF,
                    $E000..$FFFD, $10000..$10FFFF: valid_char := true;
                    end;
                end
                else begin
                    case c of
                    $20..$7E, $80..$D7FF,
                    $E000..$FFFD, $10000..$10FFFF: valid_char := true;
                    end;
                end;
                if (not valid_char) then exit;
                if (curlen > 256) then exit;
            end;
            1: begin
                // domain
                case c of
                $2D, $2E, $30..$39, $5F, $41..$5A, $61..$7A: valid_char := true;
                end;
                if (not valid_char) then exit;
                if (curlen > 256) then exit;
            end;
            2: begin
                // resource
                case c of
                $20..$D7FF, $E000..$FFFD,
                $10000..$10FFFF: valid_char := true;
                end;

                if (not valid_char) then exit;
                if (curlen > 256) then exit;
            end;
        end;

        end;
    end;
    Result := true;
end;    }

{---------------------------------------}
constructor TJID.Create(jid: string; isEscaped: boolean = true);
begin
    // parse the jid
    // user@domain/resource
    inherited Create();

    _raw := jid;
    _user := '';
    _domain := '';
    _resource := '';
    _bare:='';
    if (_raw <> '') then ParseJID(_raw, isEscaped);
end;

constructor TJID.Create(user: string; domain: string; resource: string);
begin
    inherited Create();

    _raw := '';
    _user := user;
    _user:=applyJEP106(_user);
    _user:=xmpp_nodeprep(_user);

    _domain := xmpp_nameprep(domain);
    _resource :=xmpp_resourceprep( resource);
    BuildJid;
end;



procedure TJID.fsetuser(value: string);
var
  s:string;
begin
  s:=applyJEP106(value);
  _user:=xmpp_nodeprep(s);
  BuildJid;
end;



constructor TJID.Create(jid: TJID);
begin
    inherited Create();

    _raw := jid._raw;
    _user := jid._user;

    _domain := jid._domain;
    _resource := jid._resource;
end;

procedure TJID.FSetDomain(value: string);
begin
  _domain:=xmpp_nameprep(value);
  BuildJid;
end;

procedure TJID.FSetResource(value: string);
begin
  _resource:=xmpp_resourceprep(value);
  BuildJid;
end;

{---------------------------------------}
procedure TJID.ParseJID(jid: string; isEscaped: boolean = true);
var
    tmps: String;
    p1, p2: integer;
    pnode, pname, pres: string;
begin
    _user := '';
    _bare:='';
    _domain := '';
    _resource := '';
    _raw := jid;

    if (isEscaped) then begin
        // If escaped 1st / and @ are the resource and node separators
        p1 := AnsiPos('@', _raw);
        p2 := AnsiPos('/', _raw);
    end
    else begin
        // If not escaped then 1st / after last @ is the separator
        p1 := lastIndexOf(_raw, '@');
        p2 := lastIndexOf(_raw, '/');
    end;

    tmps := _raw;
    if ((p2 > 0) and (p2>p1)) then begin
        // pull off the resource..
        _resource := Copy(tmps, p2 + 1, length(tmps) - p2 + 1);
        tmps := Copy(tmps, 1, p2 - 1);
    end;

    if p1 > 0 then begin
        _domain := Copy(tmps, p1 + 1, length(tmps) - p1 + 1);
        _user := Copy(tmps, 1, p1 - 1);
    end
    else
        _domain := tmps;

    // apply JEP-106 to user portion & save display value
    if (not isEscaped) then begin

        _user := applyJEP106(_user);
    end
    else begin
        _user := removeJEP106(_user);
    end;


    // prep all parts to normalize
    if (_user <> '') then begin
        pnode := xmpp_nodeprep(_user);
        if (pnode = '') then begin
            _valid := false;
            exit;
        end;
        _user := pnode;
    end;

    pname := xmpp_nameprep(_domain);
    if (pname = '') then begin
        _valid := false;
        exit;
    end;
    _domain := pname;

    if (_resource <> '') then begin
        pres := xmpp_resourceprep(_resource);
        if (pres = '') then begin
            _valid := false;
            exit;
        end;
        _resource := pres;
    end;

    _valid := true;
end;

{---------------------------------------}
class function TJID.applyJEP106(unescapedUser: String): String;
var
  sb:TStringBuilder;
  i:integer;
  c:Char;
  function replaceEscape(input: String): String;
    var
        test, replace: String;
        idx: Integer;
    begin
        Result := '';
        while (input <> '') do begin
            idx := Pos('\', input);

            if (idx = 0) then break;
            replace := '\';
            test := UpperCase(Copy(input, idx, 3));
            if      (test = '\20') or
                    (test = '\22') or
                    (test = '\26') or
                    (test = '\27') or
                    (test = '\2F') or
                    (test = '\3A') or
                    (test = '\3C') or
                    (test = '\3E') or
                    (test = '\40') or
                    (test = '\5C') then begin
                replace := '\5C'
            end;

            Result := Result + Copy(input, 1, idx - 1) + replace;
            input := Copy(input, idx + 1, Length(input));
        end;

        Result := Result + input;
    end;
begin
   sb:=TStringBuilder.Create;
   unescapedUser:= replaceEscape(unescapedUser);
   for i := 1 to Length(unescapedUser) do
   begin
     c:=unescapedUser[i];
     case c of
      ' ':sb.Append('\20');
      '"': sb.Append('\22');
      '&': sb.Append('\26');
     '''': sb.Append('\27');
      '/': sb.Append('\2f');
     ':': sb.Append('\3a');
     '<': sb.Append('\3c');
      '>': sb.Append('\3e');
       '@': sb.Append('\40');
        '\': sb.Append('\5c');

        else
        sb.Append(c);
     end;
   end;


   Result := sb.ToString;
end;

{---------------------------------------}
class function TJID.removeJEP106(escapedUser: string): string;
var
    sb:TStringBuilder;
  i:integer;
  c1,c2,c3:Char;

begin
  sb:=TStringBuilder.Create;
  i:=1;
  while i <=Length(escapedUser) do
  begin
    c1 := escapedUser[i];
    if ((c1 = '\') and (i + 2 <= Length(escapedUser))) then
                begin
                    i :=i+ 1;
                    c2 := escapedUser[i];
                    i :=i+ 1;
                    c3 := escapedUser[i];
                    if (c2 = '2') then
                    begin
                        case (c3) of

                            '0':
                                sb.Append(' ');

                            '2':
                                sb.Append('"');

                            '6':
                                sb.Append('&');

                            '7':
                                sb.Append('''');

                            'f':
                                sb.Append('/');

                        end;
                    end
                    else if (c2 = '3') then
                    begin
                        case (c3)  of

                            'a':
                                sb.Append(':');

                            'c':
                                sb.Append('<');

                            'e':
                                sb.Append('>');

                        end;
                    end
                    else if (c2 = '4') then
                    begin
                        if (c3 = '0') then
                            sb.Append('@');
                    end
                    else if (c2 = '5') then
                    begin
                        if (c3 = 'c') then
                            sb.Append('\');
                    end;
                end
    else
      sb.Append(c1);

    i:=i+1;
  end;
  result:=sb.ToString();
  result:=StringReplace(Result,'\5C','\',[rfReplaceAll, rfIgnoreCase]);
  
end;




{---------------------------------------}

function TJID.ToString():string;
begin
        Result := _raw;
end;


{---------------------------------------}
procedure TJID.BuildJid;
begin
  _raw:=BuildJid(_user,_domain,_resource);
end;

function TJID.BuildJid(user, server, resource: string): string;
begin
  if _user <> '' then
        _bare := _user + '@' + _domain
    else
        _bare := _domain;
  result:=_bare;
  if _resource <> '' then
        Result := Result + '/' + _resource
end;

function TJID.compare(sjid: widestring; resource: boolean): boolean;
begin
    // compare the 2 jids for equality
    Result := false;
end;
{
    \brief This method searches s for the last occurance of substr.

    This method searches s for the last occurance of substr.

    \param s The string to search.
    \param substr The substring to find in given string.
    \return The index of the last occurance of substr (0 if not found).
}
function lastIndexOf(const s :string; const substr: string): integer;
var
  idx, tmp: integer;
  tmps: string;
begin
    Result := 0;
    idx    := 0;
    tmp    := 0;
    tmps   := s;

    if (length(s) = 0) then
      exit;

    repeat
        idx  := idx + tmp;
        tmps := Copy(tmps, tmp+1, length(tmps)- tmp + 1);
        tmp  := AnsiPos(substr,tmps);
    until tmp = 0;
    Result := idx;
end;

end.
