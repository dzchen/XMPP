unit ElementFactory;

interface
uses
  NativeXml,ElementType,Element,XmppUri,IQ,Message,Presence,Error,Agent,Group,Auth,Agents,Delay,bind,session,Address,Email,name,Organization,Photo,Telephone,Vcard
  //,SearchItem,protocol.iq.last.Last,protocol.iq.version.Version,protocol.iq.time.Time
  ,Generics.Collections,protocol.iq.roster.RosterItem,protocol.Stream,protocol.Error,StrUtils
  ,protocol.iq.roster.Roster,protocol.iq.register,protocol.iq.disco.DiscoItems,protocol.iq.disco.DiscoInfo,protocol.iq.disco.DiscoFeature,protocol.iq.disco.DiscoIdentity,protocol.iq.disco.DiscoItem
  ,protocol.x.data.Data,Field,event,option,value,protocol.x.data.Reported,protocol.x.data.Item,protocol.stream.Features,protocol.stream.feature.compression.Compression
  ,protocol.stream.feature.Register,protocol.stream.feature.compression.Method,protocol.tls.StartTls,protocol.tls.Proceed,protocol.sasl.Mechanisms,protocol.sasl.Mechanism,protocol.sasl
  ,shim.Headers,shim.Header,protocol.iq.roster.Delimiter,primary.Primary,nickname.Nickname,html.Html,html.Body,protocol.extensions.caps.Capabilities
  ,MUActor,MUDecline,MUInvitation,MUInvite,MUItem,MUStatus,User,protocol.extensions.si,protocol.extensions.bytestreams,protocol.extensions.featureneg,protocol.extensions.filetransfer
  ;
type
  TClassElement=class of telement;
  TElementFactory=class
  public
    class procedure AddElementType(tag,ns:string;mt:TClassElement);
    class function GetElement(prefix,tag,ns:string):TElement;
    class function ConvertElement(el:TsdElement):TElement;
  end;
  function CreateElement(tagname,namespace:string):TElement;overload;
  function CreateElement(classtype:Pointer):TElement; overload;
implementation
var
  _table:TDictionary<string,TClassElement>;
function CreateElement(classtype:Pointer):TElement;
begin

end;
function CreateElement(tagname,namespace:string):TElement;
var
  te:TElement;
