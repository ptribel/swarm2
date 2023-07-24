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

-- Returns the distance, angle and red value of the signaling an obstacle in the target.
function get_obstacle()
	local neighbors = #robot.colored_blob_omnidirectional_camera
	local obstacle = {distance = math.maxinteger, angle = 0, red = math.maxinteger}
	if neighbors > 0 then
		for i = 1, neighbors do
			if robot.colored_blob_omnidirectional_camera[i].color.red > 0 and robot.colored_blob_omnidirectional_camera[i].distance < obstacle.distance then
				obstacle = {distance = robot.colored_blob_omnidirectional_camera[i].distance, angle = robot.colored_blob_omnidirectional_camera[i].angle, red = robot.colored_blob_omnidirectional_camera[i].color.red}
			end
		end
	end
	return obstacle
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
