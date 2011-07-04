unit Element;

interface
uses
  NativeXml,TypInfo,Classes,Generics.Collections,jid,SysUtils,sdStringTable,EncdDecd,XMPPConst,Xml.Dom.Text;
type
  TElement=class(TsdElement)
    private
      _prefix:string;
      _namespace:string;
      function  FGetIsRootElement:Boolean;
      
      function FGetNamespace:string;
      procedure FSetNamespace(value:string);
      function FGetTextBase64:string;
      procedure FSetTextBase64(value:string);


      function _SelectElement(se:TElement;classtype:pointer;traversechildren:Boolean):TElement;overload;
      function _SelectElement(se:Telement;classtype:Pointer):Telement;overload;
      function _SelectElement(se:Telement;tagname:string):Telement;overload;
      function _SelectElement(se:Telement;tagname:string;traversechildren:Boolean):Telement;overload;
      function _SelectElement(se:Telement;tagname,attrname,attrvalue:string):Telement;overload;
      function _SelectElement(se:Telement;tagname,namespace:string;traversechildren:Boolean):Telement;overload;
      procedure _SelectElements(se:Telement;classtype:pointer;const es:TList<TElement>);overload;
      procedure _SelectElements(se:Telement;classtype:pointer;const es:TList<TElement>;traversechildren:Boolean);overload;
      procedure _SelectElements(se:Telement;tagname:string;const es:TList<TElement>;traversechildren:Boolean);overload;
      function FGetLastNode:TXmlNode;
      function FGetFirstNode:TXmlNode;

    public
      constructor Create();overload;virtual;
      constructor Create(Aowner:TNativeXml);overload;override;
      constructor Create(tagname:string);overload;virtual;
      constructor Create(tagname:string;tagtext:string);overload;
      constructor Create(tagname:string;tagtext:Boolean);overload;
      constructor Create(tagname,tagtext,ns:string);overload;virtual;

      property IsRootElement:Boolean read FGetIsRootElement;
      property Prefix:string read _prefix write _prefix;

      property Namespace:string read FGetNamespace write FSetNamespace;
      property LastNode:TXmlNode read FGetLastNode;
      property FirstNode:TXmlNode read FGetFirstNode;
      property TextBase64:string read FGetTextBase64 write FSetTextBase64;

      function HasTag(tag:string):Boolean;overload;
      function HasTag(tag:string;traverseChildren:Boolean):Boolean;overload;
      function HasTag(classtype:Pointer):Boolean;overload;
      function HasTag(classtype:Pointer;traverseChildren:Boolean):Boolean;overload;

      function GetTag(tag:string):string;overload;
      function GetTag(tag:string;traverseChildren:Boolean):string;overload;
      function GetTag(clastype:Pointer):string;overload;
      function GetTagBase64(tagname:string):string;
      function GetTagBool(tagname:string):Boolean;

      function GetTagInt(tagname:string):integer;
      function GetTagJid(tagname:string):TJid;
      function GetTagEnum(name:string;enumtype:PTypeInfo):integer;
      function HasTagEnum(enumtype:PTypeInfo):integer;
      function HasTagArray(arr:array of string):string;
      procedure SetEnumTag(name:Integer;enumtype:PTypeInfo);
      procedure ReplaceNode(e:Telement);overload;
      procedure SetAttribute(name,val:string);overload;
      procedure SetAttribute(name:string;val:Boolean);overload;
      procedure RemoveAttribute(name:string);

      function RemoveTag(tag:string):Boolean;overload;
      function RemoveTag(classtype:Pointer):Boolean;overload;
      function RemoveTags(classtype:Pointer):Boolean;
      
      procedure SetTag(classtype:pointer;argText:string); overload;
      procedure SetTag(name,value:string);overload;
      procedure SetTag(classtype:pointer);overload;
      procedure SetTag(name:string);overload;
      procedure SetTag(name,value,ns:string);overload;
      procedure SetTag(name:string;val:Boolean);overload;
      procedure SetTag(name:string;val:integer);overload;
      procedure SetTag(name:string;jid:TJID);overload;
      procedure SetTagBase64(name:string;val:string);overload;
      procedure SetTagBase64(name:string;buffer:TArray<Byte>);overload;
      function SelectElements(tagname:string):TList<TElement>;overload;
      function SelectElements(tagname:string;traverseChildren:Boolean):TList<TElement>;overload;
      function SelectElements(classtype:pointer):TList<TElement>;overload;

      function SelectSingleElement(classtype:Pointer):TElement;overload;
      function SelectSingleElement(classtype:Pointer;loopchild:Boolean):TElement;overload;
      function SelectSingleElement(tagname:string):TElement;overload;
      function SelectSingleElement(tagname:string;traversechild:Boolean):TElement;overload;
      function SelectSingleElement(tagname,attrname,attrvalue:string):TElement;overload;
      function SelectSingleElement(tagname,ns:string):TElement;overload;
      function SelectSingleElement(tagname,ns:string;traversechild:Boolean):TElement;overload;


      procedure WriteStream(S: TStream); override;
      function ParseStream(P: TsdXmlParser): TElement;

  end;

