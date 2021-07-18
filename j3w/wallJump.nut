//radian to degree
const deg = 57.295779513;
//degree to radian
const rad = 0.0174533;

::debug <- true;
::jumpers <- {};

::marked <- null;
w <- [];
function registerJumper(ply){
	if(ply in jumpers){
		return;
	}
	local ui = Entities.CreateByClassname("game_ui");
	ui.__KeyValueFromInt("spawnflags", 256);
	ui.__KeyValueFromInt("FieldOfView", -1);
	jumpers[ply] <- Jumper(ply, ui);
	playerDir[ply] <- PlayerAngles(ply);
}
class Wall{
	trig = null;
	name = null;
	
	rv = null;
	fv = null;
	ang = null;
	
	force = null;
	up = null;
	
	members = null;
	length = null;
	constructor(t, ...){
		trig = typeof t == "instance" ? t : Entities.FindByName(null, t);
		name = trig.GetName();
		Assert(trig, "trig is null");
		
		if(vargc == 4){
			setFV(vargv[0]);
			force = vargv[1];
			up = vargv[2];
			length = vargv[3];
		}else{
			//default
			setFV(trig.GetForwardVector());
			force = 255;
			up = 255;
			length = trig.GetBoundingMaxs().y > trig.GetBoundingMaxs().x ? trig.GetBoundingMaxs().y - trig.GetBoundingMins().y : trig.GetBoundingMaxs().x - trig.GetBoundingMins().x;
		}
		
		members = {};
		
		local bb = this;
		trig.ValidateScriptScope();
		trig.GetScriptScope().onTouch <- function():(bb){
			bb.addMember(activator);
		}
		trig.GetScriptScope().onEndTouch <- function():(bb){
			bb.removeMember(activator);
		}
		trig.ConnectOutput("OnStartTouch", "onTouch");
		trig.ConnectOutput("OnEndTouch", "onEndTouch");
		
	}
	function addMember(v){
		if(v.IsNoclipping()){
			return;
		}
		members[v] <- false;
	}
	function removeMember(v){
		if(v in members){
			jumpers[v].unstick();
			jumpers[v].deactivate();
			delete members[v];
			
		}
	}
	function setFV(n){
		if(typeof n != "Vector"){
			ang = n;
			fv = Vector(cos(ang * rad), sin(ang * rad), 0)
		}else{
			ang = atan2(n.y, n.x) * deg;
			fv = n;
		}
		rv = Vector(fv.y, -fv.x, 0);
	}
	function getVel(){
		return Vector(fv.x * force, fv.y * force, up);
	}	
	function isLooking(eyePos, fv){
		return lineIntersect((rv * (length/2)) + trig.GetOrigin(), rv * -1, length, eyePos, fv, -1);
	}
	//print info that made up this object
	function printInfo(){
		printl("w.push(Wall(\"" + name + "\", " + ang + ", " + force + ", " + up + ", " + length +"));");
	}
	function think(){
		foreach(k, v in members){
			if(k.IsValid()){
				if(isLooking(k.EyePosition(), playerDir[k].getForwardVector())){
					if(!v){
						jumpers[k].stick(this);
						members[k] = true;
					}
				}else {
					if(v){
						jumpers[k].unstick();
						members[k] = false;
					}
				}
			}else{
				delete members[k];
			}
		}
	}
	function highlight(){
		local o = trig.GetOrigin();
		local k = Vector(0.5, length/2, trig.GetBoundingMins().z);
		//draw bounding box
		DebugDrawBoxAngles(o, k * -1, k, Vector(0, ang, 0), 255, 255, 0, 5, 0);
		
		//draw trajectory
		k = o + (fv * (force/2));
		DebugDrawLine(o, k, 0, 255, 0, true, 0);
		DebugDrawLine(k, k + Vector(0, 0, up/2), 255, 0, 0, true, 0);
		DebugDrawLine(o, k + Vector(0, 0, up/2), 0, 0, 255, true, 0);
	}
}

::lineIntersect <- function(origin1, dir1, length1, origin2, dir2, length2){
	//I have no idea how it work but it does
	local diff = origin2 - origin1;
	local d = dir1.x * dir2.y - dir1.y * dir2.x;
		
	local u = (diff.x * dir1.y - diff.y * dir1.x) / d;
	local t = (diff.x * dir2.y - diff.y * dir2.x) / d;
	return (0 < t && (t < length1 || length1 == -1)) && (0 < u  && (u < length2 || length2 == -1))
}

