function [characteristic_curve Max_Torque]=get_power_fun(Input,in_power)

skew=Input.skew;           % Skew On-Off 정의

%%
if skew == 0
    disp('characteristic_curve Start');
    if exist('Output\characteristic_curve.csv','file')
        characteristic_curve = csvread('Output\characteristic_curve.csv', 1, 0);
        Max_Torque = characteristic_curve(1, 2);
        disp('characteristic_curve.csv - read');
        disp('characteristic_curve End');
        disp(' ');
        return;
    end
else
    disp('characteristic_curve_skew Start');
    if exist('Output\characteristic_curve_skew.csv','file')
        characteristic_curve = csvread('Output\characteristic_curve_skew.csv', 1, 0);
        Max_Torque = characteristic_curve(1, 2);
        disp('characteristic_curve_skew.csv - read');
        disp('characteristic_curve_skew End');
        disp(' ');
        return;
    end
end

in_power=[in_power; zeros(1,4)];
d =Input.d_interval;

mode_d = round(cos(((Input.mode_m-1)*90+45)/180*pi)*sqrt(2));
mode_q = round(sin(((Input.mode_m-1)*90+45)/180*pi)*sqrt(2));

%% //-----------------------q축 전류 데이터 구분-----------------------//
z=1;
end_val=1;

num = length(in_power);

ele = zeros(num,4);         %pre_alloc

for i=1:num-1
    if in_power(i,1)==in_power(i+1,1)  
        for m=1:d
            k=2:4;
            ele(d*(i-z)+m+z-1,1)=in_power(i,1);
            ele(d*(i-z)+m+z-1,k)=in_power(i,k) + (m-1)*(in_power(i+1,k)-in_power(i,k))/d;  % q축 전류에 대한 선형보간
        end
        end_val=end_val+1;
    else
        k=1:4;
        ele(d*(end_val-1)+z,k)=in_power(i,k);
        z=z+1;
    end 
end

%//------------------ q축 전류 순으로 sorting --------------------------//

ele = sortrows(ele,[mode_q*2 mode_d*1]);

z=1;
end_val=1;

%//-------------------- d축 전류도 데이터 구분 ----------------------------//

ele=[ele; zeros(1,4)];

size_of=size(ele(:,1));

[i_d i_q  Lamda_ds Lamda_qs] = deal(zeros(1,size_of(1,1)));  %pre_alloc

for i=1:size_of(1,1)-1
    if ele(i,2)==ele(i+1,2)
        for m=1:d
            i_d(d*(i - z) + m + z-1) = ele(i,1) + (m-1)*(ele(i + 1,1) - ele(i,1)) / d;
            i_q(d*(i - z) + m + z-1) = ele(i,2);
            Lamda_ds(d*(i - z) + m + z-1) = ele(i,3) + (m-1)*(ele(i + 1,3) - ele(i,3)) / d;
            Lamda_qs(d*(i - z) + m + z-1) = ele(i,4) + (m-1)*(ele(i + 1,4) - ele(i,4)) / d;
        end
        end_val=end_val+1;
    else
        i_d(d*(end_val-1) + z) = ele(i,1);
        i_q(d*(end_val-1) + z) = ele(i,2);
        Lamda_ds(d*(end_val-1) + z) = ele(i,3);
        Lamda_qs(d*(end_val-1) + z) = ele(i,4);
        z = z + 1;
    end
end

%% //----------------------- 특성곡선 데이터 출력 --------------------------//

size_of=size(i_d(1,:));

characteristic_curve = [];
Iref = sqrt(i_d.*i_d + i_q.*i_q);

for k=1:length(Input.freq)
    freq=Input.freq(k);
    Wr = 2 * pi * freq / 60 * Input.p / 2;
    max_power = 0;

    Vds_t = Input.Rs*i_d - Wr*Lamda_qs;
    Vqs_t = Input.Rs*i_q + Wr*Lamda_ds;
    Vabs_s = sqrt(Vds_t.^2 + Vqs_t.^2);
 
    for i=1:size_of(1,2)       
        if Iref(i)<=Input.i_max            
            if Input.Vmax>Vabs_s(i)    
                Vds = (-1) * Wr * Lamda_qs(i);    
                Vqs = Wr * Lamda_ds(i);          
                power_s = 3/2 * (Vds*i_d(i) + Vqs*i_q(i));
               
                if abs(power_s)>abs(max_power)
                    Id = i_d(i);
                    Iq = i_q(i);
                    Imax = sqrt(Id^2 + Iq^2);
                    Vll = Vabs_s(i)*sqrt(3);
                    max_power = power_s;
                    torque = max_power / (Wr * 2 / Input.p);
                end
            end
        end
    end
    characteristic_curve = [characteristic_curve; freq torque Imax atan2(Iq,Id)*180/pi+360*(max_power<0) Vll max_power];
end
Max_Torque = characteristic_curve(1,2);

%% characteristic_curve.csv 파일 생성
headers = {'RPM','Torque','Imax','Phase','V_line','Max_power'};
if skew == 0
    csvwrite_with_headers('Output\characteristic_curve.csv',characteristic_curve,headers);
    disp('characteristic_curve.csv - write');
else
    csvwrite_with_headers('Output\characteristic_curve_skew.csv',characteristic_curve,headers);
    disp('characteristic_curve_skew.csv - write');
end
disp('Getpower End');
disp(' ');