//Written By Color[STEAM_1:0:44837813]
//DO NOT COPY WITHOUT MY PERMISSION

players <- [];
callers <- ["STEAM_1:0:44837813"];
e_player_connect  <- null;
e_player_say  <- null;
e_player_disconnect  <- null;
e_door_moving  <- null;
difficulty <- 1;

class Player{
	userid = null;
	steamid = null;
	handle = null;
	constructor(_u,_s){
		userid=_u;
		steamid=_s;
	}
}

function Precache() {
	e_player_connect = Entities.FindByName(null, "e_player_connect");
	e_player_say = Entities.FindByName(null, "e_player_say");
	e_player_disconnect = Entities.FindByName(null, "e_player_disconnect");
	e_door_moving = Entities.FindByName(null, "e_door_moving");
}

function PlayerConnect(){
	local userid = e_player_connect.GetScriptScope().event_data.userid;
	local steamid = e_player_connect.GetScriptScope().event_data.networkid;
	if(steamid !=null || steamid != "BOT"){
		local p = Player(userid,steamid);
		players.push(p);
	}
}

function PlayerDisconnect(){
	local userid = e_player_disconnect.GetScriptScope().event_data.userid;
	for (local i = 0; i < players.len(); i++) {
		if(players[i].userid == userid){
			players.remove(i);
			break;
		}
	}
}

function PlayerSay(){
	local userid = e_player_say.GetScriptScope().event_data.userid;
	local text = e_player_say.GetScriptScope().event_data.text;
	text = text.tolower();
	local flag = 0;
	
	foreach(p in players){
		if(p.userid == userid){
			for (local i = 0; i < callers.len(); i++) {
				if(p.steamid == callers[i]){
					flag = 1;
					if(text.find("!ent_fire ") == 0){
						local str = split(text, " ");
						if(str.len() == 5){
							if(str[1].find("/id") != 0){
								if(Concat(str[3],"/") != ""){
									str[3] = Concat(str[3],"/");
								};
								EntFire(str[1],str[2],str[3],str[4].tofloat(),null);
							}
							else{
								local userid = str[1].slice(3,str[1].len());
								local handle = GetPlayerByUserID(userid.tointeger());
								if(handle != null){
									str[3] = Concat(str[3],"/");
									EntFire("!activator",str[2],str[3],str[4].tofloat(),handle);
									break;
								}
							}
						}
					}
					else if(text.find("!ext") == 0){
						text = text.slice(4, text.len());
						if(text != null && text != ""){
							text = "mp_timelimit "+text;
							SendToConsoleServer(text);
						}
					}
					else if(text.find("!ban /id") == 0){
						text = text.slice(8, text.len());
						local handle = GetPlayerByUserID(text.tointeger());
						if(handle != null){
							EntFire("!activator","RunScriptCode","ban<-1;",0,handle);
							EntFire("!activator","AddOutput","origin 15872 14944 112",0,handle);
						}
					}
					else if(text.find("!unban /id") == 0){
						text = text.slice(10, text.len());
						local handle = GetPlayerByUserID(text.tointeger());
						if(handle != null){
							EntFire("!activator","RunScriptCode","ban<-0;",0,handle);
						}
					}
					else if(text.find("!slay ") == 0){
						text = text.slice(6, text.len());
						if(text.find("/id") == 0){
							text = text.slice(3, text.len());
							local handle = GetPlayerByUserID(text.tointeger());
							if(handle != null){
								EntFire("!activator","AddOutput","origin 15872 14944 112",0,handle);
							}
						}
						else if(text == "all"){
							local handle = null;
							while(null != (handle = Entities.FindInSphere(handle,self.GetOrigin(),500000))){
								if(handle.GetClassname() == "player"){
									EntFire("!activator","AddOutput","origin 15872 14944 112",0,handle);
								}
							}
						}
						else if(text == "ct"){
							local handle = null;
							while(null != (handle = Entities.FindInSphere(handle,self.GetOrigin(),500000))){
								if(handle.GetClassname() == "player"){
									if(handle.GetTeam() == 3){
										EntFire("!activator","AddOutput","origin 15872 14944 112",0,handle);
									}
								}
							}
						}
					}
					else if(text == "!startscan"){
						EntFire("scan","AddOutput","targetname scan_1");
					}
					else if(text == "!stopscan"){
						EntFire("scan_1","AddOutput","targetname scan");
					};
					
					if(text.find("!trip") == 0){
						text = text.slice(text.len()-1,text.len());
						if(text != null && text != ""){
							EntFire("tostage"+text+"_button","Press","");
						}
					};
					break;
				};
			};
			if(flag){
				break;
			};
		}
	}
}


