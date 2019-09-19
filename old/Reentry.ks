run functionlib.
SteeringManager:RESETTODEFAULT().
set steeringmanager:maxstoppingtime to 4.
set steeringmanager:pitchts to 5.
set steeringmanager:yawts to 5.
Global InputCoordinates to LATLNG(0,-42).//Barge
//Global InputCoordinates to LATLNG(-0.003,-41.2537).//GroundPad far Continent
ReentryCorrection().
rcs off.
clearscreen.
lock throttle to 0.
slamit(500,1,60).//XtraD,PropAtmo,max engine Acceleration in meters/s^2.MUST INPUT .
clearscreen.
print "LANDIT 1"  at (20,25).
LandIt(1).
set ship:control:neutralize to true.
unlock steering.
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
clearscreen.