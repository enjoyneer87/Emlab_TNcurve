function make_vbs_for_lamda(Input)
disp('Vbs_Run_lamda Start');

rpm = Input.base_rpm;      % base rpm ����
skew=Input.skew;           % Skew On-Off ����
floor=Input.skew_floor;    % Skew �ܼ� ����
angle=Input.initial_angle; % Initial Angle ����
skew_angle=Input.skew_angle;  % Skew ������ ����
total_angle=[];
id_iq=Input.id_iq;

i_d = id_iq(:,1);
i_q = id_iq(:,2);
                   
for k=1:length(id_iq)+1          % length ���� +1�� ���� / Lambda_fd�ؼ� �ѹ��� ���� ����    
    if (skew==0)
        
        if exist('Run_for_lamda.vbs', 'file')
            delete('Run_for_lamda.vbs');    
        end
        
        if (k==length(id_iq)+1)     % idiq_map �ؼ��� �� ������ Lambda_fd ����� ���� �ؼ� ����
            f_name=['Emf_Data/Lamda_fd@',num2str(rpm),'.csv'];
            fid_T = fopen(f_name, 'r');       
                % ���� �����Ͱ� �ִ� �ؼ����� �ؼ��� �������� ����
            if fid_T>0
                disp(['Lambda_fd@',num2str(rpm),'.csv','-����']);
                fclose(fid_T);
                continue;
            end
            % �����Ͱ� ���� �ؼ����� �ؼ� ����            
            Run_for_lamda(Input,0,0);
            winopen('Run_for_lamda.vbs');

            while fid_T < 0
                pause(10);
                fid_T = fopen(f_name, 'r');
            end
            disp(['Lambda_fd@',num2str(rpm),'.csv','-�Ϸ�']);
            fclose(fid_T);
            
        else
            
            f_name=['IdIq/',num2str(i_d(k)),'_',num2str(i_q(k)),'.csv'];
            fid_T = fopen(f_name, 'r');       
                % ���� �����Ͱ� �ִ� �ؼ����� �ؼ��� �������� ����
            if fid_T>0
                disp([num2str(i_d(k)),'_',num2str(i_q(k)),'.csv','-����']);
                fclose(fid_T);
                continue;
            end
            % �����Ͱ� ���� �ؼ����� �ؼ� ����
            Run_for_lamda(Input,i_d(k),i_q(k));    % idiq_map �ؼ�
        
            winopen('Run_for_lamda.vbs');

            while fid_T < 0
                pause(10);
                fid_T = fopen(f_name, 'r');
            end
            disp([num2str(i_d(k)),'_',num2str(i_q(k)),'.csv','-�Ϸ�']);
            fclose(fid_T);
            
        end
        

            
    else
        interval=skew_angle/floor;
        total_angle=angle-(skew_angle-interval)/2;
        for f=1:1:floor                   
 
            if exist('Run_for_lamda_skew.vbs', 'file')    % vbs ���� �ʱ�ȭ
                delete('Run_for_lamda_skew.vbs');    
            end
            
            if (k==length(id_iq)+1)   % idiq_map �ؼ��� �� ������ Lambda_fd ����� ���� �ؼ� ����
                f_name=['Emf_Data_Skew/Lamda_fd@',num2str(rpm),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
                fid_T = fopen(f_name, 'r');       
                        % ���� �����Ͱ� �ִ� �ؼ����� �ؼ��� �������� ����
                if fid_T>0
                    disp(['Lambda_fd@',num2str(rpm),'_',num2str(floor),'th_skew_',num2str(f), '.csv','-����']);
                    fclose(fid_T);
                    total_angle=total_angle+interval;
                continue;
                end                     
                Run_for_lamda_skew(Input, 0, 0,f, total_angle);

                winopen('Run_for_lamda_skew.vbs');
                total_angle=total_angle+interval;
                while fid_T < 0
                    pause(10);
                    fid_T = fopen(f_name, 'r');
                end
                disp(['Lambda_fd@',num2str(rpm),'_',num2str(floor),'th_skew_',num2str(f), '.csv','-�Ϸ�']);
                fclose(fid_T);
                
            else
                f_name=['IdIq_Skew/',num2str(i_d(k)),'_',num2str(i_q(k)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
                fid_T = fopen(f_name, 'r');       
                        % ���� �����Ͱ� �ִ� �ؼ����� �ؼ��� �������� ����
                if fid_T>0
                    disp([num2str(i_d(k)),'_',num2str(i_q(k)),'_',num2str(floor),'th_skew_',num2str(f), '.csv','-����']);
                    fclose(fid_T);
                    total_angle=total_angle+interval;
                continue;
                end                           
                Run_for_lamda_skew(Input, i_d(k), i_q(k),f, total_angle);
                
                winopen('Run_for_lamda_skew.vbs');
                total_angle=total_angle+interval;
                while fid_T < 0
                    pause(10);
                    fid_T = fopen(f_name, 'r');
                end
                disp([num2str(i_d(k)),'_',num2str(i_q(k)),'_',num2str(floor),'th_skew_',num2str(f), '.csv','-�Ϸ�']);
                fclose(fid_T);
                
            end
            

    
        end
    end
    
end
disp('Vbs_Run_lamda End');