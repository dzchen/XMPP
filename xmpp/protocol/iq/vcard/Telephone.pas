unit Telephone;

interface
uses
  Element,NativeXml,XmppUri,TypInfo;
const
  TelephoneLocation:array[0..2] of string=('NONE' ,
		'HOME',
		'WORK');
  TelephoneType:array[0..12] of string=('NONE',
		'VOICE',
		'FAX',
		'PAGER',
		'MSG',
		'CELL',
		'VIDEO',
		'BBS',
		'MODEM',
		'ISDN',
		'PCS',
		'PREF',
		'NUMBER'	);
type



  TTelephone=class(TElement)
  private
    function FGetNumber():string;
    procedure FSetNumber(value:string);
    function FGetLocation():string;
    procedure FSetLocation(value:string);
    function FGetTelType():string;
    procedure FSetTelType(value:string);
  public
    constructor Create();override;
    constructor CreateTelephone(loc:string;tp:string;number:string);
    property Number:string read FGetNumber write FSetNumber;
    property Location:string read FGetLocation write FSetLocation;
    property TelType:string read FGetTelType write FSetTelType;
  end;
var
  TagName:string='TEL';
implementation

{ TTelephone }

constructor TTelephone.Create();
begin
  inherited Create();
  Name:='TEL';
  Namespace:=XMLNS_VCARD;
end;

constructor TTelephone.CreateTelephone(loc: string;
  tp: string; number: string);
begin
  if(loc<>'NONE')then
    Location:=loc;
  if(tp<>'NONE')then
    TelType:=tp;
  self.Number:=number;
end;

function TTelephone.FGetLocation: string;
begin
  result:=HasTagArray(TelephoneLocation);
end;

function TTelephone.FGetNumber: string;
begin
  Result:=GetTag('NUMBER');
end;

function TTelephone.FGetTelType: string;
begin
  result:=HasTagArray(TelephoneType);
end;

procedure TTelephone.FSetLocation(value: string);
begin
  NodeFindOrCreate(value);
end;

procedure TTelephone.FSetNumber(value: string);
begin
  NodeFindOrCreate('NUMBER').Value:=value;
end;

procedure TTelephone.FSetTelType(value: string);
begin
  NodeFindOrCreate(value);
end;

end.
