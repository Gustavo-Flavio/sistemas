program Financas;

uses
  Vcl.Forms,
  View.Principal in 'View\View.Principal.pas' {Form1},
  Model.Conexao in 'Model\Model.Conexao.pas' {Conexao: TDataModule},
  Controller.Connetions in 'Controller\Controller.Connetions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TConexao, Conexao);
  Application.Run;
end.
