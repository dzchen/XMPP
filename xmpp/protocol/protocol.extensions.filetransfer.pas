unit protocol.extensions.filetransfer;

interface
uses
  XmppUri,Element,SysUtils,Time;
type
  TRange=class(TElement)
  private
    function FGetOffset:LongInt;
    procedure FSetOffset(value:LongInt);
    function FGetLen:LongInt;
    procedure FSetLen(value:LongInt);
  public
    constructor Create;overload;override;
    constructor Create(offset,len:LongInt);overload;
    property Offset:LongInt read FGetOffset write FSetOffset;
    property Len:LongInt read FGetLen write FSetLen;
  end;
  TFile=class(TElement)
  private
    function FGetFileName:string;
    procedure FSetFileName(value:string);
    function FGetSize:Int64;
    procedure FSetSize(value:Int64);
    function FGetHash:string;
    procedure FSetHash(value:string);
    function FGetDate:TDateTime;
    procedure FSetDate(value:TDateTime);
    function FGetDescription:string;
    procedure FSetDescription(value:string);
    function FGetRange:TRange;
    procedure FSetRange(value:TRange);
  public
    constructor Create;overload;override;
    constructor Create(name:string;size:Int64);overload;
    property FileName:string read FGetFileName write FSetFileName;
    property Size:Int64 read FGetSize write FSetSize;
    property Hash:string read FGetHash write FSetHash;
    property Date:TDateTime read FGetDate write FSetDate;
    property Description:string read FGetDescription write FSetDescription;
    property Range:TRange read FGetRange write FSetRange;
  end;

implementation

{ TRange }

constructor TRange.Create;
begin
  inherited;
  Name:='range';
  Namespace:=XMLNS_SI_FILE_TRANSFER;
end;

constructor TRange.Create(offset, len: Integer);
begin
self.Create;
self.Offset:=offset;
self.Len:=len;
end;

function TRange.FGetLen: LongInt;
begin
  Result:=StrToInt64(AttributeValueByName['length']);
end;

function TRange.FGetOffset: LongInt;
begin
  Result:=StrToInt64(AttributeValueByName['offset']);
end;

procedure TRange.FSetLen(value: Integer);
begin
  SetAttribute('length',IntToStr(value));
end;

procedure TRange.FSetOffset(value: Integer);
begin
  SetAttribute('offset',IntToStr(value));
end;

{ TFile }

constructor TFile.Create(name: string; size: Int64);
begin
  self.Create;
  self.FileName:=name;
  self.Size:=size;
end;

constructor TFile.Create;
begin
  inherited;
  Name:='file';
  namespace:=XMLNS_SI_FILE_TRANSFER;
end;

function TFile.FGetDate: TDateTime;
begin
  Result:=JabberToDateTime(AttributeValueByName['date']);
end;

function TFile.FGetDescription: string;
begin
  Result:=GetTag('desc');
end;

function TFile.FGetFileName: string;
begin
  Result:=AttributeValueByName['name'];
end;

function TFile.FGetHash: string;
begin
  Result:=AttributeValueByName['hash'];
end;

function TFile.FGetRange: TRange;
begin
  Result:=TRange(SelectSingleElement(TRange.ClassInfo));
end;

function TFile.FGetSize: Int64;
begin
  Result:=StrToInt64(AttributeValueByName['size']);
end;

procedure TFile.FSetDate(value: TDateTime);
begin
  SetAttribute('date',DateTimeToJabber(value));
end;

procedure TFile.FSetDescription(value: string);
begin
  SetTag('desc',value);
end;

procedure TFile.FSetFileName(value: string);
begin
  SetAttribute('name',value);
end;

procedure TFile.FSetHash(value: string);
begin
  SetAttribute('hash',value);
end;

procedure TFile.FSetRange(value: TRange);
begin
  RemoveTag(TRange.ClassInfo);
  NodeAdd(value);
end;

procedure TFile.FSetSize(value: Int64);
begin
  SetAttribute('size',IntToStr(value));
end;

end.
