#pragma TextEncoding = "Windows-1252"
//#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "gpibcom"
//static strconstant com = " "

//IMPROTANT: 
//To make this program work, we have to introduce the folder called "SolarSimulatorData" into the "Igor Pro User Files" Folder.
//THe path to that folder is "C:User:Documents:Wavemetric:IgorProUserFiles:" for most computers

//The Mightex Channel is set here.
static constant channel1 = 1
static constant channel2 = 2
static constant channel3 = 3
static constant imax = 800

Menu "S.Solar"
	SubMenu "Solar Panel"	
		"Display /�",/Q, Init_SP ()
		"Init SolarPanel /�", /Q, Init_SP (val = 1)	
		"KillPanel /�", /Q, killPanel()
	End
	SubMenu "Keithley 2600"
		"Init Kethley", /Q, init_keithley_k2600()
		"Close Keithley", /Q, close_keithley_k2600()
	End
	SubMenu "Mightex"
		"Mightex Panel", /Q, include_Mightex()
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
	wave wavelamp, wavespectre;
	
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
		wavepath = "root:SolarSimulator:Spectre:SRef:"+fname
		break
	case 13:
		wavepath = "root:SolarSimulator:Spectre:SLamp:"+fname
		break
	endswitch
	
	variable id = num2id(num)
	if ( mod (num, 2) && num<12)//type: ref		
		destwavename = "wavesubdut"+num2str(id)	
	elseif ( !mod (num, 2) && num<12)//type: dut
		destwavename = "wavesubref"+num2str(id)		
	elseif (num == 12 )
		destwavename = "wavespectre"
	elseif (num == 13 )
		destwavename = "wavelamp"
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
	
	if (!isScaled(destwave))
		SetScale /I x, 0, 2000 , destwave
	endif
	/////////****we will see this in the future***///
	//It has been reviewed, my decision is to comment Draw at Load.
//	if (!Draw (destwave, id))
//		string realname = nameofwave (destwave)
//		ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(65535, 0, 0)//redcolor for new loaded waves
//	endif	
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
		case 6:	//it is Spectre Slamp or Sref
			AppendtoGraph/R /W=SSPanel#SSGraph trace
			Label/W=SSPanel#SSGraph right "Spectrum"
			ModifyGraph /W=SSPanel#SSGraph minor=1
			ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(20000, 20000, 20000)
			break
		case 7:	//led spectre
			Appendtograph /W=SSPanel#SSGraph trace
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
			return 1		
End

