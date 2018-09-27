#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "gpibcom"
//static strconstant com = " "

Menu "S.Solar"
	"Display /ç",/Q, Init_SP (val = 1)
	"Init /ñ", /Q, Init_SP ()
	"KillPanel /´", /Q, killPanel()
	"Mightex Panel", /Q, init_mightexPanel()
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
	wave originwave = $wavepath
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
			case "waveled470":
				ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(65535, 0, 0)
				break
			case "waveled850":
				ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(6554,56098,2359)
				break
			case "waveled1540":
				ModifyGraph /W=SSPanel#SSGraph rgb($realname)=(3146,5243,45875)
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
			strswitch (sva.ctrlname)
				//sva.dval -> variable value
				case "setvarLed470":	
					Led_Gauss(470)
				break
				case "setvarLed850":
					Led_Gauss(850)
				break
				case "setvarLed1540":
					Led_Gauss(1540)
				break
				//I do it directly from setvar 
//				case "setvardarea":
//					nvar darea = root:SolarSimulator:Storage:darea
//					darea = sva.dval
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
			strswitch (ba.ctrlname)
//				case "buttonLog":
				case "buttonMeasIV":
//					configK2600_GPIB(deviceID,0,channel,probe,ilimit,nplc,delay) // o second argument means iv meas
//					sweepIV_K2600(deviceID,step,nmin,nmax,channel,forw)
				case "buttonLedApply":
					nvar ledchecked = root:SolarSimulator:Storage:ledchecked
					if (ledchecked)
						Led_Apply()		
					endif			
				break
				case "buttonClean":
					Clean()
				break
				default: 
					if (stringmatch (baName, "btncheck*"))
						if (str2num(baName[8])>=0 && str2num(baName[8])<=5)
							wave btnValues = root:SolarSimulator:Storage:btnValues
							variable id = str2num(baName[8])
							btnValues[id]=1							
							Button_JscEnable(id)
							Calc_JscObj(id)
							Calc_JscMeas(id)
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
				case "checkgraph_leds":
					nvar ledchecked = root:SolarSimulator:Storage:ledchecked
					ledchecked = checked
					Check_PlotEnable (7, checked=checked)	
					break
				case "checkgraph_spectre":
					Check_PlotEnable (6, checked=checked)
					break
				default:
				if (stringmatch (check_name, "Check*"))
					variable id = str2num (check_name[5])
					if (id>=0 && id<=5)			
//						Check_JscEnable(id, checked)
						if(checked)
							Calc_JscObj(id)
						endif
					endif
				endif
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
			string wavepath//useless.
			strswitch (pa.ctrlname)
				case "popupChannel":
					svar /Z channel = root:SolarSimulator:Storage:channel
					channel = popStr
					break
				case "popupAmbient":
					nvar /z light_dark = root:SolarSimulator:Storage:light_dark
					light_dark = popNum
					break
				case "popupCom":
					svar /Z com = root:SolarSimulator:Storage:com					
					if (init_leds(popStr))
						com=popStr
					else
						PopupMenu popupCom, popvalue=" ", mode=1
					endif
					break
				//CODIGO DE IVAN PARA LOS POPUP DROPDOWNS.
				//My idea here is to use eqlist to display the sref and slamp as we do in the normal spectres.
				case "popupSubSref":	//Cargar Sref
					wavepath = Load (popStr, 12)
					
					//Note: lOOK if /H is necessary (it creates a copy of the loaded wave)					
				break
				case "popupSubSlamp":	//Cargar Slamp
					wavepath = Load (popStr, 13)
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
	init_solarVar ()
	Solar_Panel ()
//	InitBoard_GPIB(0)
//	InitDevice_GPIB(0,26)
End
	
Function Init_SolarVar ()

	string path = "root:SolarSimulator"
	//If never initialized
	if(!DatafolderExists(path))
		string smsg = "You have to initialize first.\n"
		smsg += "Do you want to initialize?\n"
		DoAlert /T="Unable to open the program" 1, smsg
		if (V_flag == 2)		//Clicked <"NO">
//			Abort "Execution aborted.... Restart IGOR"
			return NaN
		elseif (V_flag == 1)	//Clicked <"YES">
			genDFolders(path)
			genDFolders(path + ":Storage")	
