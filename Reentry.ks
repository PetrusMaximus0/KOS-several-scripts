run functionlib.
SAS off.
//SteeringManager:RESETTODEFAULT().
//SteeringManager:RESETPIDS().
//set steeringmanager:maxstoppingtime to 4.
//set steeringmanager:pitchts to 5.
//set steeringmanager:yawts to 5.
Global InputCoordinates to LATLNG(0,-42).//Barge
//Global InputCoordinates to LATLNG(-0.003,-41.2537).//GroundPad far Continent
//local InputCoordinates to LATLNG(-0.097,-74.558).//ksp
stagelogic().

ReentryHeadingCorrection(InputCoordinates).
if (ADDONS:TR:AVAILABLE) = true {
	ReentryPitchCorrection(InputCoordinates).	
}

rcs off.
slamit(400,1,40).//XtraD,PropAtmo,max engine Acceleration in meters/s^2.MUST INPUT .
LandIt(1).
set ship:control:neutralize to true.
wait 0.5.
SAS ON.
brakes off.
wait 2.
print "Expected Successful landing" at (0,11).
print "complete".
wait 5.
rcs off.
lights off.
sas off.
unlock all.