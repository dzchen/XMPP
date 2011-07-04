unit protocol.extensions.caps.Capabilities;

interface
uses
  XmppUri,Element,protocol.iq.disco.DiscoInfo,Generics.Collections,protocol.iq.disco.DiscoFeature,protocol.iq.disco.DiscoIdentity,SecHash,EncdDecd,StringUtils,Classes;
type
  TCapabilities=class(TElement)
  private
    function FGetNode:string;
    procedure FSetNode(value:string);
    function FGetVersion:string;
    procedure FSetVersion(value:string);
    function BuildCapsVersion(di:TDiscoInfo):string;
    function FGetExtensions:Tarray<string>;
    procedure FSetExtensions(value:Tarray<string>);
  public
    constructor Create;overload;override;
    constructor Create(version,node:string);overload;
    property Node:string read FGetNode write FSetNode;
    property Version:string read FGetVersion write FSetVersion;
    property Extensions:Tarray<string> read FGetExtensions write FSetExtensions;
    procedure SetVersion(di:TDiscoInfo);
    procedure AddExtension(ext:string);
    procedure RemoveExtension(ext:string);
    function ContainsExtension(ext:string):Boolean;

  end;

implementation

{ TCapabilities }

procedure TCapabilities.AddExtension(ext: string);
var
  exts:tarray<string>;
  n,size:integer;
begin
  exts:=extensions;
  if TArray.BinarySearch<string>(exts,ext,n)then
    exit;
  SetLength(exts,Length(exts)+1);
  Extensions:=exts;
end;

function TCapabilities.BuildCapsVersion(di: TDiscoInfo): string;
var
  features,identities:TArray<string>;
  tid,tfd:TList<TElement>;
  did:TDiscoIdentity;
  df:TDiscoFeature;
  i:integer;
  s:string;
  sec:TSecHash;
  bt:TByteDigest;
begin
  tid:=di.GetIdentities();
  tfd:=di.GetFeatures();
  SetLength(identities,tid.Count);
  for i:=0 to tid.Count-1 do
  begin
    did:=TDiscoIdentity(tid[i]);
    if did=nil then
      identities[i]:=did.Category
    else
      identities[i]:=did.Category+'/'+did.DiscoType;
  end;
  SetLength(features,tfd.Count);
  for i := 0 to tfd.Count-1 do
    features[i]:=TDiscoFeature(tfd[i]).DiscoVar;
  TArray.Sort<string>(identities);
  TArray.Sort<string>(features);
  for i := 0 to Length(identities)-1 do
    s:=s+identities[i]+'<';
  for i := 0 to Length(features)-1 do
    s:=s+features[i]+'<';
  sec:=TSecHash.Create(nil);
  bt:=sec.IntDigestToByteDigest(sec.ComputeString(s));
  result:=EncodeBase64(@bt,SizeOf(bt));
end;

function TCapabilities.ContainsExtension(ext: string): Boolean;
var
  exts:tarray<string>;
  n:Integer;
begin
  exts:=extensions;
  if Length(exts)=0 then
  begin
    result:=False;
    exit;
  end;
  if TArray.BinarySearch<string>(exts,ext,n) then
    Result:=true
  else
    Result:=False;

end;

constructor TCapabilities.Create(version, node: string);
begin
  self.Create;
  Self.Version:=version;
  Self.Node:=node;
end;

constructor TCapabilities.Create;
begin
  inherited Create;
  Name:='c';
  Namespace:=XMLNS_CAPS;
end;

function TCapabilities.FGetExtensions: Tarray<string>;
var
  ts:Tstrings;
  sa:Tarray<string>;
  i:integer;
begin
  ts:=tstrings.create;
  split(attributevaluebyname['ext'],' ',ts);
  setlength(sa,ts.count);
  for i := 0 to ts.count-1 do
    sa[i]:=ts[i];
  result:=sa;
end;

function TCapabilities.FGetNode: string;
begin
  result:=attributevaluebyname['node'];
end;

function TCapabilities.FGetVersion: string;
begin
  result:=attributevaluebyname['ver'];
end;

procedure TCapabilities.FSetExtensions(value: Tarray<string>);
var
s:string;
i:integer;
begin
  s:='';
  for i := 0 to Length(value)-1 do
  begin
    s:=s+value[i];
    if i<Length(value)-1 then
      s:=s+' ';
  end;
  SetAttribute('ext',s);
end;

procedure TCapabilities.FSetNode(value: string);
begin
  SetAttribute('node',value);
end;

procedure TCapabilities.FSetVersion(value: string);
begin
  SetAttribute('ver',value);
end;

procedure TCapabilities.RemoveExtension(ext: string);
begin

end;

procedure TCapabilities.SetVersion(di: TDiscoInfo);
begin
  version:=buildcapsversion(di);
end;

end.
