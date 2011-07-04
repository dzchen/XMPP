unit Xml.XmppStreamParser;

interface
uses
  NativeXml,sdDebug,SysUtils,StrUtils,ElementFactory,XMPPEvent,EventList,Element,Xml.xpnet.NS,XMPPConst,Classes,Generics.Collections;
type
  TXmppStreamParser=class(TsdXmlParser)
  private
    parser:TsdXmlParser;
    _depth:Integer;
    _root,current:TElement;
    _ns:TNS;
    _cdata:Boolean;
    FExternalBomInfo: TsdBomInfo;
    FOnStreamStart:StreamHandler;
    FOnStreamEnd:StreamHandler;
    FOnStreamElement:TEventList<StreamHandler>;
    FOnStreamError:StreamError;
    FOnError:ErrorHandler;
    function ParseAttributeList(ht:TObjectDictionary<string,string>;Parser: TsdXmlParser):AnsiChar;
    procedure ParseStream(Parser: TsdXmlParser);
    procedure ParseElement(Parser: TsdXmlParser;out parent:TElement);
    procedure ParseElementList(P: TsdXmlParser;out parent:TElement;const SupportedTags: TsdElementTypes);
    procedure ParseIntermediateData(P: TsdXmlParser;out parent:TElement);
    procedure DoRaiseOnStreamElement(el:TElement);
    procedure EndTag(el:TElement);
  public
    constructor Create;
    property OnStreamStart:StreamHandler read FOnStreamStart write FOnStreamStart;
    property OnStreamEnd:StreamHandler read FOnStreamEnd write FOnStreamEnd;
    property OnStreamElement:TEventList<StreamHandler> read FOnStreamElement write FOnStreamElement;
    property OnStreamError:StreamError read FOnStreamError write FOnStreamError;
    property OnError:ErrorHandler read FOnError write FOnError;

    property Depth:LongInt read _depth;

    procedure Reset();
    procedure Push(xml:string);

  end;

implementation

{ TXmppStreamParser }

constructor TXmppStreamParser.Create;
begin
  _ns:=TNS.Create;
  FOnStreamElement:=TEventList<StreamHandler>.Create;
end;

procedure TXmppStreamParser.DoRaiseOnStreamElement(el: TElement);
var
  i:Integer;
begin
  try
  if Assigned(FOnStreamElement) and (FOnStreamElement.Count>0) then
  begin
    for i := 0 to FOnStreamElement.Count-1 do
    FOnStreamElement[i](Self,el);
  end;

  except
  on e:Exception do
    if Assigned(FOnError) then
      FOnError(Self,e);

  end;
end;

procedure TXmppStreamParser.EndTag(el:TElement);
begin
  _ns.PopScope;
  if not Assigned(el.Parent) then
     DoRaiseOnStreamElement(el);
  //el:=TElement(el.Parent);
end;

function TXmppStreamParser.ParseAttributeList(ht:TObjectDictionary<string,string>;Parser: TsdXmlParser):AnsiChar;
var
  Blanks: Utf8String;
  name,val,prefix,tag,ns:Utf8String;
  IsTrimmed: boolean;
  FQuoteChar:AnsiChar;
  n:integer;
  WhiteSpaceNode: TsdWhiteSpace;

begin

  repeat

    Result := parser.NextCharSkipBlanks(Blanks);
    {if Length(Blanks) > 0 then
    begin
      if Blanks <> ' ' then
      begin
        DoDebugOut(Self, wsHint, Format(sNonDefaultChardata, [P.LineNumber, P.Position]));
        // add non-default blank chardata
        if GetPreserveWhiteSpace then
        begin
          WhiteSpaceNode := TsdWhiteSpace.Create(TNativeXml(FOwner));
          NodeAdd(WhiteSpaceNode);
          WhiteSpaceNode.SetValue(Blanks);
        end;
      end
    end;}
    // Are any of the characters determining the end?
    if Result in ['!', '/', '>' ,'?'] then
      exit;

    parser.MoveBack;
    name:=sdTrim(parser.ReadStringUntilChar('='), IsTrimmed);
    FQuoteChar:=parser.NextCharSkipBlanks(Blanks);
    if not (FQuoteChar in cXmlQuoteChars) then
    begin
      DoDebugOut(Self, wsWarn, Format(sQuoteCharExpected, [parser.Position]));
      exit;
    end;
    val:=parser.ReadQuotedString(FQuoteChar);

    if StartsStr('xmlns:',name) then
    begin
      n:=Pos(':',name);
      prefix:=rightstr(name,Length(name)-n);
      _ns.AddNamespace(prefix,val);
    end
    else
    if name='xmlns' then
    begin
      _ns.AddNamespace('',val);
    end
    else
      ht.Add(name,val);
  until parser.EndOfStream;
