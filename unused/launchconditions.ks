//make sure there conditions for a safe launch.
//can add more conditions such as launch schedule.
function launchcond {
	declare global launchconditions to false.
	if  
		ship:velocity:surface:mag < 1 
		and alt:radar <20 
		and stage:liquidfuel <= 0
	{
		set launchconditions to true.
		
		}
	wait until launchconditions = true.
	print "true".
}