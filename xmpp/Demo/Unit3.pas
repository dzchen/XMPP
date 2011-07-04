unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Xml.xpnet.BufferAggregate,util.Random,ZLib;

type
  TForm3 = class(TForm)
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    btn4: TButton;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
  private
    { Private declarations }
    procedure grow(var n:tarray<Integer>);
    function test:string;
    function testT<T:class>(c:TForm3):T;
  public
    { Public declarations }
  end;
  t1form3=class(TForm3)

  end;

var
  Form3: TForm3;

implementation

uses xmppconntest, Unit4,main,SecHash,IdHashMessageDigest,IdCoderMime,IdHash,StringUtils,bind,jid,Element,Xml.XmppStreamParser,Auth;

{$R *.dfm}

procedure TForm3.btn1Click(Sender: TObject);
begin
  form2:=TForm2.Create(Self);
  Form2.show;
  form4:=TForm4.Create(self);
  //Form4.Show;
end;

procedure TForm3.btn2Click(Sender: TObject);
var
  bind:Tbind;
  el,el2:Telement;
  s:string;
  pare:TXmppStreamParser;
  auth:TAuth;
begin
  auth:=TAuth.Create;
  auth.Username:='90002';
  auth.Password:='123';
  auth.Username:='90002';
  auth.Password:='123';
  s:='<stream:stream xmlns:stream="http://etherx.jabber.org/streams" from="disha.com.cn" xml:lang="en" id="e738e5be" version="1.0" >';
  s:=s+'<a><b><c t=1></c></b></a>';
  pare:=TXmppStreamParser.Create;
  s:='<stream:stream xmlns:stream="http://etherx.jabber.org/streams" from="disha.com.cn" xml:lang="en" id="e738e5be" version="1.0" >';
  pare.Push(s);
  s:='<a><b><c t=1></c></b></a>';
  pare.Push(s);
end;

procedure TForm3.btn3Click(Sender: TObject);
var
 s:string;
 bt,ot:tbytes;
 n:integer;
 sec:TSecHash;
 v:TGUID;
begin
  V := TGUID.NewGuid;
  s:=StringReplace(v.tostring,'{','',[rfIgnoreCase]);
  s:=StringReplace(s,'}','',[rfIgnoreCase]);
  MessageDlg('',tmsgdlgtype.mtError,[mbYes,mbNo],0);
  s:=TSecHash.Sha1Hash('测试');
  s:=TSecHash.Sha1Hash('test');
  s:='迪沙会议室';
  s:='<stream:stream xmlns:stream="http://etherx.jabber.org/streams" from="disha.com.cn" xml:lang="en" id="e738e5be" version="1.0" >';
  s:=UTF8Encode(s);
  bt:=BytesOf(s);
  bt:=TEncoding.UTF8.GetBytes(s);
  //s:=#$B5#$CF'ɳ'#$BB#$E1#$D2#$E9#$CA#$D2;
    bt:=ZCompressstr(s);
    s:=ZDecompressStr(bt);
end;

procedure TForm3.btn4Click(Sender: TObject);
var
frm:Tform1;
begin
  frm:=Tform1.Create(Self);
  frm.show;
end;

procedure TForm3.grow(var n: tarray<Integer>);
var
  i:integer;
  ar:tarray<Integer>;
begin


  SetLength(n,Length(n)shl 1);

end;

function TForm3.test: string;
var
s:TStringBuilder;
s1:string;
begin
s:=TStringBuilder.Create;
s.Append('fsfsd');
s.Append(1);
s1:=s.ToString;
Result:=s.ToString;
s.Free;
s:=nil;
end;

function TForm3.testT<T>(c: TForm3): T;
begin
  Result:=c as T;
end;

end.
