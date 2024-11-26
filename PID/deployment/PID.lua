---------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------- INIT ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Writeable variables (aka INPUTS)
-------------------------------------

dataref("rightAileron", "sim/flightmodel/controls/rail1def", "writeable")    -- Degrees, Positive is trailing-edge up

dataref("elevator1", "sim/flightmodel/controls/hstab1_elv1def", "writeable") -- Degrees, Positive is trailing-edge down.
dataref("elevator2", "sim/flightmodel/controls/hstab2_elv1def", "writeable") -- Degrees, Positive is trailing-edge down.


dataref("rudder", "sim/flightmodel/controls/vstab1_rud1def", "writeable")

dataref("throttle", "sim/flightmodel/engine/ENGN_thro_use", "writeable", 0)



local allTestDataRefsReset = false
function reset_all_test_datarefs()

    if not allTestDataRefsReset then

        --ailerons
        -- set("sim/flightmodel/controls/lail1def", 0) --: leftAileron (only rolls left, stops  rolling after a certain bank angle)
        -- set("sim/flightmodel/controls/rail1def", 0) -- good: rightAileron (rolls perfectly )
        -- set("sim/flightmodel2/controls/roll_ratio", 0) -- bad
        -- set("sim/flightmodel/controls/wing1l_ail1def", 0) --
        -- set("sim/flightmodel/controls/wing1l_ail2def", 0) --
        -- set("sim/flightmodel/controls/wing2r_ail1def", 0) -- good
        -- set("sim/flightmodel/controls/wing2r_ail2def", 0) --

        -- elevator
        -- set("sim/flightmodel/controls/hstab1_elv1def", 0) -- good
        -- set("sim/flightmodel/controls/hstab2_elv1def", 0) -- good
        -- set("sim/flightmodel2/controls/pitch_ratio", 0)

        -- rudder
        -- set("sim/flightmodel/controls/ldruddef", 0)
        -- set("sim/flightmodel/controls/rdruddef", 0)
        -- set("sim/flightmodel/controls/vstab1_rud1def", 0)
        -- set("sim/flightmodel/controls/vstab1_rud2def", 0) -- good
        -- set("sim/flightmodel/controls/vstab2_rud1def", 0)
        -- set("sim/flightmodel/controls/vstab2_rud2def", 0)

        -- engine
        -- set_array("sim/flightmodel/engine/ENGN_thro_use", 0, 0) -- good
        -- set("sim/cockpit2/engine/actuators/throttle_ratio_all", 0) -- bad


    end
    
    allTestDataRefsReset = true
end





-- Readonly variables (aka OUTPUTS)
-------------------------------------
dataref("roll", "sim/flightmodel/position/phi", "readonly")    -- Degrees, The roll of the aircraft in degrees - OpenGL coordinates (-ve left, +ve right)
dataref("pitch", "sim/flightmodel/position/theta", "readonly") -- Degrees, The pitch relative to the plane normal to the Y axis in degrees - OpenGL coordinates (-ve down, +ve up)
-- dataref("heading", "sim/flightmodel/position/psi", "readonly")  -- Degrees, The true heading of the aircraft in degrees from the Z axis - OpenGL coordinates
-- Although these values can be written to (when in 'writeable' mode), the aircraft's orientation will only change if 'override_planepath' == 1


dataref("airspeed", "sim/flightmodel/position/indicated_airspeed", "readonly") -- KIAS, Air speed indicated - this takes into account air density and wind direction




-- Variables to fix (hold) when testing PID
-------------------------------------
local quaternionDataRef = "sim/flightmodel/position/q"

dataref("pitchRate", "sim/flightmodel/position/Q", "writeable") -- Degrees/second, The pitch rotation rate (relative to the flightpath) (-ve down, +ve up)
dataref("rollRate", "sim/flightmodel/position/P", "writeable")    -- Degrees/second, The roll rotation rate (relative to the flightpath) (-ve left, +ve right)
dataref("yawRate", "sim/flightmodel/position/R", "writeable")  -- Degrees/second, The yaw rotation rate (relative to the flightpath) (-ve left, +ve right)


-- dataref("vx", "sim/flightmodel/position/local_vx", "writeable") -- Meters/second, The velocity in local OGL coordinates 
-- dataref("vy", "sim/flightmodel/position/local_vy", "writeable")    -- Meters/second, The velocity in local OGL coordinates
dataref("vz", "sim/flightmodel/position/local_vz", "writeable")  -- Meters/second, The velocity in local OGL coordinates
dataref("y", "sim/flightmodel/position/local_y", "writeable") -- Meters, The location of the plane in OpenGL coordinates
-- The aircraft's velocities (vx, vy, vz) will only change if 'override_planepath' == 0