implementation
uses
  ElementFactory;

{ TElement }


constructor TElement.Create( tagname: string);
begin
  Self.Create;
  Name:=tagname;
end;

constructor TElement.Create(Aowner: TNativeXml);
begin
  inherited Create(Aowner);
end;





constructor TElement.Create( tagname, tagtext, ns: string);
begin
  Self.Create();
  Name:=tagname;
  Value:=tagtext;
  Namespace:=ns;

end;

constructor TElement.Create;
begin
  if not Assigned(xmppconst.xmldoc) then
    XMPPConst.xmldoc:=TNativeXml.Create(nil);
  Self.Create(XMPPConst.xmldoc);

end;

constructor TElement.Create( tagname: string;
  tagtext: Boolean);
var
  t:string;
begin
  if(tagtext)then t:='true'else t:='false';
  Self.Create();
  Name:=tagname;
  Value:=t;
end;

constructor TElement.Create( tagname, tagtext: string);
begin
  Self.Create();
  Name:=tagname;
  Value:=tagtext;
end;

function TElement.FGetFirstNode: TXmlNode;
begin
  if NodeList.Count>0 then
    result:=NodeList.Items[0]
  else
    result:=nil;
end;

function TElement.FGetIsRootElement: Boolean;
begin
  Result:=(Parent=nil);
end;

function TElement.FGetLastNode: TXmlNode;
begin
  if NodeList.Count>0 then
    result:=NodeList.Items[NodeList.Count-1]
  else
    result:=nil;
end;

function TElement.FGetNamespace: string;
begin
  Result:=_namespace;
end;





function TElement.FGetTextBase64: string;
var
  b:Tbytes;
begin
  b:=DecodeBase64(Value);
  Result:=StringOf(b);
end;






procedure TElement.FSetNamespace(value: string);
begin
  _namespace:=value;
  //SetAttribute('xmlns',_namespace);
end;

procedure TElement.FSetTextBase64(value: string);
var
  b:tbytes;
begin
  b:=BytesOf(UTF8Encode(value));
  self.Value:=EncodeBase64(b,Length(b));
end;

{procedure TElement.FSetPrefix(value: string);
begin
  _prefix:=value;
  if(_prefix<>'')then
  begin
    Name:=_prefix+':'+Name;
    if _namespace<>'' then
    begin
      AttributeDelete(AttributeIndexByName('xmlns'));
      SetAttribute('xmlns:'+_prefix,_namespace);
    end;
  end;
end;
     }


function TElement.GetTag(tag: string): string;
begin
  Result:=GetTag(tag,False);
end;



function TElement.GetTag(tag: string; traverseChildren: Boolean): string;
var
  el:TXmlNode;
begin
  el:=_SelectElement(self,tag,traverseChildren);
  if(el<>nil)then
  Result:=el.Value
  else
  Result:='';
end;

function TElement.GetTag(clastype: Pointer): string;
var
  el:TXmlNode;
begin
  el:=_SelectElement(Self,classtype);
  if(el<>nil)then
  Result:=el.Value
  else
  Result:='';
end;



function TElement.GetTagBase64(tagname: string): string;
begin
  Result:=EncdDecd.DecodeString(GetTag(tagname));
