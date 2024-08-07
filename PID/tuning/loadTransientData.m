clear;clc
close all


allDataMapKeys = [ "aileron", "elevator", "rudder", "throttle"];
allDataMapValues = zeros(1, length(allDataMapKeys));
allDataMap = containers.Map(allDataMapKeys, allDataMapValues, "UniformValues", false);


filenameSeed = "_transient.txt";
dataFileStruct = dir( pwd + "/*/*" + filenameSeed );

transientFileNameFolders = string({dataFileStruct.folder});
allData = [];

i = 1;
for transientFileName = string({dataFileStruct.name})

    allData = [];

    transientFileNameFolder = transientFileNameFolders(i) + "/";
    transientFileFullPath =  transientFileNameFolder + transientFileName;

    if contains(transientFileName, "validation") || contains(transientFileNameFolder, "archived")
        i = i + 1;
        continue
    end

    device = erase(transientFileName, "_transient.txt");


    allData = [allData, {csvread(transientFileFullPath)}];
    


    dataFileStruct_VALIDATION = dir( transientFileNameFolder + "*_validation*" + filenameSeed );


    for transientFileName_VALIDATION = string({dataFileStruct_VALIDATION.name})


        transientFileFullPath_VALIDATION =  transientFileNameFolder + transientFileName_VALIDATION;

  
        allData = [allData, {csvread(transientFileFullPath_VALIDATION)}];

    end


    device = erase(transientFileName, "_transient.txt");
    allDataMap(device) = allData;

    i = i + 1;
end



%############################## choose presets ############################


currDevice = "elevator"
mapContents = allDataMap(currDevice);
validationDataSetNum = 1; % specify which validation data set to use, if multiple exist


currentTransientDataSet = mapContents{1};
try 
    currentTransientDataSet_VALIDATION = mapContents{validationDataSetNum+1}; 
catch 
end


%################# copy into systemIdentification Toolbox #################

startTime = 0


currInputTransientData_TEST = currentTransientDataSet(:, 2);
currOutputTransientData_TEST = currentTransientDataSet(:, 3);
dataName_TEST = currDevice + "_test" % copy output, not variable
sampleTime_TEST = mean(diff(currentTransientDataSet(:, 1)))


try
    currInputTransientData_VALIDATION = currentTransientDataSet_VALIDATION(:, 2);
    currOutputTransientData_VALIDATION = currentTransientDataSet_VALIDATION(:, 3);
    dataName_VALIDATION = currDevice + "_validation_" + validationDataSetNum % copy output, not variable
    sampleTime_VALIDATION = mean(diff(currentTransientDataSet_VALIDATION(:, 1)))
catch
end






