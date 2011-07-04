unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,jid,TypInfo,Delay,Event,Presence,Generics.Collections
  ,Element,Email,IdSocks, ComCtrls;

type

  testenum=(t1,t2);
  TForm1 = class(TForm)
    btn1: TButton;
    edt1: TEdit;
    edt2: TEdit;
    btn2: TButton;
    btn3: TButton;
    btn4: TButton;
    btn5: TButton;
    mmo1: TMemo;
    btn6: TButton;
    btn7: TButton;
    btn8: TButton;
    btn9: TButton;
    redt1: TRichEdit;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    function GetTagEnum(name:string;pt:PTypeInfo):integer;
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure btn7Click(Sender: TObject);
    procedure btn8Click(Sender: TObject);
    procedure btn9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  item,NativeXml,EncdDecd,vcard,Address,testnode,SecHash;

{$R *.dfm}

procedure TForm1.btn1Click(Sender: TObject);
begin
  //testnode.sss:='dsdfs';
  edt2.Text:=TJID.applyJEP106(edt1.Text);
end;

procedure TForm1.btn2Click(Sender: TObject);
var
  sec:TSecHash;
  bt:TByteDigest;
  s:string;
  us:UTF8String;
begin
  //s:=TNativeXml.EncodeBase64(UTF8Encode('≤‚ ‘'));
  sec:=TSecHash.Create(nil);
  //s:=EncodeString(UTF8Encode('≤‚ ‘'));
  //us:=UTF8Encode('≤‚ ‘');
  //bt:=sec.IntDigestToByteDigest(sec.ComputeString(UTF8Encode('test')));
  bt:=sec.IntDigestToByteDigest(sec.ComputeString(UTF8Encode('≤‚ ‘')));
  ShowMessage(EncodeBase64(@bt,SizeOf(bt)));
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  dir:TItem;
  doc:TNativeXml;
  mem,mem2:TStringStream;
  en:TEncoding;
  buf:tbytes;
  s:string;

begin
  {doc:=TNativeXml.Create(nil);
  dir:=TItem.Create(doc);
  dir.ItemName:='test';
  dir.Value:='sdfsfsdfsf';
  ShowMessage(dir.WriteToString);
  doc.Free;      }

  //mem2:=TStringStream.Create;
  //mem:=TStringStream.Create('test');
  //DecodeStream(mem,mem2);
  s:='test';
  buf:=DecodeBase64(s);
  s:=EncodeBase64(buf,Length(buf));
  ShowMessage(s);
  ShowMessage(IntToStr(buf[0]));
  //DecodeBase64Buf('test',buf,Length('test'));

end;



procedure TForm1.btn4Click(Sender: TObject);
begin

  //ShowMessage(GetEnumName(TypeInfo(testenum),GetTagEnum<testenum>('t1')));
 ShowMessage(GetEnumName(TypeInfo(testenum),GetTagEnum('t1',TypeInfo(testenum))));
end;

procedure TForm1.btn5Click(Sender: TObject);
var
  vc:tvcard;
  doc:TNativeXml;
  addr,addr2,tempaddr:Taddress;
  al:Tlist;
  pres:TPresence;
  fs:TFormatSettings;
  td:TXmlNode;
  i:integer;
  em,temp:TEmail;
  ift:TFormatSettings;
begin
td:=nil;
doc:=TNativeXml.Create(nil);
  vc:=TVcard.Create();
  vc.Fullname:='chenjianzhi';
  fs.ShortDateFormat:='yyyy-mm-dd';
  fs.DateSeparator:='-';

  vc.Birthday:=StrToDate('2010-07-07',fs);
  addr:=TAddress.CreateAddress(AddressLocation[1],'Suite 600','1899 Wynkoop Street','Denver','CO','80202','USA',true);

  addr2:=TAddress.CreateAddress(AddressLocation[1],'Suite 610','1899 Wynkoop Street','Denver','CO','80202','USA',true);
  addr.NodeAdd(addr2);
  em:=TEmail.CreateEmail('pop','ddddd);',True);

  addr2.NodeAdd(em);
  vc.AddAddress(addr);
  //td:=TEmail(vc._selectelement(vc,TEmail.ClassInfo,true));
  if td<>nil then

  ShowMessage(td.WriteToString);
  for i:=0 to vc.ChildContainerCount-1 do
  begin
    if vc.ChildContainers[i] is TAddress then
      ShowMessage('address');
  end;
  i:=0;
  td:=nil;
  //addr:=TAddress.Create(doc);
  i:=vc.NodeIndexOf(addr);
  if Assigned(td) and (td is TVcard) then
    ShowMessage('Vcard');
  ShowMessage(vc.WriteToString);
  mmo1.Text:=vc.WriteToString;
  doc.Free;
  //FreeAndNil();
end;

procedure TForm1.btn6Click(Sender: TObject);
var
  s:string;
  s1:UTF8String;
begin
  s:='≤‚ ‘';
  s1:='≤‚ ‘2';
  redt1.Lines.Append(s);
  redt1.Lines.Append(s1);
  s:=s1;
  s:=s+'sss';
  redt1.Lines.Append(s);
end;

procedure TForm1.btn7Click(Sender: TObject);
var
  doc:TNativeXml;
  cd,nd:TElement;

begin
  nd:=TElement.Create(doc);
  cd:=TElement.Create(doc);

  cd.nodeadd(TElement.Create(doc));
  nd.nodeadd(cd);
end;

procedure TForm1.btn8Click(Sender: TObject);
var
  doc:TNativeXml;
  cd,nd:TNode;

begin
  nd:=TNode.Create();
  cd:=TNode.Create();
  cd.add(TNode.Create());
  nd.add(cd);
end;

procedure TForm1.btn9Click(Sender: TObject);
var
  e1,e2:TList<Tnode>;
  e,temp:Tnode;
begin
  e1:=tlist<tnode>.create;
  e2:=tlist<tnode>.create;
  e:=Tnode.Create;
  e.txt:='dddddd';
  e1.Add(e);
  e.txt:='sss';
  e2.Add(e);
  temp:=e2.Items[0];
  //e2.Free;
  //e1.Free;
 
end;

function TForm1.GetTagEnum(name: string;pt:ptypeinfo): integer;
begin
//
  result:=GetEnumValue(pt,name);
end;

end.
