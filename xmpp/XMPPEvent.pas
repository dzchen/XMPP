unit XMPPEvent;

interface
uses
  IQ,Presence,protocol.iq.roster.RosterItem,agent,Element,Message,XMPPConst,SysUtils,protocol.iq.RegisterEventArgs,sasl.SaslEventArgs;
type
  IqHandler=procedure(sender:TObject;iq:TIQ) of object;
  PresenceHandler=procedure(sender:TObject;pres:TPresence) of object;
  MessageHandler=procedure(sender:TObject;msg:TMessage) of object;
  RosterHandler=procedure(sender:TObject;item:TRosterItem) of object;
  AgentHandler=procedure(sender:TObject;agent:TAgent) of object;
  XmppElementHandler=procedure(sender:TObject;e:TElement) of object;
  XmlHandler=procedure(sender:TObject;xml:string)of object;
  XmppConnectionStateHandler=procedure(sender:TObject;state:TXmppConnectionState)of object;
  OnSocketDataHandler=procedure(sender:TObject;bt:TBytes;len:Integer)of object;
  OnSocketXmlHandler=procedure(sender:TObject;xml:string)of object;
  ErrorHandler=procedure(sender:TObject;ex:Exception)of object;
  StreamHandler=procedure(sender:TObject;e:TElement) of object;
  StreamError=procedure(sender:TObject;ex:Exception)of object;

  GrabberCB=procedure(sender:TObject;iq:TElement;data:string) of object;
  IqCB=procedure(sender:TObject;iq:TIQ;data:string) of object;
  MessageCB=procedure(sender:TObject;msg:TMessage;data:string) of object;
  IqCBElement=procedure(sender:TObject;iq:TIQ;data:telement) of object;
  PresenceCB=procedure(sender:TObject;pres:TPresence;data:string) of object;
  RegisterEventHandler=procedure (sender:TObject;args:TRegisterEventArgs) of object;
  SaslEventHandler=procedure(sender:TObject;args:TSaslEventArgs) of object;
  ProgressEventHandler=procedure(sender:TObject;len:Int64) of object;
implementation

end.
