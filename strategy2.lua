-- Use Shift + Click to select a robot
-- When a robot is selected, its variables appear in this editor

-- Use Ctrl + Click (Cmd + Click on Mac) to move a selected robot to a different location



-- Put your global variables here

LEADING = false
PROBABILITY_TO_LEAD = 0.3
RED = 0
GREEN = 0
BLUE = 0
SPEED = 15
WAIT = 50

--[[ This function is executed every time you press the 'execute' button ]]
function init()
	robot.colored_blob_omnidirectional_camera.enable()
  if (robot.random.uniform() <= PROBABILITY_TO_LEAD) then
		LEADING = true
	end
end

-- Drives with linear speed $forward and angular speed $angular. If $angular > 0, then the robot goes to the left.
function drive(forward, angular)
	robot.wheels.set_velocity(forward - angular, forward + angular)
end

function random_walk()
	local speed = robot.random.uniform_int(-SPEED, SPEED)
	local angular_speed = robot.random.uniform_int(-SPEED, SPEED)
	drive(speed, angular_speed)
end

-- Returns the distance, angle and blue value of the closest leader.
function get_closest_leader()
	local neighbors = #robot.colored_blob_omnidirectional_camera
	local target = {distance = math.maxinteger, angle = math.maxinteger, blue = 0}
	if neighbors > 0 then
		for i = 1, neighbors do
			if ((robot.colored_blob_omnidirectional_camera[i].color.blue > 0 and robot.colored_blob_omnidirectional_camera[i].distance < target.distance) or robot.colored_blob_omnidirectional_camera[i].color.blue > target.blue) and robot.colored_blob_omnidirectional_camera[i].color.blue > BLUE then
				target = {distance = robot.colored_blob_omnidirectional_camera[i].distance, angle = robot.colored_blob_omnidirectional_camera[i].angle, blue = robot.colored_blob_omnidirectional_camera[i].color.blue}
			end
		end
	end
	return target
end

function follow_leader()
	leader = get_closest_leader()
	if (leader.distance < math.maxinteger) then
		BLUE = leader.blue - 10
		local angular_speed = leader.angle * 5
		if (angular_speed > 0.1 or angular_speed < -0.1) then
			drive(0, angular_speed)
		else
			drive(SPEED, 0)
		end
	else
		LEADING = true
		--random_walk()
	end
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

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
   if (LEADING) then
		BLUE = 255
		if (WAIT == 0) then
			drive_away_from_light_source()
		else
			WAIT = WAIT - 1
		end
	else
		follow_leader()
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
