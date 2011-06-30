unit xmltestmain;

interface

uses
  Classes, Controls, SysUtils, StdCtrls, Forms, Dialogs, Menus, Windows,
  //for comparison
  NativeXmlOld,
  // NativeXml component
  NativeXml, sdDebug;

type
  TfrmMain = class(TForm)
    mmDebug: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    mnuParse: TMenuItem;
    mnuParseCanonical: TMenuItem;
    est1: TMenuItem;
    mnuTest1: TMenuItem;
    N1: TMenuItem;
    mnuExit: TMenuItem;
    mnuTest2: TMenuItem;
    mnuTest3: TMenuItem;
    mnuTest4: TMenuItem;
    mnuTest5: TMenuItem;
    mnuTest6: TMenuItem;
    mnuTest7: TMenuItem;
    mnuTest8: TMenuItem;
    mnuTest9: TMenuItem;
    mnuTest10: TMenuItem;
    mnuTest11: TMenuItem;
    mnuTest12: TMenuItem;
    mnuTest13: TMenuItem;
    mnuTest14: TMenuItem;
    mnuTest15: TMenuItem;
    mnuTest16: TMenuItem;
    Test171: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuParseClick(Sender: TObject);
//    procedure mnuParseCanonicalClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuTest1Click(Sender: TObject);
    procedure mnuTest2Click(Sender: TObject);
    procedure mnuTest3Click(Sender: TObject);
    procedure mnuTest4Click(Sender: TObject);
    procedure mnuTest5Click(Sender: TObject);
    procedure mnuTest6Click(Sender: TObject);
    procedure mnuTest7Click(Sender: TObject);
    procedure mnuTest8Click(Sender: TObject);
    procedure mnuTest9Click(Sender: TObject);
    procedure mnuTest10Click(Sender: TObject);
    procedure mnuTest11Click(Sender: TObject);
    procedure mnuTest12Click(Sender: TObject);
    procedure mnuTest13Click(Sender: TObject);
    procedure mnuTest14Click(Sender: TObject);
    procedure mnuTest15Click(Sender: TObject);
    procedure mnuTest16Click(Sender: TObject);
    procedure Test171Click(Sender: TObject);
  private
    FXml: TNativeXml;
    procedure XmlNodeNew(Sender: TObject; ANode: TXmlNode);
    procedure XmlNodeLoaded(Sender: TObject; ANode: TXmlNode);
    procedure XmlDebug(Sender: TObject; WarnStyle: TsdWarnStyle; const AMessage: Utf8String);
    function WriteNodeList(AList: TsdNodeList): Utf8String;
  public
    // testing procedures for user questions
    procedure WriteToXMLNode(aDeep, aWriteEmpty: Boolean; aNode: TXmlNode; aNodeName: string);
    function WriteToXMLString(aDeep: Boolean; aWriteEmpty: Boolean; aNodeName: string): string;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FXml := TNativeXml.Create(Self);
  mmDebug.Clear;
  FXml.OnNodeNew := XmlNodeNew;
  FXml.OnNodeLoaded := XmlNodeLoaded;
  FXml.OnDebugOut := XmlDebug;
end;

procedure TfrmMain.FormDestroy;
begin
  FXml.Free;
end;


function TfrmMain.WriteNodeList(AList: TsdNodeList): Utf8String;
var
  i: integer;
begin
  for i := 0 to AList.Count - 1 do
  begin
    Result := Result + Format('type=%s name=%s value=%s depth=%d',
      [AList[i].ElementTypeName, AList[i].Name, AList[i].Value, AList[i].TreeDepth]);
  end;
end;

procedure TfrmMain.XmlNodeLoaded(Sender: TObject; ANode: TXmlNode);
begin
  mmDebug.Lines.Add(
    Format('loaded: type "%s" level %d, name "%s", value "%s", subnodes: %d',
     [ANode.ElementTypeName, ANode.TreeDepth, ANode.Name, ANode.Value, ANode.NodeCount]));
end;

