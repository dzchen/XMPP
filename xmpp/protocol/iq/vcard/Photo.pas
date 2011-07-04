unit Photo;

interface
uses
  Element,NativeXml,XmppUri,Graphics,Classes,IdHTTP,EncdDecd;

type
  TImageFormat=(ifnone=-1,Bmp=0,Emf,Exif,Gif,Icon,Jpeg,Png,Tiff,Wmf);
  TPhoto=class(TElement)
  private
    function FGetImageFormat:TImageFormat;

    function FGetType:string;
    procedure FSetType(value:string);
    function FGetImage:TBitmap;

  public
    constructor Create();override;
    constructor CreatePhoto(image:TBitmap;format:TImageFormat);overload;
    constructor CreatePhoto(url:string);overload;
    property PhotoType:string read FGetType write FSetType;
    procedure SetImage(url:string); overload;
    procedure SetImage(image:TBitmap;format:TImageFormat);overload;
    property ImageFormat:TImageFormat read FGetImageFormat;
    property Image:TBitmap read FGetImage;
  end;
var
  TagName:string='PHOTO';

implementation

{ TPhoto }

constructor TPhoto.CreatePhoto( image: TBitmap;
  format: TImageFormat);
begin
  self.Create();
  SetImage(image,format);
end;

constructor TPhoto.Create();
begin
  inherited Create();
  name:='PHOTO';
  Namespace:=XMLNS_VCARD;
end;

constructor TPhoto.CreatePhoto( url: string);
begin
  self.Create();
  SetImage(url);
end;

function TPhoto.FGetImage: TBitmap;
var
  tb:TBitmap;
  buf:TBytesStream;
  http:TIdHTTP;
begin
  if HasTag('BINVAL') then
  begin
    tb:=TBitmap.Create;
    buf:=TBytesStream.Create(DecodeBase64(GetTag('BINVAL')));
    tb.LoadFromStream(buf);
    Result:=tb;
    buf.Free;
  end
  else if HasTag('EXTVAL') then
  begin
    http:=TIdHTTP.Create();
    http.Get(GetTag('EXTVAL'),buf);
    tb:=TBitmap.Create;

    tb.LoadFromStream(buf);
    Result:=tb;
    buf.Free;
  end
  else
    Result:=nil;
end;

function TPhoto.FGetImageFormat: TImageFormat;
var
  s:string;
begin
  s:=GetTag('TYPE');
  if s='image/jpeg' then
  result:=Jpeg
  else if s='image/png'then
    Result:=Png
  else if s='image/gif' then
    Result:=Gif
  else if s='image/tiff'then
    Result:=Tiff
  else
    Result:=TImageFormat(-1);
end;

function TPhoto.FGetType: string;
begin
  Result:=GetTag('TYPE');
end;



procedure TPhoto.FSetType(value: string);
begin
  NodeFindOrCreate('TYPE').Value:=value;
end;

procedure TPhoto.SetImage(url: string);
begin
  NodeFindOrCreate('EXTVAL').Value:=url;
end;

procedure TPhoto.SetImage(image: TBitmap; format: TImageFormat);
var
  s:string;
  mem:TBytesStream;
begin
  if format=TImageFormat(-1) then
    format:=Png;
  s:='image';
  case format of
    Gif: s:='image/gif';
    Jpeg: s:='image/jpeg';
    Png: s:='image/png';
    Tiff: s:='image/tiff';
  end;
  NodeFindOrCreate('TYPE').Value:=s;
  image.SaveToStream(mem);

  NodeFindOrCreate('BINVAL').Value:=EncodeBase64(mem.Bytes,Integer(mem.Size));
end;

end.
