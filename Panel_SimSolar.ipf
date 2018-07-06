#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//#include "Leds"

Menu "S.Solar"
	"Init 1/ç", /Q, init_SolarPanel()
	"Initialize", /Q, init_SolarPanel(init=1)
	
	//"Init 2/´", /Q, init_SolarPanel2()
	
End
//Function init_SolarPanel2()
//	if (ItemsinList (WinList ("SS", ";", "")) > 0) 
//		DoWindow /F SS
//		return 0
//	else
//		Execute "SS()"
//	endif
//end

Function init_SolarPanel([init])
	
	variable init
	if (paramisdefault (init))
		init=0
	endif
	DFRef saveDFR=GetDataFolderDFR()
	string path = "root:SolarSimulator"
	if(!DatafolderExists(path) || init == 1)
		string smsg = "You have to initialize first.\n"
		smsg += "Do you want to initialize?\n"
		DoAlert /T="Unable to open the program" 1, smsg
		if (V_flag == 2)		//Clicked <"NO">
			//Abort "Execution aborted.... Restart IGOR"
		elseif (V_flag == 1)	//Clicked <"YES">
			genDFolders(path)
			genDFolders(path + ":Storage")			
			genDFolders(path + ":LedController")
			genDFolders(path + ":LoadedWaves")
			//PATHS will be created at the same time as the panel does. But when the buttons or something gets killed by the destruction
			//of the own panel, i want paths to be destroyed too.
							
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
//	string/G COM = selectComLeds ()
	variable/G channel = 1
//	if (strlen (com) == 0) 
//		DoAlert 0, "There is no COM connected"
//	else 
//		init_Leds(com)
//	endif	
	Solar_Panel ()
	SetDataFolder saveDFR
end

Function/S selectComLeds()
	Variable comNum=1
	Prompt comNum,"COM Port",popup,"COM1;COM2;COM3;COM4;COM5;COM6;COM7;COM8;USB"
	DoPrompt "Choose the COM Port",comNum
	if (V_Flag)	
		return ""		// user canceled
	endif
	string com = "COM" + num2str (comNum)
	return com
End

