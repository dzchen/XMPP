unit Presence;

interface
uses
  Stanza,XmppUri,NativeXml,Error,User,Delay,nickname.Nickname,primary.Primary,SysUtils;
type
  TPresence=class(TStanza)
  private
    function FGetStatus:string;
    procedure FSetStatus(value:string);
    function FGetPresenceType:string;
    procedure FSetPresenceType(value:string);
    function FGetError:TError;
    procedure FSetError(value:TError);
    function FGetShow:string;
    procedure FSetShow(value:string);
    function FGetPriority:Integer;
    procedure FSetPriority(value:Integer);
    function FGetDelay:TDelay;
    procedure FSetDelay(value:TDelay);
    function FGetIsPrimary:Boolean;
    procedure FSetIsPrimary(value:Boolean);
    function FGetMucUser:TMUUser;
    procedure FSetMucUser(value:TMUUser);
    function FGetNickname:TNickname;
    procedure FSetNickname(value:TNickname);
  public
    constructor Create();override;
    constructor Create(show,status:string);overload;
    constructor Create(show,status:string;priority:integer);overload;
    property Status:string read FGetStatus write FSetStatus;
    property PresenceType:string read FGetPresenceType write FSetPresenceType;
    property Error:TError read FGetError write FSetError;
    property Show:string read FGetShow write FSetShow;
    property Priority:Integer read FGetPriority write FSetPriority;
    property XDelay:TDelay read FGetDelay write FSetDelay;
    property IsPrimary:Boolean read FGetIsPrimary write FSetIsPrimary;
    property MucUser:TMUUser read FGetMucUser write FSetMucUser;
    property Nickname:TNickname read FGetNickname write FSetNickname;
  end;

implementation

{ TPresence }

constructor TPresence.Create( show, status: string;
  priority: integer);
begin
   self.Create();
   self.Show:=show;
   self.Status:=status;
   self.Priority:=priority;
end;

constructor TPresence.Create(show, status: string);
begin
  self.Create();
  self.Show:=show;
  self.Status:=status;
end;

constructor TPresence.Create();
begin
  inherited Create();
  Name:='presence';
  Namespace:=XMLNS_CLIENT;
end;

function TPresence.FGetDelay: TDelay;
begin
  Result:=TDelay(selectsingleelement(TDelay.ClassInfo));
end;

function TPresence.FGetError: TError;
begin
  result:=TError(selectsingleelement(TError.ClassInfo));
end;

function TPresence.FGetIsPrimary: Boolean;
begin
  if hastag(TPrimary.ClassInfo) then
    Result:=true
  else
    Result:=false;

end;

function TPresence.FGetMucUser: TMUUser;
begin
  Result:=TMUUser(selectsingleelement(TMUUser.ClassInfo));
end;

function TPresence.FGetNickname: TNickname;
begin
  Result:=TNickname(selectsingleelement(TNickname.ClassInfo));
end;

function TPresence.FGetPresenceType: string;
begin
  Result:=AttributeValueByName['type'];
end;

function TPresence.FGetPriority: Integer;
begin
  Result:=strtoint(GetTag('priority'));
end;

function TPresence.FGetShow: string;
begin
  Result:=GetTag('show');
end;

function TPresence.FGetStatus: string;
begin
  Result:=GetTag('status');
end;

procedure TPresence.FSetDelay(value: TDelay);
begin
  ReplaceNode(value);
end;

procedure TPresence.FSetError(value: TError);
begin
  ReplaceNode(value);
end;

procedure TPresence.FSetIsPrimary(value: Boolean);
begin
  if Value then
    NodeAdd(TPrimary.Create(Document))
  else
    RemoveTag('p');
end;

procedure TPresence.FSetMucUser(value: TMUUser);
begin
  ReplaceNode(value);
end;

procedure TPresence.FSetNickname(value: TNickname);
begin
  ReplaceNode(value);
end;

procedure TPresence.FSetPresenceType(value: string);
begin
  if value='available' then
    RemoveAttribute('type')
  else
    SetAttribute('type',value);
end;

procedure TPresence.FSetPriority(value: Integer);
begin
  settag('priority',value);
end;

procedure TPresence.FSetShow(value: string);
begin
  if value='NONE' then
    RemoveAttribute('show')
  else
    SetAttribute('show',value);
end;

procedure TPresence.FSetStatus(value: string);
begin
  settag('status',value);
end;

end.
