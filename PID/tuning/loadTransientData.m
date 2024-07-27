clear;clc
close all


allDataMapKeys = [ "aileron", "elevator", "rudder", "throttle"];
allDataMapValues = zeros(1, length(allDataMapKeys));
allDataMap = containers.Map(allDataMapKeys, allDataMapValues, "UniformValues", false);


filenameSeed = "_Transient.txt";
dataFileStruct = dir( pwd + "/*/*" + filenameSeed );

transientFileNameFolders = {dataFileStruct.folder};
allData = [];

i = 1;
for datafileNameCellArr = {dataFileStruct.name}

    transientFileName = datafileNameCellArr{1};
    transientFileNameFolder = transientFileNameFolders{i} + "/";
    transientFileFullPath =  transientFileNameFolder + transientFileName;

    if contains(transientFileName, "validation") || contains(transientFileNameFolder, "archived")
        i = i + 1;
        continue
    end

    device = erase(transientFileName, "_Transient.txt");


    allData = [allData, {csvread(transientFileFullPath)}];
    


    dataFileStruct_VALIDATION = dir( transientFileNameFolder + "*_validation*" + filenameSeed );

    legendSeedValidationOutput = "validation data # output";

    for datafileNameCellArr_VALIDATION = {dataFileStruct_VALIDATION.name}

        transientFileName_VALIDATION = datafileNameCellArr_VALIDATION{1};

        transientFileFullPath_VALIDATION =  transientFileNameFolder + transientFileName_VALIDATION;

  
        allData = [allData, {csvread(transientFileFullPath_VALIDATION)}];

    end


    device = erase(transientFileName, "_Transient.txt");
    allDataMap(device) = allData;

    i = i + 1;
end



%############################## choose presets ############################


currDevice = "elevator"
mapContents = allDataMap(currDevice);
validationDataSetNum = 1; % specify which validation data set to use, if multiple exist


currentTransientDataSet = mapContents{1};
try currentTransientDataSet_VALIDATION = mapContents{validationDataSetNum+1}; 
catch 
end


%################# copy into systemIdentification Toolbox #################

startTime = 0


currInputTransientData = currentTransientDataSet(:, 2);
currOutputTransientData = currentTransientDataSet(:, 3);
dataName_TEST = currDevice + "_test" % copy output, not variable
sampleTime_TEST = mean(diff(currentTransientDataSet(:, 1)))


try
currInputTransientData_VALIDATION = currentTransientDataSet_VALIDATION(:, 2);
currOutputTransientData_VALIDATION = currentTransientDataSet_VALIDATION(:, 3);
dataName_VALIDATION = currDevice + "_validation_" + validationDataSetNum % copy output, not variable
sampleTime_VALIDATION = mean(diff(currentTransientDataSet_VALIDATION(:, 1)))
catch
end





