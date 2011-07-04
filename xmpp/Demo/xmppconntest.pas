unit xmppconntest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,protocol.iq.roster.RosterItem,Element,Presence,IQ,Message,
  IdBaseComponent, IdAntiFreezeBase, IdAntiFreeze,Xml.XmppStreamParser, ComCtrls;

type
  TForm2 = class(TForm)
    edt1: TEdit;
    edt2: TEdit;
    btn1: TButton;
    mmo1: TMemo;
    btn2: TButton;
    btn3: TButton;
    mmo2: TMemo;
    btn4: TButton;
    redt1: TRichEdit;
    cbb1: TComboBox;
    btn5: TButton;
    btn6: TButton;
    mmo3: TMemo;
    edt3: TEdit;
    btn7: TButton;
    mmo4: TMemo;
    chk1: TCheckBox;
    btn8: TButton;
    dlgSave1: TSaveDialog;
    flpndlg1: TFileOpenDialog;
    btn9: TButton;
    procedure btn1Click(Sender: TObject);
    procedure ClientSocket_OnReceive(sender:TObject;bt:TBytes;len:integer);
    procedure XmppCon_OnReadXml(sender:TObject;xml:string);
    procedure XmppCon_OnWriteXml(sender:TObject;xml:string);
    procedure XmppCon_OnRosterStart(sender:TObject);
    procedure XmppCon_OnRosterEnd(sender:TObject);
    procedure XmppCon_OnRosterItem(sender:TObject;item:TRosterItem);
    procedure XmppCon_OnLogin(sender:TObject);
    procedure XmppCon_OnAuthError(sender:TObject;e:TElement);
    procedure XmppCon_OnPresence(sender:TObject;pres:TPresence);
    procedure XmppCon_OnIQ(sender:TObject;iq:TIQ);
    procedure XmppCon_OnMessage(sender:TObject;msg:TMessage);
    procedure XmppCon_OnClose(sender:TObject);
    procedure XmppCon_OnError(sender:TObject;ex:Exception);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DiscoServer();
    procedure OnDiscoServerResult(sender:TObject;iq:TIQ;data:TElement);
    procedure OnDiscoInfoResult(sender:TObject;iq:TIQ;data:TElement);
    procedure btn6Click(Sender: TObject);
    procedure btn7Click(Sender: TObject);
    procedure MessageCallback(sender:TObject;msg:TMessage;data:string);
    procedure IncomingMessage(msg:TMessage);
    procedure OutgoingMessage(msg:TMessage);
    procedure btn8Click(Sender: TObject);
    procedure btn9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
implementation
uses
 main,XmppClientConnection,jid,protocol.iq.disco.DiscoInfo,protocol.iq.disco.DiscoIdentity,protocol.iq.disco.DiscoFeature
 ,XmppUri,xmppconst,protocol.iq.disco.DiscoManager,testinit,NativeXml,Xml.StreamParser,protocol.iq.disco.DiscoItems,protocol.iq.disco.DiscoItem,Generics.Collections,
  Unit4,protocol.extensions.si,protocol.extensions.filetransfer,JEP65Socket,FileGrabber;
 var
  connection:TXmppClientConnection;
  discomanager:TDiscoManager;
  curfileiq:Tiq;
{$R *.dfm}

procedure TForm2.btn1Click(Sender: TObject);
var

  jid:TJid;

begin
  jid:=TJID.Create(edt1.Text);
  connection.Server:=jid.domain;
  connection.UserName:=jid.user;
  connection.Password:=edt2.Text;
  connection.Resource:='dx';
  connection.Priority:=6;
  connection.Port:=5222;
  connection.UseSSL:=false;
  connection.AutoResolveConnectServer:=true;
  connection.UseCompression:=False;

  connection.EnableCapabilities:=true;
  connection.ClientVersion:='0.1';
  connection.Capabilities.Node:='http://www.ag-software.de/delphi/caps';

  connection.DiscoInfo.AddIdentity(TDiscoIdentity.Create('pc', 'MiniClient', 'client'));

            connection.DiscoInfo.AddFeature(TDiscoFeature.Create(xmlns_DISCO_INFO));
            connection.DiscoInfo.AddFeature(TDiscoFeature.Create(xmlns_DISCO_ITEMS));
            connection.DiscoInfo.AddFeature(TDiscoFeature.Create(xmlns_MUC));


 connection.Open;
  connection.MessageGrabber.add(tjid.Create(edt3.Text),MessageCallback,'');
