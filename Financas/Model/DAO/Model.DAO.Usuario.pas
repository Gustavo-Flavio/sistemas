unit Model.DAO.Usuario;

interface

uses
  System.SysUtils,
  Bcrypt,
  FireDAC.Comp.Client,
  Data.DB,
  FireDAC.Stan.Param,
  Vcl.Forms,
  Winapi.Windows,
  System.UITypes,
  Vcl.Dialogs;

type
  TModelDAOUsuario = class
    private
    FSenhaTemporaria   : String;
    FIdUsuarioLogado   : Integer;
    FStatus            : String;
    FSenha             : String;
    FLoginUsuarioLogado: String;
    FConexao           :TFDConnection;
    FDataCadastro: Tdatetime;
    FNomeUsuarioLogado: String;


    public
    property Conexao         : TFDConnection read FConexao write FConexao;
    property ID_USUARIO      : Integer read  FIdUsuarioLogado write FIdUsuarioLogado;
    property Nome            : String read  FNomeUsuarioLogado write FNomeUsuarioLogado;
    property Login           : String read  FLoginUsuarioLogado write FLoginUsuarioLogado;
    Property Senha           : String read  FSenha write FSenha;
    Property Status          : String read  FStatus write FStatus;
    Property DataCadastro    : Tdatetime read  FDataCadastro write FDataCadastro;
    Property SenhaTemporaria : String read FSenhaTemporaria write FSenhaTemporaria;

    Constructor Create (Conexao :TFDConnection) ;
    Destructor Destroy ;Override;

    Function Insert_Upadate(TipoOperacao:String; out Erro :String):Boolean;
    Procedure Delete (id:integer);
    Function Consulta (texto :String):TFDQuery;
    function TemLoginCadastrado(Login: string; ID_USUARIO: string): Boolean;
    procedure EfetuarLogin(login: String; Senha: string);


  end;
 implementation

uses Functions;
 var
 Qry :TFDQuery;

{ TModelDAOUsuario }

function TModelDAOUsuario.Consulta(texto: String): TFDQuery;
begin
  try
    Conexao.Connected :=False;
    Conexao.Connected :=True;
    qry.Close;
    qry.SQL.clear;
    qry.SQL.Add(' SELECT ID_USUARIO, upper(NOME) NOME, LOGIN, SENHA, STATUS, DATACADASTRO,SENHATEMPORARIA '+
                '       FROM USUARIO ' +
                ' WHERE NOME LIKE :NOME');
    qry.ParamByName('NOME').AsString :='%'+ texto +'%' ;
    qry.Open;
  finally
    Result := qry;
  end;

end;

constructor TModelDAOUsuario.Create(Conexao: TFDConnection);
begin

  FConexao := Conexao;
  Qry := TFDQuery.Create(nil);
  Qry.Connection := Fconexao;
end;

procedure TModelDAOUsuario.Delete(id: integer);
begin
 if Application.MessageBox('Deseja Exluir esse Usu�rio ?',
                            'Pergunta',
                             MB_YESNO + MB_ICONQUESTION) = mryes
                             then
    begin
      FConexao.Connected := False;
      FConexao.Connected := True;
      FConexao.ExecSQL('DELETE FROM USUARIO WHERE ID_USUARIO=:ID_USUARIO',[ID_USUARIO]) ;
      Consulta('');
//      Showmessage('Registro Excluido com sucesso!');
    end;

end;

destructor TModelDAOUsuario.Destroy;
begin
  Qry.Destroy;
  inherited;
end;

procedure TModelDAOUsuario.EfetuarLogin(login, Senha: string);
var
  Qry_Consulta: TFDQuery;
