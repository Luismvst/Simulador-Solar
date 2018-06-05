#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//#include "Leds"

Menu "S.Solar"
	"Init", /Q, init_SolarPanel()
	
End


Function init_SolarPanel()
	DFRef saveDFR=GetDataFolderDFR()
	string path = "root:SolarSimulator"
	DFRef dfr = $path
	SetDatafolder dfr
	if (ItemsinList (WinList("SSPanel", ";", "")) > 0)
		SetDrawLayer /W=SSPanel  Progfront
		DoWindow /F SSPanel
		return 0
	elseif (ItemsinList (WinList("COMPanel", ";", "")) > 0)
		SetDrawLayer /W=COMPanel  Progfront
		DoWindow /F COMPanel
		return 0
	endif
	string/G :LedController:COM = ""
	Show_Panels()	
	SetDataFolder saveDFR
end

Function Show_Panels ()

	svar COM = root:SolarSimulator:LedController:COM
//	if (strlen (COM) == 0)
//		which_COM ()		
//	elseif (strlen (COM) > 0)
//		//We should check if the com of the serial port is useless or not, to kill the window or throw a DoAlert
//		init_Leds(COM)
//		if (WinType("COMPanel")==7) //True if COMPanel exists as a name of a Panel "explicitly" ( non a graph or anythg else)
//			killWindow COMPanel
//			print "COMPanel is dead now"
//			Solar_Panel ()
//		endif
//		
//	endif
	Solar_Panel()
end 

Function which_COM ()	
	PauseUpdate; Silent 1		// building window...
	DoWindow /K COMPanel; DelayUpdate
	NewPanel /K=1 /W=(690,55,982,121) as "Choose COM SerialPort"
	DoWindow /C COMPanel
	CheckBox check1,pos={10.00,15.00},size={50.00,15.00},proc=CheckProc_1,title="COM1"
	CheckBox check1,help={"To know which COM Port you are using, right-click on Equipo and click on Administrar. It will show you in \"Administrador de dispositivos/Puertos\" the current COM's that are being used."}
	CheckBox check1,value= 0,mode=1
	CheckBox check2,pos={10.00,40.00},size={50.00,15.00},proc=CheckProc_1,title="COM2"
	CheckBox check2,value= 0,mode=1
	CheckBox check3,pos={85.00,14.00},size={50.00,15.00},proc=CheckProc_1,title="COM3"
	CheckBox check3,value= 0,mode=1
	CheckBox check4,pos={85.00,40.00},size={50.00,15.00},proc=CheckProc_1,title="COM4"
	CheckBox check4,value= 0,mode=1
	CheckBox check5,pos={160.00,14.00},size={50.00,15.00},proc=CheckProc_1,title="COM5"
	CheckBox check5,value= 0,mode=1
	CheckBox check6,pos={160.00,40.00},size={50.00,15.00},proc=CheckProc_1,title="COM6"
	CheckBox check6,value= 0,mode=1
	CheckBox check7,pos={235.00,13.00},size={50.00,15.00},proc=CheckProc_1,title="COM7"
	CheckBox check7,value= 0,mode=1
	CheckBox check8,pos={235.00,40.00},size={50.00,15.00},proc=CheckProc_1,title="COM8"
	CheckBox check8,value= 0,mode=1
	
end
Function Solar_Panel()
	
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	if(!DatafolderExists(path))
		string smsg = "You have to initialize first.\n"
		smsg += "Do you want to initialize?\n"
		DoAlert /T="Unable to open the program" 1, smsg
		if (V_flag == 2)		//Clicked <"NO">
			Abort "Execution aborted.... Restart IGOR"
		elseif (V_flag == 1)	//Clicked <"YES">
			genDFolders(path)
			genDFolders(path + ":LedController")
			genDFolders("root:PapeleraDeVariables")
			//init() everything. Estrategia ir haciendo
			//cosas avisando a la gente de qué debe hacer
			
			//GetData se hace aquí, y dentro de cada initX()
		endif
	endif
	SetDataFolder path
	make /N=1 /O  root:PapeleradeVariables:ss
	wave ss = root:PapeleradeVariables:ss
	string nameDisplay 
	nvar Imax = root:SolarSimulator:LedController:Imax
	nvar Iset = root:SolarSimulator:LedController:Iset
	PauseUpdate; Silent 1		// building window...
	
	//Display 
//	DoWindow /K SolarSimulator;DelayUpdate
//	Display /K=1 /W=(168.75,43.25,840.5,569.25) ss
//	DoWindow /C SolarSimulator;DelayUpdate
//	ModifyGraph  /W=$nameDisplay mirror=1, tick=2, zero=2, minor = 1, mode=3, standoff=0
//	ModifyGraph /W=$nameDisplay lsize=2
//	Label /W=$nameDisplay bottom "Voltage (V)"
//	Label /W=$nameDisplay left "Intensity (A)"	
//	ControlBar /W=$nameDisplay 128
//	ControlBar/W=$nameDisplay  /R 152
//	ControlBar /W=$nameDisplay /L 71
//	ModifyGraph  mirror=1, tick=2, zero=2, minor = 1, mode=3, standoff=0
//	ModifyGraph  lsize=2
//	Label bottom "Voltage (V)"
//	Label left "Intensity (A)"	
//	ControlBar 128
//	ControlBar  /R 152
//	ControlBar /L 71

//	SetDrawLayer /W=SSPanel UserFront
	//Panel
	DoWindow /K SSPanel;DelayUpdate
	NewPanel /K=0 /W=(306,53,709,571) as "SolarSimulatorPanel"
	DoWindow /C SSPanel
	
	//Buttons
	Button buttonClear, pos={278.00,318.00},size={80.00,30.00}, proc=ButtonProcVDP, title="Clean"
	Button buttonClear, fSize=12,fColor=(65535,49157,16385)
	Button buttonMeas, pos={250.00,449.00},size={118.00,47.00}, proc=ButtonProcVDP, title="Measure"
	Button buttonMeas, fSize=16,fColor=(1,16019,65535)
	
	//Slider	
	Slider slider0,pos={52.00,71.00},size={26.00,66.00},proc=SliderProc
	Slider slider0,help={"Current in mA"},labelBack=(65535,65535,65535)
	Slider slider0,limits={0,1000,0},variable= root:SolarSimulator:LedController:Imax,ticks= -5
	Slider slider1,pos={106.00,72.00},size={26.00,66.00},proc=SliderProc
	Slider slider1,help={"Current in mA"},labelBack=(65535,65535,65535)
	Slider slider1,limits={0,Imax,0},variable= root:SolarSimulator:LedController:Iset,ticks= -5
	
	//SetVar
	SetVariable setvarmaxcurrent,pos={237.00,365.00},size={140.00,18.00},title="Max. Current"
	SetVariable setvarmaxcurrent,limits={0,0.5,0.01},value= root:VanDerPauw:K2600:nmax

	//ValDisplay
	ValDisplay valdisp0,pos={253.00,420.00}, size={89.00,17.00}
	ValDisplay valdisp0,barmisc={0,100}
	ValDisplay valdisp0,value=#"root:SolarSimulator:LedController:Imax"
	
	//Text
	DrawText 252,409,"Total Resistance:"
	
	
end

Function CheckProc_1(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			//We take the last number of the variable check'X' to create COM'X'
			//The lowst COM is COM1, so check1 -> COM1	
			//The highest COM is COM8, so check8 -> COM8
			svar COM = root:SolarSimulator:LedController:COM 
			string name = cba.ctrlname		
			COM = "COM" + name[5]
			//print com
			Show_Panels()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