procedure TfrmMain.XmlNodeNew(Sender: TObject; ANode: TXmlNode);
begin
  mmDebug.Lines.Add(
    Format('new: type "%s" level %d', [ANode.ElementTypeName, ANode.TreeDepth]));
end;

procedure TfrmMain.mnuParseClick(Sender: TObject);
begin
  FXml.Clear;
  FXml.OnNodeNew := nil;
  FXml.OnNodeLoaded := nil;
  FXml.OnDebugOut := XmlDebug;
//  FXml.LoadFromFile('..\..\xml_test_files\basic_unicode.xml');
//  FXml.LoadFromFile('..\..\xml_test_files\CDATA_section.xml');
//  FXml.LoadFromFile('..\..\xml_test_files\sample_with_entity_references.svg');

  FXml.XmlFormat := xfReadable;
  FXml.IndentString := '';
  FXml.EolStyle := esWindows;
  //FXml.PreserveWhiteSpace := True;
  //FXml.FixStructuralErrors := True;
  FXml.LoadFromFile('..\..\..\..\..\..\admin\simdesign\registrations\mailgroup\abc-view.xml');

  mmDebug.Lines.Add('done');

  FXml.ExternalEncoding := seUtf8;
  FXml.SaveToFile('output.xml');
  mmDebug.Lines.Add('done');
end;

{procedure TfrmMain.mnuParseCanonicalClick(Sender: TObject);
var
  C14n: TNativeXmlC14n;
begin
  FXml.LoadFromFile('..\..\xml_test_files\sample_with_entity_references.svg');

  C14N := TNativeXmlC14N.Create(Self);
  try
    C14N.CanonicalizeXml(FXml);
  finally
    C14N.Free;
  end;

  FXml.XmlFormat := xfReadable;
  FXml.SaveToFile('output.xml');
end;}

procedure TfrmMain.mnuExitClick(Sender: TObject);
begin
  FXml.AbortParsing := True;
end;

procedure TfrmMain.XmlDebug(Sender: TObject; WarnStyle: TsdWarnStyle; const AMessage: Utf8String);
begin
  mmDebug.Lines.Add(Format('%s: [%s] %s', [Sender.ClassName, cWarnStyleNames[WarnStyle], AMessage]))
end;

procedure TfrmMain.WriteToXMLNode(aDeep, aWriteEmpty: Boolean; aNode: TXmlNode; aNodeName: string);
var
  PERSONNUM1: integer;
begin
  PERSONNUM1 := 1234;
  aNode.Name := aNodeName;
  with aNode do
  begin
    if aWriteEmpty or (PERSONNUM1<> 0) then WriteInteger('PERSONNUM1', PERSONNUM1);
    {...}
  end;
  if not aWriteEmpty then aNode.DeleteEmptyNodes;
end;

function TfrmMain.WriteToXMLString(aDeep, aWriteEmpty: Boolean; aNodeName: string): string;
var
  lXMLDoc: TNativeXml;
begin
  lXMLDoc := TNativeXml.Create(nil);
  WriteToXMLNode(aDeep, aWriteEmpty, lXMLDoc.Root, aNodeName);
  lXMLDoc.XmlFormat := xfReadable;
  Result := lXMLDoc.Root.WriteToString;
  lXMLDoc.Free;
end;

procedure TfrmMain.mnuTest1Click(Sender: TObject);
var
  FS: TFileStream;
  Str: Utf8String;
begin
  Str := WriteToXMLString(False, True, 'bla');
  FS := TFileStream.Create('testdata.xml', fmCreate);
  FS.Write(Str[1], length(Str));
  FS.Free;
end;

procedure TfrmMain.mnuTest2Click(Sender: TObject);
var
  Xml: TNativeXml;
begin
//
  Xml := TNativeXml.CreateName('root');
  try
    Xml.EolStyle := esWindows;
    Xml.XmlFormat := xfReadable;
    with Xml.Root.NodeNew('ThisNodeOK') do
      begin
        Value := 'This text is OK';
      end;
    with Xml.Root.NodeNew('BadNode') do
      begin
        Value := 'The second line is OK' + #13 + 'Lines separated by #13 only';
      end;
    with Xml.Root.NodeNew('BadNode') do
      begin
        Value := 'The third line' + #13#10 + 'Gets the penultimate character doubled';
      end;
    // Send the XML to the Queue
    mmDebug.Lines.Add(Xml.WriteToString);

  finally
    Xml.Free;
  end;
