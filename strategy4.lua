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
SOURCE = 1
GRABBING = false
STARTING_DELAY = 50
GRIPPED = false


--[[ This function is executed every time you press the 'execute' button ]]
function init()
   robot.colored_blob_omnidirectional_camera.enable()
	robot.turret.set_position_control_mode()
end

-- Drives with linear speed $forward and angular speed $angular. If $angular > 0, then the robot goes to the left.
function drive(forward, angular)
	robot.wheels.set_velocity(forward - angular, forward + angular)
end

function random_walk()
	local speed = robot.random.uniform_int(0, SPEED)
	local angular_speed = robot.random.uniform_int(-SPEED, SPEED)
	drive(speed, angular_speed)
end

-- Returns the distance, angle and blue value of the closest blue robot
function get_blue_target()
	local neighbors = #robot.colored_blob_omnidirectional_camera
	local target = {distance = math.maxinteger, angle = 0, blue = BLUE}
	if neighbors > 0 then
		for i = 1, neighbors do
			if (robot.colored_blob_omnidirectional_camera[i].color.blue > target.blue and robot.colored_blob_omnidirectional_camera[i].distance < target.distance) then
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
	if (STARTING_DELAY > 0) then
		STARTING_DELAY = STARTING_DELAY - 1
	end
	if (BRIGHTEST_INDEX ~= 12 and BRIGHTEST_INDEX ~= 13) then
		drive(1, SPEED)
	else
		if (STARTING_DELAY == 0) then
			drive(SPEED, robot.random.uniform_int(-1, 1))
		else
			drive(0, 0)
		end
	end
end

function drive_to_blue_target()
    if (BLUE_TARGET.angle < -0.2) then
        drive(0, -4)
    else
        if (BLUE_TARGET.angle > 0.2) then
            drive(0, 4)
        else
            drive(SPEED, 0)--random_walk()
        end
    end
end

function drive_out_of_the_source()
    BRIGHTEST_INDEX = get_brightest_index()
    if (BRIGHTEST_INDEX ~= 0) then
        BLUE = 245
        drive_away_from_light_source()
    else
        BLUE_TARGET = get_blue_target()
        if (BLUE_TARGET.distance < math.maxinteger) then
            BLUE = BLUE_TARGET.blue - 10
				if (BLUE < 0) then
					BLUE = 0
				end
            drive_to_blue_target()
        else
				BLUE = 0
            random_walk()
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

function is_in_source()
	local in_source = 0
	for i = 1, 4 do
	   if(robot.motor_ground[i].value == SOURCE) then
	      in_source = in_source + 1
	    end
	end
	return in_source == 4
end

function drive_to_target()
	BLUE_TARGET = get_blue_target()
   if (BLUE_TARGET.distance < math.maxinteger) then
      BLUE = BLUE_TARGET.blue - 1
		if (BLUE < 0) then
			BLUE = 0
		end
      	drive_to_blue_target()
   else
		BLUE = 255
      drive(SPEED, 0)
   end
	drive(SPEED, robot.random.uniform_int(0, 0))
end

-- Returns the distance, angle and blue value of the closest red obstacle
function get_red_obstacle()
	local neighbors = #robot.colored_blob_omnidirectional_camera
	local target = {distance = math.maxinteger, angle = 0, red = 0}
	if neighbors > 0 then
		for i = 1, neighbors do
			if (robot.colored_blob_omnidirectional_camera[i].color.red > 0 and robot.colored_blob_omnidirectional_camera[i].distance < 19 and (robot.colored_blob_omnidirectional_camera[i].angle < math.pi/2 and robot.colored_blob_omnidirectional_camera[i].angle > -math.pi/2)) then
				target = {distance = robot.colored_blob_omnidirectional_camera[i].distance, angle = robot.colored_blob_omnidirectional_camera[i].angle, red = robot.colored_blob_omnidirectional_camera[i].color.red}
			end
		end
	end
	return target
end

function grab_and_remove_obstacle()
	if (not GRABBING) then
		RED_OBSTACLE = get_red_obstacle()
	end
	if (RED_OBSTACLE.red > 0) then
		GRABBING = true
		drive(0, 0)
		robot.turret.set_rotation(RED_OBSTACLE.angle)
		if ((robot.turret.rotation - RED_OBSTACLE.angle < 0.1 and robot.turret.rotation - RED_OBSTACLE.angle > -0.1) or GRIPPED) then
			GRIPPED = true
			robot.gripper.lock_positive()
			local angle_opposite = 2*math.pi/3 
			if (RED_OBSTACLE.angle < 0) then
				angle_opposite = -2*math.pi/3
			end
			drive(-2, 0)
			robot.turret.set_rotation(angle_opposite)
			if (robot.turret.rotation - angle_opposite < 0.1 and robot.turret.rotation - angle_opposite > -0.1) then
				robot.gripper.unlock()
				GRABBING = false
				GRIPPED = false
			end
		end
	end
	-- check if obstacle is in front: check if red is in front with distance < 19 (check exact)
	-- if true: stop the robot
	-- 			put the turret at the angle of the obstacle
	--				grab the obstacle
	--				put the turret at the opposite of the angle
	--				release the obstacle
	--				drive again
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
    if (is_in_source()) then
        drive_out_of_the_source()
		  robot.leds.set_single_color(13, RED, GREEN, BLUE)
    else
			grab_and_remove_obstacle()
			if (not GRABBING) then
				robot.leds.set_single_color(13, 0, 0, 0)
	 	  		if (is_in_target()) then
					GREEN = 255
					BLUE = 255
	        		robot.leds.set_all_colors(RED, GREEN, BLUE)
		  		else
			   	BLUE = 0
					drive_to_target()
					GREEN = 0
					robot.leds.set_single_color(6, RED, GREEN, BLUE)
					robot.leds.set_single_color(7, RED, GREEN, BLUE)
				end
		  end
    end
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
