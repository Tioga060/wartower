//Tioga060

debug <- true;
function debugprint(line){
	if(debug){
		printl("###########################################################");
		printl(line);
		print("Message recieved at time ");
		printl(Time());
		
	}
}

//==================//
//--Math Functions--//
//==================//
function RandIntBetween(min,max) {
    // Generate a pseudo-random integer between 0 and max
    local roll = (1.0 * rand() / RAND_MAX) * (max - min + 1);
	
    return roll.tointeger()+min;
}

function max(x,y)
{
	if(x>y) return x;
	return y;
}

//====================//
//---Squirrel Fixes---//
//====================//
function ArrayFindFix(ar, val){
	
	for(local a = 0;a<(ar.len());a+=1)
	{
		if(val == ar[a]){
			return a;
		}
	}
	return -1;
}



//=================//
//--Trace Helpers--//
//=================//
class TraceInfo 
{
	constructor(h,d)
	{
		Hit = h;
		Dist = d;
	}

	Hit = null;
	Dist = null;
}


//Returns the hit position of a trace between two points.
function TraceVec(start, end, filter)
{
	local dir = (end-start);
	local frac = TraceLine(start,end,filter);
	//return start+(dir*frac);
	return TraceInfo(start+(dir*frac),dir.Length());
}
//Returns the hit position of a trace along a normalized direction vector.
function TraceDir(orig, dir, maxd, filter)
{
	local frac = TraceLine(orig,orig+dir*maxd,filter);
	if(frac == 1.0) { return TraceInfo(orig+(dir*maxd),0.0);}
	return TraceInfo(orig+(dir*(maxd*frac)),maxd*frac);
}

//=================//
//---Hit Helpers---//
//=================//

function IsTouchingGround(ent, tolerance){
	local height = TraceDir(ent.GetOrigin(),(Vector(0,0,-1)),8192,ent).Dist;
	if(abs(height) <= tolerance) return true;
	return false;
}

//==================//
//---Text Helpers---//
//==================//

//Displays text to a single player specified by the input
function displayText(ply, text){
	DoEntFire("Script_Text", "AddOutput", "message " +text, 0, null, null);
	DoEntFire("Script_Text", "ShowMessage", "<none>", 0, ply, ply);
}

//Displays text to a single player specified by the input after a specified delay
function displayTextDelay(ply, text,delay){
	DoEntFire("Script_Text", "AddOutput", "message " +text, delay, null, null);
	DoEntFire("Script_Text", "ShowMessage", "<none>", delay, ply, ply);
}

ChatColors <- {
	white="\x01"
	red="\x02"
	purple="\x03"
	darkgreen="\x04"
	lightgreen="\x05"
	green="\x06"
	lightred="\x07"
	grey="\x08"
	yellow="\x09"
	orange="\x10"
}

function PrintAllColors()
{
	local printme = " ";
	foreach(index,color in ChatColors){
		printme += color + index + " ";
	}
	ScriptPrintMessageChatAll(printme);
}

function SystemChatPrint(message)
{
	local system_string = "[" + ChatColors.purple + "Wartower" + ChatColors.white + "]";
	ScriptPrintMessageChatAll(system_string + message);
}

/*
ammo_762mm 800 // scout, ak47, g3sg1, aug
ammo_556mm_box 800 // m249
ammo_556mm 800 // galil, sg552, famas, m4a1, sg550
ammo_338mag 200 // awp
ammo_9mm 800 // mp5navy, tmp, glock, elite
ammo_buckshot 800 // m3, xm1014
ammo_45acp 800 // ump45, mac10, usp
ammo_357sig 800 // P228
ammo_57mm 800 // p90, fiveseven on)
*/

//Squirrel Utilities
//Constants
Pi <- 3.14159265
TwoPi <- 6.2831853
HalfPi <- 1.5707963

Rad <- 0.01745329251994329576923690768489
Deg <- 57.295779513082320876798154814105

