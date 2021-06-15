function [Lamda_fd] = get_emf(Input)

disp('No_Load 해석 시작');

skew=Input.skew;           % Skew On-Off 정의
floor=Input.skew_floor;    % Skew 단수 정의
angle=Input.initial_angle; % Initial Angle 정의
skew_angle=Input.skew_angle;  % Skew 적용할 각도
total_angle=[];

if skew==0
    
    if isfile(['Emf_Data\Emf', num2str(Input.base_rpm), '.csv'])==1
        disp('EMF 해석 DATA 존재');
    else
        disp('EMF 해석 시작');
        Run_for_emf;
        disp('EMF 해석 완료');
    end
    
    f_name_Lamda = ['Emf_Data\Lamda_fd@', num2str(Input.base_rpm), '.csv'];
    Lamda_fd = Lamda_dq_trans(Input, f_name_Lamda);
    
else
    
    if isfile(['Emf_Data_Skew\Emf', num2str(Input.base_rpm), '.csv'])==1
        disp('EMF Skew 해석 DATA 존재');
    else
        disp('EMF Skew 해석 시작');
        Run_for_emf_skew;
        disp('EMF Skew 해석 완료');
    end
    
    f_name_Lamda = ['Emf_Data_Skew\Lamda_fd@', num2str(Input.base_rpm), '.csv'];
    Lamda_fd = Lamda_dq_trans(Input, f_name_Lamda);