end;

procedure TfrmMain.mnuTest3Click(Sender: TObject);
var
  Xml: TNativeXml;
  DatBirth: TDateTime;
  Year, Month, Day, Hour, Mn, Sec, Msec: word;
begin
//
  Xml := TNativeXml.CreateName('root');
  try
    DatBirth := EncodeDate(2011, 1, 31) + EncodeTime(13, 59, 0, 0) ;
    Xml.Root.WriteDateTime('DATBIRTH', DATBIRTH);
    DatBirth := Xml.Root.ReadDateTime('DATBIRTH', 0);
    DecodeDate(DatBirth, Year, Month, Day);
    DecodeTime(DatBirth, Hour, Mn, Sec, Msec);


    // Send the XML to the Queue
    mmDebug.Lines.Add(Xml.WriteToString);
    mmDebug.Lines.Add(Format('year=%d, month=%d, day=%d, hour=%d, min=%d, sec=%d',
      [Year, Month, Day, Hour, Mn, Sec]));

  finally
    Xml.Free;
  end;
end;

procedure TfrmMain.mnuTest4Click(Sender: TObject);
var
  Xml: TNativeXml;
begin
  Xml := TNativeXml.CreateName('root');
  try
    Xml.Root.NodesAdd([

      //a comment node
      Xml.NodeNewTextType('AComment1', 'My comment', xeComment)

    ]);
    mmDebug.Lines.Add(Xml.WriteToString);
  finally
    Xml.Free;
  end;
end;

procedure TfrmMain.mnuTest5Click(Sender: TObject);
var
  Xml: TNativeXml;
begin
  Xml := TNativeXml.CreateName('root');
  try
    Xml.Root.AttributeAdd('Length', '1''0"');
    mmDebug.Lines.Add(Xml.WriteToString);
    mmDebug.Lines.Add(Xml.Root.AttributeByName['Length'].Value);
  finally
    Xml.Free;
  end;
end;

procedure TfrmMain.mnuTest6Click(Sender: TObject);
var
  lXMLDoc: TNativeXml;
  lstr: Utf8String;
begin
  lXMLDoc := TNativeXml.CreateName('test');
  lXMLDoc.Root.NodeNew('node1').Value:= sdAnsiToUtf8('e(šc(r(žýáíé', 1250);
  lXMLDoc.XmlFormat := xfReadable;
  lXMLDoc.Root.NodesAdd([ lXMLDoc.NodeNewText('node2','hi') ]);
  lstr := lXMLDoc.WriteToString;

  FreeAndNil(lXMLDoc);
  lXMLDoc:= TNativeXml.Create(nil);
  lXMLDoc.ReadFromString(lStr);

  ShowMessage(sdUtf8ToAnsi(lXMLDoc.Root.NodeByName('node1').Value, 1250));

  lXMLDoc.Free;

end;

procedure TfrmMain.mnuTest7Click(Sender: TObject);
var
  lXMLDoc: TNativeXml;
begin
  lXMLDoc := TNativeXml.CreateName('root');
  lXMLDoc.Root.NodeNew('node1').Value:= sdAnsiToUtf8('e(šc(r(žýáíé', 1250);
  lXMLDoc.XmlFormat := xfReadable;
  lXMLDoc.Root.NodesAdd([ lXMLDoc.NodeNewText('node2','hi') ]);
  lXMLDoc.ExternalEncoding := seUTF16BE;
  lXMLDoc.SaveToFile('testUTF16BE.xml');

  lXMLDoc.Free;
end;

procedure TfrmMain.mnuTest8Click(Sender: TObject);
var
  Xml: TNativeXml;
