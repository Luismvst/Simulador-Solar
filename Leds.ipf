#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "serialcom"
#include "serialcomB"

//In a future it will be merged with Mario´s InitOpenSerial() 
Function init_OpenSerialLed (com, Device)

	string com, Device
	string cmd, DeviceCommands
	//string reply
	variable flag
	string sports=getSerialPorts()
//		print "Available Ports:"
//		print sports
	if (StringMatch(Device, "LedController"))
		//9600 N81 (No hw flow ctrl)
		DeviceCommands=" baud=9600, parity=0, databits=8, stopbits=1"
	endif
		// is the port available in the computer?
	if (WhichListItem(com,sports)!=-1)
		cmd = "VDT2 /P=" + com + DeviceCommands
		Execute/Z cmd
		cmd = "VDTOperationsPort2 " + com
		Execute/Z cmd
//		cmd = "VDTOpenPort2 " + com
//		Execute/Z cmd

		//Port available but VDT can not openPort..
		if (V_Flag)	//V_Flag returns the number 0 if no error. The error number if there's error oppressed by /Z
			string smsg1="Problem openning port:" +com+". Try the following:\r"
			smsg1+="0.- TURN IT ON!\r"
			smsg1+="1.- Verify is not being used by another program\r"
			smsg1+="2.- Verify the PORT is available in Device Manager (Ports COM). If not, rigth-click and scan hardware changes or disable and enable it.\r"
			DoAlert /T="Unable to open Serial Port" 0, smsg1
			return 0
		endif
		flag = 1
	else
		//Error Message with an OK button
		string smsg="Problem openning port:" +com+". Try the following:\r"
		smsg+="0.- TURN IT ON!\r"
		smsg+="1.- Verify is not being used by another program\r"
		smsg+="2.- Verify the PORT is available in Device Manager (Ports COM). If not, rigth-click and scan hardware changes or disable and enable it.\r"
		DoAlert /T="Unable to open Serial Port" 0, smsg
//		Abort "Execution aborted.... Restart IGOR"
		flag = 0
	endif
	return flag 
end
//Initialize data needed
//Baudrate: 9600 bps, 		Other data: N, 8, 1 ( no hardware flow control )                                                                               
//Do NOT use NULL Modem Cable

//Response structure
// ## ---- ## -> Everything OK
// #! ---- #! -> Valid command but error during execution
// #? ---- #? -> NOT valid in Range (Channel Nºx out of range)
//When invalid command sent, it is returned: 
//<SP><SP><SP><SP>xxxx is not defined] where “xxxx” is the command user input. 

//endl is 
//	<LF> --> /n
//	<CR> --> /r
//	<LF> <CR> are 0x0A and 0x0D in hex, 10 and 13 in decimal
//space is <SP> (used when commands have no data field)

//****May be not needed "/r/n" at the end of reply; just /r required??****//
//Commands are NOT case sensitive 


//MAGNITUDES
//	Current	is expressed in mA
//	Time 		is expressed in uS

//RANGE
//	Step  -> [ 0 - 127 ]			
//	Repeat_range : 0 - 9999 ( 9999 is repeated for ever , 1 is repeated once... and so on )
//	pwmLevel  -> 0 - 10   	(5 = 50%)

//ECHO MODE COMMAND -> Echo Control 
//echoON returns the command recibed, a <LF><CR> answer and a prompt. echoOFF just a a <LF><CR> answer
//The device is in EchoOFF as default ( after reset too )
Function echoCtrl (ctrl)
	//Format: ECHOON<LF><CR>
	//Format: ECHOOFF<LF><CR>
	variable ctrl 
	string endl = "\n\r"
	string ans
	if (ctrl == 1)
		ans = "ON"
	elseif (ctrl == 0)
		ans = "OFF"
	endif
	VDTWrite2 /O=1 "echo" + ans + endl
end

//****NOT TRUSTED BY LUIS, BUT JUST AN IDEA****************//
//getError() returns the number of error that has happened
Function getError ()
	string endl = "\n\r"
	string reply
	VDTWrite2 /O=1 "Error" + endl
	delay (40)
	VDTRead2 /O=1 /T=endl reply
	print reply
end

//********************************************************//

//To listen the command back from Mightex Led Controller
Function Listen ()
	string reply 
	string endl = "\n\r"
	//VDTRead2 /O=1 /T=endl reply
	VDTRead2 /O=1 /Q reply
	print reply
end
Function ls ()
	return Listen()
end		//Short version of Listen() - For debugging

Function Send (cmd)
	string cmd
	string endl = "\n\r"
	VDTWrite2 /O=1 cmd + endl
end
Function sd (cmd) 
	string cmd
	return Send(cmd)
end

//G	et Current Working Mode
Function getMode(channel)
	//Format: ?MODE CHLNo<LF><CR>
	//return: #mode<CR><LF> 
	variable channel
	string reply
	string endl = "\n\r"
	VDTWrite2 /O=1 "?mode " + num2str(channel) + endl
//	delay (40)
//	VDTRead2 /O=1 /T=" " reply
//	//return 
	print reply
end