//==================//
//--Math Functions--//
//==================//
//Distance between the x/y components of two 3D vectors.
function Distance2D(v1,v2)
{
	local a = (v2.x-v1.x);
	local b = (v2.y-v1.y);
	
	return sqrt((a*a)+(b*b));
}

//Distance between two 3D vectors.
function Distance3D(v1,v2)
{
	local a = (v2.x-v1.x);
	local b = (v2.y-v1.y);
	local c = (v2.z-v1.z);
	
	return sqrt((a*a)+(b*b)+(c*c));
}

//Return the Pitch and Yaw between two 3D vectors.
function AngleBetween(v1,v2)
{
		local aZ = (atan2((v1.y - v2.y),(v1.x - v2.x))+PI)*180/PI;	
		local aY = (atan2((v1.z - v2.z),Distance2D(v1,v2))+PI)*180/PI;
		
		return Vector(aY,aZ,0.0);
}

function AngleBetween2(v1,v2)
{
		local aZ = (atan2((v1.z - v2.z),(v1.x - v2.x))+Pi)*180/PI;	
		local aY = (atan2((v1.z - v2.z),(v1.y - v2.y))+Pi)*180/PI;
		
		return Vector(aY,aZ,0.0);
}

//Returns the difference between two angles
//actionsnippet.com/?p=1451
function AngleDiff(angle0,angle1)
{
    return (abs((angle0 + Pi -  angle1)%(Pi*2.)) - Pi);
}

//Normalizes a vector
function Normalize(v)
{
	local len = v.Length();
	return Vector(v.x/len,v.y/len,v.z/len);
}

//Cross product of two vectors
function Cross(v1, v2) 
{
	local v = Vector(0.0,0.0,0.0);
	v.x = ( (v1.y * v2.z) - (v1.z * v2.y) );
	v.y = ( (v1.x * v2.z) - (v1.z * v2.x) );
	v.z = ( (v1.x * v2.y) - (v1.y * v2.x) );
	return v;
}

//Constrain a number to a given range
function clamp(v,mi,ma)
{
	if(v < mi) return mi;
	if(v > ma) return ma;
	return v;
}

//Maps value between its bounds and the target bounds
function Map(value, low1, high1, low2, high2){
	return (low2 + (value - low1) * (high2 - low2) / (high1 - low1));
}

//Return the smallest of two numbers.
function min(v1,v2)
{
	if(v1 < v2) return v1;
	return v2;
}
//Vector multiplication fix
function Mul(v1,v2)
{
	local typ = typeof(v2);
	
	//Vector * Scalar
	if(typ == "integer" || typ == "float")
	{
		return Vector(v1.x*v2,v1.y*v2,v1.z*v2);
	}
	//Vector * Vector
	if(typ == "Vector")
	{
		return Vector(v1.x*v2.x,v1.y*v2.y,v1.z*v2.z);
	}
	return null;
}

function FloatVecToIntVec(vec)
{
	return Vector(vec.x.tointeger(), vec.y.tointeger(), vec.z.tointeger());
}

//=================//
//--Debug Helpers--//
//=================//

//Draws a cross showing the X, Y, and Z axes.
function DrawAxis(pos,s,nocull,time)
{
	DebugDrawLine(Vector(pos.x-s,pos.y,pos.z), Vector(pos.x+s,pos.y,pos.z), 255, 0, 0, nocull, time);
	DebugDrawLine(Vector(pos.x,pos.y-s,pos.z), Vector(pos.x,pos.y+s,pos.z), 0, 255, 0, nocull, time);
	DebugDrawLine(Vector(pos.x,pos.y,pos.z-s), Vector(pos.x,pos.y,pos.z+s), 0, 0, 255, nocull, time);
}

//Draw the bounding box of a given entity.
function DrawEntityBBox(ent,r,g,b,a,time)
{
	DebugDrawBox(ent.GetOrigin(),ent.GetBoundingMins(), ent.GetBoundingMaxs(), r, g, b, a, time)
}

