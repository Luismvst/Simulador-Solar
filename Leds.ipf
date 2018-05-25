#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "serialcom"
#include "serialcomB"
//#include "VDP"

Menu "Leds"
	"Init", /Q, initialize()
End

//Initialize the LEDS with the 
Function initialize()		
	DFRef saveDFR=GetDataFolderDFR()
	string path = "root:SolarSimulator:LedController"
	DFRef dfr = $path
	SetDatafolder dfr
	string Device = "LedController"
	string com = "COM5"
	variable/G Imax, Inow
	init_OpenSerial(com, Device)	
	SetDataFolder saveDFR
end
//endl is 
//<LF> --> /n
//<CR> --> /r

//MODE -> DISABLE, NORMAL, STROBE 
Function setMode (mode, numchannel)
	variable mode
	variable numchannel
	string cmd
	string endl = "/n/r"
	VDTWrite2 /O=1 "?mode "+num2str(numchannel)+ endl	
end

Function getMode(numchannel)
	variable numchannel
	string reply
	string endl = "/n/r"
	VDTWrite2 /O=1 "?mode "+num2str(numchannel)+ endl
	delay (40)
	//May be not needed "/r/n" at the end of reply; just /r required??
	VDTRead2 /O=1 /T=endl reply
	print reply
end

//NORMAL MODE COMMANDS
Function setNormalParameters (numchannel)
	variable numchannel
	string endl = "/n/r"
	nvar Inow = root:SolarSimulator:LedController:Inow
	nvar Imax = root:SolarSimulator:LedController:Imax
	VDTWrite2 /O=1 "?current " + num2str(numchannel) + num2str(Imax) + num2str(Inow) + endl
end

Function getNormalParameters (numchannel)
	variable numchannel 
	string reply
	string endl = "/n/r"
	VDTWrite2 /O=1 "?current " + num2str(numchannel) + endl
	delay (40)
	VDTRead2 /O=1 /T=endl reply
	print reply	
	//The first 2 parameters returned by reply (i.e. #0 0 ...) can be ignored. Used for calibration only
end

//Set Normal Mode Working Current
Function setNormalCurrent (numchannel)
	variable numchannel
	string endl = "/n/r"
	nvar Inow = root:SolarSimulator:LedController:Inow
	VDTWrite2 /O=1 "current "+num2str(numchannel) + num2str(Inow) + endl	
end

//STROBE MODE COMMANDS
Function setStrobeParameters (numchannel)
	//Format: STROBE CHLno Imax Repeat<LF><CR> 
	variable numchannel
	string endl = "/n/r"
	nvar Imax = root:SolarSimulator:LedController:Imax
	nvar Repeat = root:SolarSimulator:LedController:Repeat
	//Repeat_range : 0 - 9999 ( 9999 is repeated for ever , 1 is repeated once... and so on )
	VDTWrite2 /O=1 "strobe " + num2str(numchannel) + num2str(Imax) + num2str(Repeat) + endl	
end

