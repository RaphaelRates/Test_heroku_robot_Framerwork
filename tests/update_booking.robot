*** Settings ***
Documentation    Update Booking Tests
Library          RequestsLibrary
Library          Collections

Suite Setup      Create Session    api    https://restful-booker.herokuapp.com
Suite Teardown   Delete All Sessions

*** Variables ***
${ENDPOINT}    /booking
${AUTH_ENDPOINT}    /auth

*** Test Cases ***
Update Booking
    [Tags]    update    positive
    ${booking_id}=    Create Test Booking
    ${token}=    Get Auth Token
    ${headers}=    Create Dictionary    Cookie=token=${token}
    
    ${update_data}=    Create Update Data    Updated    Name    200
    ${response}=    PUT On Session    api    ${ENDPOINT}/${booking_id}    json=${update_data}    headers=${headers}
    Should Be Equal As Numbers    ${response.status_code}    200
    
    Should Be Equal    ${response.json()['firstname']}    Updated
    Should Be Equal    ${response.json()['lastname']}    Name
    Should Be Equal As Numbers    ${response.json()['totalprice']}    200

Partial Update Booking
    [Tags]    update    positive
    ${booking_id}=    Create Test Booking
    ${token}=    Get Auth Token
    ${headers}=    Create Dictionary    Cookie=token=${token}
    
    ${patch_data}=    Create Dictionary    firstname=Patched    totalprice=150
    ${response}=    PATCH On Session    api    ${ENDPOINT}/${booking_id}    json=${patch_data}    headers=${headers}
    Should Be Equal As Numbers    ${response.status_code}    200
    
    Should Be Equal    ${response.json()['firstname']}    Patched
    Should Be Equal As Numbers    ${response.json()['totalprice']}    150

Update Without Auth
    [Tags]    update    negative
    ${booking_id}=    Create Test Booking
    ${update_data}=    Create Update Data    Test    User    100
    
    ${response}=    PUT On Session    api    ${ENDPOINT}/${booking_id}    json=${update_data}    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    403

Update Invalid Booking
    [Tags]    update    negative
    ${token}=    Get Auth Token
    ${headers}=    Create Dictionary    Cookie=token=${token}
    ${update_data}=    Create Update Data    Test    User    100
    
    ${response}=    PUT On Session    api    ${ENDPOINT}/999999    json=${update_data}    headers=${headers}    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    405

Update With Invalid Token
    [Tags]    update    negative
    ${booking_id}=    Create Test Booking
    ${headers}=    Create Dictionary    Cookie=token=invalid
    ${update_data}=    Create Update Data    Test    User    100
    
    ${response}=    PUT On Session    api    ${ENDPOINT}/${booking_id}    json=${update_data}    headers=${headers}    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    403

Update With Invalid Data
    [Tags]    update    negative
    ${booking_id}=    Create Test Booking
    ${token}=    Get Auth Token
    ${headers}=    Create Dictionary    Cookie=token=${token}
    
    ${invalid_data}=    Create Dictionary    firstname=Test
    ${response}=    PUT On Session    api    ${ENDPOINT}/${booking_id}    json=${invalid_data}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} >= 400

*** Keywords ***
Create Test Booking
    ${dates}=    Create Dictionary    checkin=2024-01-15    checkout=2024-01-20
    ${data}=    Create Dictionary
    ...    firstname=Test
    ...    lastname=User
    ...    totalprice=100
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    
    ${response}=    POST On Session    api    ${ENDPOINT}    json=${data}
    [Return]    ${response.json()['bookingid']}

Create Update Data
    [Arguments]    ${firstname}    ${lastname}    ${price}
    ${dates}=    Create Dictionary    checkin=2024-02-01    checkout=2024-02-05
    ${data}=    Create Dictionary
    ...    firstname=${firstname}
    ...    lastname=${lastname}
    ...    totalprice=${price}
    ...    depositpaid=${False}
    ...    bookingdates=${dates}
    [Return]    ${data}

Get Auth Token
    ${auth_data}=    Create Dictionary    username=admin    password=password123
    ${response}=    POST On Session    api    ${AUTH_ENDPOINT}    json=${auth_data}

