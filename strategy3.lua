-- Use Shift + Click to select a robot
-- When a robot is selected, its variables appear in this editor

-- Use Ctrl + Click (Cmd + Click on Mac) to move a selected robot to a different location



-- Put your global variables here
BRIGHTEST_INDEX = 0
SPEED = 15
RED = 0
GREEN = 0
BLUE = 0
TARGET = 0


--[[ This function is executed every time you press the 'execute' button ]]
function init()
   robot.colored_blob_omnidirectional_camera.enable()
end

-- Drives with linear speed $forward and angular speed $angular. If $angular > 0, then the robot goes to the left.
function drive(forward, angular)
	robot.wheels.set_velocity(forward - angular, forward + angular)
end

-- Returns the distance, angle and blue value of the closest blue robot
function get_blue_target()
	local neighbors = #robot.colored_blob_omnidirectional_camera
	local target = {distance = math.maxinteger, angle = 0, blue = 0}
	if neighbors > 0 then
		for i = 1, neighbors do
			if (robot.colored_blob_omnidirectional_camera[i].color.blue > 0 and robot.colored_blob_omnidirectional_camera[i].color.blue >= target.blue and robot.colored_blob_omnidirectional_camera[i].distance < target.distance) then
				target = {distance = robot.colored_blob_omnidirectional_camera[i].distance, angle = robot.colored_blob_omnidirectional_camera[i].angle, blue = robot.colored_blob_omnidirectional_camera[i].color.blue}
			end
		end
	end
	return target
end

-- Gets the index of the captor which detects the brightest source of light (the food source).
function get_brightest_index()
	local brightest_source = 0
	local brightest_index = 0
	for i = 1, 24 do
		if robot.light[i].value > brightest_source then
			brightest_source = robot.light[i].value
			brightest_index = i
		end
	end
	return brightest_index
end

function drive_away_from_light_source()
	if (BRIGHTEST_INDEX ~= 12) then
		drive(4, SPEED)
	else
		drive(SPEED, 0)
	end
end

function drive_to_blue_target(target)
    if (target.angle < -0.2) then
        drive(1, 4)
    else
        if (target.angle > 0.2) then
            drive(1, -4)
        else
            drive(SPEED, 0)
        end
    end
end

function drive_to_the_target()
    BRIGHTEST_INDEX = get_brightest_index()
    if (brightest_index ~= 0) then
        BLUE = 255
        drive_away_from_light_source()
    else
        local blue_target = get_blue_target()
        if (blue_target.distance < math.maxinteger) then
            BLUE = blue_target.blue - 10
            drive_to_blue_target(blue_target)
        else
            BLUE = 0
            drive(SPEED, 0)
        end
    end
end

function is_in_target()
	local in_target = 0
	for i = 1, 4 do
	   if(robot.motor_ground[i].value == TARGET) then
	      in_target = in_target + 1
	    end
	end
	return in_target == 4
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
    if (not is_in_target()) then
        drive_to_the_target()
    else
        GREEN = 255
        drive(0, 0)
    end
    robot.leds.set_single_color(13, RED, GREEN, BLUE)
end



--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
   -- put your code here
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
