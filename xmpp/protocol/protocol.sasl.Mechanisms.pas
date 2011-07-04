unit protocol.sasl.Mechanisms;

interface
uses
  Element,XmppUri,Generics.Collections,XMPPConst,protocol.sasl.Mechanism;
type
  TMechanisms=class(TElement)
  public
    constructor Create;override;
    function GetMechanisms:TList<TElement>;
    function SupportsMechanism(mechtype:TMechanismType):Boolean;

  end;

implementation

{ TMechanisms }

constructor TMechanisms.Create;
begin
  inherited Create;
  name:='mechanisms';
  Namespace:=XMLNS_SASL;
end;

function TMechanisms.GetMechanisms: TList<TElement>;
begin
  Result:=SelectElements('mechanism');
end;

function TMechanisms.SupportsMechanism(mechtype: TMechanismType): Boolean;
var
  el:TList<TElement>;
  e:TElement;

begin
  result:=False;
  el:=GetMechanisms;
  for e in el do
    if TMechanism(e).MechanismType=mechtype then
    begin
      Result:=true;
      exit;
    end;
end;

end.
