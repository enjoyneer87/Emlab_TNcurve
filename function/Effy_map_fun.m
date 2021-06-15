function Effy_Map=Effy_map_fun(Input,in_power)
%% 이미 Effy_map 데이터가 존재할 경우 읽어드리고 바로 함수종료
skew = Input.skew;

if skew == 0
    disp('Effy_map Start');
    if exist('Output\Effy_map.csv','file')
        Effy_Map = csvread('Output\Effy_map.csv', 1, 0);
        disp('Effy_map.csv - read');
        disp('Effy_map End');
        disp(' ');
        return;
    end
else
	disp('Effy_map_skew Start');
    if exist('Output\Effy_map_skew.csv','file')
        Effy_Map = csvread('Output\Effy_map_skew.csv', 1, 0);
        disp('Effy_map_skew.csv - read');
        disp('Effy_map_skew End');
        disp(' ');
        return;
    end
end

%%
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
            ele(d*(i-z)+m+z-1,k)=in_power(i,k) + (m-1)*(in_power(i+1,k)-in_power(i,k))/d;
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

[i_d i_q  Lamda_ds Lamda_qs torque] = deal(zeros(1,size_of(1,1)));  %pre_alloc

index = [1];

for i=1:size_of(1,1)-1
    if ele(i,2)==ele(i+1,2)
        for m=1:d
            i_d(d*(i-z) + m + z-1) = ele(i,1) + (m-1)*(ele(i+1,1) - ele(i,1)) / d;
            i_q(d*(i-z) + m + z-1) = ele(i,2);
            Lamda_ds(d*(i-z) + m + z-1) = ele(i,3) + (m-1)*(ele(i+1,3) - ele(i,3)) / d;
            Lamda_qs(d*(i-z) + m + z-1) = ele(i,4) + (m-1)*(ele(i+1,4) - ele(i,4)) / d;
        end
        end_val=end_val+1;
    else
        i_d(d*(end_val-1) + z) = ele(i,1);
        i_q(d*(end_val-1) + z) = ele(i,2);
        Lamda_ds(d*(end_val-1) + z) = ele(i,3);
        Lamda_qs(d*(end_val-1) + z) = ele(i,4);
        index = [index; d*(end_val-1)+z+1];
        z = z + 1;
    end
end

torque = 3/2 * Input.p/2 *(Lamda_ds.*i_q - Lamda_qs.*i_d);
total = [torque' i_d' i_q' Lamda_ds' Lamda_qs'];
total = sortrows(total,[mode_d*2 mode_q*3]);

Trq = Input.torque;
RPM = Input.RPM;
Effy_Map = [];                                % RPM, Trq, I_mag, Angle
index_cal = [];

for i=1:length(index)-1
    index_cal = [index_cal  index(i+1)-index(i)];
end

total_cell = mat2cell(total,index_cal,5);
total_num = 1;

for k=1:length(RPM)    
    for m=1:length(Trq)
        torque_ref=Trq(m);
        
        kk=1;        
        for n=1:length(total_cell)      
            h = find(abs(total_cell{n}(:,1)) >= abs(torque_ref),1,'first');
            if h == 1
               continue
            end
            if h ~= 1
                data1=[total_cell{n}(h-1,:)];                       % data2의 앞 data
                data2=[total_cell{n}(h,:)];                         % torque_ref가 넘을때 in_power의 앞데이터인 data1과 선형근사         
                coef=(torque_ref-data1(1))/(data2(1)-data1(1));     % 선형 근사
                save_data(kk,:)=data1+coef*(data2-data1);           % 선형근사 data 저장
                kk=kk+1;
            end
        end
        
        I_mag=sqrt(save_data(:,2).^2+save_data(:,3).^2);
        V_d=Input.Rs*save_data(:,2)-2*pi()*RPM(k)/60*Input.p/2*save_data(:,5);
        V_q=Input.Rs*save_data(:,3)+2*pi()*RPM(k)/60*Input.p/2*save_data(:,4);
        V_mag=sqrt(V_d.^2+V_q.^2);
        
        total_data=[I_mag V_mag save_data(:,2) save_data(:,3) save_data(:,4) save_data(:,5)];            
        total_data=sortrows(total_data,1);
        data_size=size(total_data);
        for pp=1:data_size(1)
            if (total_data(pp,2)<(Input.Vmax))&&(total_data(pp,1)<=Input.i_max)
                Effy_Map(total_num,1) = RPM(k);
                Effy_Map(total_num,2) = Trq(m);
                Effy_Map(total_num,3) = total_data(pp,1);                                                          %I_mag
                Effy_Map(total_num,4) = atan2(total_data(pp,4),total_data(pp,3))/pi*180+360*(total_data(pp,4)<0);  %Angle
                Effy_Map(total_num,5) = total_data(pp,3);
                Effy_Map(total_num,6) = total_data(pp,4);
                Effy_Map(total_num,7) = total_data(pp,5);
                Effy_Map(total_num,8) = total_data(pp,6);
                total_num = total_num+1;
                break;
            else
                pp=pp+1;
            end
        end
        clearvars save_data;
    end            
end

%% Effy_map.csv 파일 생성
headers = {'RPM','Torque','Imax','Phase','I_d','I_q','Lamda_d','Lamda_q'};
if skew == 0
    csvwrite_with_headers('Output\Effy_map.csv',Effy_Map,headers);
    disp('Effy_map.csv - write');
    disp('Effy_map End');
else
	csvwrite_with_headers('Output\Effy_map_skew.csv',Effy_Map,headers);
    disp('Effy_map_skew.csv - write');
    disp('Effy_map_skew End');
end
disp(' ');










