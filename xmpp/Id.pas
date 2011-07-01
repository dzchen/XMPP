unit Id;

interface
uses
  SysUtils;
type
  IdType=(Numeric,Guid);
  TId=class
  private
    class
    var _id:LongInt;
    _prefix:string;
    _type:IdType;
  public
    class property IdType:IdType read _type write _type;
    class function GetNextId():string;
    class procedure Reset();
    class property Prefix:string read _prefix write _prefix;
  end;

implementation

{ TId }

class function TId.GetNextId: string;
var
  V: TGUID;
  S: String;
begin
  if(_type=Numeric) then
  begin
    _id:=_id+1;
    Result:=_prefix+inttostr(_Id);
  end
  else
  begin
    V := TGUID.NewGuid;
    S := V.ToString;
    Result:=_prefix+s;
  end;
end;

class procedure TId.Reset;
begin
  _id:=0;
end;
initialization
TId._id:=0;
TId._type:=Numeric;
tid._prefix:='agsXMPP_';
//
//
end.
