*** Settings ***
Library           RPA.Robocorp.WorkItems
Library           RPA.Tables
Library    Collections
Library    RPA.Browser.Selenium

*** Keywords ***
Login
    [Documentation]    
    ...    Simulates a login that fails 1/5 times to highlight APPLICATION exception handling.
    ...    In this example login is performed only once for all work items.

    ${Login as James Bond}=    Evaluate    random.randint(1, 5) 
    IF   ${Login as James Bond} != 1 
        Log     Logged in as Bond.. James Bond
    ELSE    
        Fail    Login failed    
    END


*** Keywords ***
Action For Item
    [Documentation]    
    ...    Simulates handling of one work item that fails 1/5 times to highlight BUSINESS exception handling.
    [Arguments]    ${payload}

    ${Item Action OK}=    Evaluate    random.randint(1, 5) 
    IF    ${Item Action OK} != 1 
        Log    Did a thing item for: ${payload}
    ELSE    
        Fail   Failed to handle item for: ${payload}.
    END
    

*** Keywords ***
Handle Item
    [Documentation]    Error handling around one work item

    ${payload}=    Get Work Item Payload
    ${Item Handled}=    Run Keyword And Return Status
    ...    Action For Item    ${payload} 
    
    IF    ${Item Handled}
        Release Input Work Item    DONE    
    ELSE
        # Giving a good error message here means that data related errors can be fixed faster in Control Room
        ${error_message}=    Set Variable
        ...   Failed to handle item for: ${payload}.

        Log    ${error_message}    level=ERROR
        Release Input Work Item    FAILED    exception_type=BUSINESS    message=${error_message}
    END


*** Tasks ***
Consume Items
    [Documentation]    Login and then cycle through work items

    ${Login OK}=    Run Keyword And Return Status
    ...    Login
    IF    ${Login OK}
        For Each Input Work Item    Handle Item
    ELSE
        ${error_message}=    Set Variable
        ...   Unable to login to target system. Please check that the site/application is up and available..

        Log    ${error_message}    level=ERROR
        Release Input Work Item    FAILED    exception_type=APPLICATION    message=${error_message}
    END
