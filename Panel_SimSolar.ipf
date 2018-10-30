#pragma TextEncoding = "Windows-1252"
//#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//#include "gpibcom"

//IMPROTANT: 
//To make this program work, we have to introduce the folder called "SolarSimulatorData" into the "Igor Pro User Files" Folder.
//The path to that folder is "C:User:Documents:Wavemetric:IgorProUserFiles:" for most computers

//The Mightex Channel is set here.
static constant channel1 = 1
static constant channel2 = 2
static constant channel3 = 3
static constant imax = 500	//Max 1000 mA



Menu "S.Solar"
	SubMenu "Solar Panel"	
		"Display SolarPanel /ç", /Q, Init_SP (val=1)	
		"Initialize Solar Panel ", /Q, Init_SP ()
		"KillPanel /´", /Q, killPanel()
	End
	SubMenu "Keithley 2600"
		"Init Kethley", /Q, init_keithley_k2600()
		"Close Keithley", /Q, close_keithley_k2600(º)
	End
	SubMenu "Mightex"
		"Mightex Panel", /Q, include_Mightex()
		"TurnOn_Leds",/Q, TurnOn_Leds()
		"TurnOff_leds",/Q, TurnOff_Leds()
	End
End

//This kills the actual SSPanel
Function killPanel ()
	KillWindow/Z SSpanel
//	print "Panel dead"
end
//This function does load from the current experiment waves
Function/S Load (fname, num)
	//num is necessary to know which position of SubCell is the wave going to be (wavesubdut"0")
	//fname is necessary to load and display it from the dropdown on the graph
	//
	string fname	
	variable num
	
	string current = "root:SolarSimulator:GraphWaves"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder current
	
	wave wavesubdut0, wavesubdut1, wavesubdut2, wavesubdut3, wavesubdut4, wavesubdut5;
	wave wavesubref0, wavesubref1, wavesubref2, wavesubref3, wavesubref4, wavesubref5;
	wave waveLamp, wavespectra;
	
	variable flag= 0
	string wavenames
	string sdf
	string fich_name
	string destwavename
	string wavepath
	
	if (num<12) 
		wavepath = stringfromlist (0, getQEpath (fname))	
	endif
	switch (num)
	case 12:			
		wavepath = "root:SolarSimulator:Spectra:SRef:"+fname
		break
	case 13:
		wavepath = "root:SolarSimulator:Spectra:SLamp:"+fname
		break
	endswitch
	
	variable id = num2id(num)
	if ( mod (num, 2) && num<12)//type: ref		
		destwavename = "wavesubdut"+num2str(id)	
	elseif ( !mod (num, 2) && num<12)//type: dut
		destwavename = "wavesubref"+num2str(id)		
	elseif (num == 12 )
		destwavename = "waveSpectra"
	elseif (num == 13 )
		destwavename = "waveLamp"
	endif
	
	if (stringmatch (fname,"_none_") )
		wave destwave = $destwavename
		destwave = Nan
		return ""
	endif
	
	wave originwave = $wavepath
	
	//This is necessary becouse duplicate function creates the new wave in the dfr of the originwave
	destwavename = current + ":" + destwavename
	wave destwave = $destwavename
	Duplicate /O originwave, destwave
	
	if(deltax(destwave)<0.01)  /// ÑAPAAA TEMPORAL!!!
		// Escala en micras, pasarla a nm
		SetScale/I x, (leftx(destwave)*1000), (rightx(destwave)*1000), destwave
	endif
	
	Draw (destwave, id)
	Setdatafolder savedatafolder
	return wavepath
end

Function Draw (trace, id)
	wave trace
	variable id
	string cadena
	String traceList = TraceNameList("SSPanel#SSGraph", ";", 1)
	if(strlen(tracelist))
		variable i			
		for (i=0; strlen(cadena)!=0; i+=1)
			cadena = (StringFromList(i, traceList))
			if(stringmatch(cadena, NameOfWave(trace)) )
				 return 0
			endif				
		endfor
	endif
		string realname = nameofwave (trace)
		switch (id)
		case 0:
			Appendtograph /W=SSPanel#SSGraph trace
			ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(22806,20185,30670)
			break
		case 1:
			Appendtograph /W=SSPanel#SSGraph trace
			ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(43253,2359,56098)
			break
		case 2:
			Appendtograph /W=SSPanel#SSGraph trace
			ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(0,0,65535)
			break
		case 3:
			Appendtograph /W=SSPanel#SSGraph trace
			ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(20000, 20000, 0)
			break
		case 4:
			Appendtograph /W=SSPanel#SSGraph trace
			ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(65535, 0, 65535)
			break
		case 5:
			Appendtograph /W=SSPanel#SSGraph trace
			ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(0,0,0)
			break
		case 6:	//it is Spectra SLamp or Sref
		case 7:
			AppendtoGraph/R /W=SSPanel#SSGraph trace
			Label/W=SSPanel#SSGraph right "Spectrum"
			ModifyGraph /W=SSPanel#SSGraph minor=1
			ModifyGraph /W=SSPanel#SSGraph lSize($realname)=0.5
			ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(20000, 20000, 20000)
			SetAxis /W=SSPanel#SSGraph right 0,120
			break
		case 8:	//led Spectra
			Appendtograph /W=SSPanel#SSGraph trace
			ModifyGraph /W=SSPanel#SSGraph lSize($realname)=1.5
			strswitch (realname)
			case "waveled530":
				ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(30000, 30000, 30000)
				break
			case "waveled740":
				ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(65535, 0, 0)
				break
			case "waveled940":
				ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(6554,56098,2359)//Blue:(3146,5243,45875)
				break
			endswitch
			break
		endswitch
			ModifyGraph /W=SSPanel#SSGraph  tick=2
			ModifyGraph /W=SSPanel#SSGraph  zero=2
			ModifyGraph /W=SSPanel#SSGraph  minor=1
			ModifyGraph /W=SSPanel#SSGraph  standoff=0	
			if (stringmatch (realname, "wavesub*"))
				ModifyGraph /W=SSPanel#SSGraph lSize($realname)=1.5
			endif
			return 1		
End

Function Autoscale (num)
	variable num
	if (num == 0)
		SetAxis/A /W=SSpanel#SSgraph 
	elseif (num == 1)
		SetAxis/A /W=SSpanel#SSCurvaIV
	endif
end

