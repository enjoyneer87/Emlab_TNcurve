function get_result_by_lamda_schedule(Input)
disp('Get_Result_for_Lamda Start');

p = Input.p;
rpm = Input.base_rpm;
floor = Input.skew_floor;
angle=Input.initial_angle;
skew_angle=Input.skew_angle;

skew=Input.skew;           % Skew On-Off 정의
id_iq=Input.id_iq;
num_case=0; % Scheduler에 들어가는 case 횟수
idiq_scheduler =[];
new_parameter = [];

time=120/rpm/p/6;
freq=rpm*p/120;

id_iq=[0 0;id_iq]; % id=0, iq=0 추가

if (skew==0)   
    i_d = id_iq(:,1);
    i_q = id_iq(:,2);
    
    for i=1:length(id_iq)                                                           % 파일 존재 여부 확인 및 해석 지점 저장
        a = readmatrix(['IdIq\' num2str(i_d(i)) '_' num2str(i_q(i)) '.csv']);
        if isfile(['IdIq\' num2str(i_d(i)) '_' num2str(i_q(i)) '.csv'])==1
            if length(a)==step
                disp([num2str(i_d(i)) '_' num2str(i_q(i)) '.csv - 존재']);
                continue;
            else
                num_case = num_case+1;
                idiq_scheduler = [idiq_scheduler;i_d(i) i_q(i)];
                disp([num2str(i_d(i)) '_' num2str(i_q(i)) '.csv - 중간에 해석 끊김, 해석 필요']);
            end
        else
            num_case = num_case+1;
            idiq_scheduler = [idiq_scheduler;i_d(i) i_q(i)];
            disp([num2str(i_d(i)) '_' num2str(i_q(i)) '.csv - 해석 필요']);
        end
    end
    
    if num_case==0
        disp('모든 id iq에 대한 해석 완료');
    elseif num_case==length(id_iq)
        disp('id iq 별 해석 시작');
        Run_case_of_id_iq_by_scheduler(Input,id_iq,length(id_iq)); %% Scheduler로 모든 Case 해석 및 csv 파일로 저장
    else
        disp([num2str(num_case) '/' num2str(length(id_iq)) '다시 해석 필요']);
        disp('csv 파일 없는 운전점 해석 시작');
        Run_case_of_id_iq_by_scheduler(Input,idiq_scheduler,num_case);
    end
            
else
    for k=1:length(id_iq)*floor
        
        interval=skew_angle/floor;
        
        if mod(k,floor)==0
            total_angle(k,1)=angle-(skew_angle-interval)/2+interval*(floor-1);
            id(k,1) = id_iq(k/floor,1);
            iq(k,1) = id_iq(k/floor,2);
        else
            total_angle(k,1)=angle-(skew_angle-interval)/2+interval*(mod(k,floor)-1);
            id(k,1) = id_iq((k-mod(k,floor))/floor+1,1);
            iq(k,1) = id_iq((k-mod(k,floor))/floor+1,2);
        end
        
        current(k,1) = sqrt(id(k,1)^2+iq(k,1)^2);
        phase(k,1) = atan2(iq(k,1),id(k,1))*180/pi+360*(iq(k,1)<0)+90;
        
        parameter=[id iq current phase total_angle];
    end
    
    
    for k=1:length(parameter)
        a = readmatrix(['IdIq_skew\' num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(floor) '.csv']);
        
        if mod(k,floor)==0
            if isfile(['IdIq_skew\' num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(floor) '.csv'])==1
                if length(a) == step
                    disp([num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(floor) '.csv - 존재']);
                    continue;
                else
                    num_case = num_case+1;
                    new_parameter = [new_parameter;parameter(k,:)];
                    disp([num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(floor) '.csv - 중간에 해석 끊김, 해석 필요']);
                end
            else
                num_case = num_case+1;
                new_parameter = [new_parameter;parameter(k,:)];
                disp([num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(floor) '.csv - 해석 필요']);
            end
        else
            if isfile(['IdIq_skew\' num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(mod(k,floor)) '.csv'])==1
                disp([num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(mod(k,floor)) '.csv - 존재']);
                continue;
            else
                num_case = num_case+1;
                new_parameter = [new_parameter;parameter(k,:)];
                disp([num2str(id(k)) '_' num2str(iq(k)) '_' num2str(floor) '_skew_' num2str(mod(k,floor)) '.csv -  해석 필요']);
            end
        end
    end
    
     if num_case==0
        disp('모든 id iq에 대한 해석 완료');
    elseif num_case==length(parameter)
        disp('id iq 별 해석 시작');
        Run_case_of_id_iq_by_scheduler_skew(Input, parameter,length(parameter));
    else
        disp([num2str(num_case) '/' num2str(length(parameter)) '다시 해석 필요']);
        disp('csv 파일 없는 운전점 해석 시작');
        Run_case_of_id_iq_by_scheduler_skew(Input, new_parameter,num_case);
     end
end
            
            