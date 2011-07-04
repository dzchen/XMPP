unit PacketGrabber;

interface
uses
  XmppConnection,Generics.Collections,iq,XMPPEvent,SyncObjs,Element,JidComparer;
type
  TrackerData=record
    cb:TMethod;
    data:string;
    elm:Telement;
    comparer:TBareJidComparer;
  end;
  TPacketGrabber=class
  protected
    _lock:TCriticalSection;
    _connection:TXmppConnection;
    _grabbing:TDictionary<string,TrackerData>;
  public
    constructor Create;
    destructor Destory;
    procedure Clear;
    procedure Remove(id:string);
  end;

implementation

{ TPacketGrabber }

procedure TPacketGrabber.Clear;
begin
  _lock.Acquire;
  _grabbing.Clear;
  _lock.Release;
end;

constructor TPacketGrabber.Create;
begin
  _lock:=TCriticalSection.Create;
   _grabbing:=TDictionary<string,TrackerData>.Create;
end;

destructor TPacketGrabber.Destory;
begin
  _lock.Free;
end;

procedure TPacketGrabber.Remove(id: string);
begin
  if _grabbing.ContainsKey(id) then
    _grabbing.Remove(id);
end;


end.
