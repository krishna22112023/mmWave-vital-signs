classdef DiagnosisReport < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        DiagnosisReportLabel  matlab.ui.control.Label
        AgeLabel              matlab.ui.control.Label
        GenderLabel           matlab.ui.control.Label
        HeartrateLabel        matlab.ui.control.Label
        BreathingrateLabel    matlab.ui.control.Label
        CardiachealthriskdiagnosisLabel  matlab.ui.control.Label
        Age                   matlab.ui.control.NumericEditField
        Gender                matlab.ui.control.EditField
        HR                    matlab.ui.control.NumericEditField
        BR                    matlab.ui.control.NumericEditField
        diagnosis             matlab.ui.control.EditField
        HRV_UIAxes            matlab.ui.control.UIAxes
        BRV_UIAxes_2          matlab.ui.control.UIAxes
        OKButton              matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: OKButton
        function OKButtonPushed(app, event)
            closereq();
        end
    end

    % Component initialization
    methods (Access = private)
        

        % Create UIFigure and components
        function createComponents(app)
            prompt = {'Enter age:','Enter gender:'};
            dlgtitle = 'Input details';
            dims = [1 35];
            definput = {'0','1'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            age=str2num(cell2mat(answer(1,1)));
            gender=cell2mat(answer(2,1));
            [BMI, Heart_rate,breath_rate,mean_HR,mean_BR,message]=ECG(age,gender);

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.8 0.8 0.8];
            app.UIFigure.Position = [100 100 641 631];
            app.UIFigure.Name = 'UI Figure';

            % Create DiagnosisReportLabel
            app.DiagnosisReportLabel = uilabel(app.UIFigure);
            app.DiagnosisReportLabel.HorizontalAlignment = 'center';
            app.DiagnosisReportLabel.FontName = 'Lucida Sans';
            app.DiagnosisReportLabel.FontSize = 24;
            app.DiagnosisReportLabel.FontWeight = 'bold';
            app.DiagnosisReportLabel.Position = [122 569 373 30];
            app.DiagnosisReportLabel.Text = 'Diagnosis Report';

            % Create AgeLabel
            app.AgeLabel = uilabel(app.UIFigure);
            app.AgeLabel.FontWeight = 'bold';
            app.AgeLabel.Position = [75 534 28 22];
            app.AgeLabel.Text = 'Age';

            % Create GenderLabel
            app.GenderLabel = uilabel(app.UIFigure);
            app.GenderLabel.FontWeight = 'bold';
            app.GenderLabel.Position = [75 493 48 22];
            app.GenderLabel.Text = 'Gender';

            % Create HeartrateLabel
            app.HeartrateLabel = uilabel(app.UIFigure);
            app.HeartrateLabel.FontWeight = 'bold';
            app.HeartrateLabel.Position = [75 452 62 22];
            app.HeartrateLabel.Text = 'Heart rate';

            % Create BreathingrateLabel
            app.BreathingrateLabel = uilabel(app.UIFigure);
            app.BreathingrateLabel.FontWeight = 'bold';
            app.BreathingrateLabel.Position = [75 410 87 22];
            app.BreathingrateLabel.Text = 'Breathing rate';

            % Create CardiachealthriskdiagnosisLabel
            app.CardiachealthriskdiagnosisLabel = uilabel(app.UIFigure);
            app.CardiachealthriskdiagnosisLabel.FontWeight = 'bold';
            app.CardiachealthriskdiagnosisLabel.Position = [75 369 172 22];
            app.CardiachealthriskdiagnosisLabel.Text = 'Cardiac health risk diagnosis';

            % Create Age
            app.Age = uieditfield(app.UIFigure, 'numeric');
            app.Age.Position = [499 534 100 22];
            app.Age.Value=age;
            

            % Create Gender
            app.Gender = uieditfield(app.UIFigure, 'text');
            app.Gender.Position = [499 493 100 22];
            app.Gender.Value=gender;

            % Create HR
            app.HR = uieditfield(app.UIFigure, 'numeric');
            app.HR.Position = [499 452 100 22];
            HR_value=round(mean_HR);
            app.HR.Value=HR_value;

            % Create BR
            app.BR = uieditfield(app.UIFigure, 'numeric');
            app.BR.Position = [499 410 100 22];
            BR_value=round(mean_BR);
            app.BR.Value=BR_value;

            % Create diagnosis
            app.diagnosis = uieditfield(app.UIFigure, 'text');
            app.diagnosis.Position = [276 369 323 22];
            app.diagnosis.Value=message;

            % Create HRV_UIAxes
            app.HRV_UIAxes = uiaxes(app.UIFigure);
            title(app.HRV_UIAxes, 'Heart rate variability')
            xlabel(app.HRV_UIAxes, 'Observations')
            ylabel(app.HRV_UIAxes, 'HR')
            app.HRV_UIAxes.Position = [11 63 300 271];
            plot(app.HRV_UIAxes,Heart_rate);

            % Create BRV_UIAxes_2
            app.BRV_UIAxes_2 = uiaxes(app.UIFigure);
            title(app.BRV_UIAxes_2, 'Breathing rate variability')
            xlabel(app.BRV_UIAxes_2, 'Observations')
            ylabel(app.BRV_UIAxes_2, 'BR')
            app.BRV_UIAxes_2.Position = [331 63 300 271];
            plot(app.BRV_UIAxes_2,breath_rate);

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.OKButton.BusyAction = 'cancel';
            app.OKButton.Position = [273 22 100 22];
            app.OKButton.Text = 'OK';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Diagnosis_report_GUI_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end