//Draws a line along a given normal.
function DrawNormal(pos,norm,s,time)
{
	local ns = norm*s;
	DebugDrawLine(Vector(pos.x,pos.y,pos.z), Vector(pos.x+ns.x,pos.y+ns.y,pos.z+ns.z), 0, 255, 255, false, time);	
}
//==================//
//====Crate Class===//
//==================//

class Crate
{
	number_to_spawn = 0;
	crate_type = 0;
	level = 0;
	constructor(vec){
		number_to_spawn = vec.z.tointeger();
		crate_type = vec.y.tointeger();
		level = vec.x.tointeger();
	}

}


//==================//
//==Custom Helpers==//
//==================//

function MinIndex(tab)
{
	local mini = null;
	local minkey = 0;
	foreach(key, value in tab)
	{
		if(mini == null) mini = value;
		if(value < mini)
		{
			mini = value;
			minkey = key;
		}
	}
	return minkey;
}

//Converts a Vector object to a string with format "x0.0y0.0z0.0"
function VectorToString(vec){
	return ("x"+(vec.x).tostring() + "y" + (vec.y).tostring() + "z" + (vec.z).tostring());
}

//Converts a string with format "x0.0y0.0z0.0" to a Vector object
function StringToVector(str){
	xpos <- 0;
	xpos <- str.find("x");
	ypos <- str.find("y");
	zpos <- str.find("z");
	xcoord <- (str.slice(xpos+1, ypos)).tofloat();
	ycoord <- (str.slice(ypos+1, zpos)).tofloat();
	zcoord <- (str.slice(zpos+1)).tofloat();
	return Vector(xcoord,ycoord,zcoord);
}

function GetAndScaleXYOffset(reference, tomove, scale)
{
	local direction = Normalize(tomove-reference);
	direction.z = 0.0;
	return Mul(direction, scale*Distance2D(reference,tomove));
}


//Displays a spell's specified cooldown to a specified player
function DrawCooldown(ply, cooldown){
	displayTextDelay(ply, "Spell Ready", cooldown);
	for(local a=cooldown;a>0;a-=1){
		displayTextDelay(ply, "Cooldown: "+a.tostring()+" Seconds",cooldown-a);
		if(a==1){
			for(local b=1.0;b>0.2;b-=0.25)
			displayTextDelay(ply, "Cooldown: "+b.tostring()+" Seconds",1.0-b+(cooldown-a));
		}
	}
	
}

function GetHitTargetCorrected(tply, range){
	TraceOrig <- tply.orig;
	playerProp <- tply.IndiProp;
	eyePos <- (tply.Ent).EyePosition();
	loc <- TraceDir(eyePos,TraceOrig.GetForwardVector(),range,(tply.Ent))
	Hit <- loc.Hit;
	Dist <- loc.Dist;
	directionVector <- Normalize(Hit - eyePos);
	directionVector.x *= 48;
	directionVector.y *= 48;
	Hit <- Hit-directionVector;
	
	heightMax <- 84;
	VerticalCollision <- heightMax-(TraceDir(Hit,(Vector(0,0,1)),heightMax,(tply.Ent)).Dist);
	if(VerticalCollision != heightMax){
		Hit <- Hit - Vector(0,0,VerticalCollision);
	}
	return Hit;

	
}

function GetHitTarget(tply, range, corrected){
		if(corrected){
			return GetHitTargetCorrected(tply, range);
		}
		else{
			TraceOrig <- tply.orig;
			playerProp <- tply.IndiProp;
			eyePos <- (tply.Ent).EyePosition();
			return TraceDir(eyePos,TraceOrig.GetForwardVector(),range,(tply.Ent)).Hit;
		}
}

function GetUniqueHandle(ply){
	return ((ply.GetName()).slice(7));
}