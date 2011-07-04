unit VcardIq;

interface
uses
  IQ,Vcard,NativeXml,jid;
type
  TVcardIq=class(TIQ)
  private
    _vcard:TVcard;
    procedure FSetVcard(value:TVcard);
  public
    constructor Create();overload;override;
    constructor Create(iqtype:string);overload;
    constructor Create(iqtype:string;vcard:TVcard);overload;
    constructor Create(iqtype:string;tojid:TJID);overload;
    constructor Create(iqtype:string;tojid:TJID;vcard:TVcard);overload;
    constructor Create(iqtype:string;tojid:TJID;fromjid:TJID);overload;
    constructor Create(iqtype:string;tojid:TJID;fromjid:TJID;vcard:TVcard);overload;
    property Vcard:TVcard read _vcard write FSetVcard;
  end;

implementation

{ TVcardIq }

constructor TVcardIq.Create( iqtype: string; vcard: TVcard);
begin
  Self.Create(iqtype);
  self.Vcard:=vcard;
end;

constructor TVcardIq.Create(iqtype: string);
begin
  Self.Create();
  self.iqtype:=iqtype
end;

constructor TVcardIq.Create();
begin
  inherited Create();
  _vcard:=TVcard.Create();
  GenerateId;
  FSetQuery(_vcard);
end;

constructor TVcardIq.Create(iqtype: string; tojid: TJID);
begin
  Self.Create(iqtype);
  Self.ToJid:=tojid;
end;

constructor TVcardIq.Create(iqtype: string; tojid,
  fromjid: TJID; vcard: TVcard);
begin
  Self.Create(iqtype,tojid,fromjid);
  self.Vcard:=vcard;
end;

constructor TVcardIq.Create(iqtype: string; tojid,
  fromjid: TJID);
begin
  Self.Create(iqtype);
  Self.ToJid:=tojid;
  Self.fromjid:=fromjid;

end;

constructor TVcardIq.Create(iqtype: string; tojid: TJID;
  vcard: TVcard);
begin
  Self.Create(iqtype,tojid);
  self.Vcard:=vcard;
end;

procedure TVcardIq.FSetVcard(value: TVcard);
begin
  ReplaceNode(value);
end;

end.
