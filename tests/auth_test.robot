*** Settings ***
Resource    ../variables/auth_variables.resource
Resource    ../resources/auth_resources.resource

Suite Setup    Criar Sessao API
Suite Teardown    Delete All Sessions

*** Test Cases ***
TC01 - Login Com Credenciais Validas
    [Documentation]    Testa login com credenciais válidas
    [Tags]    AUTH    SMOKE
    
    ${response}=    Fazer Login    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Validar Resposta de Sucesso    ${response}

TC02 - Login Com Usuario Invalido
    [Documentation]    Testa login com usuário inválido
    [Tags]    AUTH    NEGATIVE
    
    ${response}=    Fazer Login    ${INVALID_USERNAME}    ${VALID_PASSWORD}
    Validar Resposta de Erro    ${response}

TC03 - Login Com Senha Invalida
    [Documentation]    Testa login com senha inválida
    [Tags]    AUTH    NEGATIVE
    
    ${response}=    Fazer Login    ${VALID_USERNAME}    ${INVALID_PASSWORD}
    Validar Resposta de Erro    ${response}

TC04 - Login Com Ambos Campos Invalidos
    [Documentation]    Testa login com ambos campos inválidos
    [Tags]    AUTH    NEGATIVE
    
    ${response}=    Fazer Login    ${INVALID_USERNAME}    ${INVALID_PASSWORD}
    Validar Resposta de Erro    ${response}

TC05 - Login Sem Usuario
    [Documentation]    Testa login sem informar usuário
    [Tags]    AUTH    NEGATIVE
    
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${data}=    Create Dictionary    password=${VALID_PASSWORD}
    
    ${response}=    POST On Session    api_session    ${AUTH_ENDPOINT}    
    ...    json=${data}    headers=${headers}    expected_status=200
    
    Validar Resposta de Erro    ${response}

TC06 - Login Sem Senha
    [Documentation]    Testa login sem informar senha
    [Tags]    AUTH    NEGATIVE
    
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${data}=    Create Dictionary    username=${VALID_USERNAME}
    
    ${response}=    POST On Session    api_session    ${AUTH_ENDPOINT}    
    ...    json=${data}    headers=${headers}    expected_status=200
    
    Validar Resposta de Erro    ${response}

TC07 - Login Com Body Vazio
    [Documentation]    Testa login com body vazio
    [Tags]    AUTH    NEGATIVE
    
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${data}=    Create Dictionary
    
    ${response}=    POST On Session    api_session    ${AUTH_ENDPOINT}    
    ...    json=${data}    headers=${headers}    expected_status=200
    
    Validar Resposta de Erro    ${response}

TC08 - Validar Estrutura do Token
    [Documentation]    Valida a estrutura do token retornado
    [Tags]    AUTH    STRUCTURE
    
    ${response}=    Fazer Login    ${VALID_USERNAME}    ${VALID_PASSWORD}
    
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Set Variable    ${response.json()["token"]}
    
    # Verifica se o token tem pelo menos 10 caracteres (valor arbitrário)
    Length Should Be Greater Than    ${token}    10
    Should Match Regexp    ${token}    ^[a-zA-Z0-9]+$    # Token deve ser alfanumérico