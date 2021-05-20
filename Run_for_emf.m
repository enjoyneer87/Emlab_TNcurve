function Run_for_emf(Input)

current_path = [pwd '/'];
current_path = strrep(current_path,'\','/');

p = Input.p;
step = Input.steps+1;
rpm = Input.base_rpm;
time=120/rpm/p/6;
Motion = Input.Motion_condi;
ini_angle=Input.initial_angle;
stack=Input.Stack*Input.Stack_Margin;

ini_angle_str=num2str(ini_angle, '%10.8f');
stack_str=num2str(stack,'%10.8f');

fid = fopen('Run_for_emf.vbs','a');

fprintf(fid, '\nSet study = designer');    
fprintf(fid, ['\nCall study.Load("' current_path Input.JMAG_name_for_lamda '")']);                    
fprintf(fid, '\nCall study.GetModel(0).GetStudy(1).DeleteResult()'); %이전결과 삭제
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).SetName("EMF@',num2str(rpm),'")']);
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetStep().SetValue("EndPoint",',num2str(time),')']);                                %해석시간
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetStep().SetValue("Step", ',num2str(6*(step-1) + 1),')']);                         %step
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetStep().SetValue("StepDivision",',num2str(step-1),')']);                          % division
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetStudyProperties().SetValue("ModelThickness",',stack_str,')']);                             %적층 길이
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetCondition("' ,Motion, '").SetValue("AngularVelocity",',num2str(rpm),')']);       %회전속도
fprintf(fid, ['\nCall study.GetModel(0).GetStudy(1).GetCondition("' ,Motion, '").SetValue("InitialRotationAngle", ',ini_angle_str,')']);  %초기각 설정
   
fprintf(fid, '\nCall study.GetModel(0).GetStudy(1).Run()');
 
fprintf(fid, '\nSet tabledata = study.GetModel(0).GetStudy(1).GetResultTable().GetData("TerminalVoltage")');
fprintf(fid, ['\nCall tabledata.WriteTable("' current_path 'Emf_Data/Emf@' ,num2str(rpm), '.csv", "Time")']);

fprintf(fid,'\nCall study.Save()');

fprintf(fid,'\nCall study.quit');

fclose(fid);