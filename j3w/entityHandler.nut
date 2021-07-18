::E_Var <- null;
EntitiesMaker <- class{//in env_entity_maker
	static maker = self;
	temp_n = null;
	single = null;
	keyvalue = null;
	constructor(point_template, singleOnly = null){
		local temp = ::Entities.FindByName(null, point_template);
		::Assert(temp, point_template + " doesn't exist. FindByName returned NULL");
		::Assert(temp.IsValid(), point_template + "Not Valid");
		::Assert(temp.ValidateScriptScope(), point_template + "ValidateScriptScope Failed");
		
		temp_n = point_template;
		local temp_s = temp.GetScriptScope();
		temp_s.PostSpawn <- function(e){
			E_Var = e;
		};
		temp_s.PreSpawnInstance <- PreSpawnDefault.bindenv(this);
		single = singleOnly;
	}
	function PreSpawnDefault(c, n){
		if(keyvalue != null){
			if(single != null){
				return keyvalue;
			}else if(n in keyvalue){
				return keyvalue[n];
			}
		}
	}
	function setKey(k){
		keyvalue = k;
		maker.__KeyValueFromString("EntityTemplate", temp_n);
	}
	function getEnt(){
		if(single != null){
			return E_Var[single];
		}
		return E_Var;
	}
	
	function SpawnEntity(k = null){//spawn and return spawn entities in table;
		setKey(k);
		
		maker.SpawnEntity();
		return getEnt();
	}
	function SpawnEntityAtEntityOrigin(e, k = null){
		setKey(k);
		
		maker.SpawnEntityAtEntityOrigin(e);
		return getEnt();
	}
	function SpawnEntityAtLocationFV(origin, orientation, k = null){
		setKey(k);
		
		maker.SetForwardVector(orientation);
		maker.SetOrigin(origin);
		
		maker.SpawnEntity();
		return getEnt();
	}
	function SpawnEntityAtLocation(origin, orientation, k = null){
		setKey(k);
		
		maker.SpawnEntityAtLocation(origin, orientation);
		return getEnt();
	}
	function SpawnEntityAtNamedEntityOrigin(targetname, k = null){
		setKey(k);
		
		maker.SpawnEntityAtNamedEntityOrigin(targetname);
		return getEnt();
	}
	function SpawnPhysicEntity(origin, speed, dir){
		maker.__KeyValueFromInt("PostSpawnSpeed", speed);
		maker.__KeyValueFromVector("PostSpawnDirection", dir);
		
		return SpawnEntityAtLocation(origin, Vector(0,0,0));
	}
}

function OnPostSpawn(){
	::playerAnglesTemp <- EntitiesMaker("playerAngles");
}