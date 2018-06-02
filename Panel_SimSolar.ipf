#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Menu "S.Solar"
	"Init", /Q, init_SolarPanel()
End
Function init_SolarPanel()
	
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
	PauseUpdate; Silent 1		// building window...
	
	//Display 
	DoWindow /K SolarSimulator;DelayUpdate
	Display /K=1 /W=(168.75,43.25,840.5,569.25) ss
	DoWindow /C SolarSimulator;DelayUpdate
	
	ModifyGraph
	//Panel
	
	NewPanel /K=0 /W=(306,53,709,571) as "Solar_Simulator_Panel"
	DoWindow /C VDPanel
	
	//Buttons
	Button buttonClear, pos={278.00,318.00},size={80.00,30.00}, proc=ButtonProcVDP, title="Clean"
	Button buttonClear, fSize=12,fColor=(65535,49157,16385)
	Button buttonMeas, pos={250.00,449.00},size={118.00,47.00}, proc=ButtonProcVDP, title="Measure"
	Button buttonMeas, fSize=16,fColor=(1,16019,65535)
	
	
	//SetVar
	SetVariable setvarmaxcurrent,pos={237.00,365.00},size={140.00,18.00},title="Max. Current"
	SetVariable setvarmaxcurrent,limits={0,0.5,0.01},value= root:VanDerPauw:K2600:nmax

	//ValDisplay
	ValDisplay valdisp0,pos={253.00,420.00}, size={89.00,17.00}
	ValDisplay valdisp0,barmisc={0,100}
	ValDisplay valdisp0,value=#"root:VanDerPauw:result"
	
	//Text
	DrawText 252,409,"Total Resistance:"
	
	
end
