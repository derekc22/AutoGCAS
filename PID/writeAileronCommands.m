

function writeAileronCommands(setPoint)
    
        
    Kp = 0.459075283547877; %0.459075283547877;
    Ki = 0.0706270626625867; %0.0706270626625867
    Kd = -0.0530858140803597; %-0.0530858140803597
    N = 8.64779586600939; %8.64779586600939
    Tf = 1/N;
    
    
    aileronControllerPID = pid(Kp, Ki, Kd, Tf);
    saturationUpperLimit = 10; % upward aileron deflection limit (20 deg trailing edge down)
    saturationLowerLimit = -15; % lower aileron deflection limit (-15 deg trailing edge down)
    
    obsWindow = 15;
    aileronTransientData = csvread("outputdata.txt");
    
    
    tArr = linspace(0, aileronTransientData(end, 1), length(aileronTransientData(:, 1)));
    rollAngleArr = aileronTransientData(1:end, 3);


   
    errorArr = setPoint - rollAngleArr;


     
    %[pidOutputArr, ~] = lsim(aileronControllerPID, errorArr, tArr); % gives extremely agressive commands for wayyyy too long (causing massive overshoot) 
    %[pidOutputArr, ~] = lsim(aileronControllerPID, errorArr(end-1:end), tArr(end-1:end));
    [pidOutputArr, ~] = lsim(aileronControllerPID, errorArr(end-obsWindow:end), tArr(end-obsWindow:end));
    aileronControlCommand = pidOutputArr(end);

      
     if aileronControlCommand < saturationLowerLimit
           aileronControlCommand = saturationLowerLimit;
     elseif aileronControlCommand > saturationUpperLimit
           aileronControlCommand = saturationUpperLimit;
     end





     
    % WRITE TO AIRCRAFT

    aileronIndex = 1;
    controlInputFileName = "controlInputs.txt";
    
    fileLinesArr = readlines(controlInputFileName);
    fileLinesArr(aileronIndex) = aileronControlCommand;
    
    writelines(fileLinesArr,controlInputFileName);



   


end

