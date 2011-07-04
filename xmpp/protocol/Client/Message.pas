unit Message;

interface
uses
  Stanza,XmppUri,Jid,NativeXml,Error,html.HTML,Event,Delay,shim.Headers,nickname.Nickname
  ,chatstates.Chatstate,SysUtils;
type
  TMessageType=(
  /// <summary>
		/// This in a normal message, much like an email. You dont expect a fast
		/// </summary>
		mtnormal = -1,

		/// <summary>
		/// a error messages
		/// </summary>
		mterror,

		/// <summary>
		/// is for chat like messages, person to person. Send this if you expect a fast reply. reply or no reply at all.
		/// </summary>
		mtchat,

		/// <summary>
		/// is used for sending/receiving messages from/to a chatroom (IRC style chats)
		/// </summary>
		///
		mtgroupchat,

        /// <summary>
		/// Think of this as a news broadcast, or RRS Feed, the message will normally have a URL and Description Associated with it.
		/// </summary>
		mtheadline
  );
  TMessage=class(TStanza)
  private
    procedure RemoveChatstate();
    function FGetBody:string;
    procedure FSetBody(value:string);
    function FGetSubject:string;
    procedure FSetSubject(value:string);
    function FGetThread:string;
    procedure FSetThread(value:string);
    function FGetMessageType:string;
    procedure FSetMessageType(value:string);
    function FGetError:TError;
    procedure FSetError(value:TError);
    function FGetHtml:THTML;
    procedure FSetHtml(value:THTML);
    function FGetEvent:TEvent;
    procedure FSetEvent(value:TEvent);
    function FGetDelay:TDelay;
    procedure FSetDelay(value:TDelay);
    function FGetHeaders:THeaders;
    procedure FSetHeaders(value:THeaders);
    function FGetNickname:TNickname;
    procedure FSetNickname(value:TNickname);
    function FGetChatstate:TChatstate;
    procedure FSetChatstate(value:TChatstate);
  public
    constructor Create();override;
    constructor Create(tojid:TJID);overload;
    constructor Create(tojid:TJID;body:string);overload;
    constructor Create(tojid:TJID;fromjid:TJID);overload;
    constructor Create(tojid:string;body:string);overload;
    constructor Create(tojid:TJID;body:string;subject:string);overload;
    constructor Create(tojid:string;body:string;subject:string);overload;
    constructor Create(tojid:string;body:string;subject:string;thread:string);overload;
    constructor Create(tojid:TJID;body:string;subject:string;thread:string);overload;
    constructor CreateMessage(tojid:string;messagetype:string;body:string);overload;
    constructor CreateMessage(tojid:TJID;messagetype:string;body:string);overload;
    constructor CreateMessage(tojid:string;messagetype:string;body:string;subject:string);overload;
    constructor CreateMessage(tojid:TJID;messagetype:string;body:string;subject:string);overload;
    constructor CreateMessage(tojid:string;messagetype:string;body:string;subject:string;thread:string);overload;
    constructor CreateMessage(tojid:TJID;messagetype:string;body:string;subject:string;thread:string);overload;
    constructor Create(tojid,fromjid:TJID;body:string);overload;
    constructor Create(tojid,fromjid:TJID;body:string;subject:string);overload;
    constructor Create(tojid,fromjid:TJID;body:string;subject:string;thread:string);overload;
    constructor CreateMessage(tojid,fromjid:TJID;messagetype:string;body:string);overload;
    constructor CreateMessage(tojid,fromjid:TJID;messagetype:string;body:string;subject:string);overload;
    constructor CreateMessage(tojid,fromjid:TJID;messagetype:string;body:string;subject:string;thread:string);overload;
    property Body:string read FGetBody write FSetBody;
    property Subject:string read FGetSubject write FSetSubject;
    property Thread:string read FGetThread write FSetThread;
    property MessageType:string read FGetMessageType write FSetMessageType;
    property Error:TError read FGetError write FSetError;
    property Html:THTML read FGetHtml write FSetHtml;
    property XEvent:TEvent read FGetEvent write FSetEvent;
    property XDelay:TDelay read FGetDelay write FSetDelay;
    property Headers:THeaders read FGetHeaders write FSetHeaders;
    property NickName:TNickname read FGetNickname write FSetNickname;
    property Chatstate:TChatstate read FGetChatstate write FSetChatstate;

    function CreateNewThread():string;
  end;

implementation

{ TMessage }

constructor TMessage.Create(tojid, body, subject,
  thread: string);
begin
  self.create();
  Self.ToJid:=TJID.Create(tojid);
  self.Body:=body;
  Self.Subject:=subject;
  self.Thread:=thread;
end;

constructor TMessage.Create(tojid, body, subject: string);
begin
  self.create();
  Self.ToJid:=TJID.Create(tojid);
  self.Body:=body;
  Self.Subject:=subject;
end;

