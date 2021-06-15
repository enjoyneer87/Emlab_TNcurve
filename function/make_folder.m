function make_folder(Input)

skew=Input.skew;

if ~exist('Output', 'dir')
    mkdir Output;
end

if Input.skew ==0
    if ~exist('Core_Loss_Data', 'dir')
        mkdir Core_Loss_Data;
    end
    
    if ~exist('Current_Data', 'dir')
        mkdir Current_Data;
    end
    
    if ~exist('Eddy_Loss_Data', 'dir')
        mkdir Eddy_Loss_Data;
    end
    
    if ~exist('Emf_Data', 'dir')
        mkdir Emf_Data;
    end
    
    if ~exist('Flux_Data', 'dir')
        mkdir Flux_Data;
    end
    
    if ~exist('Hysteresis_Loss_Data', 'dir')
        mkdir Hysteresis_Loss_Data;
    end
    
    if ~exist('IdIq', 'dir')
        mkdir IdIq;
    end
    
    if ~exist('Joule_Loss_Data', 'dir')
        mkdir Joule_Loss_Data;
    end
    
    if ~exist('Torque_Data', 'dir')
        mkdir Torque_Data;
    end
    
    if ~exist('Voltage_Data', 'dir')
        mkdir Voltage_Data;
    end
    
else
    if ~exist('Core_Loss_Data_Skew', 'dir')
        mkdir Core_Loss_Data_Skew;
    end
    
    if ~exist('Current_Data_Skew', 'dir')
        mkdir Current_Data_Skew;
    end
    
    if ~exist('Eddy_Loss_Data_Skew', 'dir')
        mkdir Eddy_Loss_Data_Skew;
    end
    
    if ~exist('Emf_Data_Skew', 'dir')
        mkdir Emf_Data_Skew;
    end
    
    if ~exist('Flux_Data_Skew', 'dir')
        mkdir Flux_Data_Skew;
    end
    
    if ~exist('Hysteresis_Loss_Data_Skew', 'dir')
        mkdir Hysteresis_Loss_Data_Skew;
    end
    
    if ~exist('IdIq_Skew','dir')
        mkdir IdIq_Skew
    end
    
    if ~exist('Joule_Loss_Data_Skew', 'dir')
        mkdir Joule_Loss_Data_Skew;
    end
   
    if ~exist('Torque_Data_Skew', 'dir')
        mkdir Torque_Data_Skew;
    end
    
    if ~exist('Voltage_Data_Skew', 'dir')
        mkdir Voltage_Data_Skew;
    end
end

