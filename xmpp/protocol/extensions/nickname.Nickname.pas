unit nickname.Nickname;

interface
uses
  Element,NativeXml,XmppUri;
type
  TNickname=class(TElement)
  public
    constructor Create();override;
    constructor Create(nick:string);overload;
  end;
implementation

{ TNickname }

constructor TNickname.Create();
begin
  inherited Create();
  Name:='nick';
  Namespace:=XMLNS_NICK;
end;

constructor TNickname.Create(nick: string);
begin
  Self.Create();
  Value:=nick;
end;

end.