end;

procedure TForm2.btn2Click(Sender: TObject);
var
  t:Ttestinit;
begin
  connection.Send('<stream:stream to=''disha.com.cn'' xmlns=''jabber:client'' xmlns:stream=''http://etherx.jabber.org/streams'' version=''1.0'' xml:lang=''en''>');
end;

procedure TForm2.btn3Click(Sender: TObject);
var
  xml:tnativexml;
  el:TsdElement;
begin
  xml:=TNativeXml.Create(nil);
  xml.ReadFromString(mmo2.Text);
  el:=xml.Root;
  el.WriteToString;
  xml.Free;
end;

procedure TForm2.btn4Click(Sender: TObject);
var
  parser:TStreamParser;
  b:tbytes;
begin
  parser:=TStreamParser.Create;
  b:=BytesOf(UTF8Encode(mmo2.Text));
  parser.Push(b,0,Length(b));

end;

procedure TForm2.btn6Click(Sender: TObject);
begin
  connection.Send(mmo2.Text);
end;

procedure TForm2.btn7Click(Sender: TObject);
var
  msg:Tmessage;
begin
  msg:=TMessage.Create;
  msg.MessageType:='chat';
  msg.ToJid:=tjid.Create(edt3.Text);
  msg.Body:=mmo4.Text;
  connection.Send(msg);
  OutgoingMessage(msg);
  msg.Free;
  msg:=nil;
  mmo4.Text:='';
end;

procedure TForm2.btn8Click(Sender: TObject);
var
  fi:TFileGrabber;
begin
  if dlgSave1.Execute(Handle) then
  begin
  fi:=TFileGrabber.Create(connection,curfileiq,dlgSave1.FileName);
  fi.Accept;
  end;
end;

procedure TForm2.btn9Click(Sender: TObject);
var
  fs:TFileStream;
  iq:TSIIq;
  fi:TFileGrabber;
begin
  if flpndlg1.Execute then
  begin
    fi:=TFileGrabber.Create(connection,tjid.Create(edt3.Text),flpndlg1.FileName);
    fi.SendFile;
  end;
end;

procedure TForm2.ClientSocket_OnReceive(sender: TObject; bt:TBytes;len:integer);
begin
  mmo1.Lines.Add(StringOf(bt));
  form4.addlog(StringOf(bt));
end;

procedure TForm2.DiscoServer;
begin
  discomanager.DiscoverItems(tjid.Create(connection.Server),ondiscoserverresult);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
    connection:=TXmppClientConnection.Create;
  connection.SocketConnectionType:=direct;
  connection.OnReadXml:=xmppcon_onreadxml;
  connection.OnWriteXml:=xmppcon_onwritexml;
  connection.OnRosterItem:=XmppCon_OnRosterItem;
  connection.OnRosterStart:=xmppcon_onrosterstart;
  connection.OnRosterEnd:=xmppcon_onrosterend;
  connection.OnLogin:=xmppcon_onlogin;
  connection.OnClose:=xmppcon_onclose;
  connection.OnError:=xmppcon_onerror;
  connection.OnPresence.Add(xmppcon_onpresence);
  connection.OnMessage.Add(xmppcon_onmessage);
  connection.OnIq.Add(xmppcon_oniq);

  connection.onautherror:=xmppcon_onautherror;
  connection.OnReadSocketData:=ClientSocket_OnReceive;

  discomanager:=tdiscomanager.Create(connection);
  //discoconn:=connection;


 end;

procedure TForm2.IncomingMessage(msg: TMessage);
begin
  mmo3.Lines.Append(msg.FromJid.ToString+' said:');
  mmo3.Lines.Append(msg.Body);

end;

procedure TForm2.MessageCallback(sender: TObject; msg: TMessage; data: string);
begin
  if msg.Body<>'' then
    IncomingMessage(msg);
end;

procedure TForm2.OnDiscoInfoResult(sender: TObject; iq: TIQ; data: TElement);
var
  di:TDiscoInfo;
  jid:TJID;
begin
  if iq.IqType='result' then
  begin
    if iq.Query is TDiscoInfo then
    begin
      di:=TDiscoInfo(iq.Query);
      if di.HasFeature(XMLNS_IQ_SEARCH) then
      begin
        jid:=iq.FromJid;

        
      end;
    end;
  end;
