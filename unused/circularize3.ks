//Circularization.
//run FunctionLib.
clearscreen.
sas off.
rcs on.
print "Running Circularize3" at (0,20).
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
local kpp to 5.000.
local kdp to 0.500.
local kip to 0.050.
local ThrottleInput to kpp*CurrentError+kdp*DerivativeOfError+kip*IntegralError.
local dacc to 0.
local detaap to 20.
lock steering to prograde.
lock throttle to ntval_calc(dacc).
function ntval_calc{
   	// not accurate with SRBs attached.
	parameter dacc.//desired acceleration
	if ship:availablethrust > 0{
        return ship:mass*dacc/ship:availablethrust.	
   }else{
        return 0.
   }
}
// VARIABLES
wait until eta:apoapsis < 25.
declare global gotap to ship:apoapsis.
until ship:periapsis >=  gotap {			  
	set CurrentError to detaap-eta:apoapsis.
	set e0 to CurrentError.
	set t0 to time:seconds.
	wait 0.01.
	set CurrentError to detaap-eta:apoapsis.
	set e1 to CurrentError.
	set t1 to time:seconds.
	set deltaError to e1-e0.
	set deltaTime to t1-t0.
	Set DerivativeOfError to deltaError/deltaTime.
	set I0 to IntegralError.
	set I1 to deltaTime*((e0+e1)/2).
	set IntegralError to I0+I1.
	set ThrottleInput to kpp*CurrentError+kdp*DerivativeOfError+kip*IntegralError.
	print round(kpp*CurrentError,2) + "  p  " at (0,3).
	print round(kdp*DerivativeofError,2) + " d " at (0,4).
	print round(kip*IntegralError,2) + " i " at (0,5).
	print round(ThrottleInput,2) + "  Sum of All " at (0,6).
	set dacc to max(1,ThrottleInput).
	set gotap to ship:apoapsis-100.//50 is margin for overshoot and adjustment.
	if periapsis > 0 {
		set detaap to 10.
	}
	
}
lock throttle to 0.
clearscreen.
sas on.
unlock all.