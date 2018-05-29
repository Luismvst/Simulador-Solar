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
//****May be not needed "/r/n" at the end of reply; just /r required??****//
//Commands are NOT case sensitive 

//ECHO MODE COMMAND -> Echo Control 
//echoON returns the command recibed, a <LF><CR> answer and a prompt. echoOFF just a a <LF><CR> answer
//The device is in EchoOFF as default ( after reset too )
Function echoCtrl (ctrl)
	//Format: ECHOON<LF><CR>
	//Format: ECHOOFF<LF><CR>
	variable ctrl 
	string endl = "/n/r"
	string ans
	if (ctrl == 1)
		ans = "ON"
	else if (ctrl == 0)
		ans = "OFF"
	endif
	VDTWrite2 /O=1 "echo" + ans + endl
end
	
//To listen the command back from Mightex Led Controller
Function Listen ()
	string reply
	string endl = "/n/r"
	VDTRead2 /O=1 /T=endl reply
	print reply
end
Function ls ()
	return Listen()
end//Short version of Listen() - For debugging
	
//G	et Current Working Mode
Function getMode(channel)
	//Format: ?MODE CHLNo<LF><CR>
	variable channel
	string reply
	string endl = "/n/r"
	VDTWrite2 /O=1 "?mode " + num2str(channel) + endl
	delay (40)
	VDTRead2 /O=1 /T=endl reply
	//return 
	print reply
end

//Set Current Working Mode
Function setMode (channel, mode)
	//Format: MODE CHLno mode<LF><CR>	
	variable channel
	variable mode
	string endl = "/n/r"
	VDTWrite2 /O=1 "mode " + num2str(channel) + num2str(mode) + endl	
end
//MODE -> 	0 	DISABLE
//				1	NORMAL
//				2	STROBE 
//			---	3	TRIGGER --- (NOT Implemented)


//NORMAL MODE COMMANDS
Function setNormalParameters (channel, Imax, Iset)
	//Format: NORMAL CHLno Imax Iset<LF><CR>
	variable channel
	variable Imax
	variable Iset
	string endl = "/n/r"
//	nvar Inow = root:SolarSimulator:LedController:Inow
//	nvar Imax = root:SolarSimulator:LedController:Imax
	VDTWrite2 /O=1 "?current " + num2str(channel) + num2str(Imax) + num2str(Iset) + endl
end

Function getNormalParameters (channel)
	//Format: ?CURRENT CHLno<LF><CR> 
	variable channel 
	string reply
	string endl = "/n/r"
	VDTWrite2 /O=1 "?current " + num2str(channel) + endl
	delay (40)
	VDTRead2 /O=1 /T=endl reply
	print reply	
	//The first 2 parameters returned by reply (i.e. #0 0 ...) can be ignored. Used for calibration only
end

//Set Normal Mode Working Current
Function setNormalCurrent (channel, Iset)
	//Format: CURRENT CHLno Iset<LF><CR>
	variable channel
	variable Iset
	string endl = "/n/r"
//	nvar Inow = root:SolarSimulator:LedController:Inow
	VDTWrite2 /O=1 "current "+num2str(channel) + num2str(Iset) + endl	
end

//STROBE MODE COMMANDS
//Set Strobe Mode Parameters
Function setStrobeParameters (channel, Imax, Repeat)
	//Format: STROBE CHLno Imax Repeat<LF><CR> 
	variable channel
	variable Imax
	variable Repeat
	//Repeat_range : 0 - 9999 ( 9999 is repeated for ever , 1 is repeated once... and so on )
	string endl = "/n/r"	
//**************************************************************************************************//
//	PENDIENTE DE REALIZAR PARA CUANDO CONSIGA OTRAS FUNCIONES MENOS MODULARES PARA EL PANEL
//	nvar Imax_panel = root:SolarSimulator:LedController:Imax
//	nvar Repeat_panel = root:SolarSimulator:LedController:Repeat
//	if (paramisdefault(IMax_manual))
//		Imax = Imax_panel
//	endif
//	if (paramisdefault(Repeat))
//		Repeat = Repeat_panel
//	endif
	//Note: If you want to use the data of the panel, do not use IMax and Repeat as
	//arguments of the function and they will be taken automatically from the panel 
//**************************************************************************************************//
	VDTWrite2 /O=1 "strobe " + num2str(channel) + num2str(Imax) + num2str(Repeat) + endl	
end

//Set Strobe Profile 
Function  setStrobeProfile (



//OTHER COMMANDS 
