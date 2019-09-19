clearscreen.
run functionlib.
run hover.

if ship:mass > 100 {
	steermantune().
	print " adjusted steering manager " at (0,15).
}

print "functions loaded".
sas off.
set ship:control:pilotmainthrottle to 0.
print "waiting".
until alt:radar < 6000 {

properatmo().
}
clearscreen.
CLEARVECDRAWS().
slamit(0,1,100).//XtraD,PropAtmo,maxG. MUST INPUT MAX G.
clearscreen.
CLEARVECDRAWS().
lock steering to -ship:body:position.
lat(1).//0 for normal,1 for nothing

set ship:control:neutralize to true.
SAS ON.
wait 2.
rcs off.
brakes off.
Sas off.
print "Expected Successful landing" at (0,11).

