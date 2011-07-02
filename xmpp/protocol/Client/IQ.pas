unit IQ;

interface
uses
  Stanza,NativeXml,jid;
type
  TIqType=(iqget,
		iqset,
		iqresult,
		iqerror);
  TIQ=class(TStanza)
  private
    procedure FSetIqType(value:TIqType);
    function FGetIqType:TIqType;
  public
    constructor Create(AOwner:TNativeXml);overload;
    constructor Create(AOwner:TNativeXml;iqtype:TIqType);overload;
    constructor Create(AOwner:TNativeXml;fromjid:TJID;tojid:TJID);overload;
    constructor Create(AOwner:TNativeXml;iqtype:TIqType;fromjid:TJID;tojid:TJID);overload;
    property IqType: TIqType read FGetIqType write FSetIqType;
  end;
implementation
  //
end.
