classdef Blood_pressure_output_GUI_exported_final < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        BloodpressurereportLabel     matlab.ui.control.Label
        AgeLabel                     matlab.ui.control.Label
        GenderLabel                  matlab.ui.control.Label
        HeartrateLabel               matlab.ui.control.Label
        BreathingrateLabel           matlab.ui.control.Label
        SystolicbloodpressureLabel   matlab.ui.control.Label
        Age                          matlab.ui.control.NumericEditField
        HR                           matlab.ui.control.NumericEditField
        BR                           matlab.ui.control.NumericEditField
        diagnosis                    matlab.ui.control.NumericEditField
        OKButton                     matlab.ui.control.Button
        DiastolicbloodpressureLabel  matlab.ui.control.Label
        diagnosis_2                  matlab.ui.control.NumericEditField
        BloodpressurecategoryLabel   matlab.ui.control.Label
        EditField                    matlab.ui.control.EditField
        EditField_2                  matlab.ui.control.EditField
        BMILabel                     matlab.ui.control.Label
        BMI                          matlab.ui.control.NumericEditField
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
            
            prompt = {'Enter age:','Enter gender:','Enter height (cm):','Enter weight (kg):'};
            dlgtitle = 'Input details';
            dims = [1 35];
            definput = {'0','1','2','None'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            age=str2num(cell2mat(answer(1,1)));
            gender=cell2mat(answer(2,1));
            height=str2num(cell2mat(answer(3,1)));
            weight=str2num(cell2mat(answer(4,1)));
            
            [BMI_out,Heart_rate,Breathing_rate,SBP,DBP,message]=BP_test;
            

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.902 0.902 0.902];
            app.UIFigure.Position = [100 100 641 631];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.Scrollable = 'on';

            % Create BloodpressurereportLabel
            app.BloodpressurereportLabel = uilabel(app.UIFigure);
            app.BloodpressurereportLabel.HorizontalAlignment = 'center';
            app.BloodpressurereportLabel.FontName = 'Times New Roman';
            app.BloodpressurereportLabel.FontSize = 14;
            app.BloodpressurereportLabel.FontWeight = 'bold';
            app.BloodpressurereportLabel.Position = [122 567 373 32];
            app.BloodpressurereportLabel.Text = 'Blood pressure report';

            % Create AgeLabel
            app.AgeLabel = uilabel(app.UIFigure);
            app.AgeLabel.FontName = 'Times New Roman';
            app.AgeLabel.FontSize = 14;
            app.AgeLabel.FontWeight = 'bold';
            app.AgeLabel.Position = [75 522 72 34];
            app.AgeLabel.Text = 'Age';

            % Create GenderLabel
            app.GenderLabel = uilabel(app.UIFigure);
            app.GenderLabel.FontName = 'Times New Roman';
            app.GenderLabel.FontSize = 14;
            app.GenderLabel.FontWeight = 'bold';
            app.GenderLabel.Position = [75 479 112 31];
            app.GenderLabel.Text = 'Gender';

            % Create HeartrateLabel
            app.HeartrateLabel = uilabel(app.UIFigure);
            app.HeartrateLabel.FontName = 'Times New Roman';
            app.HeartrateLabel.FontSize = 14;
            app.HeartrateLabel.FontWeight = 'bold';
            app.HeartrateLabel.Position = [75 384 131 32];
            app.HeartrateLabel.Text = 'Heart rate';

            % Create BreathingrateLabel
            app.BreathingrateLabel = uilabel(app.UIFigure);
            app.BreathingrateLabel.FontName = 'Times New Roman';
            app.BreathingrateLabel.FontSize = 14;
            app.BreathingrateLabel.FontWeight = 'bold';
            app.BreathingrateLabel.Position = [75 334 144 30];
            app.BreathingrateLabel.Text = 'Breathing rate';

            % Create SystolicbloodpressureLabel
            app.SystolicbloodpressureLabel = uilabel(app.UIFigure);
            app.SystolicbloodpressureLabel.FontName = 'Times New Roman';
            app.SystolicbloodpressureLabel.FontSize = 14;
            app.SystolicbloodpressureLabel.FontWeight = 'bold';
            app.SystolicbloodpressureLabel.Position = [75 285 161 37];
            app.SystolicbloodpressureLabel.Text = 'Systolic blood pressure';

            % Create Age
            app.Age = uieditfield(app.UIFigure, 'numeric');
            app.Age.FontName = 'Times New Roman';
            app.Age.FontSize = 14;
            app.Age.Position = [551 522 48 34];
            app.Age.Value=age;

            % Create HR
            app.HR = uieditfield(app.UIFigure, 'numeric');
            app.HR.FontName = 'Times New Roman';
            app.HR.FontSize = 14;
            app.HR.Position = [560 384 39 32];
            app.HR.Value=Heart_rate;

            % Create BR
            app.BR = uieditfield(app.UIFigure, 'numeric');
            app.BR.FontName = 'Times New Roman';
            app.BR.FontSize = 14;
            app.BR.Position = [560 334 39 30];
            app.BR.Value=Breathing_rate;

            % Create diagnosis
            app.diagnosis = uieditfield(app.UIFigure, 'numeric');
            app.diagnosis.HorizontalAlignment = 'right';
            app.diagnosis.FontName = 'Times New Roman';
            app.diagnosis.FontSize = 14;
            app.diagnosis.Position = [560 290 39 27];
            app.diagnosis.Value=SBP;

            % Create OKButton
            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @OKButtonPushed, true);
            app.OKButton.BusyAction = 'cancel';
            app.OKButton.FontName = 'Times New Roman';
            app.OKButton.FontSize = 14;
            app.OKButton.Position = [273 20 100 24];
            app.OKButton.Text = 'OK';

            % Create DiastolicbloodpressureLabel
            app.DiastolicbloodpressureLabel = uilabel(app.UIFigure);
            app.DiastolicbloodpressureLabel.FontName = 'Times New Roman';
            app.DiastolicbloodpressureLabel.FontSize = 14;
            app.DiastolicbloodpressureLabel.FontWeight = 'bold';
            app.DiastolicbloodpressureLabel.Position = [75 224 199 62];
            app.DiastolicbloodpressureLabel.Text = 'Diastolic blood pressure';

            % Create diagnosis_2
            app.diagnosis_2 = uieditfield(app.UIFigure, 'numeric');
            app.diagnosis_2.HorizontalAlignment = 'right';
            app.diagnosis_2.FontName = 'Times New Roman';
            app.diagnosis_2.FontSize = 14;
            app.diagnosis_2.Position = [560 242 39 27];
            app.diagnosis_2.Value=DBP;

            % Create BloodpressurecategoryLabel
            app.BloodpressurecategoryLabel = uilabel(app.UIFigure);
            app.BloodpressurecategoryLabel.FontName = 'Times New Roman';
            app.BloodpressurecategoryLabel.FontSize = 14;
            app.BloodpressurecategoryLabel.FontWeight = 'bold';
            app.BloodpressurecategoryLabel.Position = [75 168 199 62];
            app.BloodpressurecategoryLabel.Text = 'Blood pressure category';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'text');
            app.EditField.HorizontalAlignment = 'center';
            app.EditField.FontName = 'Times New Roman';
            app.EditField.FontSize = 14;
            app.EditField.Position = [530 483 100 22];
            app.EditField.Value=gender;

            % Create EditField_2
            app.EditField_2 = uieditfield(app.UIFigure, 'text');
            app.EditField_2.HorizontalAlignment = 'center';
            app.EditField_2.FontName = 'Times New Roman';
            app.EditField_2.FontSize = 14;
            app.EditField_2.Position = [301 188 329 22];
            app.EditField_2.Value= message;

            % Create BMILabel
            app.BMILabel = uilabel(app.UIFigure);
            app.BMILabel.FontName = 'Times New Roman';
            app.BMILabel.FontSize = 14;
            app.BMILabel.FontWeight = 'bold';
            app.BMILabel.Position = [75 430 131 32];
            app.BMILabel.Text = 'BMI';

            % Create BMI
            app.BMI = uieditfield(app.UIFigure, 'numeric');
            app.BMI.FontName = 'Times New Roman';
            app.BMI.FontSize = 14;
            app.BMI.Position = [561 430 39 32];
            app.BMI.Value=BMI_out;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Blood_pressure_output_GUI_exported_final

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