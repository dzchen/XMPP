unit protocol.iq.disco.DiscoItemsIq;

interface
uses
  IQ,protocol.iq.disco.DiscoItems;
type
  TDiscoItemsIq=class(TIQ)
  private
    _discoitems:TDiscoItems;
  public
    constructor Create;overload;override;
    constructor Create(iqtype:string);overload;
    property Query:TDiscoItems read _discoitems;
  end;

implementation

{ TDiscoItemsIq }

constructor TDiscoItemsIq.Create;
begin
  inherited Create;
  _discoitems:=TDiscoItems.Create;
  FSetQuery(_discoitems);
  GenerateId;
end;

constructor TDiscoItemsIq.Create(iqtype: string);
begin
  self.Create;
  self.IqType:=iqtype;
end;

end.
