unit Xml.xpnet.Exception;

interface
uses
  SysUtils,XMPPConst;
type
  TTokenException=class(exception)
  public
    constructor Create;
  end;
  TEmptyTokenException=class(TTokenException);
  TEndOfPrologException=class(TTokenException);
  TExtensibleTokenException=class(TTokenException)
  private
    _toktype:TOK;
  public
    constructor Create(toktype:TOK);overload;
    property TokenType:TOK read _toktype;
  end;
  TInvalidTokenException=class(TTokenException)
  const
    ILLEGAL_CHAR:byte=0;
    XML_TARGET:byte=1;
    DUPLICATE_ATTRIBUTE:byte=2;
  private
    _offset:integer;
    _type:Byte;
    function FGetType:integer;

  public
    constructor Create(offset:integer;tp:Byte);overload;
    constructor Create(offset:integer);overload;
    property Offset:Integer read _offset;
    property EXType:Integer read FGetType;
  end;
  TPartialTokenException=class(TTokenException);
  TPartialCharException=class(TPartialTokenException)
  private
    _leadByteIndex:integer;
  public
    constructor Create(leadbyteindex:Integer);overload;
    property LeadByteIndex:Integer read _leadByteIndex;
  end;
implementation

{ TExtensibleTokenException }

constructor TExtensibleTokenException.Create(toktype: TOK);
begin
  Self._toktype:=toktype;
end;

{ TInvalidTokenException }

constructor TInvalidTokenException.Create(offset: integer; tp: Byte);
begin
  self._offset:=offset;
  self._type:=tp;
end;

constructor TInvalidTokenException.Create(offset: integer);
begin
  self._offset:=offset;
  self._type:=ILLEGAL_CHAR;
end;

function TInvalidTokenException.FGetType:integer;
begin
  Result:=Integer(_type);
end;

{ TPartialCharException }

constructor TPartialCharException.Create(leadbyteindex: Integer);
begin
  self._leadByteIndex:=leadbyteindex;
end;

{ TTokenException }

constructor TTokenException.Create;
begin
  inherited Create('Exception');
end;

end.