constructor TMessage.Create(tojid: TJID; body, subject,
  thread: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.Body:=body;
  Self.Subject:=subject;
  self.Thread:=thread;
end;

constructor TMessage.CreateMessage(tojid: TJID;
  messagetype: string; body: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.Body:=body;
  Self.MessageType:=messagetype;
end;

constructor TMessage.CreateMessage(tojid: string;
  messagetype: string; body: string);
begin
  self.create();
  Self.ToJid:=TJID.Create(tojid);
  self.Body:=body;
  Self.MessageType:=messagetype;
end;

constructor TMessage.Create(tojid: TJID; body,
  subject: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.Body:=body;
  Self.Subject:=subject;
end;

constructor TMessage.Create(tojid: TJID);
begin
  self.create();
  self.ToJid:=tojid;
end;

constructor TMessage.Create();
begin
  inherited Create();
  Name:='message';
  Namespace:=XMLNS_CLIENT;
end;

constructor TMessage.Create(tojid: TJID; body: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.Body:=body;
end;

constructor TMessage.Create(tojid, body: string);
begin
  self.create();
  Self.ToJid:=TJID.Create(tojid);
  self.Body:=body;
end;

constructor TMessage.Create(tojid, fromjid: TJID);
begin
  self.create();
  Self.ToJid:=tojid;
  self.FromJid:=fromjid;
end;

constructor TMessage.Create(tojid, fromjid: TJID; body,
  subject, thread: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.FromJid:=fromjid;
  Self.Subject:=subject;
  self.Thread:=Thread;
end;

constructor TMessage.Create(tojid, fromjid: TJID; body,
  subject: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.FromJid:=fromjid;
  self.Body:=body;
  self.Subject:=subject;
end;

constructor TMessage.CreateMessage(tojid, fromjid: TJID;
  messagetype: string; body: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.FromJid:=fromjid;
  self.Body:=body;
  self.MessageType:=messagetype;
end;

constructor TMessage.CreateMessage(tojid, fromjid: TJID;
  messagetype: string; body, subject, thread: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.FromJid:=fromjid;
  self.Body:=body;
  self.MessageType:=messagetype;
  self.Subject:=subject;
  Self.Thread:=thread;
end;

constructor TMessage.CreateMessage(tojid, fromjid: TJID;
  messagetype: string; body, subject: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.FromJid:=fromjid;
  self.MessageType:=messagetype;
  self.Body:=body;
  Self.Subject:=subject;
end;

constructor TMessage.CreateMessage(tojid: TJID;
  messagetype: string; body, subject: string);
begin
  self.create();
  Self.ToJid:=tojid;
  self.MessageType:=messagetype;
  self.Body:=body;
  Self.Subject:=subject;
end;

constructor TMessage.CreateMessage(tojid: string;
  messagetype: string; body, subject: string);
begin
  self.create();
  Self.ToJid:=TJID.Create(tojid);
  self.MessageType:=messagetype;
  self.Body:=body;
  Self.Subject:=subject;
end;

constructor TMessage.CreateMessage(tojid: string;
  messagetype: string; body, subject, thread: string);
begin
   self.create();
  Self.ToJid:=TJID.Create(tojid);
  self.MessageType:=messagetype;
  self.Body:=body;
  Self.Subject:=subject;
  Self.Thread:=thread;
end;

constructor TMessage.Create(tojid, fromjid: TJID;
  body: string);
begin
  self.create();
  self.FromJid:=fromjid;
  self.Body:=body;
end;

constructor TMessage.CreateMessage(tojid: TJID;
  messagetype: string; body, subject, thread: string);
begin
  self.create();
  Self.ToJid:=TJID.Create(tojid);
  self.MessageType:=messagetype;
  self.Body:=body;
  Self.Subject:=subject;
  Self.Thread:=thread;
end;

function TMessage.CreateNewThread;
var
  v:TGUID;
begin
  V := TGUID.NewGuid;
  result := V.ToString;
end;

function TMessage.FGetBody: string;
begin
  Result:=GetTag('body');
end;

function TMessage.FGetChatstate: TChatstate;
begin
  if HasTag('active') then
    Result:=active
  else if HasTag('inactive') then
    result:=inactive
  else if HasTag('composing') then
    result:=composing
  else if HasTag('paused') then
    result:=paused
  else if HasTag('gone') then
    result:=gone
  else
    result:=None;
end;

function TMessage.FGetDelay: TDelay;
begin
  result:=TDelay(selectsingleelement(TDelay.ClassInfo));
end;

function TMessage.FGetError: TError;
begin
  result:=TError(selectsingleelement(TError.ClassInfo));
end;

function TMessage.FGetEvent: TEvent;
begin
  result:=TEvent(selectsingleelement(TEvent.ClassInfo));
end;

function TMessage.FGetHeaders: THeaders;
begin
  Result:=THeaders(selectsingleelement(THeaders.ClassInfo));
end;

function TMessage.FGetHtml: THTML;
begin
  Result:=THTML(selectsingleelement(THTML.ClassInfo));
end;

function TMessage.FGetMessageType: string;
begin
  Result:=AttributeValueByName['type'];
end;

function TMessage.FGetNickname: TNickname;
begin
  Result:=TNickname(selectsingleelement(TNickname.ClassInfo));
end;

function TMessage.FGetSubject: string;
begin
  Result:=GetTag('subject');
end;

function TMessage.FGetThread: string;
begin
  Result:=GetTag('thread');
end;

procedure TMessage.FSetBody(value: string);
begin
  NodeFindOrCreate('body').Value:=value;
end;

procedure TMessage.FSetChatstate(value: TChatstate);
begin
  RemoveChatstate;
  {case value of
    active: NodeAdd(TActive.Create(Document));
    inactive: NodeAdd(TInactive.Create(Document));
    composing: NodeAdd(TComposing.Create(Document));
    gone: NodeAdd(TGone.Create(Document));
    paused: NodeAdd(TPause.Create(Document));
  end; }
end;

procedure TMessage.FSetDelay(value: TDelay);
begin
  //if HasTag('x') then

end;

procedure TMessage.FSetError(value: TError);
begin

end;

procedure TMessage.FSetEvent(value: TEvent);
begin

end;

procedure TMessage.FSetHeaders(value: THeaders);
begin

end;

procedure TMessage.FSetHtml(value: THTML);
begin

end;

procedure TMessage.FSetMessageType(value: string);
begin

end;

procedure TMessage.FSetNickname(value: TNickname);
begin

end;

procedure TMessage.FSetSubject(value: string);
begin

end;

procedure TMessage.FSetThread(value: string);
begin

end;

procedure TMessage.RemoveChatstate;
begin

end;

end.
