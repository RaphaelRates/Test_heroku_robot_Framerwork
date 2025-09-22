*** Settings ***
Documentation    Delete Booking Tests
Library          RequestsLibrary
Library          Collections

Suite Setup      Create Session    api    https://restful-booker.herokuapp.com
Suite Teardown   Delete All Sessions

*** Variables ***
${ENDPOINT}    /booking
${AUTH_ENDPOINT}    /auth

*** Test Cases ***
Delete Booking
    [Tags]    delete    positive
    ${booking_id}=    Create Test Booking
    ${token}=    Get Auth Token
    ${headers}=    Create Dictionary    Cookie=token=${token}
    
    ${response}=    DELETE On Session    api    ${ENDPOINT}/${booking_id}    headers=${headers}
    Should Be Equal As Numbers    ${response.status_code}    201
    
    # Verify deletion
    ${response}=    GET On Session    api    ${ENDPOINT}/${booking_id}    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    404

Delete Without Auth
    [Tags]    delete    negative
    ${booking_id}=    Create Test Booking
    
    ${response}=    DELETE On Session    api    ${ENDPOINT}/${booking_id}    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    403

Delete Invalid Booking
    [Tags]    delete    negative
    ${token}=    Get Auth Token
    ${headers}=    Create Dictionary    Cookie=token=${token}
    
    ${response}=    DELETE On Session    api    ${ENDPOINT}/999999    headers=${headers}    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    405

Delete With Invalid Token
    [Tags]    delete    negative
    ${booking_id}=    Create Test Booking
    ${headers}=    Create Dictionary    Cookie=token=invalid
    
    ${response}=    DELETE On Session    api    ${ENDPOINT}/${booking_id}    headers=${headers}    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    403

Delete Already Deleted Booking
    [Tags]    delete    edge
    ${booking_id}=    Create Test Booking
    ${token}=    Get Auth Token
    ${headers}=    Create Dictionary    Cookie=token=${token}
    
    # First deletion
    DELETE On Session    api    ${ENDPOINT}/${booking_id}    headers=${headers}
    
    # Second deletion attempt
    ${response}=    DELETE On Session    api    ${ENDPOINT}/${booking_id}    headers=${headers}    expected_status=any
    Should Be Equal As Numbers    ${response.status_code}    405

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

Get Auth Token
    ${auth_data}=    Create Dictionary    username=admin    password=password123
    ${response}=    POST On Session    api    ${AUTH_ENDPOINT}    json=${auth_data}
    [Return]    ${response.json()['token']}