function [Lamda_fd] = make_vbs_for_emf(Input)

disp('No_Load �ؼ� ����');

skew=Input.skew;           % Skew On-Off ����
floor=Input.skew_floor;    % Skew �ܼ� ����
angle=Input.initial_angle; % Initial Angle ����
skew_angle=Input.skew_angle;  % Skew ������ ����
total_angle=[];

if skew == 0

    f_name = ['Emf_Data\Emf@', num2str(Input.base_rpm), '.csv'];

    fid = fopen(f_name, 'r');

    while (1)
        if fid > 0
            disp('EMF �ؼ� DATA ����');
            disp(' ');
            break;
        end

        if exist('Run_for_emf.vbs', 'file')
            delete('Run_for_emf.vbs');
        end

        Run_for_emf(Input);
        winopen('Run_for_emf.vbs');

        while fid < 0
            pause(10);
            fid = fopen(f_name, 'r');
        end

        disp('EMF_Data.csv-�Ϸ�');
        fclose(fid);
        break;
    end

    f_name_Lamda = ['Emf_Data/Lamda_fd@', num2str(Input.base_rpm), '.csv'];
    Lamda_fd = Lamda_dq_trans(Input, f_name_Lamda);
    
else
    
    f_name = ['Emf_Data_Skew\Emf@', num2str(Input.base_rpm), '.csv'];
    
    fid = fopen(f_name, 'r');

    while (1)
        if fid > 0
            disp('EMF �ؼ� DATA ����');
            disp(' ');
            break;
        end
        
        interval=skew_angle/floor;
        total_angle=angle-(skew_angle-interval)/2;
        for f=1:1:floor
            f_name=['Emf_Data_Skew\Emf@', num2str(Input.base_rpm) ,'_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv'];
            fid_T = fopen(f_name, 'r');
            if fid_T>0
                disp(['Emf@', num2str(Input.base_rpm) ,'_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv','-����']);
                fclose(fid_T);
                continue;
            end
            if exist('Run_for_emf_skew.vbs', 'file')    % vbs ���� �ʱ�ȭ
               delete('Run_for_emf_skew.vbs');    
            end
            Run_for_emf_skew(Input, f, total_angle);
            winopen('Run_for_emf_skew.vbs');
            total_angle=total_angle+interval;
            while fid_T < 0
                pause(10);
                fid_T = fopen(f_name, 'r');
            end
                
            disp(['Emf@', num2str(Input.base_rpm) ,'_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv','-�Ϸ�']);
            fclose(fid_T);
        end
        break;
    end
    skew_emf_data_avg(Input, floor);
    f_name_Lamda = ['Emf_Data_Skew/Lamda_fd@', num2str(Input.base_rpm), '.csv'];
    Lamda_fd = Lamda_dq_trans(Input, f_name_Lamda);
    
    f_name = ['Emf_Data_Skew\Emf@', num2str(Input.base_rpm), '.csv'];
end
                
data = xlsread(f_name);
emf_data = (data(2:121,2)-data(2:121,3));
[EMF_THD, YfreqDomain] = RunFFT(emf_data);

EMF_THD
disp('No_Load �ؼ� �Ϸ�');
disp(' ');