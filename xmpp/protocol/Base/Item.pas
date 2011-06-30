unit Item;

interface
uses
  Element,NativeXml,Jid;
type
  TItem=class(TElement)
  private
    function fgetjid: TJID;
    procedure fsetjid(value:TJID);
    function fgetitemname:string;
    procedure fsetitemname(value:string);
  published
  public
    constructor Create(AOwner:tnativexml);
    property Jid:TJID read fgetjid write fsetjid;
    property ItemName:string read fgetitemname write fsetitemname;
  end;

implementation

{ TItem }

constructor TItem.Create(AOwner: tnativexml);
begin
  inherited Create(AOwner);
  name:='item';
end;

function TItem.fgetitemname: string;
begin
  Result:=AttributeValueByName['name'];
end;

function TItem.fgetjid: TJID;
begin
  if(HasAttribute('jid')) then
    Result:=TJID.Create(AttributeValueByName['jid'])
  else
    Result:=nil;
end;

procedure TItem.fsetitemname(value: string);
begin
  AttributeAdd('name',value);
end;

procedure TItem.fsetjid(value: TJID);
begin
  if(value<>nil)then
    AttributeByName['jid'].Value:=value.ToString
  else
    AttributeByName['jid'].Value:='';
end;

end.
