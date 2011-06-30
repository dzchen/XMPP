{ program xmltest - a simple NativeXml tester
}
program xmltest;

uses
  Forms,
  xmltestmain in 'xmltestmain.pas' {frmMain},
  sdStreams in '..\..\..\general\sdStreams.pas',
  sdDebug in '..\..\..\general\sdDebug.pas',
  sdStringTable in '..\..\..\general\sdStringTable.pas',
  NativeXml in '..\..\NativeXml.pas',
  NativeXmlOld in '..\..\NativeXmlOld.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