end;

procedure TXmppStreamParser.ParseElement(Parser: TsdXmlParser;out parent:TElement);
var
  Ch: AnsiChar;
  AName: Utf8String;
  IsTrimmed: boolean;
  FSourcePos:integer;
  n:integer;
  prefix,ns,attname:string;
  ht:TObjectDictionary<string,string>;
  newel:TElement;
begin

  // Flush the reader.
  Parser.Flush;
  FSourcePos := Parser.Position;
  // Parse name
  AName := sdTrim(Parser.ReadStringUntilBlankOrEndTag, IsTrimmed);
  _ns.PushScope;
  // Parse attribute list
  ht:=TObjectDictionary<string,string>.create;

  Ch := ParseAttributeList(ht,Parser);
    n:=Pos(':',AName);
  if n>0 then
  begin
    prefix:=leftstr(AName,n-1);
    AName:=RightStr(AName,Length(AName)-n);
    ns:=_ns.LookupNamespace(prefix);
  end
  else
    ns:=_ns.DefaultNamespace;

  newel:=TElementFactory.GetElement(prefix,AName,ns);
  for attname in ht.Keys do
    newel.SetAttribute(attname,ht[attname]);

  ht.Free;
  if Assigned(newel) then
  begin
  if _root=nil then
  begin
    _root:=newel;
   if Assigned(FOnStreamStart) then
     FOnStreamStart(Self,_root);
   newel:=nil;
  end
  else
  begin
    //if current<>nil then
    //    current.NodeAdd(newel);
    current:=newel;
    if parent<>nil then
      parent.NodeAdd(newel)
    else
      parent:=newel;
  end;

  if Ch = '/' then
  begin
    // Direct tag
    Ch := Parser.NextChar;
    if Ch <> '>' then
    begin
      DoDebugOut(Self, wsWarn, Format(sIllegalEndTag, [Ch, Parser.LineNumber, Parser.Position]));
      exit;
    end;
    newel.NodeClosingStyle := ncClose;
    EndTag(newel);
    exit;
  end else
  begin
    if Ch <> '>' then
    begin
      DoDebugOut(Self, wsWarn, Format(sIllegalEndTag, [Ch, Parser.LineNumber, Parser.Position]));
      exit;
    end;

    // parse subelements
    ParseElementList(Parser,newel, [xeElement..xeCData, xeInstruction..xeEndTag]);
   
  end;
  end;

end;

procedure TXmppStreamParser.Push(xml: string);
var
  astream:Tstringstream;
begin

  if not Assigned(xmldoc) then
    xmldoc:=TNativeXml.Create(nil);
  astream:=TStringStream.Create(utf8string(xml));

    Parser := TsdXmlParser.Create(AStream, cParserChunkSize);

      ParseStream(parser);

      FreeAndNil(Parser);

  astream.Free;


end;
procedure TXmppStreamParser.ParseStream(Parser: TsdXmlParser);
var
  B: AnsiChar;
  ElementType: TsdElementType;
  NodeClass: TsdNodeClass;
  Node: TXmlNode;
  StringData: Utf8String;
  CD: TsdCharData;
  {$ifdef SOURCEPOS}
  SP: int64;
  {$endif SOURCEPOS}
  IsTrimmed: boolean;
  DeclarationEncodingString: Utf8String;
  el:TElement;
  n:Integer;
