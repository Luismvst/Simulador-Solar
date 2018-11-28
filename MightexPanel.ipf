
#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


 Function init_mightexPanel()
 
	if (ItemsinList (WinList("LedPanel", ";", "")) > 0)
		SetDrawLayer /W=LedPanel  Progfront
		DoWindow /F LedPanel
		return 0
	endif 
	genDFolders("root:SolarSimulator:MightexPanel")
	
	string path = "root:SolarSimulator:MightexPanel"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path
	make /N=1 /O  sa
	wave sa 
	string nameDisplay 
	
	variable/G Imax
	variable/G Iset
	string/G com
	variable/G channel
	variable /G caution = 0
	nvar Imax 
	nvar channel
	
	PauseUpdate; Silent 1		// building window...
	
	DoWindow /K LedPanel;DelayUpdate
	NewPanel /K=0 /W=(1063,55,1351,223) as "LedPanel"
	DoWindow /C LedPanel
	
	Sliders(Imax)
	
	//Text
	SetDrawEnv fstyle= 1
	DrawText 8,58,"   Max \rCurrent"
	SetDrawEnv fstyle= 1
	DrawText 67,59,"   Set  \rCurrent "
//	SetDrawEnv fstyle= 1
	
	DrawText 153,54,"1º"
	DrawText 149,119,"2º"
	DrawText 117,129,"3º"
	//Buttons
	
	Button buttonApplyCurrent,pos={109.00,131.00},size={167.00,30.00},proc=ButtonProc_Led,title="Apply"
	Button buttonApplyCurrent,help={"Click to Apply changes in current"},fSize=12
	Button buttonApplyCurrent,fColor=(1,16019,65535)
	Button buttonSetParameters,pos={172.00,97.00},size={102.00,31.00},proc=ButtonProc_Led,title="Parameters"
	Button buttonSetParameters,help={"Click to Apply changes in parametes"},fSize=12
	Button buttonSetParameters,fColor=(40000,20000,65535)
	Button buttonMode1,pos={169.00,28.00},size={107.00,30.00},proc=ButtonProc_Led,title="Normal Mode"
	Button buttonMode1,fSize=12,fColor=(65535,49157,16385)
	Button buttonMode0,pos={169.00,62.00},size={107.00,30.00},proc=ButtonProc_Led,title="Disable Mode"
	Button buttonMode0,fSize=12,fColor=(32792,65535,1)
	//PopUps
	PopupMenu popupchannel,pos={164.00,4.00},size={113.00,19.00},proc=PopMenuProc_Led,title="\\f01Select Channel"
	PopupMenu popupchannel,help={"Selecction of the channel the panel will affect to"}
	PopupMenu popupchannel,mode=1,popvalue="1",value= #"\"1;2;3;4;5;6;7;8\""
	PopupMenu popupCom,pos={15.00,4.00},size={111.00,19.00},bodyWidth=60,proc=PopMenuProc_Led,title="ComPort"
	PopupMenu popupCom,mode=1,popvalue=com,value= #"\"COM1;COM2;COM3;COM4;COM5;COM6;COM7;COM8;USB\""

end
 //*************************************************************************************************************//
Function SliderProc_Led(sa) : SliderControl
	STRUCT WMSliderAction &sa
	
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set 
				Variable curval = sa.curval
				nvar Iset = root:SolarSimulator:MightexPanel:Iset
				nvar Imax = root:SolarSimulator:MightexPanel:Imax
				nvar caution = root:SolarSimulator:MightexPanel:caution
				//Security
				if (Imax>=600 && !caution)
					string mss="Caution, Imax can be dangerous for the useful life of the leds\r\r"
					mss+="Please, use this Imax's values at your own risk"					
					DoAlert /T="Alert!! Leds can be in danger" 0, mss
					caution = 1	
				elseif (Imax <600)
					caution = 0			
				endif
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
 Function SetVarProc_Led(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
 	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			nvar Iset = root:SolarSimulator:MightexPanel:Iset
			nvar Imax = root:SolarSimulator:MightexPanel:Imax
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
 Function ButtonProc_Led(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if (ba.eventcode == -1 || ba.eventcode == 2 || ba.eventcode == 6)
		ba.blockReentry=1
	endif
	switch( ba.eventCode )
		case 2: // mouse up
			nvar channel = root:SolarSimulator:MightexPanel:channel
			nvar Imax = root:SolarSimulator:MightexPanel:Imax
			nvar Iset = root:SolarSimulator:MightexPanel:Iset
			strswitch (ba.ctrlname)				
				case "buttonApplyCurrent":
					setNormalCurrent (channel, Iset)
				break
				case "buttonSetParameters":
					//Defect parameters to start 
					Imax = 100
					Iset = 0
					setMode (channel, 1)
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
			endswitch
			
			break
		case -1: // control being killed
			strswitch (ba.ctrlname)	
				case "buttonMode0":		//Button Disable being killed
					TurnOffLeds()					
				break
			endswitch
			break
	endswitch
 	return 0
End
// Function Disable_All ()
//	string smsg = "Do you want to disable all channels?\n"
//	DoAlert /T="Disable before Exit" 1, smsg
//	if (V_flag == 2)		//Clicked <"NO">
//	//Abort "Execution aborted.... Restart IGOR"
//		return 0
//	elseif (V_flag == 1)	//Clicked <"YES">
//		variable channel			
//		for (channel=1;channel<13;channel+=1)	//12 channels
//			setMode (channel, 0)
//		endfor
//		KillDataFolder /Z root:SolarSimulator:MightexPanel
//	endif
//End
 Function Sliders (Imax)
	
	variable Imax 
	variable tick 
	if (Imax < 6)
		tick = -1
	else
		tick = -5
	endif
	//Slider	
	Slider slider0,pos={18.00,67.00},size={26.00,66.00},proc=SliderProc_Led
	Slider slider0,help={"Current in mA"}
	Slider slider0,limits={0,1000,1},variable= root:SolarSimulator:MightexPanel:Imax,ticks= tick
	Slider slider1,pos={68.00,67.00},size={26.00,66.00},proc=SliderProc_Led
	Slider slider1,help={"Current in mA"}
	Slider slider1,limits={0,Imax,1},variable= root:SolarSimulator:MightexPanel:Iset,ticks= tick
	
//	SetVariable setvarmaxcurrent,pos={32.00,187.00},size={140.00,18.00},title="Max. Current"
//	SetVariable setvarmaxcurrent,limits={0,1000,1},value= root:SolarSimulator:MightexPanel:Imax
	SetVariable setvarimax,pos={8.00,141.00},size={44.00,18.00},proc=SetVarProc_Led, title=" "
	SetVariable setvarimax,fColor=(65535,65535,65535)
	SetVariable setvarimax,limits={0,1000,1},value= root:SolarSimulator:MightexPanel:Imax
	SetVariable setvariset,pos={58.00,141.00},size={44.00,18.00},proc=SetVarProc_Led, title=" "
	SetVariable setvariset,fColor=(65535,65535,65535)
	SetVariable setvariset,limits={0,Imax,1},value= root:SolarSimulator:MightexPanel:Iset
	//May be Imax in setvariset is not necessary. Lets see if this configuration works 
End

Function TurnOffLeds()
	variable i
	for (i = 0; i<13; i++)
		setMode (i, 0)
	endfor
End