end;

function TElement.GetTagBool(tagname: string): Boolean;
var
  el:TElement;
  s:string;
begin
  el:=_SelectElement(self,tagname);
  if(el<>nil)then
  begin
    s:= LowerCase(el.Value);
    if (s='false') or (s='0') then
      Result:=false
    else if (s='true') or (s='1') then
      Result:=True
    else
      Result:=false;
  end
  else
  Result:=false;
end;



function TElement.GetTagEnum(name: string; enumtype: PTypeInfo): integer;
var
  s:string;
begin
  s:=GetTag(name);
  if s<>'' then
  begin
    Result:=-1;
  end
  else
  begin
    Result:=GetEnumValue(enumtype,name);
  end;
end;

function TElement.GetTagInt(tagname: string): integer;
var
  el:TElement;
begin
  el:=_SelectElement(self,tagname);
  if(el<>nil)then
  Result:=StrToInt(el.Value)
  else
  Result:=0;
end;

function TElement.GetTagJid(tagname: string): TJid;
var
  s:string;
begin
  s:=GetTag(tagname);
  if(s<>'')then
    Result:=TJID.Create(s)
  else
    Result:=nil;
end;

function TElement.HasTag(tag: string): Boolean;
begin
  if(_SelectElement(self,tag)<>nil)then
    Result:=True
  else
    Result:=false;
end;



function TElement.HasTag(classtype:Pointer): Boolean;
begin
  if(_SelectElement(self,classtype)<>nil)then
    Result:=True
  else
    Result:=false;
end;

function TElement.HasTag(classtype: Pointer;
  traverseChildren: Boolean): Boolean;
begin
  if(_SelectElement(self,classtype,traverseChildren)<>nil)then
    Result:=True
  else
    Result:=false;
end;

function TElement.HasTag(tag: string; traverseChildren: Boolean): Boolean;
begin
  if(_SelectElement(self,tag,traverseChildren)<>nil)then
    Result:=True
  else
    Result:=false;
end;

function TElement.HasTagArray(arr: array of string): string;
var
  i:integer;
begin
  //if Assigned(arr) then
  begin
    for i := 0 to Length(arr) do
    begin
      if HasTag(arr[i])then
      begin
        Result:=arr[i];
        exit;
      end;
    end;
  end;
  Result:='';
end;

function TElement.HasTagEnum(enumtype: PTypeInfo): integer;
var
  i:integer;
  s:string;
  p:PTypeData;
begin
  p:=GetTypeData(enumtype);
  for i := p.MinValue to p.MaxValue do
  begin
    s:=GetEnumName(enumtype,i);
    if HasTag(s) then
    begin
      Result:=GetEnumValue(enumtype,s);
      Exit;
    end;
  end;
  Result:=-1;
end;



function TElement.ParseStream(P: TsdXmlParser): TElement;
var
  Ch: AnsiChar;
  AName: Utf8String;
  IsTrimmed: boolean;
