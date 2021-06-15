function Total_Effy = cal_effy(Input,Effy_Map,Lamda_fd)
%CORELOSS_EXT Summary of this function goes here
%Detailed explanation goes here

disp('Cal_Effy Start');

iter = Input.iter;
step = Input.core_loss_step;
stack = Input.Stack;
End_wind = Input.End_Winding*pi/2;
margin = Input.Stack_Margin;

if Input.Mech==1
    Mech_Basic=xlsread(Input.Mech_Loss);                                      %  ���� �ʱ� ������
    Mech_Basic_rpm  = Mech_Basic(:,1) ;   % ���� ������ �� rpm
    Mech_Basic_loss = Mech_Basic(:,2) ;   % ���� ������ �� �ս�
    Mech_Div=Input.RPM';                    %  ���� ���� ����
    Mech_Tot = interp1(Mech_Basic_rpm, Mech_Basic_loss, Mech_Div, 'pchip');  % �ش� ȿ�� �ؼ����� ���� ���� ������ ����
    Mech_rpm_Tot=[Mech_Div Mech_Tot];
    Mech_Loss=[];      % ���� ������ ���� 0 ��� ����
else
    Mech_Loss=0;      % ���� ������ ���� 0 ��� ����
end

Total_Effy = [];

[col, row] = size(Effy_Map);

