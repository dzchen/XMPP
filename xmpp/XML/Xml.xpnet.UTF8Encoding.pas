unit Xml.xpnet.UTF8Encoding;

interface
uses
  Xml.xpnet.Encoding,SysUtils,Xml.xpnet.Position,Xml.xpnet.Exception;
type
  TUTF8Encoding=class(Xml.xpnet.Encoding.TEncoding)
  private
    function byteType3(buf:TBytes;off:Integer):integer;
    procedure check3(buf:TBytes;off:Integer);
    procedure check4(buf:TBytes;off:Integer);
    function extendData(buf:tbytes;off,ed:Integer):integer;
  protected
    function byteType(buf:TBytes;off:Integer):integer;override;
    function byteToAscii(buf:TBytes;off:Integer):Char;override;
    function charMatches(buf:Tbytes;off:integer;c:Char):Boolean;override;
    function byteType2(buf:TBytes;off:Integer):integer;override;
    function convert(sourcebuf:tbytes;sourcestart,sourceend:Integer;targetbuf:PChar;targetstart:Integer):Integer;override;
    procedure movePosition(buf:TBytes;off,ed:Integer;pos:TPosition);override;
  public
    constructor Create();overload;
    class constructor Create();

  end;

var
  utf8typetable:array[0..255]of integer;
  utf8HiTypeTable:array[0..127] of integer =
        (
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM,///* 0x80 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM,///* 0x84 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM,///* 0x88 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM, ///* 0x8C */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM, ///* 0x90 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM,///* 0x94 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM, ///* 0x98 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM,///* 0x9C */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM, ///* 0xA0 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM,///* 0xA4 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM, ///* 0xA8 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM, ///* 0xAC */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM,  ///* 0xB0 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM, ///* 0xB4 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM, ///* 0xB8 */
            BT_MALFORM, BT_MALFORM, BT_MALFORM, BT_MALFORM, ///* 0xBC */
            BT_LEAD2, BT_LEAD2, BT_LEAD2, BT_LEAD2,  ///* 0xC0 */
            BT_LEAD2, BT_LEAD2, BT_LEAD2, BT_LEAD2,  ///* 0xC4 */
            BT_LEAD2, BT_LEAD2, BT_LEAD2, BT_LEAD2,  ///* 0xC8 */
            BT_LEAD2, BT_LEAD2, BT_LEAD2, BT_LEAD2,  ///* 0xCC */
            BT_LEAD2, BT_LEAD2, BT_LEAD2, BT_LEAD2, ///* 0xD0 */
            BT_LEAD2, BT_LEAD2, BT_LEAD2, BT_LEAD2, ///* 0xD4 */
            BT_LEAD2, BT_LEAD2, BT_LEAD2, BT_LEAD2,///* 0xD8 */
            BT_LEAD2, BT_LEAD2, BT_LEAD2, BT_LEAD2,   ///* 0xDC */
            BT_LEAD3, BT_LEAD3, BT_LEAD3, BT_LEAD3, ///* 0xE0 */
            BT_LEAD3, BT_LEAD3, BT_LEAD3, BT_LEAD3, ///* 0xE4 */
            BT_LEAD3, BT_LEAD3, BT_LEAD3, BT_LEAD3,  ///* 0xE8 */
            BT_LEAD3, BT_LEAD3, BT_LEAD3, BT_LEAD3,///* 0xEC */
            BT_LEAD4, BT_LEAD4, BT_LEAD4, BT_LEAD4, ///* 0xF0 */
            BT_LEAD4, BT_LEAD4, BT_LEAD4, BT_LEAD4,  ///* 0xF4 */
            BT_NONXML, BT_NONXML, BT_NONXML, BT_NONXML, ///* 0xF8 */
            BT_NONXML, BT_NONXML, BT_MALFORM, BT_MALFORM ///* 0xFC */
        );
implementation
{ TUTF8Encoding }

function TUTF8Encoding.byteToAscii(buf:TBytes;off:Integer):Char;
begin
  result:=chr(buf[off]);
end;

function TUTF8Encoding.byteType(buf:TBytes;off:Integer):integer;
begin
  result:=utf8typetable[buf[off]and $FF];
end;

function TUTF8Encoding.byteType2(buf: TBytes; off: Integer): integer;
var
  page:TInt256Array;
begin
  page:=chartypetable[(buf[off] shr 2) and $7];
  result:=page[((buf[off]and 3) shl 6) or (buf[off+1] and $3F)];
end;

function TUTF8Encoding.byteType3(buf: TBytes; off: Integer): integer;
var
  page:TInt256Array;
begin
  page:=chartypetable[((buf[off] and $F) shl 4) or ((buf[off+1] shr 2) and $F)];
  result:=page[((buf[off+1]and 3) shl 6) or (buf[off+2] and $3F)];

end;

function TUTF8Encoding.charMatches(buf: Tbytes; off: integer; c: Char): Boolean;
begin
  result:=(chr(buf[off])=c);
