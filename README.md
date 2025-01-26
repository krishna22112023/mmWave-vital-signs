# mm-Wave Radar-Based Vital Signs Monitoring and Arrhythmia Detection Using Machine Learning

This repository is the official implementation of the [paper](https://www.mdpi.com/1424-8220/22/9/3106) titled "mm-Wave Radar-Based Vital Signs Monitoring and Arrhythmia Detection Using Machine Learning" published in Sensors MDPI. 

https://github.com/user-attachments/assets/b26673e0-3b43-454f-b0a3-cd51da913339


## Requirements

### Software 
- TI mmWave SDK 2.1.0.4 and all related dependencies installed as mentioned in the mmWave SDK release notes in docs/ 
- UniFlash : For flashing firmware images onto. Download from TI.com/tool/uniflash 
- XDS110 Drivers : For EVM XDS device support. Included with CCS Installation, or standalone through TI XDS Emulation Software 
- MATLAB runtime R2016b (9.1) 

### Hardware
- AWR14xx/IWR14xx EVM ES3.0 
- Micro USB cable (included in the EVM package) 
- 5V/2.5A Power Supply 
- A lens/concentrator (optional) to direct the radar waves towards the chest 

## Setup

- If you want to directly run the GUI, follow the quick start guide in docs/ and flash the prebuilt binary in `backend/Prebuilt_binaries/xwr14xx_vitalSigns_lab_mss.bin` to the EVM board. Then run the `frontend/app/VitalSignsGUI.m` to launch the GUI.

- If you want to modify and build the vital signs code, follow the developers guide in docs/. Then run the `frontend/app/VitalSignsGUI.m` to launch the GUI.