//			genDFolders(path + ":Storage:Jsc-K2600")
			genDFolders(path + ":GraphWaves")
			genDFolders(path + ":Spectre")
			//Here we have to load Sstd and Slamp manually 
			genDFolders(path + ":Spectre:Sref")
			genDFolders(path + ":Spectre:Slamp")
			genDFolders(path + ":Spectre:Sleds")
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
	make /O 	root:SolarSimulator:GraphWaves:waveled470 = Nan
	make /O 	root:SolarSimulator:GraphWaves:waveled850 = Nan
	make /O 	root:SolarSimulator:GraphWaves:waveled1540 = Nan
			
	//Disable/Enable Dropdowns things on the panel
	make /N=6 /O  :Storage:popvalues
	wave popValues = :Storage:popvalues
	popValues = {1, 1, 1, 0, 0, 0}
	
	//Display traces on graph depending on the checkbox selected
	make /N=5 /O :Storage:btnValues
	wave btnValues = :Storage:btnValues
	btnValues = {0, 0, 0, 0, 0, 0}
	
	variable /G :Storage:ledchecked 
	//Increase power of leds
	make /N=3 /O :Storage:LedLevel
	wave LedLevel = :Storage:LedLevel
	LedLevel = {0, 0, 0}
	make /O :Storage:led470 = Nan
	make /O :Storage:led850 = Nan
	make /O :Storage:led1540 = Nan
	 
	//Values of LedCurrents
	make /N=3	/O 		root:SolarSimulator:Storage:Iset = Nan
	make /N=3 /O 	root:SolarSimulator:Storage:Imax 
	wave Imax = root:SolarSimulator:Storage:Imax  
	Imax = {1000, 1000, 1000}
	
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
	wave JscObj = root:SolarSimulator:Storage:JscObj 
	wave JscMeas = root:SolarSimulator:Storage:JscMeas 
	JscMeas = {0,0,0,0,0,0}
	JscObj = 0
	
	SetDataFolder ":Storage"
	variable/G darea
	variable/G iarea
	darea = 0
	
	//Keithley K2600
//	SetDataFolder ":Storage:Jsc-K2600"	
	Variable/G probe, probe, ilimit, nplc, delay, vmax, vmin, step, light_dark, forward;
	String /G channel
	channel = "A"
	probe = 1 //2-Wire = 0, 4-Wire = 1
	nplc = 1
	ilimit = 0.1
	delay = 1 
	vmax = 1
	vmin = 0
	step = 0.01
	light_dark = 0	//1 - Light / 2 - Dark
	forward = 1	 //Reverse => forward=2
		
		
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
		
	//Leds	
	SetDataFolder :Storage
	Copy ("root:SolarSimulator:Spectre:SLeds:led470", "led470")
	Copy ("root:SolarSimulator:Spectre:SLeds:led850", "led850")
	Copy ("root:SolarSimulator:Spectre:SLeds:led1540", "led1540")
	SetDataFolder path
//	wave led470 = :storage:led470
//	wave led850 = :storage:led850
//	wave led1540 = :storage:led1540
	
	//The leds' power
	wave LedLevel = :Storage:LedLevel
	
	//Loops
	variable i
	
	//It has been created  when Leds Procedure initialize. 
	svar com = root:SolarSimulator:Storage:com
	
	//Jsc
//	wave JscMeas = root:SolarSimulator:Storage:JscMeas
//	wave JscObj = root:SolarSimulator:Storage:JscObj
//	nvar darea = root:SolarSimulator:Storage:darea
	
	PauseUpdate; Silent 1		// building window...
	
	//Panel
	DoWindow/K SSPanel; DelayUpdate
