*** Settings ***
Documentation    API Booking Tests
Library          RequestsLibrary
Library          Collections

Suite Setup      Create Session    api    https://restful-booker.herokuapp.com
Suite Teardown   Delete All Sessions

*** Variables ***
${ENDPOINT}    /booking

*** Test Cases ***
Create Booking
    [Tags]    create    positive
    ${data}=    Create Booking Data    João    Silva    150
    ${response}=    POST On Session    api    ${ENDPOINT}    json=${data}
    Should Be Equal As Numbers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    bookingid
    Set Suite Variable    ${BOOKING_ID}    ${response.json()['bookingid']}

Get Booking
    [Tags]    get    positive
    ${response}=    GET On Session    api    ${ENDPOINT}/${BOOKING_ID}
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be Equal    ${response.json()['firstname']}    João

List Bookings
    [Tags]    list    positive
    ${response}=    GET On Session    api    ${ENDPOINT}
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be True    len(${response.json()}) > 0

Create Invalid Booking
    [Tags]    create    negative
    ${data}=    Create Dictionary    firstname=Test
    ${response}=    POST On Session    api    ${ENDPOINT}    json=${data}    expected_status=any
    Should Be True    ${response.status_code} >= 400

Get Invalid Booking
    [Tags]    get    negative
    ${response}=    GET On Session    api    ${ENDPOINT}/999999    expected_status=any
    Should Be True    ${response.status_code} >= 400

*** Keywords ***
Create Booking Data
    [Arguments]    ${firstname}    ${lastname}    ${price}
    ${dates}=    Create Dictionary    checkin=2024-01-15    checkout=2024-01-20
    ${data}=    Create Dictionary
    ...    firstname=${firstname}
    ...    lastname=${lastname}
    ...    totalprice=${price}
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    [Return]    ${data}