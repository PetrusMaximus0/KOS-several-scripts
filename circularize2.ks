@lazyglobal off.
clearscreen.
print "Running Circularize 2" at (0,20).
SAS OFF.
rcs on.
run functionlib.
stagelogic().
wait 2.// waits for engine ON
local TargetApoapsis to SHIP:APOAPSIS.
local OrbitHeading to 90.
local dacc to 0.
//local maxAccel to 2.//aceleração máxima desejada
local DeltaVforManeuver to OrbitalSpeedCircular(TargetApoapsis)-OrbitalSpeedAtCritPointEliptical("AP").
local ExhaustVelocity to AverageISP()*9.80655.//constant:g0 on later versions of KOS
local BurnTime to (ship:mass*ExhaustVelocity/ship:availablethrust)*(1-constant:e^(-DeltaVforManeuver/ExhaustVelocity)).
//local BurnTime to (ExhaustVelocity/maxAccel)*(1-constant:e^(-DeltaVforManeuver/ExhaustVelocity)).
local BurnStartTime to time:seconds + ETA:apoapsis - BurnTime/2.
local BurnEndTime to time:seconds + ETA:apoapsis + BurnTime/2.
local CircularizeNode to NODE(time:seconds + ETA:apoapsis, 0, 0, DeltaVforManeuver).
local t0 to 0.
local t1 to 0.
local TimeDelay to 0.

lock throttle to ntval_calc(dacc).
Add CircularizeNode.


print "Orbital Circular Speed "+ OrbitalSpeedCircular(TargetApoapsis) at (0,7).
print "Transfer Orbit Speed "+ OrbitalSpeedAtCritPointEliptical("AP") at (0,8).
print "BurnStartTime " + BurnStartTime + " BurnEndTime " + BurnEndTime + " Total Burn Time " + BurnTime at (0,4).
print "DeltaVforManeuver " + DeltaVforManeuver at (0,6).
	set t0 to time:seconds.


until (time:seconds >= BurnStartTime-TimeDelay){
	set t1 to time:seconds.	
	set steering to srfprograde.
	if ( time:seconds+20 >= BurnStartTime ) {
		set steering to CircularizeNode:deltaV.
	
	}
	set TimeDelay to t1 - t0.
	print "TimeLeft for burn " + (-time:seconds + BurnStartTime) at (0,2).
	print "Latency " + round(TimeDelay,6) + "                                                                  " at (0,17).
	set t0 to t1.
}

until (time:seconds >= BurnEndTime+TimeDelay ) {
	//engine is shutting off too early. The calculated time matches the node calculated time.
		//thank you for this comment past me, it helped me realize this had a prior mistake :)) 
	set dacc to 100.
	set steering to CircularizeNode:deltaV.
	print "TimeLeft for MECO " + (BurnEndTime-time:seconds) at (0,2).
	print "Latency " + round(TimeDelay,6) + "                                                                  " at (0,17).
}
print "Engines OFF " at (0,5).
SET DACC TO 0.
//exnode().
//clearscreen.
ProgradeStabilize().
Remove CircularizeNode.
unlock all.