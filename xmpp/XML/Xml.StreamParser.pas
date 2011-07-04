unit Xml.StreamParser;

interface
uses
  NativeXml,XMPPEvent,EventList,Element,Xml.xpnet.BufferAggregate,Xml.xpnet.NS,SysUtils,XMPPConst,Xml.xpnet.Token,Xml.Dom.Text,Xml.xpnet.UTF8Encoding,Xml.xpnet.Exception,Xml.Dom.Comment,Generics.Collections,StrUtils,ElementFactory,TypInfo;
type
  TStreamParser=class
  private
    _depth:Integer;
    _root:TElement;
    current:TElement;
    _buf:TBufferAggregate;
    _ns:TNS;
    _cdata:Boolean;
    utf:SysUtils.tutf8encoding;
    _enc:Xml.xpnet.UTF8Encoding.TUTF8Encoding;

    FOnStreamStart:StreamHandler;
    FOnStreamEnd:StreamHandler;
    FOnStreamElement:TEventList<StreamHandler>;
    FOnStreamError:StreamError;
    FOnError:ErrorHandler;
    procedure StartTag(buf:TBytes;offset:Integer;ct:TContentToken;tok:TOK);
    procedure EndTag(buf:TBytes;offset:Integer;ct:TContentToken;tok:TOK);
    procedure DoRaiseOnStreamElement(el:Telement);
    function NormalizeAttributeValue(buf:TBytes;offset,len:Integer):string;
    procedure AddText(text:string);
  public
    constructor Create;
    destructor Destroy;
    property OnStreamStart:StreamHandler read FOnStreamStart write FOnStreamStart;
    property OnStreamEnd:StreamHandler read FOnStreamEnd write FOnStreamEnd;
    property OnStreamElement:TEventList<StreamHandler> read FOnStreamElement write FOnStreamElement;
    property OnStreamError:StreamError read FOnStreamError write FOnStreamError;
    property OnError:ErrorHandler read FOnError write FOnError;

    property Depth:LongInt read _depth;

    procedure Reset();
    procedure Push(buf:tbytes;offset,len:integer);overload;
    procedure Push(xml:string);overload;

  end;
implementation

{ TStreamParser }

procedure TStreamParser.AddText(text: string);
var
  last:TXmlnode;
begin
  if text='' then
    Exit;
  if current<>nil then
  begin
    last:=current.lastnode;
    if (last<>nil) and ((last.elementtype=xeCData)or(last.ElementType=xeCharData)) then
      last.value:=last.value+text
    else
      current.Value:=text;
  end;
end;

constructor TStreamParser.Create;
begin
  utf:=SysUtils.TUTF8Encoding.Create();
  _enc:=xml.xpnet.UTF8Encoding.TUTF8Encoding.Create;
  _buf:=TBufferAggregate.Create;
  _ns:=TNS.Create;
  _cdata:=False;
  _depth:=0;
  FOnStreamElement:=TEventList<StreamHandler>.Create;
end;

destructor TStreamParser.Destroy;
begin
  _buf.Free;
  _ns.Free;
  _enc.Free;
  utf.Free;
  FOnStreamElement.Free;

end;

procedure TStreamParser.DoRaiseOnStreamElement(el: Telement);
var
  i:Integer;
begin
  try
  if Assigned(FOnStreamElement) and (FOnStreamElement.Count>0) then
  begin
    for i := 0 to FOnStreamElement.Count-1 do
    FOnStreamElement[i](Self,current);

  end;

  except
  on e:Exception do
    if Assigned(FOnError) then
      FOnError(Self,e);

  end;
end;

procedure TStreamParser.EndTag(buf: TBytes; offset: Integer; ct: TContentToken;
  tok: TOK);
var
  nm:string;
  parent:TElement;
begin
  Dec(_depth);
  _ns.PopScope;
  if not Assigned(current) then
  begin
    if Assigned(FOnStreamEnd) then
      FOnStreamEnd(Self,_root);
    exit;
  end;
  nm:='';
  if (tok=EMPTY_ELEMENT_WITH_ATTS) or (tok=EMPTY_ELEMENT_NO_ATTS) then
    nm:=utf.GetString(buf,offset+_enc.MinbytesPerChar,ct.NameEnd-offset-_enc.MinbytesPerChar)
  else
    nm:=utf.GetString(buf,offset+_enc.MinbytesPerChar*2,ct.NameEnd-offset-_enc.MinbytesPerChar*2);
  parent:=TElement(current.Parent);
  if not Assigned(parent) then
  begin
    DoRaiseOnStreamElement(current);
    //freeandnil(current);
  end;
  current:=parent;

end;

function TStreamParser.NormalizeAttributeValue(buf: TBytes; offset,
  len: Integer): string;
var
  val:string;
  buffer:TBufferAggregate;
  cpy,b:Tbytes;
  off:integer;
  tk:TOK;
  ct:TContentToken;
begin
  if len=0 then
  begin
    Result:='';
    exit;
  end;
  val:='';
  buffer:=TBufferAggregate.Create;
  SetLength(cpy,len);
  cpy:=Copy(buf,offset,len);
  buffer.Write(cpy);
  b:=buffer.GetBuffer;
  off:=0;
  tk:=Tok.END_TAG;
  ct:=TContentToken.Create;
  try
  try
    while off<Length(b) do
    begin
      tk:=_enc.tokenizeAttributeValue(b,off,Length(b),ct);
      case tk of
        DATA_CHARS,DATA_NEWLINE,ATTRIBUTE_VALUE_S: val:=val+utf.GetString(b,off,ct.TokenEnd-off);
        CHAR_REF,MAGIC_ENTITY_REF:val:=val+ct.RefChar1;
        CHAR_PAIR_REF:val:=val+ct.RefChar1+ct.RefChar2;
        ENTITY_REF:raise Exception.Create('Token type not implemented: ' );
      end;
      off:=ct.TokenEnd;
    end;
  except
    on ex:TpartialTokenException do;
    on ex:TExtensibleTokenException do;
    on ex:Exception do
      if Assigned(FOnStreamError) then
        FOnStreamError(Self,ex);
  end;
  finally
    buffer.clear(off);
  end;
  result:=val;
