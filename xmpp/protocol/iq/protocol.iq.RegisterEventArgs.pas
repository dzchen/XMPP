unit protocol.iq.RegisterEventArgs;

interface
uses
  protocol.iq.Register;
type
  TRegisterEventArgs=class
  private
    _auto:boolean;
    _reg:tregister;
  public
    constructor Create;overload;
    constructor Create(reg:Tregister);overload;
    property Auto:Boolean read _auto write _auto;
    property Reg:Tregister read _reg write _reg;
  end;

implementation

{ TRegisterEventArgs }

constructor TRegisterEventArgs.Create;
begin

end;

constructor TRegisterEventArgs.Create(reg: Tregister);
begin
  _reg:=reg;
end;

end.