function Concat(str,separator){
	local temp2 = "";
	if(str.find(separator) != null){
		local temp = split(str, separator);
		foreach (s in temp) {
			temp2 = temp2+s+" ";
		}
		temp2 = temp2.slice(0, temp2.len()-1);
	};
	return temp2;
}

function DoorMoving(){
	local userid = e_door_moving.GetScriptScope().event_data.userid;
	local entindex = e_door_moving.GetScriptScope().event_data.entindex;
	local temp = "GetPlayerHandle("+userid+","+entindex+");";
	EntFire("listener","RunScriptCode",temp,0.06);
}


function SetPlayerHandle(){
	local time = 0;
	local handle = null;
	while(null != (handle = Entities.FindInSphere(handle,self.GetOrigin(),500000))){
		if(handle.GetClassname() == "player"){
			local scope=handle.GetScriptScope();
			if(scope == null || !("userid" in scope)){
				EntFire("handle_door_maker","ForceSpawnAtEntityOrigin","!activator",time,handle);
				time += 0.10;
			}
		}
	}
}

function GetPlayerHandle(userid,entindex){
	local temp = Entities.First();
	while(temp.entindex() != entindex && (temp = Entities.Next(temp)) != null);
		if(temp != null && temp.GetPreTemplateName() == "handle_door"){
			local scope = temp.GetScriptScope();
			if("handle" in scope){
				EntFire("!activator","RunScriptCode","userid<-"+userid+";",0,scope.handle);
				foreach(p in players){
					if(p.userid == userid){
						p.handle = scope.handle;
					p.userid = userid;
					break;
					}
				}
			}
		}
}


function GetPlayerByUserID(userid){
	local handle = null;
	foreach(p in players){
		if(p.userid == userid){
			if(p.handle != null){
				handle = p.handle;
				break;
			}
		}
	}
	return handle;
}

function PushSteamID(a,b,c){
	callers.push("STEAM_"+a.tostring()+":"+b.tostring()+":"+c.tostring());
}

function Unique(a){
	a.sort();
	local temp=[a[0]];
	for(local i = 1; i < a.len(); i++){
		if(a[i] != temp[temp.len()-1]) 
			temp.push(a[i]);
	}
	return temp;
}

function LoadTrip5Diff(flag=1,d=1){
	if(flag){
		if(difficulty >= 5)
			difficulty = 5;
		EntFire("win_relay","AddOutput","OnTrigger cmd:Command:say <--DIFFICULTY "+difficulty+" Finished-->:0:1",5);
		EntFire("cmd","Command","say <--DIFFICULTY "+difficulty+"-->",5);
		for (local i = 2; i <= difficulty; i++) 
			LoadTrip5Diff(0,i);
	}
	else 
		switch (d){
			case 2:
				EntFire("trip5_diff2_*","Toggle","",5);
				break;
			case 3:
				EntFire("trip5_trigger_111","Enable","",5);
				EntFire("trip5_diff3_1","Toggle","",5);
				break;
			case 4:
				EntFire("trip5_diff4_1","AddOutput","renderamt 255",5);
				EntFire("trip5_diff4_2","Toggle","",5);
				break;
			case 5:
				EntFire("trip5_diff5_*","Toggle","",5);
				break;
		}
}