begin

  if (tagname='iq') and (namespace=XMLNS_CLIENT) then
    te:=TIQ.Create()
  else if(tagname='message') and (namespace=XMLNS_CLIENT)then
    te:=TMessage.Create()
  else if(tagname='presence') and (namespace=XMLNS_CLIENT)then
    te:=TPresence.Create()
  else if(tagname='error') and (namespace=XMLNS_CLIENT)then
    te:=TError.Create()

  else if(tagname='agent') and (namespace=XMLNS_IQ_AGENTS)then
    te:=TAgent.Create()

  else if(tagname='item') and (namespace=XMLNS_IQ_ROSTER)then
    te:=TRosterItem.Create()
  else if(tagname='group') and (namespace=XMLNS_IQ_ROSTER)then
    te:=TGroup.Create()
  else if(tagname='group') and (namespace=XMLNS_X_ROSTERX)then
    te:=TGroup.Create()

  //else if(tagname='item') and (namespace=XMLNS_IQ_SEARCH)then
    //te:=TSearchItem.Create()
  else if(tagname='stream') and (namespace=XMLNS_STREAM)then
    te:=TStream.Create()
  else if(tagname='error') and (namespace=XMLNS_STREAM)then
    te:=TError.Create()

  {else if(tagname='query') and (namespace=XMLNS_IQ_AUTH)then
    te:=TAuth.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_AGENTS)then
    te:=TAgents.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_ROSTER)then
    te:=TRoster.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_LAST)then
    te:=TLast.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_VERSION)then
    te:=TVersion.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_TIME)then
    te:=TTime.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_OOB)then
    te:=TOob.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_SEARCH)then
    te:=TSearch.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_BROWSE)then
    te:=TBrowse.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_AVATAR)then
    te:=TAvatar.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_REGISTER)then
    te:=TRegister.Create()
  else if(tagname='query') and (namespace=XMLNS_IQ_PRIVATE)then
    te:=TPrivate.Create()

  else if(tagname='query') and (namespace=XMLNS_IQ_PRIVACY)then
    te:=TPrivacy.Create()
  else if(tagname='item') and (namespace=XMLNS_IQ_PRIVACY)then
    te:=privacy.item.TItem.Create()
  else if(tagname='list') and (namespace=XMLNS_IQ_PRIVACY)then
    te:=privacy.item.TList.Create()
  else if(tagname='active') and (namespace=XMLNS_IQ_PRIVACY)then
    te:=privacy.item.TActive.Create()
  else if(tagname='default') and (namespace=XMLNS_IQ_PRIVACY)then
    te:=privacy.item.TDefault.Create()

  else if(tagname='service') and (namespace=XMLNS_IQ_BROWSE)then
    te:=TService.Create()
  else if(tagname='item') and (namespace=XMLNS_IQ_BROWSE)then
    te:=TBrowseItem.Create()

  else if(tagname='query') and (namespace=XMLNS_DISCO_ITEMS)then
    te:=TDiscoItems.Create()
  else if(tagname='query') and (namespace=XMLNS_DISCO_INFO)then
    te:=TDiscoInfo.Create()
  else if(tagname='feature') and (namespace=XMLNS_DISCO_INFO)then
    te:=TDiscoFeature.Create()
  else if(tagname='identity') and (namespace=XMLNS_DISCO_INFO)then
    te:=TDiscoIdentity.Create()
  else if(tagname='item') and (namespace=XMLNS_DISCO_ITEMS)then
    te:=TDiscoItem.Create()

  else if(tagname='x') and (namespace=XMLNS_X_DELAY)then
    te:=TDelay.Create()
  else if(tagname='x') and (namespace=XMLNS_X_AVATAR)then
    te:=TAvatar.Create()
  else if(tagname='x') and (namespace=XMLNS_X_CONFERENCE)then
    te:=TConference.Create()
  else if(tagname='x') and (namespace=XMLNS_X_EVENT)then
    te:=TEvent.Create()

  else if(tagname='query') and (namespace=XMLNS_STORAGE_AVATAR)then
    te:=TAvatar.Create()

  else if(tagname='x') and (namespace=XMLNS_X_DATA)then
    te:=TData.Create()
  else if(tagname='field') and (namespace=XMLNS_X_DATA)then
    te:=TField.Create()
  else if(tagname='option') and (namespace=XMLNS_X_DATA)then
    te:=TOption.Create()
  else if(tagname='value') and (namespace=XMLNS_X_DATA)then
    te:=TValue.Create()
  else if(tagname='reported') and (namespace=XMLNS_X_DATA)then
    te:=TReported.Create()
  else if(tagname='item') and (namespace=XMLNS_X_DATA)then
    te:=TItem.Create()

  else if(tagname='features') and (namespace=XMLNS_STREAM)then
    te:=TFeatures.Create()

  else if(tagname='register') and (namespace=XMLNS_IQ_REGISTER)then
    te:=TRegister.Create()
  else if(tagname='compression') and (namespace=XMLNS_COMPRESS)then
    te:=TCompression.Create()
  else if(tagname='method') and (namespace=XMLNS_COMPRESS)then
    te:=TMethod.Create()

  else if(tagname='bind') and (namespace=XMLNS_BIND)then
    te:=TBind.Create()
  else if(tagname='session') and (namespace=XMLNS_SESSION)then
    te:=TSession.Create()

  else if(tagname='failure') and (namespace=XMLNS_TLS)then
    te:=TFailure.Create()
  else if(tagname='proceed') and (namespace=XMLNS_TLS)then
    te:=TProceed.Create()
  else if(tagname='starttls') and (namespace=XMLNS_TLS)then
    te:=TStartTls.Create()

  else if(tagname='mechanisms') and (namespace=xmlns_sasl)then
    te:=TMechanisms.Create()
  else if(tagname='mechanism') and (namespace=xmlns_sasl)then
    te:=TMechanism.Create()
  else if(tagname='auth') and (namespace=xmlns_sasl)then
    te:=TAuth.Create()
  else if(tagname='response') and (namespace=xmlns_sasl)then
    te:=TResponse.Create()
  else if(tagname='challenge') and (namespace=xmlns_sasl)then
    te:=TChallenge.Create()

  else if(tagname='challenge') and (namespace=xmlns_client)then
    te:=TChallenge.Create()
  else if(tagname='success') and (namespace=xmlns_client)then
    te:=TSuccess.Create()

  else if(tagname='failure') and (namespace=xmlns_sasl)then
    te:=TFailure.Create()
  else if(tagname='abort') and (namespace=xmlns_sasl)then
    te:=TAbort.Create()
  else if(tagname='success') and (namespace=xmlns_sasl)then
    te:=TSuccess.Create()

  else if(tagname='vCard') and (namespace=xmlns_vcard)then
    te:=TVcard.Create()
  else if(tagname='TEL') and (namespace=xmlns_vcard)then
    te:=TTelephone.Create()
  else if(tagname='ORG') and (namespace=xmlns_vcard)then
    te:=TOrganization.Create()
  else if(tagname='N') and (namespace=xmlns_vcard)then
    te:=TName.Create()
  else if(tagname='EMAIL') and (namespace=xmlns_vcard)then
    te:=ADR.Create()
  else if(tagname='PHOTO') and (namespace=xmlns_vcard)then
    te:=TPhoto.Create()

  else if(tagname='handshake') and (namespace=XMLNS_ACCEPT)then
    te:=THandshake.Create()
  else if(tagname='log') and (namespace=XMLNS_ACCEPT)then
    te:=TLog.Create()
  else if(tagname='route') and (namespace=XMLNS_ACCEPT)then
    te:=TRoute.Create()
  else if(tagname='iq') and (namespace=XMLNS_ACCEPT)then
    te:=TIQ.Create()
  else if(tagname='message') and (namespace=XMLNS_ACCEPT)then
    te:=TMessage.Create()
  else if(tagname='presence') and (namespace=XMLNS_ACCEPT)then
    te:=TPresence.Create()
  else if(tagname='error') and (namespace=XMLNS_ACCEPT)then
    te:=TError.Create()

  else if(tagname='headers') and (namespace=XMLNS_SHIM)then
    te:=THeaders.Create()
  else if(tagname='header') and (namespace=XMLNS_SHIM)then
    te:=THeader.Create()
  else if(tagname='roster') and (namespace=XMLNS_ROSTER_DELIMITER)then
    te:=TDelimiter.Create()
  else if(tagname='p') and (namespace=XMLNS_PRIMARY)then
    te:=TPrimary.Create()
  else if(tagname='nick') and (namespace=XMLNS_NICK)then
    te:=TNickname.Create()

  else if(tagname='item') and (namespace=XMLNS_X_ROSTERX)then
    te:=TRosterItem.Create()
  else if(tagname='x') and (namespace=XMLNS_X_ROSTERX)then
    te:=TRosterX.Create()

  else if(tagname='file') and (namespace=XMLNS_SI_FILE_TRANSFER)then
    te:=TFile.Create()
  else if(tagname='range') and (namespace=XMLNS_SI_FILE_TRANSFER)then
    te:=TRange.Create()

  else if(tagname='query') and (namespace=XMLNS_BYTESTREAMS)then
    te:=TByteStream.Create()
  else if(tagname='streamhost') and (namespace=XMLNS_BYTESTREAMS)then
    te:=TStreamHost.Create()
  else if(tagname='streamhost-used') and (namespace=XMLNS_BYTESTREAMS)then
    te:=TStreamHostUsed.Create()
  else if(tagname='activate') and (namespace=XMLNS_BYTESTREAMS)then
    te:=TActivate.Create()
  else if(tagname='udpsuccess') and (namespace=XMLNS_BYTESTREAMS)then
    te:=TUdpSuccess.Create()

  else if(tagname='si') and (namespace=XMLNS_SI)then
    te:=TSI.Create()

  else if(tagname='html') and (namespace=XMLNS_XHTML_IM)then
    te:=THtml.Create()
  else if(tagname='body') and (namespace=XMLNS_XHTML)then
    te:=TBody.Create()

  else if(tagname='compressed') and (namespace=XMLNS_COMPRESS)then
    te:=TCompressed.Create()
  else if(tagname='compress') and (namespace=XMLNS_COMPRESS)then
    te:=TCompress.Create()
  else if(tagname='failure') and (namespace=XMLNS_COMPRESS)then
    te:=TFailure.Create()

  else if(tagname='x') and (namespace=XMLNS_MUC)then
    te:=TMuc.Create()
    else if(tagname='x') and (namespace=XMLNS_MUC_USER)then
    te:=TMucUser.Create()
  else if(tagname='item') and (namespace=XMLNS_MUC_USER)then
    te:=TMucItem.Create()
  else if(tagname='status') and (namespace=XMLNS_MUC_USER)then
    te:=TMucStatue.Create()
  else if(tagname='invite') and (namespace=XMLNS_MUC_USER)then
    te:=TMucInvite.Create()
  else if(tagname='decline') and (namespace=XMLNS_MUC_USER)then
    te:=TMucDecline.Create()
  else if(tagname='actor') and (namespace=XMLNS_MUC_USER)then
    te:=TMucActor.Create()
  else if(tagname='history') and (namespace=XMLNS_MUC)then
    te:=THistory.Create()
  else if(tagname='query') and (namespace=XMLNS_MUC_ADMIN)then
    te:=TAdmin.Create()
  else if(tagname='item') and (namespace=XMLNS_MUC_ADMIN)then
    te:=TItem.Create()
  else if(tagname='query') and (namespace=XMLNS_MUC_OWNER)then
    te:=TOwner.Create()
  else if(tagname='destroy') and (namespace=XMLNS_MUC_OWNER)then
    te:=TDestroy.Create()

  else if(tagname='query') and (namespace=XMLNS_IQ_RPC)then
    te:=TRpc.Create()
  else if(tagname='methodCall') and (namespace=XMLNS_IQ_RPC)then
    te:=TMethodCall.Create()
  else if(tagname='methodResponse') and (namespace=XMLNS_IQ_RPC)then
    te:=TMethodResponse.Create()

  else if(tagname='active') and (namespace=XMLNS_CHATSTATES)then
    te:=TActive.Create()
  else if(tagname='inactive') and (namespace=XMLNS_CHATSTATES)then
    te:=TInactive.Create()
  else if(tagname='composing') and (namespace=XMLNS_CHATSTATES)then
    te:=TComposing.Create()
  else if(tagname='paused') and (namespace=XMLNS_CHATSTATES)then
    te:=TPaused.Create()
  else if(tagname='gone') and (namespace=XMLNS_CHATSTATES)then
    te:=TGone.Create()

  else if(tagname='phone-event') and (namespace=XMLNS_JIVESOFTWARE_PHONE)then
    te:=TPhoneEvent.Create()
  else if(tagname='phone-action') and (namespace=XMLNS_JIVESOFTWARE_PHONE)then
    te:=TPhoneAction.Create()
  else if(tagname='phone-status') and (namespace=XMLNS_JIVESOFTWARE_PHONE)then
    te:=TPhoneStatus.Create()

  else if(tagname='c') and (namespace=XMLNS_CAPS)then
    te:=TCapabilities.Create()

  else if(tagname='geoloc') and (namespace=xmlns_geoloc)then
    te:=TGeoLoc.Create()

  else if(tagname='ping') and (namespace=xmlns_ping)then
    te:=TPing.Create()

  else if(tagname='command') and (namespace=XMLNS_COMMANDS)then
    te:=TCommand.Create()
  else if(tagname='actions') and (namespace=XMLNS_COMMANDS)then
    te:=TActions.Create()
  else if(tagname='note') and (namespace=XMLNS_COMMANDS)then
    te:=TNote.Create()

  else if(tagname='affiliate') and (namespace=XMLNS_PUBSUB_OWNER)then
    te:=TAffiliate.Create()
  else if(tagname='affiliates') and (namespace=XMLNS_PUBSUB_OWNER)then
    te:=TAffiliates.Create()
  else if(tagname='configure') and (namespace=XMLNS_PUBSUB_OWNER)then
    te:=TConfigure.Create()
  else if(tagname='delete') and (namespace=XMLNS_PUBSUB_OWNER)then
    te:=TDelete.Create()
  else if(tagname='pending') and (namespace=XMLNS_PUBSUB_OWNER)then
    te:=TPending.Create()
  else if(tagname='pubsub') and (namespace=XMLNS_PUBSUB_OWNER)then
    te:=TPubSub.Create()
  else if(tagname='purge') and (namespace=XMLNS_PUBSUB_OWNER)then
    te:=TPurge.Create()
  else if(tagname='subscriber') and (namespace=XMLNS_PUBSUB_OWNER)then
    te:=TSubscriber.Create()
  else if(tagname='subscribers') and (namespace=XMLNS_PUBSUB_OWNER)then
    te:=TSubscribers.Create()

  else if(tagname='delete') and (namespace=XMLNS_PUBSUB_EVENT)then
    te:=TDelete.Create()
  else if(tagname='event') and (namespace=XMLNS_PUBSUB_EVENT)then
    te:=TEvent.Create()
  else if(tagname='item') and (namespace=XMLNS_PUBSUB_EVENT)then
    te:=TItem.Create()
  else if(tagname='items') and (namespace=XMLNS_PUBSUB_EVENT)then
    te:=TItems.Create()
  else if(tagname='purge') and (namespace=XMLNS_PUBSUB_EVENT)then
    te:=TPurge.Create()

  else if(tagname='affiliation') and (namespace=XMLNS_PUBSUB)then
    te:=TAffiliation.Create()
  else if(tagname='affiliations') and (namespace=XMLNS_PUBSUB)then
    te:=TAffiliations.Create()
  else if(tagname='configure') and (namespace=XMLNS_PUBSUB)then
    te:=TConfigure.Create()
  else if(tagname='create') and (namespace=XMLNS_PUBSUB)then
    te:=TCreate.Create()
  else if(tagname='configure') and (namespace=XMLNS_PUBSUB)then
    te:=TConfigure.Create()
  else if(tagname='item') and (namespace=XMLNS_PUBSUB)then
    te:=TItem.Create()
  else if(tagname='items') and (namespace=XMLNS_PUBSUB)then
    te:=TItems.Create()
  else if(tagname='options') and (namespace=XMLNS_PUBSUB)then
    te:=TOptions.Create()
  else if(tagname='publish') and (namespace=XMLNS_PUBSUB)then
    te:=TPublish.Create()
  else if(tagname='pubsub') and (namespace=XMLNS_PUBSUB)then
    te:=TPubSub.Create()
  else if(tagname='retract') and (namespace=XMLNS_PUBSUB)then
    te:=TRetract.Create()
  else if(tagname='subscribe') and (namespace=XMLNS_PUBSUB)then
    te:=TSubscribe.Create()
  else if(tagname='subscribe-options') and (namespace=XMLNS_PUBSUB)then
    te:=TSubscribeOptions.Create()
  else if(tagname='subscription') and (namespace=XMLNS_PUBSUB)then
    te:=TSubscription.Create()
  else if(tagname='subscriptions') and (namespace=XMLNS_PUBSUB)then
    te:=TSubscriptions.Create()
  else if(tagname='unsubscribe') and (namespace=XMLNS_PUBSUB)then
    te:=TUnsubscribe.Create()

  else if(tagname='body') and (namespace=XMLNS_HTTP_BIND)then
    te:=TBody.Create()

  else if(tagname='received') and (namespace=XMLNS_MSG_RECEIPT)then
    te:=TReceived.Create()
  else if(tagname='request') and (namespace=XMLNS_MSG_RECEIPT)then
    te:=TRequest.Create()

  else if(tagname='storage') and (namespace=XMLNS_STORAGE_BOOKMARKS)then
    te:=TStorage.Create()
  else if(tagname='url') and (namespace=XMLNS_STORAGE_BOOKMARKS)then
    te:=TUrl.Create()
  else if(tagname='conference') and (namespace=XMLNS_STORAGE_BOOKMARKS)then
    te:=TConference.Create()

  else if(tagname='open') and (namespace=XMLNS_IBB)then
    te:=TOpen.Create()
  else if(tagname='data') and (namespace=XMLNS_IBB)then
    te:=TData.Create()
  else if(tagname='close') and (namespace=XMLNS_IBB)then
    te:=TClose.Create()

  else if(tagname='x') and (namespace=XMLNS_VCARD_UPDATE)then
    te:=TVcardUpdate.Create()

  else if(tagname='amp') and (namespace=XMLNS_AMP)then
    te:=TAmp.Create()

  else if(tagname='rule') and (namespace=XMLNS_AMP)then
    te:=TRule.Create();

  }
  else
  te:=TElement.Create();

  te.Namespace:=namespace;
  Result:=te;
