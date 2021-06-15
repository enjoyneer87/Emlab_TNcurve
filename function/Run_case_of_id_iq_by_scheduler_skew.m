function Run_case_of_id_iq_by_scheduler_skew(Input, parameter,num_case) %id, iq 별 해석
%% 변수 설정
p = Input.p;
step = Input.steps+1;
rpm = Input.base_rpm;
stack=Input.Stack*Input.Stack_Margin;
floor = Input.skew_floor;

time=120/rpm/p/6;
freq=rpm*p/120;

id_iq=Input.id_iq;
id_iq=[0 0;id_iq]; % id=0, iq=0 추가

current_path = [pwd,'/'];
current_path = strrep(current_path,'\','/');
max_jobs=Input.max_jobs_in_scheduler;

id = parameter(:,1);
iq = parameter(:,2);
%% Study 제목 Lamda로 설정


designer = actxserver('designer.Application.191');
scheduler = actxserver('scheduler.JobApplication');
% Display JMAG-Designer window
designer.Show();
app = designer;
jobApp = scheduler;
app.NewProject("Untitled");
app.Load([current_path,Input.JMAG_name_for_lamda]);
app.GetCurrentStudy().SetCurrentContour(0);
app.GetCurrentStudy().SetCurrentFluxLine(0);

app.SetCurrentStudy(0);
app.GetModel(0).GetStudy(0).SetName("Lamda");
app.View().SetCurrentCase(1);

%% 이전 해석에서 case 만든 것 제거

for i=1:length(id_iq)*floor
    app.GetModel(0).GetStudy(0).GetDesignTable().RemoveCase(length(id_iq)*floor-i);
end

%% Condition 설정
app.SetCurrentStudy(0);
app.GetModel(0).GetStudy(0).GetStep().SetValue("Step", num2str(step));                      % Step 설정
app.GetModel(0).GetStudy(0).GetStep().SetValue("StepDivision", num2str(step-1));              % division 설정
app.GetModel(0).GetStudy(0).GetStep().SetValue("EndPoint", num2str(time));         % 해석 시간 설정
app.GetModel(0).GetStudy(0).GetStudyProperties().SetValue("ModelThickness", num2str(stack))  % 적층 길이 설정
app.View().SetCurrentCase(1);

app.SetCurrentStudy(0);
app.GetModel(0).GetStudy(0).GetCondition("Motion").SetValue("AngularVelocity", num2str(rpm));      % 회전 속도 설정
app.GetModel(0).GetStudy(0).GetCircuit().GetComponent("CS1").SetValue("Frequency", num2str(freq));  % 주파수
%% Case num_case만큼 추가


app.View().SetCurrentCase(1);
app.GetModel(0).GetStudy(0).GetDesignTable().AddCases(num_case-1);


%% 각 Case에 전류 및 위상각 입력


for k=1:num_case
    app.GetModel(0).GetStudy(0).GetDesignTable().SetValue(k-1, 0, parameter(k,3));
    app.GetModel(0).GetStudy(0).GetDesignTable().SetValue(k-1, 1, parameter(k,4));
    app.GetModel(0).GetStudy(0).GetDesignTable().SetValue(k-1, 2, parameter(k,5));
end
    


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
        if mod(k, floor)==0
            app.GetDataManager().GetGraphModel("Coil Flux-Linkage").WriteTable([current_path 'Emf_Data_Skew/IdIq=0_floor' num2str(floor) '.csv']);
            disp([num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(floor) '-완료']);
        else
            app.GetDataManager().GetGraphModel("Coil Flux-Linkage").WriteTable([current_path 'Emf_Data_Skew/IdIq=0_floor' num2str(mod(k,floor)) '.csv']);
            disp([num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(mod(k,floor)) '-완료']);
        end
    else
        if mod(k, floor)==0
            app.GetDataManager().GetGraphModel("Coil Flux-Linkage").WriteTable([current_path 'IdIq_Skew/' num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(floor) '.csv']);
            disp([num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(floor) '-완료']);
        else
            app.GetDataManager().GetGraphModel("Coil Flux-Linkage").WriteTable([current_path 'IdIq_Skew//' num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(mod(k,floor)) '.csv']);
            disp([num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(mod(k,floor)) '-완료']);
        end
    end
end


