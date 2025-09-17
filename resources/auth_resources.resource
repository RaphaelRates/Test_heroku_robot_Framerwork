*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Keywords ***
Criar Sessao API
    [Arguments]    ${alias}=api_session    ${url}=${BASE_URL}
    Create Session    ${alias}    ${url}    verify=true

Fazer Login
    [Arguments]    ${username}    ${password}    ${expected_status}=200
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${data}=    Create Dictionary    username=${username}    password=${password}
    
    ${response}=    POST On Session    api_session    ${AUTH_ENDPOINT}    
    ...    json=${data}    headers=${headers}    expected_status=${expected_status}
    
    [Return]    ${response}

Validar Resposta de Sucesso
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    token
    Should Not Be Empty    ${response.json()["token"]}
    Log    Token obtido: ${response.json()["token"]}

Validar Resposta de Erro
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    200
    # A API Restful-Booker retorna 200 mesmo com credenciais inválidas,
    # mas com uma mensagem de erro no corpo da resposta
    ${body}=    Set Variable    ${response.json()}
    Run Keyword If    "reason" in ${body}    Log    Motivo do erro: ${body["reason"]}