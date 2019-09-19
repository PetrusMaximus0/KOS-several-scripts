clearscreen.
run functionlib.
gear on.
Print "maintaining speed".
slamit(70,0,100).
lock steering to srfretrograde.
brakes on.

until ship:status = "landed" {
	wait 0.01.
	declare local Vy to ship:verticalspeed.
	declare local h to alt:radar.
	declare local dsvy to 0.
	//
	if h > 80 {set dsvy to max((min(-8,(-h/20))),-40).// min here means faster downward speed, or > abs value of Vy.
	}else {
		set dsvy to min(-4,6*(-h/40)).
	}
	//
	declare local dsrtwr to (Vy/dsVy).
	print "rad altitude: " + round(h,2) at (0,9).
	print "desired twr: " + round(dsrtwr,2) at (0,8).
	print "desired vertical speed: " + round(dsvy,2) at (0,7).
	//
	if dsrtwr > ship:availablethrust/(ship:mass*currentg())		
		 {
		  brakes on.
	}else{ 
		 brakes off.
	}
	//
	if dsrtwr < 1 {
			lock throttle to 0.
	}else{
			lock throttle to tval_calc(dsrtwr).
	}
}
lock throttle to 0.
unlock steering.
