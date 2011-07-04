unit Exceptions;

interface
uses
  SysUtils;
type
  TJidException=class(Exception)
  public
    constructor Create; overload;
    constructor Create(msg:string);overload;
  end;
  TRegisterException=class(Exception)
  public
    constructor Create; overload;
    constructor Create(msg:string);overload;
  end;
  TXmlRpcException=class(Exception)
  private
    _code:integer;
  public
    constructor Create; overload;
    constructor Create(msg:string);overload;
    constructor Create(code:Integer;msg:string);overload;
    property Code:Integer read _code write _code;
  end;
  TStringprepException=class(Exception)
  public
    constructor Create(msg:string);overload;
  const
    CONTAINS_UNASSIGNED:string='Contains unassigned code points.';
    CONTAINS_PROHIBITED:string='Contains prohibited code points.';
    BIDI_BOTHRAL:string='Contains both R and AL code points.';
    BIDI_LTRAL:string='Leading and trailing code points not both R or AL.';
  end;
  TPunycodeException=class(Exception)
  public
    constructor Create(msg:string);overload;
  const
    OVERFLOW:string   = 'Overflow.';
    BAD_INPUT:string  = 'Bad input.';
  end;
  TIDNAException=class(Exception)
  public
    constructor Create(msg:string);overload;
    constructor Create(e:TStringprepException);overload;
    constructor Create(e:TPunycodeException);overload;
  const
    CONTAINS_NON_LDH:string		= 'Contains non-LDH characters.';
    CONTAINS_HYPHEN:string		= 'Leading or trailing hyphen not allowed.';
    CONTAINS_ACE_PREFIX:string	= 'ACE prefix (xn--) not allowed.';
    TOO_LONG:string				= 'String too long.';
  end;

implementation

{ TJidException }

constructor TJidException.Create;
begin

end;

constructor TJidException.Create(msg: string);
begin
  inherited Create(msg);

end;

{ TRegisterException }

constructor TRegisterException.Create;
begin

end;

constructor TRegisterException.Create(msg: string);
begin
  inherited Create(msg);

end;

{ TXmlRpcException }

constructor TXmlRpcException.Create;
begin

end;

constructor TXmlRpcException.Create(msg: string);
begin
  inherited Create(msg);

end;

constructor TXmlRpcException.Create(code: Integer; msg: string);
begin
  inherited Create(msg);
  _code:=code;
end;

{ TStringprepException }

constructor TStringprepException.Create(msg: string);
begin
  inherited Create(msg);
end;

{ TPunycodeException }

constructor TPunycodeException.Create(msg: string);
begin
  inherited Create(msg);
end;

{ TIDNAException }

constructor TIDNAException.Create(msg: string);
begin
  inherited Create(msg);
end;

constructor TIDNAException.Create(e: TStringprepException);
begin

end;

constructor TIDNAException.Create(e: TPunycodeException);
begin

end;

end.