end;
{ TElementFactory }

class procedure TElementFactory.AddElementType(tag, ns: string;
  mt: TClassElement);
var
  s:string;
begin
  s:=tag+':'+ns;
  if _table.ContainsKey(s) then
    _table[s]:=mt
  else
    _table.Add(s,mt);

end;

class function TElementFactory.ConvertElement(el:TsdElement):TElement;
var
  s:string;
  m:TClassElement;
  prefix,tag,ns: string;
  n:integer;
  tel:TElement;
begin
  tag:=el.Name;

  n:=Pos(':',tag);
  if n>0 then
  begin
    prefix:=RightStr(tag,Length(tag)-n);
    tag:=LeftStr(tag,n-1);
    if prefix<>'' then
      ns:=el.AttributeValueByName['xmlns:'+prefix]
    else
      ns:=el.AttributeValueByName['xmlns'];
  end;

  s:=tag+':'+ns;
  m:=_table[s];
  if not Assigned(m) then
  begin
    exit;
  end;
  tel:=TStream(el);
  if tel is TStream then

  tel:=m.Create;

  //tel:=tel.copyfrom(el);
  tel.prefix:=prefix;
  tel.Name:=tag;
  if ns<>'' then
  tel.Namespace:=ns;
  Result:=tel;
end;

