unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,jid;

type
  TForm1 = class(TForm)
    btn1: TButton;
    edt1: TEdit;
    edt2: TEdit;
    btn2: TButton;
    btn3: TButton;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  DirectionalElement;

{$R *.dfm}

procedure TForm1.btn1Click(Sender: TObject);
begin
  edt2.Text:=TJID.applyJEP106(edt1.Text);
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  edt1.Text:=TJID.removeJEP106(edt2.Text);
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  dir:TDirectionalElement;
begin
  ShowMessage(dir.Create('dddd','sss:sssss').WriteToString);
end;

end.
