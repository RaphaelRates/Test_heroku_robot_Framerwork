*** Settings ***
Resource    ../variables/booking_variables.resource
Resource    ../resources/booking_resources.resource

Suite Setup    Setup API Test
Suite Teardown    Teardown API Test

*** Test Cases ***
TC01 - GET All Booking IDs Should Return Success 200
    [Documentation]    Testa a requisição GET /booking sem filtros
    [Tags]    GET    ALL_BOOKINGS    SMOKE
    
    ${response}=    Get All Bookings
    Validate Response Status    ${response}
    Validate Booking Response Structure    ${response}
    Log Booking Count    ${response}

TC02 - GET Booking IDs Filtered By Firstname
    [Documentation]    Testa GET /booking?firstname=John
    [Tags]    GET    FILTER    FIRSTNAME
    
    ${response}=    Get Bookings With Filter    firstname=${FIRSTNAME}
    Validate Response Status    ${response}
    Validate Booking Response Structure    ${response}
    Log Booking Count    ${response}    firstname=${FIRSTNAME}

TC03 - GET Booking IDs Filtered By Lastname
    [Documentation]    Testa GET /booking?lastname=Smith
    [Tags]    GET    FILTER    LASTNAME
    
    ${response}=    Get Bookings With Filter    lastname=${LASTNAME}
    Validate Response Status    ${response}
    Validate Booking Response Structure    ${response}
    Log Booking Count    ${response}    lastname=${LASTNAME}

TC04 - GET Booking IDs Filtered By Checkin Date
    [Documentation]    Testa GET /booking?checkin=2024-01-01
    [Tags]    GET    FILTER    CHECKIN
    
    ${response}=    Get Bookings With Filter    checkin=${CHECKIN_DATE}
    Validate Response Status    ${response}
    Validate Booking Response Structure    ${response}
    Log Booking Count    ${response}    checkin=${CHECKIN_DATE}

TC05 - GET Booking IDs Filtered By Checkout Date
    [Documentation]    Testa GET /booking?checkout=2024-01-10
    [Tags]    GET    FILTER    CHECKOUT
    
    ${response}=    Get Bookings With Filter    checkout=${CHECKOUT_DATE}
    Validate Response Status    ${response}
    Validate Booking Response Structure    ${response}
    Log Booking Count    ${response}    checkout=${CHECKOUT_DATE}

TC06 - GET Booking IDs With Multiple Filters
    [Documentation]    Testa GET /booking?firstname=John&lastname=Smith
    [Tags]    GET    FILTER    COMBINED
    
    ${response}=    Get Bookings With Filter    firstname=${FIRSTNAME}    lastname=${LASTNAME}
    Validate Response Status    ${response}
    Validate Booking Response Structure    ${response}
    Log Booking Count    ${response}    firstname=${FIRSTNAME} + lastname=${LASTNAME}

TC07 - GET Booking IDs With All Filters
    [Documentation]    Testa GET /booking com todos os filtros
    [Tags]    GET    FILTER    COMPREHENSIVE
    
    ${response}=    Get Bookings With Filter    
    ...    firstname=${FIRSTNAME}
    ...    lastname=${LASTNAME}
    ...    checkin=${CHECKIN_DATE}
    ...    checkout=${CHECKOUT_DATE}
    
    Validate Response Status    ${response}
    Validate Booking Response Structure    ${response}
    Log Booking Count    ${response}    todos os filtros