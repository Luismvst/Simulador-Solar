#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//#include "Leds"

Menu "S.Solar"
	"Init/ç", /Q, init_SolarPanel()
	
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
	variable/G :LedController:channel = 1
	Show_Panels()	
	SetDataFolder saveDFR
end

Function Show_Panels ()

	svar COM = root:SolarSimulator:LedController:COM
	if (strlen (COM) == 0)
		which_COM ()		
	elseif (strlen (COM) > 0)
		//We should check if the com of the serial port is useless or not, to kill the window or throw a DoAlert
		init_Leds(COM)
		if (WinType("COMPanel")==7) //True if COMPanel exists as a name of a Panel "explicitly" ( non a graph or anythg else)
			killWindow COMPanel
			print "COMPanel is dead now"
			Solar_Panel ()
		endif
		
	endif
	//Solar_Panel()
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
			genDFolders(":PapeleraDeVariables")
			//init() everything. Estrategia ir haciendo
			//cosas avisando a la gente de qué debe hacer
			
			//GetData se hace aquí, y dentro de cada initX()
		endif
	endif
	SetDataFolder path
	make /N=1 /O  root:SolarSimulator:PapeleradeVariables:ss
	wave ss = root:SolarSimulator:PapeleradeVariables:ss
	string nameDisplay 
	nvar Imax = root:SolarSimulator:LedController:Imax
	nvar Iset = root:SolarSimulator:LedController:Iset
	nvar channel = root:SolarSimulator:LedController:channel
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
	NewPanel /K=0 /W=(730,63,1133,581) as "SolarSimulatorPanel"
	DoWindow /C SSPanel
	
	Sliders(Imax)
	
	//Text
	SetDrawEnv fstyle= 1
	DrawText 40,61,"   Max \rCurrent"
	SetDrawEnv fstyle= 1
	DrawText 99,62,"   Set  \rCurrent "
	
	//Buttons
	
	Button buttonApplyCurrent,pos={141.00,143.00},size={45.00,21.00},proc=ButtonProc_SimSolar,title="Apply"
	Button buttonApplyCurrent,help={"Click to Apply changes in current"},fSize=12
	Button buttonApplyCurrent,fColor=(1,16019,65535)
	Button buttonSetParameters,pos={43.00,174.00},size={97.00,22.00},proc=ButtonProc_SimSolar,title="Parameters"
	Button buttonSetParameters,help={"Click to Apply changes in parametes"},fSize=12
	Button buttonSetParameters,fColor=(40000,20000,65535)
	Button buttonMode,pos={288.00,42.00},size={107.00,30.00},proc=ButtonProc_SimSolar,title="Normal Mode"
	Button buttonMode,fSize=12,fColor=(65535,49157,16385)
	
	//PopUps
	PopupMenu popupchannel,pos={284.00,11.00},size={113.00,19.00},proc=PopMenuProc_SimSolar,title="\\f01Select Channel"
	PopupMenu popupchannel,help={"Selecction of the channel the panel will affect to"}
	PopupMenu popupchannel,mode=1,popvalue="1",value= #"\"1;2;3;4;5;6;7;8\""
	

	//ValDisplay
//	ValDisplay valdisp0,pos={36.00,148.00},size={39.00,17.00}
//	ValDisplay valdisp0,limits={0,0,0},barmisc={0,100}
//	ValDisplay valdisp0,value= #"root:SolarSimulator:LedController:Imax"
//	ValDisplay valdisp1,pos={97.00,147.00},size={39.00,17.00}
//	ValDisplay valdisp1,limits={0,0,0},barmisc={0,100}
//	ValDisplay valdisp1,value= #"root:SolarSimulator:LedController:Iset"
	
	
end

Function CheckProc_SimSolar(cba) : CheckBoxControl
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

Function SliderProc_SimSolar(sa) : SliderControl
	STRUCT WMSliderAction &sa
	
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set 
				Variable curval = sa.curval
				nvar Iset = root:SolarSimulator:LedController:Iset
				nvar Imax = root:SolarSimulator:LedController:Imax
				//This was not necesary
				if(Imax<Iset)
						//To ensure: Iset <= Imax
						Iset=Imax
				elseif (Imax==0)
						Iset=0
				endif
				
				if (stringmatch (sa.ctrlname, "slider0"))
					//This makes the second slider to be syncronized to the first one in possible top values.
					Sliders (Imax)
				endif
			elseif (sa.eventCode & 4 ) //Fix an error on sliders, if maximun level has changed to 0
			//I dont like this. Need a revision
//				if (Iset == 0 && Imax > Iset + 1 )
//					Iset=Iset+1
//				endif
			endif
			break
	endswitch

	return 0
End

