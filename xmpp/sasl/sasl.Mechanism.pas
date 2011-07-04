unit sasl.Mechanism;

interface
uses
  Element,XmppConnection,XMPPConst,SysUtils,StrUtils,util.Random,IdHash,IdHashMessageDigest,IdCoderMime,Types,StringUtils,Base64;
type
  TMechanism=class
  private
    _xmppclientconnection:TXmppConnection;
    _username,_password,_server:string;
  public
    constructor Create;virtual;
    property XmppClientConnection:TXmppConnection read _xmppclientconnection write _xmppclientconnection;
    property Username:string read _username write _username;
    property Password:string read _password write _password;
    property Server:string read _server write _server;
    procedure Init(con:TXmppConnection);virtual;abstract;
    procedure Parse(e:Telement);virtual;abstract;
  end;
  TAnonymousMechanism=class(TMechanism)
  public
    constructor Create;override;
    procedure Init(con:TXmppConnection);override;
    procedure Parse(e:TElement);override;
  end;
  TPlainMechanism=class(TMechanism)
    function GetMessage():string;
  public
    constructor Create;override;
    procedure Init(con:TXmppConnection);override;
    procedure Parse(e:TElement);override;
  end;
  TDigestMD5Mechanism=class(TMechanism)
  public
    constructor Create;override;
    procedure Init(con:TXmppConnection);override;
    procedure Parse(e:TElement);override;
  end;
  TChallengeParseException=class(Exception)
  public
    constructor Create(msg:string);overload;
  end;
  TStep1=class(TDigestMD5Mechanism)
  private
    _realm,_nonce,_qop,_charset,_algorithm,_rspauth,_message:string;
    procedure Parse(msg:string);
    procedure ParsePair(pair:string);
  public
    constructor Create;overload;override;
    constructor Create(msg:string);overload;
    property Realm:string read _realm write _realm;
    property Nonce:string read _nonce write _nonce;
    property Qop:string read _qop write _qop;
    property Charset:string read _charset write _charset;
    property Algorithm:string read _algorithm write _algorithm;
    property Rspauth:string read _rspauth write _rspauth;
  end;
  TStep2=class(TStep1)
  private
    _cnonce,_nc,_digesturi,_response,_authzid:string;
    hasher:TIdHashMessageDigest5;
    encoder:TIdEncoderMIME;
    function SupportsAuth(qop:string):Boolean;
    procedure GenerateCnonce();
    procedure GenerateNc();
    procedure GenerateDigestUri();
    procedure GenerateResponse();
    function GenerateMessage():string;
    function AddQuotes(s:string):string;
  public
    constructor Create;override;
    constructor Create(step1:TStep1;username,password,server:string);overload;
    constructor Create(msg:string);overload;
    property Cnonce:string read _cnonce write _cnonce;
    property Nc:string read _nc write _nc;
    property DigestUri:string read _digesturi write _digesturi;
    property Response:string  read _response write _response;
    property Authzid:string read _authzid write _authzid;
    function ToString():string;override;

  end;
implementation
uses
  XmppClientConnection,protocol.sasl;

{ TMechanism }

constructor TMechanism.Create;
begin
 //
end;

{ TDigestMD5Mechanism }

constructor TDigestMD5Mechanism.Create;
begin
  inherited;

end;

procedure TDigestMD5Mechanism.Init(con: TXmppConnection);
begin
  self.XmppClientConnection:=TXmppClientConnection(con);
  self.XmppClientConnection.Send(protocol.sasl.TAuth.Create(MTDIGEST_MD5));
end;

procedure TDigestMD5Mechanism.Parse(e: TElement);
var
  c:protocol.sasl.TChallenge;
  step1:TStep1;
  step2:TStep2;
  r:TResponse;
begin
  if e is TChallenge then
  begin
    c:=TChallenge(e);
    step1:=TStep1.Create(c.TextBase64);
    if step1.Rspauth='' then
    begin
      step2:=TStep2.Create(step1,username,Password,Server);
      r:=TResponse.Create(step2.ToString);
      XmppClientConnection.Send(r);
    end
    else
      XmppClientConnection.Send(TResponse.Create);
  end;
end;

{ TChallengeParseException }

constructor TChallengeParseException.Create(msg: string);
begin
  inherited Create(msg);

