unit FileGrabber;

interface
uses
  XMPPEvent,SysUtils,classes,PacketGrabber,iq,Jid,XmppConnection,JidComparer,EventList,protocol.extensions.featureneg,JEP65Socket,protocol.extensions.bytestreams,protocol.extensions.si,protocol.extensions.filetransfer,IOUtils,XMPPConst,Error;
type
  TFileGrabber=class(TPacketGrabber)
  const
    PROXY='proxy.ag-software.de';
  private
    _proxySocks5Socket,_p2pSocks5Socket:TJEP65Socket;
    m_FileStream:TFileStream;
    _sid,_filename:string;
    _from,_to:TJID;
    si:protocol.extensions.si.TSI;
    siiq:TIQ;
    _bytestransmitted,_lfilelength:int64;
    _startdatetime:TDateTime;
    _file:protocol.extensions.filetransfer.Tfile;
    FOnProgress:ProgressEventHandler;
    procedure OnIq(sender:TObject;iq:TIQ);
    procedure OnSockConnect(sender:TObject);
    procedure OnSockDisconnect(sender:TObject);
    procedure Onp2pConnect(sender:TObject);
    procedure Onp2pDisconnect(sender:TObject);
    procedure OnSockReceive(sender:TObject;bt:TBytes;len:Integer);
    function SelectedByteStream(fn:Tfeatureneg):Boolean;
    procedure SendStreamHosts();
    procedure SendStreamHostsResult(sender:TObject;iq:TIQ;data:string);
    procedure SiIqResult(sender:TObject;iq:TIQ;data:string);
    procedure ActivateBytestream(streamhost:TJID);
    procedure ActivateBytestreamResult(sender:TObject;iq:TIQ;data:string);
  public
    constructor Create(conn:TXmppConnection;iq:TIQ;filename:string);overload;
    constructor Create(conn:TXmppConnection;tojid:TJID;filename:string);overload;
    procedure Add(jid:TJid;cb:messagecb;cbarg:string);overload;
    procedure Add(jid:TJid;comparer:TBareJidComparer;cb:messagecb;cbarg:string);overload;
    procedure Remove(jid:TJID);
    procedure Accept();
    procedure Refuse();
    procedure HandleStreamHost(bs:protocol.extensions.bytestreams.Tbytestream;iq:TIQ);
    procedure SendStreamHostUsedResponse(shost:protocol.extensions.bytestreams.TStreamHost);
    property OnProgress:ProgressEventHandler read FOnProgress write FOnProgress;
    function HRSize(lbytes:Int64):string;
    function GetBytePerSecond():Int64;
    function GetHRByteRateString():string;
    function GetHRRemainingTime():string;

    procedure SendFile();
  end;
implementation
uses
  XmppClientConnection,Element,protocol.x.data.Data,Generics.Collections,Field,Option,XmppUri
  ,DateUtils,Dialogs;

{ TFileGrabber }

procedure TFileGrabber.Accept();
var
  fneg:protocol.extensions.featureneg.TFeatureNeg;
  data:protocol.x.data.Data.Tdata;
  xdata:protocol.x.data.Data.TData;
  f:TField;
  el,ol:TList<telement>;
  methods:TDictionary<string,string>;
  i,n:integer;
  val:string;
  siq:protocol.extensions.si.TSIIq;
begin
  fneg:=si.FeatureNeg;
  if fneg<>nil then
  begin
    data:=fneg.Data;
    if data<>nil then
    begin
      el:=data.GetFields;
      if el.Count=1 then
      begin
        methods:=TDictionary<string,string>.Create;
        ol:=field.TField(el[0]).GetOptions;
        n:=ol.Count;
        for i := 0 to n-1 do
        begin
          val:=Option.TOption(ol[i]).GetValue;
          methods.Add(val,val);
        end;
        if methods.ContainsKey(XMLNS_BYTESTREAMS) then
        begin
          siq:=protocol.extensions.si.TSIIq.Create;
          siq.Id:=siiq.id;
          siq.ToJid:=siiq.FromJid;
          siq.IqType:='result';
          siq.SI.Id:=si.Id;
          siq.SI.FeatureNeg:=protocol.extensions.featureneg.TFeatureNeg.Create;
          xdata:=TData.Create;
          xdata.DataType:='submit';
          f:=TField.Create;
          f.FieldVar:='stream-method';
          f.AddValue(XMLNS_BYTESTREAMS);
          xdata.AddField(f);
          siq.SI.FeatureNeg.Data:=xdata;
          _connection.Send(siq);
        end;
      end;
    end;
  end;
