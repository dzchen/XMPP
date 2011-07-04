unit Email;

interface
uses
  Element,NativeXml,XmppUri;

const EmailType:array[0..4] of string=('NONE',
		'HOME',
		'WORK',
		'INTERNET',
		'X400');
type
  TEmail=class(TElement)
  private

    function FGetEmailType:string;
    procedure FSetEmailType(value:string);
    function FGetPrefered:Boolean;
    procedure FSetPrefered(value:Boolean);
    function FGetUserId:string;
    procedure FSetUserId(value:string);
  public

    constructor Create();override;
    constructor CreateEmail(emailtype:string;userid:string;prefered:Boolean);
    property EmailType:string read FGetEmailType write FSetEmailType;
    property IsPrefered:Boolean read FGetPrefered write FSetPrefered;
    property UserId:string read FGetUserId write FSetUserId;
  end;
var
  TagName:string='EMAIL';


implementation

{ TEmail }

constructor TEmail.Create();
begin
  inherited Create;
  Name:=TagName;
  Namespace:=XMLNS_VCARD;
end;

constructor TEmail.CreateEmail(emailtype:string; userid: string;
  prefered: Boolean);
begin
  self.Create();
  Self.UserId:=userid;
  Self.EmailType:=EmailType;
  self.IsPrefered:=prefered;
end;

function TEmail.FGetEmailType: string;
begin
  Result:=HasTagArray(Email.EmailType);
end;

function TEmail.FGetPrefered: Boolean;
begin
  Result:=HasTag('PREF');
end;

function TEmail.FGetUserId: string;
begin
  Result:=GetTag('USERID');
end;

procedure TEmail.FSetEmailType(value: string);
begin
  if(value<>'NONE')then
    NodeFindOrCreate(value);
end;

procedure TEmail.FSetPrefered(value: Boolean);
begin
  if(value)then
    NodeFindOrCreate('PREF')
  else
    NodeRemove(FindNode('PREF'));
end;

procedure TEmail.FSetUserId(value: string);
begin
  NodeFindOrCreate('USERID').Value:=value;
end;

end.