end;

procedure TForm2.OnDiscoServerResult(sender: TObject; iq: TIQ; data: TElement);
var
  items:TList<Telement>;
  el:TElement;
begin
  if iq.IqType='result' then
  begin
    if (iq.Query<>nil) and (iq.Query is TDiscoitems) then
    begin
    items:=TDiscoItems(iq.Query).GetDiscoItems;
    for el in items do
      if TDiscoitem(el).Jid<>nil then
        discomanager.DiscoverInformation(TDiscoitem(el).Jid,OnDiscoInfoResult,el);

    end;
  end;
end;

procedure TForm2.OutgoingMessage(msg: TMessage);
begin
  mmo3.Lines.Append('Me said:');
  mmo3.Lines.Append(msg.Body);
end;

procedure TForm2.XmppCon_OnAuthError(sender: TObject; e: TElement);
begin
  //
end;

procedure TForm2.XmppCon_OnClose(sender: TObject);
begin
  ShowMessage('close');
end;

procedure TForm2.XmppCon_OnError(sender: TObject; ex: Exception);
begin
  ShowMessage('Error');
end;

procedure TForm2.XmppCon_OnIQ(sender: TObject; iq: TIQ);
var
  si:protocol.extensions.si.tsi;
  sifile:protocol.extensions.filetransfer.TFile;
begin
  if iq<>nil then
  begin
    if iq.HasTag(protocol.extensions.si.TSI.ClassInfo) then
    begin
      if iq.IqType='set' then
      begin
        si:=protocol.extensions.si.TSI(iq.SelectSingleElement(protocol.extensions.si.TSI.ClassInfo));
        sifile:= si.SIFile;
        if sifile<>nil then
        begin
          //if(MessageBox(Self.Handle,'Receive File from ' + iq.FromJid.ToString(),'接收到文件',MB_OKCANCEL)=MB_OK) then
          //begin

          //end;
          btn8.Enabled:=true;
          btn8.Caption:=sifile.FileName;
          curfileiq:=iq;
        end;
      end;
    end;
  end;
end;

procedure TForm2.XmppCon_OnLogin(sender: TObject);
begin
  DiscoServer();
end;

procedure TForm2.XmppCon_OnMessage(sender: TObject; msg: TMessage);
begin
  //
end;

procedure TForm2.XmppCon_OnPresence(sender: TObject; pres: TPresence);
begin
  //
end;

procedure TForm2.XmppCon_OnReadXml(sender: TObject; xml: string);
var
  oldselstart,oldsellength:integer;
begin
if Pos('<presence',xml)<>1 then
begin
try
oldselstart:=0;
oldsellength:=0;
  with redt1 do
  begin
    oldselstart:=SelStart;
    oldsellength:=SelLength;
    //SelStart:=Length(Text);
    SelLength:=0;
    SelAttributes.Color:=clRed;
    Lines.Append('RECV:');
    SelAttributes.Color:=clBlack;
    //xml:= UTF8Encode(xml);
    Lines.Append(xml);
    //SelStart:=Length(Text);
    if oldsellength=0 then
    Perform(EM_SCROLLCARET,SB_PAGEDOWN,0);
    //TEncoding.UTF8.GetString(BytesOf(Xml))
  end;

  //mmo1.Lines.Add(xml);

except

end;
end;
end;

procedure TForm2.XmppCon_OnRosterEnd(sender: TObject);
begin
  //
end;

procedure TForm2.XmppCon_OnRosterItem(sender: TObject; item: TRosterItem);
begin
  if item.Subscription<>'remove' then
    cbb1.Items.Append(item.ItemName)
  else
    cbb1.Items.Delete(cbb1.Items.IndexOf(item.ItemName));
end;

procedure TForm2.XmppCon_OnRosterStart(sender: TObject);
begin
  //
end;

procedure TForm2.XmppCon_OnWriteXml(sender: TObject; xml: string);
begin
  redt1.SelStart:=Length(redt1.Text);
  redt1.SelLength:=0;
  redt1.SelAttributes.Color:=clblue;
  redt1.Lines.Append('SEND:');
  redt1.SelAttributes.Color:=clBlack;
  redt1.Lines.Append(xml);

end;

end.
