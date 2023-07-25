SPEED = 15
TARGET = 0

-- This function is executed every time you press the 'execute' button 
function init()
	robot.colored_blob_omnidirectional_camera.enable()
end

-- Drives with linear speed $forward and angular speed $angular. If $angular > 0, then the robot goes to the left.
function drive(forward, angular)
	robot.wheels.set_velocity(forward - angular, forward + angular)
end

-- Returns true if the four wheels of the robot are in the target zone
function is_in_target()
	local in_target = 0
	for i = 1, 4 do
	   if(robot.motor_ground[i].value == TARGET) then
	      in_target = in_target + 1
	    end
	end
	return in_target == 4
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

-- Returns the distance, angle and blue value of the closest robot that sees the light bulb
function get_closest_blue_neighbor()
	local neighbors = #robot.colored_blob_omnidirectional_camera
	local target = {distance = math.maxinteger, angle = math.maxinteger, blue = math.maxinteger}
	if neighbors > 0 then
		for i = 1, neighbors do
			if robot.colored_blob_omnidirectional_camera[i].color.blue > 0 and robot.colored_blob_omnidirectional_camera[i].distance < target.distance then
				target = {distance = robot.colored_blob_omnidirectional_camera[i].distance, angle = robot.colored_blob_omnidirectional_camera[i].angle, blue = robot.colored_blob_omnidirectional_camera[i].color.blue}
			end
		end
	end
	return target
end


function drive_to_blue_neighbor()
	robot.leds.set_single_color(13, 0, 0, 0)
	local closest_blue_neighbor = get_closest_blue_neighbor()
	if (closest_blue_neighbor.angle < math.maxinteger) then
		if (closest_blue_neighbor.angle > 0.2) then
			drive(0, 4)
		else
			if (closest_blue_neighbor.angle < -0.2) then
				drive(0, -4)
			else
				drive(SPEED, 0)
			end
		end
	else -- Drive randomly
		local random_angular_speed = robot.random.uniform_int(-5, 5)
		drive(SPEED-random_angular_speed, random_angular_speed)
	end
end

function count_neighbors_proportion()
	local neighbors = #robot.colored_blob_omnidirectional_camera
	local left_count = 0
	local right_count = 0
	local left_proportion = 0
	local right_proportion = 0
	if neighbors > 0 then
		for i = 1, neighbors do
			if robot.colored_blob_omnidirectional_camera[i].color.blue > 0 then
				if robot.colored_blob_omnidirectional_camera.angle[i] > 0.1 then
					left_count = left_count + 1
				else
					if robot.colored_blob_omnidirectional_camera.angle[i] < -0.1 then
						right_count = right_count + 1
					end
				end
			end
		end
		left_proportion = left_count / neighbors
		right_proportion = right_count / neighbors
	end
	return {left_proportion = left_proportion, right_proportion = right_proportion}
end

function drive_away_from_light()
	local random_speed = robot.random.uniform_int(-5, 5)
	local random_angular_speed = robot.random.uniform_int(-5, 5)
	local proportions = count_neighbors_proportion()
	drive(random_speed, random_angular_speed)
	robot.leds.set_single_color(13, 0, 0, 255)
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	if (not is_in_target()) then
		local brightest_index = get_brightest_index()
		if (brightest_index ~= 0) then -- Signal that you see the light
			drive_away_from_light()
		else -- Target the closest blue robot, hoping that you see the light
			drive_to_blue_neighbor()
		end
	else
		robot.leds.set_single_color(13, 0, 255, 0)
		drive(0, 0)
	end
end

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
end

--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end