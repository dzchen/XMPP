unit Avatar;

interface
uses
  Element,NativeXml,EncdDecd,SysUtils;
type
  TAvatar=class(TElement)
  private
    procedure FSetData(value:tbytes);
    function FGetData():tbytes;
    procedure FSetMimeType(value:string);
    function FGetMimeType():string;
  public
    constructor Create(AOwner:TNativeXml;tag:string);
    property Data:tbytes  read FGetData write FSetData;
    property MimeType:string read FGetMimeType write FSetMimeType;
  end;

implementation

{ TAvatar }

constructor TAvatar.Create(AOwner: TNativeXml; tag: string);
begin
  inherited Create(AOwner,tag);
end;

function TAvatar.FGetData: tbytes;
var
  el:TElement;
begin
  el:=FindNode('data') as TElement;
  if(el<>nil) then
  begin

    Result:=DecodeBase64(el.Value);
  end
  else
    Result:=nil;

end;

function TAvatar.FGetMimeType: string;
begin
  if(FindNode('data')<>nil)then
    Result:=AttributeValueByName['mimetype']
  else
    Result:='';
end;

procedure TAvatar.FSetData(value: tbytes);
begin
  NodeFindOrCreate('data').Value:=EncodeBase64(value,length(value));
end;

procedure TAvatar.FSetMimeType(value: string);
begin
  if(FindNode('data')<>nil)then
    AttributeAdd('mimetype',value);
end;

end.
