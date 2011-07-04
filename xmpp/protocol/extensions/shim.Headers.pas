unit shim.Headers;

interface
uses
  Element,XmppUri,NativeXml,shim.Header,SysUtils,Classes;
type
  THeaders=class(TElement)
  public
    constructor Create();override;
    function AddHeader:THeader;overload;
    function AddHeader(header:THeader):THeader;overload;
    function AddHeader(nm,val:string):THeader;overload;
    procedure SetHeaders(nm,val:string);
    function GetHeader(nm:string):THeader;
    procedure GetHeaders(al:TList);
  end;

implementation

{ THeaders }

function THeaders.AddHeader(nm, val: string): THeader;
var
  h:THeader;
begin
  h:=THeader.Create(nm,val);
  NodeAdd(h);
  Result:=h;
end;

function THeaders.AddHeader(header: THeader): THeader;
begin
  NodeAdd(header);
  Result:=header;
end;

function THeaders.AddHeader: THeader;
var
  h:THeader;
begin
  h:=THeader.Create();
  NodeAdd(h);
  Result:=h;
end;

constructor THeaders.Create();
begin
  inherited Create();
  name:='headers';
  Namespace:=XMLNS_SHIM;
end;

function THeaders.GetHeader(nm: string): THeader;
begin
  Result:=THeader(SelectSingleElement('header','name',nm));
end;

procedure THeaders.GetHeaders(al:TList);
begin
  FindNodes('header',al);
end;

procedure THeaders.SetHeaders(nm, val: string);
var
  th:THeader;
begin
  th:=GetHeader(nm);
  if th<>nil then
    th.Value:=val
  else
    AddHeader(nm,val);
end;

end.
