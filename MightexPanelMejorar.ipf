#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//#pragma TextEncoding = "UTF-8"
//#include "Leds"

Menu "S.Solar"
	"Init 1/ç", /Q, init_SolarPanel()
	
End

Function init_SolarPanel()

	DFRef saveDFR=GetDataFolderDFR()
	string path = "root:SolarSimulator"
	if(!DatafolderExists(path))
		string smsg = "You have to initialize first.\n"
		smsg += "Do you want to initialize?\n"
		DoAlert /T="Unable to open the program" 1, smsg
		if (V_flag == 2)		//Clicked <"NO">
			//Abort "Execution aborted.... Restart IGOR"
		elseif (V_flag == 1)	//Clicked <"YES">
			genDFolders(path)
			genDFolders(path + ":PapeleraDeVariables")			
			genDFolders(path + ":LedController")
			genDFolders(path + ":LoadedWaves")
			//PATHS will be created at the same time as the panel does. But when the buttons or something gets killed by the destruction
			//of the own panel, i want paths to be destroyed too.
			Newpath/Q/O/Z  path_Sref, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\espectros_referencia"
			Newpath/Q/O/Z  path_Slamp, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\espectro_simuladorSolar"
			Newpath/Q/O/Z  path_EQEref, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\EQE_REF (false)"
			Newpath/Q/O/Z  path_EQEdut, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\EQE_DUT"			
			
			//init() everything. Estrategia ir haciendo
			//cosas avisando a la gente de qué debe hacer
			
			//GetData se hace aquí, y dentro de cada initX()
		endif
	endif
	DFRef dfr = $path
	SetDatafolder dfr
	//Check if this is right becouse i dont know if it is 
	//good to reinitialize leds or something to reset some values... /* check */ 
	if (ItemsinList (WinList("SSPanel", ";", "")) > 0)
		SetDrawLayer /W=SSPanel  Progfront
		DoWindow /F SSPanel
		return 0
	endif 
	string/G COM 
	variable/G channel = 1
	Solar_Panel ()
	SetDataFolder saveDFR
end

Function Solar_Panel()
	
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path
	make /N=1 /O  root:SolarSimulator:PapeleradeVariables:sa
	wave sa = root:SolarSimulator:PapeleradeVariables:sa
	string nameDisplay 
	
	variable/G root:SolarSimulator:LedController:Imax
	variable/G root:SolarSimulator:LedController:Iset
	nvar Imax = root:SolarSimulator:LedController:Imax
	nvar Iset = root:SolarSimulator:LedController:Iset
	nvar channel = root:SolarSimulator:channel
	PauseUpdate; Silent 1		// building window...
	
	DoWindow /K SSPanel;DelayUpdate
	NewPanel /K=0 /W=(790,93,1193,412) as "SolarSimulatorPanel"
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
	Button buttonMode1,pos={290.00,42.00},size={107.00,30.00},proc=ButtonProc_SimSolar,title="Normal Mode"
	Button buttonMode1,fSize=12,fColor=(65535,49157,16385)
	Button buttonMode0,pos={290.00,82.00},size={107.00,30.00},proc=ButtonProc_SimSolar,title="Disable Mode"
	Button buttonMode0,fSize=12,fColor=(32792,65535,1)
	Button buttonInit,pos={25.00,224.00},size={89.00,58.00},proc=ButtonProc_SimSolar,title="Init Serial Port "
	Button buttonInit,fSize=12,fColor=(52428,1,20971)
	//PopUps
	PopupMenu popupchannel,pos={284.00,11.00},size={113.00,19.00},proc=PopMenuProc_SimSolar,title="\\f01Select Channel"
	PopupMenu popupchannel,help={"Selecction of the channel the panel will affect to"}
	PopupMenu popupchannel,mode=1,popvalue="1",value= #"\"1;2;3;4;5;6;7;8\""
		
end

//*************************************************************************************************************//
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
//*************************************************************************************************************//

Function ButtonProc_SimSolar(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if (ba.eventcode == -1 || ba.eventcode == 2 || ba.eventcode == 6)
		ba.blockReentry=1
	endif
	switch( ba.eventCode )
		case 2: // mouse up
			nvar channel = root:SolarSimulator:channel
			nvar Imax = root:SolarSimulator:LedController:Imax
			nvar Iset = root:SolarSimulator:LedController:Iset
			strswitch (ba.ctrlname)				
				case "buttonApplyCurrent":
					setNormalCurrent (channel, Iset)
				break
				case "buttonSetParameters":
					//Defect parameters to start 
					Imax = 100
					Iset = 50
					setNormalParameters (channel, Imax, Iset)
					Sliders(Imax) //To refresh the sliders
				break
				case "buttonMode1":
					//prueba (channel, 100, 60)
					setMode (channel, 1)
					//	MODE: 	 	0 	DISABLE
					//				1	NORMAL
					//				2	STROBE 
				break
				case "buttonMode0":
					//Disable
					setMode (channel, 0)
				break
				case "buttonInit":
					svar com = root:SolarSimulator:com
					init_Leds (com)
				break
			endswitch
			
			break
		case -1: // control being killed
			strswitch (ba.ctrlname)	
				case "buttonMode0":		//Button Disable being killed
//					Disable_All()					
				break
			endswitch
			break
	endswitch

	return 0
End

Function Disable_All ()
	string smsg = "Do you want to disable all channels?\n"
	DoAlert /T="Disable before Exit" 1, smsg
	if (V_flag == 2)		//Clicked <"NO">
	//Abort "Execution aborted.... Restart IGOR"
		return 0
	elseif (V_flag == 1)	//Clicked <"YES">
		variable channel			
		for (channel=1;channel<13;channel+=1)	//12 channels
			setMode (channel, 0)
		endfor
	endif
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
	Slider slider0,help={"Current in mA"}
	Slider slider0,limits={0,1000,1},variable= root:SolarSimulator:LedController:Imax,ticks= tick
	Slider slider1,pos={100.00,70.00},size={26.00,66.00},proc=SliderProc_SimSolar
	Slider slider1,help={"Current in mA"}
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