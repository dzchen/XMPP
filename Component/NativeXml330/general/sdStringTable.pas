{ unit sdStringTable

  Author: Nils Haeck M.Sc. (n.haeck@simdesign.nl)
  Original Date: 28 May 2007
  Version: 1.1
  Copyright (c) 2007 - 2011 Simdesign BV

  Enhancement 05jan2011: no longer uses stringrec

  It is NOT allowed under ANY circumstances to publish or copy this code
  without accepting the license conditions in accompanying LICENSE.txt
  first!

  This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
  ANY KIND, either express or implied.

  Please visit http://www.simdesign.nl/xml.html for more information.
}
unit sdStringTable;

{$ifdef lcl}{$MODE Delphi}{$endif}

interface

uses
  Classes, SysUtils, Contnrs, sdDebug;

type

  // A string reference item used in string reference lists (do not use directly)
  TsdRefString = class
  private
    FID: integer;
    FFrequency: integer;
    FFirst: Pbyte;
    FCharCount: integer;
  protected
    procedure AddString(const S: Utf8String);
    procedure AddStringRec(AFirst: PByte; ACharCount: integer);
  public
    destructor Destroy; override;
    function AsString: Utf8String;
    property CharCount: integer read FCharCount;
    property Frequency: integer read FFrequency;
  end;

  // A list of string reference items (do not use directly)
  TsdRefStringList = class(TObjectList)
  private
    function GetItems(Index: integer): TsdRefString;
  protected
    // Assumes list is sorted by Id
    function IndexOfID(AID: integer): integer;// var Index: integer): boolean;
    // Assumes list is sorted by ref string
    function IndexOfRS(ARefString: TsdRefString; AllowNonExistent: boolean = False): integer;
  public
    property Items[Index: integer]: TsdRefString read GetItems; default;
  end;

  // A string table, holding a collection of unique strings, sorted in 2 ways
  // for fast access. Strings can be added with AddString or AddStringRec,
  // and should be updated with SetString. When a string is added or updated,
  // an ID is returned which the application can use to retrieve the string,
  // using GetString.
  TsdStringTable = class(TDebugPersistent)
  private
    FByID: TsdRefStringList;
    FByRS: TsdRefStringList;
    FTempRefString: TsdRefString;
  protected
    procedure DecFrequency(AItem: TsdRefString);
    function NextUniqueID: integer;
    // Add a new refstring, return fresh ID or ID of existing item, and increase
    // the existing item's frequency
    function AddRefString(ARefString: TsdRefString): integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    // Add a new string S to the table, the function returns its ID.
    function AddString(const S: Utf8String): integer;
    // Delete reference of a string S in the string table, Result = True
    // if successful
    function DeleteString(const S: Utf8String): boolean;
    // Get the refstring by ID
    function ByID(Index: integer): TsdRefString;
    // Get the string of refstring with ID
    function GetString(ID: integer): Utf8String;
    // Number of refstrings
    function StringCount: integer;
    procedure SaveToFile(const AFileName: string);
    procedure SaveToStream(S: TStream);
  end;

{utility functions}

// compare two ref strings. This is NOT an alphabetic compare. SRs are first
// compared by length, then by first byte, then last byte then second, then
// N-1, until all bytes are compared.
function sdCompareRefString(RS1, RS2: TsdRefString): integer;

// compare two bytes
function sdCompareByte(Byte1, Byte2: byte): integer;

// compare two integers
function sdCompareInteger(Int1, Int2: integer): integer;

function sdUtf16ToUtf8Mem(Src: Pword; Dst: Pbyte; Count: integer): integer;
function sdUtf8ToUtf16Mem(var Src: Pbyte; Dst: Pword; Count: integer): integer;
procedure sdStreamWrite(S: TStream; const AString: Utf8String);
procedure sdStreamWriteRefString(S: TStream; ARefString: TsdRefString);

implementation

{ TsdRefString }

function TsdRefString.AsString: Utf8String;
begin
  SetString(Result, PAnsiChar(FFirst), FCharCount);
end;

destructor TsdRefString.Destroy;
begin
  FreeMem(FFirst);
  inherited;
end;

procedure TsdRefString.AddString(const S: Utf8String);
begin
  FCharCount := Length(S);
  ReallocMem(FFirst, FCharCount);
  Move(S[1], FFirst^, FCharCount);
end;

procedure TsdRefString.AddStringRec(AFirst: PByte; ACharCount: integer);
begin
  FCharCount := ACharCount;
  ReallocMem(FFirst, FCharCount);
  Move(AFirst^, FFirst^, FCharCount);
end;

{ TsdRefStringList }

function TsdRefStringList.GetItems(Index: integer): TsdRefString;
begin
  Result := Get(Index);
end;

function TsdRefStringList.IndexOfID(AID: integer): integer;
var
  Index, Min, Max: integer;
