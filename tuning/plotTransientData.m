%clear;clc
close all

labelLegendMapKeys = [ "aileron", "elevator", "rudder", "throttle" ];
labelLegendMapValues = [ {["Aileron deflection [deg]", "Roll [deg]"]},  {[ "Elevator deflection [deg]", "Pitch [deg]"]},  {["Rudder deflection [deg]", "Yaw rate [deg/s]"]},  {["Throttle ratio [-]", "Airspeed [kts]"]} ];
labelLegendMap = containers.Map(labelLegendMapKeys, labelLegendMapValues, "UniformValues", false);



allData = [];
filenameSeed = "_transient.txt";
dataFileStruct = dir( pwd + "/*/*" + filenameSeed )

transientFileNameFolders = string({dataFileStruct.folder});

i = 1;
for transientFileName = string({dataFileStruct.name})

    transientFileNameFolder = transientFileNameFolders(i) + "/";
    transientFileFullPath =  transientFileNameFolder + transientFileName;

    if contains(transientFileName, "validation") || contains(transientFileNameFolder, "archived")
        i = i + 1
        continue
    end
 
    device = erase(transientFileName, "_transient.txt");
    labelLegendArr = labelLegendMap(device);


    transientData = csvread(transientFileFullPath);

    figure()
    grid on

    % input data
    yyaxis right
    plot(transientData(:, 1), transientData(:, 2), LineWidth=2)
    ylabel(labelLegendArr(1))
    
    % output data
    yyaxis left
    plot(transientData(:, 1), transientData(:, 3), LineWidth=2)
    ylabel(labelLegendArr(2))

    title(device, Interpreter="none")
    xlabel("Time [s]")
    
    legendOutputArr = ["test data output"];


    
    % plot validation data (if any exists)

    dataFileStruct_VALIDATION = dir( transientFileNameFolder + "*_validation*" + filenameSeed );

    validationDataLegendSeed = "validation data #_ output";

    for transientFileName_VALIDATION = string({dataFileStruct_VALIDATION.name})

        validationNum = string(regexp(transientFileName_VALIDATION,'\d*', 'Match'));

        transientFileFullPath_VALIDATION =  transientFileNameFolder + transientFileName_VALIDATION;

        transientData_VALIDATION = csvread(transientFileFullPath_VALIDATION);

        yyaxis right
        hold on
        plot(transientData_VALIDATION(:, 1), transientData_VALIDATION(:, 2), LineWidth=2)
        yAxLim = get(gca, "YLim");
        ylim([yAxLim(1)-10, yAxLim(2)+10])

        yyaxis left
        hold on
        plot(transientData_VALIDATION(:, 1), transientData_VALIDATION(:, 3), LineWidth=2)

        legendOutputArr = [legendOutputArr, strrep(validationDataLegendSeed, "_", validationNum)];
    end



    legendInputArr = [];
    for entry = legendOutputArr
        legendInputArr = [legendInputArr, strrep(entry, "output", "input")]; 
    end

    legend([legendOutputArr, legendInputArr])
   
    i = i + 1
end