begin
  Xml := TNativeXml.CreateName('root');
  try
    Xml.Root.NodesAdd([
      Xml.NodeNewTextAttr('parent', 'somevalue', [],
        [Xml.NodeNew('child1'), Xml.NodeNew('child2'), Xml.NodeNew('child3')]
      )]);

    Xml.XmlFormat := xfReadable;
    Xml.SaveToFile('parentchild.xml');
    mmDebug.Lines.Add(Xml.WriteToString);

    mmDebug.Lines.Add(Format('%d childcontainers', [Xml.Root.NodeByName('parent').ChildContainerCount]));

  finally
    Xml.Free;
  end;
end;

procedure TfrmMain.mnuTest9Click(Sender: TObject);
var
  Xml: TNativeXml;
begin
  Xml := TNativeXml.CreateName('root');
  try
    // test WriteAttributeInteger/Float/String/DateTime/Bool
    Xml.Root.WriteAttributeInteger('name1', 5, 0);
    Xml.Root.WriteAttributeFloat('name2', 5.5, 0);
    Xml.Root.WriteAttributeString('name3', 'bla', '');
    Xml.Root.WriteAttributeDateTime('name4',
      sdStringToDateTime('2011-02-11 09:04:33'), sdStringToDateTime('2011-02-11 09:04:32'));
    Xml.Root.WriteAttributeBool('name5',True, False);

    Xml.XmlFormat := xfReadable;
    mmDebug.Lines.Add(Xml.WriteToString);
  finally
    Xml.Free;
  end;
end;

{$ifdef useNativeXmlOld}
procedure TfrmMain.mnuTest10Click(Sender: TObject);
var
  Xml: TNativeXml;
  XmlOld: TNativeXmlOld;
  i: integer;
begin
//
  Xml := TNativeXml.CreateName('root');
  XmlOld := TNativeXmlOld.CreateName('root');

  //
  for i := 1 to 5 do
  begin
    Xml.Root.WriteString('Freetext', Format('Line %d', [i]));
    XmlOld.Root.WriteString('Freetext', Format('Line %d', [i]));
  end;

  mmDebug.Lines.Add(Xml.WriteToString);
  mmDebug.Lines.Add(XmlOld.WriteToString);


  Xml.Free;
  XmlOld.Free;
end;
{$else}
procedure TfrmMain.mnuTest10Click(Sender: TObject);
begin
end;
{$endif}

procedure TfrmMain.mnuTest11Click(Sender: TObject);
var
  Xml: TNativeXml;
begin
  Xml := TNativeXml.CreateName('description');
  try
    Xml.Root.NodesAdd([

      //freetext nodes
      Xml.NodeNewText('freetext', 'line 1'),
      Xml.NodeNewText('freetext', 'line 2'),
      Xml.NodeNewText('freetext', 'line 3')

    ]);

    Xml.XmlFormat := xfReadable;
    mmDebug.Lines.Add(Xml.WriteToString);
  finally
    Xml.Free;
  end;
end;

procedure TfrmMain.mnuTest12Click(Sender: TObject);
var
  Xml: TNativeXml;
  Res1: boolean;
  NL: TsdNodeList;
begin
  Xml := TNativeXml.CreateName('description');
  try
    NL := TsdNodeList.Create(False);
    Xml.Root.NodesAdd([

      //freetext nodes
      Xml.NodeNewTextAttr('freetext', 'line1',
       [Xml.AttrText('bla1', '1')]),
      Xml.NodeNewTextAttr('freetext', 'line1',
       [Xml.AttrText('bla1', '2')]),
      Xml.NodeNewText('freetext', 'line2'),
      Xml.NodeNewText('freetext', 'line3')

    ]);

    Xml.XmlFormat := xfReadable;

    Res1 := Xml.Root.Nodes[0].IsEqualTo(Xml.Root.Nodes[1],
      [xcNodeName, xcAttribValues], NL);
    mmDebug.Lines.Add(Format('name compare = %d', [integer(Res1)]));
//    mmDebug.Lines.Add(Xml.WriteToString);
    mmDebug.Lines.Add(WriteNodeList(NL));
    NL.Free;
  finally
    Xml.Free;
  end;
end;

