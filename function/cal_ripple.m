function Total_ripple = cal_ripple(Input,Effy_Map)
%CORELOSS_EXT Summary of this function goes here
%Detailed explanation goes here

disp('Cal_ripple Start');

Total_ripple = [];

for i=1:length(Effy_Map)
    
    f_name=['Torque_Data\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    fid = fopen(f_name,'r');
    
    data =  textscan(fid,'"%f","%f"','headerlines',2);
    e_data=cell2mat(data);                              % 엑섹파일로부터 데이터 로드
    v=e_data(1:Input.core_loss_step-1,2);               % 필요한 부분 추출
    
    torque_ave = sum(v)/length(v);
    torque_max = max(v);
    torque_min = min(v);
    ripple = (torque_max-torque_min)/torque_ave*100;
    
    Total_ripple = [Total_ripple; Effy_Map(i,1) Effy_Map(i,2) torque_ave torque_max torque_min ripple];
end
%%
headers = {'RPM','Torque','torque_ave','torque_max','torque_min','ripple'};  
csvwrite_with_headers('Output\Total_ripple.csv', Total_ripple,headers);
disp('Total_ripple.csv - write');
%%
% Trq_1 = [Input.Ini_torque:Input.Touque_first_interval:Input.middle_torque];
% Trq_2 = [Input.middle_torque+Input.Touque_second_interval:Input.Touque_second_interval:Input.Max_torque];

Trq = Input.torque;
% 
% if Trq(length(Trq))~=Input.Max_torque
%     Trq = [Trq Input.Max_torque];
% end

Trq = fliplr(Trq);

RPM = Input.freq;

Map = zeros(length(Trq)+1,length(RPM)+1);

Map(end,:) = [0 RPM];
Map(:,1) = [Trq 0];

Total_ripple_len = size(Total_ripple);

for k=1:Total_ripple_len(1,1)
n = find(Map(end,:)==Total_ripple(k,1));
m = find(Map(:,1)==Total_ripple(k,2));

Map(m,n) = Total_ripple(k,6);
end

csvwrite('Output\Total_ripple_for_Excel.csv', Map);
disp('Total_ripple_for_Excel.csv - write');
disp('Cal_ripple End');



