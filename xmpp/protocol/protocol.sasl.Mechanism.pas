unit protocol.sasl.Mechanism;

interface
uses
  Element,XmppUri,XMPPConst;
type
  TMechanism=class(TElement)
  private
    function FGetMechanismType:TMechanismType;
    procedure FSetMechainsmType(value:TMechanismType);
  public
    constructor Create;override;
    constructor Create(mechtype:TMechanismType);overload;
    property MechanismType:TMechanismType read FGetMechanismType write FSetMechainsmType;
    class function GetMechanismType(mech:string):TMechanismType;
    class function GetMechanismName(mech:TMechanismType):string;
  end;

implementation

{ TMechanism }

constructor TMechanism.Create;
begin
  inherited Create;
  name:='mechanism';
  Namespace:=XMLNS_SASL;
end;

constructor TMechanism.Create(mechtype: TMechanismType);
begin
  self.Create;
  self.MechanismType:=mechtype;
end;

function TMechanism.FGetMechanismType: TMechanismType;
begin
  Result:=GetMechanismType(Self.Value);
end;

procedure TMechanism.FSetMechainsmType(value: TMechanismType);
begin
  Self.Value:=GetMechanismName(Value);
end;

class function TMechanism.GetMechanismName(mech: TMechanismType): string;
begin
  Result:='';
  case mech of
    MTNONE: Result:='';
    MTKERBEROS_V4: Result:='KERBEROS_V4';
    MTGSSAPI: Result:='GSSAPI';
    MTSKEY: Result:='SKEY';
    MTEXTERNAL: Result:='EXTERNAL';
    MTCRAM_MD5: Result:='CRAM-MD5';
    MTANONYMOUS: Result:='ANONYMOUS';
    MTOTP: Result:='OTP';
    MTGSS_SPNEGO: Result:='GSS-SPNEGO';
    MTPLAIN: Result:='PLAIN';
    MTSECURID: Result:='SECURID';
    MTNTLM: Result:='NTLM';
    MTNMAS_LOGIN: Result:='NMAS_LOGIN';
    MTNMAS_AUTHEN: Result:='NMAS_AUTHEN';
    MTDIGEST_MD5: Result:='DIGEST-MD5';
    MTISO_9798_U_RSA_SHA1_ENC: Result:='9798-U-RSA-SHA1-ENC';
    MTISO_9798_M_RSA_SHA1_ENC: Result:='9798-M-RSA-SHA1-ENC';
    MTISO_9798_U_DSA_SHA1: Result:='9798-U-DSA-SHA1';
    MTISO_9798_M_DSA_SHA1: Result:='9798-M-DSA-SHA1';
    MTISO_9798_U_ECDSA_SHA1: Result:='9798-U-ECDSA-SHA1';
    MTISO_9798_M_ECDSA_SHA1: Result:='9798-M-ECDSA-SHA1';
    MTKERBEROS_V5: Result:='KERBEROS_V5';
    MTNMAS_SAMBA_AUTH: Result:='NMAS-SAMBA-AUTH';
    MTX_GOOGLE_TOKEN: Result:='X-GOOGLE-TOKEN';
    else
    Result:='';
  end;
end;

class function TMechanism.GetMechanismType(mech: string): TMechanismType;
begin
  Result:=MTNONE;
  if mech='PLAIN' then
    Result:=MTPLAIN
  else if mech='DIGEST-MD5' then
    Result:=MTDIGEST_MD5
  else if mech='X-GOOGLE-TOKEN' then
    Result:=MTX_GOOGLE_TOKEN;

end;

end.