begin
  xmldoc.AbortParsing := False;

  // read BOM
  Parser.ReadBOM;

  // store external bominfo for use later when writing
  FExternalBomInfo := Parser.BomInfo;
  el:=nil;
  n:=0;
  // Read next tag
  repeat
    {$ifdef SOURCEPOS}
    SP := Parser.Position;
    {$endif SOURCEPOS}
    StringData := Parser.ReadStringUntilChar('<');
    if not xmldoc.PreserveWhiteSpace then
      StringData := sdTrim(StringData, IsTrimmed);

    if length(StringData) > 0 then
    begin
      // Add chardata node
      CD := TsdCharData.Create(xmldoc);
      {$ifdef SOURCEPOS}
      CD.SourcePos := SP;
      {$endif SOURCEPOS}
      CD.Value := StringData;
      xmldoc.RootNodes.Add(CD);

    end;

    // At the end of the stream? Then stop
    if Parser.EndOfStream then
    begin


      break;
    end;
    Parser.MoveBack;

    B := Parser.NextChar;
    if B = '<' then
    begin
      // Determine tag type
      ElementType := Parser.ReadOpenTag;
      if ElementType = xeError then
      begin
        DoDebugOut(Self, wsWarn, Format(sIllegalTag, [B, Parser.Position]));
        exit;
      end;
      if ElementType=xeElement then
      begin
        ParseElement(Parser,el);
      end
      else
      begin
        if ElementType=xeEndTag then
        begin
          if (n=0) and (el=nil) then
          begin
            if Assigned(FOnStreamEnd) then
              FOnStreamEnd(self,_root);
            exit;
          end;
        end;
        NodeClass := cNodeClass[ElementType];
        if not assigned(NodeClass) then
        begin
          DoDebugOut(Self, wsWarn, Format(sUnsupportedTag,
            [cElementTypeNames[ElementType], Parser.Position]));
         Continue;
        end;
        // Create new node and add
        Node := NodeClass.Create(xmldoc);
        xmldoc.RootNodes.Add(Node);

        // The node will parse itself
        Node.ParseStream(Parser);


      // After adding nodes:
      // see if we added the declaration node
      if Node.ElementType = xeDeclaration then
      begin
        // give the parser the codepage from encoding in the declaration.
        // The .SetCodePage setter cares for the re-encoding of the chunk.
        DeclarationEncodingString := TsdDeclaration(Node).Encoding;
        Parser.Encoding := sdCharsetToStringEncoding(DeclarationEncodingString);
        Parser.CodePage := sdCharsetToCodePage(DeclarationEncodingString);

        DoDebugOut(Self, wsInfo, Format('declaration with encoding "%s" and codepage %d',
          [TsdDeclaration(Node).Encoding, Parser.CodePage]));
      end;

      // drop comments when parsing?
      if (Node.ElementType = xeComment) and xmldoc.DropCommentsOnParse then
      begin
        // drop comment on parse
        DoDebugOut(Self, wsInfo, 'option DropCommentsOnParse is true, deleting comment');
        xmldoc.RootNodes.Remove(Node);
      end;
      end;
    end;
    Inc(n);
    // Check if application has aborted parsing
  until xmldoc.AbortParsing or Parser.EndOfStream;

end;
procedure TXmppStreamParser.Reset;
begin
  _depth:=0;
  FreeAndNil(_root);
  _cdata:=false;
  _ns.Clear;
end;
procedure TXmppStreamParser.ParseElementList(P: TsdXmlParser;out parent:TElement; const SupportedTags: TsdElementTypes);
// parse the element list, the result (endnode) should be this element
var
  B: AnsiChar;
  BeginTagName, EndTagName: Utf8String;
  Tag: TsdElementType;
  NodeClass: TsdNodeClass;
  SubNode, EndNode: TXmlNode;
  Depth: integer;
  EndNodeName: Utf8String;
  DeeperNodeName: Utf8String;
  IsTrimmed: boolean;