-- dataref("pitchAccel", "sim/flightmodel/position/Q_dot", "writeable") -- NOT ACTUALLLY WRITEABLE
-- dataref("rollAccel", "sim/flightmodel/position/P_dot", "writeable")
-- dataref("yawAccel", "sim/flightmodel/position/R_dot", "writeable")

-- dataref("pitch_true", "sim/flightmodel/position/true_theta", "writeable") -- NOT ACTUALLLY WRITEABLE
-- dataref("roll_true", "sim/flightmodel/position/true_phi", "writeable")
-- dataref("heading_true", "sim/flightmodel/position/true_psi", "writeable")






---------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------- SCRIPT ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


local planePath = "/Users/derekchibuzor/Library/Application Support/Steam/steamapps/common/X-Plane 11/Aircraft/Laminar Research/Cessna 172SP"
--"/Users/derekchibuzor/Library/Application Support/Steam/steamapps/common/X-Plane 11/Aircraft/CRJ-200"
--"/Users/derekchibuzor/Library/Application Support/Steam/steamapps/common/X-Plane 11/Aircraft/Laminar Research/Cessna 172SP"
--"/Users/derekchibuzor/Library/Application Support/Steam/steamapps/common/X-Plane 11/Aircraft/Laminar Research/Boeing B747-400"



local controlInputsFilePath = planePath.."/myScripts/controlInputs.txt"

local transientFilePathSEED = "/Users/derekchibuzor/Desktop/Project/DEVICE_transient.txt"
local transientFilePath

local outputDataPath = planePath.."/myScripts/outputData.txt"


local function read_input_file(path)

    local inputDataArr = {0, 0, 0, 0}


    -- inputDataArr structure
    -- Line/Index 1: rightAileron deflection [Degrees]
    -- Line/Index 2: elevator (elevator1/elevator2) deflection [Degrees]
    -- Line/Index 3: rudder deflection [Degrees]
    -- Line/Index 4: throttle ratio [Ratio]

    local allLines = io.lines(path)
    local i = 1
    for line in allLines do
        if line == "" then line = 0 end
        inputDataArr[i] = tonumber(line)
        i = i + 1
    end

    return inputDataArr -- remove this return and instead set it directly to 'inputDataArr'
end





-- Continuously closing the file ensures the file gets saved/updated in real time
-- And, as a corallary, because the file is continuously being closed, it needs to also continuously be opened (in order to write to the file)

local function write_data(path, dataToWrite)

    local dataToWriteString = ""
    local delimeter

    for index, data in ipairs(dataToWrite) do
        
        delimeter = index == 1 and "" or "," -- customary (weird) way of implementing the JS 'ternary operator' (?) in Lua 

        dataToWriteString = dataToWriteString .. delimeter .. data
    end
    dataToWriteString = dataToWriteString .. "\n"

    local open = io.open
    local file = open(path, "a") -- a append mode
    if not file then print("File not found...") return nil end
    file:write(dataToWriteString)
    file:close()

end





-- local timeOfFirstWrite = 0
-- local function write_data_upon_change(path, dataToWrite)

--     if initialChangeDetected == 0 then
--         timeOfFirstWrite = elapsedTime
--         initialChangeDetected = initialChangeDetected + 1
--     end

--     dataToWrite[1] = dataToWrite[1] - timeOfFirstWrite
--     write_data(path, dataToWrite)

-- end



local timeOfFirstWrite
local function write_data_upon_change(path, dataToWrite)

    if not initialChangeDetected then
        timeOfFirstWrite = elapsedTime
        initialChangeDetected = true
    end

    dataToWrite[1] = dataToWrite[1] - timeOfFirstWrite
    write_data(path, dataToWrite)

end





local socket = require "socket"
local initTime = socket.gettime()

local aileronIndex = 1
local elevatorIndex = 2
local rudderIndex = 3
local throttleIndex = 4


function handle_essential_functions()
    inputDataArr = read_input_file(controlInputsFilePath)
    elapsedTime = socket.gettime() - initTime

end







function print_data()
    -- Disable 'AI aircraft' to ensure that the log remains clear of ATC chatter

    print("ELAPSED TIME: " .. elapsedTime .. " [s]")

    print("-------------------------------------------------------")

    print("INPUT:")
    print("right aileron deflection = " .. inputDataArr[aileronIndex] .. " [deg]")
    print("elevator deflection = " .. inputDataArr[elevatorIndex] .. " [deg]")
    print("rudder deflection = " .. inputDataArr[rudderIndex] .. " [deg]")
    print("throttle ratio = " .. inputDataArr[throttleIndex] .. " [ratio]")

    print("-------------------------------------------------------")

    print("OUPUT:")
    print("roll = " .. roll .. " [deg]")   -- (-ve left, +ve right)
    print("pitch = " .. pitch .. " [deg]") -- (-ve down, +ve up)
    print("yaw rate = " .. yawRate .. " [deg/s]")
    print("airspeed = " .. airspeed .. " [kts]")

    print("-------------------------------------------------------")

