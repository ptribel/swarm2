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