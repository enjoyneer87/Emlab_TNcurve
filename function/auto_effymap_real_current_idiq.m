function auto_effymap_real_current_idiq(Input)

Np=8;
R=0.013149878;
sf=5500;
Vdc=360;
div=1e-6;


f_name = ['Emf_Data_Skew/Lamda_fd@', num2str(Input.base_rpm), '.csv'];
data = xlsread(f_name);
lamda = data(1:Input.steps, 2:4);

ang=(0:Input.torque_ripple/Input.steps:Input.torque_ripple-Input.torque_ripple/Input.steps)';
e_ang=ang*(pi/180)*Input.p/2;       

if Input.mode_w == -1      %U-W-V
    lamda_d=(2/3)*(lamda(:,1).*cos(e_ang)+lamda(:,2).*cos(e_ang-(2/3)*pi)+lamda(:,3).*cos(e_ang+(2/3)*pi));
else                     %U-V-W
    lamda_d=(2/3)*(lamda(:,1).*cos(e_ang)+lamda(:,3).*cos(e_ang-(2/3)*pi)+lamda(:,2).*cos(e_ang+(2/3)*pi));
end
    
Lamda_f=mean(lamda_d);

if Input.skew == 1
    tmp = readcell('Output/Effy_map_skew.csv');
else
    tmp = readcell('Output/Effy_map.csv');
end

[len a] = size(tmp);
effydata = cell2mat(tmp(2:(len), 1:a));

for i = 1:1:len
    %% PARAMETER
    rpm = effydata(i, 1);
    Torque = effydata(i, 2);
    Imag= effydata(i, 3);
    Beta= effydata(i, 4);
    id = effydata(i, 5);
    iq = effydata(i, 6);
    lambda_d = effydata(i, 7);
    lambda_q = effydata(i, 8);
    
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
    
    Total_step = round(1/fre/div);
    Period_step = round(Total_step/10);
    
    %% EXCUTE
    sim('LdLq_Constant_Feedforward_1000');
    Current_period = Iabc((Total_step-Period_step):(Total_step), 1:3);
    
    SW_harmonics = sf/fre;
    
    while SW_harmonics > 25
        SW_harmonics = SW_harmonics*2;
    end
    
    Step_interval = round(Current_period/(4*SW_harmonics));
    
    Current = Current_period(1:Step_interval:Period_step+1, :);
    
    Analysis_step = length(Current);

    time = [0:1/fre/Analysis_step:1/fre-1/fre/Analysis_step 1/fre+0.000001]';
    headers = {'time', 'Ia', 'Ib', 'Ic'};
    Time_Current = [time Current];
    csvwrite_with_headers([num2str(id) '_' num2str(iq) '.csv'], Time_Current, headers);
    
    %% JMAzdesigner = actxserver('designer.Application.181');
    designer = actxserver('designer.Application.191');
%     scheduler = actxserver('scheduler.JobApplication');
    designer.Show();
    app = designer;
%     jobApp = scheduler;

    current_path = [pwd '/'];
    current_path = strrep(current_path,'\','/');
    app.Load([current_path,'Iron_Loss_K.jproj']);
    app.GetModel(0).GetStudy(0).DeleteResult();
    
    %% CURRENT SETTING
    ia = [time Current(:, 1)];
    ia =arrayfun(@num2str,ia,'un',0);
    app.ShowCircuitGrid(true)
    app.GetModel(0).GetStudy(0).GetCircuit().GetComponent('Ia').SetTableProperty('Time', app.GetDataManager().GetDataSet('ia'))
    app.GetDataManager().GetDataSet('ia').SetTable(ia);
    
    ib = [time Current(:, 2)];
    ib =arrayfun(@num2str,ib,'un',0);
    app.GetModel(0).GetStudy(0).GetCircuit().GetComponent('Ib').SetTableProperty('Time', app.GetDataManager().GetDataSet('ib'))
    app.GetDataManager().GetDataSet('ib').SetTable(ib);
    
    ic = [time Current(:, 3)];
    ic =arrayfun(@num2str,ic,'un',0);
    app.GetModel(0).GetStudy(0).GetCircuit().GetComponent('Ic').SetTableProperty('Time', app.GetDataManager().GetDataSet('ic'))
    app.GetDataManager().GetDataSet('ic').SetTable(ic);
    
    %% ANALYSIS SETTING
    %nonlinear
    app.GetModel(0).GetStudy(0).GetStep().SetValue("Step", 250+1);
    nonl = [time ones((250+1), 1)*500];
    nonl =arrayfun(@num2str,nonl,'un',0);
    app.GetModel(0).GetStudy(0).GetStep().SetTableProperty('Nonlinear', app.GetDataManager().GetDataSet('nonlinear'));
    app.GetDataManager().GetDataSet('nonlinear').SetTable(nonl);
    
    file_name = [int2str(id) '_'  int2str(iq)];
    app.GetModel(0).GetStudy(0).SetName(file_name);
    %rpm
    app.GetModel(0).GetStudy(0).GetCondition("Stator").SetValue("RevolutionSpeed", num2str(rpm));
    app.GetModel(0).GetStudy(0).GetCondition("Motion").SetValue("AngularVelocity", num2str(rpm));
    
    disp([int2str(i) '/' int2str(len)]);
    app.Save();
    app.GetModel(0).GetStudy(0).Run();

    tables = app.GetModel(0).GetStudy(0).GetResultTable();
    tables.WriteAllTables([current_path '\Real Current\' file_name '.csv'],'Time');    
    
end