begin
  {Result := Self;

  // Flush the reader.
  P.Flush;

  // the index of the chardata subnode that will hold the value, initially -1
  FValueIndex := -1;

  {$ifdef SOURCEPOS}
  {FSourcePos := P.Position;
  {$endif SOURCEPOS}

  // Parse name
  {AName := sdTrim(P.ReadStringUntilBlankOrEndTag, IsTrimmed);
  SetName(AName);

  DoNodeNew(Self);

  // Parse attribute list
  Ch := ParseAttributeList(P);

  // up till now attributes and optional chardata are direct nodes
  FDirectNodeCount := FNodes.Count;

  if Ch = '/' then
  begin
    // Direct tag
    Ch := P.NextChar;
    if Ch <> '>' then
    begin
      DoDebugOut(Self, wsWarn, Format(sIllegalEndTag, [Ch, P.LineNumber, P.Position]));
      exit;
    end;
    NodeClosingStyle := ncClose;
  end else
  begin
    if Ch <> '>' then
    begin
      DoDebugOut(Self, wsWarn, Format(sIllegalEndTag, [Ch, P.LineNumber, P.Position]));
      exit;
    end;

    // parse subelements
    Result := ParseElementList(P, [xeElement..xeCData, xeInstruction..xeEndTag]);
  end;

  // progress for elements
  DoProgress(P.Position);  }
end;

function TElement.RemoveTag(tag: string): Boolean;
var
  tg:TXmlNode;
begin
  tg:=_SelectElement(self,tag);
  if tg<>nil then
  begin
    tg.Delete;
    Result:=true;
  end
  else
    Result:=False;
end;

procedure TElement.RemoveAttribute(name: string);
begin
  if HasAttribute(name) then
    AttributeDelete(AttributeIndexByName(name));
end;

function TElement.RemoveTag(classtype: Pointer): Boolean;
var
  tg:TXmlNode;
begin
  tg:=_SelectElement(self,classtype);
  if tg<>nil then
  begin
    tg.Delete;
    { TODO : 需要确定删除时是否自动析构 }
    FreeAndNil(tg);
    Result:=true;
  end
  else
    Result:=False;
end;



procedure TElement.ReplaceNode(e: Telement);
begin
  if HasTag(e.Name) then
    RemoveTag(e.Name);
  NodeAdd(e);
end;

function TElement.SelectElements(tagname: string): TList<TElement>;
var
  es:TList<Telement>;
begin
  es:=tlist<TElement>.Create;
  _SelectElements(Self,tagname,es,false);
  Result:=es;
end;

function TElement.SelectElements(classtype: pointer): TList<TElement>;
var
  es:TList<Telement>;
begin
  es:=tlist<TElement>.Create;
  _SelectElements(Self,classtype,es,false);
  Result:=es;
end;

function TElement.SelectElements(tagname: string;
  traverseChildren: Boolean): TList<TElement>;
var
  es:TList<Telement>;
begin
  es:=tlist<TElement>.Create;
  _SelectElements(Self,tagname,es,traverseChildren);
  Result:=es;
end;


function TElement.SelectSingleElement(tagname: string): TElement;
begin
  Result:=_SelectElement(self,tagname);
end;

function TElement.SelectSingleElement(classtype: Pointer;
  loopchild: Boolean): TElement;
begin
  Result:=_SelectElement(self,classtype,loopchild);
end;

function TElement.SelectSingleElement(classtype: Pointer): TElement;
begin
  Result:=_SelectElement(self,classtype);
end;

function TElement.SelectSingleElement(tagname: string;
  traversechild: Boolean): TElement;
begin
  Result:=_SelectElement(self,tagname,traversechild);
end;

function TElement.SelectSingleElement(tagname, ns: string;
  traversechild: Boolean): TElement;
begin
  Result:=_SelectElement(self,tagname,ns,traversechild);
end;

function TElement.SelectSingleElement(tagname, ns: string): TElement;
begin
  Result:=_SelectElement(self,tagname,ns,True);
end;

function TElement.SelectSingleElement(tagname, attrname,
  attrvalue: string): TElement;
begin
  Result:=_SelectElement(self,tagname,attrname,attrvalue);
end;



procedure TElement.SetAttribute(name, val: string);
begin
  if HasAttribute(name) then
    AttributeDelete(AttributeIndexByName(name));
  AttributeAdd(name,val);
end;

procedure TElement.SetAttribute(name: string; val: Boolean);
begin
  if val then
    SetAttribute(name,'true')
  else
    SetAttribute(name,'false');
end;

procedure TElement.SetEnumTag(name: Integer; enumtype: PTypeInfo);
begin
  settag(GetEnumName(enumtype,name));
end;

procedure TElement.SetTag(name, value: string);
begin
  if HasTag(name) then
  begin
    SelectSingleElement(name).Value:=value;
  end
  else
    NodeAdd(TElement.Create(name,value));
end;

procedure TElement.SetTag(classtype:pointer;argText: string);
var
  newel:TElement;
begin
  if HasTag(classtype) then
    SelectSingleElement(classtype).Value:=argText
  else
  begin
    newel:=createelement(classtype);
    newel.Value:=argText;
    NodeAdd(newel);
  end
  
end;

function TElement._SelectElement(se: TElement; classtype:Pointer;
  traversechildren: Boolean): TElement;
var
  rel,ch:TElement;
  i:integer;

begin
  Result:=nil;
  if se.HasSubContainers then
  begin
    for i:=0 to se.nodelist.count-1 do
    begin

      if se.NodeList[i].ElementType=xeElement then
      begin
        ch:=TElement(se.NodeList[i]);
      if ch.ClassInfo= classtype then
      begin
        Result:=ch;
        Exit;
      end
      else
      begin
        if traversechildren then
        begin
          rel:=_selectelement(ch,classtype,traversechildren);
          if rel<>nil then
          begin
            Result:=rel;
            exit;
          end;
        end;
      end;
      end;
    end;
  end;
end;

function TElement.RemoveTags(classtype: Pointer): Boolean;
var
  el:TElement;
begin
  el:=_SelectElement(Self,classtype);
  if el<>nil then
  begin
    el.Delete;
    Result:=True;
  end
  else
    Result:=false;
end;



procedure TElement.SetTag(name, value, ns: string);
var
  el:TElement;
begin
  if HasTag(name) then
  begin
    el:=SelectSingleElement(name);
    el.Value:=value;
    el.Namespace:=ns;
  end
  else
    NodeAdd(TElement.Create(name,value,ns));
end;

procedure TElement.SetTag(classtype: pointer);
begin
  if HasTag(classtype) then
    RemoveTag(classtype);
  NodeAdd(CreateElement(document));
end;

procedure TElement.SetTag(name: string);
begin
  SetTag(name,'');
end;

procedure TElement.SetTag(name: string; val: Boolean);
begin
  if val then
    SetTag(name,'true')
  else
    SetTag(name,'false');
end;

procedure TElement.SetTag(name: string; jid: TJID);
begin
  SetTag(name,jid.ToString);
end;

procedure TElement.SetTag(name: string; val: integer);
begin
  SetTag(name,IntToStr(val));
end;

procedure TElement.SetTagBase64(name, val: string);
begin
  SetTag(name,EncodeString(val));
end;

procedure TElement.SetTagBase64(name: string; buffer: TArray<Byte>);
begin
  SetTag(name,EncodeBase64(buffer,Length(buffer)));
end;

procedure TElement.WriteStream(S: TStream);
var
  i: integer;
  SubNode: TXmlNode;
  HasSubElements: boolean;
  dircnode:integer;
begin
  // determine if there is at least one subelement
  HasSubElements := HasSubContainers;

  // write element
  if Prefix<>'' then
    sdStreamWrite(S, GetIndent + '<'+prefix+':' + GetName)
  else
    sdStreamWrite(S, GetIndent + '<' + GetName);
   if Namespace<>'' then
  begin
    if Prefix<>'' then
      sdStreamWrite(S,' xmlns:'+prefix+'="'+Namespace+'"')
    else
      sdStreamWrite(S,' xmlns'+'="'+Namespace+'"');
  end;

  // write attributes
  WriteAttributeList(S, GetDirectNodeCount);
   dircnode:=GetDirectNodeCount;
  
  if (NodeList.Count = dircnode) and (NodeClosingStyle = ncClose) then
  begin

    // directly write close tag
    sdStreamWrite(S, cDefaultDirectCloseTag);
    sdStreamWrite(S, GetEndOfLine);

  end else
  begin
    // indirect node
    sdStreamWrite(S, '>');

    // write sub-nodes
    for i := GetDirectNodeCount to NodeList.Count - 1 do
    begin
      SubNode := NodeList[i];

      // due to optional chardatas after the parent we use these ifs
      if (i = GetDirectNodeCount) and not (SubNode is TsdCharData) then
      begin
        sdStreamWrite(S, GetEndOfLine);
      end;
      if (i > GetDirectNodeCount) and (SubNode is TsdCharData) and HasSubElements then
      begin
        //sdStreamWrite(S, SubNode.GetIndent);
      end;

      if (SubNode is TsdElement) or (SubNode is TsdCharData) then
        SubNode.WriteStream(S);

      if HasSubElements and (SubNode is TsdCharData) then
        sdStreamWrite(S, GetEndOfLine);
    end;

    // endtag
    if HasSubElements then
      sdStreamWrite(S, GetIndent);
    if Prefix<>'' then
      sdStreamWrite(S, '</' + prefix+':'+GetName + '>' + GetEndOfLine)
    else
      sdStreamWrite(S, '</' + GetName + '>' + GetEndOfLine);
  end;
  if Assigned(Document.OnProgress) then
  Document.OnProgress(Document,S.Position);
end;

function TElement._SelectElement(se: Telement; tagname, namespace: string;
  traversechildren: Boolean): Telement;
var
  rel,ch:TElement;
  i:integer;
begin
  Result:=nil;
  if se.HasSubContainers then
  begin
    for i:=0 to se.nodelist.count-1 do
    begin

      if se.NodeList[i].ElementType=xeElement then
      begin
        ch:=TElement(se.NodeList[i]);
      if (ch.Name=tagname) and (ch.Namespace=namespace) then
      begin
        Result:=ch;
        Exit;
      end
      else
      begin
        if traversechildren then
        begin
          rel:=_selectelement(ch,tagname,namespace,traversechildren);
          if rel<>nil then
          begin
            Result:=rel;
            exit;
          end;
        end;
      end;
      end;
    end;
  end;
end;


function TElement._SelectElement(se: Telement; tagname, attrname,
  attrvalue: string): Telement;
var
  rel,ch:TElement;
  i:integer;
begin
  Result:=nil;
  if se.ElementType=xeElement then
  begin
    if (se.Name=tagname) and (se.AttributeValueByName[attrname]=attrvalue) then
    begin
      Result:=se;
      exit;
    end;

  end;
  if se.HasSubContainers then
  begin
    for i:=0 to se.nodelist.count-1 do
    begin
          rel:=_selectelement(ch,tagname,attrname,attrvalue);
          if rel<>nil then
          begin
            Result:=rel;
            exit;
          end;
    end;
  end;
end;

function TElement._SelectElement(se: Telement; tagname: string): Telement;
begin
  Result:=_SelectElement(se,tagname,false);
end;

function TElement._SelectElement(se: Telement; classtype: Pointer): Telement;
begin
  Result:=_SelectElement(se,classtype,false);
end;

function TElement._SelectElement(se: Telement; tagname: string;
  traversechildren: Boolean): Telement;
var
  rel,ch:TElement;
  i:integer;

begin
  Result:=nil;
  if se.HasSubContainers then
  begin
    for i:=0 to se.nodelist.count-1 do
    begin

      if se.NodeList[i].ElementType=xeElement then
      begin
        ch:=TElement(se.NodeList[i]);
      if ch.Name= tagname then
      begin
        Result:=ch;
        Exit;
      end
      else
      begin
        if traversechildren then
        begin
          rel:=_selectelement(ch,classtype,traversechildren);
          if rel<>nil then
          begin
            Result:=rel;
            exit;
          end;
        end;
      end;
      end;
    end;
  end;
end;


procedure TElement._SelectElements(se: Telement; classtype: pointer;
  const es: TList<TElement>);
begin
  _SelectElements(se,classtype,es,false);
end;

procedure TElement._SelectElements(se: Telement; classtype: pointer; const es: TList<TElement>;
  traversechildren: Boolean);
var
  i:Integer;
  ch:TElement;
begin
  if se.HasSubContainers then
  begin
    for i := 0 to se.NodeList.Count-1 do
    begin
      ch:=TElement(se.NodeList[i]);
      if ch.ElementType=xeElement then
      begin
        if (ch.ClassInfo=classtype) then
          es.Add(ch);
        if traversechildren then
          _selectelements(ch,classtype,es,True);
      end;
    end;
  end;
end;

procedure TElement._SelectElements(se: Telement; tagname: string; const es: TList<TElement>;
  traversechildren: Boolean);
var
  i:Integer;
  ch:TElement;
begin
  if se.HasSubContainers then
  begin
    for i := 0 to se.NodeList.Count-1 do
    begin
      ch:=TElement(se.NodeList[i]);
      if ch.ElementType=xeElement then
      begin
        if ch.Name=tagname then
          es.Add(ch);
        if traversechildren then
          _selectelements(ch,tagname,es,True);
      end;
    end;
  end;
end;

end.
