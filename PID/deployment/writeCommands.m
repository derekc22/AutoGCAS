clear;clc

tic
time = 0;
while time < inf
    
    try
        outputData = csvread("outputdata.txt");
        setpoints = readmatrix("setpoints.txt");


        setpointCell = num2cell(setpoints);
        [aileronSetpoint, elevatorSetpoint, rudderSetpoint, throttleSetpoint] = setpointCell{:};
    
    
  
        try 
            writeAileronCommands(aileronSetpoint, outputData)
        catch
        end



        try 
            writeElevatorCommands(elevatorSetpoint, outputData)
        catch
        end


        
        
        



    catch err
        
        sprintf(err.message)          
    end




    time = toc;
end