//Set Current Working Mode
Function setMode (channel, mode)
	//Format: MODE CHLno mode<LF><CR>	
	variable channel
	variable mode
	string endl = "\n\r"
	string sp = " "
	string cmd = "MODE 0" + num2str(channel) + sp + num2str(mode) + endl
	VDTWrite2 /O=1 cmd	
end
//	MODE: 	 	0 	DISABLE
//				1	NORMAL
//				2	STROBE 
//				3	TRIGGER	(NOT Implemented)


//NORMAL MODE COMMANDS
//Set Normal Mode Parameters
Function setNormalParameters (channel, Imax, Iset)
	//Format: NORMAL CHLno Imax Iset<LF><CR>
	variable channel
	variable Imax
	variable Iset
	string endl = "\n\r"
	string sp = " "
	string cmd = "NORMAL 0" + num2str(channel) + sp + num2str(Imax) + sp + num2str(Iset) + endl
	VDTWrite2 /O=1 cmd
end

//Get Normal Mode Parameters
Function getNormalParameters (channel)
	//Format: ?CURRENT CHLno<LF><CR> 
	//return: #Cal1 Cal2 Imax Iset<CR><LF> 
	variable channel 
	string reply
	string endl = "\n\r"
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
	string endl = "\n\r"
	string sp = " "
	VDTWrite2 /O=1 "CURRENT 0"+num2str(channel) + sp + num2str(Iset) + endl	
end

//STROBE MODE COMMANDS
//Set Strobe Mode Parameters
Function setStrobeParameters (channel, Imax, Repeat)
	//Format: STROBE CHLno Imax Repeat<LF><CR> 
	variable channel
	variable Imax
	variable Repeat
	string endl = "\n\r"
	string sp = " "	
	VDTWrite2 /O=1 "strobe " + num2str(channel) + sp + num2str(Imax) + sp + num2str(Repeat) + endl	
end

//Set Strobe Profile 
Function  setStrpProfile (channel, step, Iset, Tset)
	//Format: STRP CHLno STPno Iset Tset<LF><CR>
	//Sequence Example:
	//STRP 1 0 500 2000<LF><CR> /* (500mA, 2000uS ) */ 
	//STRP 1 1 10 100000<LF><CR> /* (10mA, 100000uS) */
	//STRP 1 2 0 0 <LF><CR> /* (0,0) –End */ 
	variable channel
	variable step
	variable Iset
	variable Tset
	string endl = "\n\r"
	string sp = " "
	VDTWrite2 /O=1 "strp " + num2str(channel) + sp + num2str(step) + sp + num2str(Iset) + endl	
end

//Get Strobe Mode Parameters
Function getStrobeParameters (channel)
	//Format: ?STROBE CHLno<LF><CF> 
	//retrun: #Imax Repeat<CR><LF> 
	variable channel
	string reply
	string endl = "\n\r"
	VDTWrite2 /O=1 "?strobe " + num2str(channel) + endl
	delay (40)
	VDTRead2 /O=1 /T=endl reply
	print reply	
end

//Get Strobe Mode Profile Parameters
Function getStrpParameters (channel)
	//Format: ?STRP CHLno<LF><CR> 
	//return: #Iset1 Tset1 <CR><LF>... 
	variable channel
	string reply
	string endl = "\n\r"
	VDTWrite2 /O=1 "?strp " + num2str(channel) + endl
	delay (40)
	VDTRead2 /O=1 /T=endl reply
	print reply	
end
	

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
	
//OTHER COMMANDS
//Get Channel Load Voltage
Function getLoadV (channel)
	//Format: LoadVoltage CHLno<LF><CR> 
	//return: #CHLno:vvvvv<CR><LF> [in mV]
	//Note: As the controller polls the load voltage in a 20ms interval, this feature is proper for NORMAL mode or slow Strobe mode only. 
	variable channel
	string endl = "\n\r"
	string reply
	VDTWrite2 /O=1 "LoadVoltage " + num2str(channel) + endl
	delay (40)
	VDTRead2 /O=1 /T=endl reply
	print reply
end

//Shows the deviceInfo
Function getDevInfo ()
	//Format: DEVICEINFO<LF><CR> 
	string endl = "\n\r"
	string reply
	VDTWrite2 /O=1 "DeviceInfo" + endl
//	delay (40)
//	VDTRead2 /O=1 /T=endl reply
//	print reply
end

//Reset Device
Function reset ()
	//Format: Reset<LF><CR> ( Soft Reset )
	string endl = "\n\r"
	VDTWrite2 /O=1 "Reset" + endl
end

//Restore Factory Default 
Function restore ()
	//Format: RESTOREDEF<LF><CR> 
	string endl = "\n\r"
	VDTWrite2 /O=1 "restoredef" + endl
end

//Store All settings to NV memory
Function store ()
	//Format: STORE<LF><CR>
	string endl = "\n\r"
	VDTWrite2 /O=1 "store" + endl
end

//Set Fan PWM Ratio
Function pwm (pwmLevel)
	//Format: FanPWM PWMLevel<LF><CR>
	//Range pwmLevel  -> 0 - 10   	(5 = 50%)
	variable pwmLevel
	string endl = "\n\r"
	VDTWrite2 /O=1 "FanPWM " + num2str(pwmLevel) + endl
end