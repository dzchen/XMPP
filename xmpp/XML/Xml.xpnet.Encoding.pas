unit Xml.xpnet.Encoding;

interface
uses
  XMPPConst,SysUtils,Xml.xpnet.Position,Xml.xpnet.Token,Xml.xpnet.Exception;
  const
    BT_LEAD2=-2;//Need more bytes
    BT_LEAD3=-3;
    BT_LEAD4=-4;
    BT_NONXML=BT_LEAD4-1;//Not XML
    BT_MALFORM = BT_NONXML - 1;//Malformed XML
    BT_LT = BT_MALFORM - 1;//Less than
    BT_AMP = BT_LT - 1;//Ampersand
    BT_RSQB = BT_AMP - 1;//right square bracket
    BT_CR = BT_RSQB - 1;//carriage return
    BT_LF = BT_CR - 1;//line feed
    BT_GT = 0;//greater than
    BT_QUOT = BT_GT + 1;//Quote
    BT_APOS = BT_QUOT + 1;//Apostrophe
    BT_EQUALS = BT_APOS + 1;//Equal sign
    BT_QUEST = BT_EQUALS + 1;//Question mark
    BT_EXCL = BT_QUEST + 1;//Exclamation point
    BT_SOL = BT_EXCL + 1;//Solidus (/)
    BT_SEMI = BT_SOL + 1;//Semicolon
    BT_NUM = BT_SEMI + 1;//Hash
    BT_LSQB = BT_NUM + 1;//Left square bracket
    BT_S = BT_LSQB + 1;//space
    BT_NMSTRT = BT_S + 1;//
    BT_NAME = BT_NMSTRT + 1;//
    BT_MINUS = BT_NAME + 1;//Minus
    BT_OTHER = BT_MINUS + 1;//Other
    BT_PERCNT = BT_OTHER + 1;//Percent
    BT_LPAR = BT_PERCNT + 1;//Left paren
    BT_RPAR = BT_LPAR + 1;//Right paren
    BT_AST = BT_RPAR + 1;//
    BT_PLUS = BT_AST + 1;//+
    BT_COMMA = BT_PLUS + 1;//,
    BT_VERBAR = BT_COMMA + 1;//Pipe
