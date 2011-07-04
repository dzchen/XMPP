unit Option;

interface
uses
  Element,NativeXml,XmppUri,Value;
type
  TOption=class(TElement)
  private
    function FGetLab():string;
    procedure FSetLab(value:string);
  public
    constructor Create();override;
    constructor Create(lab,val:string);overload;

    function GetValue():string;
    procedure SetValue(val:string);
    property Lab:string read FGetLab write FSetLab;

  end;

implementation

{ TOption }


constructor TOption.Create();
begin
  inherited Create();
  self.Name:='option';
  Namespace:=XMLNS_X_DATA;
end;

constructor TOption.Create(lab, val: string);
begin
  self.Create;
  self.Lab:=lab;
  SetValue(val);
end;

function TOption.FGetLab: string;
begin
  Result:=AttributeValueByName['label'];
end;

procedure TOption.FSetLab(value: string);
begin
  SetAttribute('label',value);
end;

function TOption.GetValue: string;
begin
  result:=GetTag('value');
end;

procedure TOption.SetValue(val: string);
begin
  //setTag(TValue.ClassInfo,val);
  NodeAdd(TValue.Create(val));
end;

end.
