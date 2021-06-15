function loss_skew_data_avg(Input, Eff_Map, floor, i)

f_name = ['Core_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
fid = fopen(f_name, 'r');

if fid > 0
    fclose(fid);
    return;
end

iter = Input.iter;
step = iter*(Input.core_loss_step-1) + 1;

Rotor_Loss_tot =[];                     % Empty 변수 선언
Stator_Loss_tot =[];
Total_Loss_tot =[];
Rotor_Eddy_Loss_tot=[];
Stator_Eddy_Loss_tot=[];
Total_Eddy_Loss_tot=[];
Rotor_Hysteresis_Loss_tot=[];
Stator_Hysteresis_Loss_tot=[];
Total_Hysteresis_Loss_tot=[];

Volt1 = zeros(step, 1);
Volt2 = zeros(step, 1);
Volt3 = zeros(step, 1);
Flux1 = zeros(step, 1);
Flux2 = zeros(step, 1);
Flux3 = zeros(step, 1);
Current1 = zeros(step, 1);
Current2 = zeros(step, 1);
Current3 = zeros(step, 1);
Torque = zeros(step, 1);


if Input.AC == 1
    AC_data = zeros(step, 1);
end

for f = 1:1:floor
    f_name = ['Core_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
    data =  xlsread(f_name);
    [col, row] = size(data);
    Frequency = data(:,1);
    Rotor_Loss_tot = [Rotor_Loss_tot data(:,row - 2)/floor];    % 각 단수별 데이터 쌓는 변수(단수만큼 나누기 미리 함) 
    Stator_Loss_tot =[Stator_Loss_tot data(:,row - 1)/floor];
    Total_Loss_tot = [Total_Loss_tot data(:,row)/floor];
    
    f_name = ['Eddy_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
    data =  xlsread(f_name);
    [col, row] = size(data);
    Rotor_Eddy_Loss_tot =[Rotor_Eddy_Loss_tot data(:,row - 2)/floor];
    Stator_Eddy_Loss_tot = [Stator_Eddy_Loss_tot data(:,row - 1)/floor];
    Total_Eddy_Loss_tot =[Total_Eddy_Loss_tot data(:,row)/floor];
    
    f_name = ['Hysteresis_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
    data =  xlsread(f_name);
    [col, row] = size(data);
    Rotor_Hysteresis_Loss_tot = [Rotor_Hysteresis_Loss_tot data(:,row - 2)/floor];
    Stator_Hysteresis_Loss_tot =[Stator_Hysteresis_Loss_tot data(:,row - 1)/floor];
    Total_Hysteresis_Loss_tot = [Total_Hysteresis_Loss_tot data(:,row)/floor];
    
    f_name = ['Torque_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
    data =  xlsread(f_name);
    time_torque = data(:,1);
    Torque = Torque + data(:,2) / floor;
    
    f_name = ['Voltage_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
    data =  xlsread(f_name);
    time_volt = data(:,1);
    Volt1 = Volt1+ data(:,2) / floor;
    Volt2 = Volt2+ data(:,3) / floor;
    Volt3 = Volt3+ data(:,4) / floor;
    
    f_name = ['Flux_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
    data =  xlsread(f_name);
    time_Flux = data(:,1);
    Flux1 = Flux1+ data(:,2) / floor;
    Flux2 = Flux2+ data(:,3) / floor;
    Flux3 = Flux3+ data(:,4) / floor;
    
        
    f_name = ['Current_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
    data =  xlsread(f_name);
    time_Current = data(:,1);
    Current1 = Current1+ data(:,2) / floor;
    Current2 = Current2+ data(:,3) / floor;
    Current3 = Current3+ data(:,4) / floor;
    
    if Input.AC == 1
        f_name=['Joule_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'_',num2str(floor),'th_skew_',num2str(f), '.csv'];
        data = xlsread(f_name);
        [col, row] = size(data);
        time_ac = data(:, 1);
        AC_data = AC_data + data(:, row) / floor;
    end
end


Rotor_Loss = sum(Rotor_Loss_tot,2);         % 각 단수별 데이터를 쌓은 후에 한번에 합쳐 스큐 전체 적층과 같은 결과
Stator_Loss = sum(Stator_Loss_tot,2);
Total_Loss = sum(Total_Loss_tot,2);

Rotor_Eddy_Loss = sum(Rotor_Eddy_Loss_tot,2);
Stator_Eddy_Loss = sum(Stator_Eddy_Loss_tot,2);
Total_Eddy_Loss = sum(Total_Eddy_Loss_tot,2);

Rotor_Hysteresis_Loss = sum(Rotor_Hysteresis_Loss_tot,2);
Stator_Hysteresis_Loss = sum(Stator_Hysteresis_Loss_tot,2);
Total_Hysteresis_Loss = sum(Total_Hysteresis_Loss_tot,2);

Iron_Loss = [Frequency Rotor_Loss Stator_Loss Total_Loss];
headers = {'Frequency' 'Rotor_Loss' 'Stator_Loss' 'Total_Loss'};
f_name = ['Core_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
csvwrite_with_headers(f_name, Iron_Loss, headers);

Hysteresis_Loss = [Frequency Rotor_Hysteresis_Loss Stator_Hysteresis_Loss Total_Hysteresis_Loss];
headers = {'Frequency' 'Rotor_Loss' 'Stator_Loss' 'Total_Loss'};
f_name = ['Hysteresis_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
csvwrite_with_headers(f_name, Hysteresis_Loss, headers);

Eddy_Loss = [Frequency Rotor_Eddy_Loss Stator_Eddy_Loss Total_Eddy_Loss];
headers = {'Frequency' 'Rotor_Loss' 'Stator_Loss' 'Total_Loss'};
f_name = ['Eddy_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
csvwrite_with_headers(f_name, Eddy_Loss, headers);

Torque = [time_torque Torque];
headers = {'time' 'Torque'};
f_name = ['Torque_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
csvwrite_with_headers(f_name, Torque, headers);

Voltage = [time_volt Volt1 Volt2 Volt3];
headers = {'time' 'Volt1' 'Volt2' 'Volt3'};
f_name = ['Voltage_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
csvwrite_with_headers(f_name, Voltage, headers);

Flux = [time_Flux Flux1 Flux2 Flux3];
headers = {'time' 'Flux1' 'Flux2' 'Flux3'};
f_name = ['Flux_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
csvwrite_with_headers(f_name, Flux, headers);

Current = [time_Current Current1 Current2 Current3];
headers = {'time' 'Current1' 'Current2' 'Current3'};
f_name = ['Current_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
csvwrite_with_headers(f_name, Current, headers);

if Input.AC == 1
    AC_Loss = [time_ac AC_data];
    headers = {'time' 'AC_Loss'};
    f_name = ['Joule_Loss_Data_Skew/',num2str(Eff_Map(i,1)),'_',num2str(Eff_Map(i,2)),'.csv'];
    csvwrite_with_headers(f_name, AC_Loss, headers);
end