begin
  Qry_Consulta := TFDQuery.Create(nil);
  try
    Qry_Consulta.Connection := Fconexao;
    Qry_Consulta.sql.Clear;
    Qry_Consulta.sql.add('SELECT * FROM USUARIO WHERE LOGIN = :LOGIN ');
    Qry_Consulta.ParamByName('LOGIN').AsString := login;
    Qry_Consulta.Open;
    if Qry_Consulta.IsEmpty then
      raise Exception.Create('Usu�rio e/ou Senha inv�lidos!');
    if not tbcrypt.comparehash(Senha, Qry_Consulta.FieldByName('SENHA').AsString)
    then
      raise Exception.Create('Usu�rio e/ou Senha inv�lidos!');
    if Qry_Consulta.FieldByName('STATUS').AsString <> 'A' then
      raise Exception.Create
        ('Usu�rio Desativado, favor entrar em contato com o Admnistrador!');
    FIdUsuarioLogado    := Qry_Consulta.FieldByName('ID_USUARIO').AsInteger;
    FNomeUsuarioLogado  := Qry_Consulta.FieldByName('NOME').AsString;
    FLoginUsuarioLogado := Qry_Consulta.FieldByName('LOGIN').AsString;
    FSenha              := Qry_Consulta.FieldByName('SENHA').AsString;
    FSenhaTemporaria    := Qry_Consulta.FieldByName('SENHATEMPORARIA').AsString ;
  finally
    Qry_Consulta.Close;
    Qry_Consulta.Free;
  end;

end;

function TModelDAOUsuario.Insert_Upadate(TipoOperacao: String; out Erro: String): Boolean;
var
   QryInsert:TFDQuery;
begin
  try
    try
      FConexao.Connected := False;
      FConexao.Connected := True;
      QryInsert := TFDQuery.Create(nil);
      QryInsert.Connection := Fconexao;

      QryInsert.Close;
      QryInsert.SQL.clear;
      if TipoOperacao ='INSERT' then
        begin
          QryInsert.SQL.Add('INSERT INTO USUARIO(ID_USUARIO, NOME, LOGIN, SENHA, STATUS, DATACADASTRO, SENHATEMPORARIA) '
                           + 'VALUES(:ID_USUARIO, :NOME, :LOGIN, :SENHA, :STATUS, :DATACADASTRO, :SENHATEMPORARIA)');

          QryInsert.ParamByName('ID_USUARIO').AsInteger             := GetIdS('ID_USUARIO','USUARIO');
        end
        else //Updade
        begin
          QryInsert.SQL.Add(' UPDATE USUARIO SET NOME=:NOME, LOGIN=:LOGIN, SENHA=:SENHA, ' +
                            ' STATUS=:STATUS, DATACADASTRO=:DATACADASTRO, SENHATEMPORARIA=:SENHATEMPORARIA ' +
                            ' WHERE ID_USUARIO=:ID_USUARIO');
         QryInsert.ParamByName('ID_USUARIO').AsInteger             :=  FIdUsuarioLogado;
        end;


        QryInsert.ParamByName('NOME').AsString            := FNomeUsuarioLogado;
        QryInsert.ParamByName('LOGIN').AsString           := FLoginUsuarioLogado;
        QryInsert.ParamByName('SENHA').AsString           := FSenha;
        QryInsert.ParamByName('STATUS').AsString          := FStatus;
        QryInsert.ParamByName('DATACADASTRO').AsDatetime := FdataCadastro;
        QryInsert.ParamByName('SENHATEMPORARIA').AsString:= FSenhaTemporaria;
        QryInsert.ExecSQL;

        Result := True;
        Consulta('');

    except on E:Exception do
      begin
        Erro := E.Message;
        Result := False;
      end;

    end;

  finally
   QryInsert.Destroy;
  end;

end;

 function TModelDAOUsuario.TemLoginCadastrado(Login, ID_USUARIO: string): Boolean;
var
 Qry_Consulta :TFDQuery;
begin
  Result := False;
  Qry_Consulta := TFDQuery.create(nil);
  try
    Qry_Consulta.Connection := Fconexao;
    Qry_Consulta.sql.Clear;
    Qry_Consulta.sql.Add('SELECT ID_USUARIO FROM USUARIO WHERE LOGIN = :LOGIN');
    Qry_Consulta.ParamByName('LOGIN').AsString := FLoginUsuarioLogado;
    Qry_Consulta.Open;
    if not Qry_Consulta.IsEmpty then
      Result := Qry_Consulta.FieldByName('ID_USUARIO').AsString <> ID_USUARIO;
  finally
    Qry_Consulta.Close;
    Qry_Consulta.Free;
  end;
end;

end.
