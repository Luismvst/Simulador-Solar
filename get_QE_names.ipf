#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.



function/S QElist(ref)
	
	variable ref
	//DFREF iodfr=$iostr
	//	Wave/Z QEname=iodfr:QEnames
	//	Wave/Z QElong=iodfr:QElong
	string runs=folderList()		//Get list of folders under root
	string run, QE1list="_none_;"
	variable i, notref
	//Look for QE waves in every folder
	for(i=0;(i<itemsinlist(runs,","));i+=1)
		run=StringFromList(i,runs,",")
		//If you don´t want to show the Reference QE in the list, check if folder is of Ref. QE
		notref= (cmpstr(QErefoptions(run),"_none_")==0)	
		//notref=1	//if you want to see ref QEsions(run),"_none_")==0)			
		DFREF QEDFR=$("root:"+run+":EQE")
		if ((DataFolderRefStatus(QEDFR)==1) && notref) //If folder exists and is not a reference folder
//			print run, DataFolderRefStatus(QEDFR)
			//This code selects waves with some ending. Will need to update the endings that work for us
			switch (ref)
			case 0:
				QE1list+=ReplaceString(",",ListMatch( StringByKey("WAVES",DataFolderDir(2,QEDFR),":"),"*_XExt",","),";")
				QE1list+=ReplaceString(",",ListMatch( StringByKey("WAVES",DataFolderDir(2,QEDFR),":"),"*_Ext",","),";")
				QE1list+=ReplaceString(",",ListMatch( StringByKey("WAVES",DataFolderDir(2,QEDFR),":"),"*_EQE",","),";")
				QE1list+=ReplaceString(",",ListMatch( StringByKey("WAVES",DataFolderDir(2,QEDFR),":"),"*_RM",","),";")
			break
			case 1:
				QE1list+=ReplaceString(",",ListMatch( StringByKey("WAVES",DataFolderDir(2,QEDFR),":"),"*_XExt",","),";")
				QE1list+=ReplaceString(",",ListMatch( StringByKey("WAVES",DataFolderDir(2,QEDFR),":"),"*_Ext",","),";")
			break
			case 2:
				QE1list+=ReplaceString(",",ListMatch( StringByKey("WAVES",DataFolderDir(2,QEDFR),":"),"*_EQE",","),";")
			break
			case 3:
				QE1list+=ReplaceString(",",ListMatch( StringByKey("WAVES",DataFolderDir(2,QEDFR),":"),"*_RM",","),";")
			break
			endswitch
//			print  QE1list
		endif
	endfor	
	return trimstring(QE1list)
end


function/s folderList()
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:
	string thelist=StringByKey("FOLDERS",DataFolderDir(1))
	thelist=SortList(RemoveFromList("Packages",thelist,","),",")
	SetDataFolder fldrSav
	return thelist
end

//Under Development 
Function /S getQEPath (fname)
	string fname		//Folder Name
	string path 
	string list, list2
	variable num
	String fldrSav=GetDataFolder (1)
	SetDataFolder root:
	list = getFolder("root:")
	num = ItemsinList (list, ",")
	variable i
	for (i = 0; i<num; i++)
		path = "root:" + stringfromlist (i, list, ",") + ":EQE:"
		if (datafolderexists(path))
			SetDataFolder path
		else	
			continue
		endif
		list2 = wavelist (fname, ";", "")
		if (strlen(list2) != 0)
			return path + list2
		endif
	endfor
	SetDataFolder fldrSav
End

Function /S getFolder (path)
	//GetFolders Under the folder path given
	string path
	String fldrSav=GetDataFolder (1)
	SetDataFolder path
	string thelist = StringByKey("FOLDERS", DataFolderDir(1))
	thelist=SortList(RemoveFromList("Packages", thelist,","),",")	
	SetDataFolder fldrSav
	return thelist
end

function/S QErefoptions(reflab)
	string reflab
	wave/Z/T refQEnames=root:Packages:DataSummary:refQEnames  //Wave with list of ref QE available
	strswitch(reflab)
		//alternative names
		case "MC831":
			reflab="N1-1"
			break
		case "MC031":
			reflab="N1-2"
			break
		case "MC387":
			reflab="N1-3"
			break
		case "MC889":
			reflab="N1-4"
			break
	endswitch
	
	if (waveexists(refQEnames))
		string refQE=refQEnames[%$reflab]
		if (cmpstr(refQE,"_none_")==0)
			//not in the list
			return "_none_"
		else
			string run=refQE[0,4]
			string fullname="root:"+run+":QE:"+refQE
			return fullname
		endif
	endif
	
	//retain for compatibility
	strswitch(reflab)
		case "MI994":
			return "root:MI994:QE:MI994n2_R_Ext"
			break
		case "MC831":
		case "N1-1":
			return "root:MC831:QE:MC831x2_Ext"
//			return "root:MC831:QE:MC831pack_Ext"
			break
		case "MJ011":
			return "root:MJ011:QE:MJ011n4_R_Ext"
			break
		case "MC387":
		case "N1-3":
			return "root:MC387:QE:MC387_ref_Ext"
//			return "root:MC387:QE:MC387pack_Ext"
			break
		case "MJ004":
			return "root:MJ004:QE:MJ004n4pack_Ext"
			break
		case "MJ019":
			return "root:MJ019:QE:MJ019n4_R_Ext"
			break
		case "MJ009":
			return "root:MJ009:QE:MJ009n11pack_Ext"
			break
		case "MF668":
			return "root:MF668:QE:MF668Bpack_Ext"
			break
		case "MC031":
		case "N1-2":
			return "root:MC031:QE:MC031Cpack_Ext"
			break
		case "MC889":
		case "N1-4":
			return "root:MC889:QE:MC889n2_Ext0"
			break
		default:
			return "_none_"
			break
	endswitch
end

Function /S QEWaveList(num)
	variable num
	string list="_none_;"
	String fldrSav= GetDataFolder(1)
	if (num == 1)
		SetDataFolder root:SolarSimulator:Spectre:SRef			
	elseif (num == 2)
		SetDataFolder root:SolarSimulator:Spectre:SLamp		
	endif
	list+= wavelist ("*", ";", "")
	SetDataFolder fldrSav
	return list
end