end;

procedure TFileGrabber.Add(jid: TJid; cb: messagecb; cbarg: string);
begin

end;

procedure TFileGrabber.ActivateBytestream(streamhost: TJID);
var
  bsiq:TByteStreamIq;
begin
  bsiq:=TByteStreamIq.Create;
  bsiq.ToJid:=streamhost;
  bsiq.IqType:='set';
  bsiq.Query.Sid:=_sid;
  bsiq.Query.Activate:=TActivate.Create(_to);
  TXmppClientConnection(_connection).IqGrabber.SendIq(bsiq,ActivateBytestreamResult);
end;

procedure TFileGrabber.ActivateBytestreamResult(sender: TObject; iq: TIQ;
  data: string);
begin
  if iq.IqType='result' then
    _p2pSocks5Socket.SendFile(m_filestream);
end;

procedure TFileGrabber.Add(jid: TJid; comparer: TBareJidComparer; cb: messagecb;
  cbarg: string);
begin

end;

constructor TFileGrabber.Create(conn: TXmppConnection; tojid: TJID;
  filename: string);
begin
  inherited Create();
  _bytestransmitted:=0;
  _connection:=conn;
  _filename:=filename;
  _to:=tojid;
  TXmppClientConnection(_connection).OnIq.Add(oniq);
end;

constructor TFileGrabber.Create(conn: TXmppConnection;iq:TIQ;filename:string);
begin
  inherited Create();
  _bytestransmitted:=0;
  _connection:=conn;
  siiq:=iq;
  si:=protocol.extensions.si.TSI(iq.SelectSingleElement(protocol.extensions.si.TSI.ClassInfo));
  _sid:=si.id;
  _from:=iq.FromJid;
  _file:=si.SIFile;
  if _file<>nil then
  begin
    _lfilelength:=_file.Size;
  end;
  _filename:=filename;
  TXmppClientConnection(_connection).OnIq.Add(oniq);
end;

function TFileGrabber.GetBytePerSecond: Int64;
var
  ts:double;
begin
  ts:=SecondSpan(now,_startdatetime);
  Result:=Round(_bytestransmitted / ts);
end;

function TFileGrabber.GetHRByteRateString: string;
var
  ts:double;
begin
  ts:=SecondSpan(now,_startdatetime);
  if ts<>0 then
  begin
    Result:=HRSize(Round(_bytestransmitted/ts))+'/s';
  end
  else
    Result:=HRSize(0)+'/s';
end;

function TFileGrabber.GetHRRemainingTime: string;
var
  ts,fremainingtime,ftotalnumberofbytes,fpartialnumberofbytes,fbytespersecond:double;
  sb:TStringBuilder;
begin
  fremainingtime:=0;
  ftotalnumberofbytes:=_lfilelength;
  fpartialnumberofbytes:=_bytestransmitted;
  fbytespersecond:=GetBytePerSecond;
  sb:=TStringBuilder.Create;
  if fbytespersecond<>0 then
    fremainingtime:=(ftotalnumberofbytes-fpartialnumberofbytes)/fbytespersecond;
  Result:=IntToStr(Round(fremainingtime / 3600))+'h ';
  Result:=Result+inttostr(Round(Round(fremainingtime) mod 3600 / 60))+'m ';
  Result:=Result+inttostr(Round(fremainingtime) mod 3600 mod 60)+'s';
end;

procedure TFileGrabber.HandleStreamHost(
  bs: protocol.extensions.bytestreams.Tbytestream; iq: TIQ);
begin
  if bs<>nil then
  begin
    _proxySocks5Socket:=TJEP65Socket.Create;
    _proxySocks5Socket.OnConnect:=onsockconnect;
    _proxySocks5Socket.OnReceive:=onsockreceive;
    _proxySocks5Socket.OnDisconnect:=onsockdisconnect;
    _proxySocks5Socket.BytesStream:=bs;
    _proxySocks5Socket.ID:=iq.Id;
      _proxySocks5Socket.Target := TXmppClientConnection(_connection).MyJID;
      _proxySocks5Socket.Initiator := _From;
      _proxySocks5Socket.SID := _Sid;
      _proxySocks5Socket.ConnectTimeout := 5000;
      _proxySocks5Socket.Connect();

  end;
end;

function TFileGrabber.HRSize(lbytes: Int64): string;
var
  sb:TStringBuilder;
  strunits:string;
  fadjusted:Double;
