unit protocol.iq.roster.Roster;

interface
uses
  Element,NativeXml,XmppUri,protocol.iq.roster.RosterItem,Generics.Collections;
type
  TRoster=class(TElement)
  public
    constructor Create;override;
    function GetRoster():TList<TElement>;
    procedure AddRosterItem(r:TRosterItem);
  end;

implementation

{ TRoster }

procedure TRoster.AddRosterItem(r: TRosterItem);
begin
  NodeAdd(r);
end;

constructor TRoster.Create;
begin
  inherited create;
  Name:='query';
  Namespace:=XMLNS_IQ_ROSTER;
end;

function TRoster.GetRoster: TList<TElement>;
begin
  Result:=SelectElements(TRosterItem.ClassInfo);
end;

end.
