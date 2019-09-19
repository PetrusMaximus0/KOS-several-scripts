//Power and trajectory guidance for ascent.
//This script can be restarted mid flight.
clearscreen.
print "Running PaT Guidance" at (0,20).
//declare variables
declare global dacc to (15). //desired acc
declare global ang to 90. // initial angle in current flight
declare global angc to 1. // declare multiplier to desired angle.
declare global orbithead to 90. //Change this for a different orbit; ie: Polar Orbit is 0\180 degrees.

print "parameters set".
//print feedback
print dacc + " is desired acc".
print "Currently heading is " + orbithead + " degrees".
gear off.
stagelogic().
until ship:altitude > 11000 
{
	//power
	lock throttle to ntval_calc(dacc).
	// steering
	set angc to (ship:altitude/11000). // at 11000m = 1
	print round(ang-angc*45)+" degrees" at (0,9). //at 11000m pitch will be 90-45*1 degrees
	lock steering to heading(orbithead,(ang-angc*45)). // heading(compass heading, angle).
	print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
	wait 0.1.
	
}
// update power and guidance parameters
set ang to 45.// setting to our expected current pitch at this time.
set dacc to 30. // new desired acc
print dacc + " is desired acc" at (0,11).
//30m\s max acc and continue the gravity turn so that 
//the ship points at 0 degrees by the time it reaches altitude 47 000 meters .

until ship:apoapsis >75000	
{
	//power
	lock throttle to ntval_calc(dacc).
	print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
	//steering
	set angc to ((ship:altitude-11000)/(47000-11000)). // angc is 1 at 47000m
	print round(ang-angc*45)+" degrees" at (0,9).
	lock steering to heading(orbithead,(ang-angc*45)). // at 47 000m angle is 0 because ang is now 45º
	//run stage logic
	wait 0.1.
	
}	