begin
  sb:=TStringBuilder.Create;
  strunits:='Bytes';
  fadjusted:=0.0;
  if lbytes>1024 then
  begin
    if lbytes<1024*1024 then
    begin
      strunits:='KB';
      fadjusted:=lbytes/1024;
    end
    else
    begin
      strunits:='MB';
      fadjusted:=lbytes/1048576;
    end;
    sb.AppendFormat('%.1f %s',[fadjusted,strunits]);
  end
  else
  begin
    fadjusted:=lbytes;
    sb.AppendFormat('%.0f %s',[fadjusted,strunits]);
  end;
  Result:=sb.ToString;
end;

procedure TFileGrabber.OnIq(sender: TObject; iq: TIQ);
var
  bs:protocol.extensions.bytestreams.TByteStream;
begin
  if (iq.Query<>nil) and (iq.Query is protocol.extensions.bytestreams.TByteStream) then
  begin
    bs:=protocol.extensions.bytestreams.TByteStream(iq.Query);
    if bs.Sid=_sid then
      HandleStreamHost(bs,iq);
  end;

end;

procedure TFileGrabber.Onp2pConnect(sender: TObject);
begin
  ActivateBytestream(tjid.Create(PROXY));
end;

procedure TFileGrabber.Onp2pDisconnect(sender: TObject);
begin
  if Assigned(m_FileStream) then
    m_FileStream.Free;

end;

procedure TFileGrabber.OnSockConnect(sender: TObject);
var
  path:string;
begin
  SendStreamHostUsedResponse(_proxySocks5Socket.ByteHost);
  _startdatetime:=Now;
  path:=TPath.GetDirectoryName(_filename);
  if not TDirectory.Exists(path) then
  begin
    TDirectory.CreateDirectory(path);
  end;
  m_FileStream:=TFileStream.Create(_filename,fmCreate);
end;

procedure TFileGrabber.OnSockDisconnect(sender: TObject);
begin
  m_FileStream.Free;
  m_FileStream:=nil;
  if _bytestransmitted=_lfilelength then
  begin

  end;
end;

procedure TFileGrabber.OnSockReceive(sender: TObject; bt: TBytes; len: Integer);
var
  s:TArray<Char>;
begin
  if Assigned(m_FileStream) then
  begin
  s:=TEncoding.ASCII.GetChars(bt);
  m_FileStream.WriteBuffer(s,Length(s));
  Inc(_bytestransmitted,len);
  if Assigned(FOnProgress) then
    FOnProgress(sender,_bytestransmitted);
  end;
end;

procedure TFileGrabber.Refuse;
begin

end;

procedure TFileGrabber.Remove(jid: TJID);
begin

end;

function TFileGrabber.SelectedByteStream(fn: Tfeatureneg): Boolean;
var
  data:TData;
  field:Tfield;
  el:TList<TElement>;
  i:integer;
begin
  if fn<>nil then
  begin
    data:=fn.data;
    if data<>nil then
    begin
      el:=data.GetFields;
      for i := 0 to el.Count-1 do
      begin
        field:=TField(el[i]);
        if (field<>nil) and (field.FieldVar='stream-method') then
        begin
          if field.GetValue=XMLNS_BYTESTREAMS then
          begin
            Result:=true;
            exit;
          end;
        end;
      end;
    end;
  end;
  Result:=false;
end;

procedure TFileGrabber.SendFile();
var
  iq:TSIIq;
  fneg:TFeatureNeg;
  data:TData;
  f:TField;
  fi:protocol.extensions.filetransfer.TFile;
  V: TGUID;
begin
  iq:=TSIIq.Create;
  iq.tojid:=_to;
  iq.IqType:='set';
  m_FileStream:=TFileStream.Create(_filename,fmShareDenyNone);
  _lfilelength:=m_FileStream.Size;
  fi:=protocol.extensions.filetransfer.TFile.Create(TPath.GetFileName(_filename),_lfilelength);
  fi.Range:=TRange.Create;
  fneg:=TFeatureNeg.Create;
  data:=TData.Create('form');
  f:=TField.Create(FTList_Single);
  f.FieldVar:='stream-method';
  f.AddOption().SetValue(XMLNS_BYTESTREAMS);
  data.AddField(f);
  fneg.Data:=data;
  iq.SI.SIFile:=fi;
  iq.SI.FeatureNeg:=fneg;
  iq.SI.Profile:=XMLNS_SI_FILE_TRANSFER;
  V := TGUID.NewGuid;
  _sid:=StringReplace(v.tostring,'{','',[rfIgnoreCase]);
  _sid:=StringReplace(_sid,'}','',[rfIgnoreCase]);
  iq.SI.Id:=_sid;
  TXmppClientConnection(_connection).IqGrabber.SendIq(iq,SiIqResult);
