unit Delay;

interface
uses
  Element,Jid,XmppUri,NativeXml,time;
type
  TDelay=class(TElement)
  private
    function FGetFromJid:TJID;
    procedure FSetFromJid(value:TJID);
    function FGetStamp:TDateTime;
    procedure FSetStamp(value:TDateTime);
  public
    constructor Create();override;
    property FromJid:TJID read FGetFromJid write FSetFromJid;
    property Stamp:TDateTime read FGetStamp write FSetStamp;
  end;


implementation

{ TDelay }

constructor TDelay.Create();
begin
  inherited Create();
  Name:='x';
  Namespace:=XMLNS_X_DELAY;
end;

function TDelay.FGetFromJid: TJID;
begin
  if HasAttribute('from') then
    Result:=tjid.Create(AttributeValueByName['from'])
  else
    Result:=nil;
end;

function TDelay.FGetStamp: TDateTime;
begin
  time.JabberToDateTime(AttributeValueByName['stamp']);
end;

procedure TDelay.FSetFromJid(value: TJID);
begin
  SetAttribute('from',value.ToString);
end;

procedure TDelay.FSetStamp(value: TDateTime);
begin
  SetAttribute('stamp',time.DateTimeToJabber(value));
end;

end.
