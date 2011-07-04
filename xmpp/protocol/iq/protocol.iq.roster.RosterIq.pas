unit protocol.iq.roster.RosterIq;

interface
uses
  IQ,protocol.iq.roster.Roster,XMPPConst;
type
  TRosterIq=class(TIQ)
  private
    _roster:TRoster;
  public
    constructor Create();overload;override;
    constructor Create(iqtype:string);overload;
    property Query:TRoster read _roster;
  end;

implementation

{ TRosterIq }

constructor TRosterIq.Create;
begin
  inherited create;
  //Create(xmldoc);
  Namespace:='';
  _roster:=TRoster.Create;
  FSetQuery(_roster);
  GenerateId;
end;

constructor TRosterIq.Create(iqtype: string);
begin
  self.Create;
  self.IqType:=iqtype;
end;

end.
