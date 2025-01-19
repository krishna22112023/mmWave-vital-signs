%%
% demo GUI for Vital signs monitoring
% GUI consists of monitoring for heart rate, breathing rate and chest displacement 
% Created 28-Aug-2019 17:42
%
% This script requires:
%
%profile_2d_VitalSigns_20fps.cfg: Chirp Configuration file to run the EVM board
%NTU Logo: Logo for GUI
% 
% This script assumes these functions are defined:
%  gui_components - realtime wave form ploting of vital signs and data extraction (128 bits at a time) for signal post-proccessing and machine learning
%%
%  Chirp configuration
% sensorStop  %chirp stop
% flushCfg  %erase history
% dfeDataOutputMode 1  %frame based chirp enable
% channelCfg 15 5 0    % 15->4 Rx antennas, 5->2 Tx azimuth antennas enabled
% adcCfg 2 1           % 2->number of ADC bits anabled:16, 1->Cmplx output format
% adcbufCfg 0 1 0 1
% profileCfg 0 77 7 6 57 0 0 70 1 200 4000 0 0 48   % 77-> Start frequency in GHz , 7-> idle time in us, 6->ADC start time in us, 57->ramp end time in usec, 
% 0->Tx output power back-off code for TX antennas,0->Tx phase shifter for Tx ,70-> frequency slope constant(BW=57x70=3.99GHz)
% 1->Tx start time in u-sec, 200->Number of ADC samples,4000->ADC sampling frequency in ksps, 48->Rx gain in dB
% chirpCfg 0 0 0 0 0 0 0 1 %enable chirp config for Tx1
% chirpCfg 1 1 0 0 0 0 0 4 %enable chirp config for Tx2
% frameCfg 0 1 1 0 50 1 0 % 0->chirp start index, 1->chirp end index,1->number of loops (1 time:2chirps in total), 0->infinite number of frames, 
% 50-> frame periodicity in ms,1->software trigger, 0->frame trigger delay in ms
% guiMonitor 0 0 0 0 1 %enable GUI
% vitalSignsCfg 0.3 1.0 256 512 4 0.1 0.05 100000 100000 % 0.3m to 1m:radar range set,256->Breathing Waveform Size,512->Heart rate Waveform Size, 4->Threshold for Gain Control,
% 0.1->Alpha filter value for Breathing waveform energy computation,0.05->Alpha filter value for heart-beat waveform energy computation,
% 100000-> Scale Factor for breathing and heart-beat waveform
% motionDetection 1 20 3.0 0 % 1->enable motion detection block, 20->Data segments Length (L), 3->energy threshold for discarding garbled data segment, 0-> gain control
% sensorStart %start chirp

%%