//This is going to be the next task with the visibility of LEDS gaussian waves on the screen.
//FLAG
Function SetVarProc_SimSol(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			strswitch (sva.ctrlname)
				//sva.dval -> variable value
				case "setvarLedValue530":	
					Led_Gauss(530,1)
				break
				case "setvarLedValue740":
					Led_Gauss(740,1)
				break
				case "setvarLedValue940":
					Led_Gauss(940,1)
				break
				case "setvarLedIset530":	
					Led_Gauss(530,0)
				break
				case "setvarLedIset740":
					Led_Gauss(740,0)
				break
				case "setvarLedIset940":
					Led_Gauss(940,0)
				break
			endswitch
			//If com is not selected, leds will not apply
			if (stringmatch(sva.ctrlname, "setvarLed*"))
				svar com = root:SolarSimulator:Storage:com
				if (strlen(com)>=2)
					Led_Apply()
				endif
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
	if (ba.eventcode == -1 || ba.eventcode == 2 || ba.eventcode == 6)
		ba.blockReentry=1
	endif
	switch( ba.eventCode )
		case 2: // mouse up
			string baName = ba.ctrlname
			variable deviceID = getDeviceID("K2600")
//			print deviceID 
//			variable deviceID = 31267				
			if (deviceID == 0 )
				string ms = "Unable to connect with Keithley 2602A\n\n"
				ms += "\nExecution aborted.... Restart Program and Initialize correctly"	
				Abort ms
			endif
			strswitch (ba.ctrlname)
				case "buttonAutoscale0":
					AutoScale(0)
					break
				case "buttonAutoscale1":
					Autoscale(1)
					break
				case "buttonExtendSS":
					Extend_SSGraph(0)
					break
				case "buttonContractSS":
					Extend_SSGraph(1)
					break
				case "buttonExtendIV":
					Extend_IVGraph(0)
					break
				case "buttonContractIV":
					Extend_IVGraph(1)
					break
				case "btnMeasIV":					
					meas_IV(deviceID)
					break
				case "btnMeasJsc":
					nvar jsc  = root:SolarSimulator:Storage:jsc
					jsc = Meas_Jsc(deviceID)
					break
				case "btnMeasVoc":
					nvar voc = root:SolarSimulator:Storage:voc
					voc = Meas_Voc(deviceID)
					break
				case "buttonLedOff":
					wave Iset = root:SolarSimulator:Storage:Iset
					wave LedLevel = root:SolarSimulator:Storage:LedLevel
					LedLevel = {0,0,0}
					Iset = {0,0,0}
					DoUpdate /W=SSpanel
					Check_PlotEnable (8)
					break
				case "buttonClean":
					Clean(0)
					break
				default: 
					if (stringmatch (baName, "btncheck*"))
						if (str2num(baName[8])>=0 && str2num(baName[8])<=5)
							wave btnValues = root:SolarSimulator:Storage:btnValues
							variable id = str2num(baName[8])
							btnValues[id]=!btnValues[id]							
							Button_IscEnable(id)
							Calc_Isc (id)	
							if (btnValues[id])
								nvar idtask = root:SolarSimulator:Storage:idtask
								idtask = id 
								nvar deviceIDtask = root:SolarSimulator:Storage:deviceidtask
								deviceIDtask = deviceID	
								StartCountdown ()	
							endif
						endif
					endif
			endswitch
			break
		case -1: // control being killed
			strswitch (ba.ctrlname)	
				case "buttonClean":		//Button Disable being killed
				//When the button is pressed, it will clean the paths, waves and panel will reinitialize itself.
				//When killed, it wont reinitialize, but it will do the rest actions.
//					Disable_All()		// çççç 					
				break
			endswitch
			break
	endswitch

	return 0
End

Function CheckProc_SimSolar(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			string check_name = cba.ctrlname
			strswitch (cba.ctrlname)
				case "checklog":
					string gname = "SSPanel#SSCurvaIV"
					ModifyGraph /W=$gname log(left)=checked
					if (!checked)
//						ModifyGraph /W=$gname tick = 2
						SetAxis /W=$gname left -0.1, 0.5
						SetAxis /W=$gname bottom -1, 5							
//						ModifyGraph /W=$gname zero=2
//						ModifyGraph /W=$gname mirror=1
//						ModifyGraph /W=$gname standoff=0			
					endif					
					break
				case "checkgraph_SpectraSun":
					nvar Spectrachecked = root:SolarSimulator:Storage:SpectracheckedSun
					Spectrachecked = checked
					Check_PlotEnable (6, checked=checked)
					break
				case "checkgraph_SpectraLamp":
					nvar spectrachecked = root:SolarSimulator:Storage:SpectracheckedLamp
					Spectrachecked = checked
					Check_PlotEnable (7, checked=checked)
					break
				break
			endswitch
		break
		case -1: // control being killed
		break
	endswitch

	return 0
End

Function PopMenuProc_SimSolar( pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			String paName = pa.ctrlname
			string wavepath
			strswitch (pa.ctrlname)
				case "popupChannel":
					svar /Z channel = root:SolarSimulator:Storage:channel
					channel = popStr
					break
				case "popupAmbient":
					nvar /z light_dark = root:SolarSimulator:Storage:light_dark
					light_dark = popNum
					break
				case "popupLedCom":
					svar /Z com = root:SolarSimulator:Storage:com					
					if (init_OpenSerialLed(popStr,"LedController"))
						com=popStr
					else
						PopupMenu popupLedCom, popvalue=" ", mode=1
					endif
					break
				case "popupProbe":
					nvar /Z probe = root:SolarSimulator:Storage:probe
//					print popnum
					probe = popNum
					break
				case "popupDir":
					nvar /z forward = root:SolarSimulator:Storage:forward
					forward = popNum
					break								
				case "popupSubSref":	//Cargar Sref
					wavepath = Load (popStr, 12)
					//If we load smthg
					if (strlen (wavepath))
						nvar Spectrachecked = root:SolarSimulator:Storage:SpectracheckedSun
						CheckBox checkgraph_SpectraSun,value= Spectrachecked
						Check_PlotEnable (6, checked = Spectrachecked)
					endif
					
					//Note: lOOK if /H is necessary (it creates a copy of the loaded wave)					
				break
				case "popupSubSLamp":	//Cargar SLamp
					wavepath = Load (popStr, 13)
					if (strlen (wavepath))
						nvar Spectrachecked = root:SolarSimulator:Storage:SpectracheckedLamp
						CheckBox checkgraph_SpectraLamp,value = Spectrachecked
						Check_PlotEnable (7, checked = Spectrachecked)
					endif
				break
				default: 
					if (stringmatch (paName, "popupSub*"))
						variable num, id
						if (str2num(paName[8])>=0 && str2num(paName[8])<=5)
							wave popValues = root:SolarSimulator:Storage:popValues
							num = str2num(paName[8])
							if ( cmpstr (popStr,"Yes") == 0)
								popValues[num]=1
							elseif ( cmpstr (popStr, "No") == 0 )
								popValues[num]=0
							endif
							Pop_Action (num, popValues)							
						endif
						if (stringmatch (paName, "popupSubDUT*"))//Cargar EQEdut
							id = str2num(paName[11])	
							num = id2num (id, 1) //1 for dut						
							wavepath = Load (popStr, num )						
							
						elseif (stringmatch (paName, "popupSubREF*"))//Cargar EQEref	
							id = str2num(paName[11])
							num = id2num (id, 0) //0 for ref
							wavepath = Load (popStr, num  )
							if (strlen(wavepath))
								read_Iscref(wavepath,id)							
							endif
							//Wavepath is just for debugging, it will be deleted.
						endif
						
					endif
				break
			endswitch		
			//This loop is to calc the ISCObj and Mismatch Factor as we choose the dropdown
			variable i
			for ( i=0; i<6; i++)
				Calc_Isc(i)
			endfor	
		break
		case -1: // control being killed
			break
	endswitch
	return 0
end

Function Init_SP ([val])
	variable val
	if (ItemsinList (WinList("SSPanel", ";", "")) > 0)
		SetDrawLayer /W=SSPanel  Progfront
		DoWindow /F SSPanel
		return 0
	endif 
	init_solarVar ()	
	Load_Spectrum()	
	if (val==0)
		Init_Keithley_2600()	// çççç
	endif
	Solar_Panel ()
End 

function include_Mightex() // MightexPanel
//	Execute/P/Q/Z "INSERTINCLUDE \"MightexPanel\""
//	Execute/P/Q/Z "COMPILEPROCEDURES "
//	Execute/P /Q/Z "init_MightexPanel()"
End

//In case we only export the procedure, not the experiment (in the fture it will make sense) 
Function Load_Spectrum ()
	string sp = GetDataFolder(1)
	string general_path = SpecialDirPath ("Igor Pro User Files", 0, 0, 0)
	general_path += "SolarSimulatorData"
//	string general_path1 = replaceString (":", general_path, "\ " )	
//	general_path1 = replaceString ("C\ ", general_path1, "C:\ ") 
//	general_path1 = replaceString (" ", general_path1, "")
//	print general_path1	
	
	//LED_DATA	
//	string led_path = general_path + "\SLeds"
//	C:Users:III-V:Documents:WaveMetrics:Igor Pro 7 User Files:SolarSimulatorData:SLeds:
	SetDataFolder root:SolarSimulator:Spectra:SLeds
	newpath/O/Q lpath, general_path + ":SLeds" 
	
	LoadWave/C/O/Q /P=lpath	"LED470.ibw"
	LoadWave/C/O/Q /P=lpath	"LED740.ibw"
	LoadWave/C/O/Q /P=lpath	"LED940.ibw"
	
	//SOLAR SPECTRUM DATA
	NewPath/O/Q 	rpath, general_path + ":SRef"
//	string ref_path = general_path + ":SRef"
	SetDataFolder root:SolarSimulator:Spectra:SRef
	LoadWave/C/O/Q /P=rpath	"AMG173DIRECT.ibw"
	LoadWave/C/O/Q /P=rpath	"AMG173GLOBAL.ibw"
	LoadWave/C/O/Q /P=rpath	"AMO.ibw"
	
	SetDataFolder root:SolarSimulator:Spectra:SLamp
	NewPath/O/Q 	spath, general_path + ":SLamp"
	LoadWave/C/O/Q /P=spath	"XT10open2012.ibw"
	
	killPath /A 
	SetDataFolder sp
End

Function Init_SolarVar ()
	variable val
	string path = "root:SolarSimulator"
//	//If never initialized
//	if(!DatafolderExists(path))
//		string smsg = "You have to initialize first.\n"
//		smsg += "Do you want to initialize?\n"
//		DoAlert /T="Unable to open the program" 1, smsg
//		if (V_flag == 2)		//Clicked <"NO">
////			Abort "Execution aborted.... Restart IGOR"
//			return NaN
//		elseif (V_flag == 1)	//Clicked <"YES">
			genDFolders(path)
			genDFolders(path + ":Storage")
			genDFolders(path + ":GraphWaves")
			genDFolders(path + ":Spectra")
			//Here we have to load Sstd and SLamp manually 
			genDFolders(path + ":Spectra:SRef")
			genDFolders(path + ":Spectra:SLamp")
			genDFolders(path + ":Spectra:SLeds")

//		endif
//	endif
//	
	SetDataFolder path
	//Initial wave for #GraphPanel
	make /N=1 /O		root:SolarSimulator:Storage:sa
	//reference to draw in the scene before even give them the value of the selected subcell in the panel.
	//They will be all drawn in the graqph but not showed until we give them a value. Otherwise, it is nan 
	make /O 	root:SolarSimulator:GraphWaves:wavesubdut0 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubdut1 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubdut2 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubdut3 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubdut4 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubdut5 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubref0 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubref1 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubref2 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubref3 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubref4 = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavesubref5 = Nan
	make /O 	root:SolarSimulator:GraphWaves:waveLamp = Nan
	make /O 	root:SolarSimulator:GraphWaves:waveSpectra = Nan
	make /O 	root:SolarSimulator:GraphWaves:waveled530 = Nan
	make /O 	root:SolarSimulator:GraphWaves:waveled740 = Nan
	make /O 	root:SolarSimulator:GraphWaves:waveled940 = Nan
		
	SetDataFolder ":Storage"	
	//Disable/Enable Dropdowns things on the panel
	make /N=6 /O  popvalues
	wave popValues = popvalues
	popValues = {1, 1, 1, 0, 0, 0}
	
	//Display traces on graph depending on the checkbox selected
	make /N=5 /O btnValues
	wave btnValues = btnValues
	btnValues = {0, 0, 0, 0, 0, 0}
	
	variable /G SpectracheckedSun, SpectracheckedLamp
	SpectracheckedSun = 1
	SpectracheckedLamp = 1
	//Increase power of leds
	make /N=3 /O LedLevel
	make /N=3 /O IsetGraph
	wave LedLevel = LedLevel 
	LedLevel = {0, 0, 0}
	make /O led530 = Nan
	make /O led740 = Nan
	make /O led940 = Nan
	 
	//Values of LedCurrents
	make /N=3	/O 		root:SolarSimulator:Storage:Iset = Nan
	wave Iset 
	Iset = {0,0,0}
	 
	//ComPort
	string/G root:SolarSimulator:Storage:COM //Connected by serial port
	svar com = root:SolarSimulator:Storage:COM
	com = " "
	
	//ThreadTasks
	variable/G root:SolarSimulator:Storage:DeviceIDtask
	variable/G root:SolarSimulator:Storage:idtask
	variable/G root:SolarSimulator:Storage:Count
	nvar count =root:SolarSimulator:Storage:Count
	count = 0 
	
	//Isc
	make /N=6 /O root:SolarSimulator:Storage:IscObj 
	make /N=6 /O root:SolarSimulator:Storage:IscMeas 
	make /N=6 /O root:SolarSimulator:Storage:IscM
	make /N=6 /O root:SolarSimulator:Storage:Iref
	make /N=6 /O root:SolarSimulator:Storage:NSol
	wave IscObj = root:SolarSimulator:Storage:IscObj 
	wave IscMeas = root:SolarSimulator:Storage:IscMeas 
	wave IscM = root:SolarSimulator:Storage:IscM
	wave Iref = root:SolarSimulator:Storage:Iref
	wave NSol = root:SolarSimulator:Storage:NSol
	IscMeas = {0,0,0,0,0,0}
	IscObj = {0,0,0,0,0,0}
	IscM = {0,0,0,0,0,0}
	Iref = {0,0,0,0,0,0}
	NSol = {0,0,0,0,0,0}
	
	variable/G darea
	variable/G iarea
	darea = 0
	iarea = 0
	
	//Keithley K2600
	Variable/G probe, probe, ilimit, nplc, delay, vmax, vmin, step, light_dark, forward;
	String /G channel, dname, notes
	variable /G ff, eff, jsc, jmp,vmp,voc
	dname="Test_25C"
	notes=""
	channel = "A"
	probe = 2 //2-Wire = 1, 4-Wire = 2
	nplc = 1
	ilimit = 0.1
	delay = 1 
	vmax = 1
	vmin = 0
	step = 0.01
	light_dark = 1	//1 - Light / 2 - Dark
	forward = 1	 //Reverse => forward=2 
	ff=0		//Fill factor 
	jsc=0; jmp= 0; vmp=0; voc=0;		
		
	SetDataFolder path
End

Function Solar_Panel()
	
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path
	
	//Initial wave for #GraphPanel
	wave sa = :Storage:sa
	
	//Disable/Enable Dropdowns things on the panel
	wave popValues = :Storage:popvalues
	popValues = {1, 1, 1, 0, 0, 0}
	string popVal = translate (popValues)//Yes;No; Selection
	
	string wLampname = "XT10open2012"
	string wspecname = "AMG173DIRECT"
	
	Copy ("root:SolarSimulator:Spectra:SLamp:"+wLampname, "GraphWaves:waveLamp")
	Copy ("root:SolarSimulator:Spectra:SRef:" +wspecname, "GraphWaves:waveSpectra")
	
	//Leds	
	SetDataFolder :Storage
	//We dont wave the 530 Spectra. We use for now the 470 Spectra instead of the 530
	Copy ("root:SolarSimulator:Spectra:SLeds:LED470", "led530")
	Copy ("root:SolarSimulator:Spectra:SLeds:LED740", "led740")
	Copy ("root:SolarSimulator:Spectra:SLeds:LED940", "led940")
	wave led530
	//Here we correct the difference between both spectrum
	SetScale/I x, (leftx(led530)+60), (rightx(led530)+60), led530 
	SetDataFolder path
	
	//The leds' power
	wave LedLevel = :Storage:LedLevel
	
	//For Loops
	variable i
	
	//It has been created  when Leds Procedure initialize. 
	svar com = root:SolarSimulator:Storage:com
	nvar SpectracheckedLamp = :Storage:SpectracheckedLamp
	nvar SpectracheckedSun = :Storage:SpectracheckedSun
	
	PauseUpdate; Silent 1		// building window...
	
	//Panel
	
	DoWindow/K SSPanel; DelayUpdate
//	NewPanel /K=0 /W=(150,105,1215,776) as "SSPanel"
//	NewPanel /K=0 /W=(30,59,1329,709) as "SSPanel"		//Large Panel
	NewPanel /K=0 /W=(56,85,1232,735) as "SSPanel"		//Short Panel	
	DoWindow /C SSPanel

//	ModifyPanel /W=SSPanel cbRGB=(64507,65535,64764)
	
	//Text
	SetDrawLayer UserBack
//	SetDrawEnv fstyle= 1
//	DrawText 675,71,"   Max \rCurrent"
//	SetDrawEnv fstyle= 1
//	DrawText 728,72,"   Set  \rCurrent "
	SetDrawEnv linethick= 2,dash= 1
	DrawLine 588,322,587,651
	
	DrawText 45,31,"Cargar S\\BSTD"
	DrawText 181,32,"Cargar S\\BLAMP"
	DrawText 155,75,"Cargar EQE\\BREF"
	DrawText 375,73,"Cargar EQE\\BDUT"
	DrawText 538,73,"Isc\\BOBJ"
	DrawText 641,73,"Isc\\BMEAS"
	DrawText 602,73,"M"
	DrawText 689,73,"Nº\\BSOLES"
	DrawText 292,75,"Isc\\BREF"
	SetDrawEnv fsize= 25
	DrawText 434,43,"III-V Characterization"
	
	
//	
//	Button buttonAux, title="Calc Things",pos={454,215},size={103,23},proc=ButtonProc_SimSolar,fColor=(65535,0,0)
//	
	
	//Buttons
	Button buttonLedOff,pos={24.00,263.00},size={104.00,26.00},proc=ButtonProc_SimSolar,title="TURN OFF",fColor=(16385,65535,41303)
	Button buttonClean,pos={438.00,265.00},size={163.00,25.00},proc=ButtonProc_SimSolar,title="Clean Graph",fColor=(65535,65532,16385)	
	Button btncheck0,pos={510.00,87.00},size={15.00,15.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck1,pos={510.00,110.00},size={15.00,15.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck2,pos={510.00,133.00},size={15.00,15.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck3,pos={510.00,157.00},size={15.00,15.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck4,pos={510.00,179.00},size={15.00,15.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck5,pos={510.00,202.00},size={15.00,15.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button buttonExtendSS,pos={300,232},size={103.00,26.00},proc=ButtonProc_SimSolar,title="Extend"
	Button buttonExtendSS,fColor=(16385,65535,41303)
	Button buttonContractSS,pos={300,262},size={103.00,26.00},proc=ButtonProc_SimSolar,title="Contract"
	Button buttonContractSS,fColor=(16385,65535,41303)
	Button buttonAutoscale0,pos={438,232},size={104.00,26.00},proc=ButtonProc_SimSolar,title="AutoScale"
	Button buttonAutoscale0,fColor=(16385,65535,41303)
	Button buttonSave,pos={631.00,231.00},size={100.00,25.00},proc=ButtonProc_SimSolar,title="\\f01SAVE"
	Button buttonExport,pos={632.00,262.00},size={100.00,25.00},disable=2,title="EXPORT"
	Button buttonExport,labelBack=(65280,0,0),fSize=14,fStyle=1,fColor=(65280,0,0)
	
	PopupMenu popupSubSref,pos={17.00,33.00},size={144.00,19.00},bodyWidth=143,proc=PopMenuProc_SimSolar
	PopupMenu popupSubSref,mode=100,popvalue=wspecname,value= #"QEWaveList(1)"
	PopupMenu popupSubSlamp,pos={178.00,33},size={100.00,19.00},bodyWidth=100,proc=PopMenuProc_SimSolar
	PopupMenu popupSubSlamp,mode=100,popvalue=wLampname,value= #"QEWaveList(2)"
	PopupMenu popupSub0,pos={11,87},size={100,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #0"
	PopupMenu popupSub0,mode=1,popvalue=stringfromlist(0,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub1,pos={11,110},size={100,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #1"
	PopupMenu popupSub1,mode=1,popvalue=stringfromlist(1,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub2,pos={11,133},size={100,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #2"
	PopupMenu popupSub2,mode=1,popvalue=stringfromlist(2,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub3,pos={11,157},size={100,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #3"
	PopupMenu popupSub3,mode=2,popvalue=stringfromlist(3,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub4,pos={11,179},size={100,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #4"
	PopupMenu popupSub4,mode=2,popvalue=stringfromlist(4,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub5,pos={11,202},size={100,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #5"
	PopupMenu popupSub5,mode=2,popvalue=stringfromlist(5,popVal),value= #"\"Yes;No\""	
	PopupMenu popupLedCom,pos={16,233},size={112.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="ComPort"
	PopupMenu popupLedCom,mode=100,popvalue=com,value= #"\"COM1;COM2;COM3;COM4;COM5;COM6;COM7;COM8;USB\""
	//Notes: Mode=100 -> at the beginning in the dropdowns it is shown the item number 100 ( apparently nothing )
	PopupMenu popupSubREF0,pos={117.00,87.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF0,mode=100,popvalue=" ",value= #"QElist(0)"
	PopupMenu popupSubDUT0,pos={337.00,87.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT0,mode=100,popvalue=" ",value= #"QEList(0)"
	PopupMenu popupSubREF1,pos={117.00,110},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF1,mode=100,popvalue=" ",value= #"QElist(0)"
	PopupMenu popupSubDUT1,pos={337.00,110},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT1,mode=100,popvalue=" ",value= #"QEList(0)"
	PopupMenu popupSubREF2,pos={117.00,133},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF2,mode=100,popvalue=" ",value= #"QElist(0)"
	PopupMenu popupSubDUT2,pos={337.00,133},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT2,mode=100,popvalue=" ",value= #"QEList(0)"
	PopupMenu popupSubREF3,pos={117.00,156},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF3,mode=100,popvalue=" ",value= #"QElist(0)"
	PopupMenu popupSubDUT3,pos={337.00,156},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT3,mode=100,popvalue=" ",value= #"QEList(0)"
	PopupMenu popupSubREF4,pos={117.00,179},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF4,mode=100,popvalue=" ",value= #"QElist(0)"
	PopupMenu popupSubDUT4,pos={337.00,179},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT4,mode=100,popvalue=" ",value= #"QEList(0)"
	PopupMenu popupSubREF5,pos={117.00,202},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF5,mode=100,popvalue=" ",value= #"QElist(0)"
	PopupMenu popupSubDUT5,pos={337.00,202},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT5,mode=100,popvalue=" ",value= #"QEList(0)"

	//Lo cambio de 36 a 80 el size .
	CheckBox checkgraph_SpectraSun,pos={163.00,37.00},size={13.00,13.00},proc=CheckProc_SimSolar,title=""
	CheckBox checkgraph_SpectraSun,value= SpectracheckedSun
	CheckBox checkgraph_SpectraLamp,pos={280.00,37.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="On/Off"
	CheckBox checkgraph_SpectraLamp,value= SpectracheckedLamp

	SetVariable setvarLedValue530, pos={138.00,231.00},size={100.00,18.00},proc=SetVarProc_SimSol,title="Led 530"
	SetVariable setvarLedValue530,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[0],live= 1
	SetVariable setvarLedValue740,pos={138.00,254.00},size={100,18.00},proc=SetVarProc_SimSol,title="Led 740"
	SetVariable setvarLedValue740,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[1],live= 1
	SetVariable setvarLedValue940,pos={138.00,277.00},size={100,18.00},proc=SetVarProc_SimSol,title="Led 940"
	SetVariable setvarLedValue940,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[2],live= 1
	SetVariable setvarLedIset530,pos={240.00,231.00},size={40,18.00},proc=SetVarProc_SimSol,title=" "
	SetVariable setvarLedIset530,limits={0,Imax,0},value= root:SolarSimulator:Storage:Iset[0],live= 1
	SetVariable setvarLedIset740,pos={240.00,254.00},size={40,18.00},proc=SetVarProc_SimSol,title=" "
	SetVariable setvarLedIset740,limits={0,Imax,0},value= root:SolarSimulator:Storage:Iset[1],live= 1
	SetVariable setvarLedIset940,pos={240.00,277.00},size={40,18.00},proc=SetVarProc_SimSol,title=" "
	SetVariable setvarLedIset940,limits={0,Imax,0},value= root:SolarSimulator:Storage:Iset[2],live= 1
	
	SetVariable setvariref0,pos={282.00,87.00},size={53.00,19.00},disable=2,proc=SetVarProc_SimSol, title =" "
	SetVariable setvariref0,limits={0,50,0},value= root:SolarSimulator:Storage:Iref[0],live= 1	
	SetVariable setvariref1,pos={282.00,110.00},size={53.00,19.00},disable=2,proc=SetVarProc_SimSol, title =" "
	SetVariable setvariref1,limits={0,50,0},value= root:SolarSimulator:Storage:Iref[1],live= 1	
	SetVariable setvariref2,pos={282.00,133},size={53.00,19.00},disable=2,proc=SetVarProc_SimSol, title =" "
	SetVariable setvariref2,limits={0,50,0},value= root:SolarSimulator:Storage:Iref[2],live= 1	
	SetVariable setvariref3,pos={282.00,156},size={53.00,19.00},disable=2,proc=SetVarProc_SimSol, title =" "
	SetVariable setvariref3,limits={0,50,0},value= root:SolarSimulator:Storage:Iref[3],live= 1
	SetVariable setvariref4,pos={282.00,179},size={53.00,19.00},disable=2,proc=SetVarProc_SimSol, title =" "
	SetVariable setvariref4,limits={0,50,0},value= root:SolarSimulator:Storage:Iref[4],live= 1
	SetVariable setvariref5,pos={282.00,202},size={53.00,19.00},disable=2,proc=SetVarProc_SimSol, title =" "
	SetVariable setvariref5,limits={0,50,0},value= root:SolarSimulator:Storage:Iref[5],live= 1

	ValDisplay valdispIREF0,pos={536,89},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispIREF0,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscObj(0)"
	ValDisplay valdispIREF1,pos={536,112},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdisPIREF1,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscObj(1)"
	ValDisplay valdispIREF2,pos={536,135},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispIREF2,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscObj(2)"
	ValDisplay valdispIREF3,pos={536,158},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispIREF3,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscObj(3)"
	ValDisplay valdispIREF4,pos={536,181},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispIREF4,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscObj(4)"
	ValDisplay valdispIREF5,pos={536,203},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispIREF5,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscObj(5)"
	ValDisplay valdispIM0,pos={590,89},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispIM0,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscM(0)"
	ValDisplay valdispIM1,pos={590.00,112},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispIM1,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscM(1)"
	ValDisplay valdispIM2,pos={590.00,135},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispIM2,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscM(2)"
	ValDisplay valdispIM3,pos={590.00,158},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispIM3,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscM(3)"
	ValDisplay valdispIM4,pos={590.00,181},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispIM4,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscM(4)"
	ValDisplay valdispIM5,pos={590.00,203},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispIM5,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscM(5)"
	ValDisplay valdispI0,pos={644,89},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispI0,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscMeas(0)"
	ValDisplay valdispI1,pos={644,112},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispI1,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscMeas(1)"
	ValDisplay valdispI2,pos={644,135},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispI2,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscMeas(2)"
	ValDisplay valdispI3,pos={644,158},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispI3,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscMeas(3)"
	ValDisplay valdispI4,pos={644,181},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispI4,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscMeas(4)"
	ValDisplay valdispI5,pos={644,203},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispI5,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_IscMeas(5)"
	ValDisplay valdispNSol0,pos={699,89},size={40.00,17.00},bodyWidth=40,disable=2
	ValDisplay valdispNSol0,valueColor=(65535,50115,0),limits={0,0,0},barmisc={0,1000},value= #"get_NSol(0)"
	ValDisplay valdispNSol1,pos={699,112},size={40.00,17.00},bodyWidth=40,disable=2
	ValDisplay valdispNSol1,valueColor=(65535,50115,0),limits={0,0,0},barmisc={0,1000},value= #"get_NSol(1)"
	ValDisplay valdispNSol2,pos={699,135},size={40.00,17.00},bodyWidth=40,disable=2
	ValDisplay valdispNSol2,valueColor=(65535,50115,0),limits={0,0,0},barmisc={0,1000},value= #"get_NSol(2)"
	ValDisplay valdispNSol3,pos={699,158},size={40.00,17.00},bodyWidth=40,disable=2
	ValDisplay valdispNSol3,valueColor=(65535,50115,0),limits={0,0,0},barmisc={0,1000},value= #"get_NSol(3)"
	ValDisplay valdispNSol4,pos={699,181},size={40.00,17.00},bodyWidth=40,disable=2
	ValDisplay valdispNSol4,valueColor=(65535,50115,0),limits={0,0,0},barmisc={0,1000},value= #"get_NSol(4)"
	ValDisplay valdispNSol5,pos={699,203},size={40.00,17.00},bodyWidth=40,disable=2
	ValDisplay valdispNSol5,valueColor=(65535,50115,0),limits={0,0,0},barmisc={0,1000},value= #"get_NSol(5)"

	//Functions to initialize panel
	for (i = 0; i<6; i++)
		Pop_Action (i, popValues)
	endfor 
	//Check_IscEnable (-1, 0)
	
	//Display 
	string gname = "SSPanel#SSGraph"
	
//	Display/W=(0,358,594,650)/HOST=SSPanel  :Storage:sa vs :Storage:sa
	Display/W=(0,320,584,650)/HOST=SSPanel  :Storage:sa vs :Storage:sa
	RenameWindow #,SSGraph
//	ModifyGraph mode=3
//	ModifyGraph lSize=2
	ModifyGraph /W=$gname tick=2
	ModifyGraph /W=$gname zero=2
	ModifyGraph /W=$gname mirror=1
	ModifyGraph /W=$gname minor=1
	ModifyGraph /W=$gname standoff=0
	ModifyGraph /W=$gname alblRGB(left)=(52428,1,1),alblRGB(bottom)=(1,39321,19939)
	ModifyGraph /W=$gname wbRGB=(63479,65535,65535)
	Label /W=$gname left "%"
	Label /W=$gname bottom "nm"
	//Label right "Spectrum"
	SetAxis /W=$gname left 0,1
	SetAxis /W=$gname bottom 370,1800
	
	//Draw the spectrum
	Check_PlotEnable(6)
	Check_PlotEnable(7)
	
	
	
	//Curve I-V
	Button btnMeasIV,pos={900.00,180.00},size={100,25},proc=ButtonProc_SimSolar,title="\\f01Measure IV"
	Button btnAbort,pos={900.00,210.00},size={100,25},title="ABORT",labelBack=(65280,0,0),fColor=(52428,1,41942)
	Button btnAbort,fSize=14,fStyle=1,fColor=(65280,0,0),disable=2
	Button btnMeasJsc,pos={960.00,110.00},size={40.00,20.00},proc=ButtonProc_SimSolar,title="Jsc"
	Button btnMeasJsc,fColor=(65535,65532,16385)
	Button btnMeasVoc,pos={960.00,135.00},size={40.00,20.00},proc=ButtonProc_SimSolar,title="Voc"
	Button btnMeasVoc,fColor=(16385,65535,65535)
	Button buttonExtendIV,pos={900,240.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="Extend"
	Button buttonExtendIV,fColor=(16385,65535,41303)
	Button buttonContractIV,pos={900,270.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="Contract"
	Button buttonContractIV,fColor=(16385,65535,41303)
	Button buttonAutoscale1,pos={1050,270.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="AutoScale"
	Button buttonAutoscale1,fColor=(16385,65535,41303)
	
	CheckBox checklog,pos={1050.00,300.00},size={116.00,15.00},value=0,proc=CheckProc_SimSolar,title="Logarithmic_Graph",value= 0
	
	SetVariable setvarstep,pos={755.00,172},size={113.00,18.00},proc=SetVarProc_SimSol,title="Step (V)"
	SetVariable setvarstep,limits={0,1,0.1},value= root:SolarSimulator:Storage:step,live= 1
	SetVariable setvarvmin,pos={755.00,194},size={113.00,18.00},proc=SetVarProc_SimSol,title="Min (V)"
	SetVariable setvarvmin,limits={0,1,0.1},value= root:SolarSimulator:Storage:vmin,live= 1
	SetVariable setvarvmax,pos={755.00,217},size={113.0,18.00},proc=SetVarProc_SimSol,title="Max (V)"
	SetVariable setvarvmax,limits={0,1,0.1},value= root:SolarSimulator:Storage:vmax,live= 1
	SetVariable setvardelay,pos={755.00,239},size={113.00,18.00},proc=SetVarProc_SimSol,title="Delay (V)"
	SetVariable setvardelay,limits={0,1,0.1},value= root:SolarSimulator:Storage:delay,live= 1
	SetVariable setvarilimit,pos={755.00,262},size={113.00,18.00},proc=SetVarProc_SimSol,title="Limit (A)"
	SetVariable setvarilimit,limits={0,1,0.1},value= root:SolarSimulator:Storage:ilimit,live= 1
	SetVariable setvarnplc,pos={755.00,280.00},size={113.00,18.00},proc=SetVarProc_SimSol,title="Nplc"
	SetVariable setvarnplc,limits={0,1,0.1},value= root:SolarSimulator:Storage:nplc,live= 1
	SetVariable setvarDArea,pos={975.00,80.00},size={169.00,18.00},title="Total Area (cm2)"
	SetVariable setvarDArea,value= root:SolarSimulator:Storage:darea
	SetVariable setvarNotes,pos={752.00,42.00},size={390.00,18.00},title="\\f01Notes"
	SetVariable setvarNotes,value= root:SolarSimulator:Storage:notes	
	SetVariable setvarName,pos={753.00,23.00},size={389.00,18.00},title="\\f01DUT name"
	SetVariable setvarName,value= root:SolarSimulator:Storage:dname
	
	PopupMenu popupDir,pos={755.00,79.00},size={126.00,19.00},bodyWidth=73,proc=PopMenuProc_SimSolar,title="Bias Type"
	PopupMenu popupDir,mode=1,popvalue="Forward",value= #"\"Forward;Reverse\""
	PopupMenu popupChannel,pos={755.00,148.00},size={112.00,19.00},bodyWidth=65,proc=PopMenuProc_SimSolar,title="Channel"
	PopupMenu popupChannel,mode=1,popvalue="A",value= #"\"A;B\""
	PopupMenu popupAmbient,pos={755.00,125.00},size={111.00,19.00},bodyWidth=77,proc=PopMenuProc_SimSolar,title="Curve"
	PopupMenu popupAmbient,mode=1,popvalue="Light",value= #"\"Light;Dark\""
	PopupMenu popupProbe,pos={755.00,102.00},size={112.00,19.00},bodyWidth=78,proc=PopMenuProc_SimSolar,title="Probe"
	PopupMenu popupProbe,mode=1,popvalue="4-Wire",value= #"\"2-Wire;4-Wire\""
	
	ValDisplay valdispJsc,pos={1037.00,110.00},size={108,17.00},bodyWidth=75,disable=2,title="Jsc\\B(mA/cm2)"
	ValDisplay valdispJsc,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdispJsc,value= #"root:SolarSimulator:Storage:Jsc"
	ValDisplay valdispVoc,pos={1037.00,135.00},size={108,17.00},bodyWidth=75,disable=2,title="Voc\\B(V)"
	ValDisplay valdispVoc,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdispVoc,value= #"root:SolarSimulator:Storage:Voc"
	ValDisplay valdispff,pos={1037.00,160.00},size={108,17.00},bodyWidth=75,disable=2,title="FF(%)"
	ValDisplay valdispff,limits={0,0,0},barmisc={0,1000},value= #"root:SolarSimulator:Storage:ff"
	ValDisplay valdisph,pos={1037.00,185.00},size={108,17.00},bodyWidth=75,disable=2,title="h(%)"
	ValDisplay valdisph,limits={0,0,0},barmisc={0,1000},value= #"root:SolarSimulator:Storage:eff"
	ValDisplay valdispJmp,pos={1037.00,210.00},size={108,17.00},bodyWidth=75,disable=2,title="Jmp\\B(mA/cm2)"
	ValDisplay valdispJmp,limits={0,0,0},barmisc={0,1000},value= #"root:SolarSimulator:Storage:jmp"
	ValDisplay valdispVmp,pos={1037.00,235.00},size={108,17.00},bodyWidth=75,disable=2,title="Vmp\\B(V)"
	ValDisplay valdispVmp,limits={0,0,0},barmisc={0,1000},value= #"root:SolarSimulator:Storage:vmp"
	
	gname = "SSPanel#SSCurvaIV"
	//ControlBar?
	Display/W=(592,320,1176,650)/HOST=SSPanel  :Storage:sa vs :Storage:sa
	
	RenameWindow #,SSCurvaIV
//	ModifyGraph mode=3
//	ModifyGraph lSize=2
	ModifyGraph /W=$gname tick=2
	ModifyGraph /W=$gname zero=2
	ModifyGraph /W=$gname mirror=1
	ModifyGraph /W=$gname minor=1
	ModifyGraph /W=$gname standoff=0	
	ModifyGraph /W=$gname alblRGB(left)=(39321,39319,1),alblRGB(bottom)=(1,39321,39321)
//	ModifyPanel /W=$gname cbRGB=(56576,56576,56576)//, frameStyle=1, frameInset=3
	ModifyGraph /W=$gname wbRGB=(65535,65278,63479)
	Label /W=$gname left "Current Density (mA/cm\\S2\\M)"
	Label /W=$gname bottom "Voltage (V)"	
	SetAxis /W=$gname left -0.1, 0.5
	SetAxis /W=$gname bottom -1, 5	
	
	SetDrawLayer UserFront
	SetActiveSubwindow ##	
	
end

//DropDown "Yes-No" Selection
Function/S translate (popValues)
	//popValues is a boolean array. 1 is translated into "Yes" and 0 is translated into "No" int he dropdown
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

//CheckBoxes Panel "Disable-Enable" drop action
Function Pop_Action (popNum, popValues)
	//popNum is the numeric reference to the selected popup in the Panel
	//popValues is the boolean array that carries the FMS information
	variable popNum
	wave popValues
	string setvarX
	string btnX
	string popupX
	string popupY
	string valdisp1
	string valdisp2
	setvarX = "setvariref" + num2str(popNum)
	btnX = "btncheck" + num2str(popNum)
	popupX = "popupSubREF" + num2str(popNum)
	popupY = "popupSubDUT" + num2str(popNum)
	if (popValues[popNum])
		Button $btnX, disable = 0
		PopupMenu $popupX,	disable = 0
		PopupMenu $popupY,	disable = 0	
		SetVariable $setvarX, disable = 0
	else
		Button $btnX,	disable = 1
		PopupMenu $popupX,	disable = 2
		PopupMenu $popupY,	disable = 2
		SetVariable $setvarX, disable = 2
	endif	
end

//***********Check-Rules********************************************************************************************//
//Check 0-5 Subcells 
//Check 6 Both Spectrum's Plot 
//Check 7 Led's Plot

Function Check_PlotEnable (id[, checked])
	//id is the selected box that we want to enable or disable
	//checked is the state that the selected checkbox has got
	variable id
	variable checked
	if (paramisdefault(checked))
		checked=1
	endif
	string path = "root:SolarSimulator:GraphWaves"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path
	variable i
	if (id>=0 && id <6)
		string wavesubdutX
		string wavesubrefX
		wavesubdutX = "wavesubdut" + num2str(id)
		wavesubrefX = "wavesubref" + num2str(id)
		wave wavesubdut = $wavesubdutX
		wave wavesubref = $wavesubrefX
//		clean()
		Draw (wavesubdut, id)
		Draw (wavesubref, id)	
	elseif (id >=6)
		if (id == 6)
			string Spectra
			Spectra = "waveSpectra"
			wave waveSpectra = $Spectra
			if (checked)
				Draw (waveSpectra, 6)
			else
				RemovefromGraph /Z /W=SSPanel#SSGraph waveSpectra				
				//Check if right is still in use, becouse mirror can not be executed if there are 3 axis
				if (!Stringmatch(AxisList("SSPanel#SSGraph"),"*right*"))							
					ModifyGraph/Z /W=SSPanel#SSGraph  mirror=1	
				endif
			endif
		elseif (id ==7)
			string Lamp
			Lamp = "waveLamp"
			wave waveLamp = $Lamp
			if (checked)
				Draw (waveLamp, 7)
			else
				RemovefromGraph /Z /W=SSPanel#SSGraph waveLamp	
				//Check if right is still in use, becouse mirror can not be executed if there are 3 axis
				if (!Stringmatch(AxisList("SSPanel#SSGraph"),"*right*"))							
					ModifyGraph/Z /W=SSPanel#SSGraph  mirror=1	
				endif
			endif
		elseif (id == 8)
			wave Iset = root:SolarSimulator:Storage:Iset
			SetDataFolder path			
			string led530, led740, led940
			led530 = "waveled530"
			led740 = "waveled740"
			led940 = "waveled940"
			wave waveled530 = $led530
			wave waveled740 = $led740
			wave waveled940 = $led940	
			
			if (Iset[0])
				Draw (waveled530, 8)
			else
				RemovefromGraph /Z /W=SSPanel#SSGraph waveled530
			endif
			if (Iset[1])
				Draw (waveled740, 8)
			else
				RemovefromGraph /Z /W=SSPanel#SSGraph waveled740
			endif
			if (Iset[2])
				Draw (waveled940, 8)
			else
				RemovefromGraph /Z /W=SSPanel#SSGraph waveled940
			endif	
		elseif (id == 10)			
			//Maybe somtng here
		endif
	endif
		
	SetDataFolder savedatafolder	
End
gi
Function Button_IscEnable (id)
	//id is the selected box that we want to enable or disable
	//checked is the state that the selected checkbox has got
	variable id
	wave btnValues = root:SolarSimulator:Storage:btnValues
	variable i
	//*********Coming Soon: refresh*************//
	variable refresh //Selected
	string btncheck
	string valdisp1, valdisp2, valdisp3, valdisp4;
	string getIscObj, getIscMeas, getIscM, getNSol;
	for (i=0;i<6; i++)
		btncheck = "btncheck" + num2str(i)
		valdisp1 = "valdispIREF" + num2str(i)
		valdisp2 = "valdispI" + num2str(i)
		valdisp3 = "valdispIM" + num2str(i)
		valdisp4 = "valdispNSol" + num2str(i)
		getIscObj = "get_IscObj("+num2str(i)+")"
		getIscMeas = "get_IscMeas("+num2str(i)+")"
		getIscM = "get_IscM("+num2str(i)+")"
		getNSol = "get_NSol("+num2str(i)+")"
		if (id != i || !btnValues[i])
			Button $btncheck, fColor=(16385,65535,41303)
			ValDisplay $valdisp1, disable = 2
			ValDisplay $valdisp2, disable = 2
			ValDisplay $valdisp3, disable = 2
			ValDisplay $valdisp4, disable = 2
			btnValues[i]=0
		elseif (btnValues[i])
			//I dont know why color does not change when checked.
			Button $btncheck, fColor=(65535, 0, 0)
			ValDisplay $valdisp1, disable = 0,value = #getIscObj
			ValDisplay $valdisp2, disable = 0,value = #getIscMeas
			ValDisplay $valdisp3, disable = 0,value = #getIscM
			ValDisplay $valdisp4, disable = 0,value = #getNSol			
		endif
	endfor
end

//Reconstruction of Display. Clean Display
Function Clean (graph)
	variable graph	//1 = SSCurvaIV, 0 = SSGraph
	string sdf = getdatafolder (1)
	SetDataFolder root:SolarSimulator
	if (graph == 0)
		KillWindow SSPanel#SSGraph
		Display/W=(0,320,584,650)/HOST=#  :Storage:sa vs :Storage:sa 
		RenameWindow #,SSGraph	
		ModifyGraph /W=SSPanel#SSGraph  tick=2
		ModifyGraph /W=SSPanel#SSGraph  zero=2
		ModifyGraph /W=SSPanel#SSGraph  mirror=1
		ModifyGraph /W=SSPanel#SSGraph  minor=1
		ModifyGraph /W=SSPanel#SSGraph  standoff=0
//		Label left "%"
//		Label bottom "nm"
//		Label right "Spectrum"
		SetAxis /W=SSPanel#SSGraph left 0,1
		SetAxis /W=SSPanel#SSGraph bottom 370,1800
		
		string checkSpectraSun = "checkgraph_SpectraSun"
		string checkSpectraLamp = "checkgraph_SpectraLamp"
		CheckBox $checkSpectraSun, value = 0//, labelBack = (0, 0, 0)
			CheckBox $checkSpectraLamp, value = 0//, labelBack = (0, 0, 0)
	elseif (graph == 1)
		KillWindow SSPanel#SSCurvaIV
		string gname = "SSPanel#SSCurvaIV"
		Display/W=(592,320,1176,650)/HOST=SSPanel  :Storage:sa vs :Storage:sa	
		RenameWindow #,SSCurvaIV
//		ModifyGraph mode=3
//		ModifyGraph lSize=2
		ModifyGraph /W=$gname tick=2
		ModifyGraph /W=$gname zero=2
		ModifyGraph /W=$gname mirror=1
		ModifyGraph /W=$gname minor=1
		ModifyGraph /W=$gname standoff=0	
		ModifyGraph /W=$gname alblRGB(left)=(39321,39319,1),alblRGB(bottom)=(1,39321,39321)
//		ModifyPanel /W=$gname cbRGB=(56576,56576,56576)//, frameStyle=1, frameInset=3
		ModifyGraph /W=$gname wbRGB=(65535,65278,63479)
		Label /W=$gname left "Current Density (mA/cm\\S2\\M)"
		Label /W=$gname bottom "Voltage (V)"	
		SetAxis /W=$gname left -0.1, 0.5
		SetAxis /W=$gname bottom -1, 5	
	endif
	
	Setdatafolder sdf
end

//is this wave scaled as i want?
Function isScaled (wav)
	wave wav
	variable start = leftx (wav)
	variable delta = deltax (wav)
	variable ending = rightx (wav)
	//Aprox will be able to scale waves that are loaded without an appropriate scale 
	if (  (delta > 2 && delta < 7) && (start>=0 && start<400) && ending-start<2000 )
		return 1
	else 
		return 0
	endif
End

//Generates the different led waves gradient from the input values ( 0% --- 100% )
//And you can choose to set the current directly from its real value or from the 0-100%
Function Led_Gauss (num, ref)
	variable num, ref
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path + ":Storage"
	wave led530, led740, led940;
	wave ledlevel	
	wave  Iset;
	SetDataFolder path + ":GraphWaves"
//	wave waveled530, waveled740, waveled940;	
	
	//Originally led740 and led940 spectrum is not scaled equally as the others
//	CopyScales led530, led740
//	CopyScales led530, led940
	
	switch (num)
	case 530:
		Duplicate/O led530, waveled530
		if (ref)//You modify the percentage  (ledlevel)
			Iset[0] = Imax * ledlevel[0]
		else //You modify the Iset value	
			ledlevel[0] = Iset[0]/Imax
		endif
		waveled530 = led530 * ledlevel[0] / waveMax (led530) 
		Draw (waveled530, 8)
		break
	case 740:
		Duplicate/O led740, waveled740
		if (ref)
			Iset[1] = Imax * ledlevel[1]
		else
			ledlevel[1] = Iset[1]/Imax
		endif		
		waveled740 = led740 * ledlevel[1] / waveMax (led740)
		Draw (waveled740, 8)
		break
	case 940:
		Duplicate/O led940, waveled940
		if(ref)
			Iset[2] = Imax * ledlevel[2]
		else
			ledlevel[2] = Iset[2]/Imax
		endif
		waveled940 = led940 * ledlevel[2] / waveMax (led940)  
		Draw (waveled940, 8)
		break
	endswitch	
	SetDataFolder savedatafolder	
End

//Function Based on what does Load() do.
Function Copy (origin_path, dest_wavename)
	//To copy we need the origin_wave_path of the desire wave to be copied, and the name of the dest_wave_name
	//The dest_wave is created in the CURRENT DATA FOLDER 
	string origin_path
	string dest_wavename
	string dest_path
	string current = GetDataFolder (1)
	wave originwave = $origin_path
	//This is necessary becouse duplicate function creates the new wave in the dfr of the originwave
	dest_path = current + dest_wavename
	wave destwave = $dest_path
	
	Duplicate /O originwave, destwave
	
	if(deltax(destwave)<0.01)  /// ÑAPAAA TEMPORAL!!!
		// Escala en micras, pasarla a nm
		SetScale/I x, (leftx(destwave)*1000), (rightx(destwave)*1000), destwave
	endif
End

Function id2num( id, type)
	//type is 0 for ref and 1 for dut
	//id is the subcell position (0-5)
	//this function translate the subcell position into ref or dut position (0-11)
	variable id, type
	string code = num2str(id) + num2str(type)
	strswitch(code)
		case "00":
			return 0 
		case "01": 
			return 1
		case "10": 
			return 2
		case "11": 
			return 3
		case "20": 
			return 4
		case "21": 
			return 5
		case "30": 
			return 6
		case "31": 
			return 7
		case "40": 
			return 8
		case "41":
			return 9
		case "50": 
			return 10
		case "51": 
			return 11
	endswitch	
End

Function num2id (num)
	//num is the global position of the wave that occupies in the panel
	variable num
	switch (num)
		case 0:
		case 1:
			return 0
		case 2:
		case 3:
			return 1
		case 4:
		case 5:
			return 2
		case 6:
		case 7:
			return 3
		case 8:
		case 9:
			return 4
		case 10:
		case 11:
			return 5
		case 12:
		case 13:
			return 6
		case 14:
		case 15: 
			return 7
		default: 
			return 10
	endswitch
End

	
//Tema Leds//******************
//TurnOn and Off the Mightex COntroller
//In a future it will be implemented with loops, to be able to introduce new leds without writting much code.
Function TurnOn_Leds()
	setMode (channel1, 1)	//Normal mode
	setMode (channel2, 1)
	setMode (channel3, 1)
	setNormalParameters (channel1, Imax, 0)
	setNormalParameters (channel2, Imax, 0)
	setNormalParameters (channel3, Imax, 0)
End

Function TurnOff_Leds()
	setMode (channel1, 0)
	setMode (channel2, 0)
	setMode (channel3, 0)
End

Function Led_Apply ()
	wave Iset = root:SolarSimulator:Storage:iset
	setNormalCurrent (channel1, Iset[0])
	setNormalCurrent (channel2, Iset[1])
	setNormalCurrent (channel3, Iset[2])
End

//*************************************************************************

//When the panel is closed, this function turn off the leds and the keithley
Function Disable_All ()
	TurnOff_Leds ()
	Close_Keithley_2600()
//	print "Turned Off Leds"
//	print "Closed Keithley"
End

////My own Function to calculate Isc from qe and s.Spectra
Function qe2JscSS (qe, specw)
	wave qe , specw	//qeSubCellRef y solar Spectrum (am0, amgd, amgg..)
	variable jsc
	variable num
	//Identify if the wave contains Nan on its first positin.
	if ( numtype (qe[0]) == 2 || numtype (specw[0]) == 2) 
		return 0
	endif
	//Tenemos problemas con el escalado.
	//Las ondas que no empiezan por 300 sino por 280 lambda 
	//hay que re-escalar todo para qeu no haya fallos?
	
	variable numPoints=(numpnts(qe)-1)*deltax(qe)+1
	interpolate2 /T=1 /N=(numPoints) /Y=tmpw qe
	interpolate2 /T=1 /N=(numPoints) /Y=tmpw2 specw
	Duplicate /O tmpw, sr
	
	sr=(1.602e-19*tmpw*x*1e-9)/(6.62606957e-34*2.99792458e8) // A/W/m2
	sr*=tmpw2*x*1000/10000 //mA/cm2
//	sr/=specw(x)*1000/10000
	
	// Pasar a corriente!!!. Ñapa temporal
	sr*=0.1  //Asume un área de 0.1 cm en la célula
	
	
	jsc=area(sr)
//	jsc = area ( src, rangex1, rangex2) //between a certain point-range
//	integrate/t sr
//	jsc=sr[numpnts(sr)-1]
	wavekiller("tmpw")
	wavekiller("tmpw2")
	wavekiller("sr")

	return jsc
End

//////My own Function to calculate Isc from qe and s.Spectra
//Function qe2JscSS (qe, specw)
//	wave qe , specw	//qeSubCellRef y solar Spectrum (am0, amgd, amgg..)
//	variable jsc
//	variable num
//	//Identify if the wave contains Nan on its first positin.
//	if ( numtype (qe[0]) == 2 || numtype (specw[0]) == 2) 
//		return Nan
//	endif
//
//	variable numPoints=(numpnts(qe)-1)*deltax(qe)+1
//	interpolate2 /T=1 /N=(numPoints) /Y=tmpw qe
//	interpolate2 /T=1 /N=(numPoints) /Y=tmpw2 specw
//	Duplicate /O tmpw,sr
//	Duplicate /O tmpw2, specw_interpolated
//	
//	sr=(1.602e-19*tmpw*x*1e-9)/(6.62606957e-34*2.99792458e8) // A/W/m2
//	
////	sr*=specw(x)*1000/10000 //mA/cm2
//	sr*=specw_interpolated(x)*1000/10000 //mA/cm2
//	
//	// Pasar a corriente!!!. Ñapa temporal
//	sr*=0.1  //Asume un área de 0.1 cm en la célula
//	
//	
//	jsc=area(sr)
////	jsc = area ( src, rangex1, rangex2) //between a certain point-range
////	integrate/t sr
////	jsc=sr[numpnts(sr)-1]
//	wavekiller("tmpw")
//	wavekiller("tmpw2")
//	wavekiller("specw_interpolated")
//	wavekiller("sr")
//
//	return jsc
//End

Function Calc_Isc (id)
	variable id
	wave IscM = root:SolarSimulator:Storage:IscM
	wave IscObj = root:SolarSimulator:Storage:IscObj
	string wavesubrefX = "wavesubref" + num2str(id)
	string wavesubdutX = "wavesubdut" + num2str(id)	
	string valdispIx = "valdispIREF"+num2str(id)
	string valdispIMx = "valdispIM" +num2str(id)
	string getIsc = "get_IscObj ("+num2str(id)+")"
	string getIscM = "get_IscM ("+num2str(id)+")"
	string sdf = GetDataFOlder (1)
	SetDataFolder root:SolarSimulator:GraphWaves
	wave wsref = $wavesubrefX
	wave wsdut = $wavesubdutX
	wave waveSpectra
	wave waveLamp
		
	//We are not ready to calc the Values
	//Identify if the wave contains Nan on its first positin.
	if ( numtype (wsref[0]) == 2 || numtype (wsdut[0]) == 2 || numtype(waveSpectra[0]) == 2 || numtype (waveLamp[0]) == 2) 
		IscM[id]=0
		IscObj[id]=0		
		ValDisplay $valdispIx, value= #getIsc
		ValDisplay $valdispIMx, value= #getIscM
		return 0
	endif
	
	make /O /N=4	jsc
	wave jsc
	jsc[0] = qe2jscSS ( wsdut, waveLamp )
	jsc[1] = qe2jscSS ( wsref, waveSpectra )
	jsc[2] = qe2jscSS ( wsref, waveLamp )
	jsc[3] = qe2jscSS ( wsdut, waveSpectra )
	
	IscM[id] = jsc[0]*jsc[1]/jsc[2]/jsc[3]	
	IscObj[id] =  jsc[1]*IscM[id]
	
	ValDisplay $valdispIx, value= #getIsc
	ValDisplay $valdispIMx, value= #getIscM
	
	wavekiller ("jsc")	
	SetDataFolder sdf

End

 
Function get_IscObj (i)
	variable i
	wave IscObj = root:SolarSimulator:Storage:IscObj
	return IscObj[i]
end

Function get_IscMeas (i)
	variable i
	wave IscMeas = root:SolarSimulator:Storage:IscMeas
	return IscMeas[i]
end

Function get_IscM (i)
	variable i
	wave IscM = root:SolarSimulator:Storage:IscM
	return IscM[i]
end

Function get_NSol (i)
	variable i
	wave NSol = root:SolarSimulator:Storage:NSol
	return NSol[i]
end
//*******************Keithley K2600***********************************************************************************************************//	
Function Init_Keithley_2600()
	InitBoard_GPIB(0) 		//	çç
	InitDevice_GPIB(0,26)	//26 is for Keithley_2600
	//pending to catch errors
//	print "Keithley Initialized"
End
Function  Close_Keithley_2600()
	DevClearList(0,26)
End

Function Meas_IV (deviceID)
	variable deviceID
	string sdf = GetDataFolder (1)
	SetDataFolder "root:SolarSimulator:Storage"
	nvar probe, ilimit, nplc, delay, step, vmin, vmax, forward
	svar channeL
	configK2600_GPIB_SSCurvaIV(deviceID,0,channel,probe,ilimit,nplc,delay)
	measIV_K2600(deviceID,step,vmin,vmax,channel,forward)
	
	SetDataFolder sdf
End

Function Meas_Jsc (deviceID)
	variable deviceID
	string sdf = GetDataFolder (1)
	SetDataFolder "root:SolarSimulator:Storage"
	nvar probe, probe, ilimit, nplc, delay, darea
	svar channeL
	variable jsc
		
	configK2600_GPIB_SSCurvaIV(deviceID,3,channel,probe,ilimit,nplc,delay)	 	// çç
	jsc = -1*measI_K2600(deviceID,channel)
	if (darea == 0)
		SetVariable setvarDArea, valueBackColor= (57933,66846,1573)		
	else 
		SetVariable setvarDArea, valueBackColor=0		
		jsc*=(1e3/darea)
	endif
	return jsc
	SetDataFolder sdf
End

Function Meas_Isc (deviceID)
	variable deviceID
	variable jsc		
//	configK2600_GPIB_SSCurvaIV(deviceID,3,channel,probe,ilimit,nplc,delay)	 	// çç
	configK2600_GPIB_SSCurvaIV(deviceID,3,"A"    ,2    ,0.1   ,1   , 1 )
	jsc = -1*measI_K2600(deviceID,"A")*1000	//mA
	return jsc
End

Function Meas_Voc(deviceID)
	variable deviceID
	string sdf = GetDataFolder (1)
	SetDataFolder "root:SolarSimulator:Storage"
	nvar probe, probe, ilimit, nplc, delay
	svar channel
	nvar darea
	variable voc
	configK2600_GPIB_SSCurvaIV(deviceID,2,channel,probe,ilimit,nplc,delay)	//çç
	voc=measV_K2600(deviceID,channel)
	return voc
	SetDataFolder sdf
End

Function measI_K2600 (deviceID, channel)
	variable deviceID
	String channel
	String cmd, target
	channel=lowerstr(channel)
	
	cmd="smu"+channel+".source.output = smu"+channel+".OUTPUT_ON"
	sendcmd_GPIB(deviceID,cmd)
	cmd="smu"+channel+".source.levelv = 0"
	sendcmd_GPIB(deviceID,cmd)
	cmd="print(smu"+channel+".measure.i(smu"+channel+".nvbuffer1))"
	sendcmd_GPIB(deviceID,cmd)
	GPIBRead2 /Q target
	variable imeas=str2num(target)
	cmd="smu"+channel+".source.output = smu"+channel+".OUTPUT_OFF"
	sendcmd_GPIB(deviceID,cmd)
	GPIB2 InterfaceClear
	GPIB2 KillIO
	
	return imeas
End

Function measV_K2600(deviceID,channel)
	variable deviceID
	String channel
	String cmd, target
	channel=lowerstr(channel)
	
	cmd="smu"+channel+".source.output = smu"+channel+".OUTPUT_ON"
	sendcmd_GPIB(deviceID,cmd)
	cmd="smu"+channel+".source.leveli = 0"
	sendcmd_GPIB(deviceID,cmd)
	cmd="print(smu"+channel+".measure.v(smu"+channel+".nvbuffer1))"
	sendcmd_GPIB(deviceID,cmd)
	GPIBRead2 /Q target
	variable vmeas=str2num(target)
	cmd="smu"+channel+".source.output = smu"+channel+".OUTPUT_OFF"
	sendcmd_GPIB(deviceID,cmd)
	sendcmd_GPIB(deviceID,"waitcomplete()")
	GPIB2 InterfaceClear
	GPIB2 KillIO
	
	return vmeas
End

Function/WAVE measIV_K2600 (deviceID, step, nmin, nmax, channel, forw)
	// make function where you can build the command
	// Performs IV , at the moment sweeps V and measures I
	variable deviceID,step,nmin,nmax
	string channel
	variable forw // forward or reverse?
	variable i,vstep,vini,vfin,inc
	string path="root:SolarSimulator:Storage"
	DFREF dfr=$path
	string cmd,target
	NVAR /Z it=dfr:it
	channel=lowerstr(channel)
	SVAR /Z wname=root:SolarSimulator:Storage:dname
	SVAR /Z notas=root:SolarSimulator:Storage:notes
	NVAR /Z light=root:SolarSimulator:Storage:light_dark
	NVAR /Z iarea=root:SolarSimulator:Storage:iarea
	NVAR /Z darea=root:SolarSimulator:Storage:darea
	string setupNotes=getIVsetupNotes_SSCurvaIV()
	string dfrStr=createDFRwave(wname,"IV")
	DFREF dfrw=$dfrStr
			
	// Perform sweep 
	variable npoints=((nmax-nmin)/step)+1
	npoints=ceil(npoints)
	if(forw==2) // Reverse direction
		vini=abs(nmax)
		vstep=-step
	else // Forward direction
		vini=nmin
		vstep=step
	endif
	
	make /D/O/N=(npoints) dfrw:$wname
	wave ww=dfrw:$wname
	
	cmd="smu"+channel+".source.output = smu"+channel+".OUTPUT_ON"
	sendcmd_GPIB(deviceID,cmd)
	//cmd="SweepVLinMeasureI(smu"+channel+", "+num2str(nmin)+", "+num2str(nmax)+", "+num2str(delay)+", "+num2str(npoints)+")"
	//sendcmd_GPIB(deviceID,cmd)
	//setscale /P x,vini,vstep,"V", ww
	
	for(i=0;i<(npoints);i+=1)
		inc=vini+(vstep*i)
		cmd="smu"+channel+".source.levelv = "+num2str(inc)
		sendcmd_GPIB(deviceID,cmd)
		// waitcomplete?
		//cmd="smu"+channel+".measure.i(smu"+channel+".nvbuffer1)"
		//sendcmd_GPIB(deviceID,cmd)
		//ww[i]=-1*measureI_K2600(deviceID,channel)
		cmd="print(smu"+channel+".measure.i(smu"+channel+".nvbuffer1))"
		sendcmd_GPIB(deviceID,cmd)
		GPIBRead2 /Q target
		ww[i]=str2num(target)
	endfor
	
	// When using GPIBReadWave2...
	//cmd="printbuffer(1, "+num2str(npoints)+", smu"+channel+".nvbuffer1.readings)"
	//sendcmd_GPIB(deviceID,cmd)
	//GPIBReadWave2 /Q dfr:$wstr
	
	cmd="smu"+channel+".source.output = smu"+channel+".OUTPUT_OFF"
	sendcmd_GPIB(deviceID,cmd)
	sendcmd_GPIB(deviceID,"smu"+channel+".reset()")
	GPIB2 InterfaceClear
	GPIB2 KillIO
	//Duplicate /O ww,dfrw:$wname
	//wave ww2=dfrw:$wname
	setscale /P x,vini,vstep,"V", ww
	//wave iv=root:SolarSimulator:Storage:iv
	
	string tracelist=TraceNameList("SSCurvaIV",";",1)
	if(!StringMatch(tracelist,"*"+wname+"*"))
		AppendtoGraph /W=SSPanel#SSCurvaIV ww
		ModifyGraph /W=SSPanel#SSCurvaIV lsize=1.5
		setcolorGraph("")
	endif
	string nots=getFecha4note()+notas+";\r"+setupNotes
	// What happens if its Light or Dark
	if(light==1)
		ww*=-1
		//calculate solar cell parameters - always 1-sun.
		wave sc=getIVCellParams(ww,1,darea,1,nots)
		NVAR jsc=root:SolarSimulator:Storage:jsc
		NVAR voc=root:SolarSimulator:Storage:voc
		NVAR ff=root:SolarSimulator:Storage:ff 	
		NVAR eff=root:SolarSimulator:Storage:eff
		NVAR vmp=root:SolarSimulator:Storage:vmp 
		NVAR jmp=root:SolarSimulator:Storage:jmp		

		// For the moment we replace Amperes and Area. This is good for using general function for SC parameters
		// Next version will split functions of SC params and standarized areas for sim and exp data.
		
		nots=note(ww)
		
		jsc=getVarWaveNote(ww,"Jsc(mA/cm2)")
		voc=getVarWaveNote(ww,"Voc(V)")
		ff=getVarWaveNote(ww,"FF")
		eff=getVarWaveNote(ww,"Efficiency(%)")
		vmp=getVarWaveNote(ww,"Vm(V)")
		jmp=getVarWaveNote(ww,"Jm(mA/cm2)")
		
		
		//mario did this. Lets reach the next level
		nots=RemoveByKey("\rAmperes", nots,"=",";")
		nots=RemoveByKey("\rArea(cm2)", nots,"=",";")
	endif
		note /K ww,nots
	
	return ww
End

Function /S getIVsetupNotes_SSCurvaIV()
	String snote
	NVAR /Z step=root:SolarSimulator:Storage:step
	NVAR /Z nplc=root:SolarSimulator:Storage:nplc
	NVAR /Z ilimit=root:SolarSimulator:Storage:ilimit
	NVAR /Z probe=root:SolarSimulator:Storage:probe
	NVAR /Z delay=root:SolarSimulator:Storage:delay
	NVAR /Z forward=root:SolarSimulator:Storage:forward
	SVAR /Z com=root:SolarSimulator:Storage:com
	NVAR /Z vmin=root:SolarSimulator:Storage:vmin
	NVAR /Z vmax=root:SolarSimulator:Storage:vmax
	NVAR /Z darea=root:SolarSimulator:Storage:darea
	NVAR /Z iarea=root:SolarSimulator:Storage:illumarea

	SVAR /Z channel=root:SolarSimulator:Storage:channel
	string forwardStr="",probeStr=""
	switch (forward)
		case 1:
			forwardStr="Forward"
		break
		case 2:
			forwardStr="Reverse"
		break
		case 3:
			forwardStr="Pulse"
		break
	endswitch
	
	switch (probe)
		case 1:
			probeStr="2-Wire"
		break
		case 2:
			probeStr="4-Wire"
		break
	endswitch
	
	snote="---- IV measurement setup variables ----;\r"
	snote+="COM="+com+";\r"
	snote+="Probes="+probeStr+";\r"
	snote+="Limit (A)="+num2str(ilimit)+";\r"
	snote+="NPLC="+num2str(nplc)+";\r"
	snote+="Bias type="+forwardStr+";\r"
	snote+="Max (V)="+num2str(vmax)+";\r"
	snote+="Min (V)="+num2str(vmin)+";\r"
	snote+="Step (V)="+num2str(step)+";\r"
	snote+="Delay="+num2str(step)+";\r"
	snote+="Total Area (cm2)="+num2str(darea)+";\r"
	snote+="Illuminated Area (cm2)="+num2str(iarea)+";\r"
	
	return snote
End

Function configK2600_GPIB_SSCurvaIV(deviceID,configType,channel,probe,ilimit,nplc,delay)
	variable deviceID
	variable configType
	string channel
	variable probe
	variable ilimit
	//variable vlimit
	variable nplc
	variable delay
	delay/=1000
	string cmdList

	channel=lowerstr(channel)

	switch(configType)

	case 0: // Set voltage measure current
		cmdList="smu"+channel+".reset();format.data = format.ASCII;smu"+channel+".nvbuffer1.clear();"
		cmdList+="smu"+channel+".nvbuffer1.appendmode = 1;"
		cmdList+="smu"+channel+".nvbuffer1.collectsourcevalues = 1;smu"+channel+".measure.count = 1;"
		cmdList+="smu"+channel+".measure.filter.count = 1;"
		cmdList+="smu"+channel+".measure.nplc = "+num2str(nplc)+";"
		cmdList+="smu"+channel+".source.output = smu"+channel+".OUTPUT_ON;"
		cmdList+="smu"+channel+".source.func = smu"+channel+".OUTPUT_DCVOLTS;"
		cmdList+="smu"+channel+".sense = "+num2str(probe-1)+";smu"+channel+".measure.autorangei = 1;"
		cmdList+="smu"+channel+".source.limiti = "+num2str(ilimit)+";smu"+channel+".measure.autozero = 2;"
		cmdList+="smu"+channel+".measure.delay = "+num2str(delay)+";"
	break
	
	case 1: // Inject current measure voltage
		cmdList="smu"+channel+".reset();format.data = format.ASCII;smu"+channel+".nvbuffer1.clear();"
		cmdList+="smu"+channel+".nvbuffer1.appendmode = 1;"
		cmdList+="smu"+channel+".nvbuffer1.collectsourcevalues = 1;smu"+channel+".measure.count = 1;"
		cmdList+="smu"+channel+".measure.filter.count = 1;"
		cmdList+="smu"+channel+".measure.nplc = "+num2str(nplc)+";"
		cmdList+="smu"+channel+".source.output = smu"+channel+".OUTPUT_ON;"
		cmdList+="smu"+channel+".source.func = smu"+channel+".OUTPUT_DCVOLTS;"
		cmdList+="smu"+channel+".sense = "+num2str(probe-1)+";smu"+channel+".measure.autorangev = 1;"
		cmdList+="smu"+channel+".source.limitv = 5;smu"+channel+".measure.autozero = 2;"
		cmdList+="smu"+channel+".measure.delay = "+num2str(delay)+";"	
	break
		
	case 2: // Measure voltage, must ENABLE SOURCE FUNCTION IN AMPS TO MEASURE VOLTAGE 
		cmdList="smu"+channel+".reset();format.data = format.ASCII;smu"+channel+".nvbuffer1.clear();"
		cmdList+="smu"+channel+".source.func = smu"+channel+".OUTPUT_DCAMPS;"
		cmdList+="smu"+channel+".nvbuffer1.appendmode = 1;"
		cmdList+="smu"+channel+".measure.count = 1;"
		cmdList+="smu"+channel+".measure.filter.count = 10;"
		cmdList+="smu"+channel+".measure.nplc = "+num2str(nplc)+";"
		//cmdList+="smu"+channel+".measure.filter.count = 10;smu"+channel+".filter.enable = 1;"
		cmdList+="smu"+channel+".sense = "+num2str(probe-1)+";smu"+channel+".measure.autorangev = 1;"
		cmdList+="smu"+channel+".source.limitv = 5;smu"+channel+".measure.autozero = 2;smu"+channel+".source.offmode = 0;"
		cmdList+="smu"+channel+".measure.delay = "+num2str(delay)+";"
	break
	
	case 3: // Measure Current
		cmdList="smu"+channel+".reset();format.data = format.ASCII;smu"+channel+".nvbuffer1.clear();"
		cmdList+="smu"+channel+".source.func = smu"+channel+".OUTPUT_DCVOLTS;"
		cmdList+="smu"+channel+".nvbuffer1.appendmode = 1;"
		cmdList+="smu"+channel+".measure.count = 10;"
		cmdList+="smu"+channel+".measure.nplc = "+num2str(nplc)+";"
		cmdList+="smu"+channel+".sense = "+num2str(probe-1)+";smu"+channel+".measure.autorangei = 1;"
		cmdList+="smu"+channel+".source.limiti = "+num2str(ilimit)+";smu"+channel+".measure.autozero = 2;"
		cmdList+="smu"+channel+".measure.delay = "+num2str(delay)+";"
	break
	
	default: // reset 
		cmdList="smu"+channel+".reset()"
	break

endswitch

//	if(stringmatch(channel,"B"))
//		cmdList=replaceString("smua.",cmdList,"smub.")
//	endif
	cmdList_GPIB(deviceID,cmdList)
	//print cmdList
end

//**********************Keithley K2600***********************************************************************************************************//	

Function StartCountdown ()
	variable numticks = 30	// It measures each 0.5 seconds 		//60->1second.
	CtrlNamedBackground Countdown, period = numticks, proc=Countdown_Isc
	CtrlNamedBackground Countdown, start
ENd

//This function is not needed. Return 1 pressing other buttons or escape is enough to kill the bgtask
Function StopCountDown ()
	CtrlNamedBackground Countdown, stop
End

Function CountDown_Isc(s)
	STRUCT WMBackgroundStruct &s
	
	nvar deviceID = root:SolarSImulator:storage:deviceIDtask
	nvar id = root:SolarSimulator:Storage:idtask	
	wave IscMeas = root:SolarSimulator:Storage:IscMeas
	wave NSol = root:SolarSimulator:Storage:NSol 
	wave IscObj = root:SolarSimulator:Storage:IscObj
	wave btnValues = root:SolarSimulator:Storage:btnValues
	string valdispIX = "valdispI" + num2str(id)
	string valdispNSolX = "valdispNSol" + num2str(id)
	string setvarIrefX = "setvariref"+num2str(id)
	string getIscMeas = "get_IscMeas(" + num2str (id) + ")"
	string getNSol = "get_Nsol(" + num2str(id) +")"
	String message = "---------Measuring--------"
	TitleBox countdown_message,pos={189.00,296.00},size={149.00,23.00},title=message
	String abortStr = "Hold escape to abort"
	TitleBox countdown_abort,pos={341.00,296.00},size={118.00,23.00},title=abortStr
	Variable startTicks = ticks
	Variable lastMessageUpdate = startTicks
	nvar count = root:SolarSimulator:Storage:count
	count +=1
//			IscMeas[id] = Meas_Isc (deviceID)		// çççç
			IscMeas[id] = count //Just to get some auxiliary values
			NSol[id] = IscMeas[id]/IscObj[id]
			
			ValDisplay $valdispIX,value = #getIscMeas
			ValDisplay $valdispIX,format = "%.5g"
			ValDisplay $valdispNSolX,value = #getNSol

		if (GetKeyState(0) && 32 || btnValues[id] != 1)		//Press Esc, Alt or CTRL
			btnValues[id] = 0
			Button_IscEnable(id)			
			abortStr = ""
			message = ""
			TitleBox countdown_message, title = message
			TitleBox countdown_abort, title = abortStr
			//this return 1 kills the background task
			return 1
		endif
		return 0
End

Function read_IscRef(wavepath,id )
	string wavepath
	variable id
	string notes = note($wavepath)
	variable i
	if (stringmatch (notes, "*Jsc (AMG173DIRECT_1000Wm2)=*"))
		variable pos = strsearch (notes, "Jsc (AMG173DIRECT_1000Wm2)=", 0)
		if (pos)
				variable post_coma, num
				//Cojo de Ireferencia de este espectro, por ejemplo
				pos +=strlen ("Jsc (AMG173DIRECT_1000Wm2)=")
				wave Iref = root:SolarSimulator:Storage:Iref
				for (i = pos; i<pos+8; i++)						
					post_coma*=10		
					if (!cmpstr(notes[i],"."))
						post_coma=1
					else
						num*=10	
					endif	
					if (str2num(notes[i])>=0 && str2num(notes[i])<=10)//Different from a number do not enter the condition
						//traducimos el string a numero,teniendo en cuenta las unidades contadas antes y después de la coma
						//NOTA: la coma no está contemplada como string, sino como parte del numero
						num += str2num(notes[i])
					endif		
					//the number has ended					
					if (!cmpstr(notes[i]," "))
						break
					endif
									
				endfor
				num/=post_coma		// mA/cm2				
				Iref[id] = num
		endif
	endif
end

Function Extend_SSGraph (num)
	variable num
	String traceList = TraceNameList("SSPanel#SSGraph", ";", 1)
	
	switch(num)
	case 0:
		KillWindow SSPanel#SSGraph
		Display/W=(0,320,1176,650)/HOST=#  root:solarSimulator:Storage:sa vs root:solarSimulator:Storage:sa
		RenameWindow #,SSGraph			
		ModifyGraph /W=SSPanel#SSGraph  tick=2
		ModifyGraph /W=SSPanel#SSGraph  zero=2
		ModifyGraph /W=SSPanel#SSGraph  mirror=1
		ModifyGraph /W=SSPanel#SSGraph  minor=1
		ModifyGraph /W=SSPanel#SSGraph  standoff=0
		SetAxis /W=SSPanel#SSGraph left 0,1
		SetAxis /W=SSPanel#SSGraph bottom 370,1800
		break
	case 1:
		KillWindow SSPanel#SSGraph
		Display/W=(0,320,584,650)/HOST=#  root:solarSimulator:Storage:sa vs root:solarSimulator:Storage:sa
		RenameWindow #,SSGraph			
		ModifyGraph /W=SSPanel#SSGraph  tick=2
		ModifyGraph /W=SSPanel#SSGraph  zero=2
		ModifyGraph /W=SSPanel#SSGraph  mirror=1
		ModifyGraph /W=SSPanel#SSGraph  minor=1
		ModifyGraph /W=SSPanel#SSGraph  standoff=0
		SetAxis /W=SSPanel#SSGraph left 0,1
		SetAxis /W=SSPanel#SSGraph bottom 370,1800
		break
	endswitch
	if(strlen(tracelist))
		variable i, id			
		string trace
		string sdf = GetDataFolder (1)
		SetDataFolder root:SolarSimulator:graphwaves:
		for (i=0; strlen(trace)!=0; i+=1)
			trace = (StringFromList(i, traceList))
			if (!cmpstr(trace, "sa") || strlen(trace)==0)
				continue
			endif
			id = str2num(trace[strlen(trace)-1])
			if (numtype(id)==2)
				Draw ($(StringFromList(i, traceList)),  7)	
			elseif (stringmatch (trace,"*led*"))
				Draw ($(StringFromList(i, traceList)),  8)	
			elseif (id>=0&&id <=6)
				Draw ($(StringFromList(i, traceList)), id)	
			endif						
		endfor
		SetDataFOlder sdf
	endif
End

Function Extend_ivGraph(num)
	variable num
	String traceList = TraceNameList("SSPanel#SSCurvaIV", ";", 1)
	string gname
	switch (num)
	case 0:
		KillWindow SSPanel#SSCurvaIV
		gname = "SSPanel#SSCurvaIV"
		Display/W=(0,320,1176,650)/HOST=SSPanel  root:SolarSimulator:Storage:sa vs root:SolarSimulator:Storage:sa	
		RenameWindow #,SSCurvaIV
		ModifyGraph /W=$gname tick=2
		ModifyGraph /W=$gname zero=2
		ModifyGraph /W=$gname mirror=1
		ModifyGraph /W=$gname minor=1
		ModifyGraph /W=$gname standoff=0	
		ModifyGraph /W=$gname alblRGB(left)=(39321,39319,1),alblRGB(bottom)=(1,39321,39321)
		ModifyGraph /W=$gname wbRGB=(65535,65278,63479)
		Label /W=$gname left "Current Density (mA/cm\\S2\\M)"
		Label /W=$gname bottom "Voltage (V)"	
		SetAxis /W=$gname left -0.1, 0.5
		SetAxis /W=$gname bottom -1, 5	
		break
	case 1:
		KillWindow SSPanel#SSCurvaIV
		gname = "SSPanel#SSCurvaIV"
		Display/W=(592,320,1176,650)/HOST=SSPanel  root:SolarSimulator:Storage:sa vs root:SolarSimulator:Storage:sa	
		RenameWindow #,SSCurvaIV
		ModifyGraph /W=$gname tick=2
		ModifyGraph /W=$gname zero=2
		ModifyGraph /W=$gname mirror=1
		ModifyGraph /W=$gname minor=1
		ModifyGraph /W=$gname standoff=0	
		ModifyGraph /W=$gname alblRGB(left)=(39321,39319,1),alblRGB(bottom)=(1,39321,39321)
		ModifyGraph /W=$gname wbRGB=(65535,65278,63479)
		Label /W=$gname left "Current Density (mA/cm\\S2\\M)"
		Label /W=$gname bottom "Voltage (V)"	
		SetAxis /W=$gname left -0.1, 0.5
		SetAxis /W=$gname bottom -1, 5	
		break		
	endswitch
	if(strlen(tracelist))
		variable i		
		string trace
		for (i=0; strlen(trace)!=0; i+=1)
			trace = (StringFromList(i, traceList))
			if (!cmpstr(trace, "sa") || strlen(trace)==0)
				continue
			endif
			//Return the full path including the wavename.
			string path_trace = getwavesdatafolder ($trace, 2)
			AppendToGraph  /W=$gname $path_trace	
		endfor
	endif
End

