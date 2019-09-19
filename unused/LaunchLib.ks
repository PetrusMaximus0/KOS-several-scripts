// commonly used functions
// find g function, wherever.
function currentg {
	return (ship:body):mu /(SHIP:ALTITUDE + (ship:body):RADIUS)^2.
}
//adjust throttle to match an intended accel. not accurate with solidrockets attached.
function ntval_calc {
   	parameter dacc.
	if ship:availablethrust > 0{
        return ship:mass*dacc/ship:availablethrust.	
   }else{
        return 0.
   }
}

function tval_calc {
	parameter DesiredTwr.
			 
	declare local g to currentg().
	
	if Ship:AvailableThrust > 0{
		return DesiredTWR / (Ship:AvailableThrust / (Ship:Mass * g))  . //   tval = dtwr/(F/mg),  F = maxthrust
	}else{ 
		return 0. 
	}
}

//make sure there are conditions for a safe launch.
//can add more conditions such as launch schedule.
function launchcond {
	declare local launchconditions to false.
	until launchconditions = true {
		wait 1.
		if  ship:status = "prelaunch"
		and stage:liquidfuel <= 0
		and stage:solidfuel <= 0{
			
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
//stage logic
function stagelogic {
	when true then {
		declare local englist to 0.
		list engines in englist.
		For eng in englist{
			if eng:FLAMEOUT = true{ //and
				//(stage:liquidfuel <= 0 or  stage:solidfuel  <= 0) {
				stage.
			}
		}
		preserve.
	}
}
function launchprep {
	set ship:control:pilotmainthrottle to 0.
	lights off.
	rcs on.
	sas off.
	print "setup complete".
}
function dircorrect {
	//vectors
	vectors().
	set progradePground to VXCL(up:vector,velocity:surface).
	set correctionvector to VXCL(up:vector,-(progradepground:normalized-targetaltvec:normalized)).
	//---------------------------------------------------------------------------------
	//2d correction
	if vang(progradePground,targetaltvec)> 0.5 {
		
		print "Adjusting   " + "          " at (0,2).
		print "Angle is  " + round(vang(progradePground,targetaltvec),2)+ "    " at (0,3).
		
		lock steering to correctionvector.
		// very important
		if vang(correctionvector,ship:facing:forevector)<2 {
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
}

	
	


	
	
	
	
	
	
	
	
	
	
	
	