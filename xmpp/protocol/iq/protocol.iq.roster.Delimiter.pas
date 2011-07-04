unit protocol.iq.roster.Delimiter;

interface
uses
  Element,XmppUri;
type
  TDelimiter=class(TElement)
  public
    constructor Create;overload;override;
    constructor Create(delimiter:string);overload;
  end;

implementation

{ TDelimiter }

constructor TDelimiter.Create;
begin
  inherited Create;
  Name:='roster';
  Namespace:=XMLNS_ROSTER_DELIMITER;
end;

constructor TDelimiter.Create(delimiter: string);
begin
  Self.Create;
  self.Value:=delimiter;
end;

end.
