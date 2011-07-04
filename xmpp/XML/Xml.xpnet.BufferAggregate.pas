unit Xml.xpnet.BufferAggregate;

interface
uses
  SysUtils,classes,Generics.Collections;
type
  TLinkBufNode=^TBufNode;
  TBufNode=record
    buf:tbytes;
    next:TLinkBufNode;
  end;
  TBufferAggregate=class
  private
    _stream:TBytesStream;
    _head,_tail:TLinkBufNode;
  public
    constructor Create;
    procedure Write(buf:TBytes);
    function GetBuffer():TBytes;
    procedure Clear(offset:Integer);
    function ToString:string;override;
  end;

implementation

{ TBufferAggregate }

procedure TBufferAggregate.Clear(offset: Integer);
var
  s,save,i,n:Integer;
  bn:TLinkBufNode;
  buf:Tbytes;
begin
  s:=0;
  save:=-1;
  bn:=_head;
  while bn<>nil do
  begin
    if s+length(bn.buf)<=offset then
    begin
      if s+length(bn.buf)=offset then
      begin
        bn:=bn.next;
        break;
      end;
      s:=s+Length(bn.buf);
    end
    else
    begin
      save:=s+length(bn.buf)-offset;
      break;
    end;
    bn:=bn.next;
  end;
    _head:=bn;
    if _head=nil then
      _tail:=nil;
    if save>0 then
    begin
      SetLength(buf,save);
      n:=Length(_head.buf)-save;
      for i := n to save do
        buf[i-n]:=_head.buf[i];
      _head.buf:=buf;
    end;
    if Assigned(_stream) then
    _stream.Clear;
    bn:=_head;
    while bn<>nil do
    begin
      //_stream.Write(bn.buf,Length(bn.buf));
      _stream:=TBytesStream.Create(bn.buf);
      bn:=bn.next;
    end;





end;

constructor TBufferAggregate.Create;
begin
  //_stream:=TMemoryStream.Create();
end;

function TBufferAggregate.GetBuffer: TBytes;
//var
//  buf:TBytes;
begin
  //_stream.ReadBuffer(buf,_stream.Size);
  result:=_stream.bytes;
end;

function TBufferAggregate.ToString: string;
begin
  result:=UTF8Decode(StringOf(GetBuffer));
end;

procedure TBufferAggregate.Write(buf: TBytes);
var
  n:TLinkBufNode;
begin
  _stream:=TBytesStream.Create(buf);//,Length(buf));
  if _tail=nil then
  begin
    New(_head);
    _head.next:=nil;
    New(_tail);
    _tail.next:=nil;
    _head.buf:=buf;
  end
  else
  begin
    New(n);
    n.next:=nil;
    n.buf:=buf;
    _tail.next:=n;
    _tail:=n;
  end;
end;

end.
