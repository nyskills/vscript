//EntityGroup 0-2 should be the attached entities
//EntityGroup[3]: tonemap
//EntityGroup[4]: color correction

//make sure each value in height is 0 before making this true
gettingMax <- false;

thinking <- false;

//place value from printMax here
height <- [104,208,249];
min <- [0,0,0];

maxBloomScale <- 5;

function getMin(){
	for(local i = 0; i < 3; i++){
		min[i] = EntityGroup[i].GetOrigin().z;
	}
	thinking = true;
}

function getMax(i, h){
	//if the different of the top_bone and bottom_bone is greater than the previous one
	if(height[i] < h){
		printl("new height on " + i + ": " + h);
		height[i] = h;
	}
}

function printMax(){
	foreach(idx, v in height){
		printl(idx + ": " + v);
	}
}

function think(){
	if(thinking){
		local total = 0;
		for(local i = 0; i < 3; i++){
			//get the origin of the top_bone
			local o = EntityGroup[i].GetOrigin().z;
			
			local h = o - min[i];
			if(gettingMax){
				getMax(i, h);
			}
			total += h/height[i];
		}
		if(gettingMax){
			return 0.01;
		}
		total =  total/3;
		EntFireByHandle(EntityGroup[3], "SetBloomScale", "" + (maxBloomScale * total), 0.00, null, null);	
		EntityGroup[4].__KeyValueFromFloat("maxweight", total);
	}
	return 0.1;
}