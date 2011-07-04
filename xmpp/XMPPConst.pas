unit XMPPConst;

interface
uses
  NativeXml;
type
TXmppConnectionState=(
   /// <summary>
        /// Session is Disconnected
        /// </summary>
        Disconnected,

        /// <summary>
        /// The Socket is Connecting
        /// </summary>
        Connecting,

        /// <summary>
        /// The Socket is Connected
        /// </summary>
        Connected,
        /// <summary>
        /// The XMPP Session is authenticating
        /// </summary>
        Authenticating,
        /// <summary>
        /// The XMPP session is autrhenticated
        /// </summary>
        Authenticated,

        /// <summary>
        /// Resource Binding gets started
        /// </summary>
        Binding,

        /// <summary>
        /// Resource Binded with sucess
        /// </summary>
        Binded,

        StartSession,

        /// <summary>
        /// Initialize Stream Compression
        /// </summary>
        StartCompression,

        /// <summary>
        /// Stream is compressed now
        /// </summary>
        Compressed,

        SessionStarted,

        /// <summary>
        /// We are switching from a normal connection to a secure SSL connection (StartTLS)
        /// </summary>
        Securing,

        /// <summary>
        /// started the progress to register a new account
        /// </summary>
        Registering,

        /// <summary>
        /// Account was registered successful
        /// </summary>
        Registered
        );
     TSocketConnectionType=(
  /// <summary>
		/// Direct TCP/IP Connection
		/// </summary>
		Direct,
		/// <summary>
		/// A HTTP Polling Socket connection (JEP-0025)
		/// </summary>
		HttpPolling,

        /// <summary>
        /// <para>XEP-0124: Bidirectional-streams Over Synchronous HTTP (BOSH)</para>
        /// <para>http://www.xmpp.org/extensions/xep-0124.html</para>
        /// </summary>
        Bosh
        );
  TFieldType=(
  /// <summary>
		/// a unknown fieldtype
		/// </summary>
		FTUnknown,

		/// <summary>
		/// The field enables an entity to gather or provide an either-or choice between two options. The allowable values are 1 for yes/true/assent and 0 for no/false/decline. The default value is 0.
		/// </summary>
		FTBoolean,

		/// <summary>
		/// The field is intended for data description (e.g., human-readable text such as "section" headers) rather than data gathering or provision. The <value/> child SHOULD NOT contain newlines (the \n and \r characters); instead an application SHOULD generate multiple fixed fields, each with one <value/> child.
		/// </summary>
		FTFixed,

		/// <summary>
		///	The field is not shown to the entity providing information, but instead is returned with the form.
		///	</summary>
		FTHidden,

		/// <summary>
		/// The field enables an entity to gather or provide multiple Jabber IDs.
		/// </summary>
		FTJid_Multi,

		/// <summary>
		/// The field enables an entity to gather or provide a single Jabber ID.
		/// </summary>
		FTJid_Single,

		/// <summary>
		/// The field enables an entity to gather or provide one or more options from among many.
		/// </summary>
		FTList_Multi,

		/// <summary>
		/// The field enables an entity to gather or provide one option from among many.
		/// </summary>
		FTList_Single,

		/// <summary>
		/// The field enables an entity to gather or provide multiple lines of text.
		/// </summary>
		FTText_Multi,

		/// <summary>
		/// password style textbox.
		/// The field enables an entity to gather or provide a single line or word of text, which shall be obscured in an interface (e.g., *****).
		/// </summary>
		FTText_Private,

		/// <summary>
		/// The field enables an entity to gather or provide a single line or word of text, which may be shown in an interface. This field type is the default and MUST be assumed if an entity receives a field type it does not understand.
		/// </summary>
		FTText_Single
    );
    TIqType=(itget,itset,itresult,iterror);
    TXDataFormType=
	(
		/// <summary>
		/// The forms-processing entity is asking the forms-submitting entity to complete a form.
		/// </summary>
		xdftform,
		/// <summary>
		/// The forms-submitting entity is submitting data to the forms-processing entity.
		/// </summary>
		xdftsubmit,
		/// <summary>
		/// The forms-submitting entity has cancelled submission of data to the forms-processing entity.
		/// </summary>
		xdftcancel,
		/// <summary>
		/// The forms-processing entity is returning data (e.g., search results) to the forms-submitting entity, or the data is a generic data set.
		/// </summary>
		xdftresult
	);
  TMechanismType=
	(
		MTNONE = 0,
		MTKERBEROS_V4,
		MTGSSAPI,
		MTSKEY,
		MTEXTERNAL,
		MTCRAM_MD5,
		MTANONYMOUS,
		MTOTP,
		MTGSS_SPNEGO,
		MTPLAIN,
		MTSECURID,
		MTNTLM,
		MTNMAS_LOGIN,
		MTNMAS_AUTHEN,
		MTDIGEST_MD5,
		MTISO_9798_U_RSA_SHA1_ENC,
		MTISO_9798_M_RSA_SHA1_ENC,
		MTISO_9798_U_DSA_SHA1,
		MTISO_9798_M_DSA_SHA1,
		MTISO_9798_U_ECDSA_SHA1,
		MTISO_9798_M_ECDSA_SHA1,
		MTKERBEROS_V5,
		MTNMAS_SAMBA_AUTH,
        MTX_GOOGLE_TOKEN
	);
  TStreamErrorCondition=
    (
        /// <summary>
        /// unknown error condition
        /// </summary>
        UnknownCondition        = -1,


        /// <summary>
        /// the entity has sent XML that cannot be processed; this error MAY be used instead of the more specific XML-related errors, such as &lt;bad-namespace-prefix/&gt;, &lt;invalid-xml/&gt;, &lt;restricted-xml/&gt;, &lt;unsupported-encoding/&gt;, and &lt;xml-not-well-formed/&gt;, although the more specific errors are preferred.
        /// </summary>
        BadFormat,

        /// <summary>
        /// the entity has sent a namespace prefix that is unsupported, or has sent no namespace prefix on an element that requires such a prefix (see XML Namespace Names and Prefixes (XML Namespace Names and Prefixes)).
        /// </summary>
        BadNamespacePrefix,

        /// <summary>
        /// the server is closing the active stream for this entity because a new stream has been initiated that conflicts with the existing stream.
        /// </summary>
        Conflict,

        /// <summary>
        /// the entity has not generated any traffic over the stream for some period of time (configurable according to a local service policy).
        /// </summary>
        ConnectionTimeout,

        /// <summary>
        /// the value of the 'to' attribute provided by the initiating entity in the stream header corresponds to a hostname that is no longer hosted by the server.
        /// </summary>
        HostGone,

        /// <summary>
        /// the value of the 'to' attribute provided by the initiating entity in the stream header does not correspond to a hostname that is hosted by the server.
        /// </summary>
        HostUnknown,

        /// <summary>
        /// a stanza sent between two servers lacks a 'to' or 'from' attribute (or the attribute has no value).
        /// </summary>
        ImproperAddressing,

        /// <summary>
        /// the server has experienced a misconfiguration or an otherwise-undefined internal error that prevents it from servicing the stream.
        /// </summary>
        InternalServerError,

        /// <summary>
        /// the JID or hostname provided in a 'from' address does not match an authorized JID or validated domain negotiated between servers via SASL or dialback, or between a client and a server via authentication and resource binding.
        /// </summary>
        InvalidFrom,

        /// <summary>
        /// the stream ID or dialback ID is invalid or does not match an ID previously provided.
        /// </summary>
        InvalidId,

        /// <summary>
        /// the streams namespace name is something other than "http://etherx.jabber.org/streams" or the dialback namespace name is something other than "jabber:server:dialback" (see XML Namespace Names and Prefixes (XML Namespace Names and Prefixes)).
        /// </summary>
        InvalidNamespace,

        /// <summary>
        /// the entity has sent invalid XML over the stream to a server that performs validation.
        /// </summary>
        InvalidXml,

        /// <summary>
        /// the entity has attempted to send data before the stream has been authenticated, or otherwise is not authorized to perform an action related to stream negotiation; the receiving entity MUST NOT process the offending stanza before sending the stream error.
        /// </summary>
        NotAuthorized,

        /// <summary>
        /// the entity has violated some local service policy; the server MAY choose to specify the policy in the &lt;text/&gt; element or an application-specific condition element.
        /// </summary>
        PolicyViolation,

        /// <summary>
        /// the server is unable to properly connect to a remote entity that is required for authentication or authorization.
        /// </summary>
        RemoteConnectionFailed,

        /// <summary>
        /// the server lacks the system resources necessary to service the stream.
        /// </summary>
        ResourceConstraint,

        /// <summary>
        /// the entity has attempted to send restricted XML features such as a comment, processing instruction, DTD, entity reference, or unescaped character (see Restrictions (Restrictions)).
        /// </summary>
        RestrictedXml,

        /// <summary>
        /// the server will not provide service to the initiating entity but is redirecting traffic to another host; the server SHOULD specify the alternate hostname or IP address (which MUST be a valid domain identifier) as the XML character data of the &lt;see-other-host/&gt; element.
        /// </summary>
        SeeOtherHost,

        /// <summary>
        /// the server is being shut down and all active streams are being closed.
        /// </summary>
        SystemShutdown,

        /// <summary>
        /// the error condition is not one of those defined by the other conditions in this list; this error condition SHOULD be used only in conjunction with an application-specific condition.
        /// </summary>
        UndefinedCondition,

        /// <summary>
        /// the initiating entity has encoded the stream in an encoding that is not supported by the server.
        /// </summary>
        UnsupportedEncoding,

        /// <summary>
        /// the initiating entity has sent a first-level child of the stream that is not supported by the server.
        /// </summary>
        UnsupportedStanzaType,

        /// <summary>
        /// the value of the 'version' attribute provided by the initiating entity in the stream header specifies a version of XMPP that is not supported by the server; the server MAY specify the version(s) it supports in the &lt;text/&gt; element.
        /// </summary>
        UnsupportedVersion,

        /// <summary>
        /// the initiating entity has sent XML that is not well-formed as defined by the XML specs.
        /// </summary>
        XmlNotWellFormed
    );
    TOK=
    (
        DATA_CHARS,//Represents one or more characters of data.
        DATA_NEWLINE,//Represents a newline (CR, LF or CR followed by LF) in data.
        START_TAG_NO_ATTS,//Represents a complete start-tag <code>&lt;name&gt;</code>,that doesn't have any attribute specifications.
        START_TAG_WITH_ATTS,//Represents a complete start-tag <code>&lt;nameatt="val"&gt;</code>, that contains one or more attribute specifications.
        EMPTY_ELEMENT_NO_ATTS,//Represents an empty element tag <code>&lt;name/&gt;</code>,that doesn't have any attribute specifications.
        EMPTY_ELEMENT_WITH_ATTS,//Represents an empty element tag <code>&lt;name att="val"/&gt;</code>, that contains one or more attribute specifications.
        END_TAG,//Represents a complete end-tag <code>&lt;/name&gt;</code>.
        CDATA_SECT_OPEN,//Represents the start of a CDATA section <code>&lt;![CDATA[</code>.
        CDATA_SECT_CLOSE,//Represents the end of a CDATA section <code>]]&gt;</code>.
        ENTITY_REF,//Represents a general entity reference.
        MAGIC_ENTITY_REF,//Represents a general entity reference to a one of the 5 predefined entities <code>amp</code>, <code>lt</code>, <code>gt</code>, <code>quot</code>, <code>apos</code>.
        CHAR_REF,//Represents a numeric character reference (decimal or hexadecimal), when the referenced character is less than or equal to 0xFFFF and so is represented by a single char.
        CHAR_PAIR_REF,//Represents a numeric character reference (decimal or hexadecimal), when the referenced character is greater than 0xFFFF and so is represented by a pair of chars.
        PI,//Represents a processing instruction.
        XML_DECL,//Represents an XML declaration or text declaration (a processing instruction whose target is <code>xml</code>).
        COMMENT,//Represents a comment <code>&lt;!-- comment --&gt;</code>. This can occur both in the prolog and in content.
        ATTRIBUTE_VALUE_S,//Represents a white space character in an attribute value, excluding white space characters that are part of line boundaries.
        PARAM_ENTITY_REF,//Represents a parameter entity reference in the prolog.
        PROLOG_S,//Represents whitespace in the prolog.The token contains one or more whitespace characters.
        DECL_OPEN,//Represents <code>&lt;!NAME</code> in the prolog.
        DECL_CLOSE,//Represents <code>&gt;</code> in the prolog.
        NAME,//Represents a name in the prolog.
        NMTOKEN,//Represents a name token in the prolog that is not a name.
        POUND_NAME,//Represents <code>#NAME</code> in the prolog.
        tokOR,//Represents <code>|</code> in the prolog.
        PERCENT,//Represents a <code>%</code> in the prolog that does not start a parameter entity reference. This can occur in an entity declaration.
        OPEN_PAREN,//Represents a <code>(</code> in the prolog.
        CLOSE_PAREN,//Represents a <code>)</code> in the prolog that is not followed immediately by any of <code>*</code>, <code>+</code> or <code>?</code>.
        OPEN_BRACKET,//Represents <code>[</code> in the prolog.
        CLOSE_BRACKET,//Represents <code>]</code> in the prolog.
        LITERAL,//Represents a literal (EntityValue, AttValue, SystemLiteral or PubidLiteral).
        NAME_QUESTION,//Represents a name followed immediately by <code>?</code>.
        NAME_ASTERISK,//Represents a name followed immediately by <code>*</code>.
        NAME_PLUS,//Represents a name followed immediately by <code>+</code>.
        COND_SECT_OPEN,//Represents <code>&lt;![</code> in the prolog.
        COND_SECT_CLOSE,//Represents <code>]]&gt;</code> in the prolog.
        CLOSE_PAREN_QUESTION,//Represents <code>)?</code> in the prolog.
        CLOSE_PAREN_ASTERISK,//Represents <code>)*</code> in the prolog.
        CLOSE_PAREN_PLUS,//Represents <code>)+</code> in the prolog.
        COMMA//Represents <code>,</code> in the prolog.
    );
    TFailureCondition=
    (

        /// <summary>
        /// The receiving entity acknowledges an <abort/> element sent by the initiating entity; sent in reply to the <abort/> element.
        /// </summary>
        fcaborted,

        /// <summary>
        /// The data provided by the initiating entity could not be processed because the [BASE64] (Josefsson, S., “The Base16, Base32, and Base64 Data Encodings,?July 2003.) encoding is incorrect (e.g., because the encoding does not adhere to the definition in Section 3 of [BASE64] (Josefsson, S., “The Base16, Base32, and Base64 Data Encodings,?July 2003.)); sent in reply to a <response/> element or an <auth/> element with initial response data.
        /// </summary>
        fcincorrect_encoding,

        /// <summary>
        /// The authzid provided by the initiating entity is invalid, either because it is incorrectly formatted or because the initiating entity does not have permissions to authorize that ID; sent in reply to a <response/> element or an <auth/> element with initial response data.
        /// </summary>
        fcinvalid_authzid,

        /// <summary>
        /// The initiating entity did not provide a mechanism or requested a mechanism that is not supported by the receiving entity; sent in reply to an <auth/> element.
        /// </summary>
        fcinvalid_mechanism,

        /// <summary>
        /// The mechanism requested by the initiating entity is weaker than server policy permits for that initiating entity; sent in reply to a <response/> element or an <auth/> element with initial response data.
        /// </summary>
        fcmechanism_too_weak,

        /// <summary>
        /// The authentication failed because the initiating entity did not provide valid credentials (this includes but is not limited to the case of an unknown username); sent in reply to a <response/> element or an <auth/> element with initial response data.
        /// </summary>
        fcnot_authorized,

        /// <summary>
        /// The authentication failed because of a temporary error condition within the receiving entity; sent in reply to an <auth/> element or <response/> element.
        /// </summary>
        fctemporary_auth_failure,

        fcUnknownCondition
    );
    TAmpCondition=(ampUnknown         = -1,
        ampDeliver,
        ampExprireAt,
        ampMatchResource);
    TNodeType=
	(
		NTDocument,	// xmlDocument
		NTElement,	// normal Element
		NTText,		// Textnode
		NTCdata,		// CDATA Section
		NTComment,	// comment
		NTDeclaration	// processing instruction
	);
const
    CIqType:array[TIqType] of string=('get','set','result','error');
var
  xmldoc:TNativeXml;
implementation

end.
