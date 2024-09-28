# Technical Guide

# BETA / TESTING: Not production ready

# Requirements
x32 Systems might be (depending on demand) supported at a later stage. 
This guide only functions for Windows x64 Systems.

# Warnings
This guide removes all encryption keys and formats the data on the drive, subsequent recovery of data will be difficult to impossible. 

# Guide

## Prepare BIOS / UEFI
1. Enter BIOS / UEFI
Following shortcuts provide access to BIOS

| Vendor / Brand | Type             | Keyboard Shortcut     |
|----------------|------------------|-----------------------|
| ASUS           | Notebook / PC    | F2                    |
| ACER           | Notebook / PC    | F2                    |
| Dell           | Notebook / PC    | F2 or F12             |
| HP             | Notebook / PC    | F10                   |
| Lenovo         | Consumer Laptops | F2                    |
| Lenovo         | PC / Thinkpads   | F1                    |
| Microsoft      | Surface          | Hold Volume Up button |
| Samsung        | Notebooks        | F2                    |
| Toshiba        | Notebooks        | F2                    |

2. Configure following settings
- Activate Secure Boot
- Clear TPM / Encryption or Security Chip
- Enable All Intel Virtualisation Technologies
- Boot from Network
- Save and Reboot

3. Enter Network Install
Boot from Network by choosing PXE or Network boot
Select the appropriate Installation Profile (Attention: most times the generic installation without drivers should work, if the installation does not complete switch to a manufacturer profile). 
