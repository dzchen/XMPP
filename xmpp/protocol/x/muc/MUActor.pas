unit MUActor;

interface
uses
  Element,NativeXml,XmppUri,Jid;
type
  TMUActor=class(TElement)
  private
    function FGetJID:TJID;
    procedure FSetJID(value:TJID);
  public
    constructor Create();override;
    property Jid:TJID read FGetJID write FSetJID;
  end;

implementation

{ TMUActor }

constructor TMUActor.Create();
begin
  inherited Create();
  Name:='actor';
  Namespace:=XMLNS_MUC_USER;
end;

function TMUActor.FGetJID: TJID;
begin
  Result:=TJID.Create(AttributeValueByName['jid']);
end;

procedure TMUActor.FSetJID(value: TJID);
begin
  SetAttribute('jid',value.ToString);
end;

end.