begin
  // Find position - binary method
  Min := 0;
  Max := Count;
  while Min < Max do
  begin
    Index := (Min + Max) div 2;
    case sdCompareInteger(Items[Index].FID, AID) of
    -1: Min := Index + 1;
     0: begin
          Result := Index;
          exit;
        end;
     1: Max := Index;
    end;
  end;

  Result := -1;
end;

function TsdRefStringList.IndexOfRS(ARefString: TsdRefString; AllowNonExistent: boolean = False): integer;
var
  Index, Min, Max: integer;
  RS: TsdRefString;
begin
  Index := 0;
  // Find position - binary method
  Min := 0;
  Max := Count;
  while Min < Max do
  begin
    Index := (Min + Max) div 2;
    RS := Items[Index];
    case sdCompareRefString(RS, ARefString) of
    -1: Min := Index + 1;
     0: begin
          Result := Index;
          exit;
        end;
     1: Max := Index;
    end;
  end;
  if AllowNonExistent then
    Result := Index
  else
    Result := -1;
end;

{ TsdStringTable }

function TsdStringTable.AddString(const S: Utf8String): integer;
begin
  if length(S) > 0 then
  begin
    FTempRefString.AddString(S);
    Result := AddRefString(FTempRefString);
  end else
    Result := 0;
end;

function TsdStringTable.AddRefString(ARefString: TsdRefString): integer;
var
  ByRSIndex: integer;
  Item: TsdRefString;
begin
  // zero-length string
  if ARefString.CharCount = 0 then
  begin
    Result := 0;
    exit;
  end;

  // Try to find the new string
  ByRSIndex := FByRS.IndexOfRS(ARefString);
  if ByRSIndex >= 0 then
  begin
    // yes it is found
    Item := FByRS.Items[ByRSIndex];
    inc(Item.FFrequency);
    Result := Item.FID;
    exit;
  end;

  // Not found.. must make new item
  Item := TsdRefString.Create;
  Item.AddStringRec(ARefString.FFirst, ARefString.FCharCount);
  Item.FFrequency := 1;
  Item.FID := NextUniqueID;
  FById.Add(Item);

  // Insert in ByRS lists
  ByRSIndex := FByRS.IndexOfRS(Item, True);
  FByRS.Insert(ByRSIndex, Item);

  Result := Item.FID;
end;

function TsdStringTable.DeleteString(const S: Utf8String): boolean;
var
  ByRSIndex: integer;
begin
  FTempRefString.AddString(S);
  ByRSIndex := FByRS.IndexOfRS(FTempRefString);
  Result := ByRSIndex >= 0;
  if Result then
    DecFrequency(FByRS.Items[ByRSIndex]);
end;

function TsdStringTable.ByID(index: integer): TsdRefString;
begin
  Result := FByID[Index];
end;

procedure TsdStringTable.Clear;
begin
  FByID.Clear;
  FByRS.Clear;
end;

constructor TsdStringTable.Create;
begin
  inherited Create;
  FByID := TsdRefStringList.Create(False);
  FByRS := TsdRefStringList.Create(True);
  FTempRefString := TsdRefString.Create;
end;

procedure TsdStringTable.DecFrequency(AItem: TsdRefString);
var
  ByIDIndex: integer;
  ByRSIndex: integer;
begin
  dec(AItem.FFrequency);
  assert(AItem.FFrequency >= 0);

  if AItem.FFrequency = 0 then
  begin
    // We must remove it
    ByIDIndex := FByID.IndexOfID(AItem.FID);
    FById.Delete(ByIDIndex);
    ByRSIndex := FByRS.IndexOfRS(AItem);
    FByRS.Delete(ByRSIndex);
  end;
end;

destructor TsdStringTable.Destroy;
begin
  FreeAndNil(FByID);
  FreeAndNil(FByRS);
  FreeAndNil(FTempRefString);
  inherited;
end;

function TsdStringTable.GetString(ID: integer): Utf8String;
var
  Index: integer;
  Item: TsdRefString;
begin
  if ID <= 0 then
  begin
    Result := '';
    exit;
  end;

  // Find the ID
  Index := FByID.IndexOfID(ID);
  if Index >= 0 then
  begin
    Item := FById[Index];
    Result := Item.AsString;
    exit;
  end;

  // output warning
  DoDebugOut(Self, wsWarn, 'string ID not found');
  Result := '';
end;

function TsdStringTable.NextUniqueID: integer;
begin
  if FById.Count = 0 then
    Result := 1
  else
    Result := FByID[FByID.Count - 1].FID + 1;
end;

