unit Error;

interface
uses
  Element,NativeXml,XmppUri;
type
  TErrorCondition=(BadRequest,
		Conflict,
		FeatureNotImplemented,
		Forbidden,
		Gone,
		InternalServerError,
		ItemNotFound,
		JidMalformed,
		NotAcceptable,
		NotAllowed,
		NotAuthorized,
		PaymentRequired,
		RecipientUnavailable,
		Redirect,
		RegistrationRequired,
		RemoteServerNotFound,
		RemoteServerTimeout,
		ResourceConstraint,
		ServiceUnavailable,
		SubscriptionRequired,
		UndefinedCondition,
		UnexpectedRequest);
  TErrorType=(ETcancel,
		ETcontinue,
		ETmodify,
		ETauth,
		ETwait);
  TErrorCode=(
  /// <summary>
		/// Bad request
		/// </summary>
		RCBadRequest= 400,
		/// <summary>
		/// Unauthorized
		/// </summary>
		RCUnauthorized			= 401,
		/// <summary>
		/// Payment required
		/// </summary>
		RCPaymentRequired			= 402,
		/// <summary>
		/// Forbidden
		/// </summary>
		RCForbidden				= 403,
		/// <summary>
		/// Not found
		/// </summary>
		RCNotFound				= 404,
		/// <summary>
		/// Not allowed
		/// </summary>
		RCNotAllowed				= 405,
		/// <summary>
		/// Not acceptable
		/// </summary>
		RCNotAcceptable			= 406,
		/// <summary>
		/// Registration required
		/// </summary>
		RCRegistrationRequired	= 407,
		/// <summary>
		/// Request timeout
		/// </summary>
		RCRequestTimeout			= 408,
		/// <summary>
		/// Conflict
		/// </summary>
		RCConflict                = 409,
		/// <summary>
		/// Internal server error
		/// </summary>
		RCInternalServerError		= 500,
		/// <summary>
		/// Not implemented
		/// </summary>
		RCNotImplemented			= 501,
		/// <summary>
		/// Remote server error
		/// </summary>
		RCRemoteServerError		= 502,
		/// <summary>
		/// Service unavailable
		/// </summary>
		RCServiceUnavailable		= 503,
		/// <summary>
		/// Remote server timeout
		/// </summary>
		RCRemoteServerTimeout		= 504,
		/// <summary>
		/// Disconnected
		/// </summary>
		RCDisconnected            = 510
    );
  TError=class(TElement)
  private
    procedure FSetMessage(value:string);
    function FGetMessage():string;
    procedure FSetErrorCode(value:string);
    function FGetErrorCode():string;
    procedure FSetErrorType(value:string);
    function FGetErrorType():string;
    procedure FSetCondition(value:TErrorCondition);
    function FGetCondition():TErrorCondition;
  public
    constructor Create(AOwner:TNativeXml);overload;
    constructor Create(AOwner:TNativeXml;code:TErrorCode);overload;
    constructor Create(AOwner: TNativeXml;tp:TErrorType); override;
    constructor Create(AOwner: TNativeXml;condition:TErrorCondition); override;
    constructor Create(AOwner: TNativeXml;tp:TErrorType;condition:TErrorCondition); override;
    property Message:string read FGetMessage write FSetMessage;
    property Code:TErrorCode read FGetErrorCode write FSetErrorCode;
    property ErrorType:TErrorType read FGetErrorType write FSetErrorType;
    property Condition:TErrorCondition read FGetCondition write FSetCondition;

  end;

implementation

{ TError }

constructor TError.Create(AOwner: TNativeXml; code: TErrorCode);
begin
  inherited Create(AOwner);
  AttributeAdd('code',code);
end;

constructor TError.Create(AOwner: TNativeXml);
begin
  inherited Create(AOwner,'error');
  Namespace:=XMLNS_CLIENT;
end;

constructor TError.Create(AOwner: TNativeXml; tp: TErrorType);
begin
  inherited Create(AOwner);
  ErrorType:=tp;
end;

constructor TError.Create(AOwner: TNativeXml; tp: TErrorType;
  condition: TErrorCondition);
begin
  inherited Create(AOwner,tp);
  Condition:=condition;
end;

constructor TError.Create(AOwner: TNativeXml; condition: TErrorCondition);
begin
  inherited Create(AOwner);
  Condition:=condition;
end;

function TError.FGetCondition: TErrorCondition;
begin
  if (HasTag("bad-request"))					// <bad-request/>
					return ErrorCondition.BadRequest;
				else if (HasTag("conflict"))				// <conflict/>
					return ErrorCondition.Conflict;
				else if  (HasTag("feature-not-implemented"))// <feature-not-implemented/>
					return ErrorCondition.FeatureNotImplemented;
				else if (HasTag("forbidden"))				// <forbidden/>
					return ErrorCondition.Forbidden;
				else if (HasTag("gone"))					// <gone/>
					return ErrorCondition.Gone;
				else if (HasTag("internal-server-error"))	// <internal-server-error/>
					return ErrorCondition.InternalServerError;
				else if (HasTag("item-not-found"))			// <item-not-found/>
					return ErrorCondition.ItemNotFound;
				else if (HasTag("jid-malformed"))			// <jid-malformed/>
					return ErrorCondition.JidMalformed;
				else if (HasTag("not-acceptable"))			// <not-acceptable/>
					return ErrorCondition.NotAcceptable;
				else if (HasTag("not-authorized"))			// <not-authorized/>
					return ErrorCondition.NotAuthorized;
				else if (HasTag("payment-required"))		// <payment-required/>
					return ErrorCondition.PaymentRequired;
				else if (HasTag("recipient-unavailable"))	// <recipient-unavailable/>
					return ErrorCondition.RecipientUnavailable;
				else if (HasTag("redirect"))				// <redirect/>
					return ErrorCondition.Redirect;
				else if (HasTag("registration-required"))	// <registration-required/>
					return ErrorCondition.RegistrationRequired;
				else if (HasTag("remote-server-not-found"))	// <remote-server-not-found/>
					return ErrorCondition.RemoteServerNotFound;
				else if (HasTag("remote-server-timeout"))	// <remote-server-timeout/>
					return ErrorCondition.RemoteServerTimeout;
				else if (HasTag("resource-constraint"))		// <resource-constraint/>
					return ErrorCondition.ResourceConstraint;
				else if (HasTag("service-unavailable"))		// <service-unavailable/>
					return ErrorCondition.ServiceUnavailable;
				else if (HasTag("subscription-required"))	// <subscription-required/>
					return ErrorCondition.SubscriptionRequired;
				else if (HasTag("undefined-condition"))		// <undefined-condition/>
					return ErrorCondition.UndefinedCondition;
				else if (HasTag("unexpected-request"))		// <unexpected-request/>
					return ErrorCondition.UnexpectedRequest;
				else
 					return ErrorCondition.UndefinedCondition;
end;

function TError.FGetErrorCode: string;
begin

end;

function TError.FGetErrorType: string;
begin

end;

function TError.FGetMessage: string;
begin

end;

procedure TError.FSetCondition(value: TErrorCondition);
begin

end;

procedure TError.FSetErrorCode(value: string);
begin

end;

procedure TError.FSetErrorType(value: string);
begin

end;

procedure TError.FSetMessage(value: string);
begin

end;

end.
