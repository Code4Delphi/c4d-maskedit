unit C4DMaskEdit.Demo01.View.Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Mask,
  C4D.MaskEdit;

type
  TC4DMaskEditDemo01ViewMain = class(TForm)
    RadioButton1: TRadioButton;
    Edit1: TEdit;
    Button1: TButton;
    C4DMaskEdit1: TC4DMaskEdit;
    C4DMaskEdit2: TC4DMaskEdit;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
  public
  end;

var
  C4DMaskEditDemo01ViewMain: TC4DMaskEditDemo01ViewMain;

implementation

{$R *.dfm}

procedure TC4DMaskEditDemo01ViewMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutDown := True;
end;

procedure TC4DMaskEditDemo01ViewMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Perform(Wm_NextDlgCtl, 0, 0);
  end;
end;

procedure TC4DMaskEditDemo01ViewMain.Button1Click(Sender: TObject);
begin
  ShowMessage('Value.ToString: ' + C4DMaskEdit1.Value.ToString + sLineBreak + 'Text: ' + C4DMaskEdit1.Text + sLineBreak + '');
end;

end.