begin
  repeat
    // Process char data
    ParseIntermediateData(P,parent);

    // Process subtags and end tag
    if P.EndOfStream then
    begin
      DoDebugOut(Self, wsFail, Format(sPrematureEnd, [P.Position]));
      exit;
    end;
    P.MoveBack;

    B := P.NextChar;
    if B = '<' then
    begin

      // Determine tag type
      Tag := P.ReadOpenTag;
      if not (Tag in SupportedTags) then
      begin
        DoDebugOut(Self, wsWarn, Format(sIllegalTag, [cElementTypeNames[Tag], P.Position]));
        exit;
      end;

      // End tag?
      if Tag = xeEndTag then
      begin
        // up front this is the end tag so the result is this node


        // Read end tag
        EndTagName := sdTrim(P.ReadStringUntilChar('>'), IsTrimmed);
        parent.NodeClosingStyle := ncFull;
        if parent.Prefix<>'' then
        EndTagName:=RightStr(EndTagName,Length(EndTagName)-Pos(':',EndTagName));
        // Check if begin and end tags match
        if parent.Name <> EndTagName then
        begin
          BeginTagName := parent.Name;

          // usually a user error with omitted direct end tag
          DoDebugOut(Self, wsWarn, Format(sBeginEndMismatch,
            [parent.Name, EndTagName, P.LineNumber, P.Position]));

          if not xmldoc.FixStructuralErrors then
            exit;

          // try to fix endtag mismatch:
          // check if there is a parent node with this name that is already parsed
          Depth := 0;
          repeat
            if assigned(parent.Parent) then
              DeeperNodeName := parent.Parent.Name
            else
              DeeperNodeName := '';

            if DeeperNodeName = EndTagName then
            begin
              // this is the parent's node name, so we must defer execution to the parent
              DoDebugOut(Self, wsHint,
                Format('parent%d = "%s", this endtag = "%s": maybe "%s" should be closed',
                [Depth, DeeperNodeName, EndTagName, parent.Name]));

              // we now break
              break;
            end;

            // move the node to a lower hierarchy
            if assigned(parent.Parent) and assigned(parent.Parent.Parent) then
            begin
              DoDebugOut(Self, wsInfo,
                Format('moving node "%s" from parent "%s" to grandparent "%s"',
                  [parent.Name, parent.Parent.Name, parent.Parent.Parent.Name]));
              parent.Parent.NodeExtract(parent);
              parent.Parent.Parent.NodeAdd(parent);
            end;

            inc(Depth);

          until Length(DeeperNodeName) = 0;

          // signal that this parser hierarchy is no longer valid


        end
        else
               EndTag(parent);
        // We're done reading this element, so we will set the capacity of the
        // nodelist to just the amount of items to avoid having overhead.

        exit;
      end;
      if Tag=xeElement then
      begin
        ParseElement(Parser,parent);
      end
      else
      begin
        // Determine node class
        NodeClass := cNodeClass[Tag];
        if not assigned(NodeClass) then
          raise Exception.CreateFmt(sUnsupportedTag, [P.Position]);

        // Create new node and add
        SubNode := NodeClass.Create(xmldoc);
        parent.NodeAdd(SubNode);


        // The node will parse itself
        EndNode := SubNode.ParseStream(P);
      end;
      if EndNode <> SubNode then
      begin
        if assigned(EndNode) then
          EndNodeName := EndNode.Name
        else
          EndNodeName := 'nil';
        DoDebugOut(Self, wsWarn, Format(sLevelMismatch,
          [SubNode.Name, EndNodeName, P.LineNumber, P.Position]));

        Exit;
      end;


    end else
    begin
      // Since this virtual proc is also used for doctype parsing.. check
      // end char here
      if (B = ']') and (parent.ElementType = xeDocType) then
        break;
    end;
  until xmldoc.AbortParsing or P.EndOfStream;
end;

procedure TXmppStreamParser.ParseIntermediateData(P: TsdXmlParser;out parent:TElement);
var
  CharDataString: Utf8String;
  CharDataNode: TsdCharData;
  SourcePos: int64;
  IsTrimmed: boolean;
begin
  SourcePos := P.Position;

  CharDataString := P.ReadStringUntilChar('<');
  //if not current.PreserveWhiteSpace then
  //  CharDataString := sdTrim(CharDataString, IsTrimmed);

  if length(CharDataString) > 0 then
  begin
    // Insert CharData node
    {CharDataNode := TsdCharData.Create(xmldoc);
    CharDataNode.SourcePos := SourcePos;
    CharDataNode.Value := CharDataString;
    current.NodeAdd(CharDataNode);
    }
    //current.Value:=CharDataString;
    parent.Value:=CharDataString;
  end;
end;
end.