end;

procedure TStreamParser.Push(xml: string);
var
  bt:Tbytes;
begin
  bt:=utf.GetBytes(xml);
  Push(bt,0,Length(bt));
end;

procedure TStreamParser.Push(buf: tbytes; offset, len: integer);
var
  cpy,b:TBytes;
  off:Integer;
  tk:TOK;
  ct:TContentToken;
  start,ed:integer;
  txt:string;
begin
  if len=0 then
    exit;
  SetLength(cpy,len);
  cpy:=Copy(buf,offset,len);
  _buf.Write(cpy);
  b:=_buf.GetBuffer;
  off:=0;
  tk:=tok.END_TAG;
  ct:=TContentToken.Create;
  try
    try
      while off<Length(b) do
      begin
        if _cdata then
          tk:=_enc.tokenizeCdataSection(b,off,Length(b),ct)
        else
          tk:=_enc.tokenizeContent(b,off,Length(b),ct);
        case tk of
          EMPTY_ELEMENT_NO_ATTS,EMPTY_ELEMENT_WITH_ATTS:
          begin
            StartTag(b,off,ct,tk);
            EndTag(b,off,ct,tk);
          end;
          START_TAG_NO_ATTS,START_TAG_WITH_ATTS:
            StartTag(b,off,ct,tk);
          END_TAG:
            EndTag(b,off,ct,tk);
          DATA_CHARS,DATA_NEWLINE:
            AddText(utf.GetString(b,off,ct.TokenEnd-off));
          CHAR_REF,MAGIC_ENTITY_REF:
            AddText(ct.RefChar1);
          CHAR_PAIR_REF:
            AddText(ct.RefChar1+ct.RefChar2);
          COMMENT:
          begin
            if not Assigned(current) then
            begin
              start:=off+4*_enc.MinbytesPerChar;
              ed:=ct.TokenEnd-off-7*_enc.MinbytesPerChar;
              txt:=utf.GetString(b,start,ed);
              current.NodeAdd(TComment.Create(txt));
            end;
          end;
          CDATA_SECT_OPEN:_cdata:=true;
          CDATA_SECT_CLOSE:_cdata:=False;
          XML_DECL:;
          ENTITY_REF,Pi:raise Exception.Create('Token type not implemented: ');
        end;
        off:=ct.TokenEnd;
      end;
    except
      on ex:TPartialTokenException do;
      on ex:TExtensibleTokenException do;
      on ex:Exception do ;
        //if Assigned(FOnStreamError) then
          //FOnStreamError(self,ex);
    end;
  finally
    _buf.Clear(off);
  end;
end;

procedure TStreamParser.Reset;
begin
  _depth:=0;
  FreeAndNil(_root);
  FreeAndNil(current);
  _cdata:=false;
  FreeAndNil(_buf);
  _buf:=TBufferAggregate.Create;
  _ns.Clear;
end;

procedure TStreamParser.StartTag(buf: TBytes; offset: Integer;
  ct: TContentToken; tok: TOK);
var
  colon:Integer;
  name,prefix,val,ns,attname:string;
  ht:TObjectDictionary<string,string>;
  i,start,ed:integer;
  newel:TElement;
begin
  Inc(_depth);
  colon:=0;
  name:='';
  prefix:='';
  ht:=TObjectDictionary<string,string>.create;
  _ns.PushScope;
  if (tok=START_TAG_WITH_ATTS)or(tok=EMPTY_ELEMENT_WITH_ATTS) then
  begin
    start:=0;
    ed:=0;
    val:='';
    for i := 0 to ct.GetAttributeSpecifiedCount-1 do
    begin
      start:=ct.GetAttributeNameStart(i);
      ed:=ct.GetAttributeNameEnd(i);
      name:=utf.GetString(buf,start,ed-start);
      start:=ct.GetAttributeValueStart(i);
      ed:=ct.GetAttributeValueEnd(i);
      val:=NormalizeAttributeValue(buf,start,ed-start);
      if StartsStr('xmlns:',name) then
      begin
        colon:=Pos(':',name);
        //prefix:=LeftStr(name,colon-1);
        prefix:=RightStr(name,Length(name)-colon);
        _ns.AddNamespace(prefix,val);
      end
      else if name='xmlns' then
        _ns.AddNamespace('',val)
      else
        ht.Add(name,val);
    end;
  end;
  name:=utf.GetString(buf,offset+_enc.MinbytesPerChar,ct.NameEnd-offset-_enc.MinbytesPerChar);
  colon:=Pos(':',name);
  ns:='';
  prefix:='';
  if colon>0 then
  begin
    prefix:=LeftStr(name,colon-1);
    name:=RightStr(name,Length(name)-colon);
    ns:=_ns.LookupNamespace(prefix);
  end
  else
    ns:=_ns.DefaultNamespace;
  newel:=TElementFactory.GetElement(prefix,name,ns);
  for attname in ht.Keys do
    newel.SetAttribute(attname,ht[attname]);
  if not Assigned(_root) then
  begin
    _root:=newel;
    if Assigned(FOnStreamStart) then
      FOnStreamStart(self,_root);
  end
  else
  begin
    if Assigned(current) then
      current.NodeAdd(newel);
    current:=newel;
  end;

end;

end.