end










function update_aircraft()
    -- Disable X-Coordinate scroll wheel throttle
    -- Disable X-Coordinate auto coordination

    set("sim/operation/override/override_control_surfaces", 1)
    set("sim/operation/override/override_throttles", 1)


    rightAileron = inputDataArr[aileronIndex]
    -- Only 1 aileron deflects on the 172 for some reason (the right aileron)


    elevator1 = inputDataArr[elevatorIndex]
    elevator2 = elevator1


    rudder = inputDataArr[rudderIndex]


    throttle = inputDataArr[throttleIndex]


end







local fixedSpeedKts = 120 --60 -- kts
local ktsToMetersPerSec = 1.94384

local fixedAltitudeFt = 6000 -- ft
local ftToMeters = 3.281

function tune_PID()

    -- PERFORM TESTS AT LOW SPEED (as specified by 'fixedSpeedKts') to simulate behavior of control surfaces during realistic stall event (where aircraft would be near stall speed). Vs = 48 kts for the Cessna 172SP, flaps up. For more, see https://daytonabeach.erau.edu/about/fleet-simulators/cessna-172
    -- DONT DO THIS? -> PERFORM TESTS WITH THROTTLE = 1 to simulate behavior of control surfaces during realistic stall event (where throttle would be set to max)
    -- PERFORM ELEVATOR TESTS WITH 'PITCH DOWN' ELEVATOR DEFLECTION to simulate behavior of control surfaces during realistic stall event - (where aircraft would be pitched downward)
    -- Make sure to increment file name when recording validation data

    -- NOTE NEEDED, DO NOT ENABLE
    -- set_array("sim/operation/override/override_planepath", 0, 0)


    if rightAileron == 0 then
        set_array(quaternionDataRef, 1, 0) -- set roll
        rollRate = 0 -- only works when 'override_planepath' == 0
    else
        transientFilePath = transientFilePathSEED:gsub("DEVICE", "aileron_validation1")
        write_data_upon_change(transientFilePath, {elapsedTime, rightAileron, roll})
    end


    if elevator1 == 0 then
        set_array(quaternionDataRef, 2, 0) -- set pitch
        pitchRate = 0 -- only works when 'override_planepath' == 0
    else
        transientFilePath = transientFilePathSEED:gsub("DEVICE", "elevator")
        write_data_upon_change(transientFilePath, {elapsedTime, elevator1, pitch})
    end


    if rudder == 0 then
        set_array(quaternionDataRef, 3, 0) -- set heading (not necessary?)
        yawRate = 0 -- only works when 'override_planepath' == 0
    else
        transientFilePath = transientFilePathSEED:gsub("DEVICE", "rudder")
        write_data_upon_change(transientFilePath, {elapsedTime, rudder, yawRate})
    end


    if throttle == 0.5 then
    else
        transientFilePath = transientFilePathSEED:gsub("DEVICE", "throttle")
        write_data_upon_change(transientFilePath, {elapsedTime, throttle, airspeed})
    end


    if rightAileron == 0 and elevator1 == 0 and rudder == 0 and throttle == 0.5 then
        vz = -fixedSpeedKts/ktsToMetersPerSec -- kts to m/s
        y = fixedAltitudeFt/ftToMeters -- ft to m
        initialChangeDetected = false
    end

    update_aircraft()

end









local runTest = false
function test_PID()

    if not runTest then

        set_array(quaternionDataRef, 1, 0) -- set roll
        rollRate = 0 -- only works when 'override_planepath' == 0

        set_array(quaternionDataRef, 2, 0) -- set pitch
        pitchRate = 0 -- only works when 'override_planepath' == 0

        set_array(quaternionDataRef, 3, 0) -- set heading (not necessary?)
        yawRate = 0 -- only works when 'override_planepath' == 0

        vz = -fixedSpeedKts/ktsToMetersPerSec -- kts to m/s
        y = fixedAltitudeFt/ftToMeters -- ft to m

        initialChangeDetected = false

    

    else
        write_data_upon_change(outputDataPath, {elapsedTime, roll, pitch, yawRate, airspeed})
    end

    update_aircraft()

end








do_every_frame("handle_essential_functions()") -- should always be on
do_often("print_data()")
-- do_every_frame("test_PID()")


do_every_frame("tune_PID()")
-- do_every_frame("tune_throttle_PID()")






