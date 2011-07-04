unit MUDecline;

interface
uses
  MUInvitation,NativeXml,jid;
type
  TDecline=class(TInvitation)
  public
    constructor Create();overload;override;
    constructor Create(reason:string);overload;
    constructor Create(tojid:TJID);overload;
    constructor Create(tojid:TJID;reason:string);overload;
  end;

implementation

{ TDecline }

constructor TDecline.Create(reason: string);
begin
  Self.Create();
  self.Reason:=reason;
end;

constructor TDecline.Create();
begin
  inherited Create();
  Name:='decline';
end;

constructor TDecline.Create(tojid: TJID; reason: string);
begin
  Self.Create();
  self.Reason:=reason;
  self.tojid:=tojid;
end;

constructor TDecline.Create(tojid: TJID);
begin
  Self.Create();
  self.tojid:=tojid;
end;

end.