class Jumper{
	player = null;
	game_ui = null;
	activated = null;
	
	wall_p = null;
	constructor(p, g){
		player = p;
		game_ui = g;
		activated = false;
		
		game_ui.ValidateScriptScope();
		game_ui.GetScriptScope().OnJump <-  jump.bindenv(this);
		game_ui.ConnectOutput("PlayerOff", "OnJump");
	}
	function stick(w){
		wall_p = w;
		player.__KeyValueFromInt("movetype", 0);
		player.SetVelocity(Vector(0,0,0));
		activated = true;
		EntFireByHandle(game_ui, "Activate", "", 0.00, player, null);
	}
	function unstick(){
		if(!player.IsNoclipping()){
			player.__KeyValueFromInt("movetype", 2);
		}
		wall_p = null;
	}
	function deactivate(){
		if(player.IsValid() && activated){
			activated = false;
			EntFireByHandle(game_ui, "Deactivate", "", 0.00, player, null);
		}
	}
	function jump(){
		activated = false;
		if(wall_p){
			player.SetVelocity(wall_p.getVel());
			wall_p.removeMember(player);
			unstick();
		}
	}
}

::playerDir <- {};
::nm <- 1;
class PlayerAngles{
	measure_movement = null;
	pointer = null;
	constructor(player){
		local ents = playerAnglesTemp.SpawnEntity();
		measure_movement = ents.measure_movement;
		pointer = ents.pointer;
		
		local name = "player_" + nm++;
		
		player.__KeyValueFromString("targetname", name);
		EntFireByHandle(measure_movement, "SetMeasureTarget", name, 0.00, null, null);
	}
	function getAngles(){
		return pointer.GetAngles();
	}
	function getForwardVector(){
		return pointer.GetForwardVector();
	}
	function trace(length, ignore = null){
		return pointer.GetOrigin() + (getForwardVector() * ::TraceLine(pointer.GetOrigin(), pointer.GetOrigin() + (getForwardVector() * length), ignore) * length);
	}
}

function think(){
	foreach(v in w){
		v.think();
	}
	if(debug){
		foreach(k, v in playerDir){
			DebugDrawLine(k.EyePosition(), k.EyePosition() + (v.getForwardVector() * 128), 255, 0, 255, true, 0);
		}
		if(marked){
			marked.highlight();
			if(pos1){		
				foreach(k, v in playerDir){
					DebugDrawLine(pos1, v.trace(250), 255, 192, 203, true, 0);
				}
			}
		}
		return 0.01;
	}
	return 0.1;
}

//Editor's Tool
function mark(num){
	if(num >= w.len()){
		printl("impossible");
		return;
	}
	marked = w[num];
}

function clearMark(){
	marked = null;
	pos1 = null;
}

pos1 <- null;
function markCorner(){
	if(!marked){
		printl("Marked is null");
		return;
	}
	if(activator in playerDir){
		if(pos1){
			marked.rv = playerDir[activator].trace(250) - pos1;
			marked.rv.z = 0;
			marked.length = marked.rv.Norm();
			marked.setFV(Vector(-marked.rv.y, marked.rv.x, 0));
			printl("Marked second corner");
			pos1 = null;
			EntFireByHandle(marked.trig, "Enable", "", 0.00, null, null);
		}else{
			EntFireByHandle(marked.trig, "Disable", "", 0.00, null, null);
			pos1 = playerDir[activator].trace(250);
			printl("Marked first corner");
		}
		return;
	}
	printl("PlayerAngles not found");
}

function markFlip(){
	if(!marked){
		printl("Marked is null");
		return;
	}
	marked.setFV(marked.fv * -1);
}

function printInfoAll(){
	foreach(v in w){
		v.printInfo();
	}
}

function clearData(){
	delete getroottable().w_data;
}

function OnPostSpawn(){
	//save the wall data in between rounds
	if(debug){
		if(!("w_data" in getroottable())){
			::w_data <- w;
		}else{
			foreach(v in w_data){
				w.push(Wall(v.name, v.ang, v.force, v.up, v.length));
			}
			w_data = w;
			return;
		}
	}
	w.push(Wall("wall_1"));
	w.push(Wall("wall_2"));
	w.push(Wall("wall_3"));
}