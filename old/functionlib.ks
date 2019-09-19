// Kerbin Function LiB
// DO NOT MESS THE ORDER OF THE FUNCTIONS!
@lazyglobal off.
set ship:control:pilotmainthrottle to 0.
sas off.
rcs on.
global targetaltvec 		to 0.
global altvec 			to 0.
global TrImpact 			to 0.
global progradePground	to 0.
global wangle 			to 0.
global correctionvector 	to 0.
function currentg{
	return (ship:body):mu /(SHIP:ALTITUDE + (ship:body):RADIUS)^2.
}
function ntval_calc{
   	// not accurate with SRBs attached.
	parameter dacc.//desired acceleration
	if ship:availablethrust > 0{
        return ship:mass*dacc/ship:availablethrust.	
   }else{
        return 0.
   }
}
function tval_calc{
	// not accurate with SRBs attached.
	parameter DesiredTwr.
	declare local g to currentg().
	if Ship:AvailableThrust > 0{
		return DesiredTWR / (Ship:AvailableThrust / (Ship:Mass * g))  . //   tval = dtwr/(F/mg),  F = maxthrust
	}else{ 
		return 0. 
	}
}
function stagelogic{
	when true then {
		wait 0.2.
		declare global englist to 0.
		list engines in englist.
		For eng in englist{
			if eng:FLAMEOUT = true {
				stage.
				wait 0.5.
				if availablethrust > 0 {
					Return false.
				}
			}
			if eng:ignition = false and eng:stage=stage:number
			{			
			eng:activate.
			}
		}
		preserve.
	}
	
}
function LandIt{
	SteeringManager:RESETTODEFAULT().
	parameter hover.
	gear on.
	lights on.
	Print "maintaining speed".
	declare local dsvy to 1.
	declare local Vy to ship:verticalspeed.
	declare local h to alt:radar.
	declare local dsrtwr to (Vy/dsVy).	
	lock throttle to tval_calc(dsrtwr).
	until (ship:status = "landed" or ship:status = "splashed") {
		
		set Vy to ship:verticalspeed.
		set h to alt:radar.
		set dsrtwr to (Vy/dsVy).
		if h > 80 {
			set dsvy to max((min(-8,(-h/20))),-40).
		}else {
			set dsvy to min(-2,6*(-h/40)).
		}
		if dsrtwr > ship:availablethrust/( ship:mass*currentg() ) {
			 brakes on.
		}else{ 
			 brakes off.
		}	
		if hover = 1
			hover().

		print "rad altitude: " + round(h,2) at (0,9).
		print "desired twr: " + round(dsrtwr,2) at (0,8).
		print "desired vertical speed: " + round(dsvy,2) at (0,7).	
		wait 0.
	}
	lock throttle to 0.
	unlock all.
}
function Slamit{
	rcs on.
	//"slamit(XtraD,propatmo,maxG)."
	parameter XtraD. // Xtra distance to ground
	parameter PropAtmo.// 1 for yes 0 for no
	parameter MaxG.	//Mandatory Input!
	
	declare local    a 			   to 		min(MaXG,(ship:availablethrust/ship:mass)).
	declare global 	 dacc 		   to 		0.
	declare local    Vy            to       abs(airspeed).
	declare local    dist          to       alt:radar.
	declare local    aReal		   to		a-currentg().
	declare local    burndist      to       (Vy^2)/2*aReal.
	
	until false {
		if propatmo = 1 {
			properatmo().
			wait 0.1.
		}else if propatmo = 0{
			lock steering to srfretrograde.
			wait 0.1.
		}
		print round (alt:radar,2)     +		"  Read alt radar "      	    at (0,14).
		print round (verticalspeed,2) +     "  Vertical speed " 			at (0,15).
		print round (burndist,2) 	  + 	"  Burn distance "  	 		at (0,16).
		print round (a,2) 			  + 	"  Raw available Accel "	    at (0,17).
		print round (aReal,2) 		  + 	"  Corrected Av. Accel "	    at (0,18).
	
		set      a 		    to 		min(MaXG,(ship:availablethrust/ship:mass)). //acceleration
		set  	 Vy			to		abs(airspeed).
		set  	 dist		to      alt:radar. 		
		set      aReal		to		a-currentg().
		set		 burndist   to 		(Vy^2)/(2*aReal).
		
		if  burndist+XtraD > dist and alt:radar < 5000  {
			clearscreen.
			set dacc to a.
			Break.
		}
	}	
	gear on.
	until verticalspeed > -30{
		brakes off.
		lock steering to srfretrograde.
		lock throttle to ntval_calc(dacc).
		wait 0.1.
		}

}	
function launchcond{

	declare local launchconditions to false.
	until launchconditions = true {
		wait 1.
		if  ship:status = "prelaunch" and stage:liquidfuel <= 0 and stage:solidfuel <= 0{
			set launchconditions to true.
			clearscreen.
			wait 0.1.
			print "Launch conditions met".
		}else if  ship:status = "landed"{
			set launchconditions to true.
			clearscreen.
			wait 0.1.
			print "Launch conditions met".
		}
	}
}
function launchprep{
	set ship:control:pilotmainthrottle to 0.
	lights on.
	rcs on.
	sas off.
	print "setup complete".
}
function Rocket_Ascent{
	//Power and trajectory guidance for ascent.
	//This script can be restarted mid flight.
	parameter OrbitHeading.
	parameter MaxAcc.
	parameter TargetApo.
	clearscreen.
	print "Running Ascent Guidance" at (0,20).
	//declare variables
	declare global dacc to (15). //desired acc initially
	declare local ang to 90. // initial angle in current flight
	declare local angc to 1. // declare multiplier to desired angle.
	//declare global orbithead to OrbitHeading. //Change this for a different orbit; ie: Polar Orbit is 0\180 degrees.
	print "parameters set".
	//print feedback
	print dacc + " is desired acc".
	print "Target heading is " + OrbitHeading + " degrees".
	gear off.
	
	until ship:altitude > 11000 
	{
		//power
		lock throttle to ntval_calc(dacc).
		// steering
		set angc to (ship:altitude/11000). // at 11000m = 1
		print round(ang-angc*45)+" degrees" at (0,9). //at 11000m pitch will be 90-45*1 degrees
		lock steering to heading(OrbitHeading,(ang-angc*45)). // heading(compass heading, angle).
		print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
		wait 0.1.
		
	}
	declare global englist to 0.
	list engines in englist.
	// update power and guidance parameters
	set ang to 45.// setting to our expected current pitch at this time.
	set dacc to maxacc. // new desired acc
	print dacc + " is desired acc" at (0,11).
	//30m\s max acc and continue the gravity turn so that 
	//the ship points at 0 degrees by the time it reaches altitude 47 000 meters .
	
	until ship:apoapsis > TargetApo	
	{
		//power
		lock throttle to ntval_calc(dacc).
		print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
		//steering
		set angc to ((ship:altitude-11000)/(47000-11000)). // angc is 1 at 47000m
		print round(ang-angc*45)+" degrees" at (0,9).
		lock steering to heading(OrbitHeading,(ang-angc*45)). // at 47 000m angle is 0 because ang is now 45ยบ
		//run stage logic
		wait 0.1.
	}	
}
function ReentryCorrection{
	clearscreen.
	declare local dacc to 0.
	lock throttle to ntval_calc(dacc).
	lock steering to prograde.
	print "Running Reentry " at (0,20).
	print "Stand By... " at (0,21).
	if verticalspeed>0{
		wait until ship:altitude > 60000.
	}
	//stage.
	clearscreen.
	set TrImpact to addons:tr:impactpos:position.
	set progradePground to VXCL(up:vector,velocity:surface).
	set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	set altvec to InputCoordinates:position-targetaltvec.
	set wangle to vang (altvec,targetaltvec).
	set correctionvector to VXCL(up:vector,-(progradepground:normalized-targetaltvec:normalized)).
	until wangle < 100 {
		print "WAngle is  " + round(wangle,2)+ "    " at (0,5).	
		set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
		set altvec to InputCoordinates:position-targetaltvec.
		set wangle to vang(altvec,targetaltvec).
	}
	until vang(progradePground,targetaltvec)< (max(90,wangle)-89.9) or altitude < 50000 {
		wait 0.01.
		set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
		set altvec to InputCoordinates:position-targetaltvec.
		set progradePground to VXCL(up:vector,velocity:surface).
		set correctionvector to VXCL(up:vector,-(progradepground:normalized-targetaltvec:normalized)).
		if vang(progradePground,targetaltvec)> 0.5 {
			print "Adjusting   " + "          " at (0,2).
			print "Angle is  " + round(vang(progradePground,targetaltvec),2)+ "    " at (0,3).
			lock steering to correctionvector.
			if vang(correctionvector,ship:facing:forevector) < 2 {
				set dacc to vang(progradePground,targetaltvec).
			}else{
				set dacc to 0.
			}
		}else{
			set dacc to 0.
			print "All Good    " at (0,2).
			print "Angle is " + round(vang(progradePground,targetaltvec),2)+ "    " at (0,3).
		}
		lock throttle to ntval_calc(dacc). 
		set wangle to vang (altvec,targetaltvec).
		print "Wangle is  " + round(wangle,2)+ "    " at (0,4).
	}
	set dacc to 0.
	clearscreen.
	lock steering to Lookdirup(-ship:velocity:surface,ship:body:position).
	wait until vang(velocity:surface,-facing:forevector) < 5.
	UNTIL (VXCL(ship:facing:starvector,v(0,0,0)+Trimpact)-VXCL(shIP:facing:starvector,v(0,0,0)+InputCoordinates:position)):mag < 1000 or altitude< 50000 {
		wait 0.01.
		if (v(0,0,0)+Trimpact):mag < (v(0,0,0)+InputCoordinates:position):mag {
			until (v(0,0,0)+Trimpact):mag > (v(0,0,0)+InputCoordinates:position):mag + 200{
				set TrImpact to addons:tr:impactpos:position.
				lock steering to -ship:body:position-ship:velocity:surface.
				//wait until vang(-ship:body:position,-facing:forevector) < 30.
				set dacc to 100.
			}
		}else{
			lock steering to VXCL(up:vector,-velocity:surface).
			wait until vang(ship:facing:vector, VXCL(up:vector,-velocity:surface)) < 10 .
			set TrImpact to addons:tr:impactpos:position.
			Print "Correcting for pitch" at (10,10).
			Print " D IS " + (VXCL(ship:facing:starvector,v(0,0,0)+Trimpact)-VXCL(shIP:facing:starvector,v(0,0,0)+InputCoordinates:position)):mag  at  (10,12).
			set dacc to max(20,vang(TrImpact,InputCoordinates:position)).
		}
		
	}
	set dacc to 0.
	Print "angle correct ENDED    " at (10,10).
	unlock all.
}
function properatmo {
	//vectors
	declare local targetaltvec 			to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	declare local altvec 				to InputCoordinates:position-targetaltvec.
	declare local progradePground 		to VXCL(up:vector,velocity:surface).
	declare local wangle 				to vang (altvec,targetaltvec).
	declare local errorangle 			to vang (InputCoordinates:position,altvec).//for theta0.
	declare local correction2Vec 		    to VXCL(VXCL(up:vector,targetaltvec),ProgradePground).//eliminates "spin of death"
	declare local RCSassistVec 			to (v(0,0,0)+InputCoordinates:altitudeposition(ship:altitude)).
	//multipliers adjust as necessary.
	local kd to 1.76. // 
	local kp to 1.9. //
	//
	local theta0 to errorangle.
	local t0 to TIME:SECONDS.
		//give time
	wait 0.01.
	set errorangle to vang (InputCoordinates:position,altvec).//calc it for theta1.
	local theta1 to errorangle.
	local t1 to TIME:SECONDS.
	//deltas
	local deltatheta to theta1-theta0. //change in angle.
	local deltatime to t1-t0.         //0.01 seconds.
	local deltaerror to deltatheta/deltatime.  // change in angle per 0.01 seconds.
	//
	local k to 1*kp + kd*deltaerror.
	local correctionvector to -(k*targetaltvec + InputCoordinates:position-30*correction2Vec).
	//
	if wangle < 92.5 or alt:radar < 20000 {
		if errorangle < 1  { 
			lock steering to -InputCoordinates:position.
			print "    steering to TARGET  LZ   " at (0,7).
			if Vang(RCSassistVec,ship:facing:topvector) < 90 {
					set ship:control:top to 1.
			}else if Vang(RCSassistVec,ship:facing:topvector) > 90 {
				set ship:control:top to -1.
			}else{
				set ship:control:top to 0.
			}
			
			if vang(RCSassistVec,ship:facing:starvector) < 90 {
				set ship:control:starboard to 1.
			}else if vang(RCSassistVec,ship:facing:starvector) > 90 {
				set ship:control:starboard to -1.
			}else{
				set ship:control:starboard to 0.
			}		
		}
		
		if errorangle > 1 {
			lock steering to correctionvector.
			print "     adjusting   " at (0,7). 
		}
	
	}else { 
			lock steering to srfretrograde.
	}
	//print "INTEGRAL ERROR"  + round (integralerror,3)+ "   " 													at (0,1).
	print "ERROR ANGLE "	+ round (vang (InputCoordinates:position,altvec),2) 										at (0,6).
	print "DELTATIME " 		+ round (deltatime,3)  + "   " 														at (0,2).
	print "DELTATHETA " 	+ round (deltatheta,3) + " = " + round(theta1,2) + " - " + round(theta0,2)			at (0,3). 
	print "DELTAERROR " 	+ round (deltaerror,3) + "   "  						 							at (0,4).
	print "K FACTOR "  		+ round (k,3)          + "   " 							 							at (0,5).
	//
	
	
	if (errorangle < 40 or alt:radar < 4000)  and velocity:surface:mag > 200{
		brakes on.
	}else if velocity:surface:mag > 800 and (alt:radar > 4000 and alt:radar < 20000){
		brakes on.
	}else{
		brakes off.
	}	
	if (errorangle > 50 and alt:radar < 5000) { //failsafe.
		clearscreen.
		Print " RUNNING FAILSAFE " at (0,1).
		Slamit(50,0,100).
		LandIt(0).
		return 0.
	}
}
function hover {
	local lastIntegralError to 0.
	brakes on.
	//vectors
	local targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	local InputCoordinates to inputcoordinates.
	local altvec to InputCoordinates:position-targetaltvec.
	local RCSassistVec to (v(0,0,0)+InputCoordinates:altitudeposition(ship:altitude)).
	local errorangle to vang (InputCoordinates:position,altvec).//for theta0.
	local ProgradePground to VXCL(up:vector,velocity:surface).
	local correction2Vec to VXCL(VXCL(up:vector,targetaltvec),ProgradePground).
	//multipliers adjust as necessary.
	local kp to 0.45. //to remember this is not the real KP
	local kd to 0.225. // 
	local ki to 0.// don't use this because error is always > 0.
	//derivative of the change in angle over time
	local theta0 to errorangle.
	local t0 to TIME:SECONDS.
		//give time
	wait 0.01.
	set errorangle to vang (InputCoordinates:position,altvec).//calc it for theta1.
	local theta1 to errorangle.
	local t1 to TIME:SECONDS.
	//Integral calc and limiter this isnt really necessary, see above.
	local IntegralError to min(10,lastIntegralError+((theta0+theta1)/2)*(t1-t0)).
	set lastIntegralError to IntegralError.
	//deltas
	local deltatheta to theta1-theta0.
	local deltatime to t1-t0.
	local deltaerror to deltatheta/deltatime.
	// K is a multiplier to the amount of angle that the correction vector will have.
		// the "1" is a placeholder for the proportional part of the controller.
		// The real proportional part is calculated by the vector math and tuned by kp.
	local k to 1*kp + kd*deltaerror + ki*integralerror . 
	// when k = 1 the ship will point at a 45ยบ angle
	//	The lower k the lower angle. The reverse applies.
	local correctionvector to k*(targetaltvec)-altvec-8*correction2Vec .
	if errorangle > 4 {
		wait 0.
		if alt:radar > 50 {
			wait 0.
			if errorangle > 40 and alt:radar < 200{
				set steering to -(ship:velocity:surface:normalized+ship:body:position:normalized).
				print "Mode is 3B: Retrograde OFF target(failsafe)    " at (5,12).
			}else{
				set steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 1: Correcting                 " at (5,12).
			}
		
		}else if alt:radar < 50{
			wait 0.
			if errorangle < 40 {
				set steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 1: Correcting               " at (5,12).
			}else {
				set steering to -(ship:velocity:surface:normalized+SHIP:BODY:POSITION:normalized).
				print "Mode is 3: Retrograde OFF target              " at (5,12).
			}
		}
	}else if errorangle < 4 {//needs to be adjusted for shipheight.
		
		set steering to lookdirup(-(ship:body:position:normalized+0.66*velocity:surface:normalized),v(0,0,1)).
		print "Mode is 4: Retrograde on Point!               " at (5,12).
		wait 0.01.
		if Vang(RCSassistVec,ship:facing:topvector) < 89 {
			set ship:control:top to 1.
		}else if Vang(RCSassistVec,ship:facing:topvector) > 91 {
			set ship:control:top to -1.
		}else{
			set ship:control:top to 0.
		}
		wait 0.01.
		if vang(RCSassistVec,ship:facing:starvector) < 89 {
			set ship:control:starboard to 1.
		}else if vang(RCSassistVec,ship:facing:starvector) > 91 {
			set ship:control:starboard to -1.
		}else{
			set ship:control:starboard to 0.
		}
	}
	wait 0.
	//	
	print "INTEGRAL ERROR"   + round (integralerror,3)+ "   " 													at (0,1).
	print "ERROR ANGLE "	 + round (vang (InputCoordinates:position,altvec),2) 										at (0,6).
	print "DELTA TIME " 	 + round (deltatime,3)  + "   " 													at (0,2).
	print "DELTA THETA " 	 + round (deltatheta,3) + " = " + round(theta1,2) + " - " + round(theta0,2)			at (0,3). 
	print "DELTA ERROR " 	 + round (deltaerror,3) + "   "  						 							at (0,4).
	print "K FACTOR "  		 + round (k,3)          + "   " 							 						at (0,5).
	print "TARGET DISTANCE " + round (InputCoordinates:POSITION:mag,1)+ "   " 											at (20,5).
	//
}.