//	NewPanel /K=0 /W=(150,105,1215,776) as "SSPanel"
	NewPanel /K=0 /W=(30,59,1329,709) as "SSPanel"
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
	DrawText 491,353,"Jsc\\BREF OBJETIVO"
	DrawText 574,355,"Jsc\\BREF MEDIDO"
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
//	Button buttonCargarOnda,pos={57.00,493.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="Cargar EQE Wave"
//	Button buttonCargarOnda,fColor=(16385,65535,41303)
//	Button buttonLoadLed,pos={504.00,495.00},size={103.00,15.00},proc=ButtonProc_SimSolar,title="Cargar LedSpectre"
//	Button buttonLoadLed,fColor=(65535,16385,16385)
//	Button buttonRemoveLed,pos={504.00,524.00},size={102.00,36.00},proc=ButtonProc_SimSolar,title="Remove Led\rFrom Graph"
//	Button buttonRemoveLed,fColor=(51664,44236,58982)
	Button buttonLog,pos={29.00,617.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="Print LOG"
	Button buttonLog,fColor=(16385,65535,41303)
	Button buttonLedApply,pos={506.00,501.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="APPLY"
	Button buttonLedApply,fColor=(16385,65535,41303)
	
	Button buttonClean,pos={490.00,297.00},size={102.00,36.00},proc=ButtonProc_SimSolar,title="Clean Graph"
	Button buttonClean,fColor=(65535,65532,16385)	
	
	Button btncheck0,pos={465.00,360.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck1,pos={465.00,380.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck2,pos={465.00,400.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck3,pos={465.00,420.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck4,pos={465.00,440.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	Button btncheck5,pos={465.00,460.00},size={13.00,13.00},proc=ButtonProc_SimSolar,title="",fColor=(16385,65535,41303)
	
	//Curve I-V
	Button btnMeasIV,pos={900,400},size={96,25},proc=BtnProc_measIVpanel,title="\\f01Measure IV"
	Button btnAbort,pos={715,605},size={57,20},title="ABORT",labelBack=(65280,0,0)
	Button btnAbort,fSize=14,fStyle=1,fColor=(65280,0,0)
	Button btnAbort disable=2
	
	//PopUps
	PopupMenu popupSubSref,pos={15.00,313.00},size={143.00,19.00},bodyWidth=143,proc=PopMenuProc_SimSolar
	PopupMenu popupSubSref,mode=100,popvalue=" ",value= #"QEWaveList(1)"
	PopupMenu popupSubSlamp,pos={161.00,314.00},size={100.00,19.00},bodyWidth=100,proc=PopMenuProc_SimSolar
	PopupMenu popupSubSlamp,mode=100,popvalue=" ",value= #"QEWaveList(2)"	
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
	PopupMenu popupCom,pos={142.00,502.00},size={111.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="ComPort"
	PopupMenu popupCom,mode=100,popvalue=com,value= #"\"COM1;COM2;COM3;COM4;COM5;COM6;COM7;COM8;USB\""

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
	
	PopupMenu popupDir,pos={705.00,340.00},size={113.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="Bias Type"
	PopupMenu popupDir,mode=1,popvalue="Forward",value= #"\"Forward;Reverse\""
	PopupMenu popupChannel,pos={711.00,415.00},size={107.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="Channel"
	PopupMenu popupChannel,mode=1,popvalue="A",value= #"\"A;B\""
	PopupMenu popupAmbient,pos={724.00,390.00},size={94.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="Curve"
	PopupMenu popupAmbient,mode=1,popvalue="Light",value= #"\"Light;Dark\""
	PopupMenu popupProbe,pos={725.00,366.00},size={94.00,19.00},bodyWidth=60,proc=PopMenuProc_SimSolar,title="Probe"
	PopupMenu popupProbe,mode=1,popvalue="4-Wire",value= #"\"2-Wire;4-Wire\""
	
	
	
	//CheckBox
//	CheckBox check0,pos={465.00,360.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check1,pos={465.00,380.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check2,pos={465.00,400.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check3,pos={465.00,420.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check4,pos={465.00,440.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0
//	CheckBox check5,pos={465.00,460.00},size={13.00,13.00},proc=CheckProc_SimSolar,title="", value=0

	CheckBox checkgraph_leds,pos={509.00,573.00},size={80.00,15.00},proc=CheckProc_SimSolar,title="On/Off Leds"
	CheckBox checkgraph_leds,value= 0
	
	CheckBox checkgraph_spectre,pos={274.00,315.00},size={36.00,15.00},proc=CheckProc_SimSolar,title="On/Off"
	CheckBox checkgraph_spectre,value= 0
	
	
	//SetVariable
	SetVariable setvarLed470,pos={263.00,500.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led 470"
	SetVariable setvarLed470,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[0],live= 1
	SetVariable setvarLed850,pos={263.00,520.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led 850"
	SetVariable setvarLed850,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[1],live= 1
	SetVariable setvarLed1540,pos={263.00,540.00},size={229.00,18.00},proc=SetVarProc_SimSol,title="Led 1540"
	SetVariable setvarLed1540,limits={0,1,0.1},value= root:SolarSimulator:Storage:LedLevel[2],live= 1
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
	
	//ValDisplay
	ValDisplay valdispJREF0,pos={488.00,362.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF0,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(0)"
	ValDisplay valdispJREF1,pos={488.00,382.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF1,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(1)"
	ValDisplay valdispJREF2,pos={488.00,402.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF2,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(2)"
	ValDisplay valdispJREF3,pos={488.00,422.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF3,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(3)"
	ValDisplay valdispJREF4,pos={488.00,442.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF4,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(4)"
	ValDisplay valdispJREF5,pos={488.00,462.00},size={75.00,17.00},bodyWidth=75,valueColor=(52428,1,20971)
	ValDisplay valdispJREF5,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscObj(5)"
	ValDisplay valdispJ0,pos={573.00,362.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ0,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(0)"
	ValDisplay valdispJ1,pos={573.00,382.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ1,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(1)"
	ValDisplay valdispJ2,pos={573.00,402.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ2,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(2)"
	ValDisplay valdispJ3,pos={573.00,422.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ3,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(3)"
	ValDisplay valdispJ4,pos={573.00,442.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ4,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(4)"
	ValDisplay valdispJ5,pos={573.00,462.00},size={75.00,17.00},bodyWidth=75,valueColor=(1,16019,65535)
	ValDisplay valdispJ5,format="",limits={0,0,0},barmisc={0,1000},disable=2,value = #"get_JscMeas(5)"
	
	
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
	SetDataFolder root:SolarSimulator:GraphWaves
	wave wavesubdut0, wavesubdut1, wavesubdut2, wavesubdut3, wavesubdut4, wavesubdut5;
	wave wavesubref0, wavesubref1, wavesubref2, wavesubref3, wavesubref4, wavesubref5;
	wave wavelamp, wavespectre;
	wave waveled470, waveled850, waveled1540;
	AppendtoGraph /W=SSPanel#SSGraph wavesubdut0 
	AppendtoGraph /W=SSPanel#SSGraph wavesubdut1 	
	AppendtoGraph /W=SSPanel#SSGraph wavesubdut2
	AppendtoGraph /W=SSPanel#SSGraph wavesubdut3
	AppendtoGraph /W=SSPanel#SSGraph wavesubdut4 
	AppendtoGraph /W=SSPanel#SSGraph wavesubdut5
	AppendtoGraph /W=SSPanel#SSGraph wavesubref0
	AppendtoGraph /W=SSPanel#SSGraph wavesubref1
	AppendtoGraph /W=SSPanel#SSGraph wavesubref2
	AppendtoGraph /W=SSPanel#SSGraph wavesubref3
	AppendtoGraph /W=SSPanel#SSGraph wavesubref4
	AppendtoGraph /W=SSPanel#SSGraph wavesubref5
	AppendtoGraph /W=SSPanel#SSGraph waveled470
	AppendtoGraph /W=SSPanel#SSGraph waveled850
	AppendtoGraph /W=SSPanel#SSGraph waveled1540	
	AppendtoGraph/R /W=SSPanel#SSGraph wavelamp	
	AppendtoGraph/R /W=SSPanel#SSGraph wavespectre
	Label/W=SSPanel#SSGraph right "Spectrum"
	ModifyGraph /W=SSPanel#SSGraph minor=1
//	AppendtoGraph /W=SSPanel#SSGraph wavelamp
//	AppendtoGraph /W=SSPanel#SSGraph wavelamp
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
	string popupX
	string popupY
	string valdisp1
	string valdisp2
	checkX = "check" + num2str(popNum)
	popupX = "popupSubREF" + num2str(popNum)
	popupY = "popupSubDUT" + num2str(popNum)
	if (popValues[popNum])
//		CheckBox $checkX, 	disable = 0
		PopupMenu $popupX,	disable = 0
		PopupMenu $popupY,	disable = 0	
	else
//		CheckBox $checkX, 	disable = 1
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
		clean()
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
			endif
		elseif (id == 7)
			SetDataFolder path
			string led470, led850, led1540
			led470 = "waveled470"
			led850 = "waveled850"
			led1540 = "waveled1540"
			wave waveled470 = $led470
			wave waveled850 = $led850
			wave waveled1540 = $led1540	
			if (checked)
				Draw (waveled470, 7)
				Draw (waveled850, 7)
				Draw (waveled1540, 7)
				//This is only when clicking the checkbox (On or off)
				TurnOn_Leds()
			else
				RemovefromGraph /Z /W=SSPanel#SSGraph waveled470
				RemovefromGraph /Z /W=SSPanel#SSGraph waveled850
				RemovefromGraph /Z /W=SSPanel#SSGraph waveled1540
				TurnOff_Leds()
			endif
		endif
		
	endif
		
	SetDataFolder savedatafolder	
End

Function Button_JscEnable (id)
	//id is the selected box that we want to enable or disable
	//checked is the state that the selected checkbox has got
	variable id
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path	
	wave btnValues = :Storage:btnValues
	variable i
	//*********Coming Soon: refresh*************//
	variable refresh //Selected
	string btncheck
	string valdisp1
	string valdisp2
	string getJscObj, getJscMeas;
	for (i=0;i<6; i++)
		btncheck = "btncheck" + num2str(i)
		valdisp1 = "valdispJREF" + num2str(i)
		valdisp2 = "valdispJ" + num2str(i)
		getJscObj = "get_JscObj("+num2str(i)+")"
		getJscMeas = "get_JscMeas("+num2str(i)+")"
		if (id != i || !btnValues[i])
			Button $btncheck, fColor=(16385,65535,41303)
			ValDisplay $valdisp1, disable = 2
			ValDisplay $valdisp2, disable = 2
		elseif (btnValues[i])
			//I dont know why color does not change when checked.
			Button $btncheck, fColor=(65535, 0, 0)
			ValDisplay $valdisp1, disable = 0,value = #getJscObj
			ValDisplay $valdisp1, disable = 0,value = #getJscObj
			ValDisplay $valdisp2, disable = 0,value = #getJscMeas
			//Lets draw only the correspondant EQE waves
			Check_PlotEnable (id)
			
		endif
	endfor
	SetDataFolder savedatafolder
end
//Function Check_JscEnable (id, checked)
//	//id is the selected box that we want to enable or disable
//	//checked is the state that the selected checkbox has got
//	variable id, checked
//	string path = "root:SolarSimulator"
//	string savedatafolder = GetDataFolder (1) 
//	SetDataFolder path
//	variable i
//	//*********Coming Soon: refresh*************//
//	variable refresh //Selected
//	string checkX
//	string valdisp1
//	string valdisp2
//	string getJscObj, getJscMeas;
//	for (i=0;i<6; i++)
//		checkX = "check" + num2str(i)
//		valdisp1 = "valdispJREF" + num2str(i)
//		valdisp2 = "valdispJ" + num2str(i)
//		getJscObj = "get_JscObj("+num2str(i)+")"
//		getJscMeas = "get_JscMeas("+num2str(i)+")"
//		if (id != i || !checked)
//			CheckBox $checkX, value = 0//, labelBack = (0, 0, 0)
//			ValDisplay $valdisp1, disable = 2
//			ValDisplay $valdisp2, disable = 2
//		elseif (checked)
//			//I dont know why color does not change when checked.
//			CheckBox $checkX, value = 1//, labelBack = (50000, 65535, 20000)
//			ValDisplay $valdisp1, disable = 0,value = #getJscObj
//			ValDisplay $valdisp2, disable = 0,value = #getJscMeas
//			//Lets draw only the correspondant EQE waves
//			Check_PlotEnable (id)
//			
//		endif
//	endfor
//	SetDataFolder savedatafolder
//end
//*******************************************************************************************************************//

//Reconstruction of Display. Clean Display
Function Clean ()
	SetDataFolder root:SolarSimulator
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
	CheckBox $checkleds, value = 0//, labelBack = (0, 0, 0)
	
	SetDataFolder root:SolarSimulator
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
	wave led470, led850, led1540;
	wave ledlevel	
	wave Imax, Iset;
	SetDataFolder path + ":GraphWaves"
	wave waveled470, waveled850, waveled1540;	
	
	//Originally led850 spectrum is not scaled equally as the others
	if (!isScaled(led850))
		CopyScales led470, led850
	endif
	
	switch (num)
	case 470:
		Duplicate/O led470, waveled470
		waveled470 = led470 * ledlevel[0] / waveMax (led470) 
		Iset[0] = Imax[0] * ledlevel[0]
		break
	case 850:
		Duplicate/O led850, waveled850
		waveled850 = led850 * ledlevel[1] / waveMax (led850)
		Iset[1] = Imax[1] * ledlevel[1]
		break
	case 1540:
		Duplicate/O led1540, waveled1540
		waveled1540 = led1540 * ledlevel[2] / waveMax (led1540)  
		Iset[2] = Imax[2] * ledlevel[2]
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
//Normal Mode	
	string sdf = GetDataFolder (1)
	SetDataFolder "root:SolarSimulator:Storage"
	wave Imax
//	setMode (1, 1)	//Normal mode
//	setMode (2, 1)
//	setMode (3, 1)
//	setNormalParameters (1, Imax[0], 0)
//	setNormalParameters (2, Imax[1], 0)
//	setNormalParameters (3, Imax[2], 0)
	SetDataFolder sdf

End

Function TurnOff_Leds()
	variable channel	
	for (channel=1;channel<4;channel+=1)	//12 channels, 3 used
//		setMode (channel, 0)	//Disable
	endfor
End

Function Led_Apply ()
	
	string savedatafolder = GetDataFolder(1)
	SetDataFolder "root:SolarSimulator:Storage"
	wave Iset, Imax
//	setNormalCurrent (1, Iset[0])
//	setNormalCurrent (2, Iset[1])
//	setNormalCurrent (3, Iset[2])	
	print Imax
	print Iset
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

//Measure Jsc -> DIFFERENT WAYS TO DO IT

////My own Function 
Function qe2JscSS (qe, specw)
	wave qe , specw
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

Function Calc_JscObj(id)
	variable id
	wave jscObj = root:SolarSimulator:Storage:jscObj
	wave wavespectre = root:SolarSimulator:GraphWaves:wavespectre
	switch (id)
	case 0:
		wave qe = root:SolarSimulator:GraphWaves:wavesubref0		
		jscObj[0] = qe2JscSS (qe, wavespectre)
		break
	case 1:
		wave qe = root:SolarSimulator:GraphWaves:wavesubref1
		jscObj[1] = qe2JscSS (qe, wavespectre)
		break
	case 2:
		wave qe = root:SolarSimulator:GraphWaves:wavesubref2		
		jscObj[2] = qe2JscSS (qe, wavespectre)
		break
	case 3:
		wave qe = root:SolarSimulator:GraphWaves:wavesubref3		
		jscObj[3] = qe2JscSS (qe, wavespectre)
		break
	case 4:
		wave qe = root:SolarSimulator:GraphWaves:wavesubref4		
		jscObj[4] = qe2JscSS (qe, wavespectre)
		break
	case 5:
		wave qe = root:SolarSimulator:GraphWaves:wavesubref5		
		jscObj[5] = qe2JscSS (qe, wavespectre)
		break
	endSwitch
End

Function calc_JscMeas (id)
	variable id	
	wave jscMeas = root:SolarSimulator:Storage:jscMeas
	string sdf = GetDataFolder (1)
	SetDataFolder "root:SolarSimulator:Storage:Jsc-K2600"
	nvar deviceID, probe, probe, ilimit, nplc, delay
	svar channel
	nvar darea = root:SolarSimulator:Storage:darea
//	configK2600_GPIB(deviceID,3,channel,probe,ilimit,nplc,delay)
//	jscMeas[id]=-1*measI_K2600(deviceID,channel)
//	jscMeas[id]*=(1e3/darea)	
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

//*******************Keithley K2600************************	
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