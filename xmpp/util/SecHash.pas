unit SecHash;

{ Component TSecHash Version 0.03 by Frank Kroeger

  History:
  ********

   08.06.1998: - new release version 0.03
               - procedure SHA now declared as assembler without local variables
               - restructuring of assembler code and functions ComputeString and
                 ComputeMem
                 thanks to Kovacs Attila Zoltan (kaz@freemail.c3.hu)

   03.06.1998: - new release version 0.02
               - fixed bug when last data block holds less than 56 bytes
                 ( thanks to        Ivan Saorin (isscsi@tin.it) and
                                    Jevgenij Gorbunov (gorbunov@med.muni.cz)
                   for pointing this out)
               - some changes in the assembler code
               - temp variables now belong to the instance of TSecHash which
                 uses them

   01.05.1998: - First release
}

interface

uses
    SysUtils, Classes;

type
  ESecHashException = class(Exception);
  TByteArray = Array[0..0] of Byte;
  pByteArray = ^TByteArray;
  TIntDigest = Array[0..4] of integer;
  TByteDigest = Array[0..19] of Byte;
  TSecHash = class(TComponent)
  private
    { Private-Deklarationen }
    klVar, grVar : TIntDigest;
    M : Array[0..63] of Byte;
    W : Array[0..79] of Integer;
    K : Array[0..79] of Integer;
    procedure InitSHA;
    procedure SHA;
  protected
    { Protected-Deklarationen }
  public
    { Public-Deklarationen }
    function ComputeString(const Msg:RawByteString):TIntDigest;
    function ComputeFile(FileName:String):TIntDigest;
    function ComputeMem(mem:PAnsiChar;length:integer):TIntDigest;
    function IntDigestToByteDigest(IntDigest:TIntDigest):TByteDigest;
    class function Sha1Hash(fkey: string): string;
  published
    { Published-Deklarationen }
  end;

procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('FKS', [TSecHash]);
end;

{$WARNINGS OFF}
procedure TSecHash.InitSHA;
var i : integer;
begin
   For i:= 0 to 19 do
   begin
      K[i]   :=$5a827999;
      K[i+20]:=$6ed9eba1;
      K[i+40]:=$8f1bbcdc;
      K[i+60]:=$ca62c1d6;
   end;
   grVar[0]:=$67452301;
   grVar[1]:=$efcdab89;
   grVar[2]:=$98badcfe;
   grVar[3]:=$10325476;
   grVar[4]:=$c3d2e1f0;
end;
{$WARNINGS ON}


procedure TSecHash.SHA;assembler;
asm
   push ebx
   push edi
   push esi
   mov edx, eax            // pointer to Self (instance of SecHash)
   lea esi, [edx].GrVar[0] // Load Address of GrVar[0]
   lea edi, [edx].KlVar[0] // Load Address of KlVar[0]
   mov ecx, 5
   cld
   rep movsd               // copy GrVar[] to KlVar[]
   xor ecx, ecx
   lea edi, [edx].M[0]     // Load Address of M[0]
   lea esi, [edx].W[0]     // Load Address of W[0]
@@Kopieren_M_nach_W_0_15:
   mov eax, [edi+ecx]      // Copy M[0..15] to W[0..15] while changing from
   rol ax, 8               // Little endian to Big endian
   rol eax, 16
   rol ax, 8
   mov [esi+ecx], eax
   add ecx, 4
   cmp ecx, 64
   jl @@Kopieren_M_nach_W_0_15
   xor ecx, ecx
   mov edi, esi
   add edi, 64
@@Kopieren_M_nach_W_16_79:
   mov eax, [edi+ecx-12]     // W[t] = W[t-3] xor W[t-8] xor W[t-14] xor W[t-16] <<< 1
   xor eax, [edi+ecx-32]
   xor eax, [edi+ecx-56]
   xor eax, [edi+ecx-64]
   rol eax, 1
   mov [edi+ecx], eax
   add ecx, 4
   cmp ecx, 256
   jl @@Kopieren_M_nach_W_16_79
   lea edi, [edx].KlVar[0]
   mov ecx, 20
   xor esi, esi
@@B_0_19:
   mov eax, [edi+4]          // t=0..19: TEMP=(a <<< 5)+f[t](b,c,d)
   mov ebx, eax              // f[t](b,c,d) = (b and c) or ((not b) and d)
   and eax, [edi+8]
   not ebx
   and ebx, [edi+12]
   or eax, ebx
   call @@Ft_Common
   add esi, 4
   dec ecx
   jnz @@B_0_19
   mov ecx, 20
@@B_20_39:
   mov eax, [edi+4]          // t=20..39: TEMP=(a <<< 5)+f[t](b,c,d)
   xor eax, [edi+8]          // f[t](b,c,d) = b xor c xor d
   xor eax, [edi+12]
   call @@Ft_Common
   add esi, 4
   dec ecx
   jnz @@B_20_39
   mov ecx, 20
@@B_40_59:
   mov eax, [edi+4]          // t=40..59: TEMP=(a <<< 5)+f[t](b,c,d)
   mov ebx, eax              // f[t](b,c,d) = (b and c) or (b and d) or (c and d)
   and eax, [edi+8]
   and ebx, [edi+12]
   or eax, ebx
   mov ebx, [edi+8]
   and ebx, [edi+12]
   or eax, ebx
   call @@Ft_Common
   add esi, 4
   dec ecx
   jnz @@B_40_59
   mov ecx, 20
