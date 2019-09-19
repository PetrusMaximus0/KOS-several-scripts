@lazyglobal off.
//-------------------------------
//Insert a personalized GUI .
//-------------------------------
clearscreen.//freshstart
//load functions library
run functionlib.// now use "currentg()." and "ntval_calc(dacc)."
print "loaded functions".
// check for situation

//-------------------------------------------------------------------------------------

print "waiting for launch conditions".
launchcond().
//set up 
launchprep().
//declare variables
declare global dacc to (15). //desired twr
declare global g to currentg(). // declare g variable
declare global ang to 90. // initial angle in current flight
declare global angc to 1. // declare multiplier to desired angle.
lock g to currentg().
print "parameters set".
wait 1.
//print feedback
print dacc + " is desired acc".
print "launching". 
wait 3.

stage.
wait 0.2.
gear off.
//power and trajectory guidance
until ship:altitude > 11000 
{
	//power
	lock throttle to ntval_calc(dacc).
	// steering
	set angc to (ship:altitude/11000). // at 11000m = 1
	print round(ang-angc*45)+" degrees" at (0,9). //at 11000m pitch will be 90-45*1 degrees
	lock steering to heading(90,(ang-angc*45)). // heading(compass heading, angle).
	print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
	//run stage logic
	stagelogic().
	wait 0.1.
}
set ang to 45.// setting to our expected current pitch at this time.
set dacc to 30. // new desired twr 
print dacc + " is desired acc" at (0,11).

//we let the engines loose with a 3.0 twr and continue the gravity turn so that 
//the ship points at 90ยบ by the time it reaches altitude 47 000 meters .

until ship:apoapsis >75000	
{
	//power
	lock throttle to ntval_calc(dacc).
	print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
	//steering
	set angc to ((ship:altitude-11000)/(47000-11000)). // angc is 1 at 47000m
	print round(ang-angc*45)+" degrees" at (0,9).
	lock steering to heading(90,(ang-angc*45)). // at 47 000m angle is 0 because ang is now 45º
	//run stage logic
	stagelogic().
	wait 0.1.
}	
//-------------------------------------------------------------------------------------------------------------------

//rudimentary circularization
clearscreen.
set throttle to 0.
lock steering to prograde.
declare global gotap to ship:apoapsis.
print round(gotap,2) + "is Target Peri" at (0,2).

until ship:periapsis >=  gotap {
	// VARIABLES
	declare local a to 20. // n seconds of eta to apoapsis as a start point
	declare local detaap to a. // sets detaap to start point.
	declare local mp to 10. // multiplier for dacc calc.
	declare local ecalc to constant:e^((detaap/eta:apoapsis)^2) - constant:e^1.
	
	// this is to avoid the infinity error (which isnt really infinity just a really high number)
	if abs(detaap/eta:apoapsis) < sqrt(ln(100+constant:e)) // something like 2,15
	{									  
			set dacc to (constant:e^((detaap/eta:apoapsis)^2) - constant:e^1). // this function e^(x^2)-e does not return infinity values.
	}else{ 
			set dacc to 100.
	}
	
	print "ecalc is this. " + ecalc at (0,5).// testing purposes
	stagelogic().
	if PERIAPSIS > 0{
		set a to 10.
		SET detaap TO 1+a-periapsis/gotap*a. // slowly reduce desired eta to periapsis until it is 0.
	}
	//POWER
	print round(dacc,2)+ " is daccval" at (0,3).
	//if dacc > 1{
		lock throttle to ntval_calc(dacc).
	//}else{
	//	lock throttle to 0.
	//}
	print detaap + " deetaap" at (0,4).
	wait 0.1.
}
sas on.
clearscreen.
print "Apoapsis: " at (0,1).
print round(APOAPSIS,2) at (4,1).
print "Periapsis: " at (0,2).
print round(PERIAPSIS,2) at (4,2).
print "Error is: " + (APOAPSIS - PERIAPSIS) + " meters" at (0,3).
