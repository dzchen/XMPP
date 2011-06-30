{
    Copyright 2001-2008, Estate of Peter Millard
	
	This file is part of Exodus.
	
	Exodus is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.
	
	Exodus is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with Exodus; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
unit XMLUtils;


interface
uses
      Classes, SysUtils;

function XML_EscapeChars(txt: Utf8String): Utf8String;
function XML_UnEscapeChars(txt: Utf8String): Utf8String;

function HTML_EscapeChars(txt: Utf8String; DoAPOS: boolean; DoQUOT: boolean): Utf8String;
function URL_EscapeChars(txt: Utf8String): Utf8String;

function TrimQuotes(instring: Utf8String): Utf8String;
function RightChar(instring: Utf8String; nchar: word): Utf8String;
function LeftChar(instring: Utf8String; nchar: word): Utf8String;
function SToInt(inp: Utf8String): integer;
function NameMatch(s1, s2: Utf8String): boolean;
function Sha1Hash(fkey: Utf8String): Utf8String;
function MD5File(filename: Utf8String): string; overload;
function MD5File(stream: TStream): string; overload;
function EncodeString(value: Utf8String): Utf8String;
function DecodeString(value: Utf8String): Utf8String;
function MungeFileName(str: Utf8String): Utf8String;
function MungeXMLName(str: Utf8String): Utf8String;
function SafeInt(str: Utf8String): integer;
function SafeBool(str: Utf8String): boolean;
function SafeBoolStr(value: boolean) : Utf8String;

function JabberToDateTime(datestr: Utf8String): TDateTime;
function XEP82DateTimeToDateTime(datestr: Utf8String): TDateTime;
function DateTimeToJabber(dt: TDateTime): Utf8String;
function DateTimeToXEP82Date(dt: TDateTime): Utf8String;
function DateTimeToXEP82DateTime(dt: TDateTime; dtIsUTC: boolean = false): Utf8String;
function DateTimeToXEP82Time(dt: TDateTime; dtIsUTC: boolean = false): Utf8String;
function GetTimeZoneOffset(): Utf8String;
function UTCNow(): TDateTime;
//returns a reference to a delay tag found in tag, or nil if none exists
//function GetDelayTag(tag: TXMLTag): TXMLTag;

function GetAppVersion: string;



//function generateEventMsg(tag: TXMLTag; event: Utf8String): TXMLTag;

procedure parseNameValues(list: TStringlist; str: Utf8String);

//function StringToXMLTag(input: Utf8String): TXMLTag;

//function ErrorText(tag :TXMLTag): Utf8String;

{$ifdef VER150}
    {$define INDY9}
{$endif}


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation
uses
    {$ifdef Win32}
    Forms, Windows,
    {$else}
    QForms,
    {$endif}

    IdGlobal,
    {$ifdef INDY9}
    IdHashMessageDigest, IdHash, IdCoderMime,
    {$else}
    IdCoder3To4,
    {$endif}
    SecHash,
    JabberConst,
//    XMLParser,
    StrUtils,
    DateUtils;
function XPLiteEscape(value: Utf8String): Utf8String;
var
    r: Utf8String;
    c: PWideChar;
    d: PWideChar;
    e: PWideChar;
    i: integer;
begin
    // Escape " to ""
    i := 0;
    c := @value[1];
    repeat
        c := (c, WideChar(Chr(34)));
        if (c <> nil) then begin
            inc(i);
            inc(c);
        end;
    until (c = nil);

    // alloc enough
    SetLength(r, Length(value) + i);
    d := @value[1];
    e := @value[Length(value)];
    c := StrScanW(d, WideChar(Chr(34)));
    i := 1;
    while (c <> nil) do begin
        StrLCopyW(@r[i], d, c - d + 1);
        i := i + c - d + 1;
        r[i] := '"';
        inc(i);
        if (c <> e) then begin
            d := c + 1;
            c := StrScanW(d, WideChar(Chr(34)));
            end
        else begin
            d := nil;
            break;
            end;
    end;

    if (d <> nil) then
        StrLCopyW(@r[i], d, e - d + 1);
    Result := r;
end;

{---------------------------------------}
function HTML_EscapeChars(txt: Utf8String; DoAPOS: boolean; DoQUOT: boolean): Utf8String;
var
    tmps: Utf8String;
    i: integer;
begin
    // escape special chars .. not &apos; --> only XML

    // Joe, Can we optimize this w/ regex please??
    // No.  Regexes don't do well where the replacement has to be different
    // based on the input.  Any regex would be N times slower than this.
    tmps := '';
    for i := 1 to length(txt) do begin
        if txt[i] = '&' then tmps := tmps + '&amp;'
        else if (txt[i] = Chr(39)) and (DoAPOS) then tmps := tmps + '&apos;'
        else if (txt[i] = '"') and (doQUOT) then tmps := tmps + '&quot;'
        else if txt[i] = '<' then tmps := tmps + '&lt;'
        else if txt[i] = '>' then tmps := tmps + '&gt;'
        else tmps := tmps + txt[i];
    end;
    Result := tmps;
end;

{---------------------------------------}
function URL_EscapeChars(txt: Utf8String): Utf8String;
var
    utxt : String;
    tmps : String;
    i : integer;
const
    az : set of char = ['a'..'z', 'A'..'Z', '0'..'9', '-', '_', '/', ':', '\', '.', '?', '@', '=', '&', '+'];
begin
    utxt := UTF8Encode(txt);
    for i := 1 to length(utxt) do begin
        if (utxt[i] in az) then
            tmps := tmps + utxt[i]
        else
            tmps := tmps + '%' + format('%02x', [ord(utxt[i])]);
    end;
    result := tmps;
end;

{---------------------------------------}
function XML_EscapeChars(txt: Utf8String): Utf8String;
begin
    // escape the special chars.
    Result := HTML_EscapeChars(txt, true, true);
end;

{---------------------------------------}
function XML_UnescapeChars(txt: Utf8String): Utf8String;
var
    tok, tmps: Utf8String;
    a, i: integer;
begin
    // un-escape the special chars.
    tmps := '';
    i := 1;
    while i <= length(txt) do begin
        // amp
        if txt[i] = '&' then begin
            a := i;
            repeat
                inc(i);
            until (txt[i] = ';') or (i >= length(txt));
            tok := Copy(txt, a+1, i-a-1);
            if tok = 'amp' then tmps := tmps + '&';
            if tok = 'quot' then tmps := tmps + '"';
            if tok = 'apos' then tmps := tmps + Chr(39);
            if tok = 'lt' then tmps := tmps + '<';
            if tok = 'gt' then tmps := tmps + '>';
            inc(i);
        end
        else begin
            // normal char
            tmps := tmps + txt[i];
            inc(i);
        end;
    end;
    Result := tmps;
end;

{---------------------------------------}
function TrimQuotes(instring: Utf8String): Utf8String;
var
	tmps: Utf8String;
begin
	{strip off first and last " or ' characters}
    tmps := Trim(instring);
    if Leftchar(tmps, 1) = '"' then
    	tmps := RightChar(tmps, length(tmps) - 1);
    if RightChar(tmps, 1) = '"' then
    	tmps := LeftChar(tmps, Length(tmps) - 1);
    if Leftchar(tmps, 1) = Chr(39) then
    	tmps := RightChar(tmps, length(tmps) - 1);
    if RightChar(tmps, 1) = Chr(39) then
    	tmps := LeftChar(tmps, Length(tmps) - 1);

    Result := tmps;
end;

{---------------------------------------}
function RightChar(instring: Utf8String; nchar: word): Utf8String;
var
	tmps: Utf8String;
begin
	{returns the rightmost n characters of a string}
    tmps := Copy(instring, length(instring) - nchar + 1, nchar);
    Result := tmps;
end;

{---------------------------------------}
function LeftChar(instring: Utf8String; nchar: word): Utf8String;
var
	tmps: Utf8String;
begin
	{returns the leftmost n characters of a string}
    tmps := Copy(instring, 1, nchar);
    Result := tmps;
end;

{---------------------------------------}
function SToInt(inp: Utf8String): integer;
var
	tmpi: integer;
begin
    // exception safe version of StrToInt
	try
    	tmpi := StrToInt(Trim(inp));
    except on EConvertError do
    	tmpi := 0;
end;
    Result := tmpi;
end;

{---------------------------------------}
function NameMatch(s1, s2: Utf8String): boolean;
begin
    Result := (StrCompW(PWideChar(s1), PWideChar(s2)) = 0);
end;

{---------------------------------------}
function Sha1Hash(fkey: Utf8String): Utf8String;
var
    hasher: TSecHash;
    h: TIntDigest;
    i: integer;
    s: Utf8String;
begin
    // Do a SHA1 hash using the sechash.pas unit
    hasher := TSecHash.Create(nil);
    h := hasher.ComputeString(UTF8Encode(fkey));
    s := '';
    for i := 0 to 4 do
        s := s + IntToHex(h[i], 8);
    s := Lowercase(s);
    hasher.Free;
    Result := s;
end;

{$ifdef INDY9}
function MD5File(filename: Utf8String): string;
var
    fstream: TFileStream;
begin
    try
        fstream := TFileStream.Create(filename, fmOpenRead or fmShareDenyNone);
        Result := MD5File(fstream);
        fStream.Free();
    except
        Result := '';
    end;
end;

function MD5File(stream: TStream): string;
var
    md: TIdHashMessageDigest5;
    Digest: T4x4LongWordRecord;
    S: String;
    pos: int64;
begin
    md := TIdHashMessageDigest5.Create();
    pos := stream.Position;
    stream.Seek(0, soFromBeginning);
    Digest := md.HashValue(stream);
    S := md.AsHex(Digest);
    Result := Lowercase(S);
    stream.Position := pos;
    md.Free();
end;

{$else}
// TODO: Do we need a version of md5file for < INDY9??
function MD5File(filename: Utf8String): string;
begin
    Result := '';
end;

function MD5File(stream: TStream): string;
begin
    Result := '';
end;
{$endif}


{---------------------------------------}
function EncodeString(value: Utf8String): Utf8String;
var
    tmps: String;
    {$ifdef INDY9}
    e: TIdEncoderMIME;
    {$else}
    e: TIdBase64Encoder;
    {$endif}
begin
    // do base64 encode
    {$ifdef INDY9}
    e := TIdEncoderMime.Create(nil);
    tmps := e.Encode(value);
    {$else}
    e := TIdBase64Encoder.Create(nil);
    e.CodeString(value);
    tmps := e.CompletedInput();
    Fetch(tmps, ';');
    {$endif}
    e.Free();
    Result := tmps;
end;

{---------------------------------------}
function DecodeString(value: Utf8String): Utf8String;
var
    tmps: string;
    {$ifdef INDY9}
    d: TIdDecoderMime;
    {$else}
    d: TIdBase64Decoder;
    {$endif}
begin
    // do base64 decode
    {$ifdef INDY9}
    d := TIdDecoderMime.Create(nil);
    tmps := d.DecodeString(value);
    {$else}
    d := TIdBase64Decoder.Create(nil);
    d.CodeString(value);
    tmps := d.CompletedInput();
    Fetch(tmps, ';');
    {$endif}
    d.Free();
    Result := tmps;
end;

{---------------------------------------}
function MungeFileName(str: Utf8String): Utf8String;
var
    i: integer;
    c, fn: Utf8String;
begin
    // Munge some string into a filename
    // Removes all chars which aren't allowed
    fn := '';
    for i := 0 to Length(str) - 1 do begin
        c := str[i + 1];
        if ( (c='@') or
             (c=':') or
             (c='|') or
             (c='<') or
             (c='>') or
             (c='\') or
             (c='/') or
             (c='*') or
             (c=' ') or
             (c=',')) then
            fn := fn + '_'
        else if (c > Chr(122)) then
            fn := fn + '_'
        else
            fn := fn + c;
    end;
    Result := fn;
end;

{---------------------------------------}
{ This function will take a string and translate it into a valid XML element name.
  NOTE: It does NOT make 100% sure that the name is valid XML as it doesn't
        check to see that the first char is a letter or - nor does it check
        to make sure the first 3 chars are not XML or some variation.  It only
        makes sure the chars are: a-z, A-Z, 0-9, -, _, .   All other chars
        are changed to _.  }
function MungeXMLName(str: Utf8String): Utf8String;
var
    i: integer;
    name: Utf8String;
    c: Widechar;
const
    validchars : set of char = ['a'..'z', 'A'..'Z', '0'..'9', '-', '_', '.'];
begin
    // Munge some string into a filename
    // Removes all chars which aren't allowed
    name := '';
    for i := 0 to Length(str) - 1 do begin
        c := str[i + 1];
        if (c in validchars) then
        begin
            name := name + c;
        end
        else begin
            name := name + '_';
        end;
    end;
    Result := name;
end;

{---------------------------------------}
function SafeInt(str: Utf8String): integer;
begin
    // Null safe string to int function
    Result := StrToIntDef(str, 0);
end;

{---------------------------------------}
function SafeBool(str: Utf8String): boolean;
var
    l: Utf8String;
begin
    l := trim(WideLowerCase(str));
    Result := ((l = 'yes') or (l = 'true') or (l = 'ok') or (l = '-1') or (l = '1'))
end;

{---------------------------------------}
function SafeBoolStr(value: boolean) : Utf8String;
begin
    if value then
        Result := 'true'
    else
        Result := 'false';
end;

{---------------------------------------}
procedure ClearListObjects(l: TList);
var
    i: integer;
begin
    for i := 0 to l.Count - 1 do begin
        if (l[i] <> nil) then begin
            TObject(l[i]).Free();
            l[i] := nil;
        end;
    end;
end;

{---------------------------------------}
procedure ClearStringListObjects(sl: TStringList); overload;
var
    i: integer;
    o: TObject;
begin
    //
    for i := 0 to sl.Count - 1 do begin
        if (sl.Objects[i] <> nil) then begin
            o := TObject(sl.Objects[i]);
            o.Free();
            sl.Objects[i] := nil;
        end;
    end;
end;

{---------------------------------------}
procedure ClearStringListObjects(sl: TUtf8StringList); overload;
var
    i: integer;
    o: TObject;
begin
    //
    for i := 0 to sl.Count - 1 do begin
        if (sl.Objects[i] <> nil) then begin
            o := TObject(sl.Objects[i]);
            o.Free();
            sl.Objects[i] := nil;
        end;
    end;
end;


{---------------------------------------}
function JabberToDateTime(datestr: Utf8String): TDateTime;
var
    rdate: TDateTime;
    ys, ms, ds, ts: Utf8String;
    yw, mw, dw: Word;
begin
    // Converts assumed UTC time to local.
    // translate date from 20000110T19:54:00 to proper format..
    ys := Copy(Datestr, 1, 4);
    ms := Copy(Datestr, 5, 2);
    ds := Copy(Datestr, 7, 2);
    ts := Copy(Datestr, 10, 8);

    try
        yw := StrToInt(ys);
        mw := StrToInt(ms);
        dw := StrToInt(ds);

        if (TryEncodeDate(yw, mw, dw, rdate)) then begin
            rdate := rdate + StrToTime(ts);
            Result := rdate - TimeZoneBias(); // Convert to local time
        end
        else
            Result := Now();
    except
        Result := Now;
    end;
end;

{---------------------------------------}
function XEP82DateTimeToDateTime(datestr: Utf8String): TDateTime;
var
    rdate: TDateTime;
    ys, ms, ds, ts: Utf8String;
    yw, mw, dw: Word;
    tzd: Utf8String;
    tzd_hs: Utf8String;
    tzd_ms: Utf8String;
    tzd_hw: word;
    tzd_mw: word;
begin
    // Converts UTC or TZD time to Local Time
    // translate date from 2008-06-11T10:10:23.102Z (2008-06-11T10:10:23.102-06:00) or to properformat
    Result := Now();

    datestr := Trim(datestr);
    if (Length(datestr) = 0) then exit;

    ys := Copy(datestr, 1, 4);
    ms := Copy(datestr, 6, 2);
    ds := Copy(datestr, 9, 2);
    ts := Copy(datestr, 12, 8);

    if (RightStr(datestr, 1) = 'Z') then
    begin
        // Is UTC
        try
            yw := StrToInt(ys);
            mw := StrToInt(ms);
            dw := StrToInt(ds);

            if (TryEncodeDate(yw, mw, dw, rdate)) then begin
                rdate := rdate + StrToTime(ts);
                Result := rdate - TimeZoneBias(); // Convert to local time
            end
            else
                Result := Now();
        except
            Result := Now;
        end;
    end
    else begin
        // Is not UTC so convert to UTC
        tzd := Copy(datestr, Length(datestr) - 5, 6);
        tzd_hs := Copy(tzd, 2, 2);
        tzd_ms := Copy(tzd, 5, 2);

        try
            yw := StrToInt(ys);
            mw := StrToInt(ms);
            dw := StrToInt(ds);
            tzd_hw := StrToInt(tzd_hs);
            tzd_mw := StrToInt(tzd_ms);

            if (TryEncodeDate(yw, mw, dw, rdate)) then
            begin
                rdate := rdate + StrToTime(ts);
                // modify time for TZD offset.
                if (LeftStr(tzd, 1) = '+') then
                begin
                    // Time is greater then UTC so subtract time
                    rdate := IncHour(rdate, (-1 * tzd_hw));
                    rdate := IncMinute(rdate, (-1 * tzd_mw));
                end
                else begin
                    // Time is less then UTC so add time
                    rdate := IncHour(rdate, tzd_hw);
                    rdate := IncMinute(rdate, tzd_mw);
                end;

                // Now that we have UTC, change ot local
                Result := rdate - TimeZoneBias();
            end
            else begin
                Result := Now();
            end;
        except
            Result := Now();
        end;
    end;

end;

{---------------------------------------}
function DateTimeToJabber(dt: TDateTime): Utf8String;
begin
    // Format the current date/time into "Jabber" format
    Result := FormatDateTime('yyyymmdd', dt);
    Result := Result + 'T';
    Result := Result + FormatDateTime('hh:nn:ss', dt);
end;

{---------------------------------------}
function DateTimeToXEP82Date(dt: TDateTime): Utf8String;
begin
    Result := FormatDateTime('yyyy-mm-dd', dt);
end;

{---------------------------------------}
function DateTimeToXEP82DateTime(dt: TDateTime; dtIsUTC: boolean): Utf8String;
begin
    Result := DateTimeToXEP82Date(dt);
    Result := Result + 'T';
    Result := Result + DateTimeToXEP82Time(dt, dtIsUTC);
end;

{---------------------------------------}
function DateTimeToXEP82Time(dt: TDateTime; dtIsUTC: boolean): Utf8String;
begin
    // Convert Time
    Result := FormatDateTime('hh:mm:ss.zzz', dt);

    // Add on Offset info
    if (dtIsUTC) then
    begin
        Result := Result + 'Z';
    end
    else begin
        Result := Result + GetTimeZoneOffset();
    end;
end;

{---------------------------------------}
function GetTimeZoneOffset(): Utf8String;
var
    UTCoffset: integer;
    UTCoffsetHours, UTCoffsetMinutes: integer;
    TZI: TTimeZoneInformation;
begin
    Result := '';

    // Compute Timezone offset from GMT
    case GetTimeZoneInformation(TZI) of
        TIME_ZONE_ID_STANDARD: UTCOffset := (TZI.Bias + TZI.StandardBias);
        TIME_ZONE_ID_DAYLIGHT: UTCOffset := (TZI.Bias + TZI.DaylightBias);
        TIME_ZONE_ID_UNKNOWN: UTCOffset := TZI.Bias;
    else
        UTCOffset := 0;
    end;
    UTCoffsetHours := UTCoffset div 60; //TZI.Bias in minutes
    UTCoffsetMinutes := UTCoffset mod 60; //TZI.Bias in minutes

    if (UTCoffsetHours <= 0) then
    begin
        Result := Result + '+'
    end
    else begin
        Result := Result + '-';
    end;
    Result := Result + Format('%.2d:%.2d',[abs(UTCoffsetHours), abs(UTCOffsetMinutes)]);
end;

{---------------------------------------}
function UTCNow(): TDateTime;
begin
    Result := Now + TimeZoneBias();
end;

{---------------------------------------}
function generateEventMsg(tag: TXMLTag; event: Utf8String): TXMLTag;
var
    m, e: TXMLTag;
begin
    m := TXMLTag.Create('message');
    m.setAttribute('to', tag.getAttribute('from'));
    m.setAttribute('from', tag.getAttribute('to'));
    e := m.AddTag('x');
    e.setAttribute('xmlns', 'jabber:x:event');
    e.AddBasicTag('id', tag.getAttribute('id'));
    e.AddTag(event);
    Result := m;
end;

{---------------------------------------}
procedure parseNameValues(list: TStringlist; str: Utf8String);
var
    i: integer;
    q: boolean;
    n,v: Utf8String;
    ns, vs: integer;
begin
    // Parse a list of:
    // foo="bar",thud="baz"
    // 12345678901234567890

    // foo=bar,
    // 12345678

    // ns = 1
    // vs = 5
    // i = 9
    ns := 1;
    vs := 1;
    q := false;
    for i := 0 to Length(str) - 1 do begin
        if (not q) then begin
            if (str[i] = ',') then begin
                // end of name-value pair
                if (v = '') then
                    v := Copy(str, vs, i - vs);
                list.Add(n);
                list.Values[n] := v;
                ns := i + 1;
                n := '';
                v := '';
            end
            else if (str[i] = '"') then begin
                // if we are quoting... start here
                q := true;
                vs := i + 1;
            end
            else if (str[i] = '=') then begin
                // end of name, start of value
                n := Copy(str, ns, i - ns);
                vs := i + 1;
            end;
        end
        else if (str[i] = '"') then begin
            v := Copy(str, vs, i - vs);
            q := false;
        end;
    end;
end;

{---------------------------------------}
function StringToXMLTag(input: Utf8String): TXMLTag;
var
    parser: TXMLTagParser;
begin
    Result := nil;
    if (input = '') then exit;

    parser := nil;
    try
        try
            // Input MUST be valid XML
            parser := TXMLTagParser.Create;
            parser.ParseString(input, '');
            Result := parser.popTag();
        except

        end;
    finally
        parser.Free();
    end;
end;

{---------------------------------------}
{$ifdef Win32}
function GetAppVersion: string;
const
    InfoNum = 10;
    InfoStr : array [1..InfoNum] of String =
        ('CompanyName', 'FileDescription', 'FileVersion', 'InternalName',
        'LegalCopyright', 'LegalTradeMarks', 'OriginalFilename',
        'ProductName', 'ProductVersion', 'Comments');
var
    S: string;
    n: dword;
    Len: UINT;
    i: Integer;
    Buf: PChar;
    Value: PChar;
    keyList: TStringList;
    valList: TStringList;
begin

    Result := '';

    KeyList := TStringlist.create;
    ValList := TStringlist.create;

    S := Application.ExeName;
    n := GetFileVersionInfoSize(PChar(S),n);
    if n > 0 then begin
        Buf := AllocMem(n);
        GetFileVersionInfo(PChar(S),0,n,Buf);
        if VerQueryValue(Buf,PChar('StringFileInfo\040904B0\'+ InfoStr[3]),Pointer(Value),Len) then
            Result := Value;
        for i:=1 to InfoNum do begin
            if VerQueryValue(Buf,PChar('StringFileInfo\040904B0\'+ InfoStr[i]),Pointer(Value),Len) then begin
                KeyList.Add(InfoStr[i]);
                ValList.Add(Value);
            end;
        end;
        FreeMem(Buf,n);
    end
    else
        Result := '';

    keylist.Free;
    vallist.Free;
end;

{$else}
function GetAppVersion: string;
begin
    result := '1.0';
end;
{$endif}

function ErrorText(tag: TXMLTag): Utf8String;
var
    child: TXMLTag;
    ns: Utf8String;
begin
    Result := '';
    child := tag.GetFirstTag('text');
    if (child <> nil) then begin
        ns := child.Namespace();

        if (ns = 'urn:ietf:params:xml:ns:xmpp-streams') then
            Result := child.Data
        else if (ns = 'urn:ietf:params:xml:ns:xmpp-streams') then
            Result := child.Data;
    end;

    if Result = '' then
        Result := tag.Data;
end;

//returns a reference to a delay tag found in tag, or nil if none exists
function GetDelayTag(tag: TXMLTag): TXMLTag;
begin
    Result := tag.QueryXPTag(XP_MSGDELAY_203);
    if (Result = nil) then
        Result := tag.QueryXPTag(XP_MSGDELAY);
end;


end.
