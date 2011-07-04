unit protocol.iq.roster.RosterItem;

interface
uses
  RosterItem,XmppUri,jid;
type
  TRosterItem=class(RosterItem.TRosterItem)
  private
    function FGetSubscription:string;
    procedure FSetSubscription(value:string);
    function FGetAsk:string;
    procedure FSetAsk(value:string);
  public
    constructor Create();overload;override;
    constructor Create(jid:TJID);overload;
    constructor Create(jid:TJID;name:string);overload;
    property Subscription:string read FGetSubscription write FSetSubscription;
    property Ask:string read FGetAsk write FSetAsk;
  end;

implementation

{ TRosterItem }

constructor TRosterItem.Create;
begin
  inherited Create;
  Namespace:=XMLNS_IQ_ROSTER;
end;

constructor TRosterItem.Create(jid: TJID);
begin
  self.Create;
  self.Jid:=jid;
end;

constructor TRosterItem.Create(jid: TJID; name: string);
begin
  self.Create(jid);
  self.name:=name;
end;

function TRosterItem.FGetAsk: string;
begin
  result:=AttributeValueByName['ask'];
end;

function TRosterItem.FGetSubscription: string;
begin
  result:=AttributeValueByName['subscription'];
end;

procedure TRosterItem.FSetAsk(value: string);
begin
  SetAttribute('ask',value);
end;

procedure TRosterItem.FSetSubscription(value: string);
begin
  SetAttribute('subscription',value);
end;

end.
