unit Xml.xpnet.Token;

interface
uses
  SysUtils;
type
  TToken=class
  private
    _tokenend,_nameend:integer;
    _refchar1:Char;
    _refchar2:Char;
  public
    property TokenEnd:Integer read _tokenend write _tokenend;
    property NameEnd:Integer read _nameend write _nameend;
    property RefChar1:Char read _refchar1 write _refchar1;
    property RefChar2:Char read _refchar2 write _refchar2;
  end;
  //TATTArray=array[0..7] of integer;
  //TATTBoolArray=array[0..7] of Boolean;
  TContentToken=class(TToken)
  private
    _attcount:Integer;
    _attnamestart,_attnameend,_attvaluestart,_attvalueend:Tarray<integer>;
    _attNormalized:TArray<boolean>;
    procedure Grow(var v:Tarray<integer>);overload;
    procedure Grow(var v:TArray<boolean>);overload;
  public
    constructor Create;
    function GetAttributeSpecifiedCount():integer;
    function GetAttributeNameStart(i:Integer):integer;
    function GetAttributeNameEnd(i:Integer):Integer;
    function GetAttributeValueStart(i:Integer):integer;
    function GetAttributeValueEnd(i:Integer):Integer;
    function IsAttributeNormalized(i:Integer):Boolean;
    procedure ClearAttributes();
    procedure AppendAttribute(namestart,nameend,valuestart,valueend:Integer;normalized:Boolean);
    procedure CheckAttributeUniqueness(buf:Tbytes);

  end;
implementation
const
  INIT_ATT_COUNT=8;

{ TContentToken }

procedure TContentToken.AppendAttribute(namestart, nameend, valuestart,
  valueend: Integer; normalized: Boolean);
begin
  if _attcount=Length(_attnamestart) then
  begin
    grow(_attnamestart);
    grow(_attnameend);
    grow(_attvaluestart);
    grow(_attvalueend);
    grow(_attNormalized);
  end;
  _attnamestart[_attcount]:=namestart;
  _attnameend[_attcount]:=nameend;
  _attvaluestart[_attcount]:=valuestart;
  _attvalueend[_attcount]:=valueend;
  _attNormalized[_attcount]:=normalized;
  _attcount:=_attcount+1;


end;

procedure TContentToken.CheckAttributeUniqueness(buf: Tbytes);
var
  i,j,len,n,s1,s2:integer;
begin
  for i := 0 to _attcount-1 do
  begin
    len:=_attnameend[i]-_attnamestart[i];
    for j := 0 to i-1 do
    begin
      if _attnameend[j]-_attnamestart[j]=len then
      begin
        n:=len;
        s1:=_attnamestart[i];
        s2:=_attnamestart[j];
        repeat
          n:=n-1;
           s1:=s1+1;
           s2:=s2+1;
        until buf[s1]=buf[s2] ;


      end;
    end;
  end;
end;

procedure TContentToken.ClearAttributes;
begin
  _attcount:=0;
end;

constructor TContentToken.Create;
begin
  SetLength(_attnamestart,8);
    SetLength(_attnameend,8);
    SetLength(_attvaluestart,8);
    SetLength(_attvalueend,8);
    SetLength(_attNormalized,8);
end;

function TContentToken.GetAttributeNameEnd(i: Integer): Integer;
begin
  if i>=_attcount then
    raise Exception.Create('EArgumentOutOfRangeException');
  Result:=_attnameend[i];
end;

function TContentToken.GetAttributeNameStart(i: Integer): integer;
begin
  if i>=_attcount then
    raise Exception.Create('EArgumentOutOfRangeException');
  Result:=_attnamestart[i];

end;

function TContentToken.GetAttributeSpecifiedCount: integer;
begin
  result:=_attcount;
end;

function TContentToken.GetAttributeValueEnd(i: Integer): Integer;
begin
  if i>=_attcount then
    raise Exception.Create('EArgumentOutOfRangeException');
  Result:=_attvalueend[i];

end;

function TContentToken.GetAttributeValueStart(i: Integer): integer;
begin
  if i>=_attcount then
    raise Exception.Create('EArgumentOutOfRangeException');
  Result:=_attvaluestart[i];

end;

procedure TContentToken.Grow(var v:Tarray<integer>);
begin
  //tem:=Copy(v,0,Length(v));
  //vararray
  //VarArrayRedim(v,(Length(v)shl 1));
  SetLength(v,Length(v)shl 1);
  //CopyArray(v,tem,Integer,);
  //for i := 0 to Length(v)-1 do
    //tem[i]:=v[i];
  //Result:=tem;
end;

procedure TContentToken.Grow(var v:TArray<boolean>);
var
  tem:array of Boolean;
  i:integer;
begin
  //tem:=v;
  //SetLength(v,Length(tem)shl 1);
  //CopyArray(v,tem,Integer,);
  //for i := 0 to Length(tem)-1 do
   // v[i]:=tem[i];
  SetLength(v,Length(v)shl 1);
end;

function TContentToken.IsAttributeNormalized(i: Integer): Boolean;
begin
  if i>=_attcount then
    raise Exception.Create('EArgumentOutOfRangeException');
  result:=_attNormalized[i];
end;

end.
