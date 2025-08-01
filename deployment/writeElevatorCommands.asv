

function writeElevatorCommands(setPoint, outputData)

    elevatorIndex = 3;
    

    gains = csvread("elevatorGains.txt");
    Kp = gains(1);%-0.0458759718617587; %-0.241671288993903
    Ki = gains(2);%-0.0678322474137963; %-0.498782856182308
    Kd = gains(3);%0.0214434098399764;  %-0.0145256732340008
    N = gains(4);%2.13939724158204;     %23.2374502471476
    Tf = 1/N;
    
    
    controllerPID = pid(Kp, Ki, Kd, Tf);
    saturationUpperLimit = 14.7; % upper elevator deflection limit (14.7 deg trailing edge down)
    saturationLowerLimit = -20; % lower elevator deflection limit (-20 deg trailing edge up)
    obsWindow = 15;
    
    
    elevatorOutputData = [outputData(:, 1), outputData(:, elevatorIndex)];
    tArr = linspace(0, elevatorOutputData(end, 1), length(elevatorOutputData(:, 1)));
    pitchAngleArr = elevatorOutputData(:, 2);


   
    errorArr = setPoint - pitchAngleArr;


     
    %[pidOutputArr, ~] = lsim(elevatorControllerPID, errorArr, tArr); % gives extremely agressive commands for wayyyy too long (causing massive overshoot) 
    %[pidOutputArr, ~] = lsim(elevatorControllerPID, errorArr(end-1:end), tArr(end-1:end));
    [pidOutputArr, ~] = lsim(controllerPID, errorArr(end-obsWindow:end), tArr(end-obsWindow:end));
    elevatorControlCommand = pidOutputArr(end);

      
     if elevatorControlCommand < saturationLowerLimit
           elevatorControlCommand = saturationLowerLimit;
     elseif elevatorControlCommand > saturationUpperLimit
           elevatorControlCommand = saturationUpperLimit;
     end





     
    % WRITE TO AIRCRAFT

    
    controlInputFileName = "controlInputs.txt";
    
    fileLinesArr = readlines(controlInputFileName);
    fileLinesArr(elevatorIndex-1) = elevatorControlCommand;
    
    writelines(fileLinesArr,controlInputFileName);



   


end

