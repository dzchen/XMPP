unit EventList;

interface
uses
  Generics.Collections,XMPPEvent;
type
  TEventList<T>=class(TList<T>)
  public

    procedure Add(th:T);overload;
    //procedure Remove(th:T);
    //procedure Clear;
    //property EventList:TList<T> read _eventlist;
  end;
    function ConvertToMethod(var value):TMethod;

implementation

{ TEventList }

procedure TEventList<T>.Add(th:T);
var
  i:Integer;
  t1:T;
  th1,th2:TMethod;
begin

  for i:=0 to Count-1 do
  begin
    //if (ConvertToMethod(th).Code=TMethod(Items[i]).Code) and (ConvertToMethod(th).Data=TMethod(Items[i]).Data) then
      //Exit;
    th1:=ConvertToMethod(th);
    t1:=Items[i];
    th2:=ConvertToMethod(t1);
    if (th1.Code=th2.Code) and (th1.Data=th2.Data) then
      Exit;
  end;
  inherited Add(th);
  //_eventlist.Add(th);
end;

{procedure TEventList<T>.Clear;
begin
  _eventlist.Clear;
end;

constructor TEventList<T>.Create;
begin
  _eventlist:=TList<T>.Create;
end;

procedure TEventList<T>.Remove(th: T);
begin
  _eventlist.Remove(th);
end;  }

function ConvertToMethod(var value): TMethod;
begin
  Result:=tmethod(value);
end;




end.
