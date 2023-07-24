-- Use Shift + Click to select a robot
-- When a robot is selected, its variables appear in this editor

-- Use Ctrl + Click (Cmd + Click on Mac) to move a selected robot to a different location



-- Put your global variables here
SPEED = 15
TARGET = 0
GRIPPING = false
GRIPPED = false
HAS_TURNED = false

--[[ This function is executed every time you press the 'execute' button ]]
function init()
	robot.colored_blob_omnidirectional_camera.enable()
	robot.turret.set_position_control_mode()
end

-- Drives with linear speed $forward and angular speed $angular. If $angular > 0, then the robot goes to the left.
function drive(forward, angular)
	robot.wheels.set_velocity(forward - angular, forward + angular)
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

-- Returns the distance, angle and green value of the signaling robot in the target.
function get_target()
	local neighbors = #robot.colored_blob_omnidirectional_camera
	local target = {distance = math.maxinteger, angle = 0, green = math.maxinteger}
	if neighbors > 0 then
		for i = 1, neighbors do
			if robot.colored_blob_omnidirectional_camera[i].color.blue == 0 and robot.colored_blob_omnidirectional_camera[i].color.red == 0 and robot.colored_blob_omnidirectional_camera[i].color.green > 0 then
				target = {distance = robot.colored_blob_omnidirectional_camera[i].distance, angle = robot.colored_blob_omnidirectional_camera[i].angle, green = robot.colored_blob_omnidirectional_camera[i].color.green}
			end
		end
	end
	return target
end

-- Returns the distance, angle and green value of the signaling robot in the target.
function get_obstacle()
	local neighbors = #robot.colored_blob_omnidirectional_camera
	local obstacle = {distance = math.maxinteger, angle = 0, red = math.maxinteger}
	if neighbors > 0 then
		for i = 1, neighbors do
			if robot.colored_blob_omnidirectional_camera[i].color.blue == 0 and robot.colored_blob_omnidirectional_camera[i].color.red > 0 and robot.colored_blob_omnidirectional_camera[i].color.green == 0 and robot.colored_blob_omnidirectional_camera[i].distance < obstacle.distance then
				obstacle = {distance = robot.colored_blob_omnidirectional_camera[i].distance, angle = robot.colored_blob_omnidirectional_camera[i].angle, red = robot.colored_blob_omnidirectional_camera[i].color.red}
			end
		end
	end
	return obstacle
end

function drive_away_from_light_source()
	local target = get_target()
	if (target.distance < math.maxinteger) then
		if (target.angle > 0.1 or target.angle < -0.1) then
			drive(0, SPEED)
		else
			drive(SPEED, 0)
		end
	else
		local brightest_index = get_brightest_index()
		if (brightest_index == 0) then
			drive(12, robot.random.uniform_int(-5, 5))
		else
			if (brightest_index ~= 12) then
				drive(4, SPEED)
			else
				drive(SPEED, 0)
			end
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

function get_rid_of_object()
	robot.turret.set_position_control_mode()
	local brightest_index = get_brightest_index()
	if (brightest_index ~= 0) then
		if (brightest_index <= 12) then
			angle = math.pi * brightest_index/12
		else
			angle = math.pi * (1-(12-brightest_index)/12)
		end
		if (robot.turret.rotation-angle < -0.25 or robot.turret.rotation-angle > 0.25) then
			drive(0, 0)
			robot.turret.set_rotation(angle)
		end
	else
		drive(-SPEED, 0)
	end
	if (is_in_target() == false) then
		GRIPPING = false
		GRIPPED = false
		HAS_TURNED = false
		drive(SPEED, 0)
		robot.gripper.unlock()
		robot.turret.set_rotation(0)
	end
end

function put_obstacle_out()
	if (GRIPPED) then
		get_rid_of_object()
	else
		obstacle = get_obstacle()
		if (GRIPPING) then
			robot.turret.set_rotation(obstacle.angle)
			robot.gripper.lock_positive()
			GRIPPED = true
		else
			if (obstacle.distance < math.maxinteger) then
				if (obstacle.distance <= 19) then
					GRIPPING = true
				else
					if (obstacle.distance <= 100) then
						if (obstacle.angle > 0.1 or obstacle.angle < -0.1) then
							drive(0, 10*obstacle.angle)
						else
							drive(SPEED, 0)
						end
					else
						drive_away_from_light_source()
					end
				end
			end
		end
	end
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	if is_in_target() or GRIPPING or GRIPPED then
		put_obstacle_out()
		robot.leds.set_single_color(13, 0, 255, 0)
	else
		GRIPPING = false
		GRIPPED = false
		robot.leds.set_single_color(13, 0, 0, 0)
	   drive_away_from_light_source()
	end
end



--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
   GRIPPING = false
	GRIPPED = false
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
