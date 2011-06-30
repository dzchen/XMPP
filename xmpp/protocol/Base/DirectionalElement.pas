unit DirectionalElement;

interface
uses
  NativeXml,jid;
type
  TDirectionalElement=class(TsdElement)
  private
    doc:TNativeXml;
    procedure FSetToJid(jid:Tjid);
    function FGetToJid():TJID;
    procedure FSetFromJid(jid:Tjid);
    function fGetFromJid():TJID;

  public
    constructor Create(tag,ns:string);
    procedure SwitchDirection();
    property FromJid:TJid read fGetFromJid write FSetFromJid;
    property ToJid:Tjid read FGetToJid write FSetToJid;
    function ToString():string;
  end;

implementation

{ TDirectionalElement }

constructor TDirectionalElement.Create(tag, ns: string);
begin

end;

function TDirectionalElement.fGetFromJid: TJID;
begin

end;

function TDirectionalElement.FGetToJid: TJID;
begin

end;

procedure TDirectionalElement.FSetFromJid(jid: Tjid);
begin

end;

procedure TDirectionalElement.FSetToJid(jid: Tjid);
begin

end;

procedure TDirectionalElement.SwitchDirection;
begin

end;

function TDirectionalElement.ToString: string;
begin
result:=  doc.Root.WriteToString;
end;

end.
