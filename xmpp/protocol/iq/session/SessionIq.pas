unit SessionIq;

interface
uses
  Session,IQ,NativeXml,Jid;
type
  TSessionIq=class(TIQ)
  private
    _session:TSession;
  public
    constructor Create();overload;override;
    constructor Create(iqtype:string);overload;
    constructor Create(iqtype:string;tojid:TJID);overload;
  end;

implementation

{ TSessionIq }

constructor TSessionIq.Create();
begin
  inherited Create();
  GenerateId;
  _session:=TSession.Create();
  FSetQuery(_session);
end;

constructor TSessionIq.Create(iqtype: string);
begin
  self.Create();
  self.IqType:=iqtype;
end;

constructor TSessionIq.Create(iqtype: string; tojid: TJID);
begin
  self.Create(iqtype);
  self.tojid:=tojid;
end;

end.
