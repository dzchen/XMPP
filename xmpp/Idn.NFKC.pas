unit Idn.NFKC;

interface
uses
  SysUtils,Idn.CombiningClass;
type
  TNFKC=class
  const
    SBase:integer=$AC00;
    LBase:integer=$1100;
    VBase:integer=$1161;
    TBase:integer=$11A7;
    LCount:integer=19;
    VCount:integer=21;
    TCount:integer=28;
  public
    class function NormalizeNFKC(sbin:string):string;
    class function DecomposeIndex(c:Char):integer;
    class function CombiningClass(c:Char):integer;
    class procedure CanonicalOrdering(var sbin:TStringBuilder);
    class function ComposeIndex(a:Char):integer;
    class function Compose(a,b:Char):integer;
    class function DecomposHangul(s:Char):string;
    class function ComposeHangul(a,b:Char):integer;


  end;
  var
    NCount:integer;
    SCount:integer;
implementation

{ TNFKC }

class procedure TNFKC.CanonicalOrdering(var sbin: TStringBuilder);
var
  isordered:Boolean;
  lastcc,i,j,nextcc:integer;
  t:char;
begin
  isordered:=False;
  while not isordered do
  begin
    isordered:=true;
    lastcc:=0;
    if sbin.Length>0 then
      lastcc:=CombiningClass(sbin[0]);
    for i := 0 to sbin.Length-2 do
    begin
      nextcc:=CombiningClass(sbin[i+1]);
      if (nextcc<>0) and (lastcc>nextcc) then
      begin
        for j := i+1 downto 1 do
        begin
          if CombiningClass(sbin[j-1])<=nextcc then
            break;
          t:=sbin[j];
          sbin[j]:=sbin[j-1];
          sbin[j-1]:=t;
          isordered:=false;
        end;
        nextcc:=lastcc;
      end;
      lastcc:=nextcc;
    end;
  end;
end;

class function TNFKC.CombiningClass(c: Char): integer;
var
  h,l,i:integer;
begin
  h:=Ord(c) shr 8;
  l:=Ord(c) and $ff;
  i:=CombiningClass_i[h];
  if i>-1 then
    Result:=CombiningClass_c[i,l]
  else
    Result:=0;
end;

class function TNFKC.Compose(a, b: Char): integer;
var
  h,ai,bi,i:integer;
  f:array of char;
  r:char;
begin
  h:=ComposeHangul(a,b);
  if h<>-1 then
  begin
    Result:=h;
    exit;
  end;
  ai:=ComposeIndex(a);
  if (ai>=Composition_singleFirstStart) and (ai<Composition_singleSecondStart) then
  begin
    if b=Composition_singleFirst[ai-Composition_singleFirstStart,0] then
    begin
      Result:=Ord(Composition_singleFirst[ai - Composition_singleFirstStart, 1]);
      exit;
    end
    else
    begin
      Result:=-1;
      Exit;
    end;
  end;
  bi:=ComposeIndex(b);
  if (bi >= Composition_singleSecondStart)then
  begin
				if (a = Composition_singleSecond[bi - Composition_singleSecondStart,0])then
				begin
					result:=Ord(Composition_singleSecond[bi - Composition_singleSecondStart,1]);
          exit;
        end
				else
				begin
					Result:=- 1;
          Exit;
				end;
			end;

			if (ai >= 0) and (ai < Composition_multiSecondStart) and (bi >= Composition_multiSecondStart) and (bi < Composition_singleFirstStart)then
			begin
        SetLength(f,Length(Composition_multiFirst[ai]));
				for i := 0 to Length(Composition_multiFirst[ai])-1 do
          f[i]:=Composition_multiFirst[ai][i];

				if (bi - Composition_multiSecondStart < Length(f))then
				begin
					r := f[bi - Composition_multiSecondStart];
					if (Ord(r) = 0)then
					begin
						result:=- 1;
            exit;
					end
					else
					begin
						result:=Ord(r);
            exit;
					end;
				end;
			end;

			result:=-1;

end;

class function TNFKC.ComposeHangul(a, b: Char): integer;
var
  lindex,vindex,sindex,tindex:integer;
