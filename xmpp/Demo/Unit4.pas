unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XMLDoc, xmldom, XMLIntf, msxmldom, StdCtrls, ComCtrls;

type
  TForm4 = class(TForm)
    redt1: TRichEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure addlog(txt:string);
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

{ TForm4 }

procedure TForm4.addlog(txt: string);
begin
  with redt1 do
  begin
    //SelStart:=Length(Text);
    {SelLength:=0;
    SelAttributes.Color:=clRed;
    Lines.Append('RECV:');
    SelAttributes.Color:=clBlack;
    Lines.Append(txt);
         }
  end;
end;

end.
