unit XmppUri;

interface
const
    XMLNS_STREAM			= 'http://etherx.jabber.org/streams';
		XMLNS_CLIENT			= 'jabber:client';
		XMLNS_SERVER			= 'jabber:server';

		XMLNS_IQ_AGENTS		= 'jabber:iq:agents';
		XMLNS_IQ_ROSTER		= 'jabber:iq:roster';
		XMLNS_IQ_AUTH			= 'jabber:iq:auth';
		XMLNS_IQ_REGISTER		= 'jabber:iq:register';
		XMLNS_IQ_OOB			= 'jabber:iq:oob';
		XMLNS_IQ_LAST			= 'jabber:iq:last';
		XMLNS_IQ_TIME			= 'jabber:iq:time';
		XMLNS_IQ_VERSION		= 'jabber:iq:version';
		XMLNS_IQ_BROWSE		= 'jabber:iq:browse';
		XMLNS_IQ_SEARCH		= 'jabber:iq:search';
		XMLNS_IQ_AVATAR		= 'jabber:iq:avatar';
		XMLNS_IQ_PRIVATE		= 'jabber:iq:private';
    XMLNS_IQ_PRIVACY      = 'jabber:iq:privacy';



        /// <summary>
        /// JEP-0009: Jabber-RPC
        /// </summary>
    XMLNS_IQ_RPC          = 'jabber:iq:rpc';


		XMLNS_X_DELAY			= 'jabber:x:delay';
		XMLNS_X_EVENT			= 'jabber:x:event';
		XMLNS_X_AVATAR		= 'jabber:x:avatar';


		XMLNS_X_CONFERENCE	= 'jabber:x:conference';

        /// <summary>
        /// jabber:x:data
		/// </summary>
        XMLNS_X_DATA			= 'jabber:x:data';

		/// <summary>
		/// JEP-0144 Roster Item Exchange
		/// </summary>
		XMLNS_X_ROSTERX		= 'http://jabber.org/protocol/rosterx';


		/// <summary>
        /// Multi User Chat (MUC) JEP-0045
        /// http://jabber.org/protocol/muc
		/// </summary>
		XMLNS_MUC				= 'http://jabber.org/protocol/muc';
		/// <summary>
		/// http://jabber.org/protocol/muc#user
		/// </summary>
		XMLNS_MUC_USER		= 'http://jabber.org/protocol/muc#user';
		/// <summary>
		/// 'http://jabber.org/protocol/muc#admin
		/// </summary>
		XMLNS_MUC_ADMIN		= 'http://jabber.org/protocol/muc#admin';
		/// <summary>
		/// http://jabber.org/protocol/muc#owner
		/// </summary>
		XMLNS_MUC_OWNER		= 'http://jabber.org/protocol/muc#owner';

		// Service Disovery
		XMLNS_DISCO_ITEMS		= 'http://jabber.org/protocol/disco#items';
		XMLNS_DISCO_INFO		= 'http://jabber.org/protocol/disco#info';

		XMLNS_STORAGE_AVATAR	= 'storage:client:avatar';

		XMLNS_VCARD			= 'vcard-temp';

		// New XMPP Stuff
        /// <summary>
        /// urn:ietf:params:xml:ns:xmpp-streams
        /// </summary>
        XMLNS_STREAMS         = 'urn:ietf:params:xml:ns:xmpp-streams';
        XMLNS_STANZAS			= 'urn:ietf:params:xml:ns:xmpp-stanzas';
		XMLNS_TLS				= 'urn:ietf:params:xml:ns:xmpp-tls';
		XMLNS_SASL			= 'urn:ietf:params:xml:ns:xmpp-sasl';
		XMLNS_SESSION			= 'urn:ietf:params:xml:ns:xmpp-session';
		XMLNS_BIND			= 'urn:ietf:params:xml:ns:xmpp-bind';


        /// <summary>
        /// jabber:component:accept
        /// </summary>
		XMLNS_ACCEPT			= 'jabber:component:accept';

		// Features
		//<register xmlns='http://jabber.org/features/iq-register'/>
		XMLNS_FEATURE_IQ_REGISTER	= 'http://jabber.org/features/iq-register';
        /// <summary>
        /// Stream Compression http://jabber.org/features/compress
        /// </summary>
        XMLNS_FEATURE_COMPRESS    = 'http://jabber.org/features/compress';

		// Extensions (JEPs)
		XMLNS_SHIM				= 'http://jabber.org/protocol/shim';
		XMLNS_PRIMARY				= 'http://jabber.org/protocol/primary';
        /// <summary>
        /// JEP-0172 User nickname
        /// http://jabber.org/protocol/nick
        /// </summary>
        XMLNS_NICK                = 'http://jabber.org/protocol/nick';

        /// <summary>
        /// JEP-0085 Chat State Notifications
        /// http://jabber.org/protocol/chatstates
        /// </summary>
        XMLNS_CHATSTATES          = 'http://jabber.org/protocol/chatstates';

        /// <summary>
        /// JEP-0138: Stream Compression
        /// </summary>
        XMLNS_COMPRESS            = 'http://jabber.org/protocol/compress';

		/// <summary>
		/// JEP-0020: Feature Negotiation http://jabber.org/protocol/feature-neg
		/// </summary>
		XMLNS_FEATURE_NEG			= 'http://jabber.org/protocol/feature-neg';

		/// <summary>
		/// JEO-0095 http://jabber.org/protocol/si
		/// </summary>
		XMLNS_SI					= 'http://jabber.org/protocol/si';
		/// <summary>
		/// JEO-0096 http://jabber.org/protocol/si/profile/file-transfer
		/// </summary>
		XMLNS_SI_FILE_TRANSFER	= 'http://jabber.org/protocol/si/profile/file-transfer';

        /// <summary>
        /// JEP-0065 SOCKS5 bytestreams
        /// http://jabber.org/protocol/bytestreams
        /// </summary>
        XMLNS_BYTESTREAMS         = 'http://jabber.org/protocol/bytestreams';

		// JEP-0083
		XMLNS_ROSTER_DELIMITER	= 'roster:delimiter';

        // Jive Software Namespaces

        /// <summary>
        /// Jivesoftware asterisk-im extension (http://jivesoftware.com/xmlns/phone);
        /// </summary>
        XMLNS_JIVESOFTWARE_PHONE  = 'http://jivesoftware.com/xmlns/phone';

        /// <summary>
        /// JEP-0071: XHTML-IM (http://jivesoftware.com/xmlns/phone)
        /// </summary>
        XMLNS_XHTML_IM            = 'http://jabber.org/protocol/xhtml-im';
        XMLNS_XHTML			    = 'http://www.w3.org/1999/xhtml';


        /// <summary>
        /// XEP-0115: Entity Capabilities (http://jabber.org/protocol/caps)
        /// </summary>
        XMLNS_CAPS                = 'http://jabber.org/protocol/caps';

        /// <summary>
        /// Jingle http://jabber.org/protocol/jingle
        /// </summary>
        XMLNS_JINGLE                  = 'http://jabber.org/protocol/jingle';

        /// <summary>
        /// Jingle audio format description http://jabber.org/protocol/jingle/description/audio
        /// </summary>
        XMLNS_JINGLE_AUDIO_DESCRIPTION = 'http://jabber.org/protocol/jingle/description/audio';

        /// <summary>
        /// Jingle Info audio http://jabber.org/protocol/jingle/info/audio;
        /// </summary>
        XMLNS_JINGLE_AUDIO_INFO        = 'http://jabber.org/protocol/jingle/info/audio';


        XMLNS_JINGLE_VIDEO_DESCRIPTION = 'http://jabber.org/protocol/jingle/description/video';

        /// <summary>
        /// GeoLoc (http://jabber.org/protocol/geoloc)
        /// </summary>
        XMLNS_GEOLOC              = 'http://jabber.org/protocol/geoloc';

        /// <summary>
        /// <para>XMPP ping</para>
        /// <para>Namespace: urn:xmpp:ping</para>
        /// <para><seealso cref='http://www.xmpp.org/extensions/xep-0199.html'>http://www.xmpp.org/extensions/xep-0199.html</seealso></para>
        /// </summary>
        XMLNS_PING                = 'urn:xmpp:ping';

        /// <summary>
        /// Ad-Hoc Commands (http://jabber.org/protocol/commands)
        /// </summary>
        XMLNS_COMMANDS            = 'http://jabber.org/protocol/commands';

        // Pubsub stuff
        XMLNS_PUBSUB              = 'http://jabber.org/protocol/pubsub';
        XMLNS_PUBSUB_EVENT        = 'http://jabber.org/protocol/pubsub#event';
        XMLNS_PUBSUB_OWNER        = 'http://jabber.org/protocol/pubsub#owner';

        // Http-Binding XEP-0124
        XMLNS_HTTP_BIND           = 'http://jabber.org/protocol/httpbind';

        /// <summary>
        /// <para>XEP-0184: Message Receipts</para>
        /// <para>urn:xmpp:receipts</para>
        /// </summary>
        XMLNS_MSG_RECEIPT         = 'urn:xmpp:receipts';

        /// <summary>
        /// <para>XEP-0048: Bookmark Storage</para>
        /// <para>storage:bookmarks</para>
        /// </summary>
        XMLNS_STORAGE_BOOKMARKS   = 'storage:bookmarks';

        /// <summary>
        /// <para>XEP-0047: In-Band Bytestreams (IBB)</para>
        /// <para>http://jabber.org/protocol/ibb</para>
        /// </summary>
        XMLNS_IBB                 = 'http://jabber.org/protocol/ibb';

        /// <summary>
        /// <para></para>
        /// <para>http://jabber.org/protocol/amp</para>
        /// </summary>
        XMLNS_AMP                 = 'http://jabber.org/protocol/amp';

        /// <summary>
        /// <para>XEP-0153: vCard-Based Avatars</para>
        /// <para>vcard-temp:x:update</para>
        /// </summary>
        XMLNS_VCARD_UPDATE        = 'vcard-temp:x:update';

implementation

end.
