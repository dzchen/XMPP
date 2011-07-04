unit protocol.iq.agent.AgentIq;

interface
uses
  iq,jid,Agents;
type
  TAgentsIq=class(TIQ)
  private
    _agents:Tagents;
  public
    constructor Create;overload;override;
    constructor Create(iqtype:string);overload;
    constructor Create(iqtype:string;tojid:TJID);overload;
    constructor Create(iqtype:string;tojid,fromjid:TJID);overload;
    property Query:TAgents read _agents;
  end;

implementation

{ TAgents }

constructor TAgentsIq.Create(iqtype: string);
begin
  self.Create;
  Self.IqType:=iqtype;
end;

constructor TAgentsIq.Create;
begin
  inherited create;
  _agents:=TAgents.Create;
  FSetQuery(_agents);
  GenerateId;
end;

constructor TAgentsIq.Create(iqtype: string; tojid, fromjid: TJID);
begin
  Self.Create(iqtype);
  self.ToJid:=tojid;
  self.FromJid:=fromjid;
end;

constructor TAgentsIq.Create(iqtype: string; tojid: TJID);
begin
  Self.Create(iqtype);
  self.ToJid:=tojid;
end;

end.
