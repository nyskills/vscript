s <- [];
class Swing{
	static gravity = -1;
	player = null;
	attachPoint = null;
	ropeLength = null;
	accel = null;
	speed = null;
	angle = null;
	constructor(p, o, l){
		player = p;
		attachPoint = o;
		ropeLength = l;
	}
	function think(){
        this.aAcceleration = (gravity / this.ropeLength) * sin(angle);
        this.aVelocity += this.aAcceleration;
        this.angle += this.aVelocity 
	}
}

function think(){
	if(debug){
		foreach(v in m){
			v.debugDraw();
		}
	}
	foreach(v in s){
		v.think();
	}
	return 0.01;
}

function OnPostSpawn(){
	s.push(Swing(self.GetOrigin(), 150));
}

function test(){
//	m.push(Monitor(32, playerDir[activator].pointer, Vector(1536, 352, 544)));
	s[0].addPlayer(activator);
}

//copied from old stuff with some edits
m <- [];
::Monitor <- class{
	radius = null;
	viewer = null;
	spot = null; // spot to be stare at
	offset = null;
	constructor(r, e1, o){
		radius = r;
		viewer = e1;
		spot = o;
	}
	function isLooking(){
		local dirVec1 = viewer.GetForwardVector();
		local dirVec2 = spot - viewer.GetOrigin();
		local dist = dirVec2.Norm();

		//compare the distance between two points
		return pow(radius / dist, 2) >= (dirVec2 - dirVec1).LengthSqr() ? dist : -1;
		//return the dist if true else -1.
		
		// foreach(k, v in dirVec1){
			// if(v > dirVec2[k] + tolerance || v < dirVec2[k] - tolerance){
				// snap = false;
				// return false;
			// }
		// }
	}
	function debugDraw(){
		//draw a circle in the direction of the viewer
		local dir2 = spot - viewer.GetOrigin();
		dir2.Norm();
		local color = Vector(255, 0, 0);
		if(isLooking() != -1){
			color = Vector(0, 255, 0);
		}
		::drawRegPoly(spot, 16, radius, color, -asin(dir2.z) * deg, atan2(dir2.y, dir2.x) * deg, 0, true, 0);
	}
}

::drawLineSimple <- function(pos1, pos2, color, noDepth = true, life = 0.1){
	DebugDrawLine(pos1, pos2, color.x, color.y, color.z, noDepth, life);
};

//ent_fire dis1 runscriptcode "drawRegPoly(self.GetOrigin(), 10, 30, Vector(0, 255, 0), 90, 0, 0, true, 2.0)"
::positionAlongRing <- function(center, radius, degree, pitch, yaw, offDeg = 0){
	//map the points
	degree += offDeg;
	local position = Vector(cos(degree * rad), sin(degree * rad), 0);

	//rotate them around y axis(pitch)
	pitch *= -1;
	pitch -= 90;
	position.z = position.x * sin(pitch * rad);
	position.x *= cos(pitch * rad);
	
	//rotate them around z axis(yaw)
	local aa = atan2(position.y, position.x);
	local ar = sqrt(position.y * position.y + position.x * position.x);
	position.y = ar * sin(yaw * rad + aa);
	position.x = ar * cos(yaw * rad + aa);
	
	position *= radius;
	//printl(position);
	return (position + center);
};

::drawRegPoly <- function(center, sides, radius, color, pitch, yaw, offDeg = 0, noDepth = true, life = 0.1){
	local arr = [];
	for(local i = 0; i < sides; i++){
		arr.push(positionAlongRing(center, radius, i*360/sides, pitch, yaw, offDeg));
	}
	drawConnectedPoints(arr, color, noDepth, life);
};

::drawConnectedPoints <- function(arr, color, noDepth = true, life = 0.1, traceBack = true){
	if(arr.len() < 2){
		return;
	}
	for(local i = 1; i < arr.len(); i++){
		drawLineSimple(arr[i-1], arr[i], color, noDepth, life);
	}
	if(traceBack){
		drawLineSimple(arr[0], arr[arr.len()-1], color, noDepth, life);
	}
};