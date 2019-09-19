//Circularization.
//This script can be restarted mid circularization IF ETA to Apoapsis is > "a" seconds.
// the ship must be capable of 30m\s^2 of acceleration or it won't work properly. 
//----- to find out acc =>  availablethrust= shipmass * acc  <=> acc= availablethrust / shipmass -------
run FunctionLib.
clearscreen.
print "Running Circularize" at (0,20).
lock steering to prograde.
wait until eta:apoapsis < 60.
// VARIABLES
declare local a to 30. // n seconds of eta to apoapsis as a start point
declare local detaap to a. // sets detaap to start point.
declare global gotap to ship:apoapsis.
declare local eMultiplier to 4.//Higher number means more aggressive and responsive throttle adjustment.
until ship:periapsis >=  gotap {
	// this "IF" is to avoid an infinity error 
	if abs(detaap/eta:apoapsis) < sqrt(ln((100/eMultiplier)+constant:e)) 
	{									  
		set dacc to min(30,eMultiplier*(constant:e^((detaap/eta:apoapsis)^2) - constant:e^1)). // this function e^(x^2)-e does not eturn infinity values but really high numbers.
	}else{ 
		set dacc to 30.
		PRINT " need to adjust DETAAP " at (0,10).
	}
	//-----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	if PERIAPSIS > 0{
		set a to 10.
		set detaap to a.
	}
	//POWER
	print round(dacc,2)+ " is daccval" at (0,3).
	lock throttle to ntval_calc(dacc).
	//feedback
	print detaap + " DE_ETA_AP" at (0,4).
	print round(gotap,1) + " is Target Peri" at (0,2).
	// better if this is at the end
	set gotap to ship:apoapsis-50.//50 is margin for overshoot and adjustment.
}
lock throttle to 0.
clearscreen.
sas on.