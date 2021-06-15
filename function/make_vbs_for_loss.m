function make_vbs_for_loss(Input,Eff_Map)
disp('Vbs_Run_loss Start');

skew=Input.skew;           % Skew On-Off 정의
floor=Input.skew_floor;    % Skew 단수 정의
angle=Input.initial_angle; % Initial Angle 정의
skew_angle=Input.skew_angle;  % Skew 적용할 각도
total_angle=[];
Lamda_data = [];

[col row] = size(Eff_Map);

for i=1:col
    
    if (skew == 0)
        
        f_name=['Core_Loss_Data/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
        fid_T = fopen(f_name, 'r');

        if fid_T>0
            disp([num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv','-완료']);
            fclose(fid_T);
            continue;
        end
    
        if exist('Run_for_loss.vbs', 'file')
            delete('Run_for_loss.vbs');
        end        
        Run_for_loss(Input, Eff_Map(i,:));
        winopen('Run_for_loss.vbs'); 
   
        while fid_T < 0
            pause(10);
            fid_T = fopen(f_name, 'r');
        end
        
        disp([num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv','-완료']);
        fclose(fid_T);
        
    else 
        interval=skew_angle/floor;
        total_angle=angle-(floor-1)/2*interval;
        for f=1:1:floor                   
            f_name=['Core_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
            fid_T = fopen(f_name, 'r');
            if fid_T>0
                disp([num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv','-완료']);
                fclose(fid_T);
                total_angle=total_angle+interval;
                continue;
            end                     
            if exist('Run_for_loss_skew.vbs', 'file')    % vbs 파일 초기화
               delete('Run_for_loss_skew.vbs');    
            end
            Run_for_loss_skew(Input, Eff_Map(i,:), f, total_angle);
            winopen('Run_for_loss_skew.vbs');
            total_angle=total_angle+interval;
            while fid_T < 0
                pause(10);
                fid_T = fopen(f_name, 'r');
            end
                    
            disp([num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv','-완료']);
            fclose(fid_T);
        end
        loss_skew_data_avg(Input, Eff_Map, floor, i);
    end
end

disp('Vbs_Run_loss End');