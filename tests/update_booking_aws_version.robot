*** Settings ***
DDocumentation    Testes da API Restful-Booker
Library          RequestsLibrary
Library          Collections

Suite Setup      Create Session    booking_api    https://restful-booker.herokuapp.com
Suite Teardown   Delete All Sessions

*** Variables ***
${BOOKING_ENDPOINT}    /booking
${AUTH_ENDPOINT}       /auth

*** Test Cases ***
Criar E Validar Booking
    [Documentation]    Cria um booking e valida os campos principais
    
    ${body}=    Create Dictionary
    ...    firstname    James
    ...    lastname     Brown
    ...    totalprice   111
    ...    depositpaid  ${True}
    ...    additionalneeds    Breakfast
    
    ${dates}=    Create Dictionary
    ...    checkin    2018-01-01
    ...    checkout   2019-01-01
    
    Set To Dictionary    ${body}    bookingdates    ${dates}
    
    ${response}=    POST On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    json=${body}
    ...    expected_status=200
    
    Log To Console    Booking criado: ${response.json()}
    
    ${booking_id}=    Set Variable    ${response.json()['bookingid']}
    Set Suite Variable    ${BOOKING_ID}    ${booking_id}
    
    Dictionary Should Contain Key    ${response.json()}    bookingid
    Dictionary Should Contain Key    ${response.json()}    booking
    Should Be Equal    ${response.json()['booking']['firstname']}    James
    Should Be Equal    ${response.json()['booking']['lastname']}     Brown
    Should Be Equal As Numbers    ${response.json()['booking']['totalprice']}    111
    Should Be Equal    ${response.json()['booking']['additionalneeds']}    Breakfast

Buscar Booking Por ID
    [Documentation]    Busca um booking específico por ID e valida os dados
         ${response}=    GET On Session    booking_api    ${BOOKING_ENDPOINT}/${BOOKING_ID}
    ...    expected_status=200
    
    Log To Console    Booking encontrado: ${response.json()}
    
    Should Be Equal    ${response.json()['firstname']}    James
    Should Be Equal    ${response.json()['lastname']}     Brown
    Should Be Equal As Numbers    ${response.json()['totalprice']}    111
    Should Be Equal    ${response.json()['additionalneeds']}    Breakfast
    Should Be Equal    ${response.json()['bookingdates']['checkin']}    2018-01-01
    Should Be Equal    ${response.json()['bookingdates']['checkout']}    2019-01-01

Listar Todos Os Bookings
    [Documentation]    Lista todos os bookings e verifica se o booking criado está na lista
    
    ${response}=    GET On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    expected_status=200
    
    Log To Console    Total de bookings: ${len(${response.json()})}
    
    ${booking_ids}=    Create List
    FOR    ${booking}    IN    @{response.json()}
        Append To List    ${booking_ids}    ${booking['bookingid']}
    END
    
    List Should Contain Value    ${booking_ids}    ${BOOKING_ID}
    Should Not Be Empty    ${response.json()}


*** Keywords ***
Criar Token de Autenticação
    [Documentation]    Cria um token de autenticação para operações que requerem auth
    ${auth_body}=    Create Dictionary
    ...    username    admin
    ...    password    password123
    
    ${response}=    POST On Session    booking_api    ${AUTH_ENDPOINT}
    ...    json=${auth_body}
    ...    expected_status=200
    