begin
  // 1. check to see if two current characters are L and V
			LIndex := Ord(a) - LBase;
			if (0 <= LIndex) and (LIndex < LCount)then
			begin
				VIndex := Ord(b) - VBase;
				if (0 <= VIndex) and (VIndex < VCount)then
				begin
					// make syllable of form LV
					Result:= SBase + (LIndex * VCount + VIndex) * TCount;
          Exit;
				end;
			end;

			// 2. check to see if two current characters are LV and T
			SIndex := Ord(a) - SBase;
			if (0 <= SIndex) and (SIndex < SCount) and ((SIndex mod TCount) = 0)then
			begin
				TIndex := Ord(b) - TBase;
				if (0 <= TIndex) and (TIndex <= TCount)then
				begin
					// make syllable of form LVT
					result:= Ord(a) + TIndex;
				  Exit;
        end;
			end;
			result:=-1;
end;

class function TNFKC.ComposeIndex(a: Char): integer;
var
  ap:integer;
begin
  if (Ord(a) shr 8) >= Length(Composition_composePage)then
  begin
				Result:=-1;
        exit;
  end;
	ap := Composition_composePage[Ord(a) shr 8];
			if (ap = - 1)then
			begin
				result:=- 1;
        exit;
			end;
			result:=Composition_composeData[ap, Ord(a) and $ff];
end;

class function TNFKC.DecomposeIndex(c: Char): integer;
var
  start,ed,half,code:integer;
begin
  start := 0;
	ed := Length(DecompositionKeys) div 2;

			while (true) do
			begin
				half := (start + ed) div 2;
				code := DecompositionKeys[half * 2];

				if (c = chr(code)) then
				begin
					result:=DecompositionKeys[half * 2 + 1];
          Exit;
				end;
				if (half = start)then
				begin
					// Character not found
					result:=-1;
          Exit;
        end
				else if (Ord(c) > code)then
				begin
					start := half;
				end
				else
				begin
					ed := half;
				end;
			end;
end;

class function TNFKC.DecomposHangul(s: Char): string;
var
  SIndex,l,v,t:integer;
  res:TStringBuilder;
begin
  sindex:=Ord(s)-sbase;
  if (SIndex<0)or(SIndex>=SCount) then
  begin
    result:=s;
    exit;
  end;
  res:=TStringBuilder.Create;
  l:=lbase+sindex div ncount;
  v:=vbase+(SIndex mod NCount)div tcount;
  t:=tbase+sindex mod tcount;
  res.Append(Chr(L));
  res.Append(Chr(V));
  if t<>TBase then
    res.Append(Chr(T));
  result:=res.ToString;
end;

class function TNFKC.NormalizeNFKC(sbin: string): string;
var
  sbout:TStringBuilder;
  i,index,lastcc,laststart,cc,c:integer;
  code,a,b:char;
begin
  sbout:=TStringBuilder.Create;
  for i := 1 to Length(sbin) do
  begin
    code:=sbin[i];
    if (Ord(code)>=$AC00) and (Ord(code)<=$D7AF) then
      sbout.Append(DecomposHangul(code))
    else
    begin
      index:=DecomposeIndex(code);
      if index=-1 then
        sbout.Append(code)
      else
        sbout.Append(DecompositionMappings[index]);
    end;
  end;
  CanonicalOrdering(sbout);
  lastcc:=0;laststart:=0;
  i:=0;
  while i<sbout.Length do
  begin
    cc:=CombiningClass(sbout[i]);
    if (i>0) and ((lastcc=0) or (lastcc<>cc)) then
    begin
      a:=sbout[laststart];
      b:=sbout[i];
      c:=Compose(a,b);
      if c<>-1 then
      begin
        sbout[laststart]:=chr(c);
        sbout.Remove(i,1);
        Dec(i);
        if i=laststart then
          lastcc:=0
        else
          lastcc:=CombiningClass(sbout[i-1]);
        Inc(i);
        Continue;
      end;
    end;
    if cc=0 then
    laststart:=i;
    lastcc:=cc;
    Inc(i);
  end;
  Result:=sbout.ToString;
end;
initialization
  NCount:=TNFKC.VCount*TNFKC.TCount;
    SCount:=TNFKC.LCount*NCount;

end.
