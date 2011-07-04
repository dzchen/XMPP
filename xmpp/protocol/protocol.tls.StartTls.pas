unit protocol.tls.StartTls;

interface
uses
  Element,XmppUri;
type
  TStartTls=class(TElement)
  private
    function FGetRequired:Boolean;
    procedure FSetRequired(value:Boolean);
  public
    constructor Create;override;
    property Required:Boolean read FGetRequired write FSetRequired;

  end;
  TProceed=class(TElement)
  public
    constructor Create;override;
  end;
implementation

{ TStartTls }

constructor TStartTls.Create;
begin
  inherited Create;
  Name:='starttls';
  Namespace:=XMLNS_TLS;
end;

function TStartTls.FGetRequired: Boolean;
begin
  Result:=HasTag('required');
end;

procedure TStartTls.FSetRequired(value: Boolean);
begin
  if value=False then
  begin
    RemoveTag('required');

  end
  else
    if not HasTag('required') then
      SetTag('required');
end;

{ TProceed }

constructor TProceed.Create;
begin
  inherited;
  Name:='proceed';
  Namespace:=XMLNS_TLS;
end;

end.
