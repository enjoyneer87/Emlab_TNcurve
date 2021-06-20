
%% -------------------------초기화-------------------------
clear; 
clc;
addpath('function\');

%% --------------------------입력--------------------------

skew = 1;                                                                   % Skew O : 1 / Skew X : 0
skew_angle = 7.5;
floor = 2;
ini_angle = 0;
interval=skew_angle/floor;


base_rpm = 2000;
Np=8;
R=0.013149878;
sf=5500;
Vdc=320;
div=1e-6;
Jmag_File = '200401_OSEV_Base_Model_PWM.jproj';

mode_w=1;                                                                   % 권선 모드 : UWV = -1, UVW = 1

f_name = ['Emf_Data_Skew/Lamda_fd@', num2str(base_rpm), '.csv'];
data = xlsread(f_name);
lamda = data(1:21, 2:4);

e_ang=(0:pi/3/20:pi/3)';

if mode_w == -1      %U-W-V
    lamda_d=(2/3)*(lamda(:,1).*cos(e_ang)+lamda(:,2).*cos(e_ang-(2/3)*pi)+lamda(:,3).*cos(e_ang+(2/3)*pi));
else                     %U-V-W
    lamda_d=(2/3)*(lamda(:,1).*cos(e_ang)+lamda(:,3).*cos(e_ang-(2/3)*pi)+lamda(:,2).*cos(e_ang+(2/3)*pi));
end
    
Lamda_f=mean(lamda_d);

if skew == 1
    tmp = readcell('Output/Effy_map_skew.csv');
else
    tmp = readcell('Output/Effy_map.csv');
end

[len a] = size(tmp);
effydata = cell2mat(tmp(2:(len), 1:a));
Re_effydata = [effydata zeros(len-1, 1)];

current_path = [pwd '/'];
current_path = strrep(current_path,'\','/');

disp('Computation of Real current start.');

for i = 1:1:len-1
    %% PARAMETER
    
    rpm = effydata(i, 1);
    torque = effydata(i, 2);
    Imag= effydata(i, 3);
    Beta= effydata(i, 4);
    id = effydata(i, 5);
    iq = effydata(i, 6);
    lambda_d = effydata(i, 7);
    lambda_q = effydata(i, 8);
    
    current_f_name = ['Real_Current/', num2str(torque), 'Nm@', num2str(rpm), 'rpm.csv'];
    
    if exist(current_f_name, 'file')
        disp([current_f_name, ' already exist.']);
        continue;
    end
    
    Lq = lambda_q/iq;
    Ld = (lambda_d-Lamda_f)/id;

    fre=rpm/60*Np/2;
    wc=sf/10;
    Kpd=Ld*wc*10;
    Kid=R*wc*100;
    Kad=1/Kpd;
    Kpq=Lq*wc*10;
    Kiq=R*wc*100;
    Kaq=1/Kpq;
    T=round(1/fre, 6);
    
    Period_step = round(T/div);
    
    %% EXCUTE
    sim('LdLq_Constant_Feedforward_1000');
    Current_period = Iabc((length(Iabc)-Period_step):(length(Iabc)), 1:3);
    
    SW_harmonics = sf/fre;
    
    while SW_harmonics <= 25
        SW_harmonics = SW_harmonics*2;
    end
    
    Step_interval = round(Period_step/(4*SW_harmonics));
    
    Current = Current_period(1:Step_interval:Period_step+1, :);
    
    Re_effydata(i, 9) = length(Current);
    
    Analysis_step = length(Current)-1;
    Analysis_time = T+div;

    time = [0:Analysis_time/Analysis_step:Analysis_time]';
    headers = {'time', 'Ia', 'Ib', 'Ic'};
    Time_Current = [time Current];
    csvwrite_with_headers(current_f_name, Time_Current, headers);
    disp([current_f_name, ' complete successfully']);
    
    if i == len-1
        headers = {'RPM','Torque','Imax','Phase','I_d','I_q','Lamda_d','Lamda_q','Step'};
        csvwrite_with_headers('Output/Re_Effy_map.csv', Re_effydata, headers);
    end

end



%% -------------------------실전류 해석
disp(' ');
disp('All Real Currents are saved successfully!!');
disp('Analysis is start.');

for i = 1:1:len-1
%% JMAzdesigner = actxserver('designer.Application.181');
    
    rpm = effydata(i, 1);
    torque = effydata(i, 2);
    
    f_name = ['Real_Current/', num2str(torque), 'Nm@', num2str(rpm), 'rpm.csv'];
    
    Current = csvread(f_name, 1, 0);
    
    time = Current(:, 1);
    Ia = [time Current(:, 2)];
    Ib = [time Current(:, 3)];
    Ic = [time Current(:, 4)];
    
    Analysis_step = length(Current);
    
    if skew == 1
        total_angle=ini_angle-(skew_angle-interval)/2;
    
        for f=1:1:floor
            f_name = ['Real_Current/', num2str(torque), 'Nm@', num2str(rpm), 'rpm_Skew', num2str(f),'.csv'];
            file_name = [num2str(torque), 'Nm@', num2str(rpm), 'rpm_skew', num2str(f), '.csv'];
            Check_file = [current_path 'Torque_Data_Skew/' file_name];
            
            fid_T = fopen(Check_file);
            
            if fid_T > 0
                disp([file_name, ' already exist.']);
                fclose(fid_T);
                continue;
            end
            
            if f ~= 1
                total_angle=total_angle+interval;
            end
            
            designer = actxserver('designer.Application.191');
            designer.Show();
            app = designer;
            app.Load([current_path, Jmag_File]);
            app.GetModel(0).GetStudy(0).DeleteResult();
    
           %% CURRENT SETTING
            ia =arrayfun(@num2str,Ia,'un',0);
            app.ShowCircuitGrid(true);
            app.GetModel(0).GetStudy(0).GetCircuit().GetComponent('ia').SetTableProperty('Time', app.GetDataManager().GetDataSet('ia'));
            app.GetDataManager().GetDataSet('ia').SetTable(ia);
    
            ib =arrayfun(@num2str,Ib,'un',0);
            app.GetModel(0).GetStudy(0).GetCircuit().GetComponent('ib').SetTableProperty('Time', app.GetDataManager().GetDataSet('ib'));
            app.GetDataManager().GetDataSet('ib').SetTable(ib);
    
            ic =arrayfun(@num2str,Ic,'un',0);
            app.GetModel(0).GetStudy(0).GetCircuit().GetComponent('ic').SetTableProperty('Time', app.GetDataManager().GetDataSet('ic'));
            app.GetDataManager().GetDataSet('ic').SetTable(ic);
    
            %% ANALYSIS SETTING
            %nonlinear
            app.GetModel(0).GetStudy(0).GetStep().SetValue("Step", num2str(Analysis_step));
            nonl = [time ones((Analysis_step), 1)*500];
            nonl =arrayfun(@num2str,nonl,'un',0);
            app.GetModel(0).GetStudy(0).GetStep().SetTableProperty('Nonlinear', app.GetDataManager().GetDataSet('nonlinear'));
            app.GetDataManager().GetDataSet('nonlinear').SetTable(nonl);
    
            app.GetModel(0).GetStudy(0).SetName(file_name);
            %rpm
            app.GetModel(0).GetStudy(0).GetCondition("Stator").SetValue("Poles", num2str(Np));                        %철손 극수 설정
            app.GetModel(0).GetStudy(0).GetCondition("Stator").SetValue("HysteresisLossCalcType", 1);                   %철손 계산방식 (FFT)
            app.GetModel(0).GetStudy(0).GetCondition("Stator").SetValue("RevolutionSpeed", num2str(rpm));
            app.GetModel(0).GetStudy(0).GetCondition("Motion").SetValue("AngularVelocity", num2str(rpm));
            app.GetModel(0).GetStudy(0).GetCondition("Motion").SetValue("InitialRotationAngle", num2str(total_angle));   %Initial angle 
            app.GetModel(0).GetStudy(0).Run();

            tabledata = app.GetModel(0).GetStudy(0).GetResultTable().GetData("Torque")';
            tabledata.WriteTable([current_path 'Torque_Data_Skew/' file_name],'Time');
            
            tabledata = app.GetModel(0).GetStudy(0).GetResultTable().GetData("IronLoss_IronLoss");
            tabledata.WriteTable([current_path 'Core_Loss_Data_Skew/' file_name], "Frequency");
            
            tabledata = app.GetModel(0).GetStudy(0).GetResultTable().GetData("JouleLoss_IronLoss");
            tabledata.WriteTable([current_path 'Eddy_Loss_Data_Skew/' file_name], "Frequency");
            
            tabledata = app.GetModel(0).GetStudy(0).GetResultTable().GetData("HysteresisLoss_IronLoss");
            tabledata.WriteTable([current_path 'Hysteresis_Loss_Data_Skew/' file_name], "Frequency");
            
            app.Save();
            
            disp([file_name, ' is completed.']);
        end
        
    else
        f_name = ['Real_Current/', num2str(torque), 'Nm@', num2str(rpm), 'rpm.csv'];
        file_name = [num2str(torque), 'Nm@', num2str(rpm), 'rpm.csv'];
        Check_file = [current_path 'Torque_Data/' file_name];
        
        fid_T = fopen(Check_file);
            
        if fid_T > 0
            disp([file_name, ' already exist.']);
            fclose(fid_T);
            continue;
        end
        
        designer = actxserver('designer.Application.191');
        designer.Show();
        app = designer;
        app.Load([current_path, Jmag_File]);
        app.GetModel(0).GetStudy(0).DeleteResult();
    
    %% CURRENT SETTING
        ia =arrayfun(@num2str,Ia,'un',0);
        app.ShowCircuitGrid(true);
        app.GetModel(0).GetStudy(0).GetCircuit().GetComponent('ia').SetTableProperty('Time', app.GetDataManager().GetDataSet('ia'));
        app.GetDataManager().GetDataSet('ia').SetTable(ia);
    
        ib =arrayfun(@num2str,Ib,'un',0);
        app.GetModel(0).GetStudy(0).GetCircuit().GetComponent('ib').SetTableProperty('Time', app.GetDataManager().GetDataSet('ib'));
        app.GetDataManager().GetDataSet('ib').SetTable(ib);
    
        ic =arrayfun(@num2str,Ic,'un',0);
        app.GetModel(0).GetStudy(0).GetCircuit().GetComponent('ic').SetTableProperty('Time', app.GetDataManager().GetDataSet('ic'));
        app.GetDataManager().GetDataSet('ic').SetTable(ic);
    
    %% ANALYSIS SETTING
    %nonlinear
        app.GetModel(0).GetStudy(0).GetStep().SetValue("Step", num2str(Analysis_step));
        nonl = [time ones((Analysis_step), 1)*500];
        nonl =arrayfun(@num2str,nonl,'un',0);
        app.GetModel(0).GetStudy(0).GetStep().SetTableProperty('Nonlinear', app.GetDataManager().GetDataSet('nonlinear'));
        app.GetDataManager().GetDataSet('nonlinear').SetTable(nonl);
    
        file_name = [num2str(torque), 'Nm@', num2str(rpm), 'rpm_skew', num2str(f), '.csv'];
        app.GetModel(0).GetStudy(0).SetName(file_name);
        % rpm
        app.GetModel(0).GetStudy(0).GetCondition("Stator").SetValue("Poles", num2str(Np));                        %철손 극수 설정
        app.GetModel(0).GetStudy(0).GetCondition("Stator").SetValue("HysteresisLossCalcType", 1);                   %철손 계산방식 (FFT)
        app.GetModel(0).GetStudy(0).GetCondition("Stator").SetValue("RevolutionSpeed", num2str(rpm));
        app.GetModel(0).GetStudy(0).GetCondition("Motion").SetValue("AngularVelocity", num2str(rpm));
        app.GetModel(0).GetStudy(0).GetCondition("Motion").SetValue("InitialRotationAngle", num2str(total_angle));   %Initial angle 
        app.GetModel(0).GetStudy(0).Run();

        tabledata = app.GetModel(0).GetStudy(0).GetResultTable().GetData("Torque")';
        tabledata.WriteTable([current_path 'Torque_Data/' file_name],'Time');
    
        tabledata = app.GetModel(0).GetStudy(0).GetResultTable().GetData("IronLoss_IronLoss");
        tabledata.WriteTable([current_path 'Core_Loss_Data/' file_name], "Frequency");
            
        tabledata = app.GetModel(0).GetStudy(0).GetResultTable().GetData("JouleLoss_IronLoss");
        tabledata.WriteTable([current_path 'Eddy_Loss_Data/' file_name], "Frequency");
            
        tabledata = app.GetModel(0).GetStudy(0).GetResultTable().GetData("HysteresisLoss_IronLoss");
        tabledata.WriteTable([current_path 'Hysteresis_Loss_Data/' file_name], "Frequency");
        
        app.Save();
        
    end
end

%% -------------------------------데이터 후처리

disp('Real current analysis is completed.');
disp('Post-processing start.');
disp(' ');

Total_effy = zeros(len-1, 14);

Re_effydata = csvread('Output/Re_Effy_map.csv', 1, 0);

for i = 1:1:len-1
        
    rpm = effydata(i, 1);
    torque = effydata(i, 2);
    
    if skew == 1
        
        Torque = zeros(Re_effydata(i, 9), 1);
        Core_Loss = zeros(1, 3);
        Hys_Loss = zeros(1, 3);
        Eddy_Loss = zeros(1, 3);
        
        for f = 1:1:floor
            f_name = [num2str(torque), 'Nm@', num2str(rpm), 'rpm_Skew', num2str(f),'.csv'];
            Check_file = [current_path 'Torque_Data_Skew/' f_name];
            
            data = xlsread(Check_file);
            Torque = Torque + data(:, 2) / floor;
            
            Check_file = [current_path 'Core_Loss_Data_Skew/' f_name];
            
            data = xlsread(Check_file);
            C_data = [data(2, 21) data(2, 25) data(2, 26)];
            Core_Loss = Core_Loss + C_data / floor;
            
            Check_file = [current_path 'Hysteresis_Loss_Data_Skew/' f_name];
            
            data = xlsread(Check_file);
            H_data = [data(2, 21) data(2, 25) data(2, 26)];
            Hys_Loss = Hys_Loss + H_data / floor;
            
            Check_file = [current_path 'Eddy_Loss_Data_Skew/' f_name];
            
            data = xlsread(Check_file);
            E_data = [data(2, 21) data(2, 25) data(2, 26)];
            Eddy_Loss = Eddy_Loss + E_data / floor;
            
        end
        
        T_avg = mean(Torque);
        T_ripple = (max(Torque) - min(Torque)) / T_avg * 100;
        
        Copper_Loss = 1.5*effydata(i, 3).^2*R;
        
        Total_Loss = Copper_Loss + Core_Loss(3);
        
        Power = T_avg * 2*pi*effydata(i, 1)/60;
        
        Efficiency = Power / (Power+Total_Loss) * 100;
        
        Total_effy(i, :) = [T_avg rpm T_ripple Hys_Loss Eddy_Loss Core_Loss Copper_Loss Efficiency];
        
    else
        
        f_name = [num2str(torque), 'Nm@', num2str(rpm), 'rpm.csv'];
        Check_file = [current_path 'Torque_Data/' f_name];
            
        data = xlsread(Check_file);
        Torque = data(:, 2);
            
        Check_file = [current_path 'Core_Loss_Data/' f_name];
        
        data = xlsread(Check_file);
        C_data = [data(2, 21) data(2, 25) data(2, 26)];
        Core_Loss = C_data;
            
        Check_file = [current_path 'Hysteresis_Loss_Data/' f_name];
            
        data = xlsread(Check_file);
        H_data = [data(2, 21) data(2, 25) data(2, 26)];
        Hys_Loss = H_data;
            
        Check_file = [current_path 'Eddy_Loss_Data/' f_name];
            
        data = xlsread(Check_file);
        E_data = [data(2, 21) data(2, 25) data(2, 26)];
        Eddy_Loss = E_data;
            
        T_avg = mean(Torque);
        T_ripple = (max(Torque) - min(Torque)) / T_avg * 100;
        Copper_Loss = 1.5*effydata(i, 3).^2*R;
        
        Total_Loss = Copper_Loss + Core_Loss(3);
        
        Power = T_avg * 2*pi*effydata(i, 1)/60;
        
        Efficiency = Power / (Power+Total_Loss) * 100;
        
        Total_effy(i, :) = [T_avg rpm T_ripple Hys_Loss Eddy_Loss Core_Loss Copper_Loss Efficiency];
    end
    
end

headers = {'Torque','RPM','Torque_ripple','Hys_R','Hys_S','Hys','Eddy_R','Eddy_S','Eddy','Core_R','Core_S','Core','Copper_loss','Efficiency'};

if skew == 0
    csvwrite_with_headers('Output\Total_Effy.csv', Total_effy, headers);
    disp('Total_Effy.csv - write');
else
    csvwrite_with_headers('Output\Total_Effy_skew.csv', Total_effy, headers);
    disp('Total_Effy_skew.csv - write');
end

disp('Cal_Effy End');