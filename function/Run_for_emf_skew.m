function Run_for_emf_skew(Input, f, total_angle)

current_path = [pwd '/'];
current_path = strrep(current_path,'\','/');

p = Input.p;
step = Input.steps+1;
rpm = Input.base_rpm;
time=120/rpm/p/6;
floor=Input.skew_floor;
total_angle_str=num2str(total_angle, '%10.8f');
Motion = Input.Motion_condi;
stack=Input.Stack*Input.Stack_Margin;

stack_str=num2str(stack,'%10.8f');

fid = fopen('Run_for_emf_skew.vbs','a');

fprintf(fid, '\nSet study = designer');    
fprintf(fid, ['\nCall study.Load("' current_path Input.JMAG_name_for_lamda '")']);                    
fprintf(fid, '\nCall study.GetModel(0).GetStudy(1).DeleteResult()'); %������� ����
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).SetName("EMF@',num2str(rpm),'_',num2str(floor),'th_skew_',num2str(f),'")']);
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetStep().SetValue("EndPoint",',num2str(time),')']);                                    %�ؼ��ð�
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetStep().SetValue("Step", ',num2str(6*(step-1) + 1),')']);                             %step
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetStep().SetValue("StepDivision",',num2str(step-1),')']);                              %division
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetStudyProperties().SetValue("ModelThickness",',stack_str,')']);                                 %���� ����
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetCondition("' ,Motion, '").SetValue("AngularVelocity",',num2str(rpm),')']);           %ȸ���ӵ�
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetCondition("' ,Motion, '").SetValue("InitialRotationAngle", ',total_angle_str,')']);  %�ʱⰢ ����
   
fprintf(fid, '\nCall study.GetModel(0).GetStudy(1).Run()');
 
fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(1).GetResultTable().GetData("TerminalVoltage")');
fprintf(fid, ['\nCall tabledata.WriteTable("' current_path 'Emf_Data_Skew/Emf@' ,num2str(rpm), '_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv", "Time")']);

fprintf(fid,'\nCall study.Save()');

fprintf(fid,'\nCall study.quit');

fclose(fid);