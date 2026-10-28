program C4DMaskEditDemo01;

uses
  Vcl.Forms,
  C4DMaskEdit.Demo01.View.Main in 'Src\View\C4DMaskEdit.Demo01.View.Main.pas' {C4DMaskEditDemo01ViewMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TC4DMaskEditDemo01ViewMain, C4DMaskEditDemo01ViewMain);
  Application.Run;
end.
