unit BindIq;

interface
uses
  IQ,NativeXml,Jid,bind;
type
  TBindIq=class(TIQ)
  private
    _bind:Tbind;
  public
    constructor Create();overload;override;
    constructor Create(iqtype:string);overload;
    constructor Create(iqtype:string;tojid:TJID);overload;
    constructor Create(iqtype:string;tojid:TJID;resource:string);overload;
    property Query:TBind read _bind;
  end;

implementation

{ TBindIq }

constructor TBindIq.Create(iqtype: string);
begin
  Self.Create();
  self.IqType:=iqtype;
end;

constructor TBindIq.Create();
begin
  inherited Create();
  GenerateId;
  _bind:=TBind.Create();
  FSetQuery(_bind);
end;

constructor TBindIq.Create(iqtype: string; tojid: TJID;
  resource: string);
begin
  Self.Create(iqtype,tojid);
  _bind.Resource:=resource;
end;

constructor TBindIq.Create(iqtype: string; tojid: TJID);
begin
  Self.Create(iqtype);
  Self.ToJid:=tojid;
end;

end.
