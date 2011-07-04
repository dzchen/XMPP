unit SaslFactory;

interface
uses
  protocol.sasl.Mechanism,Generics.Collections,sasl.Mechanism,XMPPConst;
type
  TClassMechanism = class of TMechanism;
  TSaslFactory=class
  public
    class function GetMechanism(mech:string):TMechanism;
    class procedure AddMechanism(mech:string;tm:TClassMechanism);
  end;

implementation
var
    _table:TDictionary<string,TClassMechanism>;
{ TSaslFactory }

class procedure TSaslFactory.AddMechanism(mech: string; tm: TClassMechanism);
begin
  _table.Add(mech,tm);
end;

class function TSaslFactory.GetMechanism(mech: string): TMechanism;
begin
  Result:=_table[mech].Create;;
end;

initialization
  _table:=TDictionary<string,TClassMechanism>.Create();
  TSaslFactory.AddMechanism(protocol.sasl.Mechanism.TMechanism.GetMechanismName(MTPLAIN),TMechanism);
  TSaslFactory.AddMechanism(protocol.sasl.Mechanism.TMechanism.GetMechanismName(MTDIGEST_MD5),TDigestMD5Mechanism);
  TSaslFactory.AddMechanism(protocol.sasl.Mechanism.TMechanism.GetMechanismName(MTANONYMOUS),TMechanism);
  TSaslFactory.AddMechanism(protocol.sasl.Mechanism.TMechanism.GetMechanismName(MTX_GOOGLE_TOKEN),TMechanism);
finalization
  _table.Clear;
  _table.Free;
end.
