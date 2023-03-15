*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
...

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.FileSystem
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Instrustries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${order}
        Download and store the receipt    ${order}
        Order another robot
    END
    Archive output PDFs
    [Teardown]    Close RobotSpareBin browser


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True

Download the orders file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Get orders
    Download the orders file
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Close the annoying modal
    Wait Until Page Contains Element    class:modal-content
    Click Button    OK

Fill the form
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    address    ${order}[Address]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Click Button    preview
    Wait Until Keyword Succeeds    10x    0.5s    Submit the order

Submit the order
    Click Button    order
    Page Should Not Contain Button    order

Download and store the receipt
    [Arguments]    ${order}
    ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
    ${screenshot}=    Take a screenshot of the robot    ${order}[Order number]
    Embed the screenshot to the receipt PDF file    ${screenshot}    ${pdf}

Order another robot
    Click Button    order-another

Store the receipt as a PDF file
    [Arguments]    ${Order Number}
    Wait Until Element Is Visible    id:receipt
    ${order_summary_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_summary_html}    ${OUTPUT_DIR}${/}receipts/order-${Order Number}_summary.pdf
    ${pdf}=    Set Variable    ${OUTPUT_DIR}${/}receipts/order-${Order Number}_summary.pdf
    RETURN    ${pdf}

Take a screenshot of the robot
    [Arguments]    ${Order Number}
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}/receipts/order-${Order Number}-image.png
    ${screenshot}=    Set Variable    ${OUTPUT_DIR}${/}receipts/order-${Order Number}-image.png
    RETURN    ${screenshot}

Embed the screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Remove File    ${screenshot}
    Close Pdf

Archive output PDFs
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}${/}Receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${zip_file_name}
    Empty Directory    ${OUTPUT_DIR}${/}receipts
    Remove Directory    ${OUTPUT_DIR}${/}receipts

Close RobotSpareBin browser
    Close Browser
