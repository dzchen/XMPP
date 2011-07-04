unit sasl.SaslEventArgs;

interface
uses
  protocol.sasl.Mechanisms;
type
  TSaslEventArgs=class
  private
    _auto:Boolean;
    _mechanism:string;
    _mechanisms:TMechanisms;
  public
    constructor Create;overload;
    constructor Create(mech:TMechanisms);overload;
    property Auto:Boolean read _auto write _auto;
    property Mechanisms:TMechanisms read _mechanisms write _mechanisms;
    property Mechanism:string read _mechanism write _mechanism;
  end;

implementation

{ TSaslEventArgs }

constructor TSaslEventArgs.Create;
begin
  _auto:=true;
end;

constructor TSaslEventArgs.Create(mech: TMechanisms);
begin
  self.Create;
  _mechanisms:=mech;
end;

end.
