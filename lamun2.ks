// prep
clearscreen.
Run lamunlib.
sas off.
set ship:control:pilotmainthrottle to 0.
print " CHECK YOUR LZ COORDINATES" at (0,30).
//---------------------------------------
//1-Low pass over LZ, recommended 8000 to 10 000 altitude.
print " Node Phase" at (0,31).
if hasnode= "true" {
run exnode.
}
print " Approach Phase" at (0,32).
//2-run dircor when wangle less than 92.5.
munApproachLz().
unlock all.
//3-suicide horizontal burn at max acc, up to 30.
print " Slam Phase" at (0,33).
clearvecdraws().
munSlamHBurn().
unlock all.
print " Final Phase" at (0,34).
//4- final descent guide.
clearvecdraws().
gear on.
until ship:status ="landed" or verticalspeed > -1.5  {
	wait 0.001.
	munLandIt().
	munDescentLz().	//fall guidance
	
}
//clearvecdraws().
lock throttle to 0.
set ship:control:neutralize to true.
unlock steering.
Sas on.
wait 2.
rcs off.
