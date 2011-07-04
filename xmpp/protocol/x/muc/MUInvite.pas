unit MUInvite;

interface
uses
  MUInvitation,NativeXml,Jid,nickname.Nickname;
type
  TInvite=class(TInvitation)
  private
    function FGetContinue:Boolean;
    procedure FSetContinue(value:Boolean);
    function FGetNickname:TNickname;
    procedure FSetNickname(value:TNickname);
  public
    constructor Create();overload;override;
    constructor Create(reason:string);overload;
    constructor Create(tojid:TJID);overload;
    constructor Create(tojid:TJID;reason:string);overload;
    property Continue:Boolean read FGetContinue write FSetContinue;
    property Nickname:TNickname read FGetNickname write FSetNickname;
  end;

implementation

{ TInvite }

constructor TInvite.Create( reason: string);
begin

end;

constructor TInvite.Create();
begin
  inherited Create();
  Name:='invite';
end;

constructor TInvite.Create(tojid: TJID; reason: string);
begin
  Self.Create(tojid);
  Self.Reason:=reason;
end;

constructor TInvite.Create(tojid: TJID);
begin
  Self.Create();
  self.ToJid:=tojid;
end;

function TInvite.FGetContinue: Boolean;
var
  s:string;
begin
  s:=GetTag('continue');
  if s='' then
    Result:=False
  else
    Result:=true;
end;

function TInvite.FGetNickname: TNickname;
begin
  Result:=TNickname(FindNode('nick'));
end;

procedure TInvite.FSetContinue(value: Boolean);
begin
  if value then
    NodeFindOrCreate('continue')
  else
    RemoveTag('continue');
end;

procedure TInvite.FSetNickname(value: TNickname);
begin
  ReplaceNode(value);
end;

end.
