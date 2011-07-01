unit Base64;

interface


  function Base64Encode(const Source: string): string;
  function Base64Decode(const Source: string): string;

implementation
const
  Base64_Table : shortstring = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function Base64Encode(const Source: string): string;
var
  NewLength: Integer;
begin
  NewLength := ((2 + Length(Source)) div 3) * 4;
  SetLength( Result, NewLength);

  asm
    Push  ESI
    Push  EDI
    Push  EBX
    Lea   EBX, Base64_Table
    Inc   EBX                // Move past String Size (ShortString)
    Mov   EDI, Result
    Mov   EDI, [EDI]
    Mov   ESI, Source
    Mov   EDX, [ESI-4]        //Length of Input String
@WriteFirst2:
    CMP EDX, 0
    JLE @Done
    MOV AL, [ESI]
    SHR AL, 2
{$IFDEF VER140} // Changes to BASM in D6
    XLATB
{$ELSE}
    XLAT
{$ENDIF}
    MOV [EDI], AL
    INC EDI
    MOV AL, [ESI + 1]
    MOV AH, [ESI]
    SHR AX, 4
    AND AL, 63
{$IFDEF VER140} // Changes to BASM in D6
    XLATB
{$ELSE}
    XLAT
{$ENDIF}
    MOV [EDI], AL
    INC EDI
    CMP EDX, 1
    JNE @Write3
    MOV AL, 61                        // Add ==
    MOV [EDI], AL
    INC EDI
    MOV [EDI], AL
    INC EDI
    JMP @Done
@Write3:
    MOV AL, [ESI + 2]
    MOV AH, [ESI + 1]
    SHR AX, 6
    AND AL, 63
{$IFDEF VER140} // Changes to BASM in D6
    XLATB
{$ELSE}
    XLAT
{$ENDIF}
    MOV [EDI], AL
    INC EDI
    CMP EDX, 2
    JNE @Write4
    MOV AL, 61                        // Add =
    MOV [EDI], AL
    INC EDI
    JMP @Done
@Write4:
    MOV AL, [ESI + 2]
    AND AL, 63
{$IFDEF VER140} // Changes to BASM in D6
    XLATB
{$ELSE}
    XLAT
{$ENDIF}
    MOV [EDI], AL
    INC EDI
    ADD ESI, 3
    SUB EDX, 3
    JMP @WriteFirst2
@done:
    Pop EBX
    Pop EDI
    Pop ESI
  end;
end;

//Decode Base64
function Base64Decode(const Source: string): string;
var
  NewLength: Integer;
begin
{
  NB: On invalid input this routine will simply skip the bad data, a
better solution would probably report the error


  ESI -> Source String
  EDI -> Result String

  ECX -> length of Source (number of DWords)
  EAX -> 32 Bits from Source
  EDX -> 24 Bits Decoded

  BL -> Current number of bytes decoded
}

  SetLength( Result, (Length(Source) div 4) * 3);
  NewLength := 0;
  asm
    Push  ESI
    Push  EDI
    Push  EBX

    Mov   ESI, Source

    Mov   EDI, Result //Result address
    Mov   EDI, [EDI]

    Or    ESI,ESI   // Nil Strings
    Jz    @Done

    Mov   ECX, [ESI-4]
    Shr   ECX,2       // DWord Count

    JeCxZ @Error      // Empty String

    Cld

    jmp   @Read4

  @Next:
    Dec   ECX
    Jz   @Done

  @Read4:
    lodsd

    Xor   BL, BL
    Xor   EDX, EDX

    Call  @DecodeTo6Bits
    Shl   EDX, 6
    Shr   EAX,8
    Call  @DecodeTo6Bits
    Shl   EDX, 6
    Shr   EAX,8
    Call  @DecodeTo6Bits
    Shl   EDX, 6
    Shr   EAX,8
    Call  @DecodeTo6Bits


  // Write Word

    Or    BL, BL
    JZ    @Next  // No Data

    Dec   BL
    Or    BL, BL
    JZ    @Next  // Minimum of 2 decode values to translate to 1 byte

    Mov   EAX, EDX

    Cmp   BL, 2
    JL    @WriteByte

    Rol   EAX, 8

    BSWAP EAX

    StoSW

    Add NewLength, 2

  @WriteByte:
    Cmp BL, 2
    JE  @Next
    SHR EAX, 16
    StoSB

    Inc NewLength
    jmp   @Next

  @Error:
    jmp @Done

  @DecodeTo6Bits:

  @TestLower:
    Cmp AL, 'a'
    Jl @TestCaps
    Cmp AL, 'z'
    Jg @Skip
    Sub AL, 71
    Jmp @Finish

  @TestCaps:
    Cmp AL, 'A'
    Jl  @TestEqual
    Cmp AL, 'Z'
    Jg  @Skip
    Sub AL, 65
    Jmp @Finish

  @TestEqual:
    Cmp AL, '='
    Jne @TestNum
    // Skip byte
    ret

  @TestNum:
    Cmp AL, '9'
    Jg @Skip
    Cmp AL, '0'
    JL  @TestSlash
    Add AL, 4
    Jmp @Finish

  @TestSlash:
    Cmp AL, '/'
    Jne @TestPlus
    Mov AL, 63
    Jmp @Finish

  @TestPlus:
    Cmp AL, '+'
    Jne @Skip
    Mov AL, 62

  @Finish:
    Or  DL, AL
    Inc BL

  @Skip:
    Ret

  @Done:
    Pop   EBX
    Pop   EDI
    Pop   ESI

  end;

  SetLength( Result, NewLength); // Trim off the excess
end;

end.
