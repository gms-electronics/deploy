# Exports Local System Information to CSV
# Run this PowerShelll script at log on to collect PC information to a CSV file on a network share
# Thom McKiernan 28/08/2014

# Allow custom scripts
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Collect the info from WMI & Other sources
$computerSystem = get-wmiobject Win32_ComputerSystem
$computerBIOS = get-wmiobject Win32_BIOS
$computerOS = get-wmiobject Win32_OperatingSystem
$computerCPU = get-wmiobject Win32_Processor

# Identifies the drive specifics
# Parameters used are Manufacturer, Model, SerialNumber, InterfaceType, MediaType, Size
$computerHDD = Get-WmiObject Win32_DiskDrive | Select -property Manufacturer, Model, InterfaceType, Size, MediaType

# Identifies the TPM specifics
# Parameters used are SpecVersion
$computerTPM = Get-WmiObject Win32_Tpm 


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
$deviceDamageNotification = 'Is the device physically broken?'
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
    'HDDType' = $computerHDD.MediaType
    'HDDSize' = "{0:N2}" -f ($computerHDD.Size/1GB)
    'HDDManufacturer' = $computerHDD.Manufacturer
    'HDDModel' = $computerHDD.Model
    'HDDInterface' = $computerHDD.InterfaceType
    'OS' = $computerOS.caption
    'TPMv' = $computerTPM.SpecVersion
    } 

#Export the fields you want from above in the specified order
$csvObject | Select deviceDoc, Manufacturer, Model, SerialNumber, CPU, RAM, deviceGPUInternal, deviceGPUDiscrete, deviceGrade, HDDType, HDDSize, HDDManufacturer, HDDModel, HDDInterface, OS, TPMv | Export-Csv 'system-info.csv' -NoTypeInformation -Append

# Open CSV file for review (leave this line out when deploying)
notepad system-info.csv

# Prohibit custom scripts
Set-ExecutionPolicy -ExecutionPolicy Restricted