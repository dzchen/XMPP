unit Auth;

interface
uses
  Element,XmppUri,NativeXml,SecHash;
type
  TAuth=class(TElement)
  private
    function FGetResource: string;
    function FGetPassword: string;
    function FGetUsername: string;
    function FGetDigest: string;
    procedure FSetUseranem(value:string);
    procedure FSetPassword(value:string);
    procedure FSetResource(value:string);
    procedure FSetDigest(value:string);
  public
    constructor Create();override;
    property Username:string read FGetUsername write FSetUseranem;
    property Password:string read FGetPassword write FSetPassword;
    property Resource:string read FGetResource write FSetResource;
    property Digest:string read FGetDigest write FSetDigest;
    procedure SetAuthDigest(username,password,streamid:string);
    procedure SetAuthPlan(username,password:string);
    procedure SetAuth(username,password,streamid:string);
  end;

implementation

{ TAuth }



constructor TAuth.Create();
begin
  inherited Create();
  Name:='query';
  Namespace:=XMLNS_IQ_AUTH;
end;

function TAuth.FGetDigest: string;
begin
  Result:=GetTag('digest');
end;

function TAuth.FGetPassword: string;
begin
  Result:=GetTag('password');
end;

function TAuth.FGetResource: string;
begin
  Result:=GetTag('resource');
end;

function TAuth.FGetUsername: string;
begin
  Result:=GetTag('username');
end;

procedure TAuth.FSetDigest(value: string);
begin
  NodeFindOrCreate('digest').Value:=value;
end;

procedure TAuth.FSetPassword(value: string);
begin
  NodeFindOrCreate('password').Value:=value;
end;

procedure TAuth.FSetResource(value: string);
begin
  NodeFindOrCreate('resource').Value:=value;
end;

procedure TAuth.FSetUseranem(value: string);
begin
  settag('username',value);
end;

procedure TAuth.SetAuth(username, password, streamid: string);
begin
  if HasTag('digest') then
    SetAuthDigest(username,password,streamid)
  else
    SetAuthPlan(username,password);
end;

procedure TAuth.SetAuthDigest(username, password, streamid: string);
begin
  RemoveTag('password');
  self.Username:=username;
  self.Digest:=TSecHash.Sha1Hash(streamid+password);
end;

procedure TAuth.SetAuthPlan(username, password: string);
begin
  RemoveTag('digest');
  self.Username:=username;
  self.Password:=password;

end;
end.
