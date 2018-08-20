#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Menu "S.Solar"
	"Init ",/Q, init_SP ()
End

Function Init_SP ()
	init_solarVar ()
	Solar_Panel ()
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
			genDFolders(path + ":LedController")
			genDFolders(path + ":LoadedWaves")
		endif
	endif
	
	SetDataFolder root:SolarSimulator
	//Initial wave for #GraphPanel
	make /N=1 /O		root:SolarSimulator:Storage:sa
	//reference to draw in the scene
//	make /O 	root:SolarSimulator:LoadedWave:wavesub0
//	make /O 	root:SolarSimulator:LoadedWave:wavesub1
//	make /O 	root:SolarSimulator:LoadedWave:wavesub2
//	make /O 	root:SolarSimulator:LoadedWave:wavesub3
//	make /O 	root:SolarSimulator:LoadedWave:wavesub4
//	make /O 	root:SolarSimulator:LoadedWave:wavesub5
//	make /O 	root:SolarSimulator:LoadedWave:wavesub6
		
	//Disable/Enable Dropdowns things on the panel
	make /N=6 /O  :Storage:popvalues
	wave popValues = :Storage:popvalues
	popValues = {1, 1, 1, 0, 0, 0}
	
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
	LedLevel = {0, 0, 0}
	
	//LedChannel
	variable/G root:SolarSimulator:channel
	nvar channel = root:SolarSimulator:channel
	channel = 1
	
	//ComPort
	string/G root:SolarSimulator:COM //Connected by serial port
	svar com = root:SolarSimulator:COM
	com = ""
	
	//**********The Solar_Panel could be launched next**********//
End

Function Solar_Panel()
	
	string path = "root:SolarSimulator"
	string savedatafolder = GetDataFolder (1) 
	SetDataFolder path
	
	//Initial wave for #GraphPanel
	wave sa = root:SolarSimulator:Storage:sa
	string nameDisplay 
	
	//Disable/Enable Dropdowns things on the panel
	wave popValues = :Storage:popvalues
	popValues = {1, 1, 1, 0, 0, 0}
	string popVal = translate (popValues)//Yes;No; Selection
	
	//Display traces on graph depending on the checkbox selected
	wave checkwave = :Storage:checkwave
	
	//Values of LedCurrents
	nvar Imax = root:SolarSimulator:LedController:Imax
	nvar Iset = root:SolarSimulator:LedController:Iset
	
	//Increase power of leds
	wave LedLevel = :Storage:LedLevel

	variable i
	
	//It has been created  when Leds Procedure initialize. 
	nvar channel = root:SolarSimulator:channel
	
	
	PauseUpdate; Silent 1		// building window...
	
	//Paths
//	Newpath/Q/O  path_Sref, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\espectros_referencia"
//	Newpath/Q/O  path_Slamp, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\espectro_simuladorSolar"
//	NewPath/Q/O 	path_SLeds, "C:\Users\III-V\Documents\Luis III-V\Prácticas Empresa\Igor\Waves_SS\Espectros_LEDS"
//	
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
	Button buttonCargarOnda,pos={57.00,493.00},size={103.00,23.00},proc=ButtonProc_SimSolar,title="Cargar EQE Wave"
	Button buttonCargarOnda,fColor=(16385,65535,41303)
	Button buttonLoadLed,pos={504.00,495.00},size={108.00,23.00},proc=ButtonProc_SimSolar,title="Cargar LedSpectre"
	Button buttonLoadLed,fColor=(65535,16385,16385)
	Button buttonRemoveLed,pos={504.00,524.00},size={102.00,36.00},proc=ButtonProc_SimSolar,title="Remove Led\rFrom Graph"
	Button buttonRemoveLed,fColor=(51664,44236,58982)
	
	Button buttonClean,pos={328.00,297.00},size={102.00,36.00},proc=ButtonProc_SimSolar,title="Clean Graph"
	Button buttonClean,fColor=(65535,65532,16385)
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
	
	CheckBox checkSetLeds,pos={509.00,573.00},size={80.00,15.00},proc=CheckProc_SimSolar,title="On/Off Leds"
	CheckBox checkSetLeds,value= 0
	
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

//DropDown "Yes-No" Selection
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

//CheckBoxes Panel "Disable-Enable" drop action
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