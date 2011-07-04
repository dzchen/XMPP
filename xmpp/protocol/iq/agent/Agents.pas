unit Agents;

interface
uses
  Element,XmppUri,NativeXml,Classes;
type
  TAgents=class(TElement)
  public
    constructor Create();override;
    procedure GetAgents(al:TList);
  end;

implementation

{ TAgents }

constructor TAgents.Create;
begin
  inherited Create();
  Name:='query';
  Namespace:=XMLNS_IQ_AGENTS;
end;

procedure TAgents.GetAgents(al: TList);
begin
  FindNodes('agent',al);
end;

end.
