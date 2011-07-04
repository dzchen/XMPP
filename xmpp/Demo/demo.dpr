program demo;

uses
  Forms,
  main in 'main.pas' {Form1},
  testnode in 'testnode.pas',
  xmppconntest in 'xmppconntest.pas' {Form2},
  testinit in 'testinit.pas',
  Unit3 in 'Unit3.pas' {Form3},
  Unit4 in 'Unit4.pas' {Form4};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  //Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.

