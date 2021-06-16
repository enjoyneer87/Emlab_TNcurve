function in_power=trans_fun(Input)

skew=Input.skew;
floor=Input.skew_floor;    % Skew 단수 정의

id_iq=Input.id_iq;

i_d = id_iq(:,1);
i_q = id_iq(:,2);

%% Output 폴더의 csv 파일 정리

if (skew==0)   % Skew 미적용 시 데이터 맵 구축

  %  이미 in_power 데이터가 존재할 경우 읽어드리고 바로 함수종료
    disp('lamda d-q 변환 시작');
    
    if exist('Output\in_power.csv','file')
        in_power = csvread('Output\in_power.csv',1,0);
        disp('in_power.csv - 존재');
        disp('lamda d-q 변환 완료');
        disp(' ');
        return;
    end


    ang=(0:Input.torque_ripple/Input.steps:Input.torque_ripple-Input.torque_ripple/Input.steps)'; % 토크리플 간격
    e_ang=ang*(pi/180)*Input.p/2;                                                                 % 전기각 변경


    in_power = [];

    for k=1:length(id_iq)
    
        num = [num2str(i_d(k)) '_' num2str(i_q(k))];      % 파일 번호
    
        f_name=['IdIq\' num '.csv'];            % 파일이름 지정

        data =  xlsread(f_name);
        v=data(1:Input.steps,:);               % 필요한 부분 추출

        if Input.mode_w == -1      %U-W-V
            lamda_d=(2/3)*(v(:,2).*cos(e_ang)+v(:,3).*cos(e_ang-(2/3)*pi)+v(:,4).*cos(e_ang+(2/3)*pi));
            lamda_q=(2/3)*(-v(:,2).*sin(e_ang)-v(:,3).*sin(e_ang-(2/3)*pi)-v(:,4).*sin(e_ang+(2/3)*pi));
        else                     %U-V-W
            lamda_d=(2/3)*(v(:,2).*cos(e_ang)+v(:,4).*cos(e_ang-(2/3)*pi)+v(:,3).*cos(e_ang+(2/3)*pi));
            lamda_q=(2/3)*(-v(:,2).*sin(e_ang)-v(:,4).*sin(e_ang-(2/3)*pi)-v(:,3).*sin(e_ang+(2/3)*pi));
        end      
    
        lamda_d_ave=mean(lamda_d);
        lamda_q_ave=mean(lamda_q);        

        w=[i_d(k) i_q(k) lamda_d_ave lamda_q_ave];
    
        in_power=[in_power; w];
    
    
        headers = {'Id','Iq','Lamda_d','Lamda_q'};
        csvwrite_with_headers('Output\in_power.csv',in_power,headers);
    end
    disp('in_power.csv - write');
    disp('lamda d-q 변환 완료');
    disp(' ');

else    % Skew 적용 시의 데이터 맵 구축
    
  %  이미 in_power 데이터가 존재할 경우 읽어드리고 바로 함수종료
    disp('lamda_skew d-q 변환 시작');
    if exist('Output\in_power_skew.csv','file')
        in_power = csvread('Output\in_power_skew.csv',1,0);
        disp('in_power_skew.csv - read');
        disp('lamda_skew d-q 변환 완료');
        disp(' ');
        return;
    end

    ang=(0:Input.torque_ripple/Input.steps:Input.torque_ripple-Input.torque_ripple/Input.steps)'; % 토크리플 간격
    e_ang=ang*(pi/180)*Input.p/2;                                                                 % 전기각 변경

    for kk=1:length(id_iq)  % Skew 해석한 데이터를 평균 취하여 계산
        coil1=zeros(21,1);
        coil2=zeros(21,1);
        coil3=zeros(21,1);
        coil=[];
        time=[];
    
        for f=1:1:floor
            f_name=['IdIq_Skew/',num2str(i_d(kk)),'_',num2str(i_q(kk)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
            fid_f=fopen(f_name,'r');
            data =  textscan(fid_f,'"%f","%f","%f","%f"','headerlines',2);  
            f_data = cell2mat(data);                   % 엑셀파일로부터 불러온 데이터를 셀로부터 행렬로 변경
            time=f_data(:,1);
            coil1=coil1+f_data(:,2)/floor;
            coil2=coil2+f_data(:,3)/floor;
            coil3=coil3+f_data(:,4)/floor;
            fclose(fid_f);
        end
    
        coil=[time coil1 coil2 coil3];
        headers = {'Time' 'Coil1' 'Coil2' 'Coil3'};
        f_name_skew=['IdIq_Skew\',num2str(i_d(kk)),'_',num2str(i_q(kk)),'.csv'];
        csvwrite_with_headers(f_name_skew,coil,headers);
    
    end

    in_power_skew = [];

    for k=1:length(id_iq)
    
        num = [num2str(i_d(k)) '_' num2str(i_q(k))];      % 파일 번호
        f_name=['IdIq_Skew\', num, '.csv'];            % 파일이름 지정                

        data=csvread(f_name,1,0);
        v=data(1:Input.steps,:);               % 필요한 부분 추출

        if Input.mode_w == -1      %U-W-V
            lamda_d=(2/3)*(v(:,2).*cos(e_ang)+v(:,3).*cos(e_ang-(2/3)*pi)+v(:,4).*cos(e_ang+(2/3)*pi));
            lamda_q=(2/3)*(-v(:,2).*sin(e_ang)-v(:,3).*sin(e_ang-(2/3)*pi)-v(:,4).*sin(e_ang+(2/3)*pi));
        else                     %U-V-W
            lamda_d=(2/3)*(v(:,2).*cos(e_ang)+v(:,4).*cos(e_ang-(2/3)*pi)+v(:,3).*cos(e_ang+(2/3)*pi));
            lamda_q=(2/3)*(-v(:,2).*sin(e_ang)-v(:,4).*sin(e_ang-(2/3)*pi)-v(:,3).*sin(e_ang+(2/3)*pi));
        end      
    
        lamda_d_ave=mean(lamda_d);
        lamda_q_ave=mean(lamda_q);        

        w=[i_d(k) i_q(k) lamda_d_ave lamda_q_ave];
    
        in_power_skew=[in_power_skew; w];
    
    end

    headers = {'Id','Iq','Lamda_d','Lamda_q'};
    csvwrite_with_headers('Output\in_power_skew.csv',in_power_skew,headers);
    disp('in_power_skew.csv - write');
    disp('lamda_skew d-q 변환 완료');
    disp(' ');
    
    in_power=in_power_skew;        % in_power 변수를 전역변수로 전체에서 사용하기 위한 정의 / skew 미적용,적용시 모두 같은 변수로 씀

end
