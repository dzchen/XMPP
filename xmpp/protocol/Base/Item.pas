unit Item;

interface
uses
  Element,NativeXml,Jid;
type
  TItem=class(TElement)
  private
    function fgetjid: TJID;
    procedure fsetjid(value:TJID);
    function fgetattr:string;
    procedure fsetattr(value:string);
  published
  public
    constructor Create(AOwner:tnativexml);
    property Jid:TJID read fgetjid write fsetjid;
    property ItemName:string read fgetattr write fsetattr;
  end;

implementation

{ TItem }

constructor TItem.Create(AOwner: tnativexml);
begin
  inherited Create(AOwner);
  name:='item';
end;

function TItem.fgetattr: string;
begin
  if(HasAttribute('jid'))
  result:=AttributeValueByName['jid'];
end;

function TItem.fgetjid: TJID;
begin

end;

procedure TItem.fsetattr(value: string);
begin

end;

procedure TItem.fsetjid(value: TJID);
begin

end;

end.
