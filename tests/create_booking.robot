*** Settings ***
Documentation    Testes automatizados para API de Booking
Library          RequestsLibrary
Library          Collections
Library          BuiltIn

Suite Setup      Create Session    booking_api    https://restful-booker.herokuapp.com
Suite Teardown   Delete All Sessions

*** Variables ***
${BASE_URL}             https://restful-booker.herokuapp.com
${BOOKING_ENDPOINT}     /booking
${VALID_BOOKING_DATA}   {"firstname":"João","lastname":"Silva","totalprice":150,"depositpaid":true,"bookingdates":{"checkin":"2024-01-15","checkout":"2024-01-20"},"additionalneeds":"Café da manhã"}

*** Test Cases ***
Criar Novo Booking Com Sucesso
    [Documentation]    Testa a criação de um novo booking com dados válidos
    [Tags]    booking    create    positive

    ${booking_data}=    Create Dictionary
    ...    firstname=João
    ...    lastname=Silva  
    ...    totalprice=${150}
    ...    depositpaid=${True}
    ...    additionalneeds=Café da manhã
    
    ${booking_dates}=    Create Dictionary    checkin=2024-01-15    checkout=2024-01-20
    Set To Dictionary    ${booking_data}    bookingdates    ${booking_dates}

    ${response}=    POST On Session    booking_api    ${BOOKING_ENDPOINT}    
    ...    json=${booking_data}    
    ...    headers=&{EMPTY}
    ...    expected_status=200
    
    Should Be Equal As Numbers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    bookingid
    Dictionary Should Contain Key    ${response.json()}    booking
    
    ${returned_booking}=    Get From Dictionary    ${response.json()}    booking
    Should Be Equal    ${returned_booking['firstname']}    João
    Should Be Equal    ${returned_booking['lastname']}    Silva
    Should Be Equal As Numbers    ${returned_booking['totalprice']}    150
    

    ${booking_id}=    Get From Dictionary    ${response.json()}    bookingid
    Set Suite Variable    ${BOOKING_ID}    ${booking_id}
    
    Log    Booking criado com ID: ${booking_id}

Buscar Booking Por ID
    [Documentation]    Testa a busca de um booking específico pelo ID
    [Tags]    booking    get    positive
    
    Should Not Be Empty    ${BOOKING_ID}    Booking ID não está disponível
    
    ${response}=    GET On Session    booking_api    ${BOOKING_ENDPOINT}/${BOOKING_ID}
    ...    expected_status=200

    Should Be Equal As Numbers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    firstname
    Dictionary Should Contain Key    ${response.json()}    lastname
    Dictionary Should Contain Key    ${response.json()}    totalprice
    
    Should Be Equal    ${response.json()['firstname']}    João
    Should Be Equal    ${response.json()['lastname']}    Silva

Listar Todos Os Bookings
    [Documentation]    Testa a listagem de todos os bookings
    [Tags]    booking    list    positive
    
    ${response}=    GET On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    expected_status=200

    Should Be Equal As Numbers    ${response.status_code}    200
    ${bookings_list}=    Set Variable    ${response.json()}

    Should Be True    isinstance($bookings_list, list)
    ${list_length}=    Get Length    ${bookings_list}
    Should Be True    ${list_length} > 0
    
    Dictionary Should Contain Key    ${bookings_list}[0]    bookingid
    
    Log    Total de bookings encontrados: ${list_length}

Falhar Ao Criar Booking Sem Campos Obrigatórios
    [Documentation]    Testa validação de campos obrigatórios
    [Tags]    booking    create    negative
    
    ${invalid_data}=    Create Dictionary    firstname=Maria

    ${response}=    POST On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    json=${invalid_data}
    ...    expected_status=any
    
    Should Be True    ${response.status_code} >= 400
    
    Log    Status retornado para dados inválidos: ${response.status_code}

Buscar Booking Inexistente
    [Documentation]    Testa busca por booking que não existe
    [Tags]    booking    get    negative
    
    ${invalid_id}=    Set Variable    999999
    
    ${response}=    GET On Session    booking_api    ${BOOKING_ENDPOINT}/${invalid_id}
    ...    expected_status=any
    
    Should Be True    ${response.status_code} == 404 or ${response.status_code} >= 400
    
    Log    Status retornado para ID inexistente: ${response.status_code}

Filtrar Bookings Por Data
    [Documentation]    Testa filtros de busca por data
    [Tags]    booking    filter    positive
    
    ${params}=    Create Dictionary    checkin=2024-01-01    checkout=2024-12-31
    
    ${response}=    GET On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    params=${params}
    ...    expected_status=200
    
    Should Be Equal As Numbers    ${response.status_code}    200
    ${filtered_bookings}=    Set Variable    ${response.json()}
    Should Be True    isinstance($filtered_bookings, list)
    
    Log    Bookings filtrados por data: ${filtered_bookings}

Validar Headers da Resposta
    [Documentation]    Testa se os headers da resposta estão corretos
    [Tags]    booking    headers    positive
    
    ${response}=    GET On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    expected_status=200
    
    Dictionary Should Contain Key    ${response.headers}    Content-Type
    Should Contain    ${response.headers}[Content-Type]    application/json
    
    Log    Content-Type: ${response.headers}[Content-Type]

*** Keywords ***
Criar Booking De Teste
    [Documentation]    Keyword para criar um booking padrão para testes
    [Arguments]    ${nome}=TestUser    ${sobrenome}=Robot    ${preco}=100
    
    ${booking_data}=    Create Dictionary
    ...    firstname=${nome}
    ...    lastname=${sobrenome}
    ...    totalprice=${preco}
    ...    depositpaid=${True}
    ...    additionalneeds=Teste automatizado
    
    ${booking_dates}=    Create Dictionary    checkin=2024-01-01    checkout=2024-01-05
    Set To Dictionary    ${booking_data}    bookingdates    ${booking_dates}
    
    ${response}=    POST On Session    booking_api    ${BOOKING_ENDPOINT}
    ...    json=${booking_data}
    ...    expected_status=200
    
    ${booking_id}=    Get From Dictionary    ${response.json()}    bookingid
    [Return]    ${booking_id}

Validar Estrutura Do Booking
    [Documentation]    Keyword para validar a estrutura padrão de um booking
    [Arguments]    ${booking_data}
    
    Dictionary Should Contain Key    ${booking_data}    firstname
    Dictionary Should Contain Key    ${booking_data}    lastname
    Dictionary Should Contain Key    ${booking_data}    totalprice
    Dictionary Should Contain Key    ${booking_data}    depositpaid
    Dictionary Should Contain Key    ${booking_data}    bookingdates
    
    ${dates}=    Get From Dictionary    ${booking_data}    bookingdates
    Dictionary Should Contain Key    ${dates}    checkin
    Dictionary Should Contain Key    ${dates}    checkout