end;

procedure TUTF8Encoding.check3(buf: TBytes; off: Integer);
begin
  case buf[off] of
    $EF:
    begin  
      if ((buf[off+1]=$BF)and ((buf[off+2]=$BF) or (buf[off+2]=$BE))) then
        raise TInvalidTokenException.Create(off);
      exit;
    end;
    $ED:
    begin
      if (buf[off+1] and $20)<>0 then
        raise TInvalidTokenException.Create(off);
      exit;
    end;
    else
    exit;
  end;
end;

procedure TUTF8Encoding.check4(buf: TBytes; off: Integer);
begin
  case buf[off] and $7 of
    5,6,7:;
    4:begin
      if (buf[off+1] and $30)=0 then
        exit;
    end;
    else
    exit;
  end;
  raise TInvalidTokenException.Create(off);
end;

function TUTF8Encoding.convert(sourcebuf: tbytes; sourcestart,
  sourceend: Integer; targetbuf: PChar; targetstart: Integer): Integer;
var
  inittargetstart:Integer;
  c:Char;
  b:byte;
  b1:integer;
begin
  inittargetstart:=targetstart;
  while sourcestart<>sourceend do
  begin
    b:=sourcebuf[sourcestart];
    inc(sourcestart);
    if b>=0 then
    begin
      targetbuf[targetstart]:=chr(b);
      inc(targetstart);
    end
    else
    begin
      case utf8TypeTable[b and $FF] of
        BT_LEAD2:
        begin
          targetbuf[targetstart]:=chr(((b and $1F) shl 6) or (sourcebuf[sourcestart] and $3F));
          inc(sourcestart);
          inc(targetstart);
        end;
        BT_LEAD3:
        begin
          b1:=((b and $F) shl 12);
          b1:=b1 or ((sourcebuf[sourcestart] and $3F) shl 6);
          inc(sourcestart);
          b1:=b1 or (sourcebuf[sourcestart] and $3F);
          inc(sourcestart);
          targetbuf[targetstart]:=chr(b1);
          inc(targetstart);
        end;
        BT_LEAD4:
        begin
          b1:=(b and $7) shr 18;
          b1:=b1 or ((sourcebuf[sourcestart] and $3F) shl 12);
          inc(sourcestart);
          b1:=b1 or ((sourcebuf[sourcestart] and $3F) shl 6);
          inc(sourcestart);
          b1:=b1 or (sourcebuf[sourcestart] and $3F);
          inc(sourcestart);
          b1:=b1-$10000;
          targetbuf[targetstart]:=chr((b1 shr 10) or $D800);
          inc(targetstart);
          targetbuf[targetstart]:=chr((b1 and ((1 shl 10)-1))or $DC00);
          inc(targetstart);
        end;
      end;
    end;
  end;
  result:=targetstart-inittargetstart;
end;

class constructor TUTF8Encoding.Create;
var
  i:integer;
begin
  for i := 0 to 127 do
    utf8typetable[i]:=asciiTypeTable[i];
  for i := 0 to 127 do
    utf8typetable[i+128]:=utf8HiTypeTable[i];
end;

constructor TUTF8Encoding.Create;
begin
  inherited Create(1);
end;

function TUTF8Encoding.extendData(buf: tbytes; off, ed: Integer): integer;
var
  tp:integer;
begin
  while off<>ed do
  begin
    tp:=utf8TypeTable[buf[off] and $FF];
    if tp>=0 then
      inc(off)
    else if tp<BT_LEAD4 then
      break
    else
    begin
      if ed-off+tp<0 then
        break;
      case tp of
        BT_LEAD3:check3(buf,off);
        BT_LEAD4:check4(buf,off);
      end;
      dec(off,tp);
    end;
  end;
  result:=off;
end;

procedure TUTF8Encoding.movePosition(buf: TBytes; off, ed: Integer;
  pos: TPosition);
var
  coldiff,linenumber:integer;
  b:byte;
begin
  coldiff:=off-pos.ColumnNumber;
  linenumber:=Pos.LineNumber;
  while off<>ed do
  begin
    b:=buf[off];
    if b>=0 then
    begin
      inc(off);
      case b of
        10:
        begin
          inc(linenumber);
          coldiff:=off;
        end;
        13:
        begin
          inc(linenumber);
          if (off<>ed) and (buf[off]=10) then
            inc(off);
          coldiff:=off;
        end;
      end;
    end
    else
    begin
      case utf8TypeTable[b and $FF] of
        BT_LEAD2:
        begin
          inc(off,2);
          inc(colDiff);
        end;
        BT_LEAD3:
        begin
          inc(off,3);
          inc(colDiff,2);
        end;
        BT_LEAD4:
        begin
          inc(off,4);
          inc(colDiff,3);
        end;
        else
          inc(off);
      end;
    end;
  end;
  Pos.ColumnNumber:=off-coldiff;
  Pos.LineNumber:=linenumber;
end;

end.
