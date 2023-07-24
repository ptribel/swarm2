SPEED = 15
RED = 0
GREEN = 0
BLUE = 255

--[[ This function is executed every time you press the 'execute' button ]]
function init()
	robot.leds.set_single_color(13, RED, GREEN, BLUE)
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

function count_left_neighbors()
	return 0
end

function count_right_neighbors()
	return 0
end

function drive_away_from_light_source()
	local brightest_index = get_brightest_index()
	if (brightest_index == 0) then
		t = robot.random.uniform_int(0, 5)
		drive(SPEED-t, t)
	else
		left_neighbors = count_left_neighbors()
		right_neighbors = count_right_neighbors()
		if (brightest_index ~= 12) then
			drive(4, SPEED-4)
		else
			drive(SPEED, 0)
		end
	end
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
   drive_away_from_light_source()
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
