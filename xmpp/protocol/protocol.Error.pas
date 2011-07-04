unit protocol.Error;

interface
uses
  Element,XMPPConst,XmppUri;
type
  TError=class(TElement)
  private
    function FGetCondition:TStreamErrorCondition;
    procedure FSetCondition(value:TStreamErrorCondition);
    function FGetText:string;
    procedure FSetText(value:string);
  public
    constructor Create;override;
    constructor Create(condition:TStreamErrorCondition);overload;
    property Condition:TStreamErrorCondition read FGetCondition write FSetCondition;
    property Text:string read FGetText write FSetText;
  end;

implementation

{ TError }

constructor TError.Create;
begin
  inherited Create;
  Name:='error';
  Namespace:=XMLNS_STREAM;
end;

constructor TError.Create(condition: TStreamErrorCondition);
begin
  self.Create;
  self.Condition:=condition;
end;

function TError.FGetCondition: TStreamErrorCondition;
begin
  if (HasTag('bad-format')) then
                    result:=TStreamErrorCondition.BadFormat
                else if (HasTag('bad-namespace-prefix')) then
                    result:=TStreamErrorCondition.BadNamespacePrefix
                else if (HasTag('conflict'))  then
                    result:=TStreamErrorCondition.Conflict
                else if (HasTag('connection-timeout')) then
                    result:=TStreamErrorCondition.ConnectionTimeout
                else if (HasTag('host-gone')) then
                    result:=TStreamErrorCondition.HostGone
                else if (HasTag('host-unknown')) then
                    result:=TStreamErrorCondition.HostUnknown
                else if (HasTag('improper-addressing')) then
                    result:=TStreamErrorCondition.ImproperAddressing
                else if (HasTag('internal-server-error')) then
                    result:=TStreamErrorCondition.InternalServerError
                else if (HasTag('invalid-from')) then
                    result:=TStreamErrorCondition.InvalidFrom
                else if (HasTag('invalid-id')) then
                    result:=TStreamErrorCondition.InvalidId
                else if (HasTag('invalid-namespace')) then
                    result:=TStreamErrorCondition.InvalidNamespace
                else if (HasTag('invalid-xml')) then
                    result:=TStreamErrorCondition.InvalidXml
                else if (HasTag('not-authorized')) then
                    result:=TStreamErrorCondition.NotAuthorized
                else if (HasTag('policy-violation')) then
                    result:=TStreamErrorCondition.PolicyViolation
                else if (HasTag('remote-connection-failed')) then
                    result:=TStreamErrorCondition.RemoteConnectionFailed
                else if (HasTag('resource-constraint')) then
                    result:=TStreamErrorCondition.ResourceConstraint
                else if (HasTag('restricted-xml')) then
                    result:=TStreamErrorCondition.RestrictedXml
                else if (HasTag('see-other-host'))  then
                    result:=TStreamErrorCondition.SeeOtherHost
                else if (HasTag('system-shutdown')) then
                    result:=TStreamErrorCondition.SystemShutdown
                else if (HasTag('undefined-condition')) then
                    result:=TStreamErrorCondition.UndefinedCondition
                else if (HasTag('unsupported-encoding')) then
                    result:=TStreamErrorCondition.UnsupportedEncoding
                else if (HasTag('unsupported-stanza-type')) then
                    result:=TStreamErrorCondition.UnsupportedStanzaType
                else if (HasTag('unsupported-version')) then
                    result:=TStreamErrorCondition.UnsupportedVersion
                else if (HasTag('xml-not-well-formed')) then
                    result:=TStreamErrorCondition.XmlNotWellFormed
                else
                    result:=TStreamErrorCondition.UnknownCondition;
end;

function TError.FGetText: string;
begin
  result:=GetTag('text');
end;

procedure TError.FSetCondition(value: TStreamErrorCondition);
begin
  case (value)of

                    TStreamErrorCondition.BadFormat:
                        SetTag('bad-format', '', XMLNS_STREAMS);

                    TStreamErrorCondition.BadNamespacePrefix:
                        SetTag('bad-namespace-prefix', '', XMLNS_STREAMS);

                    TStreamErrorCondition.Conflict:
                        SetTag('conflict', '', XMLNS_STREAMS);

                    TStreamErrorCondition.ConnectionTimeout:
                        SetTag('connection-timeout', '', XMLNS_STREAMS);

                    TStreamErrorCondition.HostGone:
                        SetTag('host-gone', '', XMLNS_STREAMS);

                    TStreamErrorCondition.HostUnknown:
                        SetTag('host-unknown', '', XMLNS_STREAMS);

                    TStreamErrorCondition.ImproperAddressing:
                        SetTag('improper-addressing', '', XMLNS_STREAMS);

                    TStreamErrorCondition.InternalServerError:
                        SetTag('internal-server-error', '', XMLNS_STREAMS);

                    TStreamErrorCondition.InvalidFrom:
                        SetTag('invalid-from', '', XMLNS_STREAMS);

                    TStreamErrorCondition.InvalidId:
                        SetTag('invalid-id', '', XMLNS_STREAMS);

                    TStreamErrorCondition.InvalidNamespace:
                        SetTag('invalid-namespace', '', XMLNS_STREAMS);

                    TStreamErrorCondition.InvalidXml:
                        SetTag('invalid-xml', '', XMLNS_STREAMS);

                    TStreamErrorCondition.NotAuthorized:
                        SetTag('not-authorized', '', XMLNS_STREAMS);

                    TStreamErrorCondition.PolicyViolation:
                        SetTag('policy-violation', '', XMLNS_STREAMS);

                    TStreamErrorCondition.RemoteConnectionFailed:
                        SetTag('remote-connection-failed', '', XMLNS_STREAMS);

                    TStreamErrorCondition.ResourceConstraint:
                        SetTag('resource-constraint', '', XMLNS_STREAMS);

                    TStreamErrorCondition.RestrictedXml:
                        SetTag('restricted-xml', '', XMLNS_STREAMS);

                    TStreamErrorCondition.SeeOtherHost:
                        SetTag('see-other-host', '', XMLNS_STREAMS);

                    TStreamErrorCondition.SystemShutdown:
                        SetTag('system-shutdown', '', XMLNS_STREAMS);

                    TStreamErrorCondition.UndefinedCondition:
                        SetTag('undefined-condition', '', XMLNS_STREAMS);

                    TStreamErrorCondition.UnsupportedEncoding:
                        SetTag('unsupported-encoding', '', XMLNS_STREAMS);

                    TStreamErrorCondition.UnsupportedStanzaType:
                        SetTag('unsupported-stanza-type', '', XMLNS_STREAMS);

                    TStreamErrorCondition.UnsupportedVersion:
                        SetTag('unsupported-version', '', XMLNS_STREAMS);

                    TStreamErrorCondition.XmlNotWellFormed:
                        SetTag('xml-not-well-formed', '', XMLNS_STREAMS);

                   end;
end;

procedure TError.FSetText(value: string);
begin
  SetTag('text',value,XMLNS_STREAMS);
end;

end.
