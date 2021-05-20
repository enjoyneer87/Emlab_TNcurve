function lamda_d_ave = Lamda_dq_trans(Input, f_name)

step = Input.steps;

data = xlsread(f_name);
lamda = data(1:step, 2:4);

ang=(0:Input.torque_ripple/Input.steps:Input.torque_ripple-Input.torque_ripple/Input.steps)'; % 토크리플 간격
e_ang=ang*(pi/180)*Input.p/2;       

if Input.mode_w == -1      %U-W-V
    lamda_d=(2/3)*(lamda(:,1).*cos(e_ang)+lamda(:,2).*cos(e_ang-(2/3)*pi)+lamda(:,3).*cos(e_ang+(2/3)*pi));
else                     %U-V-W
    lamda_d=(2/3)*(lamda(:,1).*cos(e_ang)+lamda(:,3).*cos(e_ang-(2/3)*pi)+lamda(:,2).*cos(e_ang+(2/3)*pi));
end
    
lamda_d_ave=mean(lamda_d);