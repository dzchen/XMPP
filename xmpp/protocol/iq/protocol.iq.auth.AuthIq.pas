unit protocol.iq.auth.AuthIq;

interface
uses
  IQ,Jid,Auth;
type
  TAuthIq=class(TIQ)
  private
    _auth:TAuth;
  public
    constructor Create();overload;override;
    constructor Create(iqtype:string);overload;
    constructor Create(iqtype:string;tojid:TJID);overload;
    constructor Create(iqtype:string;tojid,fromjid:TJID);overload;
    property Query:TAuth read _auth;
  end;

implementation

{ TAuthIq }

constructor TAuthIq.Create(iqtype: string);
begin
  Self.Create;
  Self.IqType:=iqtype;
end;

constructor TAuthIq.Create;
begin
  inherited Create;
  _auth:=TAuth.Create();
  FSetQuery(_auth);
  GenerateId;
end;

constructor TAuthIq.Create(iqtype: string; tojid, fromjid: TJID);
begin
  Self.Create;
  Self.IqType:=iqtype;
  self.ToJid:=tojid;
  self.FromJid:=fromjid;
end;

constructor TAuthIq.Create(iqtype: string; tojid: TJID);
begin
  Self.Create;
  Self.IqType:=iqtype;
  self.ToJid:=tojid;
end;

end.
