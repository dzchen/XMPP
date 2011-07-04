unit Bind;

interface
uses
  Element,NativeXml,XmppUri,jid;
type
  TBind=class(TElement)
  private
    procedure FSetResource(value:string);
    function FGetResource():string;
    procedure FSetJId(value:TJID);
    function FGetJid():TJID;
  public
    constructor Create();override;
    constructor CreateResource(resouce:string);
    constructor CreateJid(jid:Tjid);
    property Resource:string read FGetResource write FSetResource;
    property Jid:TJID read FGetJid write FSetJId;
  end;
var
  TagName:string='bind';
implementation

{ TBind }

constructor TBind.Create();
begin
  inherited Create;
  Name:='bind';
  Namespace:=XMLNS_BIND;
end;

constructor TBind.CreateJid(jid: Tjid);
begin
  self.Create();
  self.Jid:=jid;
end;

constructor TBind.CreateResource(resouce: string);
begin
  self.Create();
  self.Resource:=resource;
end;

function TBind.FGetJid: TJID;
begin
  Result:=TJID.Create(GetTag('jid'));
end;

function TBind.FGetResource: string;
begin
  Result:=GetTag('resource');
end;

procedure TBind.FSetJId(value: TJID);
begin
  settag('jid',value.ToString);
end;

procedure TBind.FSetResource(value: string);
begin
  settag('resource',value);
end;

end.
