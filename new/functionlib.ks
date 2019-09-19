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
global g                to 0.
global englist			to 0.
global dsvy				to 1.
global Vy 				to 0.
global h 				to 0.
global dsrtwr 			to 0.
global a 			   	to 0.
global dacc 		   		to 0.
global dist         		to 0.
global aReal		   		to 0.
global burndist      	to 0.
global ang 				to 0.
global angc 				to 0.
global errorangle		to 0.//for theta0.
global correction2Vec	    to 0.//eliminates "spin of death"
global RCSassistVec		to 0.
global kp 				to 0.
global kd 				to 0.
global ki 				to 0.
global theta0 			to 0.
global t0 				to 0.
global theta1 			to 0.
global t1 				to 0.
global deltatheta 		to 0. //change in angle.
global deltatime 		to 0.         //0.01 seconds.
global deltaerror 		to 0.  // change in angle per 0.01 seconds.
global k 				to 0.
global lastIntegralError	to 0.
global integralerror		to 0.
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
	set g to currentg().
	if Ship:AvailableThrust > 0{
		return DesiredTWR / (Ship:AvailableThrust / (Ship:Mass * g))  . //   tval = dtwr/(F/mg),  F = maxthrust
	}else{ 
		return 0. 
	}
}
function stagelogic{
	when true then {
		wait 0.2.	
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
	lock throttle to tval_calc(dsrtwr).
	until ship:status = "landed" {
		wait 0.
		set h to alt:radar.	
		if h > 80 {
			set dsvy to max((min(-8,(-h/20))),-40).
		}else {
			set dsvy to min(-2,6*(-h/40)).
		}		
		set Vy to ship:verticalspeed.
		set dsrtwr to (Vy/dsVy).	
		if hover = 1{
			hover().
		}		
		if dsrtwr > ship:availablethrust/(ship:mass*currentg()) {
			 brakes on.
		}else{ 
			 brakes off.
		}
		print "rad altitude: " + round(h,2) at (0,9).
		print "desired twr: " + round(dsrtwr,2) at (0,8).
		print "desired vertical speed: " + round(dsvy,2) at (0,7).		
	}
	set dsrtwr to 0.
	unlock ALL.
}
function Slamit{
	rcs on.
	//"slamit(XtraD,propatmo,maxG)."
	parameter XtraD. // Xtra distance to ground
	parameter PropAtmo.// 1 for yes 0 for no
	parameter MaxG.	//Mandatory Input!
	until false {
		wait 0.
		if propatmo = 1 {
			properatmo().
		}else if propatmo = 0{
			lock steering to srfretrograde.
		}
		set      a 		    to 		min(MaXG,(ship:availablethrust/ship:mass)). //acceleration
		set  	 Vy			to		abs(airspeed).
		set  	 dist		to      alt:radar. 		
		set      aReal		to		a-currentg().
		set		 burndist   to 		(Vy^2)/(2*aReal).
		
		print round (alt:radar,2)     +		"  Read alt radar "      	    at (0,14).
		print round (verticalspeed,2) +     "  Vertical speed " 			at (0,15).
		print round (burndist,2) 	  + 	"  Burn distance "  	 		at (0,16).
		print round (a,2) 			  + 	"  Raw available Accel "	    at (0,17).
		print round (aReal,2) 		  + 	"  Corrected Av. Accel "	    at (0,18).
		
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
		wait 0.
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
	set dacc to 15. //desired acc initially
	set ang to 90. // initial angle in current flight
	set angc to 0.
	lock throttle to ntval_calc(dacc).
	lock steering to heading(OrbitHeading,(ang-angc*45)).
	print "Target heading is " + OrbitHeading + " degrees".
	gear off.
	until ship:altitude > 11000 {
		set angc to (ship:altitude/11000). // at 11000m = 1
		print round(ang-angc*45)+" degrees" at (0,9). //at 11000m pitch will be 90-45*1 degrees
		print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
		wait 0.		
	}
	set ang to 45.// setting to our expected current pitch at this time.
	set dacc to maxacc. // new desired acc
	print dacc + " is desired acc" at (0,11).
	//30m\s max acc and continue the gravity turn so that 
	//the ship points at 0 degrees by the time it reaches altitude 47 000 meters .
	until ship:apoapsis > TargetApo	{
		
		print round(ship:availablethrust/ship:mass,2) + "max accel" at (0,10).
		set angc to ((ship:altitude-11000)/(47000-11000)). // angc is 1 at 47000m
		print round(ang-angc*45)+" degrees" at (0,9).
		wait 0.
	}	
}
function ReentryCorrection{
	clearscreen.
	set dacc to 0.
	lock throttle to ntval_calc(dacc).
	lock steering to prograde.
	print "Running Reentry " at (0,20).
	if verticalspeed > 0{
		wait until ship:altitude > 60000.
		print "Stand By... " at (0,21).
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
		set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
		set altvec to InputCoordinates:position-targetaltvec.
		set wangle to vang(altvec,targetaltvec).
		print "WAngle is  " + round(wangle,2)+ "    " at (0,5).	
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
		set wangle to vang (altvec,targetaltvec).
		print "Wangle is  " + round(wangle,2)+ "    " at (0,4).
	}
	set dacc to 0.
	wait 5.
	clearscreen.
	lock steering to Lookdirup(-ship:velocity:surface,ship:body:position).
	wait until vang(velocity:surface,-facing:forevector) < 5.
	if altitude > 50000 {
		UNTIL (VXCL(ship:facing:starvector,v(0,0,0)+Trimpact)-VXCL(shIP:facing:starvector,v(0,0,0)+InputCoordinates:position)):mag < 1000 {
			if (v(0,0,0)+Trimpact):mag < (v(0,0,0)+InputCoordinates:position):mag {
				until VXCL(ship:facing:starvector,v(0,0,0)+Trimpact)-VXCL(shIP:facing:starvector,v(0,0,0)+InputCoordinates:position)):mag > 200 {
					set TrImpact to addons:tr:impactpos:position.
					lock steering to -ship:body:position-ship:velocity:surface.
					wait until vang(-ship:body:position,-facing:forevector) < 10.
					set dacc to 30.
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
	}
	set dacc to 0.
	Print "angle correct ENDED    " at (10,10).
	unlock all.
}
function properatmo{
	//vectors
	set targetaltvec 		to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	set altvec 				to InputCoordinates:position-targetaltvec.
	set progradePground 		to VXCL(up:vector,velocity:surface).
	set wangle 				to vang (altvec,targetaltvec).
	set errorangle 			to vang (InputCoordinates:position,altvec).//for theta0.
	set correction2Vec 		to VXCL(VXCL(up:vector,targetaltvec),ProgradePground).//eliminates "spin of death"
	set RCSassistVec 		to (v(0,0,0)+InputCoordinates:altitudeposition(ship:altitude)).
	//multipliers adjust as necessary.
	set kd to 1.76. // 
	set kp to 1.9. //
	//
	set theta0 to errorangle.
	set t0 to TIME:SECONDS.
	//give time
	wait 0.02.
	set errorangle to vang (InputCoordinates:position,altvec).//calc it for theta1.
	set theta1 to errorangle.
	set t1 to TIME:SECONDS.
	//deltas
	set deltatheta to theta1-theta0. //change in angle.
	set deltatime to t1-t0.         //0.01 seconds.
	set deltaerror to deltatheta/deltatime.  // change in angle per 0.01 seconds.
	//
	set k to 1*kp + kd*deltaerror.
	set correctionvector to -(k*targetaltvec + InputCoordinates:position-30*correction2Vec).
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
function hover{
	set lastIntegralError to 0.
	brakes on.
	//vectors
	set targetaltvec to inputcoordinates:ALTITUDEPOSITION(ship:altitude).
	set InputCoordinates to inputcoordinates.
	set altvec to InputCoordinates:position-targetaltvec.
	set RCSassistVec to (v(0,0,0)+InputCoordinates:altitudeposition(ship:altitude)).
	set errorangle to vang (InputCoordinates:position,altvec).//for theta0.
	set ProgradePground to VXCL(up:vector,velocity:surface).
	set correction2Vec to VXCL(VXCL(up:vector,targetaltvec),ProgradePground).
	//multipliers adjust as necessary.
	set kp to 0.45. //to remember this is not the real KP
	set kd to 0.225. // 
	set ki to 0.// don't use this because error is always > 0.
	//derivative of the change in angle over time
	set theta0 to errorangle.
	set t0 to TIME:SECONDS.
		//give time
	wait 0.02.
	set errorangle to vang (InputCoordinates:position,altvec).//calc it for theta1.
	set theta1 to errorangle.
	set t1 to TIME:SECONDS.
	//Integral calc and limiter this isnt really necessary, see above.
	set IntegralError to min(10,lastIntegralError+((theta0+theta1)/2)*(t1-t0)).
	set lastIntegralError to IntegralError.
	//deltas
	set deltatheta to theta1-theta0.
	set deltatime to t1-t0.
	set deltaerror to deltatheta/deltatime.
	// K is a multiplier to the amount of angle that the correction vector will have.
		// the "1" is a placeholder for the proportional part of the controller.
		// The real proportional part is calculated by the vector math and tuned by kp.
	//	The lower k the lower angle. The reverse applies.
	set k to 1*kp + kd*deltaerror + ki*integralerror . // when k = 1 the ship will point at a 45ยบ angle
	set correctionvector to k*(targetaltvec)-altvec-8*correction2Vec .
	if errorangle > 4 {
		if alt:radar > 50 {	
			if errorangle > 40 and alt:radar < 200{
				lock steering to -(ship:velocity:surface:normalized+ship:body:position:normalized).
				print "Mode is 3B: Retrograde OFF target(failsafe)    " at (5,12).
			}else{
				lock steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 1: Correcting                 " at (5,12).
			}		
		}else if alt:radar < 50{			
			if errorangle < 40 {
				lock steering to lookdirup(correctionvector,v(0,0,1)).
				print "Mode is 1: Correcting               " at (5,12).
			}else {
				lock steering to -(ship:velocity:surface:normalized+SHIP:BODY:POSITION:normalized).
				print "Mode is 3: Retrograde OFF target              " at (5,12).
			}
		}
	}else if errorangle < 4 {//needs to be adjusted for shipheight.
		
		lock steering to lookdirup(-(ship:body:position:normalized+0.66*velocity:surface:normalized),v(0,0,1)).
		print "Mode is 4: Retrograde on Point!               " at (5,12).
		
		if Vang(RCSassistVec,ship:facing:topvector) < 89 {
			set ship:control:top to 1.
		}else if Vang(RCSassistVec,ship:facing:topvector) > 91 {
			set ship:control:top to -1.
		}else{
			set ship:control:top to 0.
		}		
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
}
function launchProcedure{
	if ship:status = "prelaunch" {
		print "waiting for launch conditions".
		launchcond().
		launchprep().
		print "Launching from prelaunch status".
		lock throttle to 1.
		stage.
			
	}else if ship:status = "landed"{	
		print "waiting for launch conditions".
		launchcond().
		launchprep().	
		print "Launching from landed status, check headings".
		wait 1.
		lock throttle to 1.

	}
}
function ProgradeStabilize {
	local englist to 0.
	list engines in englist.
	For eng in englist{
		eng:shutdown.
	}
	set throttle to 0.
	set ship:control:pilotmainthrottle to 0.
	lock steering to prograde.
}




