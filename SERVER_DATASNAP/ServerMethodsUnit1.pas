unit ServerMethodsUnit1;

interface

uses System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  Datasnap.DSAuth,
  System.JSON;

type
{$METHODINFO ON}
  TServerMethods1 = class(TComponent)
  private
    { Private declarations }
    function QuantidadeProduto(const Produto: string): Integer;
  public
    { Public declarations }
    function EchoString(Value: string): string;
    function ReverseString(Value: string): string;
    function UpdateProcessarChatBot(AData: TJSONObject): string;
  end;
{$METHODINFO OFF}

implementation

uses System.StrUtils,
  FormUnit1,
  Data.DBXPlatform;

function TServerMethods1.UpdateProcessarChatBot(AData: TJSONObject): string;
var
  oRetorno: TDSInvocationMetadata;
  oResult: TJSONObject;
  oContent: TJSONObject;
  sIntentName: string;
  sProduto: string;
  sBuffer: string;

begin

  // Escrevendo no Memo o conteúdo recebido
  Form2.Memo1.Text := AData.ToString;
  sBuffer := 'Ação não identificada!';

  // Recuperando cada parte relevante do JSON do DialogFlow
  oResult := TJSONObject(AData.GetValue('result'));
  sIntentName := TJSONObject(oResult.GetValue('metadata')).GetValue('intentName').Value;
  sProduto := TJSONObject(oResult.GetValue('parameters')).GetValue('produto').Value;

  // Roteando para a rotina associada ao Intent acionado
  if sIntentName = 'Quanto temos de papel?' then
  begin
    // Preparando a resposta
    sBuffer := Format('Temos %d t de %s', [Self.QuantidadeProduto(sProduto), sProduto]);
  end;

  // Preparando o JSON de retorno
  oContent := TJSONObject.Create;
  oContent.AddPair('speech', sBuffer);
  oContent.AddPair('displayText', sBuffer);

  // Escrevendo a resposta HTTP para contornar o JSON padrão do Data Snap
  oRetorno := GetInvocationMetadata;
  oRetorno.ResponseCode := 200;
  oRetorno.ResponseContent := oContent.ToJSON;

  // Liberando a resposta
  oContent.Free;
end;

function TServerMethods1.EchoString(Value: string): string;
begin
  Result := Value;
end;

function TServerMethods1.QuantidadeProduto(const Produto: string): Integer;
begin
  if Produto = 'papel' then
    Result := 1
  else
    Result := 2
end;

function TServerMethods1.ReverseString(Value: string): string;
begin
  Result := System.StrUtils.ReverseString(Value);
end;

end.
