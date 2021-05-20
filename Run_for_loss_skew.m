function Run_for_loss_skew(Input,Eff_Map_i, f, total_angle)
%RUN_TN Summary of this function goes here
%   Detailed explanation goes here

p = Input.p;
step = Input.core_loss_step;
iter = Input.iter;
rpm = Eff_Map_i(1);
torque = Eff_Map_i(2);
current = Eff_Map_i(3);
phase = Eff_Map_i(4)+90;
floor=Input.skew_floor;
IronLoss_Stator = Input.Iron_condi_Stator;
IronLoss_Rotor = Input.Iron_condi_Rotor;
Motion = Input.Motion_condi;
stack=Input.Stack*Input.Stack_Margin;

current_path = [pwd '/'];
current_path = strrep(current_path,'\','/');

freq=rpm*p/120;
freq_str=num2str(freq,'%10.8f');
time = 1/freq+0.00001;
time_str=num2str(time,'%10.8f');
current_str=num2str(current,'%10.8f');
phase_str=num2str(phase,'%10.8f');
total_angle_str=num2str(total_angle, '%10.8f');
stack_str=num2str(stack,'%10.8f');

if Input.AC == 1
    JMAG_name = Input.JMAG_name_for_AC_loss;
else
    JMAG_name = Input.JMAG_name_for_loss;
end

fid = fopen('Run_for_loss_Skew.vbs','a');

fprintf(fid, '\nSet study = designer');    

fprintf(fid, ['\nCall study.Load("' current_path JMAG_name '")']);

fprintf(fid, '\nCall study.GetModel(0).GetStudy(0).DeleteResult()'); %이전결과 삭제

fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).SetName("RPM:',num2str(rpm),'/ Torque:',num2str(torque), '_',num2str(floor),'th_skew_',num2str(f),'")']);
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStep().SetValue("EndPoint",',time_str,')']);                             %해석시간

fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStep().SetValue("Step", ',num2str((step-1)*iter+1),')']);                % Step
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStep().SetValue("StepDivision",',num2str(step-1),')']);                  %division
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStudyProperties().SetValue("ModelThickness",',stack_str,')']);                    %적층 길이
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,Motion, '").SetValue("AngularVelocity",',num2str(rpm),')']);            %회전속도
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,Motion, '").SetValue("InitialRotationAngle", ',total_angle_str,')']);   %Initial angle

fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,IronLoss_Stator, '").SetValue("Poles",',num2str(p),')']);                        %철손 극수 설정
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,IronLoss_Stator, '").SetValue("RevolutionSpeed",',num2str(rpm),')']);            %철손 계산 회전속도
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,IronLoss_Stator, '").SetValue("HysteresisLossCalcType", 1)']);                   %철손 계산방식 (FFT)
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,IronLoss_Stator, '").SetValue("EndReferenceStep", ',num2str((step-1)*iter+1),')']);                   %철손 step 설정

fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,IronLoss_Rotor, '").SetValue("Poles",',num2str(p),')']);                        %철손 극수 설정
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,IronLoss_Rotor, '").SetValue("RevolutionSpeed",',num2str(rpm),')']);            %철손 계산 회전속도
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,IronLoss_Rotor, '").SetValue("HysteresisLossCalcType", 1)']);                   %철손 계산방식 (FFT)
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,IronLoss_Rotor, '").SetValue("EndReferenceStep", ',num2str((step-1)*iter+1),')']);                   %철손 step 설정

fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("Amplitude",',current_str,')']);  %전류크기
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("Frequency",',freq_str,')']);     %주파수
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("PhaseU",',phase_str,')']);       %위상각
   
fprintf(fid, '\nCall study.GetModel(0).GetStudy(0).Run()');

fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("LineCurrent")');
fprintf(fid, ['\nCall tabledata.WriteTable("' ,current_path, 'Current_Data_Skew/' ,num2str(rpm), '_' ,num2str(torque), '_',num2str(floor),'th_skew_' ,num2str(f), '.csv", "Time")']);

fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("TerminalVoltage")');
fprintf(fid, ['\nCall tabledata.WriteTable("' ,current_path, 'Voltage_Data_Skew/' ,num2str(rpm), '_' ,num2str(torque), '_',num2str(floor),'th_skew_' ,num2str(f), '.csv", "Time")']);

fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("Torque")');
fprintf(fid, ['\nCall tabledata.WriteTable("' ,current_path, 'Torque_Data_Skew/' ,num2str(rpm), '_' ,num2str(torque), '_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv", "Time")']);

if Input.AC == 1
    fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("FEMConductorFlux")');
    fprintf(fid, ['\nCall tabledata.WriteTable("' ,current_path, 'Flux_Data_Skew/' ,num2str(rpm), '_' ,num2str(torque), '_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv", "Time")']);
    fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("JouleLoss")');
    fprintf(fid, ['\nCall tabledata.WriteTable("' ,current_path, 'Joule_Loss_Data_Skew/' ,num2str(rpm), '_' ,num2str(torque), '_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv", "Time")']);
else
    fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("FEMCoilFlux")');
    fprintf(fid, ['\nCall tabledata.WriteTable("' ,current_path, 'Flux_Data_Skew/' ,num2str(rpm), '_' ,num2str(torque), '_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv", "Time")']);
end

fprintf(fid, '\nCall study.SetCurrentStudy(0)');
fprintf(fid, '\nSet ref1 = study.GetDataManager().GetDataSet("Iron Loss (Iron loss)")');
fprintf(fid, '\nCall study.GetDataManager().CreateGraphModel(ref1)');
fprintf(fid, ['\nCall study.GetDataManager().GetGraphModel("Iron Loss (Iron loss)").WriteTable("' ,current_path, 'Core_Loss_Data_Skew/' ,num2str(rpm), '_' ,num2str(torque), '_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv")']);

fprintf(fid, '\nSet ref1 = study.GetDataManager().GetDataSet("Hysteresis Loss (Iron loss)")');
fprintf(fid, '\nCall study.GetDataManager().CreateGraphModel(ref1)');
fprintf(fid, ['\nCall study.GetDataManager().GetGraphModel("Hysteresis Loss (Iron loss)").WriteTable("' ,current_path, 'Hysteresis_Loss_Data_Skew/' ,num2str(rpm), '_' ,num2str(torque), '_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv")']);

fprintf(fid, '\nSet ref1 = study.GetDataManager().GetDataSet("Joule Loss (Iron loss)")');
fprintf(fid, '\nCall study.GetDataManager().CreateGraphModel(ref1)');
fprintf(fid, ['\nCall study.GetDataManager().GetGraphModel("Joule Loss (Iron loss)").WriteTable("' ,current_path, 'Eddy_Loss_Data_Skew/' ,num2str(rpm), '_' ,num2str(torque), '_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv")']);
fprintf(fid,'\nCall study.Save()');

fprintf(fid,'\nCall study.quit');

fclose(fid);
end

