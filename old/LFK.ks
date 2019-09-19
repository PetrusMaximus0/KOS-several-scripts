@lazyglobal off. 
//Launch from Kerbin. Works with boosters

clearscreen.
run functionlib.
print "loaded functions".
if ship:status = "prelaunch" or ship:status = "landed"{
	print "waiting for launch conditions".
	launchcond().
	launchprep().
	if ship:status = "prelaunch"{
		print "Launching from prelaunch status".
		lock throttle to 1.
		stage.
			
	}else if ship:status = "landed"{	
			print "Launching from landed status, check headings".
			wait 1.
			lock throttle to 1.
	}
}
stagelogic().
Rocket_Ascent(90,30,75000).//(OrbitHeading,MaxAcc,TargetApo)
clearscreen.
declare global englist to 0.
list engines in englist.
For eng in englist{
	eng:shutdown.
}
set throttle to 0.
set ship:control:pilotmainthrottle to 0.
lock steering to prograde.
//chose which to run
print "Run Circularize or Reentry " at (10,1).
sas on.
rcs on.	
unlock all.
	