procedure TfrmMain.mnuTest13Click(Sender: TObject);
var
  FileName: string;
  XmlNew: TNativeXml;
  XmlOld: TNativeXmlOld;
  Tick1, Tick2, Tick3: longword;
  FS: TFileStream;
  FileSize: int64;
  // local
  procedure RunStats(Name: string; Size: int64; Ticks: longword);
  begin
    mmDebug.Lines.Add(Format('%s: %d ms for %d bytes, %3.2f Mb/sec',
      [Name, Ticks, Size, Size / (Ticks * 1000)]));
  end;
begin
  // compare parsing speed of TNativeXml and TNativeXmlOld
  FileName := 'c:\trunk\admin\simdesign\registrations\mailgroup\abc-view.xml';
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    FileSize := FS.Size;
  finally
    FS.Free;
  end;

  XmlNew := TNativeXml.Create(nil);
  XmlOld := TNativeXmlOld.Create;
  try
    Tick1 := GetTickCount;
    mmDebug.Lines.Add('starting run 1');
    XmlNew.LoadFromFile(FileName);
    Tick2 := GetTickCount;
    mmDebug.Lines.Add('starting run 2');
    XmlOld.LoadFromFile(FileName);
    Tick3 := GetTickCount;
    mmDebug.Lines.Add('finished');

    RunStats('NativeXml 3.2x', FileSize, Tick2 - Tick1);
    RunStats('NativeXml 3.10', FileSize, Tick3 - Tick2);
  finally
    XmlNew.Free;
    XmlOld.Free;
  end;
end;

procedure TfrmMain.mnuTest14Click(Sender: TObject);
var
  myxml: TNativeXml;
  myxml2: TNativeXmlOld;
begin
  myxml:=TNativeXML.Create(nil);
  myxml.OnDebugOut := XmlDebug;
  myxml.LoadFromFile('test.xml');
  myxml.XmlFormat:=xfReadable; // just for better readability. the problem occures without this, too
  myxml.SaveToFile('out1.xml');
  myxml.Free;
  myxml2:=TNativeXMLOld.Create();
  myxml2.LoadFromFile('test.xml');
  myxml2.XmlFormat:=xfoReadable; // just for better readability. the problem occures without this, too
  myxml2.SaveToFile('out2.xml');
  myxml2.Free;
end;

procedure TfrmMain.mnuTest15Click(Sender: TObject);
var
  Xml: TNativeXml;
  DocType: TsdDocType;
begin
  Xml := TNativeXml.CreateName('root');
  Xml.XmlFormat := xfReadable;
  {old method
  DocType := TsdDocType.Create(Xml);
  DocType.Name := 'blabla';
  DocType.ExternalId.Value := 'SYSTEM';
  DocType.SystemLiteral.Value := 'blabla.dtd';
  Xml.RootNodes.Insert(1, DocType);}

  // new method
  DocType := Xml.InsertDocType('blabla');
  DocType.SystemLiteral.Value := 'blabla.dtd';

  mmDebug.Lines.Add(Xml.WriteToString);
  Xml.Free;
end;

procedure TfrmMain.mnuTest16Click(Sender: TObject);
var
  S, E, R: Utf8String;
begin
// sdEscapeString and sdReplaceString

//  S := 'Hi & there, "miaw"';
//  S := 'Hi & there, <miaw>';
  S := 'Osia;gnie;to <%B>';
//  S := 'Hi &copy; there, miaw &quot;';

  mmDebug.Lines.Add('original:');
  mmDebug.Lines.Add(S);
  mmDebug.Lines.Add('escaped:');
  E := sdEscapeString(S);
  mmDebug.Lines.Add(E);
  mmDebug.Lines.Add('replaced:');
  R := sdReplaceString(E);
  mmDebug.Lines.Add(R);
end;

procedure TfrmMain.Test171Click(Sender: TObject);
var
  Xml: TNativeXml;
begin
  Xml := TNativeXml.Create(nil);
  Xml.OnDebugOut := XmlDebug;
  try
    Xml.LoadFromFile('..\..\xml_test_files\error.xml');
//    Xml.LoadFromFile('..\..\xml_test_files\comments.xml');
  finally
    Xml.Free;
  end;
end;

end.
