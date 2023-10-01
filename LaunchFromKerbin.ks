//DESCRIPTION
//Launch a rocket from the launch pad, following an ascent profile.
//Manage staging

@lazyglobal off. 
//LIBRARY INCLUSION
runOncePath("utility.ks").
//GLOBAL VARIABLE DECLARATIONS
//FUNCTION DECLARATIONS
function preLaunch{
	set ship:control:pilotmainthrottle to 0.
	lights on.
	rcs on.
	sas off.
	print "setup complete".
	print "waiting for launch conditions".
	wait 1.
	if  (ship:status = "prelaunch" and stage:liquidfuel <= 0 and stage:solidfuel <= 0)  {
		print "Launch conditions met".
		print "Launching from prelaunch status".
		lock throttle to 1.
		stage.
	}else if  ship:status = "landed"{
		print "Launch conditions met".
		print "Launching from landed status, check headings".
		lock throttle to 1.	
	}
}
function followAscentProfile{
	//Power and trajectory guidance for ascent.
	//This script can be restarted mid flight.
	parameter OrbitHeading.
	parameter MaxAcc.
	parameter TargetApo.
	clearscreen.
	print "Running Ascent Guidance" at (0,20).
	//declare variables
	local desiredAcceleration to 15. //max desired acc initially
	local initialAngle to 90. // initial angle in current flight
	local angleAltitudeRatio to 0.
	lock throttle to ntval_calc(desiredAcceleration).
	lock steering to heading(OrbitHeading,(initialAngle-angleAltitudeRatio*45)).
	print "Target heading is " + OrbitHeading + " degrees".
	gear off.
	until ship:altitude > 11000 {
		set angleAltitudeRatio to (ship:altitude/11000). // at 11000m = 1
		print round(initialAngle-angleAltitudeRatio*45)+" degrees" at (0,9). //at 11000m pitch will be 90-45*1 degrees
		print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
		//abort_logic( heading(OrbitHeading,(initialAngle-angleAltitudeRatio*45)) ).
		wait 0.
			
	}
	set initialAngle to 45.// setting to our expected current pitch at this time.
	set desiredAcceleration to maxacc. // new desired acc
	print desiredAcceleration + " is desired acc" at (0,11).
	//30m\s max acc and continue the gravity turn so that 
	//the ship points at 0 degrees by the time it reaches altitude 47 000 meters .
	until ship:apoapsis > TargetApo	{
		set angleAltitudeRatio to ((ship:altitude-11000)/(47000-11000)). // angleAltitudeRatio is 1 at 47000m
		print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
		print round(initialAngle-angleAltitudeRatio*45)+" degrees" at (0,9).
		wait 0.
	}	
}
function ProgradeStabilize {
	local englist to list(0).
	list engines in englist.
	For eng in englist{
		eng:shutdown.
	}
	set ship:throttle to 0.
	set ship:control:pilotmainthrottle to 0.
	lock steering to prograde.
}

//PROGRAMs
clearscreen.
print "loaded functions".
preLaunch().
stageLogic().
followAscentProfile(90,40,100000).//(OrbitHeading,MaxAcc,TargetApo)
ProgradeStabilize().//shuts down engines
sas on.
rcs on.	
unlock all.
print " COMPLETE " at (0,1).
