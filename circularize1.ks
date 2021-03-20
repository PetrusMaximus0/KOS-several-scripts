clearscreen.
sas off.
rcs on.
lock steering to prograde.
run functionlib.
stagelogic().
print "Running Circularize 1" at (0,20).
local TargetApoapsis to 75000.
local OrbitHeading to 90.
local HeadingVector to 0.
local e1 to 0.
local e0 to 0.
local deltaError to 0.
local t1 to 0.
local t0 to 0.
local deltaTime to 0.
local DerivativeOfError to 0.
local CurrentError to 0.
local IntegralError to 0.
local I0 to 0.
local I1 to 0.
local kpp to 0.030.
local kdp to 0.099.
local kip to 0.001.
local PitchInput to kpp*CurrentError+kdp*DerivativeOfError+kip*IntegralError.
declare global gotap to ship:apoapsis.

until ship:apoapsis >= TargetApoapsis{
	lock throttle to 1.
}
lock throttle to ntval_calc(dacc).
until ship:periapsis >=  gotap {			  
	if Periapsis > 0 { 
		set dacc to 1. 
	}else{
		set dacc to 5.
	}
	if verticalspeed > 0 {
		set CurrentError to -TargetApoapsis+Apoapsis.
	}else{
		set CurrentError to -(TargetApoapsis+Altitude).
	}
	set e0 to CurrentError.
	set t0 to time:seconds.
	wait 0.01.
	if verticalspeed > 0 {
		set CurrentError to -TargetApoapsis+Apoapsis.
	}else{
		set CurrentError to -(TargetApoapsis+Altitude).
	}
	set e1 to CurrentError.
	set t1 to time:seconds.
	set deltaError to e1-e0.
	set deltaTime to t1-t0.
	Set DerivativeOfError to deltaError/deltaTime.
	set I0 to IntegralError.
	set I1 to deltaTime*((e0+e1)/2).
	set IntegralError to max(-200,min(I0+I1,200)).
	local CorrectPitchForETA to 0.
	if ETA:Apoapsis < 20 {
		set CorrectPitchForETA to 2*(20-ETA:apoapsis).
	}else {
		set CorrectPitchForETA to 0.
	}
	set PitchInput to kpp*CurrentError+kdp*DerivativeOfError+kip*IntegralError-CorrectPitchForETA.
	print round(kpp*CurrentError,2) + "  p  " at (0,3).
	print round(kdp*DerivativeofError,2) + " d " at (0,4).
	print round(kip*IntegralError,2) + " i " at (0,5).
	print round(PitchInput,2) + "  Sum of All " at (0,6).
	set HeadingVector to heading(OrbitHeading ,max(-35,min(35,-PitchInput))).
	lock steering to HeadingVector.
	wait 0.5.
	set gotap to TargetApoapsis-100.//50 is margin for overshoot and adjustment.
	if abs(currentError) < 10 
		set integralError to 0.
}
clearscreen.
sas on.
unlock all.