end;

{ TStep1 }

constructor TStep1.Create;
begin
  _charset:='utf-8';

end;

constructor TStep1.Create(msg: string);
begin
  self.Create;
  _message:=msg;
  Parse(msg);
end;

procedure TStep1.Parse(msg: string);
var
  start,ed,equalpos:Integer;
  s:string;
begin
  try
    start:=1;
    ed:=0;
    while start<Length(msg) do
    begin
      s:=MidStr(msg,start,Length(msg));
      equalpos:=Pos('=',s);
      if equalpos>1 then
      begin
      equalpos:=equalpos+start-1;
        if MidStr(msg,equalpos+1,1)='"' then
        begin
          s:=MidStr(msg,equalpos+2,Length(msg));
          ed:=Pos('"',s)+equalpos+1;
          ParsePair(MidStr(msg,start,ed-start+1));
          start:=ed+2;
        end
        else
        begin
          s:=MidStr(msg,equalpos+1,Length(msg));
          ed:=Pos(',',s)+equalpos;
          if ed=equalpos then
            ed:=Length(msg);
          ParsePair(MidStr(msg,start,ed-start));
          start:=ed+1;
        end;
      end;
    end;
  except
    raise TChallengeParseException.Create('Unable to parse challenge');

  end;
end;

procedure TStep1.ParsePair(pair: string);
var
  equalPos:integer;
  key,data:string;
begin
  equalPos:=Pos('=',pair);
  if equalPos>1 then
  begin
    key:=MidStr(pair,1,equalPos-1);
    if MidStr(pair,equalPos+1,1)='"' then
      data:=MidStr(pair,equalPos+2,Length(pair)-equalpos-2)
    else
      data:=MidStr(pair,equalPos+1,Length(pair));
    if key='realm' then
      _realm:=data
    else if key='nonce' then
      _nonce:=data
    else if key='qop' then
      _qop:=data
    else if key='charset' then
      _charset:=data
    else if key='algorithm' then
      _algorithm:=data
    else if key='rspauth' then
      _rspauth:=data;

  end;
  //_nonce:='PK41EiPQRwG9zZ8wUldWqzdQIDFRm0Mh8WWLW9RB';
end;

{ TStep2 }

