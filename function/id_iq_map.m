function Input=id_iq_map(Input)
disp('id iq map ���� - Start');
skew=Input.skew;

%% id_iq_map �����Ͱ� ������ ���, ���� ������ ���

if (skew==0)
    if exist('IdIq\id_iq_map.csv','file')
        id_iq = csvread('IdIq\id_iq_map.csv',1,0);
        Input.total = length(id_iq);
        Input.id_iq = id_iq;
        disp('id_iq_map.csv - ����');
        disp('id_iq_map ���� - End');
        disp(' ');
        return;
    end
else
    if exist('IdIq_Skew\id_iq_map.csv','file')
        id_iq = csvread('IdIq_Skew\id_iq_map.csv',1,0);
        Input.total = length(id_iq);
        Input.id_iq = id_iq;
        disp('id_iq_map.csv - ����');
        disp('id_iq_map ���� �Ϸ�');
        disp(' ');
        return;
    end    
end

%% id_iq_map �����Ͱ� ���� ���, id_iq_map ������ ����

mode_d = round(cos(((Input.mode_m-1)*90+45)/180*pi)*sqrt(2));      % d-q plane���� ��и� �����ϱ� ���� ����
mode_q = round(sin(((Input.mode_m-1)*90+45)/180*pi)*sqrt(2));      % d-q plane���� ��и� �����ϱ� ���� ����

i_d = [mode_d*Input.i_s:mode_d*Input.interval:mode_d*Input.i_max]; 
i_q = [mode_q*Input.i_s:mode_q*Input.interval:mode_q*Input.i_max]; 

if i_d(length(i_d))~=mode_d*Input.i_max
    i_d = [i_d i_d(1,end)+mode_d*Input.interval];
end

if i_q(length(i_q))~=mode_q*Input.i_max
    i_q = [i_q i_q(1,end)+mode_q*Input.interval];
end

id_iq = [];

for n=1:length(i_d)
    for m=1:length(i_q)
        if n==1 && m==1
            id_iq = [id_iq;i_d(n),i_q(m)];
            continue;
        end

        if n==1
            if sqrt(i_d(n)^2+i_q(m-1)^2)<=Input.i_max
                id_iq = [id_iq;i_d(n),i_q(m)];
            end
            continue;
        end

        if m==1
            if sqrt(i_d(n-1)^2+i_q(m)^2)<=Input.i_max
                id_iq = [id_iq;i_d(n),i_q(m)];
            end
            continue;
        end

        if (sqrt(i_d(n-1)^2+i_q(m-1)^2)<=Input.i_max)||(sqrt(i_d(n)^2+i_q(m-1)^2)<=Input.i_max)||(sqrt(i_d(n-1)^2+i_q(m)^2)<=Input.i_max)
            id_iq = [id_iq;i_d(n),i_q(m)];
            continue;
        end
    end
end

Input.total = length(id_iq);

Input.id_iq = id_iq;




%% id_iq_map.csv ���� ����
if (skew==0)
    headers = {'Id','Iq'};
    csvwrite_with_headers('IdIq\id_iq_map.csv',id_iq,headers);
    disp('id_iq_map.csv - write');
    disp('id iq map ���� �Ϸ�');
    disp(' ');
else
    headers = {'Id','Iq'};
    csvwrite_with_headers('IdIq_Skew\id_iq_map.csv',id_iq,headers);
    disp('id_iq_map.csv - write');
    disp('id iq map ���� �Ϸ�');
    disp(' '); 
end
