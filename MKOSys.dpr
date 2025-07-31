program MKOSys;

uses
  Vcl.Forms,
  uMain in '_Source\uMain.pas' {fMain},
  TaskInterface in '_Source\TaskInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