//This is going to be the next task with the visibility of LEDS gaussian waves on the screen.
//FLAG
Function SetVarProc_SimSol(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			nvar ledchecked = root:SolarSimulator:Storage:ledchecked
			strswitch (sva.ctrlname)
				//sva.dval -> variable value
				case "setvarLed530":	
					Led_Gauss(530)
//					ledchecked = 1
//					Check_PlotEnable (7, checked=checked)
//					CheckBox checkgraph_leds,value=ledchecked
				break
				case "setvarLed740":
					Led_Gauss(740)
				break
				case "setvarLed940":
					Led_Gauss(940)
				break
			endswitch
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
//			variable deviceID = 31269	//Me lo invento, the other function does not work yet
			strswitch (ba.ctrlname)
//				case "buttonLog":
				case "btnMeasIV":					
					meas_SSCurvaIV(deviceID, 0)
					break
				case "btnMeasJsc":
					nvar jsc  = root:SolarSimulator:Storage:jsc
					jsc = Meas_Jsc(deviceID)
//					jsc = meas_SSCurvaIV (deviceID, 3)
					break
				case "btnMeasVoc":
					nvar voc = root:SolarSimulator:Storage:voc
					voc = Meas_Voc(deviceID)
					voc = meas_SSCurvaIV (deviceID, 2)
					break
				case "buttonLedApply":
					nvar ledchecked = root:SolarSimulator:Storage:ledchecked
					if (ledchecked)
						Led_Apply()		
					endif			
					break
				case "buttonClean":
					Clean(btn = 1)
					break
				default: 
					if (stringmatch (baName, "btncheck*"))
						if (str2num(baName[8])>=0 && str2num(baName[8])<=5)
							wave btnValues = root:SolarSimulator:Storage:btnValues
//							wave JscMeas = root:SolarSimulator:Storage:jscMeas
							variable id = str2num(baName[8])
							btnValues[id]=!btnValues[id]							
							Button_JscEnable(id)
							Calc_JscObj(id)	
							Calc_JscM (id)	
							if (btnValues[id])
								CountDown_Jsc (deviceID, id, 10 )					
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
//					Disable_All(1)					
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
					ModifyGraph /W=SSPanel#SSCurvaIV log(left)=checked
					break
				case "checkgraph_leds":
					nvar ledchecked = root:SolarSimulator:Storage:ledchecked
					ledchecked = checked
					Check_PlotEnable (7, checked=checked)	
					break
				case "checkgraph_spectre":
					nvar spectrechecked = root:SolarSimulator:Storage:spectrechecked
					spectrechecked = checked
					Check_PlotEnable (6, checked=checked)
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
					print popnum
					probe = popNum
					break
				case "popupDir":
					nvar /z forward = root:SolarSimulator:Storage:forward
					forward = popNum
					break
								
				//CODIGO DE IVAN PARA LOS POPUP DROPDOWNS.
				//My idea here is to use eqlist to display the sref and slamp as we do in the normal spectres.
				case "popupSubSref":	//Cargar Sref
					wavepath = Load (popStr, 12)
					if (strlen (wavepath))
						nvar spectrechecked = root:SolarSimulator:Storage:spectrechecked
						spectrechecked = 1
						CheckBox checkgraph_spectre,value= spectrechecked
						Check_PlotEnable (6, checked = spectrechecked)
					endif
					
					//Note: lOOK if /H is necessary (it creates a copy of the loaded wave)					
				break
				case "popupSubSlamp":	//Cargar Slamp
					wavepath = Load (popStr, 13)
					if (strlen (wavepath))
						nvar spectrechecked = root:SolarSimulator:Storage:spectrechecked
						spectrechecked = 1
						CheckBox checkgraph_spectre,value= spectrechecked
						Check_PlotEnable (6, checked = spectrechecked)
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
							//Wavepath is just for debugging, it will be deleted.
						endif
						
					endif
				break
			endswitch			
		break
		case -1: // control being killed
			break
	endswitch
	return 0
end

Function Init_SP ([val])
	variable val
	if (ItemsinList (WinList("SSPanel", ";", "")) > 0 && val == 1)
		SetDrawLayer /W=SSPanel  Progfront
		DoWindow /F SSPanel
		return 0
	endif 
	init_solarVar (val=val)	
//	Load_Spectre()
	Solar_Panel ()
	Init_Keithley_2600()
End

function include_Mightex() // MightexPanel
//	Execute/P/Q/Z "INSERTINCLUDE \"MightexPanel\""
//	Execute/P/Q/Z "COMPILEPROCEDURES "
//	Execute/P /Q/Z "init_MightexPanel()"
End

//In case we only export the procedure, not the experiment (in the fture it will make sense) 
Function Load_Spectre ()
	string sp = GetDataFolder(1)
	string general_path = SpecialDirPath ("Igor Pro User Files", 0, 0, 0)
	general_path += "SolarSimulatorData"
//	string general_path1 = replaceString (":", general_path, "\ " )	
//	general_path1 = replaceString ("C\ ", general_path1, "C:\ ") 
//	general_path1 = replaceString (" ", general_path1, "")
//	print general_path1	
	
	//LED_DATA	
//	string led_path = general_path + "\SLeds"
	SetDataFolder root:SolarSimulator:Spectre:SLeds
	newpath/O/Q lpath, general_path + ":SLeds"
	LoadWave/C/O/Q /P=lpath	"LED530.ibw"
	LoadWave/C/O/Q /P=lpath	"LED740.ibw"
	LoadWave/C/O/Q /P=lpath	"LED940.ibw"
	
	//SOLAR SPECTRE DATA
	NewPath/O/Q 	rpath, general_path + ":SRef"
//	string ref_path = general_path + ":SRef"
	SetDataFolder root:SolarSimulator:Spectre:SRef
	LoadWave/C/O/Q /P=rpath	"AMG173DIRECT.ibw"
	LoadWave/C/O/Q /P=rpath	"AMG173GLOBAL.ibw"
	LoadWave/C/O/Q /P=rpath	"AMO.ibw"
	
	SetDataFolder root:SolarSimulator:Spectre:SLamp
	NewPath/O/Q 	lpath, general_path + ":SLamp"
	LoadWave/C/O/Q /P=lpath	"XT10open2012.ibw"
	
	killPath /A 
	SetDataFolder sp
End

Function Init_SolarVar ([val])
	variable val
	string path = "root:SolarSimulator"
	//If never initialized
	if(!DatafolderExists(path) || val == 1)
		string smsg = "You have to initialize first.\n"
		smsg += "Do you want to initialize?\n"
		DoAlert /T="Unable to open the program" 1, smsg
		if (V_flag == 2)		//Clicked <"NO">
//			Abort "Execution aborted.... Restart IGOR"
			return NaN
		elseif (V_flag == 1)	//Clicked <"YES">
			genDFolders(path)
			genDFolders(path + ":Storage")	
//			genDFolders(path + ":Storage:K2600")
			genDFolders(path + ":GraphWaves")
			genDFolders(path + ":Spectre")
			//Here we have to load Sstd and Slamp manually 
			genDFolders(path + ":Spectre:SRef")
			genDFolders(path + ":Spectre:SLamp")
			genDFolders(path + ":Spectre:SLeds")
		endif
	endif
	
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
	make /O 	root:SolarSimulator:GraphWaves:wavelamp = Nan
	make /O 	root:SolarSimulator:GraphWaves:wavespectre = Nan
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
	
	variable /G ledchecked 
	variable /G spectrechecked
	spectrechecked = 0
	ledchecked = 0
	//Increase power of leds
	make /N=3 /O LedLevel
	wave LedLevel = LedLevel
	LedLevel = {0, 0, 0}
	make /O led530 = Nan
	make /O led740 = Nan
	make /O led940 = Nan
	 
	//Values of LedCurrents
	make /N=3	/O 		root:SolarSimulator:Storage:Iset = Nan
	
	//LedChannel
//	variable/G root:SolarSimulator:Storage:channel
//	nvar channel = root:SolarSimulator:Storage:channel
//	channel = 1
	
	//ComPort
	string/G root:SolarSimulator:Storage:COM //Connected by serial port
	svar com = root:SolarSimulator:Storage:COM
	com = " "
	
	//Jsc
	make /N=6 /O root:SolarSimulator:Storage:JscObj 
	make /N=6 /O root:SolarSimulator:Storage:JscMeas 
	make /N=6 /O root:SolarSimulator:Storage:JscM
	wave JscObj = root:SolarSimulator:Storage:JscObj 
	wave JscMeas = root:SolarSimulator:Storage:JscMeas 
	wave JscM = root:SolarSimulator:Storage:JscM
	JscMeas = {0,0,0,0,0,0}
	JscObj = {0,0,0,0,0,0}
	JscM = {0,0,0,0,0,0}
	
	
	variable/G darea
	variable/G iarea
	darea = 0
	
	//Keithley K2600
//	SetDataFolder "Jsc-K2600"	
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
	light_dark = 0	//1 - Light / 2 - Dark
	forward = 1	 //Reverse => forward=2 
	ff=0; jsc=0; jmp= 0; vmp=0; voc=0;		
		
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
	
	string wlampname = "XT10open2012"
	string wspecname = "AMG173DIRECT"
	
	Copy ("root:SolarSimulator:Spectre:SLamp:"+wlampname, "GraphWaves:wavelamp")
	Copy ("root:SolarSimulator:Spectre:SRef:" +wspecname, "GraphWaves:wavespectre")
	
	//Leds	
	SetDataFolder :Storage
	//We dont wave the 530 spectre. We use for now the 470 spectre instead of the 530
	Copy ("root:SolarSimulator:Spectre:SLeds:LED470", "led530")
	Copy ("root:SolarSimulator:Spectre:SLeds:LED740", "led740")
	Copy ("root:SolarSimulator:Spectre:SLeds:LED940", "led940")
	SetDataFolder path
	
	
	//The leds' power
	wave LedLevel = :Storage:LedLevel
	
	//Loops
	variable i
	
	//It has been created  when Leds Procedure initialize. 
	svar com = root:SolarSimulator:Storage:com
	nvar spectrechecked = :Storage:spectrechecked
	//Jsc
//	wave JscMeas = root:SolarSimulator:Storage:JscMeas
//	wave JscObj = root:SolarSimulator:Storage:JscObj
//	nvar darea = root:SolarSimulator:Storage:darea
	
	PauseUpdate; Silent 1		// building window...
	
	//Panel
	
	DoWindow/K SSPanel; DelayUpdate
//	NewPanel /K=0 /W=(150,105,1215,776) as "SSPanel"
//	NewPanel /K=0 /W=(30,59,1329,709) as "SSPanel"		//Large Panel
	NewPanel /K=0 /W=(56,85,1232,735) as "SSPanel"		//Short Panel	
	DoWindow /C SSPanel
	
	//Text
	SetDrawLayer UserBack
//	SetDrawEnv fstyle= 1
//	DrawText 675,71,"   Max \rCurrent"
//	SetDrawEnv fstyle= 1
//	DrawText 728,72,"   Set  \rCurrent "
	SetDrawEnv linethick= 1.5
	DrawLine 672,639,672,24
	
//	DrawText 43,313,"Cargar S\\BSTD"
//	DrawText 179,314,"Cargar S\\BLAMP"
//	DrawText 169,357,"Cargar EQE\\BREF"
//	DrawText 319,355,"Cargar EQE\\BDUT"
//	DrawText 482,355,"Jsc\\BOBJ"
//	DrawText 585,355,"Jsc\\BMEAS"
//	DrawText 546,355,"M"	
//	DrawText 633,355,"N�\\BSOLES"
	
	DrawText 39,18,"Cargar S\\BSTD"
	DrawText 175,19,"Cargar S\\BLAMP"
	DrawText 165,62,"Cargar EQE\\BREF"
	DrawText 315,60,"Cargar EQE\\BDUT"
	DrawText 478,60,"Jsc\\BOBJ"
	DrawText 581,60,"Jsc\\BMEAS"
	DrawText 542,60,"M"
	DrawText 629,60,"N�\\BSOLES"
	
	//Buttons
//	Button buttonLog,pos={29.00,617.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="Print LOG",fColor=(16385,65535,41303)
	Button buttonLedApply,pos={506.00,501.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="APPLY",fColor=(16385,65535,41303)
	Button buttonClean,pos={490.00,297.00},size={102.00,36.00},proc=ButtonProc_SimSolar,title="Clean Graph",fColor=(65535,65532,16385)	
	Button btncheck0,pos={450.00,360.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck1,pos={450.00,380.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck2,pos={450.00,400.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck3,pos={450.00,420.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck4,pos={450.00,440.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck5,pos={450.00,460.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)

	PopupMenu popupSubSref,pos={15.00,313.00},size={143.00,19.00},bodyWidth=143,proc=PopMenuProc_SimSolar
	PopupMenu popupSubSref,mode=100,popvalue=wspecname,value= #"QEWaveList(1)"
	PopupMenu popupSubSlamp,pos={161.00,314.00},size={100.00,19.00},bodyWidth=100,proc=PopMenuProc_SimSolar
	PopupMenu popupSubSlamp,mode=100,popvalue=wlampname,value= #"QEWaveList(2)"
	PopupMenu popupSub0,pos={5.00,360.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #0"
	PopupMenu popupSub0,mode=1,popvalue=stringfromlist(0,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub1,pos={5.00,380.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #1"
	PopupMenu popupSub1,mode=1,popvalue=stringfromlist(1,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub2,pos={5.00,400.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #2"
	PopupMenu popupSub2,mode=1,popvalue=stringfromlist(2,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub3,pos={5.00,420.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #3"
	PopupMenu popupSub3,mode=2,popvalue=stringfromlist(3,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub4,pos={5.00,440.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #4"
	PopupMenu popupSub4,mode=2,popvalue=stringfromlist(4,popVal),value= #"\"Yes;No\""
	PopupMenu popupSub5,pos={5.00,460.00},size={99.00,19.00},bodyWidth=40,proc=PopMenuProc_SimSolar,title="SubCell #5"
	PopupMenu popupSub5,mode=2,popvalue=stringfromlist(5,popVal),value= #"\"Yes;No\""	
	PopupMenu popupLedCom,pos={142.00,502.00},size={111.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="ComPort"
	PopupMenu popupLedCom,mode=100,popvalue=com,value= #"\"COM1;COM2;COM3;COM4;COM5;COM6;COM7;COM8;USB\""
	//Notes: Mode=100 -> at the beginning in the dropdowns it is shown the item number 100 ( apparently nothing )
	PopupMenu popupSubREF0,pos={110.00,360.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF0,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT0,pos={275.00,360.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT0,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF1,pos={110.00,380.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF1,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT1,pos={275.00,380.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT1,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF2,pos={110.00,400.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF2,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT2,pos={275.00,400.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT2,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF3,pos={110.00,420.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF3,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT3,pos={275.00,420.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT3,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF4,pos={110.00,440.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF4,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT4,pos={275.00,440.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT4,mode=100,popvalue=" ",value= #"QEList(2)"
	PopupMenu popupSubREF5,pos={110.00,460.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubREF5,mode=100,popvalue=" ",value= #"QElist(1)"
	PopupMenu popupSubDUT5,pos={275.00,460.00},size={163.00,19.00},bodyWidth=163,proc=PopMenuProc_SimSolar
	PopupMenu popupSubDUT5,mode=100,popvalue=" ",value= #"QEList(2)"
	
//	CheckBox check0,pos={465.00,360.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check1,pos={465.00,380.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check2,pos={465.00,400.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check3,pos={465.00,420.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check4,pos={465.00,440.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check5,pos={465.00,460.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0

	CheckBox checkgraph_leds,pos={509.00,573.00},size={80.00,15.00},proc=CheckProc_SimSolar,title="On/Off Leds"
	CheckBox checkgraph_leds,value= 0
	
	CheckBox checkgraph_spectre,pos={274.00,315.00},size={36.00,15.00},proc=CheckProc_SimSolar,title="On/Off"
	CheckBox checkgraph_spectre,value= spectrechecked

	SetVariable setvarLed530,pos={263.00,500.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led 530"
	SetVariable setvarLed530,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[0],live= 1
	SetVariable setvarLed740,pos={263.00,520.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led 740"
	SetVariable setvarLed740,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[1],live= 1
	SetVariable setvarLed940,pos={263.00,540.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led 940"
	SetVariable setvarLed940,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[2],live= 1
	
	ValDisplay valdispJREF0,pos={473.00,362.00},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispJREF0,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(0)"
	ValDisplay valdispJREF1,pos={473.00,382.00},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispJREF1,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(1)"
	ValDisplay valdispJREF2,pos={473.00,402.00},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispJREF2,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(2)"
	ValDisplay valdispJREF3,pos={473.00,422.00},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispJREF3,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(3)"
	ValDisplay valdispJREF4,pos={473.00,442.00},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispJREF4,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(4)"
	ValDisplay valdispJREF5,pos={473.00,462.00},size={50.00,17.00},bodyWidth=50,valueColor=(52428,1,20971)
	ValDisplay valdispJREF5,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(5)"
	ValDisplay valdispJ0,pos={581,362.00},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispJ0,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(0)"
	ValDisplay valdispJ1,pos={581,382.00},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispJ1,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(1)"
	ValDisplay valdispJ2,pos={581,402.00},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispJ2,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(2)"
	ValDisplay valdispJ3,pos={581,422.00},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispJ3,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(3)"
	ValDisplay valdispJ4,pos={581,442.00},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispJ4,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(4)"
	ValDisplay valdispJ5,pos={581,462.00},size={50.00,17.00},bodyWidth=50,valueColor=(1,16019,65535)
	ValDisplay valdispJ5,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(5)"
	ValDisplay valdispJM0,pos={527.00,362.00},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispJM0,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscM(0)"
	ValDisplay valdispJM1,pos={527.00,382.00},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispJM1,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscM(1)"
	ValDisplay valdispJM2,pos={527.00,402.00},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispJM2,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscM(2)"
	ValDisplay valdispJM3,pos={527.00,422.00},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispJM3,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscM(3)"
	ValDisplay valdispJM4,pos={527.00,442.00},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispJM4,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscM(4)"
	ValDisplay valdispJM5,pos={527.00,462.00},size={50.00,17.00},bodyWidth=50,valueColor=(30000,20000,60000)
	ValDisplay valdispJM5,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscM(5)"
	ValDisplay valdispSol0,pos={635.00,362.00},size={29.00,17.00},bodyWidth=29,disable=2
	ValDisplay valdispSol0,valueColor=(1,16019,65535),limits={0,0,0},barmisc={0,1000},value= #"get_JscMeas(0)"
	ValDisplay valdispSol1,pos={635.00,382.00},size={29.00,17.00},bodyWidth=29,disable=2
	ValDisplay valdispSol1,valueColor=(1,16019,65535),limits={0,0,0},barmisc={0,1000},value= #"get_JscMeas(0)"
	ValDisplay valdispSol2,pos={635.00,402.00},size={29.00,17.00},bodyWidth=29,disable=2
	ValDisplay valdispSol2,valueColor=(1,16019,65535),limits={0,0,0},barmisc={0,1000},value= #"get_JscMeas(0)"
	ValDisplay valdispSol3,pos={635.00,422.00},size={29.00,17.00},bodyWidth=29,disable=2
	ValDisplay valdispSol3,valueColor=(1,16019,65535),limits={0,0,0},barmisc={0,1000},value= #"get_JscMeas(0)"
	ValDisplay valdispSol4,pos={635.00,442.00},size={29.00,17.00},bodyWidth=29,disable=2
	ValDisplay valdispSol4,valueColor=(1,16019,65535),limits={0,0,0},barmisc={0,1000},value= #"get_JscMeas(0)"
	ValDisplay valdispSol5,pos={635.00,462.00},size={29.00,17.00},bodyWidth=29,disable=2
	ValDisplay valdispSol5,valueColor=(1,16019,65535),limits={0,0,0},barmisc={0,1000},value= #"get_JscMeas(0)"
	ValDisplay valdispJsc,pos={1040.00,380.00},size={99.00,17.00},bodyWidth=75,disable=2,title="Jsc\\B(mA/cm2)"
	ValDisplay valdispJsc,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdispJsc,value= #"root:SolarSimulator:Storage:Jsc"
	ValDisplay valdispVoc,pos={1040.00,410.00},size={99.00,17.00},bodyWidth=75,disable=2,title="Voc\\B(V)"
	ValDisplay valdispVoc,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdispVoc,value= #"root:SolarSimulator:Storage:Voc"
	ValDisplay valdispff,pos={1040.00,440.00},size={99.00,17.00},bodyWidth=75,disable=2,title="FF(%)"
	ValDisplay valdispff,limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdisph,pos={1040.00,470.00},size={99.00,17.00},bodyWidth=75,disable=2,title="h(%)"
	ValDisplay valdisph,limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispJmp,pos={1040.00,500.00},size={99.00,17.00},bodyWidth=75,disable=2,title="Jsc\\B(mA/cm2)"
	ValDisplay valdispJmp,limits={0,0,0},barmisc={0,1000},value= #"0"
	ValDisplay valdispVmp,pos={1040.00,530.00},size={99.00,17.00},bodyWidth=75,disable=2,title="Voc\\B(V)"
	ValDisplay valdispVmp,limits={0,0,0},barmisc={0,1000},value= #"0"
	
	//Functions to initialize panel
	for (i = 0; i<6; i++)
		Pop_Action (i, popValues)
	endfor 
	//Check_JscEnable (-1, 0)
	
	//Display 
	string gname = "SSPanel#SSGraph"
	Display/W=(0,0,594,292)/HOST=SSPanel  :Storage:sa vs :Storage:sa
	RenameWindow #,SSGraph
//	ModifyGraph mode=3
//	ModifyGraph lSize=2
	ModifyGraph /W=$gname tick=2
	ModifyGraph /W=$gname zero=2
	ModifyGraph /W=$gname mirror=1
	ModifyGraph /W=$gname minor=1
	ModifyGraph /W=$gname standoff=0
	Label /W=$gname left "%"
	Label /W=$gname bottom "nm"
	//Label right "Spectrum"
	SetAxis /W=$gname left*,1
	SetAxis /W=$gname bottom*,2000
	
	
	//Curve I-V
	Button btnMeasIV,pos={900,400},size={96,25},proc=ButtonProc_SimSolar,title="\\f01Measure IV"
	Button btnAbort,pos={715,605},size={57,20},title="ABORT",labelBack=(65280,0,0)
	Button btnAbort,fSize=14,fStyle=1,fColor=(65280,0,0)
	Button btnAbort, disable=2
	Button btnMeasJsc,pos={1045.00,302.00},size={96.00,25.00},proc=ButtonProc_SimSolar,title="Measure Jsc"
	Button btnMeasJsc,fColor=(65535,65532,16385)
	Button btnMeasVoc,pos={1045.00,333.00},size={96.00,25.00},proc=ButtonProc_SimSolar,title="Measure Voc"
	Button btnMeasVoc,fColor=(16385,65535,65535)
	
	CheckBox checklog,pos={700.00,308.00},size={36.00,15.00},proc=CheckProc_SimSolar,title="Logarithmic_Graph",value= 0
	
	SetVariable setvarstep,pos={714.00,449.00},size={112.00,18.00},proc=SetVarProc_SimSol,title="Step (V)"
	SetVariable setvarstep,limits={0,1,0.1},value= root:SolarSimulator:Storage:step,live= 1
	SetVariable setvarvmin,pos={715.00,473.00},size={112.00,18.00},proc=SetVarProc_SimSol,title="Min (V)"
	SetVariable setvarvmin,limits={0,1,0.1},value= root:SolarSimulator:Storage:vmin,live= 1
	SetVariable setvarilimit,pos={714.00,551.00},size={112.00,18.00},proc=SetVarProc_SimSol,title="Limit (A)"
	SetVariable setvarilimit,limits={0,1,0.1},value= root:SolarSimulator:Storage:ilimit,live= 1
	SetVariable setvardelay,pos={715.00,522.00},size={112.00,18.00},proc=SetVarProc_SimSol,title="Delay (V)"
	SetVariable setvardelay,limits={0,1,0.1},value= root:SolarSimulator:Storage:delay,live= 1
	SetVariable setvarvmax,pos={716.00,497.00},size={112.00,18.00},proc=SetVarProc_SimSol,title="Max (V)"
	SetVariable setvarvmax,limits={0,1,0.1},value= root:SolarSimulator:Storage:vmax,live= 1
	SetVariable setvarnplc,pos={717.00,578.00},size={112.00,18.00},proc=SetVarProc_SimSol,title="Nplc"
	SetVariable setvarnplc,limits={0,1,0.1},value= root:SolarSimulator:Storage:nplc,live= 1
	SetVariable setvarDArea,pos={843.00,339.00},size={169.00,18.00},title="Total Area (cm2)"
	SetVariable setvarDArea,value= root:SolarSimulator:Storage:darea
	SetVariable setvarNotes,pos={829.00,609.00},size={336.00,18.00},title="\\f01Notes"
	SetVariable setvarNotes,value= root:SolarSimulator:Storage:notes	
	SetVariable setvarName,pos={870.00,583.00},size={293.00,18.00},title="\\f01DUT name"
	SetVariable setvarName,value= root:SolarSimulator:Storage:dname
	
	PopupMenu popupDir,pos={705.00,340.00},size={113.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="Bias Type"
	PopupMenu popupDir,mode=1,popvalue="Forward",value= #"\"Forward;Reverse\""
	PopupMenu popupChannel,pos={711.00,415.00},size={107.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="Channel"
	PopupMenu popupChannel,mode=1,popvalue="A",value= #"\"A;B\""
	PopupMenu popupAmbient,pos={724.00,390.00},size={94.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="Curve"
	PopupMenu popupAmbient,mode=1,popvalue="Light",value= #"\"Light;Dark\""
	PopupMenu popupProbe,pos={725.00,366.00},size={94.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="Probe"
	PopupMenu popupProbe,mode=1,popvalue="4-Wire",value= #"\"2-Wire;4-Wire\""
	
	gname = "SSPanel#SSCurvaIV"
	//ControlBar?
	Display/W=(674,0,1329,295)/HOST=SSPanel  :Storage:sa vs :Storage:sa
	RenameWindow #,SSCurvaIV
//	ModifyGraph mode=3
//	ModifyGraph lSize=2
	ModifyGraph /W=$gname tick=2
	ModifyGraph /W=$gname zero=2
	ModifyGraph /W=$gname mirror=1
	ModifyGraph /W=$gname minor=1
	ModifyGraph /W=$gname standoff=0
	Label /W=$gname left "Current Density (mA/cm\\S2\\M)"
	Label /W=$gname bottom "Voltage (V)"
	SetDrawLayer UserFront
	

	SetActiveSubwindow ##	
	
	//Waves drawn in the graph
//	SetDataFolder root:SolarSimulator:GraphWaves
//	wave wavesubdut0, wavesubdut1, wavesubdut2, wavesubdut3, wavesubdut4, wavesubdut5;
//	wave wavesubref0, wavesubref1, wavesubref2, wavesubref3, wavesubref4, wavesubref5;
//	wave wavelamp, wavespectre;
//	wave waveled530, waveled740, waveled940;
//	AppendtoGraph /W=SSPanel#SSGraph wavesubdut0 
//	AppendtoGraph /W=SSPanel#SSGraph wavesubdut1 	
//	AppendtoGraph /W=SSPanel#SSGraph wavesubdut2
//	AppendtoGraph /W=SSPanel#SSGraph wavesubdut3
//	AppendtoGraph /W=SSPanel#SSGraph wavesubdut4 
//	AppendtoGraph /W=SSPanel#SSGraph wavesubdut5
//	AppendtoGraph /W=SSPanel#SSGraph wavesubref0
//	AppendtoGraph /W=SSPanel#SSGraph wavesubref1
//	AppendtoGraph /W=SSPanel#SSGraph wavesubref2
//	AppendtoGraph /W=SSPanel#SSGraph wavesubref3
//	AppendtoGraph /W=SSPanel#SSGraph wavesubref4
//	AppendtoGraph /W=SSPanel#SSGraph wavesubref5
////	AppendtoGraph /W=SSPanel#SSGraph waveled530
////	AppendtoGraph /W=SSPanel#SSGraph waveled740
////	AppendtoGraph /W=SSPanel#SSGraph waveled940	
//	AppendtoGraph/R /W=SSPanel#SSGraph wavelamp	
//	AppendtoGraph/R /W=SSPanel#SSGraph wavespectre
//	Label/W=SSPanel#SSGraph right "Spectrum"
//	ModifyGraph /W=SSPanel#SSGraph minor=1
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
	string checkX
	string btnX
	string popupX
	string popupY
	string valdisp1
	string valdisp2
	checkX = "check" + num2str(popNum)
	btnX = "btn"+checkX
	popupX = "popupSubREF" + num2str(popNum)
	popupY = "popupSubDUT" + num2str(popNum)
	if (popValues[popNum])
//		CheckBox $checkX, 	disable = 0
		Button $btnX, disable = 0
		PopupMenu $popupX,	disable = 0
		PopupMenu $popupY,	disable = 0	
	else
//		CheckBox $checkX, 	disable = 1
		Button $btnX,	disable = 1
		PopupMenu $popupX,	disable = 2
		PopupMenu $popupY,	disable = 2
	endif	
end

//***********Check-Rules********************************************************************************************//
//Check 0-5 Subcells 
//Check 6 Both Spectres' Plot 
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
			string spectre, lamp
			spectre = "wavespectre"
			lamp = "wavelamp"
			wave wavelamp = $lamp
			wave wavespectre = $spectre
			if (checked)
				Draw (wavelamp, 6)
				Draw (wavespectre, 6)
			else
				RemovefromGraph /Z /W=SSPanel#SSGraph wavelamp
				RemovefromGraph /Z /W=SSPanel#SSGraph wavespectre
				
				ModifyGraph /W=SSPanel#SSGraph  tick=2
				ModifyGraph /W=SSPanel#SSGraph  zero=2
				ModifyGraph /W=SSPanel#SSGraph  mirror=1
				ModifyGraph /W=SSPanel#SSGraph  minor=1
				ModifyGraph /W=SSPanel#SSGraph  standoff=0
			endif
		elseif (id == 7)
			SetDataFolder path
			string led530, led740, led940
			led530 = "waveled530"
			led740 = "waveled740"
			led940 = "waveled940"
			wave waveled530 = $led530
			wave waveled740 = $led740
			wave waveled940 = $led940	
			if (checked)
				Draw (waveled530, 7)
				Draw (waveled740, 7)
				Draw (waveled940, 7)
				//This is only when clicking the checkbox (On or off)
				TurnOn_Leds()
			else
				RemovefromGraph /Z /W=SSPanel#SSGraph waveled530
				RemovefromGraph /Z /W=SSPanel#SSGraph waveled740
				RemovefromGraph /Z /W=SSPanel#SSGraph waveled940
				TurnOff_Leds()
			endif
		endif
	endif
		
	SetDataFolder savedatafolder	
End
gi
Function Button_JscEnable (id)
	//id is the selected box that we want to enable or disable
	//checked is the state that the selected checkbox has got
	variable id
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path	
	wave btnValues = :Storage:btnValues
	nvar ledchecked = :Storage:LedChecked
	variable i
	//*********Coming Soon: refresh*************//
	variable refresh //Selected
	string btncheck
	string valdisp1, valdisp2, valdisp3;
	string getJscObj, getJscMeas, getJscM;
	for (i=0;i<6; i++)
		btncheck = "btncheck" + num2str(i)
		valdisp1 = "valdispJREF" + num2str(i)
		valdisp2 = "valdispJ" + num2str(i)
		valdisp3 = "valdispJM" + num2str(i)
		getJscObj = "get_JscObj("+num2str(i)+")"
		getJscMeas = "get_JscMeas("+num2str(i)+")"
		getJscM = "get_JscM("+num2str(i)+")"
		if (id != i || !btnValues[i])
			Button $btncheck, fColor=(16385,65535,41303)
			ValDisplay $valdisp1, disable = 2
			ValDisplay $valdisp2, disable = 2
			ValDisplay $valdisp3, disable = 2
			btnValues[i]=0
		elseif (btnValues[i])
			//I dont know why color does not change when checked.
			Button $btncheck, fColor=(65535, 0, 0)
			ValDisplay $valdisp1, disable = 0,value = #getJscObj
			ValDisplay $valdisp2, disable = 0,value = #getJscMeas
			ValDisplay $valdisp3, disable = 0,value = #getJscM
			//Lets draw only the correspondant EQE waves
//			Check_PlotEnable (id)
//			Check_PlotEnable (7, checked = ledchecked)
			
		endif
	endfor
	SetDataFolder savedatafolder
end

//Reconstruction of Display. Clean Display
Function Clean ([btn])
	variable btn
	string sdf = getdatafolder (1)
	SetDataFolder root:SolarSimulator
	nvar ledchecked = :Storage:ledchecked
	switch (btn)
	case 1://if btn==1 -> Included Leds
		ledchecked = 0
	case 2://if btn==2 -> Total Clean (included jsc_buttons)
		wave btnValues = :Storage:btnValues
		btnValues = {0,0,0,0,0,0}
		Button_jscEnable (-1)
		break
	endswitch
	KillWindow SSPanel#SSGraph
	Display/W=(0,0,594,292)/HOST=#  :Storage:sa vs :Storage:sa 
	RenameWindow #,SSGraph	
	ModifyGraph /W=SSPanel#SSGraph  tick=2
	ModifyGraph /W=SSPanel#SSGraph  zero=2
	ModifyGraph /W=SSPanel#SSGraph  mirror=1
	ModifyGraph /W=SSPanel#SSGraph  minor=1
	ModifyGraph /W=SSPanel#SSGraph  standoff=0
//	Label left "%"
//	Label bottom "nm"
//	Label right "Spectrum"
	SetAxis left*,1
	SetAxis bottom*,2000
	string checkspectre = "checkgraph_spectre"
	string checkleds = "checkgraph_leds"
	CheckBox $checkspectre, value = 0//, labelBack = (0, 0, 0)
	CheckBox $checkleds, value = ledchecked//, labelBack = (0, 0, 0)
	
	Setdatafolder sdf
end

//Different Functions for Scaling . We will use them maybe in the future
//Get Delta from start parameter
//Function newDeltaStart (wav, newstart)
//	wave wav
//	variable newstart
//	variable start = leftx (wav)					
//	variable ending = rightx (wav)
//	variable newending = newstart/start*ending
//	variable rows = DimSize (wav, 0)
//	variable newdelta = (newending - newstart)/rows
//	return newdelta	
//End

//Get delta from End parameter
//Function newDeltaEnding (wav, newending)
//	wave wav
//	variable newending
//	variable start = leftx (wav)					
//	variable ending = rightx (wav)
//	variable newstart = newending*start/ending
//	variable rows = DimSize (wav, 0)
//	variable newdelta = (newending - newstart)/rows
//	return newdelta	
//End

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
Function Led_Gauss (num)
	variable num	
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path + ":Storage"
	wave led530, led740, led940;
	wave ledlevel	
	wave  Iset;
	SetDataFolder path + ":GraphWaves"
	wave waveled530, waveled740, waveled940;	
	
	//Originally led740 spectrum is not scaled equally as the others
	if (!isScaled(led740))
		CopyScales led530, led740
	endif
	
	switch (num)
	case 530:
		Duplicate/O led530, waveled530
		waveled530 = led530 * ledlevel[0] / waveMax (led530) 
		Iset[0] = Imax * ledlevel[0]
		Draw (waveled530, 7)
		break
	case 740:
		Duplicate/O led740, waveled740
		waveled740 = led740 * ledlevel[1] / waveMax (led740)
		Iset[1] = Imax * ledlevel[1]
		Draw (waveled740, 7)
		break
	case 940:
		Duplicate/O led940, waveled940
		waveled940 = led940 * ledlevel[2] / waveMax (led940)  
		Iset[2] = Imax * ledlevel[2]
		Draw (waveled940, 7)
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
	if (!isScaled(destwave))
		SetScale /I x, 0, 2000 , destwave
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
//Switching on and off
Function TurnOn_Leds()
	setMode (channel1, 1)	//Normal mode
	setMode (channel2, 1)
	setMode (channel3, 1)
	setNormalParameters (channel1, Imax, 0)
	setNormalParameters (channel2, Imax, 0)
	setNormalParameters (channel3, Imax, 0)
End

Function TurnOff_Leds()
	variable channel	
	for (channel=1;channel<4;channel+=1)	//12 channels, 3 used
		setMode (channel, 0)	//Disable
	endfor
End



Function Led_Apply ()
	
	string savedatafolder = GetDataFolder(1)
	SetDataFolder "root:SolarSimulator:Storage"
	wave Iset
	setNormalCurrent (channel1, Iset[0])
	setNormalCurrent (channel2, Iset[1])
	setNormalCurrent (channel3, Iset[2])
	SetDataFolder savedatafolder
End

Function Led_Disable (option)
	variable option
	variable channel
		string smsg = "Do you want to disable all channels?\n"
		DoAlert /T="Disable before Exit" 1, smsg
		if (V_flag == 2)		//Clicked <"NO">
			return 0
		elseif (V_flag == 1)	//Clicked <"YES">	
			for (channel=1;channel<13;channel+=1)	//12 channels
				setMode (channel, 0)	//Disable
			endfor
		endif
End

//Function Disable_All ([option])
//	variable option
//	if (paramisdefault (option))
//		option = 0
//	endif
//	
//	variable channel
//	switch (option)
//		case 1:
//			string smsg = "Do you want to disable all channels?\n"
//			DoAlert /T="Disable before Exit" 1, smsg
//			if (V_flag == 2)		//Clicked <"NO">
//			//Abort "Execution aborted.... Restart IGOR"
//				return 0
//			elseif (V_flag == 1)	//Clicked <"YES">	
//				TurnOff_leds()
//			endif
//			break
//		case 2:
//			KillDataFolder root:SolarSimulator:Storage
////			KillPath ref_path
////			KillPath led_path
////			KillPath lamp_path
//			break
//	endswitch	
//End

////My own Function to calculate jsc from qe and s.spectre
Function qe2JscSS (qe, specw)
	wave qe , specw	//qeSubCellRef y solar spectre (am0, amgd, amgg..)
	variable jsc
	variable num
	//Identify if the wave contains Nan on its first positin.
	if ( numtype (qe[0]) == 2 || numtype (specw[0]) == 2) 
		return 0
	endif

	variable numPoints=(numpnts(qe)-1)*deltax(qe)+1
	interpolate2 /T=1 /N=(numPoints) /Y=tmpw qe
	Duplicate /O tmpw,sr
	
	sr=(1.602e-19*tmpw*x*1e-9)/(6.62606957e-34*2.99792458e8) // mA / W
	
	sr*=specw(x)/10
	jsc=area(sr)
//	jsc = area ( src, rangex1, rangex2) //between a certain point-range
//	integrate/t sr
//	jsc=sr[numpnts(sr)-1]
	wavekiller("tmpw")
	wavekiller("sr")

	return jsc
End

//Function Calc_JscObj_v1(id)
//	variable id
//	wave jscObj = root:SolarSimulator:Storage:jscObj
//	wave wavespectre = root:SolarSimulator:GraphWaves:wavespectre
//	switch (id)
//	case 0:
//		wave qe = root:SolarSimulator:GraphWaves:wavesubref0		
//		jscObj[0] = qe2JscSS (qe, wavespectre)
//		break
//	case 1:
//		wave qe = root:SolarSimulator:GraphWaves:wavesubref1
//		jscObj[1] = qe2JscSS (qe, wavespectre)
//		break
//	case 2:
//		wave qe = root:SolarSimulator:GraphWaves:wavesubref2		
//		jscObj[2] = qe2JscSS (qe, wavespectre)
//		break
//	case 3:
//		wave qe = root:SolarSimulator:GraphWaves:wavesubref3		
//		jscObj[3] = qe2JscSS (qe, wavespectre)
//		break
//	case 4:
//		wave qe = root:SolarSimulator:GraphWaves:wavesubref4		
//		jscObj[4] = qe2JscSS (qe, wavespectre)
//		break
//	case 5:
//		wave qe = root:SolarSimulator:GraphWaves:wavesubref5		
//		jscObj[5] = qe2JscSS (qe, wavespectre)
//		break
//	endSwitch
//	string valdispJx = "valdispJREF"+num2str(id)
//	string getJsc = "get_JscObj ("+num2str(id)+")"
//	ValDisplay $valdispJx, value= #getJsc
//	
//End

Function Calc_JscObj(id)
	variable id
	wave jscObj = root:SolarSimulator:Storage:jscObj
	wave wavespectre = root:SolarSimulator:GraphWaves:wavespectre
	string sdf = GetDataFolder (1)
	SetDataFolder root:SolarSimulator:GraphWaves
	string sref = "wavesubref"+num2str(id)
	wave qe = $sref
	SetDataFolder sdf
	JscObj[id] = qe2JscSS ( qe, wavespectre)
	string valdispJx = "valdispJREF"+num2str(id)
	string getJsc = "get_JscObj ("+num2str(id)+")"
	ValDisplay $valdispJx, value= #getJsc
End

Function Calc_JscM (id)
	variable id
	wave JscM = root:SolarSimulator:Storage:JscM
	wave JscObj = root:SolarSimulator:Storage:JscObj
	string wavesubrefX = "wavesubref" + num2str(id)
	string wavesubdutX = "wavesubdut" + num2str(id)
	string sdf = GetDataFOlder (1)
	SetDataFolder root:SolarSimulator:GraphWaves
	wave wsref = $wavesubrefX
	wave wsdut = $wavesubdutX
	wave wavespectre
	wave wavelamp
	make /O /N=4	jsc
	wave jsc
	
	jsc[0] = qe2jscSS ( wsdut, wavelamp )
	jsc[1] = qe2jscSS ( wsref, wavespectre )
	jsc[2] = qe2jscSS ( wsref, wavelamp )
	jsc[3] = qe2jscSS ( wsdut, wavespectre )
	
	//Introducir Calculo de JscObj dentro de este
//	JscObj[id] =  
	JscM[id] = jsc[0]*jsc[1]/jsc[2]/jsc[3]	
	
	string valdispJx = "valdispJREF"+num2str(id)
	string getJsc = "get_JscObj ("+num2str(id)+")"
	ValDisplay $valdispJx, value= #getJsc
	
	wavekiller ("jsc")	
	SetDataFolder sdf

End


 
 
Function get_JscObj (i)
	variable i
	wave JscObj = root:SolarSimulator:Storage:JscObj
	return JscObj[i]
end

Function get_JscMeas (i)
	variable i
	wave JscMeas = root:SolarSimulator:Storage:JscMeas
	return JscMeas[i]
end

Function get_JscM (i)
	variable i
	wave JscM = root:SolarSimulator:Storage:JscM
	return JscM[i]
end

//*******************Keithley K2600***********************************************************************************************************//	
Function Init_Keithley_2600()
	InitBoard_GPIB(0) 		//	****
	InitDevice_GPIB(0,26)	//26 is for Keithley_2600
	//pending to catch errors
//	print "Keithley Initialized"
End
Function  Close_Keithley_2600()
	DevClearList(0,26)
End

//en meas_SSCurvaIV we implementate this fnction. 
Function Meas_Jsc (deviceID)
	variable deviceID
	string sdf = GetDataFolder (1)
	SetDataFolder "root:SolarSimulator:Storage"
	nvar probe, probe, ilimit, nplc, delay, darea
	svar channeL
	variable jsc
	if (darea == 0)
		SetVariable setvarDArea, valueBackColor= (57933,66846,1573)
		
	else 
		SetVariable setvarDArea, valueBackColor=0
	endif
	configK2600_GPIB_SSCurvaIV(deviceID,3,channel,probe,ilimit,nplc,delay)	 	// ****
	jsc = -1*measI_K2600(deviceID,channel)
	jsc*=(1e3/darea)
	return jsc
	SetDataFolder sdf
End

//en meas_SSCurvaIV we implementate this fnction. 
Function Meas_Voc(deviceID)
	variable deviceID
	string sdf = GetDataFolder (1)
	SetDataFolder "root:SolarSimulator:Storage"
	nvar probe, probe, ilimit, nplc, delay
	svar channel
	nvar darea
	variable voc
	configK2600_GPIB_SSCurvaIV(deviceID,3,channel,probe,ilimit,nplc,delay)		// ****
	voc=-1*measI_K2600(deviceID,channel)
	voc*=(1e3/darea)
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

Function meas_SSCurvaIV (deviceID, type)
	variable deviceID, type;
	svar channel = root:SolarSimulator:Storage:channel
	nvar probe = root:SolarSimulator:Storage:probe
	nvar ilimit = root:SolarSimulator:Storage:ilimit
	nvar nplc = root:SolarSimulator:Storage:nplc
	nvar delay = root:SolarSimulator:Storage:delay
	nvar step = root:SolarSimulator:Storage:step
	nvar vmin = root:SolarSimulator:Storage:vmin
	nvar vmax = root:SolarSimulator:Storage:vmax
	nvar forward = root:SolarSimulator:Storage:forward
	nvar darea = root:SolarSimulator:Storage:darea
	
	switch (type)
	case 0:		//Meas IV
		configK2600_GPIB_SSCurvaIV(deviceID,type,channel,probe,ilimit,nplc,delay)
		measIV_K2600(deviceID,step,vmin,vmax,channel,forward)
		break
	case 2:		//Meas V
		variable voc
		configK2600_GPIB_SSCurvaIV(deviceID,type,channel,probe,ilimit,nplc,delay) // o second argument means iv meas
		voc=measV_K2600(deviceID,channel)	// ****
		ValDisplay valdispVoc,value= #"root:SolarSimulator:Storage:Voc"
		return voc
	case 3:		//Meas I ( Jsc)
		variable jsc
		configK2600_GPIB_SSCurvaIV(deviceID,3,channel,probe,ilimit,nplc,delay) // ****
		jsc=-1*measI_K2600(deviceID,channel)
		jsc*=(1e3/darea)		
		return jsc
	endswitch		
End
//*********************************************************************************DO NOT UNCOMMENT***********************//
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

//*******************Keithley K2600***********************************************************************************************************//	


Function CountDown_Jsc(deviceID, id, countdown)
	variable deviceID
	variable id, countdown	
	wave jsc = root:SolarSimulator:Storage:jscMeas
	wave btnValues = root:SolarSimulator:Storage:btnValues
	string valdispJX = "valdispJ" + num2str(id)
	string getJscMeas = "get_JscMeas(" + num2str (id) + ")"
	String message = "Initializing measurement"
	TitleBox countdown_message,pos={340,617},size={100,20},title=message
	String abortStr = "Press escape to abort"
	TitleBox countdown_abort,pos={500,617},size={100,20},title=abortStr
	Dilay (500)
	Variable startTicks = ticks
	Variable endTicks = startTicks + 60*countdown
	Variable lastMessageUpdate = startTicks
	variable count = 1 //borrar***
	do		
		DoUpdate /W=SSPanel#SSGraph /E=1
		if (ticks>=lastMessageUpdate+60)			// Time to update message?
			Variable remaining = (endTicks - ticks) / 60
			sprintf message, "Time remaining: %d seconds", remaining
			TitleBox countdown_message, title=message
			lastMessageUpdate = ticks
			jsc[id] = Meas_Jsc (deviceID)		// ****
//			jsc[id] = count //Just to get some auxiliary values
			ValDisplay $valdispJX,valueColor=(1,16019,65535),value = #getJscMeas
			ValDisplay $valdispJX,format = "%.3g"
		endif

		if (GetKeyState(0) && 32 || btnValues[id] != 1)		//Press Esc, Alt or CTRL
//			abortStr = "Test aborted by Escape."
//			message = "CANCELLED"
//			TitleBox countdown_abort,title=abortStr
//			TitleBox countdown_message,title=message
//			jsc [id] = Nan
//			Dilay (500)	//ms
			break			//Out of loop	
		endif
		count ++
	while(ticks < endTicks)
	abortStr = ""
	message = ""
	TitleBox countdown_message, title = message
	TitleBox countdown_abort, title = abortStr

End


	
	