end;

procedure TFileGrabber.SendStreamHosts;
var
  bsiq:TByteStreamIq;
begin
  bsiq:=TByteStreamIq.Create;
  bsiq.ToJid:=_to;
  bsiq.IqType:='set';
  bsiq.Query.Sid:=_sid;
  bsiq.Query.AddStreamHost(TJID.Create(PROXY),PROXY,7777);

  _p2pSocks5Socket:=TJEP65Socket.Create;
  _p2pSocks5Socket.Initiator := TXmppClientConnection(_connection).MyJID;
  _p2pSocks5Socket.Target := _To;
  _p2pSocks5Socket.SID := _Sid;
  _p2pSocks5Socket.OnConnect := Onp2pConnect;
  _p2pSocks5Socket.OnDisconnect := Onp2pDisConnect;
  _p2pSocks5Socket.Listen(1000);
  TXmppClientConnection(_connection).IqGrabber.SendIq(bsiq,SendStreamHostsResult);

end;

procedure TFileGrabber.SendStreamHostsResult(sender: TObject; iq: TIQ;
  data: string);
var
  bs:TByteStream;
  sh:tjid;
begin
  if iq.IqType='result' then
  begin
    bs:=TByteStream(iq.Query);
    if bs<>nil then
    begin
      sh:=bs.StreamHostUsed.Jid;
      if (sh<>nil) and (TFullJidComparer.Create.Compare(sh,TXmppClientConnection(_connection).MyJID)=0) then
        _p2pSocks5Socket.SendFile(m_FileStream);
      if (sh<>nil) and (TFullJidComparer.Create.Compare(sh,tjid.Create(PROXY))=0) then
      begin
        _p2pSocks5Socket:=TJEP65Socket.Create(1);
        _p2pSocks5Socket.Address := PROXY;
        _p2pSocks5Socket.Port := 7777;
        _p2pSocks5Socket.Target := _To;
        _p2pSocks5Socket.Initiator := TXmppClientConnection(_connection).MyJID;
        _p2pSocks5Socket.SID := _Sid;
        _p2pSocks5Socket.ConnectTimeout := 5000;
        _p2pSocks5Socket.Connect();
      end;
    end;
  end;
end;

procedure TFileGrabber.SendStreamHostUsedResponse(
  shost: protocol.extensions.bytestreams.TStreamHost);
var
  bsiq:protocol.extensions.bytestreams.TByteStreamIq;
begin
  bsiq:=TByteStreamIq.Create('result',_from);
  bsiq.Id:=_proxySocks5Socket.Id;
  bsiq.Query.StreamHostUsed:=TStreamHostUsed.Create(shost.Jid);
  _connection.Send(bsiq);
end;

procedure TFileGrabber.SiIqResult(sender: TObject; iq: TIQ; data: string);
var
  si:TSI;
  fneg:TFeatureNeg;
  err:terror;
begin
  if iq.IqType='result' then
  begin
    si:=TSI(iq.SelectSingleElement(TSI.ClassInfo));
    if si<>nil then
    begin
      fneg:=si.FeatureNeg;
      if selectedbyteStream(fneg) then
        sendstreamhosts;
    end;
  end
  else if iq.IqType='error' then
  begin
    err:=iq.Error;
    if err<>nil then
    begin
      case err.Code of
        RCBadRequest: ;
        RCUnauthorized: ;
        RCPaymentRequired: ;
        RCForbidden:
        MessageDlg('The file was rejected by the remote user',tmsgdlgtype.mtError,[mbOK],0);
        RCNotFound: ;
        RCNotAllowed: ;
        RCNotAcceptable: ;
        RCRegistrationRequired: ;
        RCRequestTimeout: ;
        RCConflict: ;
        RCInternalServerError: ;
        RCNotImplemented: ;
        RCRemoteServerError:  ;
        RCServiceUnavailable:
        MessageDlg('The file was rejected by the remote server',tmsgdlgtype.mtError,[mbOK],0);
        RCRemoteServerTimeout: ;
        RCDisconnected: ;
      end;
      m_FileStream.Free;
    end;
  end;
end;

end.
