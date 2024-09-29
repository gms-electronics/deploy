# Exports Local System Information to CSV
# Run this PowerShelll script at log on to collect PC information to a CSV file on a network share
# Thom McKiernan 28/08/2014

# Collect the info from WMI & Other sources
$computerSystem = get-wmiobject Win32_ComputerSystem
$computerBIOS = get-wmiobject Win32_BIOS
$computerOS = get-wmiobject Win32_OperatingSystem
$computerCPU = get-wmiobject Win32_Processor
# Identifies the drive specifics
# Parameters used are Manufacturer, Model, SerialNumber, InterfaceType, MediaType, Size
$computerHDD = Get-WmiObject Win32_DiskDrive
# $computerGPU = 
$computerTPM = Get-WmiObject Win32_Tpm 
#$computerHDD = Get-WmiObject Win32_LogicalDisk -Filter drivetype=3

# Enter Device Doc
$deviceDocNotificationMessage = 'Please enter the repair number (YYYY / XXXXXX), PINV (PINV-XXXXX) or Asset Number'
$deviceDoc = Read-Host $deviceDocNotificationMessage

# Enter Device GPU Details
Get-WmiObject Win32_VideoController
$deviceGPUInternalNotification = 'Please enter the internal GPU model from the list above'
$deviceGPUInternal = Read-Host $deviceGPUInternalNotificationMessage
$deviceGPUDiscreteNotification = 'If there are more than one GPUs enter the discrete GPU model (nVidia or ATI) from the list above, leave empty if there is only one GPU'
$deviceGPUDiscrete = Read-Host $deviceGPUDiscreteNotificationMessage

#Build the CSV file
$csvObject = New-Object PSObject -property @{
    'deviceDoc' = $deviceDoc
    'Manufacturer' = $computerSystem.Manufacturer
    'Model' = $computerSystem.Model
    'SerialNumber' = $computerBIOS.SerialNumber
    'CPU' = $computerCPU.Name
    'RAM' = "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB)
    'TPMv' = $computerTPM.SpecVersion
    'deviceGPUInternal' = $deviceGPUInternal
    'deviceGPUDiscrete' = $deviceGPUDiscrete
    'HDDManufacturer' = $computerHDD.Manufacturer
    'HDDModel' = $computerHDD.Model
    'HDDInterface' = $computerHDD.InterfaceType
    'HDDType' = $computerHDD.MediaType
    'HDDSize' = "{0:N2}" -f ($computerHDD.Size/1GB)
    'OS' = $computerOS.caption
    } 

#Export the fields you want from above in the specified order
$csvObject | Select deviceDoc, Manufacturer, SerialNumber, Model, CPU, Ram, HDDSize, HDDType | Export-Csv 'system-info.csv' -NoTypeInformation -Append

# Open CSV file for review (leave this line out when deploying)
notepad system-info.csv