class function TElementFactory.GetElement(prefix, tag, ns: string): TElement;
var
  s:string;
  m:TClassElement;
begin
  s:=tag+':'+ns;
  m:=nil;
  if _table.ContainsKey(s) then
    m:=_table[s];
  if not Assigned(m) then
    Result:=TElement.Create(tag)
  else
    Result:=m.Create;

  Result.Prefix:=prefix;
  if ns<>'' then
  Result.Namespace:=ns;

end;
initialization
  _table:=TDictionary<string,TClassElement>.create;
  TElementFactory.AddElementType('iq',XMLNS_CLIENT,TIQ);
  TElementFactory.AddElementType('message',XMLNS_CLIENT,TMessage);
  TElementFactory.AddElementType('presence',XMLNS_CLIENT,TPresence);
  TElementFactory.AddElementType('error',XMLNS_CLIENT,Error.TError);

  TElementFactory.AddElementType('agent',XMLNS_IQ_AGENTS,TAgent);

  TElementFactory.AddElementType('item',XMLNS_IQ_ROSTER,protocol.iq.roster.RosterItem.TRosterItem);
  TElementFactory.AddElementType('group',XMLNS_IQ_ROSTER,Group.TGroup);
  TElementFactory.AddElementType('group',XMLNS_IQ_ROSTER,Group.TGroup);

  //TElementFactory.TElementFactory.AddElementType('item',XMLNS_IQ_SEARCH,TSearchItem);

  TElementFactory.AddElementType('stream',XMLNS_STREAM,TStream);
  TElementFactory.AddElementType('error',XMLNS_STREAM,protocol.Error.TError);

  TElementFactory.AddElementType('query',				XMLNS_IQ_AUTH,				Auth.TAuth);
			TElementFactory.AddElementType('query',				XMLNS_IQ_AGENTS,				TAgents);
			TElementFactory.AddElementType('query',				XMLNS_IQ_ROSTER,				protocol.iq.roster.Roster.TRoster);
			//TElementFactory.AddElementType('query',				XMLNS_IQ_LAST,				protocol.iq.last.Last.TLast);
      //TElementFactory.AddElementType('query',				XMLNS_IQ_VERSION,				protocol.iq.version.Version.TVersion);
			//TElementFactory.AddElementType('query',				XMLNS_IQ_TIME,				protocol.iq.time.Time.TTime);
			//TElementFactory.AddElementType('query',				XMLNS_IQ_OOB,					protocol.iq.oob.Oob);
			//TElementFactory.AddElementType('query',				XMLNS_IQ_SEARCH,				protocol.iq.search.Search);
			//TElementFactory.AddElementType('query',				XMLNS_IQ_BROWSE,				protocol.iq.browse.Browse);
			//TElementFactory.AddElementType('query',				XMLNS_IQ_AVATAR,				protocol.iq.avatar.Avatar);
			TElementFactory.AddElementType('query',				XMLNS_IQ_REGISTER,			protocol.iq.register.TRegister);
			//TElementFactory.AddElementType('query',				XMLNS_IQ_PRIVATE,				protocol.iq.@private.Private);

      // Privacy Lists
      //TElementFactory.AddElementType('query',             XMLNS_IQ_PRIVACY,             protocol.iq.privacy.Privacy);
      //TElementFactory.AddElementType('item',              XMLNS_IQ_PRIVACY,             protocol.iq.privacy.Item);
      //TElementFactory.AddElementType('list',              XMLNS_IQ_PRIVACY,             protocol.iq.privacy.List);
      //TElementFactory.AddElementType('active',            XMLNS_IQ_PRIVACY,             protocol.iq.privacy.Active);
      //TElementFactory.AddElementType('default',           XMLNS_IQ_PRIVACY,             protocol.iq.privacy.Default);

			// Browse
			//TElementFactory.AddElementType('service',			XMLNS_IQ_BROWSE,				protocol.iq.browse.Service);
			//TElementFactory.AddElementType('item',				XMLNS_IQ_BROWSE,				protocol.iq.browse.BrowseItem);

			// Service Discovery
			TElementFactory.AddElementType('query',				XMLNS_DISCO_ITEMS,			protocol.iq.disco.DiscoItems.TDiscoItems);
			TElementFactory.AddElementType('query',				XMLNS_DISCO_INFO,				protocol.iq.disco.DiscoInfo.TDiscoInfo);
			TElementFactory.AddElementType('feature',			XMLNS_DISCO_INFO,			    protocol.iq.disco.DiscoFeature.tDiscoFeature);
			TElementFactory.AddElementType('identity',			XMLNS_DISCO_INFO,			    protocol.iq.disco.DiscoIdentity.TDiscoIdentity);
			TElementFactory.AddElementType('item',				XMLNS_DISCO_ITEMS,			protocol.iq.disco.DiscoItem.TDiscoItem);

			TElementFactory.AddElementType('x',					XMLNS_X_DELAY,				TDelay);
			//TElementFactory.AddElementType('x',					XMLNS_X_AVATAR,				protocol.x.Avatar);
			//TElementFactory.AddElementType('x',					XMLNS_X_CONFERENCE,			protocol.x.Conference);
      TElementFactory.AddElementType('x',                 XMLNS_X_EVENT,                TEvent);

			////TElementFactory.AddElementType('x',					XMLNS_STORAGE_AVATAR,	protocol.storage.Avatar);
			//TElementFactory.AddElementType('query',				XMLNS_STORAGE_AVATAR,			protocol.storage.Avatar);

			// XData Stuff
			TElementFactory.AddElementType('x',					XMLNS_X_DATA,					protocol.x.data.Data.TData);
			TElementFactory.AddElementType('field',				XMLNS_X_DATA,					TField);
			TElementFactory.AddElementType('option',			XMLNS_X_DATA,					TOption);
			TElementFactory.AddElementType('value',				XMLNS_X_DATA,					TValue);
      TElementFactory.AddElementType('reported',          XMLNS_X_DATA,                 protocol.x.data.Reported.TReported);
      TElementFactory.AddElementType('item',              XMLNS_X_DATA,                 protocol.x.data.Item.TItem);

			TElementFactory.AddElementType('features',			XMLNS_STREAM,					protocol.stream.Features.TFeatures);

			TElementFactory.AddElementType('register',			XMLNS_FEATURE_IQ_REGISTER,	protocol.stream.feature.Register.TRegister);
            TElementFactory.AddElementType('compression',       XMLNS_FEATURE_COMPRESS,       protocol.stream.feature.compression.Compression.TCompression);
            TElementFactory.AddElementType('method',            XMLNS_FEATURE_COMPRESS,       protocol.stream.feature.compression.Method.TMethod);

			TElementFactory.AddElementType('bind',				XMLNS_BIND,					TBind);
			TElementFactory.AddElementType('session',			XMLNS_SESSION,				TSession);

			// TLS stuff
			//TElementFactory.AddElementType('failure',			XMLNS_TLS,					protocol.tls.TFailure);
			TElementFactory.AddElementType('proceed',			XMLNS_TLS,					protocol.tls.Proceed.TProceed);
			TElementFactory.AddElementType('starttls',			XMLNS_TLS,					protocol.tls.StartTls.TStartTls);

			// SASL stuff
			TElementFactory.AddElementType('mechanisms',		XMLNS_SASL,					protocol.sasl.Mechanisms.TMechanisms);
			TElementFactory.AddElementType('mechanism',			XMLNS_SASL,					protocol.sasl.Mechanism.TMechanism);
			TElementFactory.AddElementType('auth',				XMLNS_SASL,					protocol.sasl.TAuth);
			TElementFactory.AddElementType('response',			XMLNS_SASL,					protocol.sasl.TResponse);
			TElementFactory.AddElementType('challenge',			XMLNS_SASL,					protocol.sasl.TChallenge);

      // TODO, this is a dirty hacks for the buggy BOSH Proxy
      // BEGIN
      //TElementFactory.AddElementType('challenge',         XMLNS_CLIENT,                 protocol.sasl.Challenge);
      //TElementFactory.AddElementType('success',           XMLNS_CLIENT,                 protocol.sasl.Success);
      // END

			TElementFactory.AddElementType('failure',			XMLNS_SASL,					protocol.sasl.TFailure);
			TElementFactory.AddElementType('abort',				XMLNS_SASL,					protocol.sasl.TAbort);
			TElementFactory.AddElementType('success',			XMLNS_SASL,					protocol.sasl.TSuccess);

			// Vcard stuff
			TElementFactory.AddElementType('vCard',				XMLNS_VCARD,					TVcard);
      TElementFactory.AddElementType('TEL',				XMLNS_VCARD,					TTelephone);
			TElementFactory.AddElementType('ORG',				XMLNS_VCARD,					TOrganization);
			TElementFactory.AddElementType('N',					XMLNS_VCARD,					TName);
			TElementFactory.AddElementType('EMAIL',				XMLNS_VCARD,					TEmail);
			TElementFactory.AddElementType('ADR',				XMLNS_VCARD,					TAddress);

			TElementFactory.AddElementType('PHOTO',				XMLNS_VCARD,					TPhoto);

            // Server stuff
            //TElementFactory.AddElementType('stream',            XMLNS_SERVER,                 protocol.server.Stream);
            //TElementFactory.AddElementType('message',           XMLNS_SERVER,                 protocol.server.Message);

			// Component stuff
			//TElementFactory.AddElementType('handshake',			XMLNS_ACCEPT,					protocol.component.Handshake);
			//TElementFactory.AddElementType('log',				XMLNS_ACCEPT,					protocol.component.Log);
			//TElementFactory.AddElementType('route',				XMLNS_ACCEPT,					protocol.component.Route);
			//TElementFactory.AddElementType('iq',				XMLNS_ACCEPT,					protocol.component.IQ);
      //TElementFactory.AddElementType('message',           XMLNS_ACCEPT,                 protocol.component.Message);
      //TElementFactory.AddElementType('presence',          XMLNS_ACCEPT,                 protocol.component.Presence);
      //TElementFactory.AddElementType('error',             XMLNS_ACCEPT,                 protocol.component.Error);

			//Extensions (JEPS)
			TElementFactory.AddElementType('headers',			XMLNS_SHIM,					shim.Header.THeader);
			TElementFactory.AddElementType('header',			XMLNS_SHIM,					shim.Headers.THeaders);
			TElementFactory.AddElementType('roster',			XMLNS_ROSTER_DELIMITER,		protocol.iq.roster.Delimiter.TDelimiter);
			TElementFactory.AddElementType('p',					XMLNS_PRIMARY,				primary.Primary.TPrimary);
      TElementFactory.AddElementType('nick',              XMLNS_NICK,                   nickname.Nickname.TNickname);

			//TElementFactory.AddElementType('item',				XMLNS_X_ROSTERX,				protocol.x.rosterx.RosterItem);
			//TElementFactory.AddElementType('x',					XMLNS_X_ROSTERX,				protocol.x.rosterx.RosterX);

      // Filetransfer stuff
			TElementFactory.AddElementType('file',				XMLNS_SI_FILE_TRANSFER,		protocol.extensions.filetransfer.TFile);
			TElementFactory.AddElementType('range',				XMLNS_SI_FILE_TRANSFER,		protocol.extensions.filetransfer.TRange);

      // FeatureNeg
      TElementFactory.AddElementType('feature',           XMLNS_FEATURE_NEG,            protocol.extensions.featureneg.TFeatureNeg);

     // Bytestreams
     TElementFactory.AddElementType('query',             XMLNS_BYTESTREAMS,            protocol.extensions.bytestreams.TByteStream);
     TElementFactory.AddElementType('streamhost',        XMLNS_BYTESTREAMS,            protocol.extensions.bytestreams.TStreamHost);
     TElementFactory.AddElementType('streamhost-used',   XMLNS_BYTESTREAMS,            protocol.extensions.bytestreams.TStreamHostUsed);
     TElementFactory.AddElementType('activate',          XMLNS_BYTESTREAMS,            protocol.extensions.bytestreams.TActivate);
     TElementFactory.AddElementType('udpsuccess',        XMLNS_BYTESTREAMS,            protocol.extensions.bytestreams.TUdpSuccess);


     TElementFactory.AddElementType('si',				XMLNS_SI,						protocol.extensions.si.TSI);

     TElementFactory.AddElementType('html',              XMLNS_XHTML_IM,               html.Html.THtml);
     TElementFactory.AddElementType('body',              XMLNS_XHTML,                  html.Body.TBody);

     //TElementFactory.AddElementType('compressed',        XMLNS_COMPRESS,               protocol.extensions.compression.Compressed);
     //TElementFactory.AddElementType('compress',          XMLNS_COMPRESS,               protocol.extensions.compression.Compress);
     //TElementFactory.AddElementType('failure',           XMLNS_COMPRESS,               protocol.extensions.compression.Failure);

            // MUC (JEP-0045 Multi User Chat)
     //TElementFactory.AddElementType('x',                 XMLNS_MUC,                    protocol.x.muc.Muc);
            TElementFactory.AddElementType('x',                 XMLNS_MUC_USER,               User.TMUUser);
     //TElementFactory.AddElementType('item',              XMLNS_MUC_USER,               mucItem.tmucitem);
     //TElementFactory.AddElementType('status',            XMLNS_MUC_USER,               mucStatus.mucstatus);
     //TElementFactory.AddElementType('invite',            XMLNS_MUC_USER,               mucInvite.tmucinvite);
     //TElementFactory.AddElementType('decline',           XMLNS_MUC_USER,               mucDecline.TmucDecline);
     //TElementFactory.AddElementType('actor',             XMLNS_MUC_USER,               mucActor.TmucActor);
     //TElementFactory.AddElementType('history',           XMLNS_MUC,                    protocol.x.muc.History);
     //TElementFactory.AddElementType('query',             XMLNS_MUC_ADMIN,              protocol.x.muc.iq.admin.Admin);
     //TElementFactory.AddElementType('item',              XMLNS_MUC_ADMIN,              protocol.x.muc.iq.admin.Item);
     //TElementFactory.AddElementType('query',             XMLNS_MUC_OWNER,              protocol.x.muc.iq.owner.Owner);
     //TElementFactory.AddElementType('destroy',           XMLNS_MUC_OWNER,              protocol.x.muc.Destroy);


            //Jabber RPC JEP 0009
     //TElementFactory.AddElementType('query',             XMLNS_IQ_RPC,                 protocol.iq.rpc.Rpc);
     //TElementFactory.AddElementType('methodCall',        XMLNS_IQ_RPC,                 protocol.iq.rpc.MethodCall);
     //TElementFactory.AddElementType('methodResponse',    XMLNS_IQ_RPC,                 protocol.iq.rpc.MethodResponse);

            // Chatstates Jep-0085
     //TElementFactory.AddElementType('active',            XMLNS_CHATSTATES,             protocol.extensions.chatstates.Active);
     //TElementFactory.AddElementType('inactive',          XMLNS_CHATSTATES,             protocol.extensions.chatstates.Inactive);
     //TElementFactory.AddElementType('composing',         XMLNS_CHATSTATES,             protocol.extensions.chatstates.Composing);
     //TElementFactory.AddElementType('paused',            XMLNS_CHATSTATES,             protocol.extensions.chatstates.Paused);
     //TElementFactory.AddElementType('gone',              XMLNS_CHATSTATES,             protocol.extensions.chatstates.Gone);

            // Jivesoftware Extenstions
     //TElementFactory.AddElementType('phone-event',       XMLNS_JIVESOFTWARE_PHONE,     protocol.extensions.jivesoftware.phone.PhoneEvent);
     //TElementFactory.AddElementType('phone-action',      XMLNS_JIVESOFTWARE_PHONE,     protocol.extensions.jivesoftware.phone.PhoneAction);
     //TElementFactory.AddElementType('phone-status',      XMLNS_JIVESOFTWARE_PHONE,     protocol.extensions.jivesoftware.phone.PhoneStatus);

            // Jingle stuff is in heavy development, we commit this once the most changes on the Jeps are done
            //TElementFactory.AddElementType('jingle',            XMLNS_JINGLE,                 protocol.extensions.jingle.Jingle);
            //TElementFactory.AddElementType('candidate',         XMLNS_JINGLE,                 protocol.extensions.jingle.Candidate);

     TElementFactory.AddElementType('c',                 XMLNS_CAPS,                   protocol.extensions.caps.Capabilities.TCapabilities);

     //TElementFactory.AddElementType('geoloc',            XMLNS_GEOLOC,                 protocol.extensions.geoloc.GeoLoc);

            // Xmpp Ping
    //TElementFactory.AddElementType('ping',              XMLNS_PING,                   protocol.extensions.ping.Ping);

            //Ad-Hock Commands
    //TElementFactory.AddElementType('command',           XMLNS_COMMANDS,               protocol.extensions.commands.Command);
    //TElementFactory.AddElementType('actions',           XMLNS_COMMANDS,               protocol.extensions.commands.Actions);
    //TElementFactory.AddElementType('note',              XMLNS_COMMANDS,               protocol.extensions.commands.Note);

            // **********
            // * PubSub *
            // **********
            // Owner namespace
    //TElementFactory.AddElementType('affiliate',         XMLNS_PUBSUB_OWNER,           protocol.extensions.pubsub.owner.Affiliate);
    //TElementFactory.AddElementType('affiliates',        XMLNS_PUBSUB_OWNER,           protocol.extensions.pubsub.owner.Affiliates);
    //TElementFactory.AddElementType('configure',         XMLNS_PUBSUB_OWNER,           protocol.extensions.pubsub.owner.Configure);
    //TElementFactory.AddElementType('delete',            XMLNS_PUBSUB_OWNER,           protocol.extensions.pubsub.owner.Delete);
    //TElementFactory.AddElementType('pending',           XMLNS_PUBSUB_OWNER,           protocol.extensions.pubsub.owner.Pending);
    //TElementFactory.AddElementType('pubsub',            XMLNS_PUBSUB_OWNER,           protocol.extensions.pubsub.owner.PubSub);
    //TElementFactory.AddElementType('purge',             XMLNS_PUBSUB_OWNER,           protocol.extensions.pubsub.owner.Purge);
    //TElementFactory.AddElementType('subscriber',        XMLNS_PUBSUB_OWNER,           protocol.extensions.pubsub.owner.Subscriber);
    //TElementFactory.AddElementType('subscribers',       XMLNS_PUBSUB_OWNER,           protocol.extensions.pubsub.owner.Subscribers);

            // Event namespace
    //TElementFactory.AddElementType('delete',            XMLNS_PUBSUB_EVENT,           protocol.extensions.pubsub.@event.Delete);
    //TElementFactory.AddElementType('event',             XMLNS_PUBSUB_EVENT,           protocol.extensions.pubsub.@event.Event);
    //TElementFactory.AddElementType('item',              XMLNS_PUBSUB_EVENT,           protocol.extensions.pubsub.@event.Item);
    //TElementFactory.AddElementType('items',             XMLNS_PUBSUB_EVENT,           protocol.extensions.pubsub.@event.Items);
    //TElementFactory.AddElementType('purge',             XMLNS_PUBSUB_EVENT,           protocol.extensions.pubsub.@event.Purge);

            // Main Pubsub namespace
           { TElementFactory.AddElementType('affiliation',       XMLNS_PUBSUB,                 protocol.extensions.pubsub.Affiliation);
            TElementFactory.AddElementType('affiliations',      XMLNS_PUBSUB,                 protocol.extensions.pubsub.Affiliations);
            TElementFactory.AddElementType('configure',         XMLNS_PUBSUB,                 protocol.extensions.pubsub.Configure);
            TElementFactory.AddElementType('create',            XMLNS_PUBSUB,                 protocol.extensions.pubsub.Create);
            TElementFactory.AddElementType('configure',         XMLNS_PUBSUB,                 protocol.extensions.pubsub.Configure);
            TElementFactory.AddElementType('item',              XMLNS_PUBSUB,                 protocol.extensions.pubsub.Item);
            TElementFactory.AddElementType('items',             XMLNS_PUBSUB,                 protocol.extensions.pubsub.Items);
            TElementFactory.AddElementType('options',           XMLNS_PUBSUB,                 protocol.extensions.pubsub.Options);
            TElementFactory.AddElementType('publish',           XMLNS_PUBSUB,                 protocol.extensions.pubsub.Publish);
            TElementFactory.AddElementType('pubsub',            XMLNS_PUBSUB,                 protocol.extensions.pubsub.PubSub);
            TElementFactory.AddElementType('retract',           XMLNS_PUBSUB,                 protocol.extensions.pubsub.Retract);
            TElementFactory.AddElementType('subscribe',         XMLNS_PUBSUB,                 protocol.extensions.pubsub.Subscribe);
            TElementFactory.AddElementType('subscribe-options', XMLNS_PUBSUB,                 protocol.extensions.pubsub.SubscribeOptions);
            TElementFactory.AddElementType('subscription',      XMLNS_PUBSUB,                 protocol.extensions.pubsub.Subscription);
            TElementFactory.AddElementType('subscriptions',     XMLNS_PUBSUB,                 protocol.extensions.pubsub.Subscriptions);
            TElementFactory.AddElementType('unsubscribe',       XMLNS_PUBSUB,                 protocol.extensions.pubsub.Unsubscribe);

            // HTTP Binding XEP-0124
            TElementFactory.AddElementType('body',              XMLNS_HTTP_BIND,              protocol.extensions.bosh.Body);

            // Message receipts XEP-0184
            TElementFactory.AddElementType('received',          XMLNS_MSG_RECEIPT,            protocol.extensions.msgreceipts.Received);
            TElementFactory.AddElementType('request',           XMLNS_MSG_RECEIPT,            protocol.extensions.msgreceipts.Request);

            // Bookmark storage XEP-0048
            TElementFactory.AddElementType('storage',           XMLNS_STORAGE_BOOKMARKS,      protocol.extensions.bookmarks.Storage);
            TElementFactory.AddElementType('url',               XMLNS_STORAGE_BOOKMARKS,      protocol.extensions.bookmarks.Url);
            TElementFactory.AddElementType('conference',        XMLNS_STORAGE_BOOKMARKS,      protocol.extensions.bookmarks.Conference);

            // XEP-0047: In-Band Bytestreams (IBB)
            TElementFactory.AddElementType('open',              XMLNS_IBB,                    protocol.extensions.ibb.Open);
            TElementFactory.AddElementType('data',              XMLNS_IBB,                    protocol.extensions.ibb.Data);
            TElementFactory.AddElementType('close',             XMLNS_IBB,                    protocol.extensions.ibb.Close);

            // XEP-0153: vCard-Based Avatars
            TElementFactory.AddElementType('x',                 XMLNS_VCARD_UPDATE,           protocol.x.vcard_update.VcardUpdate);

            // AMP
            TElementFactory.AddElementType('amp',               XMLNS_AMP,                    protocol.extensions.amp.Amp);
            TElementFactory.AddElementType('rule',              XMLNS_AMP,                    protocol.extensions.amp.Rule);
 }
 end.