Function SetVarProc_SimSol(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			nvar Iset = root:SolarSimulator:LedController:Iset
			nvar Imax = root:SolarSimulator:LedController:Imax
			if (Iset>Imax)
				Iset = Imax
			elseif (Imax == 0)
				Iset = 0
			
			endif
			if (stringmatch (sva.ctrlname, "setvarimax"))
				//We try to adjust the Imax limit for sliders ( so it is only modified if you change imax )
				//The funcition sliders avoid to roll it with the wheel, so i do this temporarily
				//Sliders (Imax)
				variable tick
				if (Imax < 6)
					tick = -1
				else
					tick = -5
				endif
				Slider slider0,limits={0,1000,1},variable= root:SolarSimulator:LedController:Imax,ticks= tick
				Slider slider1,limits={0,Imax,1},variable= root:SolarSimulator:LedController:Iset,ticks= tick
				SetVariable setvariset,limits={0,Imax,1},value= root:SolarSimulator:LedController:Iset
			endif
			break
		case -1: // control being killed
			break
		case 6:
			break
	endswitch

	return 0
End

Function ButtonProc_SimSolar(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			strswitch (ba.ctrlname)	
				nvar channel = root:SolarSimulator:LedController:channel
				//nvar Imax = root:SolarSimulator:LedController:Imax
				case "buttonApplyCurrent":
					nvar Iset = root:SolarSimulator:LedController:Iset
					setNormalCurrent (channel, Iset)
				break
				case "buttonSetParameters":
					//Defect parameters to start 
					setNormalParameters (channel, 100, 0)
				break
				case "buttonMode":
					setMode (channel, 1)
					//	MODE: 	 	0 	DISABLE
					//				1	NORMAL
					//				2	STROBE 
				break
			endswitch
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function PopMenuProc_SimSolar(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			strswitch (pa.ctrlname)
				case "popupchannel":
					nvar channel = root:SolarSimulator:LedController:channel
					channel = popNum
				break
			endswitch
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function Sliders (Imax)
	
	variable Imax 
	variable tick 
	if (Imax < 6)
		tick = -1
	else
		tick = -5
	endif
	//Slider	
	Slider slider0,pos={50.00,70.00},size={26.00,66.00},proc=SliderProc_SimSolar
	Slider slider0,help={"Current in mA"},labelBack=(65535,65535,65535)
	Slider slider0,limits={0,1000,1},variable= root:SolarSimulator:LedController:Imax,ticks= tick
	Slider slider1,pos={100.00,70.00},size={26.00,66.00},proc=SliderProc_SimSolar
	Slider slider1,help={"Current in mA"},labelBack=(65535,65535,65535)
	Slider slider1,limits={0,Imax,1},variable= root:SolarSimulator:LedController:Iset,ticks= tick
	
	//SetVar
	//Conservo este set variable por si acaso quiero hacer algo con él. Sino borrar.
//	SetVariable setvarmaxcurrent,pos={32.00,187.00},size={140.00,18.00},title="Max. Current"
//	SetVariable setvarmaxcurrent,limits={0,1000,1},value= root:SolarSimulator:LedController:Imax
	SetVariable setvarimax,pos={40.00,144.00},size={44.00,18.00},proc=SetVarProc_SimSol, title=" "
	SetVariable setvarimax,fColor=(65535,65535,65535)
	SetVariable setvarimax,limits={0,1000,1},value= root:SolarSimulator:LedController:Imax
	SetVariable setvariset,pos={90.00,144.00},size={44.00,18.00},proc=SetVarProc_SimSol, title=" "
	SetVariable setvariset,fColor=(65535,65535,65535)
	SetVariable setvariset,limits={0,Imax,1},value= root:SolarSimulator:LedController:Iset
	//May be Imax in setvariset is not necessary. Lets see if this configuration works 
End

Function which_COM ()	
	PauseUpdate; Silent 1		// building window...
	DoWindow /K COMPanel; DelayUpdate
	NewPanel /K=1 /W=(690,55,982,121) as "Choose COM SerialPort"
	DoWindow /C COMPanel
	CheckBox check1,pos={10.00,15.00},size={50.00,15.00},proc=CheckProc_SimSolar,title="COM1"
	CheckBox check1,help={"To know which COM Port you are using, right-click on Equipo and click on Administrar. It will show you in \"Administrador de dispositivos/Puertos\" the current COM's that are being used."}
	CheckBox check1,value= 0,mode=1
	CheckBox check2,pos={10.00,40.00},size={50.00,15.00},proc=CheckProc_SimSolar,title="COM2"
	CheckBox check2,value= 0,mode=1
	CheckBox check3,pos={85.00,14.00},size={50.00,15.00},proc=CheckProc_SimSolar,title="COM3"
	CheckBox check3,value= 0,mode=1
	CheckBox check4,pos={85.00,40.00},size={50.00,15.00},proc=CheckProc_SimSolar,title="COM4"
	CheckBox check4,value= 0,mode=1
	CheckBox check5,pos={160.00,14.00},size={50.00,15.00},proc=CheckProc_SimSolar,title="COM5"
	CheckBox check5,value= 0,mode=1
	CheckBox check6,pos={160.00,40.00},size={50.00,15.00},proc=CheckProc_SimSolar,title="COM6"
	CheckBox check6,value= 0,mode=1
	CheckBox check7,pos={235.00,13.00},size={50.00,15.00},proc=CheckProc_SimSolar,title="COM7"
	CheckBox check7,value= 0,mode=1
	CheckBox check8,pos={235.00,40.00},size={50.00,15.00},proc=CheckProc_SimSolar,title="COM8"
	CheckBox check8,value= 0,mode=1
	
end