@@B_60_79:
   mov eax, [edi+4]          // t=60..79: TEMP=(a <<< 5)+f[t](b,c,d)
   xor eax, [edi+8]          // f[t](b,c,d) = b xor c xor d
   xor eax, [edi+12]
   call @@Ft_Common
   add esi, 4
   dec ecx
   jnz @@B_60_79
   lea esi, [edx].GrVar[0]   // Load Address of GrVar[0]
   mov eax, [edi]            // For i:=0 to 4 do GrVar[i]:=GrVar[i]+klVar[i]
   add eax, [esi]
   mov [esi], eax
   mov eax, [edi+4]
   add eax, [esi+4]
   mov [esi+4], eax
   mov eax, [edi+8]
   add eax, [esi+8]
   mov [esi+8], eax
   mov eax, [edi+12]
   add eax, [esi+12]
   mov [esi+12], eax
   mov eax, [edi+16]
   add eax, [esi+16]
   mov [esi+16], eax
   pop esi
   pop edi
   pop ebx
   jmp @@End
@@Ft_Common:
   add eax, [edi+16]         // + e
   lea ebx, [edx].W[0]
   add eax, [ebx+esi]        // + W[t]
   lea ebx, [edx].K[0]
   add eax, [ebx+esi]        // + K[t]
   mov ebx, [edi]
   rol ebx, 5                // ebx = a <<< 5
   add eax, ebx              // eax = (a <<< 5)+f[t](b,c,d)+e+W[t]+K[t]
   mov ebx, [edi+12]
   mov [edi+16], ebx         // e = d
   mov ebx, [edi+8]
   mov [edi+12], ebx         // d = c
   mov ebx, [edi+4]
   rol ebx, 30
   mov [edi+8], ebx          // c = b <<< 30
   mov ebx, [edi]
   mov [edi+4], ebx          // b = a
   mov [edi], eax            // a = TEMP
   ret
@@End:
end;


class function TSecHash.Sha1Hash(fkey: string): string;
var
    hasher: TSecHash;
    h: TIntDigest;
    i: integer;
    s: string;
begin
    // Do a SHA1 hash using the sechash.pas unit
    hasher := TSecHash.Create(nil);
    h := hasher.ComputeString(UTF8Encode(fkey));
    s := '';
    for i := 0 to 4 do
        s := s + IntToHex(h[i], 8);
    s := Lowercase(s);
    hasher.Free;
    Result := s;
end;

function TSecHash.ComputeMem(Mem:PAnsiChar;length:integer):TIntDigest;
var
    i,BitsLow,BitsHigh,ToCompute : integer;

begin
   Try
      BitsHigh:=(length and $FF000000) shr 29;
      BitsLow:=length shl 3;
      InitSHA;
      ToCompute:=length;
      While ToCompute>0 do
      begin
         If ToCompute>=64 then
         begin
            for i:=0 to 63 do begin M[i]:=ord(Mem^); inc(Mem); end;
            SHA;
            dec(ToCompute,64);
            If ToCompute=0 then
            begin
               FillChar(M,sizeof(M),0);
               M[0]:=$80;
        end;
     end else
         begin // ToCompute<64
            FillChar(M,SizeOf(M),0);
            for i:=0 to ToCompute-1 do begin M[i]:=ord(Mem^); inc(Mem); end;
            M[ToCompute]:=$80;
            If ToCompute>=56 then
            begin
               SHA;
               FillChar(M,SizeOf(M),0);
        end;
            ToCompute:=0;
     end; //End else ToCompute>=64
         If ToCompute=0 then
         begin
            M[63]:=BitsLow and $000000FF;
            M[62]:=(BitsLow and $0000FF00) shr 8;
            M[61]:=(BitsLow and $00FF0000) shr 16;
            M[60]:=(BitsLow and $FF000000) shr 24;
            M[59]:=(BitsHigh and $000000FF);
            SHA;
     end;
  end; //End While ToCompute>0
      Result:=grVar;
   finally
   end;
end;

function TSecHash.ComputeString(const Msg:RawByteString):TIntDigest;
begin
   Result:=ComputeMem(PAnsiChar(Msg),length(Msg));
end;


function TSecHash.ComputeFile(FileName:String):TIntDigest;
var f : file;
    ToCompute : integer;
    BitsLow, BitsHigh : integer;
begin
   Try
      InitSHA;
      Try
         AssignFile(f,filename);
         reset(f,1);
      except
         on exception do
           Raise ESecHashException.Create('File not found !');
  end;
      Try
         ToCompute:=FileSize(f);
         BitsHigh:=(ToCompute and $FF000000) shr 29;
         BitsLow :=(ToCompute shl 3);
         While ToCompute>0 do
         begin
            If ToCompute>=64 then
            begin
               BlockRead(F,M,64);
               SHA;
               dec(ToCompute,64);
               If ToCompute=0 then
               begin
                  FillChar(M,sizeof(M),0);
                  M[0]:=$80;
           end;
        end else
            begin // ToCompute<64
               FillChar(M,SizeOf(M),0);
               BlockRead(F,M,ToCompute);
               M[ToCompute]:=$80;
               If ToCompute>=56 then
               begin
                  SHA;
                  FillChar(M,SizeOf(M),0);
           end;
               ToCompute:=0;
        end; //End else ToCompute>=64
            If ToCompute=0 then
            begin
               M[63]:=BitsLow and $000000FF;
               M[62]:=(BitsLow and $0000FF00) shr 8;
               M[61]:=(BitsLow and $00FF0000) shr 16;
               M[60]:=(BitsLow and $FF000000) shr 24;
               M[59]:=(BitsHigh and $000000FF);
               SHA;
        end;
     end; //End While ToCompute>0
      finally
         CloseFile(f);
  end;
      Result:=grVar;
   finally
   end;
end;

function TSecHash.IntDigestToByteDigest(IntDigest:TIntDigest):TByteDigest;
var i : integer;
begin
   For i:=0 to 19 do Result[i]:=(IntDigest[i div 4] shr ((3-(i-(i div 4)*4))*8))and $FF;
end;

end.