type
  TInt256Array=array[0..255] of integer;
  TEncoding=class
  const
    UTF8_ENCODING:byte = 0;
    UTF16_LITTLE_ENDIAN_ENCODING:byte = 1;
    UTF16_BIG_ENDIAN_ENCODING:byte = 2;
    INTERNAL_ENCODING:byte = 3;
    ISO8859_1_ENCODING:byte = 4;
    ASCII_ENCODING:byte = 5;

    CDATA:string='CDATA[';
    nameStartSingles:string =
  #$003a#$005f#$0386#$038c#$03da#$03dc#$03de#$03e0#$0559#$06d5#$093d#$09b2 +
  #$0a5e#$0a8d#$0abd#$0ae0#$0b3d#$0b9c#$0cde#$0e30#$0e84#$0e8a#$0e8d#$0ea5 +
  #$0ea7#$0eb0#$0ebd#$1100#$1109#$113c#$113e#$1140#$114c#$114e#$1150#$1159 +
  #$1163#$1165#$1167#$1169#$1175#$119e#$11a8#$11ab#$11ba#$11eb#$11f0#$11f9 +
  #$1f59#$1f5b#$1f5d#$1fbe#$2126#$212e#$3007;
    nameStartRanges:string =
  #$0041#$005a#$0061#$007a#$00c0#$00d6#$00d8#$00f6#$00f8#$00ff#$0100#$0131 +
  #$0134#$013e#$0141#$0148#$014a#$017e#$0180#$01c3#$01cd#$01f0#$01f4#$01f5 +
  #$01fa#$0217#$0250#$02a8#$02bb#$02c1#$0388#$038a#$038e#$03a1#$03a3#$03ce +
  #$03d0#$03d6#$03e2#$03f3#$0401#$040c#$040e#$044f#$0451#$045c#$045e#$0481 +
  #$0490#$04c4#$04c7#$04c8#$04cb#$04cc#$04d0#$04eb#$04ee#$04f5#$04f8#$04f9 +
  #$0531#$0556#$0561#$0586#$05d0#$05ea#$05f0#$05f2#$0621#$063a#$0641#$064a +
  #$0671#$06b7#$06ba#$06be#$06c0#$06ce#$06d0#$06d3#$06e5#$06e6#$0905#$0939 +
  #$0958#$0961#$0985#$098c#$098f#$0990#$0993#$09a8#$09aa#$09b0#$09b6#$09b9 +
  #$09dc#$09dd#$09df#$09e1#$09f0#$09f1#$0a05#$0a0a#$0a0f#$0a10#$0a13#$0a28 +
  #$0a2a#$0a30#$0a32#$0a33#$0a35#$0a36#$0a38#$0a39#$0a59#$0a5c#$0a72#$0a74 +
  #$0a85#$0a8b#$0a8f#$0a91#$0a93#$0aa8#$0aaa#$0ab0#$0ab2#$0ab3#$0ab5#$0ab9 +
  #$0b05#$0b0c#$0b0f#$0b10#$0b13#$0b28#$0b2a#$0b30#$0b32#$0b33#$0b36#$0b39 +
  #$0b5c#$0b5d#$0b5f#$0b61#$0b85#$0b8a#$0b8e#$0b90#$0b92#$0b95#$0b99#$0b9a +
  #$0b9e#$0b9f#$0ba3#$0ba4#$0ba8#$0baa#$0bae#$0bb5#$0bb7#$0bb9#$0c05#$0c0c +
  #$0c0e#$0c10#$0c12#$0c28#$0c2a#$0c33#$0c35#$0c39#$0c60#$0c61#$0c85#$0c8c +
  #$0c8e#$0c90#$0c92#$0ca8#$0caa#$0cb3#$0cb5#$0cb9#$0ce0#$0ce1#$0d05#$0d0c +
  #$0d0e#$0d10#$0d12#$0d28#$0d2a#$0d39#$0d60#$0d61#$0e01#$0e2e#$0e32#$0e33 +
  #$0e40#$0e45#$0e81#$0e82#$0e87#$0e88#$0e94#$0e97#$0e99#$0e9f#$0ea1#$0ea3 +
  #$0eaa#$0eab#$0ead#$0eae#$0eb2#$0eb3#$0ec0#$0ec4#$0f40#$0f47#$0f49#$0f69 +
  #$10a0#$10c5#$10d0#$10f6#$1102#$1103#$1105#$1107#$110b#$110c#$110e#$1112 +
  #$1154#$1155#$115f#$1161#$116d#$116e#$1172#$1173#$11ae#$11af#$11b7#$11b8 +
  #$11bc#$11c2#$1e00#$1e9b#$1ea0#$1ef9#$1f00#$1f15#$1f18#$1f1d#$1f20#$1f45 +
  #$1f48#$1f4d#$1f50#$1f57#$1f5f#$1f7d#$1f80#$1fb4#$1fb6#$1fbc#$1fc2#$1fc4 +
  #$1fc6#$1fcc#$1fd0#$1fd3#$1fd6#$1fdb#$1fe0#$1fec#$1ff2#$1ff4#$1ff6#$1ffc +
  #$212a#$212b#$2180#$2182#$3041#$3094#$30a1#$30fa#$3105#$312c#$ac00#$d7a3 +
  #$4e00#$9fa5#$3021#$3029;
    nameSingles:string =
  #$002d#$002e#$05bf#$05c4#$0670#$093c#$094d#$09bc#$09be#$09bf#$09d7#$0a02 +
  #$0a3c#$0a3e#$0a3f#$0abc#$0b3c#$0bd7#$0d57#$0e31#$0eb1#$0f35#$0f37#$0f39 +
  #$0f3e#$0f3f#$0f97#$0fb9#$20e1#$3099#$309a#$00b7#$02d0#$02d1#$0387#$0640 +
  #$0e46#$0ec6#$3005;
    nameRanges:string =
  #$0300#$0345#$0360#$0361#$0483#$0486#$0591#$05a1#$05a3#$05b9#$05bb#$05bd +
  #$05c1#$05c2#$064b#$0652#$06d6#$06dc#$06dd#$06df#$06e0#$06e4#$06e7#$06e8 +
  #$06ea#$06ed#$0901#$0903#$093e#$094c#$0951#$0954#$0962#$0963#$0981#$0983 +
  #$09c0#$09c4#$09c7#$09c8#$09cb#$09cd#$09e2#$09e3#$0a40#$0a42#$0a47#$0a48 +
  #$0a4b#$0a4d#$0a70#$0a71#$0a81#$0a83#$0abe#$0ac5#$0ac7#$0ac9#$0acb#$0acd +
  #$0b01#$0b03#$0b3e#$0b43#$0b47#$0b48#$0b4b#$0b4d#$0b56#$0b57#$0b82#$0b83 +
  #$0bbe#$0bc2#$0bc6#$0bc8#$0bca#$0bcd#$0c01#$0c03#$0c3e#$0c44#$0c46#$0c48 +
  #$0c4a#$0c4d#$0c55#$0c56#$0c82#$0c83#$0cbe#$0cc4#$0cc6#$0cc8#$0cca#$0ccd +
  #$0cd5#$0cd6#$0d02#$0d03#$0d3e#$0d43#$0d46#$0d48#$0d4a#$0d4d#$0e34#$0e3a +
  #$0e47#$0e4e#$0eb4#$0eb9#$0ebb#$0ebc#$0ec8#$0ecd#$0f18#$0f19#$0f71#$0f84 +
  #$0f86#$0f8b#$0f90#$0f95#$0f99#$0fad#$0fb1#$0fb7#$20d0#$20dc#$302a#$302f +
  #$0030#$0039#$0660#$0669#$06f0#$06f9#$0966#$096f#$09e6#$09ef#$0a66#$0a6f +
  #$0ae6#$0aef#$0b66#$0b6f#$0be7#$0bef#$0c66#$0c6f#$0ce6#$0cef#$0d66#$0d6f +
  #$0e50#$0e59#$0ed0#$0ed9#$0f20#$0f29#$3031#$3035#$309d#$309e#$30fc#$30fe;
    
  private
    _minBPC:integer;
    class constructor Create;
    class function getEncoding(enc:Byte):Xml.xpnet.Encoding.TEncoding;overload;
    function byteType3(buf:TBytes;off:Integer):Integer;
    function byteType4(buf:TBytes;off:Integer):Integer;
    procedure check2(buf:TBytes;off:Integer);
    procedure check3(buf:TBytes;off:Integer);
    procedure check4(buf:TBytes;off:Integer);
    procedure checkCharMatches(buf:TBytes;off:integer;c:Char);
    function scanComment(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function scanDecl(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function targetIsXml(buf:TBytes;off,ed:Integer):Boolean;
    function scanPi(buf:TBytes;off,ed:integer;tk:TToken):TOK;
    function scanCdataSection(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function extendCdata(buf:TBytes;off,ed:Integer):Integer;
    function scanEndTag(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function scanHexCharRef(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function scanCharRef(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function setRefChar(num:integer;tk:TToken):Tok;
    function isMagicEntityRef(buf:TBytes;off,ed:integer;tk:TToken):Boolean;
    function scanRef(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function scanAtts(namestart:Integer;buf:TBytes;off,ed:integer;tk:TContentToken):Tok;
    function scanLt(buf:TBytes;off,ed:integer;tk:TContentToken):Tok;
    function adjustEnd(off,ed:Integer):integer;
    function extendData(buf:tbytes;off,ed:Integer):integer;
    function scanPercent(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function scanPoundName(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function scanLit(open:integer;buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function isNameChar2(buf:TBytes;off:Integer):Boolean;
    function isNameChar3(buf:TBytes;off:Integer):Boolean;
    function isNameChar4(buf:TBytes;off:Integer):Boolean;
    function offPlusminBPC(off,bpc:integer):integer;
  protected

    function convert(sourcebuf:tbytes;sourcestart,sourceend:Integer;targetbuf:PChar;targetstart:Integer):Integer;virtual;abstract;
    function byteType(buf:TBytes;off:Integer):integer;virtual;abstract;
    function byteToAscii(buf:TBytes;off:Integer):Char;virtual;abstract;
    function charMatches(buf:TBytes;off:integer;c:Char):Boolean;virtual;abstract;
    function byteType2(buf:TBytes;off:Integer):Integer;virtual;
    procedure movePosition(buf:TBytes;off,ed:Integer;pos:TPosition);virtual;abstract;
    class procedure setCharType(c:Char;tp:Integer);overload;
    class procedure setCharType(min,max:Char;tp:Integer);overload;
  public
    property MinbytesPerChar:Integer read _minBPC;
    constructor Create(minbpc:Integer);
    function tokenizeCdataSection(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function tokenizeContent(buf:TBytes;off,ed:integer;tk:TContentToken):Tok;
    class function getInitialEncoding(buf:TBytes;off,ed:integer;tk:TToken):xml.xpnet.Encoding.TEncoding;
    function getEncoding(name:string):xml.xpnet.Encoding.TEncoding;overload;
    function getSingleByteEncoding(map:string):xml.xpnet.Encoding.TEncoding;
    class function getInternalEncoding():xml.xpnet.Encoding.TEncoding;
    function tokenizeProlog(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function tokenizeAttributeValue(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function tokenizeEntityValue(buf:TBytes;off,ed:integer;tk:TToken):Tok;
    function skipIgnoreSect(buf:TBytes;off,ed:Integer):integer;
    function getPublicId(buf:TBytes;off,ed:Integer):string;
    function matchesXMLstring(buf:TBytes;off,ed:Integer;str:string):Boolean;
    function skipS(buf:TBytes;off,ed:Integer):integer;
  end;
var
  charTypeTable:array[0..255] of TInt256Array;
  asciiTypeTable:array[0..127] of integer=
  (BT_NONXML, BT_NONXML, BT_NONXML, BT_NONXML,///* 0x00 */
             BT_NONXML, BT_NONXML, BT_NONXML, BT_NONXML,///* 0x04 */
             BT_NONXML, BT_S, BT_LF, BT_NONXML,///* 0x08 */
             BT_NONXML, BT_CR, BT_NONXML, BT_NONXML,///* 0x0C */
             BT_NONXML, BT_NONXML, BT_NONXML, BT_NONXML,///* 0x10 */
             BT_NONXML, BT_NONXML, BT_NONXML, BT_NONXML,///* 0x14 */
             BT_NONXML, BT_NONXML, BT_NONXML, BT_NONXML,///* 0x18 */
             BT_NONXML, BT_NONXML, BT_NONXML, BT_NONXML, ///* 0x1C */
             BT_S, BT_EXCL, BT_QUOT, BT_NUM, ///* 0x20 */
             BT_OTHER, BT_PERCNT, BT_AMP, BT_APOS, ///* 0x24 */
             BT_LPAR, BT_RPAR, BT_AST, BT_PLUS,  ///* 0x28 */
             BT_COMMA, BT_MINUS, BT_NAME, BT_SOL,///* 0x2C */
             BT_NAME, BT_NAME, BT_NAME, BT_NAME, ///* 0x30 */
             BT_NAME, BT_NAME, BT_NAME, BT_NAME,///* 0x34 */
             BT_NAME, BT_NAME, BT_NMSTRT, BT_SEMI, ///* 0x38 */
             BT_LT, BT_EQUALS, BT_GT, BT_QUEST, ///* 0x3C */
             BT_OTHER, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT,///* 0x40 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT,///* 0x44 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT,///* 0x48 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, ///* 0x4C */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT,   ///* 0x50 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, ///* 0x54 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_LSQB, ///* 0x58 */
             BT_OTHER, BT_RSQB, BT_OTHER, BT_NMSTRT,   ///* 0x5C */
             BT_OTHER, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, ///* 0x60 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, ///* 0x64 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT,  ///* 0x68 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT,   ///* 0x6C */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, ///* 0x70 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, ///* 0x74 */
             BT_NMSTRT, BT_NMSTRT, BT_NMSTRT, BT_OTHER,  ///* 0x78 */
            BT_VERBAR, BT_OTHER, BT_OTHER, BT_OTHER);  ///* 0x7C */
implementation
uses
  Xml.xpnet.UTF8Encoding;
var

  utf8Encoding:TEncoding;
{ TEncoding }

function TEncoding.adjustEnd(off, ed: Integer): integer;
var
  n:integer;
begin
  n:=ed-off;
  if (n and (_minbpc-1))<>0 then
  begin
    n:=n and (not(_minBPC-1));
    if n=0 then
      raise TPartialCharException.Create(off);
    Result:=off+n;
    exit;
  end
  else
    Result:=ed;

end;

function TEncoding.byteType2(buf: TBytes; off: Integer): Integer;
begin
  Result:=BT_OTHER;
end;

function TEncoding.byteType3(buf: TBytes; off: Integer): Integer;
begin
  Result:=BT_OTHER;
end;

function TEncoding.byteType4(buf: TBytes; off: Integer): Integer;
begin
  Result:=BT_OTHER;
end;

procedure TEncoding.check2(buf: TBytes; off: Integer);
begin

end;

procedure TEncoding.check3(buf: TBytes; off: Integer);
begin

end;

procedure TEncoding.check4(buf: TBytes; off: Integer);
begin

end;

procedure TEncoding.checkCharMatches(buf: TBytes; off: integer; c: Char);
begin
  if not charMatches(buf,off,c) then
    raise TInvalidTokenException.Create(off);
end;

constructor TEncoding.Create(minbpc:Integer);
begin
  _minBPC:=minbpc;
end;

class constructor TEncoding.Create;
var
  i:integer;
  other:TInt256Array;
begin

  for i := 1 to Length(nameSingles) do
    setchartype(nameSingles[i],bt_name);
  i:=1;
  while i<=Length(nameRanges) do
  begin
    setchartype(nameRanges[i],nameRanges[i+1],bt_name);
    Inc(i,2);
  end;
  for i := 1 to Length(nameStartSingles) do
    setchartype(nameStartSingles[i],BT_NMSTRT);
  i:=1;
  while i<=Length(nameStartRanges) do
  begin
    setchartype(nameStartRanges[i],nameStartRanges[i+1],BT_NMSTRT);
    Inc(i,2);
  end;
  setchartype(#$D800, #$DBFF, BT_LEAD4);
  setCharType(#$DC00, #$DFFF, BT_MALFORM);
  setCharType(#$FFFE, #$FFFF, BT_NONXML);
  for i := 0 to 255 do
    other[i]:=bt_other;
  for i := 0 to 255 do
      charTypeTable[i]:=other;
  for i := 0 to 127 do
    charTypeTable[0][i]:=asciiTypeTable[i];
end;

function TEncoding.extendCdata(buf: TBytes; off, ed: Integer): Integer;
begin
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_lead2:
      begin
        if ed-off<2 then
        begin
          Result:=off;
          exit;
        end;
        check2(buf,off);
        Inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
        begin
          Result:=off;
          exit;
        end;
        check3(buf,off);
        Inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
        begin
          Result:=off;
          exit;
        end;
        check4(buf,off);
        Inc(off,4);
      end;
      BT_RSQB,BT_NONXML,BT_MALFORM,BT_CR,BT_LF:
      begin
        Result:=off;
        exit;
      end;
      else
      Inc(off,_minbpc);
      exit;
    end;
  end;
  Result:=off;
end;

function TEncoding.extendData(buf: tbytes; off, ed: Integer): integer;
begin
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_lead2:
      begin
        if ed-off<2 then
        begin
          Result:=off;
          exit;
        end;
        check2(buf,off);
        Inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
        begin
          Result:=off;
          exit;
        end;
        check3(buf,off);
        Inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
        begin
          Result:=off;
          exit;
        end;
        check4(buf,off);
        Inc(off,4);
      end;
      BT_RSQB,BT_AMP,BT_LT,BT_NONXML,BT_MALFORM,BT_CR,BT_LF:
      begin
        Result:=off;
        exit;
      end;
      else
      Inc(off,_minbpc);
    end;
  end;
  Result:=off;
end;

class function TEncoding.getEncoding(enc: Byte): Xml.xpnet.Encoding.TEncoding;
begin
  case enc of
    0://UTF8_ENCODING:
            begin
                if (utf8Encoding = nil)then
                    utf8Encoding := TUTF8Encoding.Create;
                Result:= utf8Encoding;
                exit;
            end;
             {
            case UTF16_LITTLE_ENDIAN_ENCODING:
                if (utf16LittleEndianEncoding == null)
                    utf16LittleEndianEncoding = new UTF16LittleEndianEncoding();
                return utf16LittleEndianEncoding;
            case UTF16_BIG_ENDIAN_ENCODING:
                if (utf16BigEndianEncoding == null)
                    utf16BigEndianEncoding = new UTF16BigEndianEncoding();
                return utf16BigEndianEncoding;
            case INTERNAL_ENCODING:
                if (internalEncoding == null)
                    internalEncoding = new InternalEncoding();
                return internalEncoding;
            case ISO8859_1_ENCODING:
                if (iso8859_1Encoding == null)
                    iso8859_1Encoding = new ISO8859_1Encoding();
                return iso8859_1Encoding;
            case ASCII_ENCODING:
                if (asciiEncoding == null)
                    asciiEncoding = new ASCIIEncoding();
                return asciiEncoding;
            }
  end;
  Result:=nil;
end;

function TEncoding.getEncoding(name: string): xml.xpnet.Encoding.TEncoding;
begin
  if name='' then
  begin
    Result:=Self;
    Exit;
  end;
  if UpperCase(name)='UTF-8' then
  begin
    Result:=getEncoding(UTF8_ENCODING);
    exit;
  end;
  Result:=nil;
end;

class function TEncoding.getInitialEncoding(buf: TBytes; off, ed: integer;
  tk: TToken): xml.xpnet.Encoding.TEncoding;
var
  b0,b1:integer;
  label xy,xy8;
begin
  tk.TokenEnd:=off;
  case ed-off of
    0:;
    1:
    begin
    if buf[off]>127 then
    begin
      Result:=nil ;
      Exit;
    end;
    end;
    else
    begin
      b0:=buf[off] and $FF;
      b1:=buf[off+1] and $FF;
      case (b0 shl 8) or b1 of
        $FEFF:
        begin
          tk.TokenEnd:=off+2;
          goto xy;
        end;
        Ord('<'):
        begin
          xy:
          begin
          Result:=getEncoding(UTF16_BIG_ENDIAN_ENCODING);
          Exit;
          end;
        end;
        $FFFE:
        begin
          tk.TokenEnd:=off+2;
          goto xy8;
        end;
        ord('<')shr 8:
        begin
          xy8:
          begin
          getEncoding(UTF16_LITTLE_ENDIAN_ENCODING);
          exit;
          end;
        end;
      end;
    end;
  end;
  Result:=getEncoding(UTF8_ENCODING);
end;

class function TEncoding.getInternalEncoding: xml.xpnet.Encoding.TEncoding;
begin
  Result:=getEncoding(INTERNAL_ENCODING);
end;

function TEncoding.getPublicId(buf: TBytes; off, ed: Integer): string;
var
  sbuf:TStringBuilder;
  c:char;
  label btcr,def;
begin
  sbuf:=TStringBuilder.Create;
  Inc(off,_minbpc);
  Dec(ed,_minbpc);
  while off<>ed do
  begin
    c:=byteToAscii(buf,off);
    case byteType(buf,off) of
      BT_MINUS,BT_APOS,BT_LPAR,BT_RPAR,BT_PLUS,BT_COMMA,BT_SOL,BT_EQUALS,BT_QUEST,BT_SEMI,BT_EXCL,BT_AST,BT_PERCNT,BT_NUM:
      sbuf.Append(c);
      bt_s:
      begin
        if charMatches(buf,off,#9) then
          raise TInvalidTokenException.Create(off);
        goto btcr;
      end;
      BT_CR,bt_lf:
      begin
        btcr:
        begin
          if (sbuf.Length>0) and (sbuf[sbuf.Length-1]<>' ') then
            sbuf.Append(' ');

        end;
      end;
      BT_NAME,BT_NMSTRT:
      begin
        if (Ord(c) and (not $7F))=0 then
          sbuf.Append(c)
        else
          goto def;
      end;
      else
      begin
        def:
        begin
          case c of
            '$','@':;
            else
              raise TInvalidTokenException.Create(off);
          end;
        end;
      end;
    end;
    Inc(off,_minbpc);
  end;
  if (sbuf.Length>0) and (sbuf[sbuf.Length-1]='') then
    sbuf.Remove(sbuf.Length-1,1);
  Result:=sbuf.ToString;
  sbuf.Free;
  sbuf:=nil;
end;

function TEncoding.getSingleByteEncoding(map: string): xml.xpnet.Encoding.TEncoding;
begin
  raise Exception.Create('NotImplementedException');
end;

function TEncoding.isMagicEntityRef(buf: TBytes; off, ed: integer;
  tk: TToken): Boolean;
begin
  case byteToAscii(buf,off) of
    'a':
    begin
      if ed-off>=_minbpc*4 then
      begin
        case byteToAscii(buf,off+_minbpc) of
          'm':
          begin
            if (charMatches(buf,off+_minbpc*2,'p')) and charMatches(buf,off+_minbpc*3,';') then
            begin
              tk.TokenEnd:=off+_minbpc*4;
              tk.RefChar1:='&';
              Result:=True;
              exit;
            end;
          end;
          'p':
          begin
            if (ed-off>=_minbpc*5) and charMatches(buf,off+_minbpc*2,'o') and charMatches(buf,off+_minbpc*3,'s') and charMatches(buf,off+_minbpc*4,';') then
            begin
              tk.TokenEnd:=off+_minbpc*5;
              tk.RefChar1:='''';
              Result:=True;
              Exit;
            end;
          end;
        end;
      end;
    end;
    'l':
    begin
      if (ed-off>=_minbpc*3) and charMatches(buf,off+_minbpc,'t') and charMatches(buf,off+_minbpc*2,';') then
      begin
        tk.TokenEnd:=off+_minbpc*3;
        tk.RefChar1:='<';
        Result:=True;
        exit;
      end;
    end;
    'g':
    begin
      if (ed-off>=_minbpc*3) and charMatches(buf,off+_minbpc,'t') and charMatches(buf,off+_minbpc*2,';') then
      begin
        tk.TokenEnd:=off+_minbpc*3;
        tk.RefChar1:='>';
        Result:=True;
        exit;
      end;
    end;
    'q':
    begin
      if (ed-off>=_minbpc*5) and charMatches(buf,off+_minbpc,'u') and charMatches(buf,off+_minbpc*2,'o') and charMatches(buf,off+_minbpc*3,'t') and charMatches(buf,off+_minbpc*4,';') then
      begin
              tk.TokenEnd:=off+_minbpc*5;
              tk.RefChar1:='"';
              Result:=True;
              Exit;
      end;
    end;
  end;
  Result:=False;
end;

function TEncoding.isNameChar2(buf: TBytes; off: Integer): Boolean;
var
  bt:integer;
begin
  bt:=byteType2(buf,off);
  Result:=((bt=BT_NAME)or(bt=BT_NMSTRT));
end;

function TEncoding.isNameChar3(buf: TBytes; off: Integer): Boolean;
var
  bt:integer;
begin
  bt:=byteType3(buf,off);
  Result:=((bt=BT_NAME)or(bt=BT_NMSTRT));
end;

function TEncoding.isNameChar4(buf: TBytes; off: Integer): Boolean;
var
  bt:integer;
begin
  bt:=byteType4(buf,off);
  Result:=((bt=BT_NAME)or(bt=BT_NMSTRT));
end;

function TEncoding.matchesXMLstring(buf: TBytes; off, ed: Integer;
  str: string): Boolean;
var
  len,i:integer;
begin
  len:=length(str);
  if len*_minbpc<>ed-off then
  begin
    Result:=False;
    exit;
  end;
  for i := 1 to len do
  begin
    if not charMatches(buf,off,str[i]) then
    begin
      Result:=False;
      exit;
    end;
    Inc(off,_minbpc);
  end;
  Result:=True;
end;

function TEncoding.offPlusminBPC(off, bpc: integer): integer;
begin
  Result:=off+bpc;
end;

function TEncoding.scanAtts(namestart: Integer; buf: TBytes; off, ed: integer;
  tk: TContentToken): Tok;
var
  nameend,open,valuestart,t,savenameend:integer;
  normalized:boolean;
  label loop,def,skiptoname;
begin
  nameend:=-1;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_NMSTRT,BT_NAME,BT_MINUS:Inc(off,_minbpc);
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        if not isNameChar2(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        if not isNameChar3(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        if not isNameChar4(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,4);
      end;
      BT_S,BT_CR,BT_LF:
      begin
        nameend:=off;
        while True do
        begin
          inc(off,_minbpc);
          if off=ed then
            raise TPartialTokenException.Create();
          case byteType(buf,off) of
            BT_EQUALS:goto loop;
            BT_S,BT_LF,BT_CR:;
            else
              raise TInvalidTokenException.Create(off);
          end;
        end;
      end;
      BT_EQUALS:
      begin
        loop:
        begin
          if nameend<0 then
            nameend:=off;

          while True do
          begin
            Inc(off,_minbpc);
            if off=ed then
              raise TPartialTokenException.Create();
            open:=byteType(buf,off);
            if (open=BT_QUOT)or(open=BT_APOS) then
            begin
              Break;
            end
            else
            begin
              case open of
                BT_S,BT_LF,BT_CR:;
                else
                  raise TInvalidTokenException.Create(off);
              end;
            end;
          end;
          inc(off,_minbpc);
          valuestart:=off;
          normalized:=true;
          t:=0;
          while True do
          begin
            if off=ed then
              raise TPartialTokenException.Create();
            t:=byteType(buf,off);
            if t=open then
              break;
            case t of
              BT_NONXML,BT_MALFORM:
                raise TPartialTokenException.Create();
              BT_LEAD2:
              begin
                if ed-off<2 then
                  raise TPartialCharException.Create(off);
                check2(buf,off);
                inc(off,2);
              end;
              BT_LEAD3:
              begin
                if ed-off<3 then
                  raise TPartialCharException.Create(off);
                check3(buf,off);
                inc(off,3);
              end;
              BT_LEAD4:
              begin
                if ed-off<4 then
                  raise TPartialCharException.Create(off);
                check4(buf,off);
                inc(off,4);
              end;
              BT_AMP:
              begin
                normalized:=False;
                savenameend:=tk.NameEnd;
                scanRef(buf,off+_minbpc,ed,tk);
                tk.NameEnd:=savenameend;
                off:=tk.TokenEnd;
              end;
              BT_S:
              begin
                if normalized and ((off=valuestart)or (byteToAscii(buf, off)<>' ')
                                        or ((off + _minBPC <>ed)
                                            and ((byteToAscii(buf, off + _minBPC) = ' ')
                                                or (byteType(buf, off + _minBPC) = open)))) then
                begin
                  normalized:=false;
                end;
                inc(off,_minbpc);
              end;
              BT_LT:
                raise TInvalidTokenException.Create(off);
              BT_LF,BT_CR:
              begin
                normalized:=false;
                goto def;
              end;
              else
              begin
                def:
                inc(off,_minbpc);
              end;
            end;
          end;
            tk.AppendAttribute(namestart,nameend,valuestart,off,normalized);
            inc(off,_minbpc);
            if off=ed then
              raise TPartialTokenException.Create();
            t:=byteType(buf,off);
            case t of
              BT_S,BT_CR,BT_LF:
              begin
                inc(off,_minbpc);
                if off=ed then
                  raise TPartialTokenException.Create();
                t:=byteType(buf,off);
              end;
              BT_GT,BT_SOL:;
              else
                raise TInvalidTokenException.Create(off);
            end;
            while True do
            begin
              case t of
              BT_NMSTRT:
              begin
                namestart:=off;
                inc(off,_minbpc);
                goto skiptoname;
              end;
              BT_LEAD2:
              begin
                if ed-off<2 then
                  raise TPartialCharException.Create(off);
                if byteType2(buf,off)<>BT_NMSTRT then
                  raise TInvalidTokenException.Create(off);
                namestart:=off;
                inc(off,2);
                goto skiptoname;
              end;
              BT_LEAD3:
              begin
                if ed-off<3 then
                  raise TPartialCharException.Create(off);
                if byteType3(buf,off)<>BT_NMSTRT then
                  raise TInvalidTokenException.Create(off);
                namestart:=off;
                inc(off,3);
                goto skiptoname;
              end;
              BT_LEAD4:
              begin
                if ed-off<4 then
                  raise TPartialCharException.Create(off);
                if byteType4(buf,off)<>BT_NMSTRT then
                  raise TInvalidTokenException.Create(off);
                namestart:=off;
                inc(off,4);
                goto skiptoname;
              end;
              BT_S,BT_CR,BT_LF:;
              BT_GT:
              begin
                tk.CheckAttributeUniqueness(buf);
                tk.TokenEnd:=off+_minbpc;
                Result:=tok.START_TAG_WITH_ATTS;
                exit;
              end;
              BT_SOL:
              begin
                inc(off,_minbpc);
                if off=ed then
                  raise TPartialTokenException.Create();
                checkCharMatches(buf,off,'>');
                tk.CheckAttributeUniqueness(buf);
                tk.TokenEnd:=off+_minbpc;
                Result:=Tok.EMPTY_ELEMENT_WITH_ATTS;
                exit;
              end;
              else
                raise TInvalidTokenException.Create(off);
              end;
              inc(off,_minbpc);
              if off=ed then
                raise TPartialTokenException.Create();
              t:=byteType(buf,off);
            end;
            skiptoname:
            begin
              nameend:=-1;
            end;

        end;

      end;
      else
        raise TInvalidTokenException.Create(off);
    end;
  end;
  raise TPartialTokenException.Create();
end;

function TEncoding.scanCdataSection(buf: TBytes; off, ed: integer;
  tk: TToken): Tok;
var
  i:integer;
begin
  if ed-off<6*_minbpc then
    raise TPartialTokenException.Create();
  for i := 1 to Length(CDATA) do
  begin
    checkCharMatches(buf,off,cdata[i]);
    inc(off,_minbpc);
  end;
  tk.TokenEnd:=off;
  Result:=TOK.CDATA_SECT_OPEN;
end;

function TEncoding.scanCharRef(buf: TBytes; off, ed: integer; tk: TToken): Tok;
var
  num:integer;
  c:char;
  label def;
begin
  if off<>ed then
  begin
    c:=bytetoascii(buf,off);
    case c of
      'x':
      begin
        Result:=scanHexCharRef(buf,off+_minbpc,ed,tk);
        Exit;
      end;
      '0','1','2','3','4','5','6','7','8','9':;
      else
        raise TInvalidTokenException.Create(off);
    end;
    num:=Ord(c)-ord('0');
    inc(off,_minbpc);
    while off<>ed do
    begin
      c:=bytetoascii(buf,off);
      case c of
        '0','1','2','3','4','5','6','7','8','9':
        begin
          num:=num*10+(Ord(c)-ord('0'));
          if num>=$110000 then
            goto def
        end;
        ';':
        begin
          tk.TokenEnd:=off+_minbpc;
          Result:=setRefChar(num,tk);
          exit;
        end
        else
          def:raise TInvalidTokenException.Create(off);

      end;
      inc(off,_minbpc);
    end;

  end;
  raise TPartialTokenException.Create();
end;

function TEncoding.scanComment(buf: TBytes; off, ed: integer; tk: TToken): Tok;
begin
  if off<>ed then
  begin
    checkCharMatches(buf,off,'-');
    inc(off,_minbpc);
    while off<>ed do
    begin
      case byteType(buf,off) of
        BT_LEAD2:
        begin
          if ed-off<2 then
            raise TPartialCharException.Create(off);
          check2(buf,off);
          inc(off,2);
        end;
        BT_LEAD3:
        begin
          if ed-off<3 then
            raise TPartialCharException.Create(off);
          check3(buf,off);
          inc(off,3);
        end;
        BT_LEAD4:
        begin
          if ed-off<4 then
            raise TPartialCharException.Create(off);
          check4(buf,off);
          inc(off,4);
        end;
        BT_NONXML,BT_MALFORM:
          raise TInvalidTokenException.Create(off);
        BT_MINUS:
        begin
          inc(off,_minbpc);
          if off=ed then
            raise TPartialTokenException.Create();
          if charMatches(buf,off,'-') then
          begin
            inc(off,_minbpc);
            if off=ed then
              raise TPartialTokenException.Create();
            checkCharMatches(buf,off,'>');
            tk.TokenEnd:=off+_minbpc;
            Result:=tok.COMMENT;
            exit;

          end;

        end;
        else
          inc(off,_minbpc);
      end;
    end;
  end;
end;

function TEncoding.scanDecl(buf: TBytes; off, ed: integer; tk: TToken): Tok;
  label bts;
begin
  if off=ed then
    raise TPartialTokenException.Create();
  case byteType(buf,off) of
    BT_MINUS:
    begin
      Result:=scanComment(buf,off+_minbpc,ed,tk);
      exit;
    end;
    BT_LSQB:
    begin
      tk.TokenEnd:=off+_minbpc;
      Result:=TOK.COND_SECT_OPEN;
      exit;
    end;
    BT_NMSTRT:inc(off,_minbpc);
    else
      raise TInvalidTokenException.Create(off);
  end;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_PERCNT:
      begin
        if off+_minbpc=ed then
          raise TPartialCharException.Create();
        case byteType(buf,off+_minbpc) of
          BT_S,BT_CR,BT_LF,BT_PERCNT:
            raise TInvalidTokenException.Create(off);
        end;
        goto bts;
      end;
      BT_S,BT_CR,BT_LF:
      begin
      bts:
        begin
          tk.TokenEnd:=off;
          Result:=TOK.DECL_OPEN;
          exit;
        end;
      end;
      BT_NMSTRT:inc(off,_minbpc);
      else raise TInvalidTokenException.Create(off);
    end;
  end;
  raise TPartialTokenException.Create();
end;

function TEncoding.scanEndTag(buf: TBytes; off, ed: integer; tk: TToken): Tok;
begin
  if off=ed then
    raise TPartialTokenException.Create();
  case byteType(buf,off) of
    BT_NMSTRT:inc(off,_minbpc);
    BT_LEAD2:
    begin
      if ed-off<2 then
        raise TPartialCharException.Create(off);
      if byteType2(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,2);
    end;
    BT_LEAD3:
    begin
      if ed-off<3 then
        raise TPartialCharException.Create(off);
      if byteType3(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,3);
    end;
    BT_LEAD4:
    begin
      if ed-off<4 then
        raise TPartialCharException.Create(off);
      if byteType4(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,4);
    end;
    else
    raise TInvalidTokenException.Create(off);
  end;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_NMSTRT,BT_NAME,BT_MINUS:inc(off,_minbpc);
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        if not isNameChar2(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        if not isNameChar3(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        if not isNameChar4(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,4);
      end;
      BT_S,BT_CR,BT_LF:
      begin
        tk.NameEnd:=off;
        inc(off,_minbpc);
        while off<>ed do
        begin
          case byteType(buf,off) of
            BT_S,BT_CR,BT_LF:;
            BT_GT:
            begin
              tk.TokenEnd:=off+_minbpc;
              Result:=TOK.END_TAG;
              exit;
            end;
            else
              raise TInvalidTokenException.Create(off);
          end;
          inc(off,_minbpc);
        end;
      end;
      BT_GT:
      begin
        tk.NameEnd:=off;
        tk.TokenEnd:=off+_minbpc;
        Result:=TOK.END_TAG;
        exit;
      end;
      else
        raise TInvalidTokenException.Create(off);
    end;
  end;
  raise TPartialTokenException.Create();
end;

function TEncoding.scanHexCharRef(buf: TBytes; off, ed: integer;
  tk: TToken): Tok;
var
  c:char;
  num:integer;
begin
  if off<>ed then
  begin
    c:=byteToAscii(buf,off);
    num:=0;
    case c of
      '0','1','2','3','4','5','6','7','8','9':num:=Ord(c)-ord('0');
      'A','B','C','D','E','F':num:=Ord(c)-(Ord('A')-10);
      'a','b','c','d','e','f':num:=Ord(c)-(Ord('a')-10);
      else
        raise TInvalidTokenException.Create(off);
    end;
    inc(off,_minbpc);
    while off<>ed do
    begin
      c:=byteToAscii(buf,off);
      case c of
        '0','1','2','3','4','5','6','7','8','9':num:=(num shl 4)+Ord(c)-ord('0');
        'A','B','C','D','E','F':num:=(num shl 4)+Ord(c)-(Ord('A')-10);
        'a','b','c','d','e','f':num:=(num shl 4)+Ord(c)-(Ord('a')-10);
        ';':
        begin
          tk.TokenEnd:=off+_minbpc;
          Result:=setRefChar(num,tk);
          Exit;
        end;
        else
          raise TInvalidTokenException.Create(off);
      end;
      if num>=$110000 then
        raise TInvalidTokenException.Create(off);
      inc(off,_minbpc);
    end;
  end;
  raise TPartialTokenException.Create();
end;

function TEncoding.scanLit(open:Integer;buf: TBytes; off, ed: integer; tk: TToken): Tok;
var
  t:integer;
begin
  while off<>ed do
  begin
    t:=byteType(buf,off);
    case t of
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialTokenException.Create();
        check2(buf,off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialTokenException.Create();
        check3(buf,off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialTokenException.Create();
        check4(buf,off);
        inc(off,4);
      end;
      BT_NONXML,BT_MALFORM:raise TInvalidTokenException.Create(off);
      BT_QUOT,BT_APOS:
      begin
        inc(off,_minbpc);
        if t=open then
        begin
          if off=ed then
            raise TExtensibleTokenException.Create(TOK.LITERAL);
          case byteType(buf,off) of
            BT_S,BT_CR,BT_LF,BT_GT,BT_PERCNT,BT_LSQB:
            begin
              tk.TokenEnd:=off;
              Result:=TOK.LITERAL;
              Exit;
            end;
            else
              raise TInvalidTokenException.Create(off);
          end;
        end;
      end;
      else
        inc(off,_minbpc);
    end;
  end;
  raise TPartialTokenException.Create();
end;

function TEncoding.scanLt(buf: TBytes; off, ed: integer;
  tk: TContentToken): Tok;
  label loop;
begin
  if off=ed then
    raise TPartialTokenException.Create();
  case byteType(buf,off) of
    BT_NMSTRT:inc(off,_minbpc);
    BT_LEAD2:
    begin
      if ed-off<2 then
        raise TPartialCharException.Create(off);
      if byteType2(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,2);
    end;
    BT_LEAD3:
    begin
      if ed-off<3 then
        raise TPartialCharException.Create(off);
      if byteType3(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,3);
    end;
    BT_LEAD4:
    begin
      if ed-off<4 then
        raise TPartialCharException.Create(off);
      if byteType4(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,4);
    end;
    BT_EXCL:
    begin
      inc(off,_minbpc);
      if off=ed then
        raise TPartialTokenException.Create();
      case byteType(buf,off) of
        BT_MINUS:
        begin
          Result:=scanComment(buf,off+_minbpc,ed,tk);
          exit;
        end;
        BT_LSQB:
        begin
          Result:=scanCdataSection(buf,off+_minbpc,ed,tk);
          Exit;
        end;
      end;
      raise TInvalidTokenException.Create(off);
    end;
    BT_QUEST:
    begin
      Result:=scanPi(buf,off+_minbpc,ed,tk);
      Exit;
    end;
    BT_SOL:
    begin
      Result:=scanEndTag(buf,off+_minbpc,ed,tk);
      exit;
    end;
    else
      raise TInvalidTokenException.Create(off);
  end;
  tk.NameEnd:=-1;
  tk.ClearAttributes;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_NMSTRT,BT_NAME,BT_MINUS:inc(off,_minbpc);
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        if not isNameChar2(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        if not isNameChar3(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        if not isNameChar4(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,4);
      end;
      BT_S,BT_CR,BT_LF:
      begin
        tk.NameEnd:=off;
        inc(off,_minbpc);
        while True do
        begin
          if off=ed then
            raise TPartialTokenException.Create();
          case byteType(buf,off) of
            BT_NMSTRT:
            begin
              Result:=scanAtts(off,buf,off+_minbpc,ed,tk);
              exit;
            end;
            BT_LEAD2:
            begin
              if ed-off<2 then
                raise TPartialCharException.Create(off);
              if byteType2(buf,off)<>BT_NMSTRT then
                raise TInvalidTokenException.Create(off);
              Result:=scanAtts(off,buf,off+2,ed,tk);
              exit;
            end;
            BT_LEAD3:
            begin
              if ed-off<3 then
                raise TPartialCharException.Create(off);
              if byteType3(buf,off)<>BT_NMSTRT then
                raise TInvalidTokenException.Create(off);
              Result:=scanAtts(off,buf,off+3,ed,tk);
              exit;
            end;
            BT_LEAD4:
            begin
              if ed-off<4 then
                raise TPartialCharException.Create(off);
              if byteType4(buf,off)<>BT_NMSTRT then
                raise TInvalidTokenException.Create(off);
              Result:=scanAtts(off,buf,off+4,ed,tk);
              exit;
            end;
            BT_GT,BT_SOL:goto loop;
            BT_S,BT_CR,BT_LF:inc(off,_minbpc);
            else
              raise TInvalidTokenException.Create(off);
          end;
        end;
        loop:;
      end;
      BT_GT:
      begin
        if tk.NameEnd<0 then
          tk.NameEnd:=off;
        tk.TokenEnd:=off+_minbpc;
        Result:=TOK.START_TAG_NO_ATTS;
        exit;
      end;
      BT_SOL:
      begin
        if tk.NameEnd<0 then
          tk.NameEnd:=off;
        Inc(off,_minbpc);
        if off=ed then
          raise TPartialTokenException.Create();
        checkCharMatches(buf,off,'>');
        tk.TokenEnd:=off+_minbpc;
        Result:=TOK.EMPTY_ELEMENT_NO_ATTS;
        exit;
      end;
      else raise TInvalidTokenException.Create(off);
    end;
  end;
  raise TPartialTokenException.Create();
end;

function TEncoding.scanPercent(buf: TBytes; off, ed: integer; tk: TToken): Tok;
begin
  if off=ed then
    raise TPartialTokenException.Create();
  case byteType(buf,off) of
    BT_NMSTRT:
      inc(off,_minbpc);
    BT_LEAD2:
    begin
      if ed-off<2 then
        raise TPartialCharException.Create(off);
      if byteType2(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,2);
    end;
    BT_LEAD3:
    begin
      if ed-off<3 then
        raise TPartialCharException.Create(off);
      if byteType3(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,3);
    end;
    BT_LEAD4:
    begin
      if ed-off<4 then
        raise TPartialCharException.Create(off);
      if byteType4(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,4);
    end;
    BT_S,BT_LF,BT_CR,BT_PERCNT:
    begin
      tk.TokenEnd:=off;
      Result:=tOk.PERCENT;
      exit;
    end;
    else
      raise TInvalidTokenException.Create(off);
  end;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_NMSTRT,BT_NAME,BT_MINUS:inc(off,_minbpc);
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        if not isNameChar2(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        if not isNameChar3(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        if not isNameChar4(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,4);
      end;
      BT_SEMI:
      begin
        tk.NameEnd:=off;
        tk.TokenEnd:=off+_minbpc;
        Result:=Tok.PARAM_ENTITY_REF;
        exit;
      end;
      else
        raise TInvalidTokenException.Create(off);
    end;
  end;
  raise TPartialTokenException.Create();
end;

function TEncoding.scanPi(buf: TBytes; off, ed: integer; tk: TToken): TOK;
var
  target:integer;
  isxml:Boolean;
begin
  target:=off;
  if off=ed then
    raise TPartialTokenException.Create();
  case byteType(buf,off) of
    BT_NMSTRT:inc(off,_minbpc);
    BT_LEAD2:
    begin
      if ed-off<2 then
        raise TPartialCharException.Create(off);
      if byteType2(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,2);
    end;
    BT_LEAD3:
    begin
      if ed-off<3 then
        raise TPartialCharException.Create(off);
      if byteType3(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,3);
    end;
    BT_LEAD4:
    begin
      if ed-off<4 then
        raise TPartialCharException.Create(off);
      if byteType4(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,4);
    end;
    else
      raise TInvalidTokenException.Create(off);
  end;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_NMSTRT,BT_NAME,BT_MINUS:inc(off,_minbpc);
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        if not isNameChar2(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        if not isNameChar3(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        if not isNameChar4(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,4);
      end;
      BT_S,BT_CR,BT_LF:
      begin
        isxml:=targetisxml(buf,target,off);
        tk.NameEnd:=off;
        inc(off,_minbpc);
        while off<>ed do
        begin
          case byteType(buf,off) of
            BT_LEAD2:
            begin
              if ed-off<2 then
                raise TPartialCharException.Create(off);
              check2(buf,off);
              inc(off,2);
            end;
            BT_LEAD3:
            begin
              if ed-off<3 then
                raise TPartialCharException.Create(off);
              check3(buf,off);
              inc(off,3);
            end;
            BT_LEAD4:
            begin
              if ed-off<4 then
                raise TPartialCharException.Create(off);
              check4(buf,off);
              inc(off,4);
            end;
            BT_NONXML,BT_MALFORM:raise TInvalidTokenException.Create(off);
            BT_QUEST:
            begin
              inc(off,_minbpc);
              if off=ed then
                raise TPartialTokenException.Create();
              if charMatches(buf,off,'>') then
              begin
                tk.TokenEnd:=off+_minbpc;
                if isxml then
                  Result:=TOK.XML_DECL
                else
                  Result:=TOK.PI;
                Exit;
              end;
            end;
            else
              inc(off,_minbpc);
          end;
        end;
        raise TPartialTokenException.Create();
      end;
      BT_QUEST:
      begin
        tk.NameEnd:=off;
        inc(off,_minbpc);
        if off=ed then
          raise TPartialTokenException.Create();
        checkCharMatches(buf,off,'>');
        tk.TokenEnd:=off+_minbpc;
        if targetIsXml(buf,target,tk.NameEnd) then
          Result:=TOK.XML_DECL
        else
          Result:=TOK.PI;
        Exit;
      end;
      else
        raise TInvalidTokenException.Create(off);
    end;
  end;
  raise TPartialTokenException.Create();
end;

function TEncoding.scanPoundName(buf: TBytes; off, ed: integer;
  tk: TToken): Tok;
begin
  if off=ed then
    raise TPartialTokenException.Create();
  case byteType(buf,off) of
    BT_NMSTRT:inc(off,_minbpc);
    BT_LEAD2:
    begin
      if ed-off<2 then
        raise TPartialCharException.Create(off);
      if byteType2(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,2);
    end;
    BT_LEAD3:
    begin
      if ed-off<3 then
        raise TPartialCharException.Create(off);
      if byteType3(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,3);
    end;
    BT_LEAD4:
    begin
      if ed-off<4 then
        raise TPartialCharException.Create(off);
      if byteType4(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,4);
    end;
    else
      raise TInvalidTokenException.Create(off);
  end;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_NMSTRT,BT_NAME,BT_MINUS:inc(off,_minbpc);
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        if not isNameChar2(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        if not isNameChar3(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        if not isNameChar4(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,4);
      end;
      BT_CR,BT_LF,BT_S,BT_RPAR,BT_GT,BT_PERCNT,BT_VERBAR:
      begin
        tk.TokenEnd:=off;
        Result:=TOK.POUND_NAME;
        exit;
      end;
      else
        raise TInvalidTokenException.Create(off);
    end;
  end;
  raise TExtensibleTokenException.Create(TOK.POUND_NAME);
end;

function TEncoding.scanRef(buf: TBytes; off, ed: integer; tk: TToken): Tok;
begin
  if off=ed then
    raise TPartialTokenException.Create();
  if isMagicEntityRef(buf,off,ed,tk) then
  begin
    Result:=TOK.MAGIC_ENTITY_REF;
    exit;
  end;
  case byteType(buf,off) of
    BT_NMSTRT:inc(off,_minbpc);
    BT_LEAD2:
    begin
      if ed-off<2 then
        raise TPartialCharException.Create(off);
      if byteType2(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,2);
    end;
    BT_LEAD3:
    begin
      if ed-off<3 then
        raise TPartialCharException.Create(off);
      if byteType3(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,3);
    end;
    BT_LEAD4:
    begin
      if ed-off<4 then
        raise TPartialCharException.Create(off);
      if byteType4(buf,off)<>BT_NMSTRT then
        raise TInvalidTokenException.Create(off);
      inc(off,4);
    end;
    BT_NUM:
    begin
      Result:=scanCharRef(buf,off+_minbpc,ed,tk);
      exit;
    end;
    else
      raise TInvalidTokenException.Create(off);
  end;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_NMSTRT,BT_NAME,BT_MINUS:inc(off,_minbpc);
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        if not isNameChar2(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        if not isNameChar3(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        if not isNameChar4(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,4);
      end;
      BT_SEMI:
      begin
        tk.NameEnd:=off;
        tk.TokenEnd:=off+_minbpc;
        Result:=TOK.ENTITY_REF;
        exit;
      end;
      else
        raise TInvalidTokenException.Create(off);
    end;
  end;
  raise TPartialTokenException.Create();
end;

class procedure TEncoding.setCharType(min, max: Char; tp: Integer);
var
  i:integer;
  n:char;
  shared:TInt256Array;
begin
  for i := 0 to 255 do
    shared[i]:=tp;
  repeat
    if (Ord(min) and $FF)=0 then
    begin
      while chr(Ord(min)+$FF)<=max do
      begin
        charTypeTable[Ord(min)shr 8]:=shared;
        if Chr(ord(min)+$FF)=max then
          exit;
        min:=chr(Ord(min)+$100);
      end;
    end;
    setCharType(min,tp);
    n:=min;
    inc(min);
  until n=max;

end;

class procedure TEncoding.setCharType(c: Char; tp: Integer);
var
  hi,i:integer;
begin
  if Ord(c)<$80 then
    exit;
  hi:=Ord(c)shr 8;
  { TODO : 数组是否初始化判断 }
  //if charTypeTable[hi] then
  for i := 0 to 255 do
    charTypeTable[hi][i]:=BT_OTHER;
  charTypeTable[hi][Ord(c)and $FF]:=tp;
end;

function TEncoding.setRefChar(num: integer; tk: TToken): Tok;
begin
  if num<$10000 then
  begin
    case charTypeTable[num shr 8][num and $FF] of
      BT_NONXML,BT_LEAD4,BT_MALFORM:raise TInvalidTokenException.Create(tk.TokenEnd-_minbpc);
    end;
    tk.RefChar1:=chr(num);
    Result:=TOK.CHAR_REF;
    exit;
  end
  else
  begin
    Dec(num,$10000);
    tk.RefChar1:=chr((num shr 10)+$D800);
    tk.RefChar2:=chr((num and ((1 shl 10)-1))+$DC00);
    Result:=TOK.CHAR_PAIR_REF;
    exit;
  end;
end;

function TEncoding.skipIgnoreSect(buf: TBytes; off, ed: Integer): integer;
label loop;
var
  level:integer;
begin
  if _minBPC>1 then
    ed:=adjustEnd(off,ed);
  level:=0;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        check2(buf,off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        check3(buf,off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        check4(buf,off);
        inc(off,4);
      end;
      BT_NONXML,BT_MALFORM:raise TInvalidTokenException.Create(off);
      BT_LT:
      begin
        inc(off,_minbpc);
        if off=ed then
          goto loop;
        if charMatches(buf,off,'!') then
        begin
          inc(off,_minbpc);
          if off=ed then
            goto loop;
          if charMatches(buf,off,'[') then
          begin
            Inc(level);
            inc(off,_minbpc);
          end;
        end;
      end;
      BT_RSQB:
      begin
        inc(off,_minbpc);
        if off=ed then
          goto loop;
        if charMatches(buf,off,']') then
        begin
          inc(off,_minbpc);
          if off=ed then
            goto loop;
          if charMatches(buf,off,'>') then
          begin
            if level=0 then
            begin
              Result:=off+_minbpc;
              exit;
            end;
            Dec(level);
          end
          else
          if not charMatches(buf,off,']') then
          begin
            inc(off,_minbpc);
          end;
        end;
      end;
      else
        inc(off,_minbpc);
    end;
  end;
  loop:raise TPartialTokenException.Create;
end;

function TEncoding.skipS(buf: TBytes; off, ed: Integer): integer;
begin
  while off<ed do
  begin
    case byteType(buf,off) of
      BT_S,BT_CR,BT_LF:inc(off,_minbpc);
      else
      begin
        Result:=off;
        exit;
      end;
    end;
  end;
end;

function TEncoding.targetIsXml(buf: TBytes; off, ed: Integer): Boolean;
var
  upper:Boolean;
begin
  upper:=false;
  if ed-off<>_minbpc*3 then
  begin
    Result:=false;
    exit;
  end;
  case byteToAscii(buf,off) of
    'x':;
    'X':upper:=true;
    else
    begin
      Result:=False;
      exit;
    end;
  end;
  inc(off,_minbpc);
  case byteToAscii(buf,off) of
    'm':;
    'M':upper:=true;
    else
    begin
      Result:=false;
      exit;
    end;
  end;
  inc(off,_minbpc);
  case byteToAscii(buf,off) of
    'l':;
    'L':upper:=true;
    else
    begin
      Result:=false;
      exit;
    end;
  end;
  if upper then
    raise TInvalidTokenException.Create(off,TInvalidTokenException.XML_TARGET);
  Result:=True;
end;

function TEncoding.tokenizeAttributeValue(buf: TBytes; off, ed: integer;
  tk: TToken): Tok;
var
  start:integer;
begin
  if _minBPC>1 then
    ed:=adjustEnd(off,ed);
  if off=ed then
    raise TEmptyTokenException.Create();
  start:=off;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        inc(off,4);
      end;
      BT_AMP:
      begin
        if off=start then
        begin
          Result:=scanRef(buf,off+_minbpc,ed,tk);
          Exit;
        end;
        tk.TokenEnd:=off;
        Result:=TOK.DATA_CHARS;
        exit;
      end;
      BT_LT:raise TInvalidTokenException.Create(off);
      BT_S:
      begin
        if off=start then
        begin
          tk.TokenEnd:=off+_minbpc;
          Result:=TOK.ATTRIBUTE_VALUE_S;
          exit;
        end;
        tk.TokenEnd:=off;
        Result:=TOK.DATA_CHARS;
        exit;
      end;
      BT_LF:
      begin
        if off=start then
        begin
          tk.TokenEnd:=off+_minbpc;
          Result:=TOK.DATA_NEWLINE;
          exit;
        end;
        tk.TokenEnd:=off;
        Result:=TOK.DATA_CHARS;
        exit;
      end;
      BT_CR:
      begin
        if off=start then
        begin
          inc(off,_minbpc);
          if off=ed then
            raise TExtensibleTokenException.Create(TOK.DATA_NEWLINE);
          if byteType(buf,off)=BT_LF then
            inc(off,_minbpc);
          tk.TokenEnd:=off;
          Result:=TOK.DATA_NEWLINE;
          exit;
        end;
        tk.TokenEnd:=off;
        Result:=TOK.DATA_CHARS;
        exit;
      end;
      else
        inc(off,_minbpc);
    end;
  end;
  tk.TokenEnd:=off;
  Result:=TOK.DATA_CHARS;
end;

function TEncoding.tokenizeCdataSection(buf: TBytes; off, ed: integer;
  tk: TToken): Tok;
begin
  if _minBPC>1 then
    ed:=adjustEnd(off,ed);
  if off=ed then
    raise TEmptyTokenException.Create();
  case byteType(buf,off) of
    BT_RSQB:
    begin  
      inc(off,_minbpc);
      if off=ed then
        raise TPartialTokenException.Create();
      if charMatches(buf,off,']') then
      begin
        inc(off,_minbpc);
        if off=ed then
          raise TPartialTokenException.Create();
        if not charMatches(buf,off,'>') then
          Dec(off,_minbpc)
        else
        begin
          tk.TokenEnd:=off+_minbpc;
          Result:=TOK.CDATA_SECT_close;
          exit;
        end;
      end;
    end;
    BT_CR:
    begin
      inc(off,_minbpc);
      if off=ed then
        raise TExtensibleTokenException.Create(TOK.DATA_NEWLINE);
      if byteType(buf,off)=BT_LF then
        inc(off,_minbpc);
      tk.TokenEnd:=off;
      Result:=TOK.DATA_NEWLINE;
      exit;
    end;
    BT_LF:
    begin
      tk.TokenEnd:=off+_minbpc;
      Result:=TOK.DATA_NEWLINE;
      Exit;
    end;
    BT_NONXML,BT_MALFORM:
      raise TInvalidTokenException.Create(off);
    BT_LEAD2:
    begin
      if ed-off<2 then
        raise TPartialCharException.Create(off);
      check2(buf,off);
      inc(off,2);
    end;
    BT_LEAD3:
    begin
      if ed-off<3 then
        raise TPartialCharException.Create(off);
      check3(buf,off);
      inc(off,3);
    end;
    BT_LEAD4:
    begin
      if ed-off<4 then
        raise TPartialCharException.Create(off);
      check4(buf,off);
      inc(off,4);
    end;
    else
      inc(off,_minbpc);
  end;
  tk.TokenEnd:=extendCdata(buf,off,ed);
  Result:=TOK.DATA_CHARS;
end;

function TEncoding.tokenizeContent(buf: TBytes; off, ed: integer;
  tk: TContentToken): Tok;
begin
  if _minBPC>1 then
    ed:=adjustEnd(off,ed);
  if off=ed then
    raise TEmptyTokenException.Create();
  case byteType(buf,off) of
    BT_LT:
    begin
      Result:=scanLt(buf,off+_minbpc,ed,tk);
      exit;
    end;
    BT_AMP:
    begin
      Result:=scanRef(buf,off+_minbpc,ed,tk);
      exit;
    end;
    BT_CR:
    begin
      inc(off,_minbpc);
      if off=ed then
        raise TExtensibleTokenException.Create(TOK.DATA_NEWLINE);
      if byteType(buf,off)=BT_LF then
        inc(off,_minbpc);
      tk.TokenEnd:=off;
      Result:=TOK.DATA_NEWLINE;
      exit;
    end;
    BT_LF:
    begin
      tk.TokenEnd:=off+_minbpc;
      result:=TOK.DATA_NEWLINE;
      exit;
    end;
    BT_RSQB:
    begin
      inc(off,_minbpc);
      if off=ed then
        raise TExtensibleTokenException.Create(TOK.DATA_CHARS);
      if charMatches(buf,off,']') then
      begin
        inc(off,_minbpc);
        if off=ed then
          raise TExtensibleTokenException.Create(TOK.DATA_CHARS);
        if charMatches(buf,off,'>') then
          raise TInvalidTokenException.Create(off)
        else
          Dec(off,_minbpc);
      end;
    end;
    BT_NONXML,BT_MALFORM:raise TInvalidTokenException.Create(off);
    BT_LEAD2:
    begin
      if ed-off<2 then
        raise TPartialCharException.Create(off);
      check2(buf,off);
      inc(off,2);
    end;
    BT_LEAD3:
    begin
      if ed-off<3 then
        raise TPartialCharException.Create(off);
      check3(buf,off);
      inc(off,3);
    end;
    BT_LEAD4:
    begin
      if ed-off<4 then
        raise TPartialCharException.Create(off);
      check4(buf,off);
      inc(off,4);
    end;
    else
      inc(off,_minbpc);
  end;
  tk.TokenEnd:=extendData(buf,off,ed);
  Result:=TOK.DATA_CHARS;
end;

function TEncoding.tokenizeEntityValue(buf: TBytes; off, ed: integer;
  tk: TToken): Tok;
var
  start:integer;
begin
  if _minBPC>1 then
    ed:=adjustEnd(off,ed);
  if off=ed then
    raise TEmptyTokenException.Create();
  start:=off;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        inc(off,4);
      end;
      BT_AMP:
      begin
        if off=start then
        begin
          Result:=scanRef(buf,off+_minbpc,ed,tk);
          exit;
        end;
        tk.TokenEnd:=off;
        Result:=TOK.DATA_CHARS;
        exit;
      end;
      BT_PERCNT:
      begin
        if off=start then
        begin
          Result:=scanPercent(buf,off+_minbpc,ed,tk);
          exit;
        end;
        tk.TokenEnd:=off;
        Result:=TOK.DATA_CHARS;
        exit;
      end;
      BT_LF:
      begin
        if off=start then
        begin
          tk.TokenEnd:=off+_minbpc;
          Result:=TOK.DATA_NEWLINE;
          exit;
        end;
        tk.TokenEnd:=off;
        Result:=TOK.DATA_CHARS;
        exit;
      end;
      BT_CR:
      begin
        if off=start then
        begin
          inc(off,_minbpc);
          if off=ed then
            raise TExtensibleTokenException.Create(TOK.DATA_NEWLINE);
          if byteType(buf,off)=BT_LF then
            inc(off,_minbpc);
          tk.TokenEnd:=off;
          Result:=TOK.DATA_NEWLINE;
          exit;
        end;
        tk.TokenEnd:=off;
        Result:=TOK.DATA_CHARS;
        Exit;
      end;
      else
        inc(off,_minbpc);
    end;
  end;
  tk.TokenEnd:=off;
  Result:=tok.DATA_CHARS;
end;

function TEncoding.tokenizeProlog(buf: TBytes; off, ed: integer;
  tk: TToken): Tok;
var
  t:TOK;
label bts,def;
begin
  if _minBPC>1 then
  ed:=adjustEnd(off,ed);
  if off=ed then
    raise TEmptyTokenException.Create();
  case byteType(buf,off) of
    BT_QUOT:
    begin
      Result:=scanLit(BT_QUOT,buf,off+_minbpc,ed,tk);
      Exit;
    end;
    BT_APOS:
    begin
      Result:=scanLit(BT_APOS,buf,off+_minbpc,ed,tk);
      Exit;
    end;
    BT_LT:
    begin
      inc(off,_minbpc);
      if off=ed then
        raise TPartialTokenException.Create();
      case byteType(buf,off) of
        BT_EXCL:
        begin
          Result:=scanDecl(buf,off+_minbpc,ed,tk);
          Exit;
        end;
        BT_QUEST:
        begin
          Result:=scanPi(buf,off+_minbpc,ed,tk);
          Exit;
        end;
        BT_NMSTRT,BT_LEAD2,BT_LEAD3,BT_LEAD4:
        begin
          tk.TokenEnd:=off-_minbpc;
          raise TEndOfPrologException.Create();
        end;
      end;
      raise TInvalidTokenException.Create(off);
    end;
    BT_CR:
    begin
      if off+_minbpc=ed then
        raise TExtensibleTokenException.Create(TOK.PROLOG_S);
      goto bts;
    end;
    BT_S,BT_LF:
    begin
      bts:
      begin
        while True do
        begin
          inc(off,_minbpc);
          if off<>ed then
          begin
            case byteType(buf,off) of
              BT_S,BT_LF:;
              BT_CR:
              begin
                if off+_minbpc=ed then
                  goto def;
              end;
              else
              begin
              def:
              begin
                tk.TokenEnd:=off;
                Result:=TOK.PROLOG_S;
                Exit;
              end;
              end;
            end;
          end;
        end;
        tk.TokenEnd:=off;
        Result:=TOK.PROLOG_S;
        exit;
      end;
    end;
    BT_PERCNT:
    begin
      Result:=scanPercent(buf,off+_minbpc,ed,tk);
      exit;
    end;
    BT_COMMA:
    begin
      tk.TokenEnd:=off+_minbpc;
      Result:=TOK.COMMA;
      exit;
    end;
    BT_LSQB:
    begin
      tk.TokenEnd:=off+_minbpc;
      Result:=TOK.OPEN_BRACKET;
      exit;
    end;
    BT_RSQB:
    begin
      inc(off,_minbpc);
      if off=ed then
        raise TExtensibleTokenException.Create(TOK.CLOSE_BRACKET);
      if charMatches(buf,off,']') then
      begin
        if off+_minbpc=ed then
          raise TPartialTokenException.Create();
        if charMatches(buf,off+_minbpc,'>') then
        begin
          tk.TokenEnd:=off+2*_minbpc;
          Result:=TOK.COND_SECT_CLOSE;
          exit;
        end;
      end;
      tk.TokenEnd:=off;
      Result:=TOK.CLOSE_BRACKET;
    end;
    BT_LPAR:
    begin
      tk.TokenEnd:=off+_minbpc;
      Result:=TOK.OPEN_PAREN;
    end;
    BT_RPAR:
    begin
      inc(off,_minbpc);
      if off=ed then
        raise TExtensibleTokenException.Create(TOK.CLOSE_PAREN);
      case byteType(buf,off) of
        BT_AST:
        begin
          tk.TokenEnd:=off+_minbpc;
          Result:=TOK.CLOSE_PAREN_ASTERISK;
          exit;
        end;
        BT_QUEST:
        begin
          tk.TokenEnd:=off+_minbpc;
          Result:=TOK.CLOSE_PAREN_QUESTION;
          exit;
        end;
        BT_PLUS:
        begin
          tk.TokenEnd:=off+_minbpc;
          Result:=TOK.CLOSE_PAREN_PLUS;
          exit;
        end;
        BT_CR,BT_LF,BT_S,BT_GT,BT_COMMA,BT_VERBAR,BT_RPAR:
        begin
          tk.TokenEnd:=off;
          Result:=TOK.CLOSE_PAREN;
          Exit;
        end;
      end;
      raise TInvalidTokenException.Create(off);
    end;
    BT_VERBAR:
    begin
      tk.TokenEnd:=off+_minbpc;
      Result:=TOK.tokOR;
      exit;
    end;
    BT_GT:
    begin
      tk.TokenEnd:=off+_minbpc;
      Result:=TOK.DECL_CLOSE;
      exit;
    end;
    BT_NUM:
    begin
      Result:=scanPoundName(buf,off+_minbpc,ed,tk);
      exit;
    end;
    BT_LEAD2:
    begin
      if ed-off<2 then
        raise TPartialCharException.Create(off);
      case byteType2(buf,off) of
        BT_NMSTRT:
        begin
          inc(off,2);
          t:=tok.NAME;
        end;
        BT_NAME:
        begin
          inc(off,2);
          t:=TOK.NMTOKEN;
        end;
        else
          raise TInvalidTokenException.Create(off);
      end;
    end;
    BT_LEAD3:
    begin
      if ed-off<3 then
        raise TPartialCharException.Create(off);
      case byteType3(buf,off) of
        BT_NMSTRT:
        begin
          inc(off,3);
          t:=tok.NAME;
        end;
        BT_NAME:
        begin
          inc(off,3);
          t:=TOK.NMTOKEN;
        end;
        else
          raise TInvalidTokenException.Create(off);
      end;
    end;
    BT_LEAD4:
    begin
      if ed-off<4 then
        raise TPartialCharException.Create(off);
      case byteType4(buf,off) of
        BT_NMSTRT:
        begin
          inc(off,4);
          t:=tok.NAME;
        end;
        BT_NAME:
        begin
          inc(off,4);
          t:=TOK.NMTOKEN;
        end;
        else
          raise TInvalidTokenException.Create(off);
      end;
    end;
    BT_NMSTRT:
    begin
      t:=TOK.NAME;
      inc(off,_minbpc);
    end;
    BT_NAME,BT_MINUS:
    begin
      t:=TOK.NMTOKEN;
      inc(off,_minbpc);
    end;
    else
      raise TInvalidTokenException.Create(off);
  end;
  while off<>ed do
  begin
    case byteType(buf,off) of
      BT_NMSTRT,BT_NAME,BT_MINUS:inc(off,_minbpc);
      BT_LEAD2:
      begin
        if ed-off<2 then
          raise TPartialCharException.Create(off);
        if not isNameChar2(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,2);
      end;
      BT_LEAD3:
      begin
        if ed-off<3 then
          raise TPartialCharException.Create(off);
        if not isNameChar3(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,3);
      end;
      BT_LEAD4:
      begin
        if ed-off<4 then
          raise TPartialCharException.Create(off);
        if not isNameChar4(buf,off) then
          raise TInvalidTokenException.Create(off);
        inc(off,4);
      end;
      BT_GT,BT_RPAR,BT_COMMA,BT_VERBAR,BT_LSQB,BT_PERCNT,BT_S,BT_CR,BT_LF:
      begin
        tk.TokenEnd:=off;
        Result:=t;
        exit;
      end;
      BT_PLUS:
      begin
        if t<>TOK.NAME then
          raise TInvalidTokenException.Create(off);
        tk.TokenEnd:=off+_minbpc;
        Result:=TOK.NAME_PLUS;
        exit;
      end;
      BT_AST:
      begin
        if t<>TOK.NAME then
          raise TInvalidTokenException.Create(off);
        tk.TokenEnd:=off+_minbpc;
        Result:=TOK.NAME_ASTERISK;
        exit;
      end;
      BT_QUEST:
      begin
        if t<>TOK.NAME then
          raise TInvalidTokenException.Create(off);
        tk.TokenEnd:=off+_minbpc;
        Result:=TOK.NAME_QUESTION;
        exit;
      end;
      else
        raise TInvalidTokenException.Create(off);
    end;
  end;
  raise TExtensibleTokenException.Create(t);
end;

end.
