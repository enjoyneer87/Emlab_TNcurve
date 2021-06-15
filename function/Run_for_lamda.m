function Run_for_lamda(Input,i_d,i_q)
%RUN_TN Summary of this function goes here
%   Detailed explanation goes here

p = Input.p;
step = Input.steps+1;
rpm = Input.base_rpm;
Motion = Input.Motion_condi;
current = sqrt(i_d^2+i_q^2);
ini_angle=Input.initial_angle; % Initial Angle ����
stack=Input.Stack*Input.Stack_Margin;

if (current==0)
    phase=0;    % Lambda_fd ������ ���� ���
else    
    phase = atan2(i_q,i_d)*180/pi+360*(i_q<0)+90;   % IdIq ���� ���� ���
end

% num_core = Input.JMAG_num_core;

current_path = [pwd '/'];
current_path = strrep(current_path,'\','/');

time=120/rpm/p/6;
time_str=num2str(time,'%10.8f');     % fprintf ������ str���� ��ȯ�ؼ� �̿��ؾ� ��
freq=rpm*p/120;
freq_str=num2str(freq,'%10.8f');
current_str=num2str(current,'%10.8f');
phase_str=num2str(phase,'%10.8f');
ini_angle_str=num2str(ini_angle, '%10.8f');
stack_str=num2str(stack,'%10.8f');

fid = fopen('Run_for_lamda.vbs','a');

fprintf(fid, '\nSet study = designer');    
fprintf(fid, ['\nCall study.Load("' current_path Input.JMAG_name_for_lamda '")']);                    
fprintf(fid, '\nCall study.GetModel(0).GetStudy(0).DeleteResult()'); %������� ����
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).SetName("i_d:',num2str(i_d),'/ i_q:',num2str(i_q),'")']);
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStep().SetValue("EndPoint",',time_str,')']);                             %�ؼ��ð�
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStep().SetValue("Step", ',num2str(step),')']);                           %step
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStep().SetValue("StepDivision",',num2str(step-1),')']);                  %division
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetStudyProperties().SetValue("ModelThickness",',stack_str,')']);                      %���� ����
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,Motion, '").SetValue("AngularVelocity",',num2str(rpm),')']);            %ȸ���ӵ�
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCondition("' ,Motion, '").SetValue("InitialRotationAngle", ',ini_angle_str,')']);   %Initial angle   
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("Amplitude",',current_str,')']);  %����ũ��
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("Frequency",',freq_str,')']);     %���ļ�
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("PhaseU",',phase_str,')']);       %����
   
fprintf(fid, '\nCall study.GetModel(0).GetStudy(0).Run()');
 
if (current==0)
    fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("FEMCoilFlux")');
    fprintf(fid, ['\nCall tabledata.WriteTable("' current_path 'Emf_Data/Lamda_fd@' num2str(rpm) '.csv", "Time")']);
else
    fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(0).GetResultTable().GetData("FEMCoilFlux")');
    fprintf(fid, ['\nCall tabledata.WriteTable("' current_path 'IdIq/' num2str(i_d) '_' num2str(i_q) '.csv", "Time")']);
end

fprintf(fid,'\nCall study.Save()');

fprintf(fid,'\nCall study.quit');

fclose(fid);      

end

