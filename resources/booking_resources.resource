*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Keywords ***
Setup API Test
    Create Session    restful_booker    ${BASE_URL}    verify=true

Teardown API Test
    Delete All Sessions

Get All Bookings
    ${response}=    GET On Session    restful_booker    ${BOOKING_ENDPOINT}
    [Return]    ${response}

Get Bookings With Filter
    [Arguments]    ${firstname}=${EMPTY}    ${lastname}=${EMPTY}    ${checkin}=${EMPTY}    ${checkout}=${EMPTY}
    
    ${params}=    Create Dictionary
    Run Keyword If    '${firstname}' != '${EMPTY}'    Set To Dictionary    ${params}    firstname=${firstname}
    Run Keyword If    '${lastname}' != '${EMPTY}'    Set To Dictionary    ${params}    lastname=${lastname}
    Run Keyword If    '${checkin}' != '${EMPTY}'    Set To Dictionary    ${params}    checkin=${checkin}
    Run Keyword If    '${checkout}' != '${EMPTY}'    Set To Dictionary    ${params}    checkout=${checkout}
    
    ${response}=    GET On Session    restful_booker    ${BOOKING_ENDPOINT}    params=${params}
    [Return]    ${response}

Validate Response Status
    [Arguments]    ${response}    ${expected_status}=${EXPECTED_STATUS}
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}

Validate Booking Response Structure
    [Arguments]    ${response}
    
    # Verifica se é uma lista
    Should Not Be Empty    ${response.json()}
    
    # Valida cada booking no array
    FOR    ${booking}    IN    @{response.json()}
        Dictionary Should Contain Key    ${booking}    bookingid
        Should Be True    ${booking['bookingid']} > 0
    END

Validate Empty Response
    [Arguments]    ${response}
    Should Be Empty    ${response.json()}

Log Booking Count
    [Arguments]    ${response}    ${filter_type}=${EMPTY}
    ${count}=    Get Length    ${response.json()}
    Run Keyword If    '${filter_type}' != '${EMPTY}'    
    ...    Log    Foram encontradas ${count} reservas com filtro: ${filter_type}
    ...    ELSE
    ...    Log    Foram encontradas ${count} reservas no total