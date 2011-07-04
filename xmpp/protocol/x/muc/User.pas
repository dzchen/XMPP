unit User;

interface
uses
  Element,NativeXml,XmppUri,MUItem,MUStatus,MUInvite,MUDecline;
type
  TMUUser=class(TElement)
  private
    function FGetItem:TMUItem;
    procedure FSetItem(value:TMUItem);
    function FGetStatus:TMUStatus;
    procedure FSetStatus(value:TMUStatus);
    function FGetInvite:TInvite;
    procedure FSetInvite(value:TInvite);
    function FGetDecline:TDecline;
    procedure FSetDecline(value:TDecline);
    function FGetPassword:string;
    procedure FSetPassword(value:string);
  public
    constructor Create();override;
    property Item:TMUItem read FGetItem write FSetItem;
    property Status:TMUStatus read FGetStatus write FSetStatus;
    property Invite:TInvite read FGetInvite write FSetInvite;
    property Decline:TDecline read FGetDecline write FSetDecline;
    property Password:string read FGetPassword write FSetPassword;
  end;
implementation

{ TMUUser }

constructor TMUUser.Create();
begin
  inherited Create();
  Name:='x';
  Namespace:=XMLNS_MUC_USER;
end;

function TMUUser.FGetDecline: TDecline;
begin
  result:=TDecline(FindNode('decline'));
end;

function TMUUser.FGetInvite: TInvite;
begin
  result:=TInvite(FindNode('invite'));
end;

function TMUUser.FGetItem: TMUItem;
begin
  result:=TMUItem(FindNode('item'));
end;

function TMUUser.FGetPassword: string;
begin
  Result:=GetTag('password');
end;

function TMUUser.FGetStatus: TMUStatus;
begin
  result:=TMUStatus(FindNode('status'));
end;

procedure TMUUser.FSetDecline(value: TDecline);
begin
  ReplaceNode(value);
end;

procedure TMUUser.FSetInvite(value: TInvite);
begin
  ReplaceNode(value);
end;

procedure TMUUser.FSetItem(value: TMUItem);
begin
  ReplaceNode(value);
end;

procedure TMUUser.FSetPassword(value: string);
begin
  NodeFindOrCreate('password').Value:=value;
end;

procedure TMUUser.FSetStatus(value: TMUStatus);
begin
  ReplaceNode(value);
end;

end.
