*** Settings ***
Documentation    Testes da API Restful-Booker - DELETE Booking
Library          RequestsLibrary
Library          Collections

Suite Setup      Create Session    booking_api    https://restful-booker.herokuapp.com
Suite Teardown   Delete All Sessions

*** Variables ***
${BOOKING_ENDPOINT}    /booking
${AUTH_ENDPOINT}       /auth

*** Test Cases ***
Criar Booking Para Teste De Delete
    [Documentation]    Cria um booking que será usado nos testes de DELETE
    
    ${body}=    Create Dictionary
    ...    firstname    John
    ...    lastname     Doe
    ...    totalprice   200
    ...    depositpaid  ${True}
    ...    additionalneeds    Late Checkout
    
    ${dates}=    Create Dictionary
    ...    checkin    2024-01-01
    ...    checkout   2024-01-05
    
    Set To Dictionary    ${body}    bookingdates    ${dates}
    
    ${response}=    POST On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    json=${body}
    ...    expected_status=200
    
    ${booking_id}=    Set Variable    ${response.json()['bookingid']}
    Set Suite Variable    ${BOOKING_ID}    ${booking_id}
    
    Log To Console    Booking criado para teste: ID ${BOOKING_ID}

Deletar Booking Com Token Cookie
    [Documentation]    Deleta um booking usando token no header Cookie
    
    ${token}=    Criar Token de Autenticação
    
    ${headers}=    Create Dictionary
    ...    Content-Type    application/json
    ...    Cookie    token=${token}
    
    ${response}=    DELETE On Session    booking_api    ${BOOKING_ENDPOINT}/${BOOKING_ID}
    ...    headers=${headers}
    ...    expected_status=201
    
    Log To Console    Booking deletado com Cookie auth: ${response.status_code}
    Should Be Equal As Strings    ${response.text}    Created

Deletar Booking Com Basic Auth
    [Documentation]    Deleta um booking usando Basic Authentication
    
    # Primeiro cria outro booking para deletar
    ${body}=    Create Dictionary
    ...    firstname    Jane
    ...    lastname     Smith
    ...    totalprice   150
    ...    depositpaid  ${False}
    ...    additionalneeds    Breakfast
    
    ${dates}=    Create Dictionary
    ...    checkin    2024-02-01
    ...    checkout   2024-02-03
    
    Set To Dictionary    ${body}    bookingdates    ${dates}
    
    ${response}=    POST On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    json=${body}
    ...    expected_status=200
    
    ${new_booking_id}=    Set Variable    ${response.json()['bookingid']}
    
    # Agora deleta com Basic Auth
    ${auth}=    Create List    admin    password123
    ${response}=    DELETE On Session    booking_api    ${BOOKING_ENDPOINT}/${new_booking_id}
    ...    auth=${auth}
    ...    expected_status=201
    
    Log To Console    Booking deletado com Basic Auth: ${response.status_code}
    Should Be Equal As Strings    ${response.text}    Created

Verificar Booking Deletado
    [Documentation]    Verifica se o booking foi realmente deletado
    
    ${response}=    GET On Session    booking_api    ${BOOKING_ENDPOINT}/${BOOKING_ID}
    ...    expected_status=404
    
    Log To Console    Booking não encontrado (como esperado): ${response.status_code}
    Should Be Equal As Numbers    ${response.status_code}    404

Tentar Deletar Booking Sem Autenticação
    [Documentation]    Tenta deletar um booking sem fornecer autenticação
    
    # Cria um booking temporário para tentar deletar sem auth
    ${body}=    Create Dictionary
    ...    firstname    Temp
    ...    lastname     User
    ...    totalprice   100
    ...    depositpaid  ${True}
    ...    additionalneeds    None
    
    ${dates}=    Create Dictionary
    ...    checkin    2024-03-01
    ...    checkout   2024-03-02
    
    Set To Dictionary    ${body}    bookingdates    ${dates}
    
    ${response}=    POST On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    json=${body}
    ...    expected_status=200
    
    ${temp_booking_id}=    Set Variable    ${response.json()['bookingid']}
    
    # Tenta deletar sem autenticação
    ${response}=    DELETE On Session    booking_api    ${BOOKING_ENDPOINT}/${temp_booking_id}
    ...    expected_status=403
    
    Log To Console    Tentativa sem auth retornou: ${response.status_code}
    Should Be Equal As Numbers    ${response.status_code}    403

*** Keywords ***
Criar Token de Autenticação
    [Documentation]    Cria um token de autenticação
    ${auth_body}=    Create Dictionary
    ...    username    admin
    ...    password    password123
    
    ${response}=    POST On Session    booking_api    ${AUTH_ENDPOINT}
    ...    json=${auth_body}
    ...    expected_status=200
    
    [Return]    ${response.json()['token']}