for i=1:col
    if Input.skew == 0
        f_name=['Core_Loss_Data\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    else
        f_name=['Core_Loss_Data_Skew\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    end
    
    core_loss_data = xlsread(f_name);    
    [x y] = size(core_loss_data);
    
    if Input.skew == 0
        f_name=['Eddy_Loss_Data\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    else
        f_name=['Eddy_Loss_Data_Skew\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    end
    
    Eddy_loss_data = xlsread(f_name);    
    [x y] = size(Eddy_loss_data);
    
    if Input.skew == 0
        f_name=['Hysteresis_Loss_Data\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    else
        f_name=['Hysteresis_Loss_Data_Skew\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    end
    
    Hysteresis_loss_data = xlsread(f_name);    
    [x y] = size(Hysteresis_loss_data);    
    
    if Input.skew == 0
        f_name=['Torque_Data\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    else
        f_name=['Torque_Data_Skew\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    end
    
    torque_data = xlsread(f_name);
    torque = mean(torque_data(iter*(step-1)+3-step:iter*(step-1)+1,2));
    torque_ripple = (max(torque_data(iter*(step-1)+3-step:iter*(step-1)+1,2)) - min(torque_data(iter*(step-1)+2-step:iter*(step-1)+1,2))) / torque * 100;
    
    P_mech = 2*pi*(Effy_Map(i,1)/60)*abs(torque);  % Wm * Torque
    
    I_pk = Effy_Map(i,3);                                                   % ���� peak ��
    I_phase = Effy_Map(i,4);                                                % ���� ����
    
    Core_loss = core_loss_data(1,y);                                        % ö�� ��ü ������ ����
    Core_loss_Rotor = core_loss_data(1,y-2);                                % ȸ���� ö�� ������ ����
    Core_loss_Stator = core_loss_data(1,y-1);                               % ������ ö�� ������ ����
    
    Eddy_loss_Rotor = Eddy_loss_data(1,y-2);                                % ȸ���� �������� ������ ����
    Eddy_loss_Stator = Eddy_loss_data(1,y-1);                               % ������ �������� ������ ����
    
    Hysteresis_loss_Rotor = Hysteresis_loss_data(1,y-2);                                % ȸ���� Hysteresis�� ������ ����
    Hysteresis_loss_Stator = Hysteresis_loss_data(1,y-1);                               % ������ Hysteresis�� ������ ����    
    
    DC_loss = (3/2)*(Effy_Map(i,3)^2)*Input.Rs;                             % ������ DC �ս� ���
    DC_end = DC_loss * End_wind / (stack+End_wind);                         % ������� DC �ս�
    DC_active = DC_loss * stack / (stack+End_wind);                         % ���������� DC �ս�
    
    if Input.AC == 1                                                        % AC ���� ���� ON
        if Input.skew == 1                                                  % Skew ���� ON
            f_name = ['Joule_Loss_Data_Skew\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
        else
            f_name = ['Joule_Loss_Data\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
        end
        data = xlsread(f_name);
        [col, row] = size(data);
        Joule_data = data(iter*(step-1)+3-step:iter*(step-1)+1, row);                                       % AC ���� ������ ����
        Joule_loss = mean(Joule_data)/margin;                                                               % �������� ��ŭ Joule Loss ����
        AC_loss = Joule_loss - DC_active;
    else
        AC_loss = 0;                                                         % AC ���� ������ ������ 0
    end
    
    if Input.skew == 0
        f_name = ['Voltage_Data\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    else
        f_name = ['Voltage_Data_Skew\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    end
    
    Volt_data = xlsread(f_name);                
    Vll = Volt_data(iter*(step-1)+3-step:iter*(step-1)+1,2) - Volt_data(iter*(step-1)+3-step:iter*(step-1)+1,3);     % �������� ���, 129������ 128���ܸ� �ؾ���
    Vll_pk = max(Vll);                                           % ���� peak �� ���
    Vll_rms = rms(Vll);
    
    [EMF_THD, YfreqDomain_V] = RunFFT(Vll);
     FFT_Data_Voltage=YfreqDomain_V;                       % FFT ������ ����(Re, Im)
     V_re=real(YfreqDomain_V(2));                % ���� ����� ���� ���� Real �� ���
     V_im=imag(YfreqDomain_V(2));                % ���� ����� ���� ���� Imag �� ���
     V_angle=angle(YfreqDomain_V(2));            % ���� ����� ���� ���� Angle �� ���
    
    if Input.skew == 0
        f_name = ['Current_Data\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    else
        f_name = ['Current_Data_Skew\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    end
    
    current_data=xlsread(f_name);                   
    coil_a=current_data(2:length(current_data),2);                            % a�� ���� �б�
    [EMF_THD, YfreqDomain_I] = RunFFT(coil_a);
     FFT_Data_Current=YfreqDomain_I;                       % FFT ������ ����(Re, Im)
    
     I_re=real(YfreqDomain_I(2));     % ���� ����� ���� ���� Real �� ���
     I_im=imag(YfreqDomain_I(2));     % ���� ����� ���� ���� Imag �� ���
     I_angle=angle(YfreqDomain_I(2));   % ���� ����� ���� ������ Angle ���
    
    power_factor=cos(I_angle-V_angle);    % pf ����� ���� ���� / ���� ������ ���
    
    if Input.skew == 0
        f_name = ['Flux_Data\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    else
        f_name = ['Flux_Data_Skew\',num2str(Effy_Map(i,1)),'_',num2str(Effy_Map(i,2)),'.csv'];
    end

    L_d = (Effy_Map(i,7) - Lamda_fd) / Effy_Map(i,5);
    L_q = Effy_Map(i,8) / Effy_Map(i,6);
    
    T_rel = Input.p/2 * 3/2 * (L_d - L_q) * Effy_Map(i,5) * Effy_Map(i,6);
    T_mag = Input.p/2 * 3/2 * Lamda_fd * Effy_Map(i,6);
    
    if Input.Mech==1
        loct=find(Mech_rpm_Tot(:,1)==Effy_Map(i,1));                            % ������ ���հ� EffyMap�� rpm�� ��Ī�� �ش� ���� ã��
        Mech_Loss=Mech_rpm_Tot(loct,2);                                         % ���� ������ �Է�
    else
        Mech_Loss=0;
    end
    
    Copper_loss = DC_loss + AC_loss;    
    Total_Loss = Core_loss + Copper_loss+Mech_Loss;

    if Input.mode_m==1 || Input.mode_m==2           % ��и鿡 ���� ȿ�� ��� ��� ����
        Effy = P_mech / (P_mech + Total_Loss)*100;
        Total_Effy = [Total_Effy; Effy_Map(i,1) torque P_mech T_rel T_mag torque_ripple I_phase I_pk Total_Loss Core_loss_Rotor Core_loss_Stator Core_loss Hysteresis_loss_Rotor Hysteresis_loss_Stator Eddy_loss_Rotor Eddy_loss_Stator DC_active DC_end AC_loss Copper_loss Mech_Loss Input.Rs Vll_pk Vll_rms Effy_Map(i,7) Effy_Map(i,8) L_d L_q power_factor Effy];
    else
        Effy = (P_mech - Total_Loss) / P_mech * 100;
        Total_Effy = [Total_Effy; Effy_Map(i,1) torque P_mech T_rel T_mag torque_ripple I_phase I_pk Total_Loss Core_loss_Rotor Core_loss_Stator Core_loss Hysteresis_loss_Rotor Hysteresis_loss_Stator Eddy_loss_Rotor Eddy_loss_Stator DC_active DC_end AC_loss Copper_loss Mech_Loss Input.Rs Vll_pk Vll_rms Effy_Map(i,7) Effy_Map(i,8) L_d L_q power_factor Effy];
    end
end
%%
headers = {'RPM','Torque','Power','T_reluctance','T_magnet','Torque_ripple','Current_phase','Current_pk','Total_Loss','Core_loss_Rotor','Core_loss_Stator','Core_loss','Hysteresis_loss_Rotor','Hysteresis_loss_Stator','Eddy_loss_Rotor','Eddy_loss_Stator','DC_active','DC_end','AC_loss','Copper_loss','Mech_Loss','Rs','Vll_pk', 'Vll_rms','Lamda_d','Lamda_q','Induct_d','Induct_q', 'Power Factor', 'Efficiency'};
if Input.skew == 0
    csvwrite_with_headers('Output\Total_Effy.csv', Total_Effy, headers);
    disp('Total_Effy.csv - write');
else
    csvwrite_with_headers('Output\Total_Effy_skew.csv', Total_Effy, headers);
    disp('Total_Effy_skew.csv - write');
end
disp('Cal_Effy End');

