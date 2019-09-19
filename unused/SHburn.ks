//Since I have a hard time accounting for fuel expenditure and thus ship mass change during the burn
//I've opted for a Semi-suicide burn and a touch down softly script.
clearscreen.
run functionlib.
print "functions loaded".
sas off.
set ship:control:pilotmainthrottle to 0.
lock steering to srfretrograde.
rcs on. 
slamit().
// select soft landing program depending on which body is orbiting.

if ship:body = "Kerbin" {
		print "Landing on Kerbin".
		lat(). //uses twr to modulate throttle.
	}else if ship:body = "Mun" {
		print "Landing on Mun".
		run lamun. //uses ship acceleration to modulate throttle.
	}else {
		lat().
		print "running default".
}
		
	// will add accordingly.

SAS ON.