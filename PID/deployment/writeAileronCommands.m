

function writeAileronCommands(setPoint, outputData)

    aileronIndex = 2;
    

    gains = csvread("aileronGains.txt");
    Kp = gains(1); %0.459075283547877;
    Ki = gains(2); %0.0706270626625867
    Kd = gains(3); %-0.0530858140803597
    N = gains(4); %8.64779586600939
    Tf = 1/N;

    
    controllerPID = pid(Kp, Ki, Kd, Tf);
    saturationUpperLimit = 10; % upper aileron deflection limit (20 deg trailing edge down)
    saturationLowerLimit = -15; % lower aileron deflection limit (-15 deg trailing edge down)
    obsWindow = 15;
    
    
    aileronOutputData = [outputData(:, 1), outputData(:, aileronIndex)];
    tArr = linspace(0, aileronOutputData(end, 1), length(aileronOutputData(:, 1)));
    rollAngleArr = aileronOutputData(:, 2);


   
    errorArr = setPoint - rollAngleArr;


     
    %[pidOutputArr, ~] = lsim(aileronControllerPID, errorArr, tArr); % gives extremely agressive commands for wayyyy too long (causing massive overshoot) 
    %[pidOutputArr, ~] = lsim(aileronControllerPID, errorArr(end-1:end), tArr(end-1:end));
    [pidOutputArr, ~] = lsim(controllerPID, errorArr(end-obsWindow:end), tArr(end-obsWindow:end));
    aileronControlCommand = pidOutputArr(end);

      
     if aileronControlCommand < saturationLowerLimit
           aileronControlCommand = saturationLowerLimit;
     elseif aileronControlCommand > saturationUpperLimit
           aileronControlCommand = saturationUpperLimit;
     end





     
    % WRITE TO AIRCRAFT

    
    controlInputFileName = "controlInputs.txt";
    
    fileLinesArr = readlines(controlInputFileName);
    fileLinesArr(aileronIndex-1) = aileronControlCommand;
    
    writelines(fileLinesArr,controlInputFileName);



   


end

