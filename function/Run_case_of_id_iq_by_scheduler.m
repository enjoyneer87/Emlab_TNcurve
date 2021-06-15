function Run_case_of_id_iq_by_scheduler(Input,idiq_scheduler,num_case) %id, iq 별 해석
%% 변수 설정
%초안 by 노시헌, KDH 주석 추가 , 리뷰 
p = Input.p;  % 기존 Run_for_lamda
step = Input.steps+1; % 기존 Run_for_lamda
rpm = Input.base_rpm; % base rpm 정의, % make_vbs_for_lamda
ini_angle=Input.initial_angle; % 기존 Run_for_lamda
stack=Input.Stack*Input.Stack_Margin; % 기존 Run_for_lamda
turn = Input.turn; %추가기능

time=120/rpm/p/6;  % 기존 Run_for_lamda
freq=rpm*p/120;    % 기존 Run_for_lamda

i_d = idiq_scheduler(:,1); % make_vbs_for_lamda
i_q = idiq_scheduler(:,2); % make_vbs_for_lamda
max_jobs=Input.max_jobs_in_scheduler;  %main에서 가져온 max_jobs_in_scheduler 추가기능

current_path = [pwd '/']; % 기존 Run_for_lamda
current_path = strrep(current_path,'\','/'); % 기존 Run_for_lamda

%% Study 제목 Lamda로 설정 
%얘를 버전별로 맞추기 위해 function으로 바꾸는게 어떨까?

designer = actxserver('designer.Application.200'); %추가기능, 주경 code에서 가져온듯
scheduler = actxserver('scheduler.JobApplication'); %추가기능, 주경 code에서 가져온듯

%%

% Display JMAG-Designer window
designer.Show();
app = designer;  
jobApp = scheduler; 

app.NewProject("Untitled");
app.Load([current_path,Input.JMAG_name_for_lamda]); % 기존 Run_for_lamda
app.GetCurrentStudy().SetCurrentContour(0);
app.GetCurrentStudy().SetCurrentFluxLine(0);


app.SetCurrentStudy(0);  % 기존 Run_for_lamda
app.GetModel(0).GetStudy(0).SetName("Lamda");  % 기존 Run_for_lamda
app.View().SetCurrentCase(1);

%% 이전 해석에서 case 만든 것 제거

% case 쌓이는게 무거워서 지우는건가?

for i=1:num_case 
    app.GetModel(0).GetStudy(0).GetDesignTable().RemoveCase(length(id_iq)-i);
end
%id_iq 변수없는데?

%% Condition 설정

app.SetCurrentStudy(0);  % 기존 Run_for_lamda
%app.GetModel(0).GetStudy(0).DeleteResult() %이전 결과 삭제하는게 낫지않나

app.GetModel(0).GetStudy(0).GetStep().SetValue("Step", num2str(step));                      % Step 설정 % 기존 Run_for_lamda
app.GetModel(0).GetStudy(0).GetStep().SetValue("StepDivision", num2str(step-1));              % division 설정% 기존 Run_for_lamda
app.GetModel(0).GetStudy(0).GetStep().SetValue("EndPoint", num2str(time));         % 해석 시간 설정 % 기존 Run_for_lamda
app.GetModel(0).GetStudy(0).GetStudyProperties().SetValue("ModelThickness", num2str(stack))  % 적층 길이 설정 % 기존 Run_for_lamda
app.View().SetCurrentCase(1); %? 이건 왜

app.SetCurrentStudy(0);  %응?
app.GetModel(0).GetStudy(0).GetCondition("Motion").SetValue("AngularVelocity", num2str(rpm));      % 회전 속도 설정 % 기존 Run_for_lamda
app.GetModel(0).GetStudy(0).GetCondition("Motion").SetValue("InitialRotationAngle", num2str(ini_angle));   % Initial Angle 설정 % 기존 Run_for_lamda
app.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("Frequency", num2str(freq));  % 주파수 % 기존 Run_for_lamda

%% Case num_case만큼 추가
%굿굿

app.View().SetCurrentCase(1);
app.GetModel(0).GetStudy(0).GetDesignTable().AddCases(num_case-1);


%% 각 Case에 전류 및 위상각 입력
% 굿굿, 이거 분리한거는 잘한듯
%%기존에 Make_for_vbs에서 for문으로 -> run_for_vbs으로 control

for k=1:num_case
    current = sqrt(i_d(k)^2+i_q(k)^2);
    phase = atan2(i_q(k),i_d(k))*180/pi+360*(i_q(k)<0)+90;
    app.GetModel(0).GetStudy(0).GetDesignTable().SetValue(k-1, 0, current); %GetdesignTable?? 함수
    app.GetModel(0).GetStudy(0).GetDesignTable().SetValue(k-1, 1, phase);
    app.GetModel(0).GetStudy(0).GetDesignTable().SetValue(k-1, 2, Input.initial_angle);
end
    %한번에 designtable을 만드나 보네


%% 모든 Case Scheduler에 넘기기


app.SetCurrentStudy(0); 
app.Save();
job = app.GetModel(0).GetStudy(0).CreateJob(); 
job.SetValue("Title", "Lamda");
job.SetValue("Queued", true);
job.Submit(true);
jobApp.SetMaxJobs(max_jobs);


%% Scheduler에 남은 결과 Study로 넘긴 후 csv 파일 저장

while 1
    if jobApp.UnfinishedJobs() == 0
        break;
    end
    pause(3);
end

app.SetCurrentStudy(0);
app.GetModel(0).GetStudy(0).CheckForNewResults();

for k=1:num_case
    app.View().SetCurrentCase(k);
    if k==1
        app.GetDataManager().GetGraphModel("Coil Flux-Linkage").WriteTable([current_path 'Emf_Data/IdIq=0.csv']);
    else
        app.GetDataManager().GetGraphModel("Coil Flux-Linkage").WriteTable([current_path 'IdIq/',num2str(i_d(k)),'_',num2str(i_q(k)),'.csv']);
        disp([num2str(i_d(k)),'_',num2str(i_q(k)),'-완료']);
    end
end

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    