procedure TsdStringTable.SaveToFile(const AFileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

procedure TsdStringTable.SaveToStream(S: TStream);
var
  i: integer;
  Res: Utf8String;
begin
  for i := 0 to FByRS.Count - 1 do
  begin
    Res := Utf8String(FByRS[i].AsString) + #9 + Utf8String(IntToStr(FByRS[i].FFrequency)) + #13#10;
    S.Write(Res[1], length(Res));
  end;
end;

function TsdStringTable.StringCount: integer;
begin
  Result := FByRS.Count;
end;

{utility functions}


function sdCompareByte(Byte1, Byte2: byte): integer;
begin
  if Byte1 < Byte2 then
    Result := -1
  else
    if Byte1 > Byte2 then
      Result := 1
    else
      Result := 0;
end;

function sdCompareInteger(Int1, Int2: integer): integer;
begin
  if Int1 < Int2 then
    Result := -1
  else
    if Int1 > Int2 then
      Result := 1
    else
      Result := 0;
end;

function sdCompareRefString(RS1, RS2: TsdRefString): integer;
var
  CharCount: integer;
  First1, First2, Last1, Last2: Pbyte;
begin
  // Compare string length first
  Result := sdCompareInteger(RS1.CharCount, RS2.CharCount);
  if Result <> 0 then
    exit;

  // Compare first
  Result := sdCompareByte(RS1.FFirst^, RS2.FFirst^);
  if Result <> 0 then
    exit;
  CharCount := RS1.CharCount;

  // Setup First & Last pointers
  First1 := RS1.FFirst;
  First2 := RS2.FFirst;
  Last1 := First1;
  inc(Last1, CharCount);
  Last2 := First2;
  inc(Last2, CharCount);

  // Compare each time last ptrs then first ptrs, until they meet in the middle
  repeat
    dec(Last1);
    dec(Last2);
    if First1 = Last1 then
      exit;
    Result := sdCompareByte(Last1^, Last2^);
    if Result <> 0 then
      exit;
    inc(First1);
    inc(First2);
    if First1 = Last1 then
      exit;
    Result := sdCompareByte(First1^, First2^);
    if Result <> 0 then
      exit;
  until False;
end;

function sdUtf16ToUtf8Mem(Src: Pword; Dst: Pbyte; Count: integer): integer;
// Convert an Unicode (UTF16 LE) memory block to UTF8. This routine will process
// Count wide characters (2 bytes size) to Count UTF8 characters (1-3 bytes).
// Therefore, the block at Dst must be at least 1.5 the size of the source block.
// The function returns the number of *bytes* written.
var
  W: word;
  DStart: Pbyte;
begin
  DStart := Dst;
  while Count > 0 do
  begin
    W := Src^;
    inc(Src);
    if W <= $7F then
    begin
      Dst^ := byte(W);
      inc(Dst);
    end else
    begin
      if W > $7FF then
      begin
        Dst^ := byte($E0 or (W shr 12));
        inc(Dst);
        Dst^ := byte($80 or ((W shr 6) and $3F));
        inc(Dst);
        Dst^ := byte($80 or (W and $3F));
        inc(Dst);
      end else
      begin //  $7F < W <= $7FF
        Dst^ := byte($C0 or (W shr 6));
        inc(Dst);
        Dst^ := byte($80 or (W and $3F));
        inc(Dst);
      end;
    end;
    dec(Count);
  end;
  Result := integer(Dst) - integer(DStart);
end;

function sdUtf8ToUtf16Mem(var Src: Pbyte; Dst: Pword; Count: integer): integer;
// Convert an UTF8 memory block to Unicode (UTF16 LE). This routine will process
// Count *bytes* of UTF8 (each character 1-3 bytes) into UTF16 (each char 2 bytes).
// Therefore, the block at Dst must be at least 2 times the size of Count, since
// many UTF8 characters consist of just one byte, and are mapped to 2 bytes. The
// function returns the number of *wide chars* written. Note that the Src block must
// have an exact number of UTF8 characters in it, if Count doesn't match then
// the last character will be converted anyway (going past the block boundary!)
var
  W: word;
  C: byte;
  DStart: Pword;
  SClose: Pbyte;
begin
  DStart := Dst;
  SClose := Src;
  inc(SClose, Count);
  while integer(Src) < integer(SClose) do
  begin
    // 1st byte
    W := Src^;
    inc(Src);
    if W and $80 <> 0 then
    begin
      W := W and $3F;
      if W and $20 <> 0 then
      begin
        // 2nd byte
        C := Src^;
        inc(Src);
        if C and $C0 <> $80 then
          // malformed trail byte or out of range char
          Continue;
        W := (W shl 6) or (C and $3F);
      end;
      // 2nd or 3rd byte
      C := Src^;
      inc(Src);
      if C and $C0 <> $80 then
        // malformed trail byte
        Continue;
      Dst^ := (W shl 6) or (C and $3F);
      inc(Dst);
    end else
    begin
      Dst^ := W;
      inc(Dst);
    end;
  end;
  Result := (integer(Dst) - integer(DStart)) div 2;
end;

procedure sdStreamWrite(S: TStream; const AString: Utf8String);
var
  L: integer;
begin
  L := Length(AString);
  if L > 0 then
  begin
    S.Write(AString[1], L);
  end;
end;

procedure sdStreamWriteRefString(S: TStream; ARefString: TsdRefString);
begin
  if ARefString = nil then
    exit;
  S.Write(PAnsiChar(ARefString.FFirst)^, ARefString.FCharCount);
end;

end.