classdef VitalSignsGUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        TexasInstrumentsVitalSignsMonitoringDemoUIFigure  matlab.ui.Figure
        PhaseUnwrapped           matlab.ui.control.UIAxes
        BreathingWfm             matlab.ui.control.UIAxes
        HeartRateWfm             matlab.ui.control.UIAxes
        BreathingRateNumberDisp  matlab.ui.control.NumericEditField
        HeartRateNumberDisp      matlab.ui.control.NumericEditField
        LoadConfigFile           matlab.ui.control.CheckBox
        RangeProfile             matlab.ui.control.UIAxes
        SaveData                 matlab.ui.control.CheckBox
        CountEditFieldLabel      matlab.ui.control.Label
        Count_GUI                matlab.ui.control.NumericEditField
        IndexLabel               matlab.ui.control.Label
        MaxRangeIndex            matlab.ui.control.NumericEditField
        BRpkLabel                matlab.ui.control.Label
        Temp1Display             matlab.ui.control.NumericEditField
        HRpkLabel                matlab.ui.control.Label
        Temp2Display             matlab.ui.control.NumericEditField
        CMBreathEditFieldLabel   matlab.ui.control.Label
        CMBreathEditField        matlab.ui.control.NumericEditField
        CMHeartLabel             matlab.ui.control.Label
        CMHeartEditField         matlab.ui.control.NumericEditField
        BreathingRateLabel       matlab.ui.control.Label
        HeartRateLabel           matlab.ui.control.Label
        Panel                    matlab.ui.container.Panel
        Start                    matlab.ui.control.Button
        Stop                     matlab.ui.control.Button
        RefreshButtonPressed     matlab.ui.control.Button
        SettingsButton           matlab.ui.control.Button
        Pause                    matlab.ui.control.Button
        Panel_2                  matlab.ui.container.Panel
        Plot_RangeProfile        matlab.ui.control.CheckBox
        Plots_Enable             matlab.ui.control.CheckBox
        FFT_BasedCheckBox        matlab.ui.control.CheckBox
        Plot_Displacement        matlab.ui.control.CheckBox
        Button                   matlab.ui.control.Button
        THBreathLabel            matlab.ui.control.Label
        ThresholdBreathing       matlab.ui.control.Spinner
        THHeartLabel             matlab.ui.control.Label
        ThresholdHeart           matlab.ui.control.Spinner
        BRFTLabel                matlab.ui.control.Label
        Temp1Display_2           matlab.ui.control.NumericEditField
        HRFTLabel                matlab.ui.control.Label
        Temp2Display_2           matlab.ui.control.NumericEditField
        MotionEditFieldLabel     matlab.ui.control.Label
        MotionFlagEditField      matlab.ui.control.NumericEditField
    end


    properties (Access = public)
                EXIT_PRESSED;         
                PAUSED_PRESSED;
                REFRESH_PRESSED;
                FFT_SPECTRAL_EST_ENABLE;
                CLI_SEND_FLAG;
                comport_UserUARTnum;       
                comport_DataPortnum;
                settings = {'config/profile_2d_VitalSigns_20fps.cfg','4','5'};      
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
                        app.Button.Icon = 'assets/logo/NTULogo.png';  % Texas Instruments Logo  
                        app.EXIT_PRESSED = 0;             % Flag for the Stop PushButton 
                        app.REFRESH_PRESSED = 0;          % Flag for the Refresh PushButton
                        app.PAUSED_PRESSED = 0;           % Flag for the Pause PushButton 

        end

        % Button pushed function: Start
        function StartPushed(app, event)
            loadConfig = 0;
            app.EXIT_PRESSED = 0;
            app.PAUSED_PRESSED = 0;
            
            app.Stop.BackgroundColor  = [0.94 0.94 0.94];
            app.Start.BackgroundColor = 'red';
            app.Pause.BackgroundColor = [0.94 0.94 0.94];
            
            if(app.LoadConfigFile.Value)
                loadConfig = 1;
            end
                        app.FFT_SPECTRAL_EST_ENABLE = app.FFT_BasedCheckBox.Value;
                        configFileName     = app.settings{1};
                        comPortnumber_CLI  = str2double(app.settings{2});
                        comPortnumber_DATA = str2double(app.settings{3});
                        gui_components(comPortnumber_DATA,comPortnumber_CLI,configFileName,loadConfig, app);                 
        end

        % Button pushed function: Stop
        function StopButtonPushed(app, event)
            app.EXIT_PRESSED = 1;
            app.LoadConfigFile.Value = 1; 
            app.Stop.BackgroundColor = 'red';
            app.Start.BackgroundColor = [0.94 0.94 0.94];
            app.Pause.BackgroundColor = [0.94 0.94 0.94];
        end

        % Button pushed function: RefreshButtonPressed
        function RefreshButtonPressedButtonPushed(app, event)
            app.REFRESH_PRESSED = 1;
        end

        % Callback function
        function PulseOximeterButtonPushed(app, event)
         
        end

        % Value changed function: FFT_BasedCheckBox
        function FFT_BasedCheckBoxValueChanged(app, event)
            value = app.FFT_BasedCheckBox.Value;
            app.FFT_SPECTRAL_EST_ENABLE = value;
            app.CLI_SEND_FLAG=1;
        end

        % Button pushed function: SettingsButton
        function SettingsButtonPushed(app, event)
        prompt = {'Configuration File name:','User UART Port', 'Auxilliary Data Port'};
        dlg_title = 'Settings';
        num_lines = 1;
       
        defaultans = {'profile_2d_VitalSigns_20fps.cfg','4','5'};
        app.settings = inputdlg(prompt,dlg_title,num_lines,defaultans);               
        end

        % Callback function
        function sizeChangedFcn(app, event)
      
        end

        % Button pushed function: Pause
        function PausePushed(app, event)
           app.PAUSED_PRESSED = 1; 
           app.LoadConfigFile.Value = 0;  
           app.Stop.BackgroundColor  = [0.94 0.94 0.94];
           app.Start.BackgroundColor = [0.94 0.94 0.94];
           app.Pause.BackgroundColor = 'red';
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create TexasInstrumentsVitalSignsMonitoringDemoUIFigure and hide until all components are created
            app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure = uifigure('Visible', 'off');
            app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure.Color = [0.9373 0.9373 0.9373];
            app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure.Position = [100 100 1100 633];
            app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure.Name = 'Vital Signs Monitoring Demo';

            % Create PhaseUnwrapped
            app.PhaseUnwrapped = uiaxes(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            title(app.PhaseUnwrapped, 'Chest Displacement')
            xlabel(app.PhaseUnwrapped, 'Frame Index')
            ylabel(app.PhaseUnwrapped, 'Displacement (mm)')
            app.PhaseUnwrapped.FontWeight = 'bold';
            app.PhaseUnwrapped.GridAlpha = 0.15;
            app.PhaseUnwrapped.MinorGridAlpha = 0.25;
            app.PhaseUnwrapped.Box = 'on';
            app.PhaseUnwrapped.Color = [0.9373 0.9373 0.9373];
            app.PhaseUnwrapped.Position = [1 109 600 193];

            % Create BreathingWfm
            app.BreathingWfm = uiaxes(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            title(app.BreathingWfm, 'Breathing Waveform')
            app.BreathingWfm.GridAlpha = 0.15;
            app.BreathingWfm.MinorGridAlpha = 0.25;
            app.BreathingWfm.Box = 'on';
            app.BreathingWfm.Color = [0.9373 0.9373 0.9373];
            app.BreathingWfm.Position = [21 307 440 201];

            % Create HeartRateWfm
            app.HeartRateWfm = uiaxes(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            title(app.HeartRateWfm, 'Heart Waveform')
            app.HeartRateWfm.GridAlpha = 0.15;
            app.HeartRateWfm.MinorGridAlpha = 0.25;
            app.HeartRateWfm.Box = 'on';
            app.HeartRateWfm.Color = [0.9373 0.9373 0.9373];
            app.HeartRateWfm.Position = [481 307 440 201];

            % Create BreathingRateNumberDisp
            app.BreathingRateNumberDisp = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.BreathingRateNumberDisp.ValueDisplayFormat = '%2.0f';
            app.BreathingRateNumberDisp.HorizontalAlignment = 'center';
            app.BreathingRateNumberDisp.FontSize = 48;
            app.BreathingRateNumberDisp.Position = [37 508 424 90];

            % Create HeartRateNumberDisp
            app.HeartRateNumberDisp = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.HeartRateNumberDisp.ValueDisplayFormat = '%3.0f';
            app.HeartRateNumberDisp.HorizontalAlignment = 'center';
            app.HeartRateNumberDisp.FontSize = 48;
            app.HeartRateNumberDisp.Position = [501 508 420 90];
            app.HeartRateNumberDisp.Value = 0;

            % Create LoadConfigFile
            app.LoadConfigFile = uicheckbox(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.LoadConfigFile.Text = 'Load Config File';
            app.LoadConfigFile.Position = [951 529 120 21];
            app.LoadConfigFile.Value = true;

            % Create RangeProfile
            app.RangeProfile = uiaxes(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            title(app.RangeProfile, 'Range Profile')
            xlabel(app.RangeProfile, 'Range (meter)')
            app.RangeProfile.FontWeight = 'bold';
            app.RangeProfile.GridAlpha = 0.15;
            app.RangeProfile.MinorGridAlpha = 0.25;
            app.RangeProfile.Box = 'on';
            app.RangeProfile.Color = [0.9373 0.9373 0.9373];
            app.RangeProfile.Position = [621 109 300 193];

            % Create SaveData
            app.SaveData = uicheckbox(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.SaveData.Text = 'Save Data';
            app.SaveData.Position = [951 552 120 21];

            % Create CountEditFieldLabel
            app.CountEditFieldLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.CountEditFieldLabel.HorizontalAlignment = 'right';
            app.CountEditFieldLabel.VerticalAlignment = 'top';
            app.CountEditFieldLabel.Visible = 'off';
            app.CountEditFieldLabel.Position = [365 48 38 15];
            app.CountEditFieldLabel.Text = 'Count';

            % Create Count_GUI
            app.Count_GUI = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.Count_GUI.Editable = 'off';
            app.Count_GUI.Visible = 'off';
            app.Count_GUI.Position = [405 44 52 22];

            % Create IndexLabel
            app.IndexLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.IndexLabel.HorizontalAlignment = 'right';
            app.IndexLabel.VerticalAlignment = 'top';
            app.IndexLabel.Visible = 'off';
            app.IndexLabel.Position = [365 18 38 15];
            app.IndexLabel.Text = ' Index';

            % Create MaxRangeIndex
            app.MaxRangeIndex = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.MaxRangeIndex.Editable = 'off';
            app.MaxRangeIndex.Visible = 'off';
            app.MaxRangeIndex.Position = [405 14 52 22];

            % Create BRpkLabel
            app.BRpkLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.BRpkLabel.HorizontalAlignment = 'right';
            app.BRpkLabel.VerticalAlignment = 'top';
            app.BRpkLabel.Visible = 'off';
            app.BRpkLabel.Position = [463 48 39 15];
            app.BRpkLabel.Text = 'BR-pk';

            % Create Temp1Display
            app.Temp1Display = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.Temp1Display.Editable = 'off';
            app.Temp1Display.Visible = 'off';
            app.Temp1Display.Position = [506 45 57 22];

            % Create HRpkLabel
            app.HRpkLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.HRpkLabel.HorizontalAlignment = 'right';
            app.HRpkLabel.VerticalAlignment = 'top';
            app.HRpkLabel.Visible = 'off';
            app.HRpkLabel.Position = [462 18 40 15];
            app.HRpkLabel.Text = 'HR-pk';

            % Create Temp2Display
            app.Temp2Display = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.Temp2Display.Editable = 'off';
            app.Temp2Display.Visible = 'off';
            app.Temp2Display.Position = [507 14 57 22];

            % Create CMBreathEditFieldLabel
            app.CMBreathEditFieldLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.CMBreathEditFieldLabel.HorizontalAlignment = 'right';
            app.CMBreathEditFieldLabel.VerticalAlignment = 'top';
            app.CMBreathEditFieldLabel.Visible = 'off';
            app.CMBreathEditFieldLabel.Position = [677 48 63 15];
            app.CMBreathEditFieldLabel.Text = 'CM Breath';

            % Create CMBreathEditField
            app.CMBreathEditField = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.CMBreathEditField.Editable = 'off';
            app.CMBreathEditField.Visible = 'off';
            app.CMBreathEditField.Position = [743 45 44 22];

            % Create CMHeartLabel
            app.CMHeartLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.CMHeartLabel.HorizontalAlignment = 'right';
            app.CMHeartLabel.VerticalAlignment = 'top';
            app.CMHeartLabel.Visible = 'off';
            app.CMHeartLabel.Position = [679 19 60 15];
            app.CMHeartLabel.Text = 'CM  Heart';

            % Create CMHeartEditField
            app.CMHeartEditField = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.CMHeartEditField.Editable = 'off';
            app.CMHeartEditField.Visible = 'off';
            app.CMHeartEditField.Position = [743 16 44 22];

            % Create BreathingRateLabel
            app.BreathingRateLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.BreathingRateLabel.HorizontalAlignment = 'center';
            app.BreathingRateLabel.VerticalAlignment = 'top';
            app.BreathingRateLabel.FontSize = 28;
            app.BreathingRateLabel.Position = [21 598 440 36];
            app.BreathingRateLabel.Text = 'Breathing Rate';

            % Create HeartRateLabel
            app.HeartRateLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.HeartRateLabel.HorizontalAlignment = 'center';
            app.HeartRateLabel.VerticalAlignment = 'top';
            app.HeartRateLabel.FontSize = 28;
            app.HeartRateLabel.Position = [501 598 420 36];
            app.HeartRateLabel.Text = 'Heart Rate';

            % Create Panel
            app.Panel = uipanel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.Panel.Position = [941 207 140 277];

            % Create Start
            app.Start = uibutton(app.Panel, 'push');
            app.Start.ButtonPushedFcn = createCallbackFcn(app, @StartPushed, true);
            app.Start.FontSize = 22;
            app.Start.FontWeight = 'bold';
            app.Start.Position = [22 232 100 36];
            app.Start.Text = 'Start';

            % Create Stop
            app.Stop = uibutton(app.Panel, 'push');
            app.Stop.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.Stop.FontSize = 22;
            app.Stop.FontWeight = 'bold';
            app.Stop.Position = [21 120 100 36];
            app.Stop.Text = 'Stop';

            % Create RefreshButtonPressed
            app.RefreshButtonPressed = uibutton(app.Panel, 'push');
            app.RefreshButtonPressed.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPressedButtonPushed, true);
            app.RefreshButtonPressed.FontSize = 22;
            app.RefreshButtonPressed.FontWeight = 'bold';
            app.RefreshButtonPressed.Position = [22 17 100 36];
            app.RefreshButtonPressed.Text = 'Refresh';

            % Create SettingsButton
            app.SettingsButton = uibutton(app.Panel, 'push');
            app.SettingsButton.ButtonPushedFcn = createCallbackFcn(app, @SettingsButtonPushed, true);
            app.SettingsButton.FontSize = 22;
            app.SettingsButton.FontWeight = 'bold';
            app.SettingsButton.Position = [22 65 100 36];
            app.SettingsButton.Text = 'Settings';   

            % Create Pause
            app.Pause = uibutton(app.Panel, 'push');
            app.Pause.ButtonPushedFcn = createCallbackFcn(app, @PausePushed, true);
            app.Pause.FontSize = 22;
            app.Pause.FontWeight = 'bold';
            app.Pause.Position = [22 174 100 36];
            app.Pause.Text = 'Pause';

            % Create Panel_2
            app.Panel_2 = uipanel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.Panel_2.Position = [943 93 140 106];

            % Create Plot_RangeProfile
            app.Plot_RangeProfile = uicheckbox(app.Panel_2);
            app.Plot_RangeProfile.Text = 'Plot Range Profile';
            app.Plot_RangeProfile.Position = [8 82 121 15];
            app.Plot_RangeProfile.Value = true;

            % Create Plots_Enable
            app.Plots_Enable = uicheckbox(app.Panel_2);
            app.Plots_Enable.Text = 'Enable Plots';
            app.Plots_Enable.Position = [9 38 91 15];
            app.Plots_Enable.Value = true;

            % Create FFT_BasedCheckBox
            app.FFT_BasedCheckBox = uicheckbox(app.Panel_2);
            app.FFT_BasedCheckBox.ValueChangedFcn = createCallbackFcn(app, @FFT_BasedCheckBoxValueChanged, true);
            app.FFT_BasedCheckBox.Text = 'FFT_Based';
            app.FFT_BasedCheckBox.Position = [9 16 85 15];

            % Create Plot_Displacement
            app.Plot_Displacement = uicheckbox(app.Panel_2);
            app.Plot_Displacement.Text = 'Plot Displacement';
            app.Plot_Displacement.Position = [9 60 121 15];

            % Create Button
            app.Button = uibutton(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'push');
            app.Button.Icon = 'NTULogo.png';
            app.Button.BackgroundColor = [0.9373 0.9373 0.9373];
            app.Button.Position = [420 9 262 101];
            app.Button.Text = '';

            % Create THBreathLabel
            app.THBreathLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.THBreathLabel.HorizontalAlignment = 'right';
            app.THBreathLabel.VerticalAlignment = 'top';
            app.THBreathLabel.Visible = 'off';
            app.THBreathLabel.Position = [802 48 60 15];
            app.THBreathLabel.Text = 'TH Breath';

            % Create ThresholdBreathing
            app.ThresholdBreathing = uispinner(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.ThresholdBreathing.Visible = 'off';
            app.ThresholdBreathing.Position = [869 44 64 22];
            app.ThresholdBreathing.Value = 10;

            % Create THHeartLabel
            app.THHeartLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.THHeartLabel.HorizontalAlignment = 'right';
            app.THHeartLabel.VerticalAlignment = 'top';
            app.THHeartLabel.Visible = 'off';
            app.THHeartLabel.Position = [805 19 57 15];
            app.THHeartLabel.Text = 'TH  Heart';

            % Create ThresholdHeart
            app.ThresholdHeart = uispinner(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.ThresholdHeart.Step = 0.1;
            app.ThresholdHeart.Visible = 'off';
            app.ThresholdHeart.Position = [869 15 64 22];
            app.ThresholdHeart.Value = 0.4;

            % Create BRFTLabel
            app.BRFTLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.BRFTLabel.HorizontalAlignment = 'right';
            app.BRFTLabel.VerticalAlignment = 'top';
            app.BRFTLabel.Visible = 'off';
            app.BRFTLabel.Position = [569 47 40 15];
            app.BRFTLabel.Text = 'BR-FT';

            % Create Temp1Display_2
            app.Temp1Display_2 = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.Temp1Display_2.Editable = 'off';
            app.Temp1Display_2.Visible = 'off';
            app.Temp1Display_2.Position = [613 44 57 22];

            % Create HRFTLabel
            app.HRFTLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.HRFTLabel.HorizontalAlignment = 'right';
            app.HRFTLabel.VerticalAlignment = 'top';
            app.HRFTLabel.Visible = 'off';
            app.HRFTLabel.Position = [567 18 41 15];
            app.HRFTLabel.Text = 'HR-FT';

            % Create Temp2Display_2
            app.Temp2Display_2 = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.Temp2Display_2.Editable = 'off';
            app.Temp2Display_2.Visible = 'off';
            app.Temp2Display_2.Position = [613 14 57 22];

            % Create MotionEditFieldLabel
            app.MotionEditFieldLabel = uilabel(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure);
            app.MotionEditFieldLabel.HorizontalAlignment = 'right';
            app.MotionEditFieldLabel.VerticalAlignment = 'top';
            app.MotionEditFieldLabel.Position = [947 64 42 15];
            app.MotionEditFieldLabel.Text = 'Motion';

            % Create MotionFlagEditField
            app.MotionFlagEditField = uieditfield(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure, 'numeric');
            app.MotionFlagEditField.Editable = 'off';
            app.MotionFlagEditField.Position = [993 61 44 22];

            % Show the figure after all components are created
            app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = vitalSignsDemo_GUI_NTU_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.TexasInstrumentsVitalSignsMonitoringDemoUIFigure)
        end
    end
   
end