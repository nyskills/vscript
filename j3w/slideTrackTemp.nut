//k: player
//v: entities
::riders <- {};
::tracks <- [];
::tracksNum <- 0;
thinkTime <- 0.1;
::timeInSec <- 1/thinkTime;


maker <- Entities.FindByName(null, "slide_maker");

function spawnTrack(num){
	if(activator in riders || !activator.IsValid()){
		return;
	}
	tracksNum = num;
	maker.SpawnEntityAtLocation(caller.GetOrigin(), Vector(0,0,0));
}
function PreSpawnInstance( entityClass, entityName )
{
}
function PostSpawn( entities )
{
	riders[activator] <- Slider(activator, caller.GetOrigin(), entities, tracksNum);
}
class Slider{
	owner = null;
	
	trig = null;
	track = null;
	move = null;
	sparks = null;
	ui = null;
	
	pos1 = null;
	pos2 = null;
	
	//setParent and initialize
	constructor(o, dest, e, type){
		owner = o;
		trig = e["slide_trig"];
		track = e["slide_track"];
		move = e["slide_move"];
		sparks = e["slide_sparks"];
		ui = e["slide_UI"];
		
		local t = ::tracks[type];
		track.SetAngles(t.angles.x, t.angles.y, t.angles.z);
		track.SetOrigin(t.origin);
		track.SetModel(t.model);
		
		trig.ValidateScriptScope();
		
		//somehow the first letter can't be capitalized if the function name and output is the same.
		trig.GetScriptScope().onEndTouch <- unstick.bindenv(this);
		trig.ConnectOutput("OnEndTouch", "onEndTouch");
		
		EntFireByHandle(move, "SetParent", "!activator", 0.00, track, null);
		EntFireByHandle(owner, "SetParent", "!activator", 0.00, move, null);
		EntFireByHandle(owner, "AddOutput", "Origin " + dest.x + " " + dest.y + " " + dest.z, 0.02, null, null);
		EntFireByHandle(owner, "AddOutput", "MoveType 0", 0.02, null, null);
		EntFireByHandle(owner, "RunScriptCode", "self.SetVelocity(Vector(0,0,0));", 0.02, null, null);
		
		
		EntFireByHandle(sparks, "StartSpark", "", 0.02, null, null);
		
		EntFireByHandle(ui, "Activate", "", 0.02, owner, owner);
		ui.ValidateScriptScope();
		ui.GetScriptScope().OnPlayerJump <- jump.bindenv(this);
		ui.ConnectOutput("PlayerOff", "OnPlayerJump");
		
		//parent: track
		EntFireByHandle(move, "SetParentAttachmentMaintainOffset", "start", 0.00, null, null);
		EntFireByHandle(track, "SetAnimation", "follow", 0.02, null, null);
		
		pos1 = move.GetOrigin();
		pos2 = move.GetOrigin();
	}
	//clearParent and kill everything
	function unstick(){
		if(activator != owner){
			return;
		}
		EntFireByHandle(owner, "ClearParent", "", 0.00, null, null);
		
		//so that the player doesn't fall while trying to noclip out
		if(!owner.IsNoclipping()){
			EntFireByHandle(owner, "AddOutput", "movetype 2", 0.00, null, null);
		}
		
		
		//delayed so that the player doesn't get deleted by it
		trig.Destroy();
		ui.Destroy();
		sparks.Destroy();
		EntFireByHandle(track, "Kill", "", 0.02, null, null);
		EntFireByHandle(move, "Kill", "", 0.02, null, null);
		
		delete ::riders[owner];
	}
	function jump(){
		local v = getVelocity();
		v.z = v.z >= 0 ? v.z + 300 : 300;
		owner.SetVelocity(v);
		unstick();
	}
	function updatePosition(){
		pos1 = pos2;
		pos2 = move.GetOrigin();
	}
	function getVelocity(){
		return (pos2 - pos1) * timeInSec;
	}
}

//thinkfunction
function think(){
	foreach(v in riders){
		v.updatePosition();
	}
	return thinkTime;
}

function OnPostSpawn(){
	tracks.push({angles = Vector(-5, 90, 5), origin = Vector(536, -360, 200), model = "models/j3w_models/slidea_track.mdl"});
	tracks.push({angles = Vector(-5, 270, 5), origin = Vector(-352, -944, 192), model = "models/j3w_models/slideb_track.mdl"});
}