Function CheckProc_SimSolar(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			string check_name = cba.ctrlname
			variable num = str2num (check_name[5])
			if (num>=0 && num<=5)
				Check_Enable(num, checked)
			endif
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
			wave LedLevel = root:SolarSimulator:Storage:LedLevel
			strswitch (sva.ctrlname)
				// sva.dval -> variable value
				case "setvarLed1":	
					wave ledwave = root:SolarSimulator:LedController:LED470
//					nvar ledlevel = root:SolarSimulator:Storage:LedLevel1
					Led_Control(ledwave, ledlevel[0])
				break
				case "setvarLed2":
					wave ledwave = root:SolarSimulator:LedController:LED850
//					nvar ledlevel = root:SolarSimulator:Storage:LedLevel2
					Led_Control(ledwave, ledlevel[1])
				break
				case "setvarLed3":
					wave ledwave = root:SolarSimulator:LedController:LED1540
//					nvar ledlevel = root:SolarSimulator:Storage:LedLevel3
					Led_Control(ledwave, ledlevel[2])
				break
			endswitch
		break
//		case 4: // Mouse wheel up
//			strswitch (sva.ctrlname)
//				case "setvarLedRojo":
//				
//				break
//			endswitch
//		break
//		case 5: // Mouse wheel down
//			strswitch (sva.ctrlname)
//				case "setvarLedRojo":
//					
//				break
//			endswitch
//		break
		case -1: // control being killed
			break
		case 6:
			break
	endswitch

	return 0
End

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
//				case "buttonApplyCurrent":
//					setNormalCurrent (channel, Iset)
//				break
//				case "buttonSetParameters":
//					//Defect parameters to start 
//					Imax = 100
//					Iset = 50
//					setNormalParameters (channel, Imax, Iset)
//				break
//				case "buttonMode1":
//					//prueba (channel, 100, 60)
//					setMode (channel, 1)
//					//	MODE: 	 	0 	DISABLE
//					//				1	NORMAL
//					//				2	STROBE 
//				break
//				case "buttonMode0":
//					//Disable
//					setMode (channel, 0)
//				break
//				case "buttonInit":
//					svar com = root:SolarSimulator:com
//					init_Leds (com)
//				break
				case "buttonCargarOnda":					
					Load_Wave()
				break
				case "buttonLoadLed":
//					LoadLed("D:\Luis\UNIVERSIDAD\4º AÑO\Prácticas Empresa\Igor\Waves\SLeds")
					LoadLed("C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\Espectros_LEDS")
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

Function PopMenuProc_SimSolar(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			String paName = pa.ctrlname
			
			strswitch (pa.ctrlname)
				case "popupchannel":
					nvar channel = root:SolarSimulator:channel
					channel = popNum
				break
//				//CODIGO DE IVAN PARA LOS POPUP DROPDOWNS.
				case "popupSubSref":	//Cargar Sref
					//Note: lOOK if /H is necessary (it creates a copy of the loaded wave)
					Load_Wave(fname=popStr, loadpath="C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\espectros_referencia")
				break
				case "popupSubSlamp":	//Cargar Slamp
					Load_Wave(fname=popStr, loadpath="C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\espectro_simuladorSolar")
				break
				default: 
					if (stringmatch (paName, "popupSub*"))
						variable num
						if (str2num(paName[8])>=0 && str2num(paName[8])<=5)
							wave popValues = root:SolarSimulator:Storage:popValues
							num = str2num(paName[8])
							if ( cmpstr (popStr,"Yes") == 0)
//								popValues[str2num(paName[8])]=1
								popValues[num]=1
							elseif ( cmpstr (popStr, "No") == 0 )
								popValues[num]=0
							endif
							Pop_Action (num, popValues)
						endif
						if (stringmatch (paName, "popupSubDUT*"))//Cargar EQEdut
							num = str2num(paName[11])	
							Load_Wave(fname=popStr, id=num, loadpath="C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\EQE_DUT")
						elseif (stringmatch (paName, "popupSubREF*"))//Cargar EQEref	
							num = str2num(paName[11])
							Load_Wave(fname=popStr, id=num, loadpath="C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\EQE_REF")
						endif
						
					endif
				break
			endswitch
			
//			if (stringmatch(paName, "popupSub*")   && str2num(paName[8])>=0 && str2num(paName[8])<=5 )
//				wave popValues = root:SolarSimulator:Storage:popValues
//				variable num = str2num(paName[8])
//				if ( cmpstr (popStr,"Yes") == 0)
////					popValues[str2num(paName[8])]=1
//					popValues[num]=1
//				elseif ( cmpstr (popStr, "No") == 0 )
//					popValues[num]=0
//				endif
//				Pop_Action (num, popValues)
//			endif
			
		break
		case -1: // control being killed
			break
	endswitch
	return 0
End

Function Pop_Action (popNum, popValues)
	variable popNum
	wave popValues
	string checkX
	string popupX
	string popupY
	string valdisp1
	string valdisp2
	checkX = "check" + num2str(popNum)
	popupX = "popupSubREF" + num2str(popNum)
	popupY = "popupSubDUT" + num2str(popNum)
	if (popValues[popNum])
		CheckBox $checkX, 	disable = 0
		PopupMenu $popupX,	disable = 0
		PopupMenu $popupY,	disable = 0	
	else
		CheckBox $checkX, 	disable = 1
		PopupMenu $popupX,	disable = 2
		PopupMenu $popupY,	disable = 2
	endif	
end


Function Check_Enable (id, checked)
	variable id, checked
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path
	variable i
	//*********Coming Soon: refresh*************//
	variable refresh //Selected 
	string checkX
	string valdisp1
	string valdisp2
	for (i=0;i<6; i++)
		checkX = "check" + num2str(i)
		valdisp1 = "valdispJREF" + num2str(i)
		valdisp2 = "valdispJ" + num2str(i)
		if (id != i)
			CheckBox $checkX, value = 0//, labelBack = (0, 0, 0)
			ValDisplay $valdisp1, disable = 2
			ValDisplay $valdisp2, disable = 2
		elseif (checked)			
			//I dont know why color does not change when checked. 
			CheckBox $checkX, value = 1//, labelBack = (50000, 65535, 20000)
			ValDisplay $valdisp1, disable = 0
			ValDisplay $valdisp2, disable = 0
		else
			CheckBox $checkX, value = 0
			ValDisplay $valdisp1, disable = 2
			ValDisplay $valdisp2, disable = 2
		endif
	endfor
	SetDataFolder savedatafolder
end

Function LoadLed (path)
	string path
	string current = "root:SolarSimulator:LedController"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder current
	NewPath /O path_Led, path
	LoadWave /O /P=path_led
	SetDataFolder savedatafolder
End

Function Load_Wave ([loadpath, id, fname] )
	//Path is necessary when you want to load smthg from folder. 
	//Id is necessary to know which SubCell is loading each wave (0-5). If there's no ID, it become general
	//fname is necessary if you want to load an specific file (from dropdown for example)
	string loadpath
	variable id
	string fname
	
	string current = "root:SolarSimulator:LoadedWaves"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder current
	variable flag= 0
	string wavenames
	
	if (paramisdefault(loadpath))
		//Path allows you to choose the file to load.
		//loadpath = "D:\Luis\UNIVERSIDAD\4º AÑO\Prácticas Empresa\Igor"
		loadpath = "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS"
	endif
	if (paramisdefault(id))
		//This is global data loaded
		id = -1
	endif
	if (paramisdefault(fname))
		flag=1
		fname = ""	
	endif
	
	string fich_name
	//stringlist ( pathlist ("*", ";", "") , way)
	if (id >= 0 && id<=5) 
		gendfolders(current + ":Subcell" + num2str(id))
		SetDataFolder current + ":Subcell" + num2str(id)
	elseif (id == -1 && stringmatch (fname,"*XT*") )
		gendfolders(current + ":SimulatorSpectre")
		SetDataFolder current + ":SimulatorSpectre"
	elseif (id == -1 && stringmatch (fname,"*AM*") )
		gendfolders(current + ":SpectreRef")
		SetDataFolder current + ":SpectreRef" 
	endif
	
	NewPath/Q/O path_loadwave, loadpath
	LoadWave/H /P=path_loadwave /O fname 	

	wavenames = S_wavenames
	if (V_flag)	//This avoid problems if we cancel the fich-loading ( have you load smthg or not? )
		fich_name = S_FileName
		if (strlen(wavenames) == 0) //The fich has no name. Error 
			print "Error in the fich-loading"						
			return -1
		else
			if (ItemsInList(WinList("SSPanel",";",""))>0)
				string tlist=TraceNameList("SSPanel#SSGraph",";",1)
				wave loadedwave = $(StringFromList(0, wavenames))
				//If we load a spectrum, it will be displayed on the right axis. EQE will be desplayed in the left axis 
				//if (stringmatch (StringFromList(0, wavenames),"*XT*") || stringmatch (StringFromList(0, wavenames),"*AM*") )
				if (isScaled(loadedwave))
					Draw(position = 0, trace = loadedwave)
				else
					variable newstart = 350
					variable delta = newDelta (loadedwave, newstart)
					SetScale /P x, newstart, delta, loadedwave
					Draw(position = 1, trace = loadedwave)
				endif
			endif
		endif
	else 
		SetDataFolder savedatafolder
		return -1
	endif
	SetDataFolder savedatafolder
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
	//Posibilidad al cerrar el programa:
	//Kill loadedwaves... (luis cell programm)
	KillPath /A
End

//ComingSoon//
//Function WhatToDraw()
//End

//It will be added new features to the Draw Function to be functional for this procedure
Function Draw ([position, trace, autoescale, color])//, [others])
	variable position		//0 -> Left, 1 -> Right
	wave trace					//Name of the wave to be drawn
	variable autoescale		//0 -> No , 1 -> Yes
	variable color			//0 -> Choose random color,  1 -> red, 2 -> green, 3 -> blue, 4 -> black, 5 -> white
	if (paramisdefault(position))
		position = 0
	endif
	if (paramisdefault(trace))
		trace = Nan
	endif
	if (paramisdefault(autoescale))
		autoescale = 0
	endif
	if (paramisdefault(color))
		color = 0
	endif
	//do not draw the same thing twice
	string tlist=TraceNameList("SSPanel#SSGraph",";",1)
	if (stringmatch (tlist, "*" + NameOfWave(trace) + "*"))
		//i dont know why just "trace" does not work with the command removefromgraph...
		RemoveFromGraph /W=SSPanel#SSGraph $NameOfWave(trace)
	endif
	if (position == 0)
		AppendtoGraph /W=SSPanel#SSGraph trace
	else
		AppendtoGraph/R /W=SSPanel#SSGraph trace
		Label/W=SSPanel#SSGraph right "Spectrum"
		ModifyGraph /W=SSPanel#SSGraph minor=1
	endif
	if (autoescale)
		SetAxis/A/W=SSPanel#SSGraph
	endif
	ModifyGraph/W=SSPanel#SSGraph tick=2, zero=2,  standoff=0
	if (color == 0)
		SetColorGraph ("SSPanel#SSGraph")
	else
//		switch (color)
//		case 1: 
//			ModifyGraph /W=SSPanel#SSGraph rgb(trace)=(65535, 0, 0)
//		break
//		case 2:
//			ModifyGraph /W=SSPanel#SSGraph rgb(trace)=(0, 65535, 0)
//		break
//		case 3:
//			ModifyGraph /W=SSPanel#SSGraph rgb(trace)=(0,0,65535)
//		break
//		case 4:
//			ModifyGraph /W=SSPanel#SSGraph rgb(trace)=(65535, 65535, 65535)
//		break
//		case 5:
//			ModifyGraph /W=SSPanel#SSGraph rgb(trace)=(0,0,0)
//		break
//		default: 
//			ModifyGraph /W=SSPanel#SSGraph rgb(trace)=(20000, 20000, 20000)
//		endswitch
	endif		
End

	
//Muestra con Draw solo lo tickeado por checkthings
//Function Select_Desplay ()
//	string path = "root:SolarSimulator:LedController"
//	string savedatafolder = GetDataFolder (1) 
//	SetDataFolder path
//	string waves = wavelist ("*", --.-
//	
//	
//	SetDataFolder savedatafolder
//End

Function Led_Control (ledwave, ledlevel)
	wave ledwave
	variable ledlevel
	string path = "root:SolarSimulator:LedController"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path
	variable delta = newDelta ( ledwave, 350)
	SetScale /P x, 350, delta, ledwave
	Duplicate/O ledwave, ledwave1
	ledwave1 = ledwave1 * ledlevel
	Draw (position = 0, trace = ledwave1, color = 1)
	SetDataFolder savedatafolder	
End

Function newDelta (wav, newstart)
	wave wav
	variable newstart
	variable start = leftx (wav)					
	variable ending = rightx (wav)
	variable newending = newstart/start*ending
	variable rows = DimSize (wav, 0)
	variable newdelta = (newending - newstart)/rows
	return newdelta	
End

Function isScaled (wav)
	wave wav
	variable start = leftx (wav)
	variable delta = deltax (wav)
	variable ending = rightx (wav)
	if (  (delta > 3 && delta < 7) && (start>15 && start<400) )
		return 1
	else 
		return 0
	endif
End

Function/S translate (popValues)
	wave popValues
	string popVal = ""
	variable i 
	for (i = 0; i<6; i++)
		switch(popValues[i])
		case 1: 	
			popVal += "Yes;"
		break
		case 0:
			popVal += "No;"
		break
		endswitch
	endfor
	return trimstring (popVal)
end

Function Solar_Panel()
	
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path
	
	//Initial wave for #GraphPanel
	make /N=1 /O  root:SolarSimulator:Storage:sa
	wave sa = root:SolarSimulator:Storage:sa
	wave sa = root:SolarSimulator:Storage:sa
	string nameDisplay 
	
	//Disable/Enable Dropdowns things on the panel
	make /N=6 /O  :Storage:popvalues
	wave popValues = :Storage:popvalues
	popValues = {1, 1, 1, 0, 0, 0}
	string popVal = translate (popValues)//Yes;No; Selection
	
	//Display traces on graph depending on the checkbox selected
	make /N=10 /O :Storage:Checkwave
	wave checkwave = :Storage:checkwave
	checkwave = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	
	//Values of LedCurrents
	variable/G root:SolarSimulator:LedController:Imax
	variable/G root:SolarSimulator:LedController:Iset
	nvar Imax = root:SolarSimulator:LedController:Imax
	nvar Iset = root:SolarSimulator:LedController:Iset
	Imax = 10; Iset = 0
	
	//Increase power of leds
	make /N=3 /O :Storage:LedLevel
	wave LedLevel = :Storage:LedLevel
	LedLevel = { 0, 0, 0 }

	variable i
	
	//It has been created  when Leds Procedure initialize. 
	nvar channel = root:SolarSimulator:channel
	channel = 1
	PauseUpdate; Silent 1		// building window...
	
	//Paths
	Newpath/Q/O  path_Sref, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\espectros_referencia"
	Newpath/Q/O  path_Slamp, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\espectro_simuladorSolar"
	NewPath/Q/O 	path_SLeds, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\Espectros_LEDS"
	
//	Newpath/Q/O  path_Sref, "D:\Luis\UNIVERSIDAD\4º AÑO\Prácticas Empresa\Igor\Waves\Sref"
//	Newpath/Q/O  path_Slamp, "D:\Luis\UNIVERSIDAD\4º AÑO\Prácticas Empresa\Igor\Waves\Slamp"
//	NewPath/Q/O 	path_SLeds, "D:\Luis\UNIVERSIDAD\4º AÑO\Prácticas Empresa\Igor\Waves\SLeds"
	
	//Panel
	DoWindow/K SSPanel; DelayUpdate
	NewPanel /K=0 /W=(150,105,1215,776) as "SSPanel"
	DoWindow /C SSPanel
	
	//Text
	SetDrawLayer UserBack
//	SetDrawEnv fstyle= 1
//	DrawText 675,71,"   Max \rCurrent"
//	SetDrawEnv fstyle= 1
//	DrawText 728,72,"   Set  \rCurrent "
	SetDrawEnv linethick= 1.5
	DrawLine 672,639,672,24
	DrawText 43,313,"Cargar S\\BSTD"
	DrawText 179,314,"Cargar S\\BLAMP"
	DrawText 169,357,"Cargar EQE\\BREF"
	DrawText 319,355,"Cargar EQE\\BDUT"
	DrawText 491,353,"Jsc\\BREF\\BOBJETIVO"
	DrawText 574,355,"Jsc\\BREF\\BMEDIDO"
	//Buttons
//	Button buttonApplyCurrent,pos={777.00,152.00},size={45.00,21.00},proc=ButtonProc_SimSolar,title="Apply"
//	Button buttonApplyCurrent,help={"Click to Apply changes in current"},fSize=12
//	Button buttonApplyCurrent,fColor=(1,16019,65535)
//	Button buttonSetParameters,pos={675.00,179.00},size={97.00,22.00},proc=ButtonProc_SimSolar,title="Parameters"
//	Button buttonSetParameters,help={"Click to Apply changes in parametes"},fSize=12
//	Button buttonSetParameters,fColor=(40000,20000,65535)
//	Button buttonMode,pos={891.00,106.00},size={107.00,30.00},proc=ButtonProc_SimSolar,title="Normal Mode"
//	Button buttonMode,fSize=12,fColor=(65535,49157,16385)
//	Button buttonMode1,pos={892.00,145.00},size={107.00,30.00},proc=ButtonProc_SimSolar,title="Disable Mode"
//	Button buttonMode1,fSize=12,fColor=(32792,65535,1)
//	Button buttonInit,pos={672.00,218.00},size={89.00,58.00},proc=ButtonProc_SimSolar,title="Init Serial Port "
//	Button buttonInit,fSize=12,fColor=(52428,1,20971)
	Button buttonCargarOnda,pos={57.00,493.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="Cargar EQE Wave"
	Button buttonCargarOnda,fColor=(16385,65535,41303)
	Button buttonLoadLed,pos={504.00,495.00},size={108.00,23.00},proc=ButtonProc_SimSolar,title="Cargar LedSpectre"
	Button buttonLoadLed,fColor=(65535,16385,16385)
	//PopUps
//	PopupMenu popupchannel,pos={890.00,74.00},size={113.00,19.00},proc=PopMenuProc_SimSolar,title="\\f01Select Channel"
//	PopupMenu popupchannel,help={"Selecction of the channel the panel will affect to"}
//	PopupMenu popupchannel,mode=1,popvalue="1",value= #"\"1;2;3;4;5;6;7;8\""

	PopupMenu popupSubSref,pos={15.00,313.00},size={143.00,19.00},bodyWidth=143,proc=PopMenuProc_SimSolar
	PopupMenu popupSubSref,mode=100,value= #"indexedfile ( path_Sref, -1, \"????\")"
	PopupMenu popupSubSlamp,pos={161.00,314.00},size={100.00,19.00},bodyWidth=100,proc=PopMenuProc_SimSolar
	PopupMenu popupSubSlamp,mode=100,popvalue=" ",value= #"indexedfile ( path_Slamp, -1, \"????\")"
	
	PopupMenu popupSub0,pos={20.00,360.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #0"
	PopupMenu popupSub0,mode=1,popvalue=stringfromlist(0,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub1,pos={20.00,380.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #1"
	PopupMenu popupSub1,mode=1,popvalue=stringfromlist(1,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub2,pos={20.00,400.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #2"
	PopupMenu popupSub2,mode=1,popvalue=stringfromlist(2,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub3,pos={20.00,420.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #3"
	PopupMenu popupSub3,mode=2,popvalue=stringfromlist(3,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub4,pos={20.00,440.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #4"
	PopupMenu popupSub4,mode=2,popvalue=stringfromlist(4,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub5,pos={20.00,460.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #5"
	PopupMenu popupSub5,mode=2,popvalue=stringfromlist(5,popVal),value= #"\"Yes;No\""
	
	//Notes: Mode=100 -> at the beginning in the dropdowns it is shown the item number 100 ( apparently nothing )
	PopupMenu popupSubREF0,pos={125.00,360.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF0,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT0,pos={290.00,360.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT0,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF1,pos={125.00,380.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF1,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT1,pos={290.00,380.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT1,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF2,pos={125.00,400.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF2,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT2,pos={290.00,400.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT2,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF3,pos={125.00,420.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF3,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT3,pos={290.00,420.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT3,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF4,pos={125.00,440.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF4,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT4,pos={290.00,440.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT4,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF5,pos={125.00,460.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF5,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT5,pos={290.00,460.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT5,mode=100,popvalue=" ",value= #"QEList(2)"
	
	//CheckBox
	CheckBox check0,pos={465.00,360.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
	CheckBox check1,pos={465.00,380.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
	CheckBox check2,pos={465.00,400.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
	CheckBox check3,pos={465.00,420.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
	CheckBox check4,pos={465.00,440.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
	CheckBox check5,pos={465.00,460.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
	
	//SetVariable
//	SetVariable setvarLedRojo,pos={263.00,497.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led Rojo"
//	SetVariable setvarLedRojo,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel,live= 1
	
	SetVariable setvarLed1,pos={263.00,500.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led 470"
	SetVariable setvarLed1,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[0],live= 1
	SetVariable setvarLed2,pos={263.00,520.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led 850"
	SetVariable setvarLed2,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[1],live= 1
	SetVariable setvarLed3,pos={263.00,540.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led 1540"
	SetVariable setvarLed3,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[2],live= 1
	
	//ValDisplay
	ValDisplay valdispJREF0,pos={488.00,362.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF0,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJREF1,pos={488.00,382.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF1,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJREF2,pos={488.00,402.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF2,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJREF3,pos={488.00,422.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF3,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJREF4,pos={488.00,442.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF4,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJREF5,pos={488.00,462.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF5,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJ0,pos={573.00,362.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ0,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJ1,pos={573.00,382.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ1,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJ2,pos={573.00,402.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ2,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJ3,pos={573.00,422.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ3,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJ4,pos={573.00,442.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ4,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJ5,pos={573.00,462.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ5,format="",limits={0,0,0},barmisc={0,1000},value= #"0"
	
	//Functions to initialize panel
	for (i = 0; i<6; i++)
		Pop_Action (i, popValues)
	endfor 
	Check_Enable (-1, 0)
	
	//Display 
	Display/W=(0,0,594,292)/HOST=#  :Storage:sa vs :Storage:sa 
//	ModifyGraph mode=3
//	ModifyGraph lSize=2
	ModifyGraph tick=2
	ModifyGraph zero=2
	ModifyGraph mirror=1
	ModifyGraph minor=1
	ModifyGraph standoff=0
	Label left "%"
	Label bottom "nm"
	//Label right "Spectrum"
	SetAxis left*,1
	SetAxis bottom*,2000
	
	SetDrawLayer UserFront
	SetDrawEnv save
	RenameWindow #,SSGraph
	SetActiveSubwindow ##	
end

//Reconstruction of graphPanel when something is removed (for check_Drawing_options )
Function prue()
	ModifyGraph /W=SSPanel#SSGraph  tick=2
	ModifyGraph /W=SSPanel#SSGraph  zero=2
	ModifyGraph /W=SSPanel#SSGraph  mirror=1
	ModifyGraph /W=SSPanel#SSGraph  minor=1
	ModifyGraph /W=SSPanel#SSGraph  standoff=0
end

Window SS() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(68,226,1133,897) as "SSPanel"
	SetDrawLayer UserBack
	SetDrawEnv linethick= 1.5
	DrawLine 619,639,619,24
	DrawText 43,313,"Cargar S\\BSTD"
	DrawText 179,314,"Cargar S\\BLAMP"
	DrawText 169,357,"Cargar EQE\\BREF"
	DrawText 319,355,"Cargar EQE\\BDUT"
	Button buttonCargarOnda,pos={157.00,398.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="Cargar EQE Wave"
	Button buttonCargarOnda,fColor=(16385,65535,41303)
	PopupMenu popupchannel,pos={890.00,74.00},size={113.00,19.00},proc=PopMenuProc_SimSolar,title="\\f01Select Channel"
	PopupMenu popupchannel,help={"Selecction of the channel the panel will affect to"}
	PopupMenu popupchannel,mode=1,popvalue="1",value= #"\"1;2;3;4;5;6;7;8\""
	PopupMenu popupSub0,pos={20.00,360.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #0"
	PopupMenu popupSub0,mode=1,popvalue="Yes",value= #"\"Yes;No\""
	PopupMenu popupSub1,pos={20.00,380.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #1"
	PopupMenu popupSub1,mode=1,popvalue="Yes",value= #"\"Yes;No\""
	PopupMenu popupSub2,pos={20.00,400.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #2"
	PopupMenu popupSub2,mode=1,popvalue="Yes",value= #"\"Yes;No\""
	PopupMenu popupSub3,pos={20.00,420.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #3"
	PopupMenu popupSub3,mode=2,popvalue="No",value= #"\"Yes;No\""
	PopupMenu popupSub4,pos={20.00,440.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #4"
	PopupMenu popupSub4,mode=2,popvalue="No",value= #"\"Yes;No\""
	PopupMenu popupSub5,pos={20.00,460.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #5"
	PopupMenu popupSub5,mode=2,popvalue="No",value= #"\"Yes;No\""
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:SolarSimulator:Storage:
	Display/W=(0,0,594,292)/HOST=#  sa vs sa
	SetDataFolder fldrSav0
	ModifyGraph mode=3
	ModifyGraph lSize=2
	ModifyGraph tick=2
	ModifyGraph zero=2
	ModifyGraph mirror=1
	ModifyGraph minor=1
	ModifyGraph standoff=0
	Label left "%"
	Label bottom "nm"
	SetAxis left*,1
	SetAxis bottom*,1
	SetDrawLayer UserFront
	SetDrawEnv save
	RenameWindow #,SSGraph
	SetActiveSubwindow ##
EndMacro
//CHange the help files of dropdown popups to the following onne (all of them ) when finished window Execution
//PopupMenu popupSub6, help={"Change directory path in function init_SolarPanel()"}

//The older popups. I want to keep them
//PopupMenu popupSub6,pos={15.00,313.00},size={143.00,19.00},bodyWidth=143,proc=PopMenuProc_SimSolar
//PopupMenu popupSub6,mode=2,popvalue="AMG173GLOBAL.ibw",value= #"indexedfile ( path_Sref, -1, \"????\")"
//PopupMenu popupSub7,pos={161.00,314.00},size={100.00,19.00},bodyWidth=100,proc=PopMenuProc_SimSolar
//PopupMenu popupSub7,mode=1,popvalue="XT10open2012.ibw",value= #"indexedfile ( path_Slamp, -1, \"????\")"
//PopupMenu popupSub8,pos={125.00,360.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
//PopupMenu popupSub8,mode=1,popvalue="UPM2367n2_1st_EQE.ibw",value= #"indexedfile ( path_EQEref, -1, \"????\")"
//PopupMenu popupSub9,pos={290.00,360.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
//PopupMenu popupSub9,mode=2,popvalue="UPM2367n2_1st_EQE.ibw",value= #"indexedfile ( path_EQEdut, -1, \"????\")"
//PopupMenu popupSub10,pos={287.00,460.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
//PopupMenu popupSub10,mode=2,popvalue="UPM2367n2_1st_EQE.ibw",value= #"indexedfile ( path_EQEdut, -1, \"????\")"

//Function gaus(num)
//	variable num
//	//if (stringmatch (wavelist("*", ";", ""), "*fit*"))
//	if (stringmatch (traceNameList ("SSPanel#SSGraph", ";", 0), "*fit*"))
//		Removefromgraph  /W=SSPanel#SSGraph fit 
//	endif
//	make/O/N=200 led
//	//make/O/N=200/D fit
//	wave led//, fit
//	led[100]=num
//	CurveFit/Q  gauss, led /D
////	CurveFit/Q  gauss, led /D=fit // /D
////	Appendtograph /W=SSPanel#SSGraph fit
//	//SetAxis /W=SS#SSGraph /A
//end

//function setcolorGraph(winStr)
//	PopupMenu popupSub7,pos={161.00,314.00},size={100.00,19.00},bodyWidth=100,proc=PopMenuProc_SimSolar
//	PopupMenu popupSub7,mode=1,popvalue="XT10open2012.ibw",value= #"indexedfile ( path_Slamp, -1, \"????\")"
//	PopupMenu popupSub8,pos={125.00,360.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
//	PopupMenu popupSub8,mode=1,popvalue="UPM2367n2_1st_EQE.ibw",value= #"indexedfile ( path_EQEref, -1, \"????\")"
//	PopupMenu popupSub9,pos={290.00,360.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
//	PopupMenu popupSub9,mode=2,popvalue="UPM2367n2_1st_EQE.ibw",value= #"indexedfile ( path_EQEdut, -1, \"????\")"