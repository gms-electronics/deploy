# Exports Local System Information to CSV
# Run this PowerShelll script at log on to collect PC information to a CSV file on a network share
# Authors: Thom McKiernan 28/08/2014, Fabian V. Thobe 12/10/2024

# Collect the info from WMI & Other sources
$computerSystem = get-wmiobject Win32_ComputerSystem
$computerBIOS = get-wmiobject Win32_BIOS
$computerOS = get-wmiobject Win32_OperatingSystem
$computerCPU = get-wmiobject Win32_Processor

# Check for OEM License
$computerOEMLicense = Get-WmiObject 'SoftwareLicensingService'
if ( $computerOEMLicense.OA3xOriginalProductKey -match '[0-9a-z]{5}-[0-9a-z]{5}-[0-9a-z]{5}-[0-9a-z]{5}-[0-9a-z]{5}' ) {
    if ( $computerOEMLicense.OA3xOriginalProductKeyDescription -match 'Pro') {
        write-host "Pro"
    }
    else {
        write-host "Home"
    }
}
else { write-host "N/A" }
# End check oem license

# Identifies the drive specifics
# Parameters used are Manufacturer, Model, SerialNumber, InterfaceType, MediaType, Size
$computerHDDfilter = “Select InterfaceType from win32_DiskDrive where InterfaceType <> 'USB'”
$computerHDD = Get-WmiObject win32_DiskDrive -Filter “NOT InterfaceType like 'USB'” | Select -property Manufacturer, Model, InterfaceType, Size, MediaType, SerialNumber

# Enter Device Doc
$deviceDocNotificationMessage = 'Please enter the repair number (YYYY / XXXXXX), PINV (PINV-XXXXX) or Asset Number'
$deviceDoc = Read-Host $deviceDocNotificationMessage

# Enter Device GPU Details
$deviceGPUList = Get-WmiObject Win32_VideoController | Select -property Description | Out-String;
$deviceGPUList
$deviceGPUInternalNotification = 'Please enter the internal GPU model from the list above'
$deviceGPUInternal = Read-Host $deviceGPUInternalNotification
$deviceGPUDiscreteNotification = 'If there are more than one GPUs enter the discrete GPU model (nVidia or ATI) from the list above, leave empty if there is only one GPU'
$deviceGPUDiscrete = Read-Host $deviceGPUDiscreteNotification

# Enter Device Estetics
$deviceDamageNotification = 'List the broken components'
$deviceDamage = Read-Host $deviceDamageNotification

# Enter Device Display
$deviceDisplayNotification ='Is the display broken?'
$deviceDisplay = Read-Host $deviceDisplayNotification

# Define Valid Grades
$validDeviceGrades = @{
    "1" = "CMN"
    "2" = "MOB"
    "3" = "UST"
    "4" = "ACC"
    "5" = "DFF"
    }
    
# Display the list of valid grades with their corresponding numbers
Write-Host "Please enter the number corresponding to the grade you wish to select:"
foreach ($grades in ($validDeviceGrades.GetEnumerator())) {
    Write-Host "[$($grades.Name)] $($grades.Value)"
}

# Prompt the user to enter the number of the employee type they want to select
$deviceGradeNotification = Read-Host 'Enter the Grade of the Device type you wish to select'

# Get the selected employee type based on the number entered by the user
$deviceGrade = $validDeviceGrades[$deviceGradeNotification]

#Build the CSV file
$csvObject = New-Object PSObject -property @{
    'deviceDoc' = $deviceDoc
    'Manufacturer' = $computerSystem.Manufacturer
    'Model' = $computerSystem.Model
    'SerialNumber' = $computerBIOS.SerialNumber
    'CPU' = $computerCPU.Name
    'RAM' = "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB)
    'deviceGPUInternal' = $deviceGPUInternal
    'deviceGPUDiscrete' = $deviceGPUDiscrete
    'deviceGrade' = $deviceGrade
    'deviceDamage' = $deviceDamage
    'HDDType' = $computerHDD.MediaType
    'HDDSize' = "{0:N2}" -f ($computerHDD.Size/1GB)
    'HDDManufacturer' = $computerHDD.Manufacturer
    'HDDModel' = $computerHDD.Model
    'HDDSerial' = $computerHDD.SerialNumber
    'HDDInterface' = $computerHDD.InterfaceType
    'OS' = $computerOEMLicense.OA3xOriginalProductKeyDescription
    } 

#Export the fields you want from above in the specified order
$csvObject | Select deviceDoc, Manufacturer, Model, SerialNumber, CPU, RAM, deviceGPUInternal, deviceGPUDiscrete, deviceGrade, deviceDamage, HDDType, HDDSize, HDDManufacturer, HDDModel, HDDSerial, HDDInterface, OS | Export-Csv -Path X:\system-info-test.csv -NoTypeInformation -Append

# Open CSV file for review (leave this line out when deploying)
notepad system-info-test.csv 
