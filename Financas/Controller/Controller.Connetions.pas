unit Controller.Connetions;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,
  System.SysUtils,
  System.IniFiles,
  Vcl.Forms;

type
  TModelConexao = Class
  Private
    FConexao: TFDConnection;
    FServidor: String;
    FBase: String;
    FLogin: String;
    FSenha: string;
    FPorta: String;
    FMgsErro: String;
  Public
    Constructor Create(NomeConexao: TFDConnection);
    Destructor  Destroy; override;
    Function  Conectar_BancoDados: Boolean;
    Function  LerConfiguracao :Boolean;
    Procedure GravarArquivoINI;


    property Conexao: TFDConnection read FConexao write FConexao;
    property Servidor:  String read FServidor  write FServidor;
    property Base:      String read FBase      write FBase;
    property Login:     String read FLogin     write FLogin;
    property Senha:     string read FSenha     write FSenha;
    property Porta:     String read FPorta     write FPorta;
    property MgsErro:   String read FMgsErro   write FMgsErro;

  End;

implementation
{uses
Functions;}

{ TModelConexao }

function TModelConexao.Conectar_BancoDados: Boolean;
begin
  Result := true;
  FConexao.Params.Clear;
  FServidor :='127.0.0.';

  if not LerConfiguracao then
   begin
     Result := False;
     FMgsErro := ' O arquivo de configura��o n�o foi encontrado. ';
   end
   else
   begin
      FConexao.Params.Add('SERVER=' + FServidor);
      FConexao.Params.Add('USER_NAME=' + FLogin);
      FConexao.Params.Add('PASSWORD=' + FSenha);
      FConexao.Params.Add('PORT =' + FPorta);
      FConexao.Params.Add('DATABASE=' + FBase);
      FConexao.Params.Add('DRIVERID=' + 'FB');

      try
        FConexao.Connected := True;
      Except
        on e: Exception do
        begin
          FMgsErro := e.Message;
          Result   := False;
        end;

      end;
   end;

end;

constructor TModelConexao.Create(NomeConexao: TFDConnection);
begin
  FConexao := NomeConexao;
end;

destructor TModelConexao.Destroy;
begin
  FConexao.Connected := False;
  inherited;
end;

procedure TModelConexao.GravarArquivoINI;
var
  IniFile : String;
  ini     : TiniFile;
begin
  IniFile := ChangeFileExt(Application.Exename,'.ini');
  ini     := TIniFile.Create(inifile);
  try
    ini.WriteString('CONFIGURACAO','SERVIDOR',FServidor);
    ini.WriteString('CONFIGURACAO','DATABASE',FBase ) ;
    ini.WriteString('CONFIGURACAO','PORTA',FPorta);
//    ini.WriteString('CONFIGURACAO','DRIVERID','FB');
    ini.WriteString('ACESSO','LOGIN',FLogin);
    ini.WriteString('ACESSO','SENHA',FSenha );
//    /Criptografia(FSenha,'545aewrqwe5451dqwer')
  finally
   ini.free;
  end;

end;



function TModelConexao.LerConfiguracao: Boolean;
var
  IniFile : String;
  ini     : TiniFile;
begin
  IniFile := ChangeFileExt(Application.Exename,'.ini');
  ini     := TIniFile.Create(IniFile);

  if not FileExists(inifile) then
    result := False
    else
    begin

      try
        FServidor := ini.ReadString('CONFIGURACAO','SERVIDOR','');
        FBase     := ini.ReadString('CONFIGURACAO','DATABASE','') ;
        FPorta    := ini.ReadString('CONFIGURACAO','PORTA','');
        FLogin    := ini.ReadString('ACESSO','LOGIN','');
        FSenha    := ini.ReadString('ACESSO','SENHA','');
       {ini.WriteString('ACESSO','SENHA',Criptografia(FSenha,'123') );
        FSenha := ini.ReadString('CONFIGURACAO','senha','') ;
        FSenha :=Criptografia(FSenha,'123') ; }

      finally
       Result := true;
       ini.free;
      end;

    end;

end;


end.