function TStep2.AddQuotes(s: string): string;
begin
  if s='' then
    s:=ReplaceStr(s,'\','\\');
  Result:='"'+s+'"';
end;

constructor TStep2.Create;
begin
  hasher:=TIdHashMessageDigest5.Create;
  encoder:=TIdEncoderMIME.Create();

end;

constructor TStep2.Create(msg: string);
begin
  { TODO : important for server stuff }

end;

constructor TStep2.Create(step1: TStep1; username, password, server: string);
begin
  self.Create;
  Nonce:=step1.Nonce;
  if SupportsAuth(step1.Qop) then
    qop:='auth';
  Realm:=step1.Realm;
  Charset:=step1.Charset;
  Algorithm:=step1.Algorithm;
  Self.Username:=username;
  self.Password:=password;
  Self.Server:=server;
  GenerateCnonce();
  GenerateNc;
  GenerateDigestUri;
  GenerateResponse;
end;

procedure TStep2.GenerateCnonce;
var
  rng:trandom;
  s:string;
begin
  rng:=TRandom.Create;
  rng.CreateRand(64,s);
  //s:=encoder.Encode(s);
  _cnonce:=LowerCase(ToHex(BytesOf(s),0,32));
  rng.Free;
  //_cnonce:='e163ceed6cfbf8c1559a9ff373b292c2f926b65719a67a67c69f7f034c50aba3';
end;

procedure TStep2.GenerateDigestUri;
begin
  _digesturi:='xmpp/'+server;
end;

function TStep2.GenerateMessage: string;
var
  sb:TStringBuilder;
begin
  sb:=TStringBuilder.Create;
  sb.Append('username=');
  sb.Append(AddQuotes(Username));
			sb.Append(',');
			sb.Append('realm=');
			sb.Append(AddQuotes(Realm));
			sb.Append(',');
			sb.Append('nonce=');
			sb.Append(AddQuotes(Nonce));
			sb.Append(',');
			sb.Append('cnonce=');
			sb.Append(AddQuotes(Cnonce));
			sb.Append(',');
			sb.Append('nc=');
			sb.Append(Nc);
			sb.Append(',');
			sb.Append('qop=');
			sb.Append(Qop);
			sb.Append(',');
			sb.Append('digest-uri=');
			sb.Append(AddQuotes(DigestUri));
			sb.Append(',');
			sb.Append('charset=');
			sb.Append(Charset);
			sb.Append(',');
			sb.Append('response=');
			sb.Append(Response);

			Result:=sb.ToString();
      sb.Free;
end;

procedure TStep2.GenerateNc;
begin
  _nc:=Format('%8.8d', [1]);
end;

procedure TStep2.GenerateResponse;
var
  h1,h2,h3,ba1,bha1:TBytes;
  a1,a2,a3,p1,p2:string;
  sb:TStringBuilder;
  i,n:integer;
begin
  sb:=TStringBuilder.Create;
  sb.Append(Username);
	sb.Append(':');
	sb.Append(Realm);
	sb.Append(':');
	sb.Append(Password);
  h1:=hasher.HashString(sb.ToString,TEncoding.UTF8);
  sb.Remove(0,sb.Length);
  sb.Append(':');
	sb.Append(Nonce);
	sb.Append(':');
	sb.Append(Cnonce);
  if _authzid<>'' then
  begin
    sb.Append(':');
    sb.Append(_authzid);
  end;
  a1:=sb.ToString;
  ba1:=BytesOf(a1);

  bha1:=Copy(h1,0,length(h1));
  SetLength(bha1,Length(h1)+length(ba1));
  n:=Length(h1);
  for i := 0 to Length(ba1)-1 do
    bha1[i+n]:=ba1[i];
  h1:=hasher.HashBytes(bha1);
  sb.Remove(0,sb.Length);
  sb.Append('AUTHENTICATE:');
	sb.Append(_DigestUri);
	if (Qop<>'auth') then
		sb.Append(':00000000000000000000000000000000');
	A2 := sb.ToString();
  //h2:=BytesOf(a2);
  //h2:=hasher.HashBytes(h2);
  p1:=LowerCase(ToHex(h1));
  p2:=LowerCase(hasher.HashStringAsHex(a2));
  sb.Remove(0, sb.Length);
	sb.Append(p1);
	sb.Append(':');
	sb.Append(Nonce);
	sb.Append(':');
	sb.Append(_Nc);
	sb.Append(':');
	sb.Append(_Cnonce);
	sb.Append(':');
	sb.Append(Qop);
	sb.Append(':');
	sb.Append(p2);

	A3 := sb.ToString();
  _response:=LowerCase(hasher.HashStringAsHex(a3));
  sb.Free;
end;

function TStep2.SupportsAuth(qop: string): Boolean;
var
  auth:tstringdynarray;
begin
  auth:=SplitString(qop,',');
  if IndexStr('auth',auth)<0 then
    result:=False
  else
    result:=true;
end;

function TStep2.ToString: string;
begin
  result:=GenerateMessage;
end;

{ TPlainMechanism }

constructor TPlainMechanism.Create;
begin
  //inherited;

end;

function TPlainMechanism.GetMessage:string;
var
  sb:TStringBuilder;
begin
  sb:=TStringBuilder.Create;
  sb.Append('0');
  sb.Append(UserName);
  sb.Append('0');
  sb.Append(Password);
  result:=Base64Encode(sb.ToString);
end;

procedure TPlainMechanism.Init(con: TXmppConnection);
begin
  self.XmppClientConnection:=TXmppClientConnection(con);
  self.XmppClientConnection.Send(protocol.sasl.TAuth.Create(MTPLAIN));
end;

procedure TPlainMechanism.Parse(e: TElement);
begin
  //
end;

{ TAnonymousMechanism }

constructor TAnonymousMechanism.Create;
begin
  //inherited;

end;

procedure TAnonymousMechanism.Init(con: TXmppConnection);
begin
  self.XmppClientConnection:=TXmppClientConnection(con);
  self.XmppClientConnection.Send(protocol.sasl.TAuth.Create(MTANONYMOUS));
end;

procedure TAnonymousMechanism.Parse(e: TElement);
begin
  //
end;

end.
