clearscreen.
run functionlib.
run hover.
print "functions loaded".
sas off.
set ship:control:pilotmainthrottle to 0.
print "waiting".
until alt:radar < 5000 {
properatmo().
}
clearscreen.
CLEARVECDRAWS().
slamit(200,1,100).//XtraD,PropAtmo,max Acceleration in meters/s^2.MUST INPUT .
clearscreen.
CLEARVECDRAWS().
lat(0).

set ship:control:neutralize to true.
wait 0.5.
SAS ON.
wait 2.
rcs off.
brakes off.
Sas off.
print "Expected Successful landing" at (0,11).

