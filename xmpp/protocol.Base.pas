unit protocol.Base;

interface

uses xmppxnode, directionalelement;

type
  TDirectionalElement = class(TXMPPXNode)
  end;

  TStanza = class(TDirectionalElement)
  end;

implementation

end.
