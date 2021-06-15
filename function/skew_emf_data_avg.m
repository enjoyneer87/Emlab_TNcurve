function skew_emf_data_avg(Input, floor)

f_name = ['Emf_Data_Skew/Emf@',num2str(Input.base_rpm),'.csv'];
fid = fopen(f_name, 'r');

if fid > 0
    fclose(fid);
    return;
end

Volt1 = zeros(Input.steps*6+1, 1);
Volt2 = zeros(Input.steps*6+1, 1);
Volt3 = zeros(Input.steps*6+1, 1);

Flux1 = zeros(Input.steps+1, 1);
Flux2 = zeros(Input.steps+1, 1);
Flux3 = zeros(Input.steps+1, 1);

for f = 1:1:floor
    f_name_emf = ['Emf_Data_Skew/Emf@', num2str(Input.base_rpm) ,'_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv'];
    data_volt =  xlsread(f_name_emf);
    time_volt = data_volt(:,1);
    Volt1 = Volt1+ data_volt(:,2) / floor;
    Volt2 = Volt2+ data_volt(:,3) / floor;
    Volt3 = Volt3+ data_volt(:,4) / floor;
    
    f_name_lamda = ['Emf_Data_Skew/Lamda_fd@', num2str(Input.base_rpm) ,'_' ,num2str(floor),'th_skew_' ,num2str(f), '.csv'];
    data_lamda =  xlsread(f_name_lamda);
    time_lamda = data_lamda(:,1);
    Flux1 = Flux1+ data_lamda(:,2) / floor;
    Flux2 = Flux2+ data_lamda(:,3) / floor;
    Flux3 = Flux3+ data_lamda(:,4) / floor;
end

Voltage = [time_volt Volt1 Volt2 Volt3];
headers = {'time' 'Volt1' 'Volt2' 'Volt3'};
f_name = ['Emf_Data_Skew/Emf@', num2str(Input.base_rpm) ,'.csv'];
csvwrite_with_headers(f_name, Voltage, headers);

Flux = [time_lamda Flux1 Flux2 Flux3];
headers = {'time' 'Flux1' 'Flux2' 'Flux3'};
f_name = ['Emf_Data_Skew/Lamda_fd@', num2str(Input.base_rpm) ,'.csv'];
csvwrite_with_headers(f_name, Flux, headers);