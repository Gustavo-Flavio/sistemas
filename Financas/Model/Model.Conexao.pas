unit Model.Conexao;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Controller.Connetions;

type
  TConexao = class(TDataModule)
    FDQuery: TFDQuery;
    FDConn: TFDConnection;

  private
    { Private declarations }
  public
    { Public declarations }
    function DataSet: TDataSet;
    Procedure SQL(Value: String);
    Procedure Params(aParam: string; aValue: Variant); overload;
    function Params(aParam: String): Variant; overload;
    // function CarregarCDS(Cds:TclientDataSet;query:TFDQuery):string; overload;

    procedure ExecSQL;
    procedure Open;
    Procedure StartTransaction;
    procedure Commit;
    Procedure RoollBack;
  end;

var
  Conexao: TConexao;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}


{$R *.dfm}
{ TConexao }

procedure TConexao.Commit;
begin
  FDConn.Commit;
end;

function TConexao.DataSet: TDataSet;
begin
  Result := FDQuery;
end;

procedure TConexao.ExecSQL;
begin
  FDQuery.ExecSQL;
end;

procedure TConexao.Open;
begin
  FDQuery.Open;
end;

function TConexao.Params(aParam: String): Variant;
begin
  Result := FDQuery.ParamByName(aParam).Value;
end;

procedure TConexao.Params(aParam: string; aValue: Variant);
begin
  FDQuery.ParamByName(aParam).Value := aValue;
end;

procedure TConexao.RoollBack;
begin
  FDConn.Rollback;
end;

procedure TConexao.SQL(Value: String);
begin
  FDQuery.SQL.Clear;
  FDQuery.SQL.add(Value);
end;

procedure TConexao.StartTransaction;
begin
  FDConn.StartTransaction;
end;

end.
