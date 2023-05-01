#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// r001 DTS 20230322
// 		Changed the #include <HDF5 Browser> to allow for Igor 9
// 		Changed all references to db_static_searchLimLNonPerturbed to db_static_searchLimLNonPerturb to be < 32 char in len
// 		Commented out many references at the beginning of DisplayLimChecks
// 		Moved references to be inside event switch in MassRangeset
// 		Changed the frames for title box descriptions to be single in AMS_MS_Comparisons(), fixed  "Non-Deconvoluted" typo
//		SetVariable UMRDB_NumTag and ADB_NumTag bodyWidth=50
//		Changed the name in the buttons for the CU web pages for the databases.
//		Modified gen_newdataSpeciesList to handle the case when there is only one spectra
//		ADB_NewdataCalculateButton changed the text in the button to read 'Cosine' instead of 'Cal' which is often a short name for calibration.
// 		Fixed typo in getNewMS_MS
//		In getFirstRefMS() commented out wave references that are not needed.
//		In updateGraph() moved the location of a few wave reference to not trip the wave doesn't exist error
//		In popupGraph() moved the location of a few wave references to not trip the wave doesn't exist error
// 		Change the comparisons result table for UMR and HR to show only 4 decimal places for the scores.


#if(igorVersion()<9)			//r001
#include <HDF5 Browser>
#endif

Strconstant ARoot = "root:Globals:Ambient"
Strconstant NARoot= "root:Globals:NonAmbient"
Strconstant PRoot = "root:Globals:Perturbed"
Strconstant NPRoot = "root:Globals:NonPerturbed"
Strconstant DECRoot = "root:Globals:Deconvoluted"
Strconstant NDECRoot = "root:Globals:NonDeconvoluted"
Strconstant AQRoot = "root:Globals:InstAQ"
Strconstant ATRoot = "root:Globals:InstAT"
Strconstant QRoot = "root:Globals:InstQ"
Strconstant CRoot = "root:Globals:InstC"
Strconstant VRoot = "root:Globals:InstV"
Strconstant WRoot = "root:Globals:InstW"
Strconstant LVRoot = "root:Globals:InstLV"
Strconstant LWRoot = "root:Globals:InstLW"
Strconstant MRoot = "root:Globals:InstM"
Strconstant UMRRoot = "root:Globals:UMR"
Strconstant HRRoot = "root:Globals:HR"
Strconstant HR2UMRRoot = "root:Globals:HR2UMR"
Strconstant ComRoot = "root:Globals:Com"
Strconstant SVRoot = "root:Globals:VapS"
Strconstant CVRoot = "root:Globals:VapC"
Strconstant FalseMSRoot = "root:Globals:FalseMS" //v3.4G
Strconstant TrueMSRoot = "root:Globals:TrueMS"//v3.4G

strConstant MSPLOT = "AMS_MS_Comparisons#G0"
strConstant MSTable = "AMS_MS_Comparisons#T0"
strConstant UMRDBPLOT = "AMS_MS_Comparisons#G3"


Function initialize_info()
	setdatafolder root:database
	make/T/O/N=0 AerosolOrigin //Ambient(A) or Non-Ambient(NA)
	make/T/O/N=0 AerosolPerturbation//Perturbed(P) or Non-perturbed(NP)
	Make/T/O/N=0 Analysis//Nondeconvluted(NDEC) or Deconvluted(DEC) 
	Make/T/O/N=0 Instrument//Air Quality ACSM (AQ), TOF-ACSM (AT), Quad_AMS (Q), C-ToF-AMS (C), 
	///////////////////////HR-Tof V-mode(V), HR-ToF W-mode(W), Long_Tof V-mode(LV), Long-Tof W-mode (LW) or multiple instruments (M)
	Make/T/O/N=0 Resolution//Unit Mass (UMR), High(HR), (HR2UMR), Combination(COM)
	Make/T/O/N=0 Vaporizer//Capture vaporizer(C), Standard vaporizer(S)
	Make/T/O/N=0 ShortFileDescriptor//i.e. myPMF.h5
	Make/O/N=0 EIEnergy//i.e. 70
	Make/O/N=0 VaporizerTempC// i.e. 600
	Make/T/O/N=0 CommentDAQ// i.e. special lens
	Make/T/O/N=0 NonAmbientType// i.e. Source
	Make/T/O/N=0 CommentNonAmbient// i.e. lab generated
	Make/T/O/N=0 PerturbedType// i.e. Filter collection
	Make/T/O/N=0 CommentPerturbed// i.e. optional
	Make/T/O/N=0 ExperimenterName// i.e. Jane
	Make/T/O/N=0 GroupStr// i.e. Jimenez Group
	Make/T/O/N=0 CitationUrl// i.e. http://direct.sref.org/xxxx-yyyy/acp/2009-x-yyyy
	Make/T/O/N=0 CitationStr// i.e. ACP, 2009, Vol.x, pp. yyy, SRef-ID: xxx
	Make/T/O/N=0 CitationFigStr// i.e. Fig A
	Make/T/O/N=0 CommentAnalysis// i.e. location, date, field project, misc infos  blah
	setdatafolder root:

End

Menu "Database"
	"Initialize", initializeMS(); initializeG(); GenFilterList()//v2.0
	//"Fetch information", PopupInputUrl()
	
	//v2.03 add 'initialize' function when open the panel
	"Database panel", initializeMS(); initializeG(); GenFilterList(); AMS_MS_Comparisons();	
	"Generate DB in .h5", GenDBH5()
	"Convert HR2UMR", ADB_menu_convert()//v3.4B
End

Function initializeMS()
	newdatafolder/O root:databasePanel
	SetDatafolder root:databasePanel
	Make/O/N=600 refMS_origin=0
	Make/O/N=600 MS_origin=0
	Make/T/O/N=0 columnlabel_sort
	Make/O/N=0 score_sort
	Make/O/N = 600 mzvalue=p+1
	Make/O/N=600 MSExpCalc=NaN
	Make/O/N=600 refMSExpCalc=NaN
	Make/O/N=600 sampleMSsubRefMSExpCalc=NaN
	Make/O/N=600 MS_Recalc=NaN
	Make/O/N=600 refMS_Recalc=NaN
	Make/O/N=600 sampleMSsubRefMS_Recalc=NaN
	variable/G mzMin_recalc, mzMax_recalc, mzexp_recalc, intexp_recalc//v2.01
	
	//UMRDBtab v3.0
	Make/O/N=600 UMRDB_MS_origin=NaN
	
	//v3.0 for HR2UMR panel, UMRDB tab, and HR2UMR DB tab
	newdatafolder/O root:databasePanel:HR2UMR
	setdatafolder root:databasePanel:HR2UMR
	Make/O/N=(600,17) HR2UMR_refMS_origin=0
	Make/O/N=(600,17) HR2UMR_MS_origin=0
	Make/T/O/N=0 HR2UMR_columnlabel_sort
	Make/O/N=0 HR2UMR_score_sort
	Make/O/N=0 HR2UMR_scoreHRfam_sort//v3.4
	Make/O/N=600 HR2UMR_mzvalue=p+1
	Make/O/N=(600,17) HR2UMR_MSExpCalc=NaN
	Make/O/N=(600,17) HR2UMR_refMSExpCalc=NaN
	Make/O/N=(600,17) HR2UMR_sampleMSsubRefMSExpCalc=NaN
	Make/O/N=(600,17) HR2UMR_MS_Recalc=NaN
	Make/O/N=(600,17) HR2UMR_refMS_Recalc=NaN
	Make/O/N=(600,17) HR2UMR_sampleMSsubRefMS_Recalc=NaN
	
	string familyName = "Cx;CH;CHO1;CHOgt1;CHN;CHO1N;CHOgt1N;CS;CSi;HO;NH;Cl;NO;SO;Air;Tungsten;Other;All"
	variable i
	
	for(i=0;i<18;i++)
		string HRMSName = "HR2UMR_MS_" + StringFromList(i,familyName)
		string HRrefMSName = "HR2UMR_refMS_" + StringFromList(i,familyName)
		string HRMSNameExpCalc = "HR2UMR_MS_" + StringFromList(i,familyName)+"_ExpCalc"
		string HRrefMSNameExpCalc = "HR2UMR_refMS_" + StringFromList(i,familyName)+"_ExpCalc"
		make/O/n=600 $HRMSNameExpCalc=NaN
		make/O/n=600 $HRrefMSNameExpCalc=NaN
	
	endfor
	
	newdatafolder/O root:databasePanel:HR2UMR:HR2UMRdb
	setdatafolder root:databasePanel:HR2UMR:HR2UMRdb
	for(i=0;i<18;i++)
		string HRMSdbName = "HR2UMRdb_MS_" + StringFromList(i,familyName)
		//string HRrefMSName = "HR2UMR_refMS_" + StringFromList(i,familyName)
		//string HRMSNameExpCalc = "HR2UMR_MS_" + StringFromList(i,familyName)+"_ExpCalc"
		//string HRrefMSNameExpCalc = "HR2UMR_refMS_" + StringFromList(i,familyName)+"_ExpCalc"
		make/O/n=600 $HRMSdbName=NaN
		//make/O/n=600 $HRrefMSNameExpCalc=NaN
	
	endfor
		
	
	/////
	
	Setdatafolder root:databasePanel
	//v2.04
	Make/T/O/N=(20,2) citation1info
		citation1info[0][0] = "AerosolOrigin", citation1info[1][0] = "AerosolPerturbation", citation1info[2][0] = "Analysis"
		citation1info[3][0] = "Instrument"
		citation1info[4][0] = "Resolution", citation1info[5][0] = "Vaporizer", citation1info[6][0] = "ShortFileDescriptor"
		citation1info[7][0] = "EI Energy", citation1info[8][0] = "Vaporizer Temp(C)", citation1info[9][0]="CommentDAQ"		
		citation1info[10][0] = "NonAmbient Type", citation1info[11][0] = "Comment NonAmbient", citation1info[12][0]="Perturbed Type"
		citation1info[13][0] = "Comment Perturbed", citation1info[14][0] = "Experimenter Name", citation1info[15][0]="Group Str"
		citation1info[16][0] = "CitationUrl", citation1info[17][0] = "CitationStr"
		citation1info[18][0] = "Citation Fig", citation1info[19][0] = "CommentAnalysis"
		citation1info[][1] = ""
		
	Make/T/O/N=(20,2) citation2Info
		citation2Info[0][0] = "AerosolOrigin", citation2Info[1][0] = "AerosolPerturbation", citation2Info[2][0] = "Analysis"
		citation2Info[3][0] = "Instrument"
		citation2Info[4][0] = "Resolution", citation2Info[5][0] = "Vaporizer", citation2Info[6][0] = "ShortFileDescriptor"
		citation2Info[7][0] = "EI Energy", citation2Info[8][0] = "Vaporizer Temp(C)", citation2Info[9][0]="CommentDAQ"		
		citation2Info[10][0] = "NonAmbient Type", citation2Info[11][0] = "Comment NonAmbient", citation2Info[12][0]="Perturbed Type"
		citation2Info[13][0] = "Comment Perturbed", citation2Info[14][0] = "Experimenter Name", citation2Info[15][0]="Group Str"
		citation2Info[16][0] = "CitationUrl", citation2Info[17][0] = "CitationStr"
		citation2Info[18][0] = "Citation Fig", citation2Info[19][0] = "CommentAnalysis"
		citation2info[][1] = ""
		
	Duplicate/O citation1info, UMRDB_citation1Info//v3.0
	Duplicate/O citation1info, HR2UMRDB_citation1Info//v3.0
	setDataFolder root:
End

Function initializeG() //initialize globals
	newdatafolder/O root:Globals
	Setdatafolder root:Globals
	string/g citation1list=""
	string/g citation2list=""
	string/g Ambient="", NonAmbient="", Perturbed="", NonPerturbed=""
	string/g Deconvoluted="",NonDeconvoluted="",InstAQ="", InstAT="", InstQ="", InstC=""
	string/g InstV="",InstW="",InstLV="",InstLW="",InstM=""
	string/g UMR="",HR="",HR2UMR="",Com=""
	string/g VapC="", VapS=""
	string/g FalseMS="", TrueMS=""//v3.4G generate list for the MS where m/z 28 is not equal to m/z 44.
	string/g allSpectraList="",mainlist="",indexlist="",scorelist=""
	variable/g mzmin=1, mzmax=300, mz_exp=0, int_exp=1 //v2.03
	variable/g mzminRe=1, mzmaxRe=300, mz_expRe=0, int_expRe=1//v2.03
	//generate strings for 'adding my MS to database' v2.03
	string/g AddAerosolOrigin="", AddAerosolPerturbation="", AddAnalysis="", AddCitationFigStr=""
	string/g AddCitationStr="", AddCitationUrl="" 
	string/g AddCommentAnalysis="",AddCommentDAQ="",AddCommentNonAmbient="", AddCommentPerturbed=""
	string/g AddExperimenterName="", AddGroupStr="", AddInstrument=""
	string/g AddNonAmbientType="", AddPerturbedType="", AddResolution="", AddShortFileDescriptor="", AddVaporizer=""
	variable/g AddEIEnergy=70, AddVaporizerTempC=600
	//generatate string for HR2UMR tab on the panel v3.0
	string/g HR2UMR_citation1list="", HR2UMR_citation2list=""
	string/g HR2UMR_mainlist="", HR2UMR_scorelist="", HR2UMR_indexlist="", HR2UMR_allSpectraList="", HR2UMR_scoreHRfamlist=""//v3.4 add HR2UMR_allSpectraList, HR2UMR_scoreHRfamlist
	variable/g HR2UMR_mzmin=1, HR2UMR_mzmax=200, HR2UMR_mz_exp=0, HR2UMR_int_exp=1 //v3.0
	variable/g HR2UMR_mzminRe=1, HR2UMR_mzmaxRe=200, HR2UMR_mz_expRe=0, HR2UMR_int_expRe=1//v3.0
	//generate string for UMR DB tab and HR2UMR DB tab on the panel v3.0
	string/g UMRDB_citation1list=""
	string/g HR2UMRDB_citation1list=""
	//generate string for HR2UMR legand
	string/g HR2UMR_legendStrUnitSticks = "Families:\r\f01\K(0,0,0)Cx\r\K(0,39168,0)CH\r\K(32640,0,29440)CHO1\r\K(65280,0,58880)CHOgt1\r\K(36864,14592,58880)CHN\r\K(8192,24448,32640)CHO1N\r\K(16384,48896,65280)CHOgt1N\r\K(8192,8192,65280)CS\r\K(0,0,0)HO\r\K(65280,43520,0)NH\r\K(65280,0,52224)Cl\r\K(0,65280,65280)NO\r\K(65280,0,0)SO\r\K(36864,36864,36864)Air\r\K(0,0,0)Tungsten\r\K(16384,16384,39168)Other\r\K(0,0,0)CSi"
	//v3.4D generate string for window name
	string/g MSname="", refMSname=""
	string/g HR2UMR_MSname="",HR2UMR_refMSname=""
	setdatafolder root:

End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////WHEN YOU CLICK THE PANEL, DO THIS!//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function MywindowHook(s)
	//Database Reference Mass Spectra table control
	STRUCT WMWinHookStruct &s
	variable selectedRow
	variable keypressed=s.keycode
	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.
	variable RowforRefMS
	
	controlinfo Check_Individual_Cal
	variable IndividualCheck = v_value
	

	if(cmpstr(s.WinName,"AMS_MS_Comparisons#T0") == 0)
		switch(s.eventCode)
			case 5://click
				setdatafolder root:databasepanel:
				string tabledata = Tableinfo("AMS_MS_Comparisons#T0",-2)
				sscanf stringbykey("SELECTION",TableData), "%d,,,,,", selectedRow
				//print Tableinfo("",-2),selectedRow
				RowforRefMS = selectedRow
				wave refMS_origin = getRefMs(RowforRefMS)
				//getFirstRefMS()
				if(IndividualCheck == 1)
					ValDisplay Display_Recalculated_score value = individualcal()
					updategraph()
				endif
	
				
			case 11:					// Keyboard event
				switch (s.keycode)
					case 30:
						//Print "Up arrow key pressed."
						setdatafolder root:databasepanel:
						tabledata = Tableinfo("AMS_MS_Comparisons#T0",-2)
						sscanf stringbykey("SELECTION",TableData), "%d,,,,,", selectedRow
						//print Tableinfo("",-2),selectedRow-1
						hookResult = 1
						RowforRefMS = selectedRow-1
						wave refMS_origin = getRefMs(RowforRefMS)
						//getFirstRefMS()
						if(IndividualCheck == 1)
							ValDisplay Display_Recalculated_score value = individualcal()
						endif
						
						break
					case 31:
						//Print "Down arrow key pressed."	
						setdatafolder root:databasepanel:									
						tabledata = Tableinfo("AMS_MS_Comparisons#T0",-2)
						sscanf stringbykey("SELECTION",TableData), "%d,,,,,", selectedRow
						//print Tableinfo("",-2),selectedRow+1
						hookResult = 1
						RowforRefMs = selectedRow+1
						wave refMS_origin = getRefMs(RowforRefMS)
						//getFirstRefMS()
						if(IndividualCheck == 1)
							ValDisplay Display_Recalculated_score value = individualcal()
							updategraph()
						endif
	
						//print s
						break			
					default:
						// The keyText field requires Igor Pro 7 or later. See Keyboard Events.
						//Printf "Key pressed: %s\r", s.keyText
						break			
				endswitch
				break
		endswitch

	elseif(cmpstr(s.WinName,"AMS_MS_Comparisons#T1") == 0) //when click results table in HR2UMR tab
		switch(s.eventCode)
			case 5://click
				setdatafolder root:databasepanel:HR2UMR:
				tabledata = Tableinfo("AMS_MS_Comparisons#T1",-2)
				sscanf stringbykey("SELECTION",TableData), "%d,,,,,", selectedRow
				//print Tableinfo("",-2),selectedRow
				RowforRefMS = selectedRow
				HR2UMR_getRefMs(RowforRefMS)
				HR2UMR_getFirstRefMS()
				//if(IndividualCheck == 1)
				//	ValDisplay Display_Recalculated_score value = individualcal()
				HR2UMR_updateRefMS()
				//endif
	
				
			case 11:					// Keyboard event
				switch (s.keycode)
					case 30:
						//Print "Up arrow key pressed."
						setdatafolder root:databasepanel:HR2UMR:
						tabledata = Tableinfo("AMS_MS_Comparisons#T1",-2)
						sscanf stringbykey("SELECTION",TableData), "%d,,,,,", selectedRow
						//print Tableinfo("",-2),selectedRow-1
						hookResult = 1
						RowforRefMS = selectedRow-1
						HR2UMR_getRefMs(RowforRefMS)
						HR2UMR_getFirstRefMS()
//						if(IndividualCheck == 1)
//							ValDisplay Display_Recalculated_score value = individualcal()
//						endif
						HR2UMR_updateRefMS()
						break
					case 31:
						//Print "Down arrow key pressed."	
						setdatafolder root:databasepanel:HR2UMR:									
						tabledata = Tableinfo("AMS_MS_Comparisons#T1",-2)
						sscanf stringbykey("SELECTION",TableData), "%d,,,,,", selectedRow
						//print Tableinfo("",-2),selectedRow+1
						hookResult = 1
						RowforRefMs = selectedRow+1
						HR2UMR_getRefMs(RowforRefMS)
						HR2UMR_getFirstRefMS()
//						if(IndividualCheck == 1)
//							ValDisplay Display_Recalculated_score value = individualcal()
//							updategraph()
//						endif
						HR2UMR_updateRefMS()
						//print s
						break			
					default:
						// The keyText field requires Igor Pro 7 or later. See Keyboard Events.
						//Printf "Key pressed: %s\r", s.keyText
						break			
				endswitch
				break
		endswitch
	endif
			


//	string info
//	print info
//	if(cmpstr(stringfromlist(0,info,";"), "TABLE:T0") == 0)
//		print info
//	endif
	
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function setTablehook()

	Dowindow/F AMS_MS_Comparisons
	if(V_flag == 1)
		Setwindow AMS_MS_Comparisons, hook(Myhook) = MywindowHook
	endif
		
end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function selectMSwave(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	variable RowforRefMS
	
	SVAR citation1list=root:globals:citation1list
	SVAR mainlist = root:globals:mainlist
	SVAR scorelist = root:globals:scorelist
	SVAR MSname = root:globals:MSname//v3.4D
	
	Wave/T AerosolOrigin=root:database:AerosolOrigin
	Wave/T AerosolPerturbation = root:database:AerosolPerturbation
	Wave/T Analysis = root:database:Analysis
	Wave/T Instrument = root:database:Instrument
	Wave/T Resolution = root:database:Resolution
	Wave/T Vaporizer = root:database:Vaporizer
	Wave/T ShortFileDescriptor = root:database:ShortFileDescriptor
	Wave EIEnergy = root:database:EIEnergy
	Wave VaporizerTempC = root:database:VaporizerTempC
	Wave/T CommentDAQ = root:database:CommentDAQ
	wave/T NonAmbientType = root:database:NonAmbientType
	wave/T CommentNonAmbient = root:Database:CommentNonAmbient
	wave/T PerturbedType = root:Database:PerturbedType
	wave/T CommentPerturbed = root:Database:CommentPerturbed
	wave/T ExperimenterName = root:Database:ExperimenterName
	wave/T GroupStr = root:Database:GroupStr
	wave/T CitationUrl = root:Database:CitationUrl
	wave/T CitationStr = root:Database:CitationStr
	wave/T CitationFigStr = root:Database:CitationFigStr
	wave/T CommentAnalysis = root:Database:CommentAnalysis
	
	wave/T columnlabel = root:database:columnlabel
	wave columnlabel_index = root:database:columnlabel_index
	wave wholewave = root:database:wholewave
	
	if(row >= 0)
		variable index = columnlabel_index[row]
	endif
	

	//print row, event
	if(event == 4) //cell selection
		//variable startTime = dateTime
		citation1list = ""
		citation1list += AerosolOrigin[index]+"|"+AerosolPerturbation[index]+"|"
		citation1list += Analysis[index] + "|" + Instrument[index] +"|"
		citation1list += Resolution[index] + "|" + Vaporizer[index]+"|"
		citation1list += ShortFileDescriptor[index] + "|" + num2str(EIEnergy[index])+"|"
		citation1list += num2str(VaporizerTempC[index]) + "|" + CommentDAQ[index]+"|"		
		citation1list += NonAmbientType[index] + "|" + CommentNonAmbient[index]+"|"	
		citation1list += PerturbedType[index] + "|" + CommentPerturbed[index]+"|"	
		citation1list += ExperimenterName[index] + "|" + GroupStr[index]+"|"	
		citation1list += CitationUrl[index] + "|" + CitationStr[index]+"|"
		citation1list += CitationFigStr[index] + "|" + CommentAnalysis[index]+"|"
	
		variable listNum = ItemsInList(citation1list,"|")
		string separator = "|"
		variable separatorLen = strLen(separator)
		variable offset = 0
		
		setdatafolder root:databasePanel:
		Make/T/O/N=(20,2) citation1Info
		citation1Info[0][0] = "AerosolOrigin", citation1Info[1][0] = "AerosolPerturbation", citation1Info[2][0] = "Analysis"
		citation1Info[3][0] = "Instrument"
		citation1Info[4][0] = "Resolution", citation1Info[5][0] = "Vaporizer", citation1Info[6][0] = "ShortFileDescriptor"
		citation1Info[7][0] = "EI Energy", citation1Info[8][0] = "Vaporizer Temp(C)", citation1Info[9][0]="CommentDAQ"		
		citation1Info[10][0] = "NonAmbient Type", citation1Info[11][0] = "Comment NonAmbient", citation1Info[12][0]="Perturbed Type"
		citation1Info[13][0] = "Comment Perturbed", citation1Info[14][0] = "Experimenter Name", citation1Info[15][0]="Group Str"
		citation1Info[16][0] = "CitationUrl", citation1Info[17][0] = "CitationStr"
		citation1Info[18][0] = "Citation Fig", citation1Info[19][0] = "CommentAnalysis"
		
		variable j
		for(j=0;j<listNum;j+=1)
			//Redimension/N=(1,dimsize(citation1Info,1)+1) citation1Info
			string item = stringFromlist(0,citation1list,separator,offset)
			offset += strlen(item) + separatorLen
			citation1Info[j][1] = item
		endfor
		
		setdatafolder root:databasePanel:
		Make/O/N=(dimsize(wholewave,0)) MS_origin = wholewave[p][row]
		Make/O/N=(dimsize(wholewave,0)) compMS
		Make/O/N=0 score_extracted
		
		variable startTime = datetime
		wave/T columnlabel_extracted = columnlabelExtracted()
		//print "Time to extract the list: "+num2str(datetime-startTime)+"seconds."
		
		variable i 
		
		mainlist = ""
		scorelist = ""
		
		//setdatafolder root:database
		startTime = datetime
		if(dimsize(columnlabel_extracted,0)>0)
			for(i=0;i<dimsize(columnlabel_extracted,0);i+=1)
				mainlist += columnlabel_extracted[i] + ";"
				
				for(j=0;j<dimsize(columnlabel,0);j+=1)
					if(cmpstr(columnlabel_extracted[i],columnlabel[j]) == 0)
						compMS = wholewave[p][j]
						Make/O/N=(dimsize(columnlabel_extracted,0)) score_extracted
						string resultlist = getMSSim(compMS,MS_origin)
						score_extracted[i]=	 str2num(stringfromlist(0,resultlist,";"))//v3.0
						string score_extractedStr = num2str(score_extracted[i])
						scorelist += score_extractedStr + ";"
						break					
					endif					
				endfor
					
			endfor
		endif
		//print "Time to calculate scores when click the list: "+num2str(datetime-startTime)+"seconds."
		
		if(dimsize(score_extracted,0) != 0)
			
			Make/T/O/N=(dimsize(columnlabel_extracted,0)) columnlabel_sort=columnlabel_extracted
			Make/O/N=(dimsize(score_extracted,0)) score_sort=score_extracted
			sort/R score_sort, score_sort, columnlabel_sort
		else
			Redimension/N=1 columnlabel_sort
			columnlabel_sort = "****No selected Comparison Constraints****"
			Redimension/N=1 score_sort
			score_sort = 0
		endif
		
		controlinfo ADB_traceSelection
		variable SampleRow = V_value
		
		if(cmpstr(columnlabel[SampleRow],columnlabel_sort[0]) == 0)
			Deletepoints 0,1,columnlabel_sort
			DeletePoints 0,1,score_sort
		endif
		
		updategraph()
		
		//print dateTime-startTIme
	endif
	
//	Make/O/N = 600 mzvalue=p+1
//	for(i=0;i<600;i+=1)
//		mzvalue[i] = i+1
//	endfor
	
	//updategraph()
	
//setdatafolder root:	
End

Function updateGraphPopMenu(ctrlName,popNum,popStr):PopupMenuControl
	string ctrlName
	variable popNum
	string popStr
	
	updateGraph()

End

Function PopupTheGraph(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	switch(ba.eventCode)
		case 2: //mouse up
	
		case 3:
			popupGraph()	
			
		case -1:
			break
	endswitch
	
	return 0
	

End


Function RemoveTracesFromGraph(windowString)
	string windowString

	string tracesToRemove = tracenamelist(windowString, ";",1)
	variable tracesinlist = itemsinlist(tracesToRemove)
	variable traceIndex
	for(traceIndex = 0; traceIndex< tracesinlist; traceIndex+=1)
		tracesToRemove = tracenamelist(windowString, ";",1)

		string curtrace = stringfromlist(0,tracesToRemove,";")
		Removefromgraph /W =$windowString $curtrace
	endfor

End

Function runIndividualCal(sva) : SetvariableControl
	STRUCT WMSetVariableAction &sva
	
	switch(sva.eventcode)
		case 1:
		case 2:
		case 3:
			//Individualcal()
			ValDisplay Display_Recalculated_score value = individualcal()
			updategraph()
			
			break
		case -1:
			break
	endswitch

End

Function DisplayLimChecks(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
//	string columnlabel_extrctlist  //r001
//	wave score = root:databasepanel:score
//	wave refMS_origin = root:databasePanel:refMS_origin
//	wave score_sort = root:databasePanel:score_sort
//	wave MS_origin = root:databsePanel:MS_origin
//	wave/T columnlabel_extracted = root:databasePanel:columnlabel_extracted
	
	 
	switch(cba.eventCode)
		case 2: // Mouse up, when cba.eventcode = 2
			//variable startTime = dateTime
			Variable check = cba.checked//0 meaning unchecking, 1 meaning checking
			string checkboxname = cba.CtrlName// i.e. db_static_searchLim_Res_ALL
			
			//ExtractSampleType(checked, checkboxname)
			EnableCheckBox(check, checkboxname)//control for 'All' checkbox
			
			//print dateTime-startTime
			
				break
			case -1: // Control being killed
				break
	endswitch

	return 0

End

Function Calculate_score(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			setdatafolder root:databasePanel
			calc_score()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function calc_score()
	wave wholewave = root:database:wholewave
	wave score_extracted = root:databasePanel:score_extracted
	wave/T columnlabel_sort = root:databasepanel:columnlabel_sort
	wave/T columnlabel = root:database:columnlabel
	
	Make/O/N=(dimsize(wholewave,0)) compMS
	Make/O/N=0 score_extracted
	Make/T/O/N=0 columnlabel_extracted
	

	Applycheckbox()
	
			
	if(dimsize(score_extracted,0) != 0)
		Make/T/O/N=(dimsize(columnlabel_extracted,0)) columnlabel_sort=columnlabel_extracted
		Make/O/N=(dimsize(score_extracted,0)) score_sort=score_extracted
		sort/R score_sort, score_sort, columnlabel_sort
		
		controlinfo ADB_traceSelection
		variable SampleRow = V_value
	
		if(cmpstr(columnlabel[SampleRow],columnlabel_sort[0]) == 0)
			Deletepoints 0,1,columnlabel_sort
			DeletePoints 0,1,score_sort
		elseif(cmpstr(columnlabel[SampleRow],columnlabel_sort[1]) == 0)
			Deletepoints 1,1,columnlabel_sort
			Deletepoints 1,1,score_sort
		endif
		
	else
		Redimension/N=1 columnlabel_sort
		columnlabel_sort = "****No selected Comparison Constraints****"
		Redimension/N=1 score_sort
		score_sort = 0
	endif
	

	variable startTime = datetime
	getFirstRefMS()
	//print "Time to get first RefMS: "+ num2str(dateTime-startTime)+"seconds"
	updategraph()

End

Function EnableCheckBox(check, checkboxname)
	variable check
	string checkboxname
	
	if(cmpstr(checkboxname, "db_static_searchLim_Res_ALL") == 0)
		if(check == 0)
			CheckBox db_static_searchLimHRD1 disable=0,value=1 //UMR
			CheckBox db_static_searchLimHRD disable=0,value=1//HR2UMR
			CheckBox db_static_searchLimCOM disable=0,value=1
		else
			CheckBox db_static_searchLimHRD1 disable=2,value=1
			CheckBox db_static_searchLimHRD disable=2,value=1
			CheckBox db_static_searchLimCOM disable=2,value=1
		endif
	elseif(cmpstr(checkboxname,"db_static_searchLim_Inst_ALL") == 0)
		if(check == 0)
			CheckBox db_static_searchLimAQ disable=0,value=1
			CheckBox db_static_searchLimAT disable=0,value=1
			CheckBox db_static_searchLimQAMS disable=0,value=1
			CheckBox db_static_searchLimCAMS disable=0,value=1
			CheckBox db_static_searchLimVHR disable=0,value=1
			CheckBox db_static_searchLimWHR disable=0,value=1
			CheckBox db_static_searchLimLVHR disable=0,value=1
			CheckBox db_static_searchLimLWHR disable=0,value=1
			CheckBox db_static_searchLim_Multiple disable=0,value=1
		else
			CheckBox db_static_searchLimAQ disable=2,value=1
			CheckBox db_static_searchLimAT disable=2,value=1
			CheckBox db_static_searchLimQAMS disable=2,value=1
			CheckBox db_static_searchLimCAMS disable=2,value=1
			CheckBox db_static_searchLimVHR disable=2,value=1
			CheckBox db_static_searchLimWHR disable=2,value=1
			CheckBox db_static_searchLimLVHR disable=2,value=1
			CheckBox db_static_searchLimLWHR disable=2,value=1
			CheckBox db_static_searchLim_Multiple disable=2,value=1
		endif
	endif
End

Function EnableNewMSCheckBox()
	controlInfo Check_NewMS
	variable check = v_value
	controlInfo Check_ExistingMS
	variable check2 = v_value
	
	SVAR MSname = root:Globals:MSname//v3.4D
	
	if(check == 1 && check2 == 1)//When check both of them
		abort "Please select either NewMS or Existing MS"
		if(check == 1)
			
		endif
	elseif(check + check2 == 1)//v2.03 only this line
		if(check == 1)//When select NewMS
			Checkbox Check_ExistingMS disable=2, value=0 //v3.0
			PopupMenu vw_pop_dataDFSel disable=0
			PopupMenu vw_pop_MSSel disable=0
			PopupMenu vw_pop_mzValueSel disable=0
			PopupMenu vw_pop_SpeciesWaveSel disable=0//v2.02
			PopupMenu vw_pop_SpeciesSel disable=0//v2.02
			Button ADB_NewdataCalculateButton disable=0//2.02
			Listbox ADB_traceSelection disable=2
			TitleBox ADB_citationOne disable=2
			Button ADB_citation1 disable=2
			Button ADB_Open_URL1 disable=2
			TitleBox ADB_citationTwo disable=0//v2.03
			Button ADB_citation2 disable=0//v2.03
			Button ADB_Open_URL2 disable=0//v2.03
			MSname = "MyMS"//v3.4D				
//		else
//			PopupMenu vw_pop_dataDFSel disable=2
//			PopupMenu vw_pop_MSSel disable=2
//			PopupMenu vw_pop_mzValueSel disable=2
//			PopupMenu vw_pop_SpeciesWaveSel disable=2//v2.02
//			PopupMenu vw_pop_SpeciesSel disable=2//v2.02
//			Button ADB_NewdataCalculateButton disable=2//2.02
//			Listbox ADB_traceSelection disable=0
//			TitleBox ADB_citationOne disable=0
//			Button ADB_citation1 disable=0
//			Button ADB_Open_URL1 disable=0
//			TitleBox ADB_citationTwo disable=2//v2.03
//			Button ADB_citation2 disable=2//v2.03
//			Button ADB_Open_URL2 disable=2//v2.03			
//		endif
		elseif(check2 == 1) //when select Existing MS
			Checkbox Check_NewMS disable=2, value=0//v3.0
			ListBox ADB_traceSelection disable=0
			TitleBox ADB_citationOne disable=0
			Button ADB_citation1 disable=0
			Button ADB_Open_URL1 disable=0
			TitleBox ADB_citationTwo disable=0//v3.0
			Button ADB_citation2 disable=0//v3.0
			Button ADB_Open_URL2 disable=0//v3.0
			PopupMenu vw_pop_dataDFSel disable=2
			PopupMenu vw_pop_MSSel disable=2
			PopupMenu vw_pop_mzValueSel disable=2
			PopupMenu vw_pop_SpeciesWaveSel disable=2//v3.0
			PopupMenu vw_pop_SpeciesSel disable=2//v3.0
			Button ADB_NewdataCalculateButton disable=2//3.0
//		else
//			ListBox ADB_traceSelection disable=2
//			TitleBox ADB_citationOne disable=2
//			Button ADB_citation1 disable=2
//			Button ADB_Open_URL1 disable=2
//			TitleBox ADB_citationTwo disable=2//v2.03
//			Button ADB_citation2 disable=2//v2.03
//			Button ADB_Open_URL2 disable=2//v2.03	
//			
		endif
	elseif(Check == 0 && check2 == 0)//v2.03
		Checkbox Check_NewMS disable=0//v3.0
		Checkbox Check_ExistingMS disable=0//v3.0
		PopupMenu vw_pop_dataDFSel disable=2
		PopupMenu vw_pop_MSSel disable=2
		PopupMenu vw_pop_mzValueSel disable=2
		PopupMenu vw_pop_SpeciesWaveSel disable=2//v2.02
		PopupMenu vw_pop_SpeciesSel disable=2//v2.02
		Button ADB_NewdataCalculateButton disable=2//2.02
		Listbox ADB_traceSelection disable=2
		TitleBox ADB_citationOne disable=2
		Button ADB_citation1 disable=2
		Button ADB_Open_URL1 disable=2
		TitleBox ADB_citationTwo disable=2//v2.03
		Button ADB_citation2 disable=2//v2.03
		Button ADB_Open_URL2 disable=2//v2.03
	endif
	
End
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function EnableIndvidualCal()
	controlInfo Check_Individual_Cal
	variable check = v_value
	
	if(check == 1)
		setvariable ADB_mzExponent_individual_cal disable = 0
		setvariable ADB_intExponent_individual_cal disable = 0
		setvariable ADB_mzMin_Individual_Calc disable = 0
		setvariable ADB_mzMax_Individual_Calc disable = 0
		Valdisplay Display_Recalculated_score disable= 0
	else
		setvariable ADB_mzExponent_individual_cal disable = 2
		setvariable ADB_intExponent_individual_cal disable = 2
		setvariable ADB_mzMin_Individual_Calc disable = 2
		setvariable ADB_mzMax_Individual_Calc disable = 2
		Valdisplay Display_Recalculated_score disable= 2
	endif
end


Function MassRangeset(sva) : SetvariableControl
	STRUCT WMSetVariableAction &sva
	
	
	switch(sva.eventcode)
		case 1: //mouse up
		case 2: //Enter key
		case 3: //Live update
			wave wholewave = root:database:wholewave  //r001
			wave MS_origin = root:databasePanel:MS_origin
			wave compMS = root:databasePanel:compMS
			wave score_sort = root:databasePanel:score_sort
			wave/T columnlabel_sort = root:databasePanel:columnlabel_sort
			wave/T columnlabel = root:database:columnlabel
			
			SVAR mainlist = root:globals:mainlist
			SVAR scorelist = root:globals:scorelist	
			
		//	//to update recalculate value with the value of whole range/exp change
		//	NVAR mzMin_recalc = root:databasePanel:mzMin_recalc //v2.01
		//	NVAR mzMax_recalc = root:databasePanel:mzMax_recalc //v2.01
		//	NVAR mzexp_recalc = root:databasePanel:mzexp_recalc //v2.01
		//	NVAR intexp_recalc = root:databasePanel:intexp_recalc //v2.01
			
			wave score = root:databasePanel:score
			wave/T columnlabel_extracted = root:databasePanel:columnlabel_extracted
			wave score_extracted = root:databasePanel:score_extracted
			
			//v3.0
			wave HRMS_All = root:databaseHR2UMR:HRMS_All
			SVAR HR2UMR_mainlist = root:globals:HR2UMR_mainlist
			SVAR HR2UMR_scorelist = root:globals:HR2UMR_scorelist
			wave/T HRMS_columnlabel = root:databaseHR2UMR:HRMS_columnlabel
			wave HR2UMR_MS_origin = root:databasePanel:HR2UMR:HR2UMR_MS_origin
			wave HR2UMR_compMS = root:databasePanel:HR2UMR:HR2UMR_compMS
			wave HR2UMR_score_sort = root:databasePanel:HR2UMR:HR2UMR_score_sort

			controlInfo ADB_tabs
			string TabStr = S_value
			
			strswitch (TabStr)
				case "UMR Data Comparison":
					//v2.03
					NVAR mzMin = root:globals:mzMin
					NVAR mzMax = root:globals:mzMax
					NVAR mzMinRe = root:globals:mzMinRe
					NVAR mzMaxRe = root:globals:mzMaxRe
					NVAR mz_exp = root:globals:mz_exp
					NVAR int_exp = root:globals:int_exp
					NVAR mz_expRe = root:globals:mz_expRe
					NVAR int_expRe = root:globals:int_expRe
					////
					controlinfo ADB_traceSelection
					variable row=V_value				
				
					if(mzMin < mzMax)
					setdatafolder root:databasePanel:
					Make/O/N=(dimsize(wholewave,0)) compMS
					Make/O/N=0 score_extracted
					
					mainlist = ""
					scorelist = ""
					
					variable startTime = datetime
					wave/T columnlabel_extracted = columnlabelExtracted()
					//print "Time to extract the list: " + num2str(dateTime-startTime) + " seconds."
					
					startTime = dateTime
					variable i,j 
					setdatafolder root:databasePanel
					if(dimsize(columnlabel_extracted,0)>0)
						for(i=0;i<dimsize(columnlabel_extracted,0);i+=1)
							mainlist += columnlabel_extracted[i] + ";"
							for(j=0;j<dimsize(columnlabel,0);j+=1)
								if(cmpstr(columnlabel_extracted[i],columnlabel[j]) == 0)
									compMS = wholewave[p][j]
									Make/O/N=(dimsize(columnlabel_extracted,0)) score_extracted
									string resultlist = getMSSim(compMS,MS_origin)
									score_extracted[i]=	 str2num(stringfromlist(0,resultlist,";"))
									string score_extractedStr = num2str(score_extracted[i])
									scorelist += score_extractedStr + ";"
								endif
							endfor
								
						endfor
					endif		
					//print "Time to calculate the score: " + num2str(dateTime-startTime) + " seconds."
					
					if(dimsize(score_extracted,0) != 0)
						Make/T/O/N=(dimsize(columnlabel_extracted,0)) columnlabel_sort=columnlabel_extracted
						Make/O/N=(dimsize(score_extracted,0)) score_sort=score_extracted
						sort/R score_sort, score_sort, columnlabel_sort
					else
						Redimension/N=1 columnlabel_sort
						columnlabel_sort = "****No selected Comparison Constraints****"
						Redimension/N=1 score_sort
						score_sort = 0
					endif
					
					controlinfo ADB_traceSelection
					variable SampleRow = V_value
				
					if(cmpstr(columnlabel[SampleRow],columnlabel_sort[0]) == 0)
						Deletepoints 0,1,columnlabel_sort
						DeletePoints 0,1,score_sort
					endif
					
		//			controlInfo ADB_mzMin
		//			mzMin_recalc = V_value //v2.01				
		//			controlInfo ADB_mzMax
		//			mzMax_recalc = V_value //v2.01
		//			controlInfo ADB_mzExponent
		//			mzexp_recalc = V_value //v2.01
		//			controlInfo ADB_intExponent
		//			intexp_recalc = V_value //v2.01
					
					//v2.03
					mzMinRe=mzMin
					mzMaxRe=mzMax
					mz_expRe=mz_exp
					int_expRe=int_exp
					///////
					
					getFirstRefMS()
					updateGraph()
					
					
					elseif(mzMin > mzMax)
						Abort "The value of minimum mz should be less than maximum mz"
					endif
					
					break
					
				case "HR Data Comparison":
					//v3.00
					NVAR HR2UMR_mzMin = root:globals:HR2UMR_mzMin
					NVAR HR2UMR_mzMax = root:globals:HR2UMR_mzMax
					NVAR HR2UMR_mzMinRe = root:globals:HR2UMR_mzMinRe
					NVAR HR2UMR_mzMaxRe = root:globals:HR2UMR_mzMaxRe
					NVAR HR2UMR_mz_exp = root:globals:HR2UMR_mz_exp
					NVAR HR2UMR_int_exp = root:globals:HR2UMR_int_exp
					NVAR HR2UMR_mz_expRe = root:globals:HR2UMR_mz_expRe
					NVAR HR2UMR_int_expRe = root:globals:HR2UMR_int_expRe
					////
					controlinfo HR2UMR_ADB_traceSelection
					row=V_value
				
					if(HR2UMR_mzMin < HR2UMR_mzMax)
						setdatafolder root:databasePanel:HR2UMR
						Make/O/N=(dimsize(HRMS_All,0)) HR2UMR_compMS
						Make/O/N=0 HR2UMR_score_extracted
						
						HR2UMR_mainlist = ""
						HR2UMR_scorelist = ""
						
						//variable startTime = datetime
						wave/T HR2UMR_columnlabel_extracted = columnlabelExtracted()
						//print "Time to extract the list: " + num2str(dateTime-startTime) + " seconds."
						
						startTime = dateTime
						
						setdatafolder root:databasePanel:HR2UMR
						if(dimsize(HR2UMR_columnlabel_extracted,0)>0)
							for(i=0;i<dimsize(HR2UMR_columnlabel_extracted,0);i+=1)
								HR2UMR_mainlist += HR2UMR_columnlabel_extracted[i] + ";"
								for(j=0;j<dimsize(HRMS_columnlabel,0);j+=1)
									if(cmpstr(HR2UMR_columnlabel_extracted[i],HRMS_columnlabel[j]) == 0)
										HR2UMR_compMS = HRMS_All[p][j]
										HR2UMR_genSelHRFamSumMS(j)
										Make/O/N=(dimsize(HR2UMR_columnlabel_extracted,0)) HR2UMR_score_extracted
										resultlist = getMSSim(HR2UMR_compMS,HR2UMR_MS_origin)
										HR2UMR_score_extracted[i]=str2num(stringfromlist(0,resultlist,";"))
										
										string HR2UMR_score_extractedStr = num2str(HR2UMR_score_extracted[i])
										HR2UMR_scorelist += HR2UMR_score_extractedStr + ";"
									endif
								endfor
									
							endfor
						endif		
						//print "Time to calculate the score: " + num2str(dateTime-startTime) + " seconds."
						
						if(dimsize(HR2UMR_score_extracted,0) != 0)
							Make/T/O/N=(dimsize(HR2UMR_columnlabel_extracted,0)) HR2UMR_columnlabel_sort=HR2UMR_columnlabel_extracted
							Make/O/N=(dimsize(HR2UMR_score_extracted,0)) HR2UMR_score_sort=HR2UMR_score_extracted
							sort/R HR2UMR_score_sort, HR2UMR_score_sort, HR2UMR_columnlabel_sort
						else
							Redimension/N=1 HR2UMR_columnlabel_sort
							HR2UMR_columnlabel_sort = "****No selected Comparison Constraints****"
							Redimension/N=1 HR2UMR_score_sort
							HR2UMR_score_sort = 0
						endif
						
						controlinfo HR2UMR_ADB_traceSelection
						SampleRow = V_value
					
						if(cmpstr(HRMS_columnlabel[SampleRow],HR2UMR_columnlabel_sort[0]) == 0)
							Deletepoints 0,1,HR2UMR_columnlabel_sort
							DeletePoints 0,1,HR2UMR_score_sort
						endif
						
						//v3.00
						HR2UMR_mzMinRe=HR2UMR_mzMin
						HR2UMR_mzMaxRe=HR2UMR_mzMax
						HR2UMR_mz_expRe=HR2UMR_mz_exp
						HR2UMR_int_expRe=HR2UMR_int_exp
						///////
						
						HR2UMR_getFirstRefMS()
						HR2UMR_updateMS()
						HR2UMR_updateRefMS()
					
					elseif(HR2UMR_mzMin > HR2UMR_mzMax)
						Abort "The value of minimum mz should be less than maximum mz"
					endif
					break
				default:
					break
			endswitch
			
		case -1: // control being killed
			break
	endswitch
End
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function getCitation2(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	SVAR refMSname = root:Globals:refMSname//v3.4D
	
	//wave citation2Info = root:database:citation2Info
	switch( ba.eventCode )
		case 2: // mouse uP
			
		case 3:
			string tabletitle = "Metadata_Table_UMR_"+refMSname//v3.4D
			DoWindow UMR_table_cit2//v3.4D
			//v3.4D
			if(V_flag==0)
				Edit/W=(40,70,300,550)
				Dowindow/C/T UMR_table_cit2, tabletitle//v3.4D
				AppendtoTable root:databasePanel:citation2Info//v3.4D add Window name
				ModifyTable/W=UMR_table_cit2 title(root:databasePanel:citation2Info)="Metadata"//v3.4G
			elseif(V_flag==1)
				Dowindow/C/T UMR_table_cit2, tabletitle//v3.4D
			endif
				
			break
			
		case -1: // control being killed
			break
	endswitch

	return 0

End
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function getCitation1(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	SVAR MSname=root:Globals:MSname//v3.4D
	
	//wave citation2Info = root:database:citation2Info
	switch( ba.eventCode )
		case 2: // mouse uP
			
		case 3:
			string tabletitle = "Metadata_Table_UMR_"+MSname//v3.4D
			Dowindow/F UMR_table_cit1//v3.4D check if the popup window exists
			//v3.4D
			if(v_flag==0)//if Popup window doesn't exist
				Edit/W=(40,70,300,550)
				Dowindow/C/T UMR_table_cit1, tabletitle
				AppendtoTable root:databasePanel:citation1Info//v3.4D add window name of table
				ModifyTable/W=UMR_table_cit1 title(root:databasePanel:citation1Info) = "Metadata"//v3.4G
			elseif(v_flag==1)//if popup window exists
				Dowindow/C/T UMR_table_cit1, tabletitle
			endif
			//
			break
			
		case -1: // control being killed
			break
	endswitch

	return 0

End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ADB_butt_publication1(ControlName):ButtonControl
	string ControlName
	wave/T citation1info = root:databasePanel:citation1Info
	
	string url1 = citation1Info[16][1]
	
		
	if(cmpstr("N/A",url1)  != 0)
	
		if(itemsinlist(url1,",") == 2) //There are two citation pdf.
			string url1_1 = url1[0,strsearch(url1,",",0)-1]
			
			string url1_2 = url1[strsearch(url1,",",0)+2,strlen(url1)]
		
			browseurl url1_1
			browseurl url1_2
		else
			browseurl url1
		endif
				
	else
		abort "There is no publication."
	endif
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ADB_butt_publication2(ControlName):ButtonControl
	string ControlName
	wave/T citation2info = root:databasePanel:citation2Info
	
	string url2 = citation2Info[16][1]
	
	if(cmpstr("N/A",url2)  != 0)
	
		if(itemsinlist(url2,",") == 2) //There are two citation pdf.
			string url2_1 = url2[0,strsearch(url2,",",0)-1]
			
			string url2_2 = url2[strsearch(url2,",",0)+2,strlen(url2)]
		
			browseurl url2_1
			browseurl url2_2
		else
			browseurl url2
		endif
				
	else
		abort "There is no citation url."
	endif
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ADB_butt_DB_webpages(ControlName): ButtonControl
	string ControlName
	
	browseurl "http://cires1.colorado.edu/jimenez-group/AMSsd/"
	
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function HR2UMRdb_butt_DB_webpages(ControlName): ButtonControl//v3.0
	string ControlName
	
	browseurl "https://cires1.colorado.edu/jimenez-group/HRAMSsd/"
	
End
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function DisplayNewMSChecks(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	switch(cba.eventcode)
		case 2:
		wave/T citation1info = root:databasePanel:citation1Info
		
		EnableNewMSCheckBox()
		
		citation1Info[][1] = ""
		
		break
		
		case -1:
			break
	endswitch
	
	return 0
	
End
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function DisplayExistingMSChecks(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	switch(cba.eventcode)
		case 2:
		
		EnableNewMSCheckBox()
		
		break
		
		case -1:
			break
	endswitch
	
	return 0
	
End
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function DisplayIndividualCalChecks(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	switch(cba.eventcode)
		case 2:
		
		EnableIndvidualCal()
		updategraph()
		
		break
		
		case -1:
			break
	endswitch
	
	return 0
	
End
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function DisplayNewMS_MS(ctrlName,popNum,popStr):PopupMenuControl
	string ctrlName
	Variable popNum
	string popStr
	
	getNewMS_MS()
	getFirstRefMS()
	//updategraph()
	
End
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function SetTagNum(sva) : SetvariableControl
	STRUCT WMSetVariableAction &sva
	wave UMRDB_MS_origin = root:databasePanel:UMRDB_MS_origin
	wave refMS_origin = root:databasePanel:refMS_origin
	wave mzvalue = root:databasePanel:mzvalue
	
	switch(sva.eventcode)
		case 1: //mouse up
		case 2: //Enter key
		case 3: //Live update
			controlInfo ADB_tabs //v3.0 add strswitch statement
			string TabStr = S_value
			
			strswitch (TabStr)
				case "UMR Data Comparison":
					updategraph()
					break
				case "HR Data Comparison":
					break
				case "UMR Database":
					UMRDB_updategraph()
					break
				case "HR Database":					
					break
				default:
					break
			endswitch
				
			break
		case -1: // control being killed
			break
	endswitch
End
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ADB_Butt_DisplayNewMS_MS(CtrlName):ButtonControl
	string ctrlName
	controlInfo ADB_tabs
	string TabStr = S_value
			
	strswitch (TabStr)
		case "UMR Data comparison":
			getNewMS_MS()
			getFirstRefMS()
			//updategraph()
			break
			
		case "HR Data Comparison":
			HR2UMR_getNewMS_MS()
			HR2UMR_UpdateMS()
			HR2UMR_getFirstRefMS()
			
			break
		
		default:
			break
	endswitch
	
	
End

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////GET MS WAVE, refMS WAVE AND CALCULATE SCORE/////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function/WAVE getRefMS(RowforRefMS)
	variable RowforRefMS
	
	
	wave/T columnlabel_sort = root:databasePanel:columnlabel_sort
	wave MS_origin = root:databasePanel:MS_origin
	wave MS_exp = root:databasePanel:MS_exp
	wave MSExpCalc = root:databasePanel:MSExpCalc
	
	Wave/T AerosolOrigin=root:database:AerosolOrigin
	Wave/T AerosolPerturbation = root:database:AerosolPerturbation
	Wave/T Analysis = root:database:Analysis
	Wave/T Instrument = root:database:Instrument
	Wave/T Resolution = root:database:Resolution
	Wave/T Vaporizer = root:database:Vaporizer
	Wave/T ShortFileDescriptor = root:database:ShortFileDescriptor
	Wave EIEnergy = root:database:EIEnergy
	Wave VaporizerTempC = root:database:VaporizerTempC
	Wave/T CommentDAQ = root:database:CommentDAQ
	wave/T NonAmbientType = root:database:NonAmbientType
	wave/T CommentNonAmbient = root:Database:CommentNonAmbient
	wave/T PerturbedType = root:Database:PerturbedType
	wave/T CommentPerturbed = root:Database:CommentPerturbed
	wave/T ExperimenterName = root:Database:ExperimenterName
	wave/T GroupStr = root:Database:GroupStr
	wave/T CitationUrl = root:Database:CitationUrl
	wave/T CitationStr = root:Database:CitationStr
	wave/T CitationFigStr = root:Database:CitationFigStr
	wave/T CommentAnalysis = root:Database:CommentAnalysis
	
	wave/T columnlabel = root:database:columnlabel
	wave columnlabel_index = root:database:columnlabel_index
	wave wholewave = root:database:wholewave
	
	SVAR citation2list=root:globals:citation2list
	SVAR refMSname=root:globals:refMSname//v3.4D
	
	 //Rownumber from hook function - follow columnlabel_sort
	variable i
	
	if(RowforRefMs >= 0)
		string MSname = columnlabel_sort[RowforRefMS] //save selected MS_origin in the table
		refMSname = MSname//v3.4D
		//find refMS_origin corresponding to selected MS_origin in the table
		for(i=0;i<dimsize(columnlabel,0);i+=1)
			if(cmpstr(MSname, columnlabel[i]) == 0)
				Make/O/N=(dimsize(wholewave,0)) refMS_origin = wholewave[p][i]	
				variable index = columnlabel_index[i]
				citation2list = ""
				citation2list += AerosolOrigin[index]+"|"+AerosolPerturbation[index]+"|"
				citation2list += Analysis[index] + "|" + Instrument[index] +"|"
				citation2list += Resolution[index] + "|" + Vaporizer[index]+"|"
				citation2list += ShortFileDescriptor[index] + "|" + num2str(EIEnergy[index])+"|"
				citation2list += num2str(VaporizerTempC[index]) + "|" + CommentDAQ[index]+"|"		
				citation2list += NonAmbientType[index] + "|" + CommentNonAmbient[index]+"|"	
				citation2list += PerturbedType[index] + "|" + CommentPerturbed[index]+"|"	
				citation2list += ExperimenterName[index] + "|" + GroupStr[index]+"|"	
				citation2list += CitationUrl[index] + "|" + CitationStr[index]+"|"
				citation2list += CitationFigStr[index] + "|" + CommentAnalysis[index]+"|"
			endif
		
		endfor
		
		variable listNum = ItemsInList(citation2list,"|")
		string separator = "|"
		variable separatorLen = strLen(separator)
		variable offset = 0
		
		Make/T/O/N=(20,2) citation2Info
		citation2Info[0][0] = "AerosolOrigin", citation2Info[1][0] = "AerosolPerturbation", citation2Info[2][0] = "Analysis"
		citation2Info[3][0] = "Instrument"
		citation2Info[4][0] = "Resolution", citation2Info[5][0] = "Vaporizer", citation2Info[6][0] = "ShortFileDescriptor"
		citation2Info[7][0] = "EI Energy", citation2Info[8][0] = "Vaporizer Temp(C)", citation2Info[9][0]="CommentDAQ"		
		citation2Info[10][0] = "NonAmbient Type", citation2Info[11][0] = "Comment NonAmbient", citation2Info[12][0]="Perturbed Type"
		citation2Info[13][0] = "Comment Perturbed", citation2Info[14][0] = "Experimenter Name", citation2Info[15][0]="Group Str"
		citation2Info[16][0] = "CitationUrl", citation2Info[17][0] = "CitationStr"
		citation2Info[18][0] = "Citation Fig", citation2Info[19][0] = "CommentAnalysis"
		
			
		variable j
		for(j=0;j<listNum;j+=1)
			//Redimension/N=(1,dimsize(citation2Info,1)+1) citation2Info
			string item = stringFromlist(0,citation2list,separator,offset)
			offset += strlen(item) + separatorLen
			citation2Info[j][1] = item
		endfor
		
		//Make/O/N=(dimsize(MS_origin,0)) sampleMSsubRefMS=0
		//Make/O/N=(dimsize(MS_origin,0)) sampleMSsubRefMS_exp=0
		Make/O/N=(dimsize(MS_origin,0)) sampleMSsubRefMSExpCalc = 0
		
		controlInfo ADB_mzMin
		variable mzMin = V_value			
		controlInfo ADB_mzMax
		variable mzMax = V_value
		controlInfo ADB_mzExponent
		variable mzExp = V_value
		controlInfo ADB_intExponent
		variable intExp = V_value

		
		Duplicate/Free/O/R=[mzMin-1,mzMax-1] refMS_origin, refMS_ranged
		Make/O/N=(dimsize(refMS_ranged,0)) refMS_scaled = refMS_ranged[p]^intExp * (mzMin+p)^mzExp
		Make/O/N=600 refMSExpCalc=0
		
		variable refMSSum = sum(refMS_scaled)//v3.4A
		refMS_scaled/=refMSSum//v3.4A
		
		for(i=0;i<dimsize(refMS_scaled,0);i++)
			refMSExpCalc[mzMin+i-1] = refMS_scaled[i]
		endfor
		
//		variable refMSSum = sum(refMSExpCalc)
//		if(refMSSum > 0)
//				refMSExpCalc/=refMSsum
//		endif
		
		for(i=0;i<dimsize(MS_origin,0);i+=1)
			//sampleMSsubRefMS[i] = MS_origin[i] - refMS_origin[i]
			sampleMSsubRefMSExpCalc[i] = MSExpCalc[i] - refMSExpCalc[i]
		endfor
		
		Titlebox/Z ADB_citationTwo, title = MSname
		Dowindow/F UMR_table_cit2//v3.4D
		
		//v3.4D
		if(v_flag==1)
			string tabletitle = "Metadata_Table_UMR_"+MSname
			Dowindow/C/T UMR_table_cit2, tabletitle
		endif
		//
		updateGraph()

	endif
	
	return refMS_origin

End

Function individualCal()
	wave refMS_origin = root:databasePanel:refMS_origin
	wave MS_origin = root:databasePanel:MS_origin
	
	setdatafolder root:databasePanel:
	
	controlInfo ADB_mzExponent_individual_cal
	variable mzExp = V_value
	controlInfo ADB_intExponent_individual_cal
	variable intExp = V_value
	controlInfo ADB_mzMin_individual_Calc
	variable mzMin = V_value
	controlInfo ADB_mzMax_individual_Calc
	variable mzMax = V_value
	
	Duplicate/Free/O/R=[mzMin-1,mzMax-1] MS_origin, MS_RecalcRanged 
	Duplicate/Free/O/R=[mzMin-1,mzMax-1] refMS_origin, refMS_RecalcRanged
	Make/O/T/N=600 textmz = num2str(p+1)

	Make/O/N=(dimsize(refMS_RecalcRanged,0)) refMS_Recalc_scaled = refMS_RecalcRanged[p]^intExp * (mzMin+p)^mzExp
	Make/O/N=(dimsize(MS_RecalcRanged,0)) MS_Recalc_scaled = MS_RecalcRanged[p]^intExp*(mzMin+p)^mzExp
	
	//Make/O/N=(dimsize(MS_RecalcRanged,0)) sampleMSsubRefMS_Recalc_scaled=0

	
	variable i
	
//	for(i=0;i<dimsize(refMS_RecalcRanged,0);i++)
//		MS_Recalc[mzMin+i-1] = MS_RecalcRanged[i]
//		refMS_Recalc[mzMin+i-1] = refMS_RecalcRanged[i]
//	endfor
	
	variable MSSum = sum(MS_Recalc_scaled)//v3.4A
	variable refMSSum = sum(refMS_Recalc_scaled)//v3.4A
	
	//if(MSsum > 0)
		MS_Recalc_scaled /= MSSum//v3.4A
	//endif
	//
	//if(refMSSum > 0)
		refMS_Recalc_scaled/=refMSSum//v3.4A
	//endif
	
	Make/O/N=(dimsize(MS_origin,0)) refMS_Recalc=0
	Make/O/N=(dimsize(MS_origin,0)) MS_Recalc=0
	Make/O/N=(dimsize(MS_origin,0)) sampleMSsubRefMS_Recalc=0
	
	for(i=0;i<dimsize(MS_Recalc_scaled,0);i++)
			refMS_Recalc[mzMin+i-1] = refMS_Recalc_scaled[i]
			MS_Recalc[mzMin+i-1] = MS_Recalc_scaled[i]
			sampleMSsubRefMS_Recalc[mzMin+i-1] = MS_Recalc_scaled[i] - refMS_Recalc_scaled[i]
	endfor
	
	
	variable numerator = MatrixDot(refMS_Recalc,MS_Recalc)
   variable denominator = sqrt(MatrixDot(refMS_Recalc,refMS_Recalc) * MatrixDot(MS_Recalc,MS_Recalc))
   variable result = numerator/denominator

   if(numType(result) == 0)
   		return result
   else
       return 0
   endif
	
	updategraph()
	//ValDisplay Display_Recalculated_score value=result
	
End

Function getNewMS_MS() //for NewMS checkbox
	wave MS_origin = root:databasePanel:MS_origin
	wave wholewave = root:database:wholewave
	wave/T columnlabel = root:database:columnlabel
	
	controlInfo vw_pop_dataDFSel
	string CurrentDF = S_value //It's from data folder popoup menu.
	
	string CurrentPath = "root:" + CurrentDF
	
	controlInfo vw_pop_MSSel
	string SelectedMS = S_value
	string MSpath = CurrentPath + SelectedMS
	wave SelectedWVTemp = $MSpath//v2.02
	
	//v2.03
	controlInfo vw_pop_SpeciesWaveSel
	string SelectedMSname = S_value
	string SpectraNamePath = CurrentPath + SelectedMSname
	wave/T selectedMSnameWV = $SpectraNamePath 
	
	//v2.02
	if(dimsize(selectedWvTemp,1)>1)
		controlInfo vw_pop_SpeciesSel
		string selectedWVname = S_value
		//v2.03
		variable k
		for(k=0;k<dimsize(selectedMSnameWV,0);k++)
			if(cmpstr(selectedMSnameWv[k],selectedWVname) == 0)
				variable index = k
				break
			endif 
		endfor

		variable columnIndex = index
		duplicate/O/RMD=[][columnIndex] SelectedWVTemp, SelectedWV
	else
		wave SelectedWV= $MSpath //  SelectedMV = $MSpath  //r001 typo
	endif
	/////
	controlInfo vw_pop_mzValueSel
	string SelectedAMU = S_value
	string AMUwvpath = CurrentPath + SelectedAMU
	wave selectedAMUwv = $AMUwvPath
	
	Redimension/N=(600,0) MS_origin
	MS_origin = 0
	
	variable j
	
	if(selectedAMUwv[0] == 0)
		for(j=0;j<dimsize(selectedAMUwv,0)-1;j+=1)										
			//setdatafolder root:database
			variable selectedWvSum = sum(SelectedWV)//v3.4A
			MS_origin[j] = SelectedWV[j+1]/selectedWvSum//v3.4A
		endfor
	else
		for(j=0;j<dimsize(selectedAMUwv,0); j+=1) //NOT CONSECUTIVE AMU
			//wave T = $itemwave
			variable unitMass = selectedAMUwv[j]
			selectedWvSum = sum(SelectedWV)//v3.4A
			MS_origin[unitmass-1]=SelectedWV[j]/selectedWvSum//v3.4A
		endfor
	endif
	
	//v2.02
	if(dimsize(selectedWvTemp,1)>1)
		KillWaves selectedWV
	endif
	////
	
	setdatafolder root:databasePanel
	
	Make/O/N=(dimsize(wholewave,0)) compMS
	Make/O/N=0 score_extracted
		
	wave/T columnlabel_extracted = columnlabelExtracted()
		
	variable i 

	if(dimsize(columnlabel_extracted,0)>0)
		for(i=0;i<dimsize(columnlabel_extracted,0);i+=1)
			
			for(j=0;j<dimsize(columnlabel,0);j+=1)
				if(cmpstr(columnlabel_extracted[i],columnlabel[j]) == 0)
					compMS = wholewave[p][j]
					Make/O/N=(dimsize(columnlabel_extracted,0)) score_extracted
					string resultlist = getMSSim(compMS,MS_origin)
					score_extracted[i]= str2num(stringfromlist(0,resultlist,";"))
				endif
			endfor
			
		endfor
	endif
		
	if(dimsize(score_extracted,0) != 0)
		Make/T/O/N=(dimsize(columnlabel_extracted,0)) columnlabel_sort=columnlabel_extracted
		Make/O/N=(dimsize(score_extracted,0)) score_sort=score_extracted
		sort/R score_sort, score_sort, columnlabel_sort
	else
		Redimension/N=1 columnlabel_sort
		columnlabel_sort = "****No selected Comparison Constraints****"
		Redimension/N=1 score_sort
		score_sort = 0
	endif
	
	
	setdatafolder root:databasePanel
End

Function/T getMSSim(compMS,MS_origin)//v3.0 add compostie score

	wave compMS, MS_origin
	//wave MS_origin = root:database:MS_origin
	//wave/T columnlabel_extracted = root:database:columnlabel_extracted
	//wave/T columnlabel = root:database:columnlabel
	
	controlInfo ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)//v3.0 add strswitch statement for HR2UMR data comparison
		case "UMR Data Comparison":
			setdatafolder root:databasePanel
			controlInfo ADB_mzMin
			variable mzMin = V_value
						
			controlInfo ADB_mzMax
			variable mzMax = V_value
			
			variable range = mzMax - mzMin + 1
			
			
			Duplicate/Free/O/R=[mzMin-1,mzMax-1] MS_origin, MS_ranged 			
			//Make/T/Free/O/N=(dimsize(columnlabel,0)) columnlabel_ranged
			//columnlabel_ranged = columnlabel_extracted
			Duplicate/Free/O/R=[mzMin-1,mzMax-1] compMS, compMS_ranged
			
			controlInfo ADB_mzExponent
			variable mzExp = V_value
			controlInfo ADB_intExponent
			variable intExp = V_value
			
		//	//also update recalculation information v2.02
		//	controlInfo ADB_mzExponent_individual_cal
		//	//variable mzExp = V_value
		//	V_value = mzExp
		//	controlInfo ADB_intExponent_individual_cal
		//	//variable intExp = V_value
		//	V_value = intExp
		//	controlInfo ADB_mzMin_individual_Calc
		//	//variable mzMin = V_value
		//	V_value = mzMin
		//	controlInfo ADB_mzMax_individual_Calc
		//	//variable mzMax = V_value 
		//	V_value = mzMax	
		//	ValDisplay Display_Recalculated_score value = individualcal()
			
			
			
			Make/O/T/N=600 textmz = num2str(p+1)
			Make/O/N=(dimsize(compMS_ranged,0)) compMS_scaled = compMS_ranged[p]^intExp * (mzMin+p)^mzExp
			Make/O/N=(dimsize(MS_ranged,0)) MS_scaled = MS_ranged[p]^intExp * (mzMin+p)^mzExp
			//Make/O/N=600 MSExpCalc = MS_origin[p]^intExp * (p)^mzExp
			Make/O/N=600 MSExpCalc
			
			variable compMSSum = sum(compMS_scaled)//v3.4A normalize MS by sum function -> sum variable
			variable MSSum = sum(MS_scaled)//v3.4A
			compMS_scaled = compMS_scaled/compMSSum//v3.4A
			MS_scaled = MS_scaled/MSSum//v3.4A
			
			variable i
			for(i=0;i<dimsize(MS_scaled,0);i++)
				MSExpCalc[mzMin+i-1] = MS_scaled[i]
			endfor
			
		//	variable MSSum = sum(MSExpCalc)
		//	if(MSSum > 0)
		//			MSExpCalc/=MSsum
		//	endif
			
			
		//	variable i
		//	setdatafolder root:database
		//	for(i=0;i<dimsize(sampMS_ranged,0);i+=1)
		//		if(i != row)
		//			Make/O/N=(dimsize(wholewave,0)) compMS = wholewave[p][i]
		//			
		//			Make/O/N=(dimsize(columnlabel_sort,0)) score_ranged
		//			score_ranged[i]=getMSSim(MS_ranged,compMSMS_ranged)
		//		endif
		//	endfor
			
			
		   variable numerator = MatrixDot(compMS_scaled,MS_scaled)
		   variable denominator = sqrt(MatrixDot(compMS_scaled,compMS_scaled) * MatrixDot(MS_scaled,MS_scaled))
		   variable result = numerator/denominator
			
			
			string resultlist = ""
			
		   if(numType(result) == 0)
		   		resultlist += num2str(result) + ";"		   		
		   		//return result
		   else
		   		resultlist += "0;"		   		
		       //return 0
		   endif
		   
		  
		   
		   return resultlist		   
		   
			
			break
			
		case "HR Data Comparison":
			wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
			setdatafolder root:databasePanel:HR2UMR
			
			controlInfo HR2UMR_mzMin
			variable HR2UMR_mzMin = V_value
						
			controlInfo HR2UMR_mzMax
			variable HR2UMR_mzMax = V_value
			
			variable HR2UMR_range = HR2UMR_mzMax - HR2UMR_mzMin + 1
			
			
			Duplicate/Free/O/R=[HR2UMR_mzMin-1,HR2UMR_mzMax-1] MS_origin, HR2UMR_MS_ranged 			
			//Make/T/Free/O/N=(dimsize(columnlabel,0)) columnlabel_ranged
			//columnlabel_ranged = columnlabel_extracted
			Duplicate/Free/O/R=[HR2UMR_mzMin-1,HR2UMR_mzMax-1] compMS, HR2UMR_compMS_ranged
			
			controlInfo HR2UMR_mzExponent
			variable HR2UMR_mzExp = V_value
			controlInfo HR2UMR_intExponent
			variable HR2UMR_intExp = V_value	
			
			Make/O/T/N=600 HR2UMR_textmz = num2str(p+1)
			Make/O/N=(dimsize(HR2UMR_compMS_ranged,0)) HR2UMR_compMS_scaled = HR2UMR_compMS_ranged[p]^HR2UMR_intExp * (HR2UMR_mzMin+p)^HR2UMR_mzExp
			Make/O/N=(dimsize(HR2UMR_MS_ranged,0)) HR2UMR_MS_scaled = HR2UMR_MS_ranged[p]^HR2UMR_intExp * (HR2UMR_mzMin+p)^HR2UMR_mzExp//HR2UMR MS_All
			
			string Hr2UMRMSPath = "root:databasepanel:HR2UMR:HR2UMR_MS_"

			variable k
			for(k=0;k<dimsize(HR_familyName,0);k++)
				string Hr2UMRMSorgn = HR2UMRMSPath+HR_familyName[k]
				string HR2UMRMSwave_scaled = HR2UMRMSPath + HR_familyName[k]+"_ExpCalc"
				string HR2UMRMSwaveName_scaled = "HR2UMR_MS_"+HR_familyName[k]+"_ExpCalc"
				wave HR2UMRMS = $HR2UMRMSorgn
				make/O/N=(600) $HR2UMRMSwaveName_scaled = 0
				wave HR2UMRMS_scaled = $HR2UMRMSwaveName_scaled
				HR2UMRMS_scaled = HR2UMRMS[p]^HR2UMR_intExp * (HR2UMR_mzMin+p)^HR2UMR_mzExp
				variable FamMSSum = sum(HR2UMR_MS_scaled)//v3.4A
				HR2UMRMS_scaled/=FamMSSum//v3.4A
		
			endfor
			
			//Make/O/N=600 MSExpCalc = MS_origin[p]^intExp * (p)^mzExp
			Make/O/N=600 HR2UMR_MSExpCalc
			
			variable HRcompMSSum = sum(HR2UMR_compMS_scaled)//v3.4A
			variable HRMSSum = sum(HR2UMR_MS_scaled)//v3.4A
			HR2UMR_compMS_scaled = HR2UMR_compMS_scaled/HRcompMSSum//v3.4A
			HR2UMR_MS_scaled = HR2UMR_MS_scaled/HRMSSum//v3.4A
			
			
			for(i=0;i<dimsize(HR2UMR_MS_scaled,0);i++)
				HR2UMR_MSExpCalc[HR2UMR_mzMin+i-1] = HR2UMR_MS_scaled[i]
			endfor
			
			variable HR2UMR_MSSum = sum(HR2UMR_MSExpCalc)
			if(HR2UMR_MSSum > 0)
					HR2UMR_MSExpCalc/=HR2UMR_MSsum
			endif
			
			
		   variable HR2UMR_numerator = MatrixDot(HR2UMR_compMS_scaled,HR2UMR_MS_scaled)
		   variable HR2UMR_denominator = sqrt(MatrixDot(HR2UMR_compMS_scaled,HR2UMR_compMS_scaled) * MatrixDot(HR2UMR_MS_scaled,HR2UMR_MS_scaled))
		   variable HR2UMR_result = HR2UMR_numerator/HR2UMR_denominator
			
			string HR2UMR_resultlist = ""
			
		   if(numType(HR2UMR_result) == 0)
		   		HR2UMR_resultlist += num2str(HR2UMR_result) + ";"
		   		//return HR2UMR_result
		   else
		   		HR2UMR_resultlist += "0;"
		   		//return 0
		   endif
		   
		   
		   string HR2UMR_SelHRFamScore = num2str(HR2UMR_calcHRfamilyscore())		   
		   	
//		   	if(str2num(HR2UMR_SelHRFamScore) == 0)
//				print "HRfamScore is 0"
//				HR2UMR_calcHRfamilyscore()
//			endif	
			
		   HR2UMR_resultlist += HR2UMR_SelHRFamScore + ";"
		   
		   return HR2UMR_resultlist
		   
			break
		default:
			break
	endswitch
	
	
	

End

Function getminMz()

	controlInfo/W=AMS_MS_Comparisons ADB_mzMin
	variable mzMin = V_value
	
	return mzMin	
	
End
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function getmaxMz()

	controlInfo/W=AMS_MS_Comparisons ADB_mzMax
	variable mzMax = V_value
	
	return mzMax
	
End

Function getFirstRefMS()
	wave wholewave = root:database:wholewave
	wave/T columnlabel = root:database:columnlabel
	wave/T columnlabel_sort = root:databasePanel:columnlabel_sort
//	wave refMSCalc = root:databasePanel:refMSCalc		//r001
	wave refMS_origin = root:databasePanel:refMS_origin
	wave MS_origin = root:databasePanel:MS_origin  
//	wave sampleMSsubRefMS = root:databasePanel:sampleMSsubRefMS  //r001
//	wave sampleMSsubRefMSExpCalc = root:databasePanel:sampleMSsubRefMSExpCalc  //r001
	wave MSExpCalc = root:databasePanel:MSExpCalc
	
	variable j
	
	for(j=0;j<dimsize(columnlabel,0);j+=1)
		if(cmpstr(columnlabel_sort[0], columnlabel[j]) == 0)
			refMS_origin = wholewave[p][j]
		
		endif
	endfor
	
	controlInfo ADB_mzMin
	variable mzMin = V_value					
	controlInfo ADB_mzMax
	variable mzMax = V_value
	controlInfo ADB_mzExponent
	variable mzExp = V_value
	controlInfo ADB_intExponent
	variable intExp = V_value
	
	Duplicate/Free/O/R=[mzMin-1,mzMax-1] refMS_origin, refMS_ranged
	Make/O/FREE/N=(dimsize(refMS_ranged,0)) refMS_scaled = refMS_ranged[p]^intExp * (mzMin+p)^mzExp
	Make/O/N=600 refMSExpCalc=0
	
	variable refMSSum = sum(refMS_scaled) //v3.4A
	refMS_scaled /= refMSSum//v3.4A
	
	variable i
	
	for(i=0;i<dimsize(refMS_scaled,0);i++)
		refMSExpCalc[mzMin+i-1] = refMS_scaled[i]
	endfor
	
//	variable refMSSum = sum(refMSExpCalc)
//	if(refMSSum > 0)
//			refMSExpCalc/=refMSsum
//	endif
	
	Make/O/N=(dimsize(MSExpCalc,0)) sampleMSsubRefMSExpCalc
	sampleMSsubRefMsExpCalc = MSExpCalc[p] - refMSExpCalc[p]
	
//	for(i=0;i<dimsize(MS_origin,0);i+=1)
//		//sampleMSsubRefMS[i] = MS_origin[i] - refMS_origin[i]
//		sampleMSsubRefMSExpCalc[i] = MSExpCalc[i] - refMSExpCalc[i]
//	endfor

End

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////COLUMNLABEL EXTRACTED AND CHECK CHECKBOX////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function Applycheckbox()
	wave MS_origin = root:databasePanel:MS_origin
	wave compMS = root:databasePanel:compMS
	wave/T columnlabel = root:database:columnlabel
	wave wholewave = root:database:wholewave
	
	SVAR allSpectraList = root:globals:allSpectraList
	SVAR mainlist = root:globals:mainlist
	SVAR indexList = root:globals:indexList
	SVAR scorelist = root:globals:scorelist
	
	string checklist = checkboxlist() //v1.5
	string newlist = ""
	string newIndexList = ""
	string newscorelist = ""
	
	variable i,j
	
	variable startTime = datetime
	for(i=0;i<itemsinlist(checklist);i+=1)
		string item = stringfromlist(i,checklist)
		variable allSpectraIndex = whichListItem(item,allSpectraList,";") 
		if(whichlistitem(item,mainlist) != -1) // item is found in the mainlist
			newlist += item + ";"
			newIndexList += num2str(allSpectraIndex) + ";"
			variable listIndex = whichlistitem(item,mainlist)
			newscorelist += stringfromlist(listIndex,scorelist) + ";"
			
		elseif(whichlistitem(item,mainlist) == -1) // item is not found in the mainlist -> adding to the mainlist and calculation
			newlist += item + ";"
			
//			for(j=0;j<dimsize(columnlabel,0);j+=1)
//				if(cmpstr(item,columnlabel[j]) == 0)
					//compMS = wholewave[p][j]
					compMS = wholewave[p][allSpectraIndex]
					string resultlist = getMSSim(compMS,MS_origin)
					variable score_calc= str2num(stringfromlist(0,resultlist,";"))
					string score_calcStr = num2str(score_calc)
					scorelist += score_calcStr + ";"
					mainlist += item + ";"
					indexList += num2str(allSpectraIndex) + ";"
					newscorelist += score_calcStr + ";"
//					break
//				endif			
//			endfor
		endif
	endfor
	
	setdatafolder root:databasePanel:
	Make/T/O/N=(itemsInlist(newlist)) columnlabel_extracted = stringfromlist(p,newlist)
	Make/O/N=(itemsInlist(newscorelist)) score_extracted = str2num(stringfromlist(p,newscorelist))
	

//	for(i=0;i<itemsInlist(newlist);i+=1)
//		columnlabel_extracted[i] = stringFromList(i,newlist)
//		variable score = str2num(stringFromlist(i,newscorelist))
//		score_extracted[i] = score	
//	endfor

	
	//print "Applycheckbox "
	//print "Time to extract list and calculate scores: "+num2str(dateTime-startTime)+"seconds."
End

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////PANEL DISPLAY(Updategraph, Popupgraph, Enable condition)//////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function updateGraph()
	wave MSExpCalc = root:databasePanel:MSExpCalc
	wave refMSExpCalc = root:databasePanel:refMSExpCalc
	wave mzvalue = root:databasePanel:mzvalue
	wave sampleMSsubRefMSExpCalc = root:databasePanel:sampleMSsubRefMSExpCalc
	wave sampleMSsubRefMS_Recalc = root:databasePanel:sampleMSsubRefMS_Recalc
	wave/T columnlabel_sort = root:databasePanel:columnlabel_sort
	wave/T columnlabel = root:database:columnlabel
	wave/T textmz = root:databasePanel:textmz
	wave MS_Recalc = root:databasePanel:MS_Recalc
	wave refMS_Recalc = root:databasePanel:refMS_Recalc
//	wave W_coef = root:databasePanel:W_coef//v2.01  //r001
//	wave fit_MSExpCalc = root:databasePanel:fit_MSExpCalc//2.01 //r001
//	wave fit_MS_Recalc = root:databasePanel:fit_MS_Recalc//2.01 //r001
	
	//v3.4D
	SVAR MSname = root:Globals:MSname
	SVAR refMSname = root:globals:refMSname
	string graph_Title1 = MSname
	string graph_title2 = refMSname
	string graph_title3 = MSname + " and " + refMSname
	string graph_title4 = MSname + " - " + refMSname
	string graph_title5 = MSname + " vs " + refMSname
	//
	
	string popvalue
	//check plot type with controlInfo of ADB_displayPlot
	controlInfo ADB_displayPlot
	String plotType = S_value
	

	
	controlInfo Check_Individual_Cal
	variable RecalcCheck = v_value
	
	
	//remove existing traces on graph (use traceNameList)
	RemoveTracesFromGraph(MSPLOT)
	
	
	//if/elseif statements to figure out plot type
	if(RecalcCheck == 0)
		variable minMz = getminMz()
		variable maxMz = getmaxMz()
		
		if(dimsize(columnlabel_sort,0) == 1)		
			if(stringmatch(plotType, "Sample MS") == 1)		
				AppendtoGraph/W=$MSPLOT MSExpCalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				variable yaxisMax = wavemax(MSExpCalc, minMz-1, maxMz-1)//v3.4 autoscale y-axis when m/z range was changed
				SetAxis /W=$MSPLOT left 0,yaxisMax//v3.4
				Legend/W=$MSPLOT /K/N=text0
				appendMSTags(MSExpCalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
			else
				RemoveTracesFromGraph(MSPLOT)
			endif
		else
			if(stringmatch(plotType, "Sample MS") == 1)		
				AppendtoGraph/W=$MSPLOT MSExpCalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				yaxisMax = wavemax(MSExpCalc, minMz-1, maxMz-1)//v3.4 autoscale y-axis when m/z range was changed
				SetAxis /W=$MSPLOT left 0,yaxisMax//v3.4
				Legend/W=$MSPLOT /K/N=text0
				appendMSTags(MSExpCalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
			
			elseif(stringmatch(plotType, "Reference MS") == 1)
				AppendtoGraph/W=$MSPLOT refMSExpCalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1, rgb=(0,0,0)
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				yaxisMax = wavemax(refMSExpCalc, minMz-1, maxMz-1)//v3.4 autoscale y-axis when m/z range was changed
				SetAxis /W=$MSPLOT left 0,yaxisMax//v3.4
				Legend/W=$MSPLOT /K/N=text0
				appendMSTags(refMSExpCalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
			
			elseif(stringmatch(plotType, "Sample and Reference MS") == 1)
				AppendtoGraph/W=$MSPLOT MSExpCalc vs mzvalue
				AppendtoGraph/W=$MSPLOT refMSExpCalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				yaxisMax = wavemax(MSExpCalc, minMz-1, maxMz-1)//v3.4 autoscale y-axis when m/z range was changed
				variable yaxisMin = -wavemax(refMSExpCalc,minMz-1,maxMz-1)	//v3.4			
				SetAxis /W=$MSPLOT left yaxisMin,yaxisMax//v3.4
				ModifyGraph/W=$MSPLOT rgb(refMSExpCalc)=(0,0,0)
				ModifyGraph/W=$MSPLOT muloffset(refMSExpCalc)={0,-1}
				Legend/W=$MSPLOT /C/N=text0/J/A=MC "\\s(MSExpCalc) MS\r\\s(refMSExpCalc) refMS\\Z12"
				Legend/W=$MSPLOT /C/N=text0 /X=44.38 /Y=43.78				
				appendMSTags(MSExpCalc,"AMS_MS_Comparisons#G0")
				appendMSTags(refMSExpCalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
		
			elseif(stringmatch(plotType, "Sample MS - Reference MS") == 1)
				AppendtoGraph/W=$MSPLOT sampleMSsubRefMSExpCalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1, rgb=(29524,1,58982)
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				yaxisMax = wavemax(sampleMSsubRefMSExpCalc,minMz-1,maxMz-1)//v3.4
				yaxisMin = waveMin(sampleMSsubRefMSExpCalc,minMz-1,maxMz-1)//v3.4
				SetAxis/W=$MSPLOT left yaxisMin, yaxisMax//v3.4
				Legend/W=$MSPLOT /K/N=text0
				appendMSTags(sampleMSsubRefMSExpCalc,"AMS_MS_Comparisons#G0")
				NegAppendMSTags(sampleMSsubRefMSExpCalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
		
			elseif(stringmatch(plotType, "Sample MS vs Reference MS") == 1)
				AppendtoGraph/W=$MSPLOT MSExpCalc vs refMSExpCalc
				Modifygraph/W=$MSPLOT mode=3, textMarker(MSExpCalc)={textmz,"default",0,0,5,0.00,0.00}, rgb=(0,0,65535)
				Label/W=$MSPLOT bottom "refMS"
				Label/W=$MSPLOT left "Selected MS"
				Legend/W=$MSPLOT /K/N=text0
				Make/O/N=2 OneToOne
				OneToOne[0] = 0
				variable MSmaxValue = waveMax(MSExpCalc)
				variable RefMSmaxValue = waveMax(RefMSExpCalc)
				
				if(MSmaxValue > RefMSmaxValue)
					OneToOne[1] = MSmaxValue
				elseif(RefMSmaxValue > MSmaxValue)
					OneToOne[1] = RefMSmaxValue
				endif
				AppendtoGraph/W=$MSPLOT OneToOne vs OneToOne
				//Legend/W=$MSPLOT /C/N=text0/F=2/G=(0,0,0)/B=(65535,65535,65535) /X=84.34 /Y=-1.01 "1:1 line\\Z14\\k(65535,0,0)\\s(OneToOne)"
				CurveFit/Q/M=2/W=0 line, MSExpCalc/X=refMSExpCalc/D//v2.01
				
				wave W_coef = root:databasePanel:W_coef//v2.01  //r001
				wave fit_MSExpCalc = root:databasePanel:fit_MSExpCalc//2.01 //r001
				fit_MSExpCalc=W_coef[0]+W_coef[1]*x//v2.01
				appendtograph/W=$MSPlot fit_MSExpCalc//v2.01
				Legend/W=$MSPLOT /C/N=text0/J "\\s(OneToOne)\\Z10 1:1 line\\k(65535,0,0)\r\\s(fit_MSExpCalc)\\Z10 Regression"//v2.01
				Legend/W=$MSPLOT /C/N=text0/J/A=LT/X=0.77/Y=0.00//v2.01
				ModifyGraph/W=$MSPLOT lstyle(OnetoOne)=3//v2.01
				TextBox/W=$MSPLOT /C/N=text1/F=0/A=RB/X=73.59/Y=65.15 "\\Z12y="+num2str(W_coef[1])+"x+"+num2str(W_coef[0])+"\rR2 ="+num2str(V_r2)//v2.01
				ModifyGraph/W=$MSPLOT rgb(fit_MSExpCalc)=(21845,21845,21845)//v2.01

				
			endif
		endif	
	elseif(Recalccheck == 1)
		controlinfo ADB_mzMin_Individual_Calc
		minMz = v_value
		controlinfo ADB_mzMax_Individual_Calc
		maxMz = v_value
		
		if(dimsize(columnlabel_sort,0) == 1)		
			if(stringmatch(plotType, "Sample MS") == 1)		
				AppendtoGraph/W=$MSPLOT MS_Recalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				yaxisMax = wavemax(MS_ReCalc, minMz-1, maxMz-1)//v3.4 autoscale y-axis when m/z range was changed
				SetAxis /W=$MSPLOT left 0,yaxisMax//v3.4
				Legend/W=$MSPLOT /K/N=text0
				appendMSTags(MS_Recalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
			else
				RemoveTracesFromGraph(MSPLOT)
			endif
		else
			if(stringmatch(plotType, "Sample MS") == 1)		
				AppendtoGraph/W=$MSPLOT MS_Recalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				yaxisMax = wavemax(MS_ReCalc, minMz-1, maxMz-1)//v3.4 autoscale y-axis when m/z range was changed
				SetAxis /W=$MSPLOT left 0,yaxisMax//v3.4
				Legend/W=$MSPLOT /K/N=text0
				appendMSTags(MS_Recalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
			
			elseif(stringmatch(plotType, "Reference MS") == 1)
				AppendtoGraph/W=$MSPLOT refMS_Recalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1, rgb=(0,0,0)
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				yaxisMax = wavemax(refMS_ReCalc, minMz-1, maxMz-1)//v3.4 autoscale y-axis when m/z range was changed
				SetAxis /W=$MSPLOT left 0,yaxisMax//v3.4
				Legend/W=$MSPLOT /K/N=text0
				appendMSTags(refMS_Recalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
			
			elseif(stringmatch(plotType, "Sample and Reference MS") == 1)
				AppendtoGraph/W=$MSPLOT MS_Recalc vs mzvalue
				AppendtoGraph/W=$MSPLOT refMS_Recalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				yaxisMax = wavemax(MS_ReCalc, minMz-1, maxMz-1)//v3.4 autoscale y-axis when m/z range was changed
				yaxisMin = -wavemax(refMS_ReCalc,minMz-1,maxMz-1)	//v3.4			
				SetAxis /W=$MSPLOT left yaxisMin,yaxisMax//v3.4
				ModifyGraph/W=$MSPLOT rgb(refMS_Recalc)=(0,0,0)
				Legend/W=$MSPLOT /C/N=text0/J/A=MC "\\s(MS_Recalc) MS\r\\s(refMS_Recalc) refMS\\Z12"
				Legend/W=$MSPLOT /C/N=text0 /X=44.38 /Y=43.78
				ModifyGraph/W=$MSPLOT muloffset(refMS_Recalc)={0,-1}
				appendMSTags(MS_Recalc,"AMS_MS_Comparisons#G0")
				appendMSTags(refMS_Recalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
		
			elseif(stringmatch(plotType, "Sample MS - Reference MS") == 1)
				AppendtoGraph/W=$MSPLOT sampleMSsubrefMS_Recalc vs mzvalue
				Modifygraph/W=$MSPLOT mode=1, rgb=(29524,1,58982)
				Label/W=$MSPLOT bottom "m/z"
				Label/W=$MSPLOT left "Relative Abundance"
				SetAxis/W=$MSPLOT bottom minMz, maxMz
				yaxisMax = wavemax(sampleMSsubrefMS_Recalc,minMz-1,maxMz-1)//v3.4
				yaxisMin = waveMin(sampleMSsubrefMS_Recalc,minMz-1,maxMz-1)//v3.4
				SetAxis/W=$MSPLOT left yaxisMin, yaxisMax//v3.4
				Legend/W=$MSPLOT /K/N=text0
				appendMSTags(sampleMSsubrefMS_Recalc,"AMS_MS_Comparisons#G0")
				NegAppendMSTags(sampleMSsubrefMS_Recalc,"AMS_MS_Comparisons#G0")
				TextBox/W=$MSPLOT /K/N=text1//2.01
		
			elseif(stringmatch(plotType, "Sample MS vs Reference MS") == 1)
				AppendtoGraph/W=$MSPLOT MS_Recalc vs refMS_Recalc
				Modifygraph/W=$MSPLOT mode=3, textMarker(MS_Recalc)={textmz,"default",0,0,5,0.00,0.00}, rgb=(0,0,65535)
				Label/W=$MSPLOT bottom "refMS"
				Label/W=$MSPLOT left "Selected MS"
				Legend/W=$MSPLOT /K/N=text0
				Make/O/N=2 OneToOne
				OneToOne[0] = 0
				MSmaxValue = waveMax(MS_Recalc)
				RefMSmaxValue = waveMax(refMS_Recalc)
				
				if(MSmaxValue > RefMSmaxValue)
					OneToOne[1] = MSmaxValue
				elseif(RefMSmaxValue > MSmaxValue)
					OneToOne[1] = RefMSmaxValue
				endif
				AppendtoGraph/W=$MSPLOT OneToOne vs OneToOne
				//Legend/W=$MSPLOT /C/N=text0/F=2/G=(0,0,0)/B=(65535,65535,65535) /X=84.34 /Y=-1.01 "1:1 line\\Z14\\k(65535,0,0)\\s(OneToOne)"
				CurveFit/Q/M=2/W=0 line, MS_ReCalc/X=refMS_Recalc/D//v2.01

				wave W_coef = root:databasePanel:W_coef//v2.01  //r001
				wave fit_MS_Recalc = root:databasePanel:fit_MS_Recalc//2.01 //r001
				fit_MS_Recalc=W_coef[0]+W_coef[1]*x//v2.01
				appendtograph/W=$MSPlot fit_MS_ReCalc//v2.01
				Legend/W=$MSPLOT /C/N=text0/J "\\s(OneToOne)\\Z10 1:1 line\\k(65535,0,0)\r\\s(fit_MS_ReCalc)\\Z10 Regression"//v2.01
				Legend/W=$MSPLOT /C/N=text0/J/A=LT/X=0.77/Y=0.00//v2.01
				ModifyGraph/W=$MSPLOT lstyle(OnetoOne)=3//v2.01
				TextBox/W=$MSPLOT /C/N=text1/F=0/A=RB/X=73.59/Y=65.15 "\\Z12y="+num2str(W_coef[1])+"x+"+num2str(W_coef[0])+"\rR2 ="+num2str(V_r2)//v2.01
				ModifyGraph/W=$MSPLOT rgb(fit_MS_ReCalc)=(21845,21845,21845)//v2.01
				
			endif
		endif

	endif
	controlinfo ADB_traceSelection
	variable SampleRow = V_value
	Titlebox ADB_citationOne, title = columnlabel[SampleRow]
	MSname = columnlabel[SampleRow]//v3.4D
	
	//v3.4D
	Dowindow/F UMR_table_cit1
	if(v_flag==1)
		string tabletitle = "Metadata_Table_UMR_"+MSname
		Dowindow/C/T UMR_table_cit1, tabletitle
	endif
	
	//v3.4D
	SVAR MSname = root:Globals:MSname
	SVAR refMSname = root:Globals:refMSname
	
	Dowindow/F UMR_graph1
	if(V_flag==1)
		Dowindow/T UMR_graph1, Graph_title1
	endif
	
	Dowindow/F UMR_graph2
	if(V_flag==1)
		Dowindow/T UMR_graph2, Graph_title2
	endif
	
	Dowindow/F UMR_graph3
	if(V_flag==1)
		Dowindow/T UMR_graph3, Graph_title3
	endif
	
	Dowindow/F UMR_graph4
	if(V_flag==1)
		Dowindow/T UMR_graph4, Graph_title4
	endif
	
	Dowindow/F UMR_graph5
	if(V_flag==1)
		Dowindow/T UMR_graph5, Graph_title5
	endif


	//
	//
	
	//add appropriate waves to graph
	//AppendToGraph/W=$"AMS_MS_Comparisons#G0" MS
	
	//set mode to 1 
	//ModifyGraph mode=1
	//make graph pretty
	//Label bottom "m/z"


End

Function popupGraph()
	wave MSExpCalc = root:databasePanel:MSExpCalc
	wave refMSExpCalc = root:databasePanel:refMSExpCalc
	wave mzvalue = root:databasePanel:mzvalue
	wave sampleMSsubRefMSExpCalc = root:databasePanel:sampleMSsubRefMSExpCalc
	wave sampleMSsubRefMS_Recalc = root:databasePanel:sampleMSsubRefMS_Recalc
	wave/T columnlabel_sort = root:databasePanel:columnlabel_sort
	wave/T columnlabel = root:database:columnlabel
	wave/T textmz = root:databasePanel:textmz
	wave MS_Recalc = root:databasePanel:MS_Recalc
	wave refMS_Recalc = root:databasePanel:refMS_Recalc
//	wave fit_MS_Recalc = root:databasePanel:fit_MS_Recalc//2.01 //r001
//	wave fit_MSExpCalc = root:databasePanel:fit_MSExpCalc//2.01 //r001
//	wave W_coef = root:databasePanel:W_coef//v2.01  //r001
	
	//v3.4D
	SVAR MSname = root:Globals:MSname
	SVAR refMSname = root:Globals:refMSname
	string graph_Title1 = MSname
	string graph_title2 = refMSname
	string graph_title3 = MSname + " and " + refMSname
	string graph_title4 = MSname + " - " + refMSname
	string graph_title5 = MSname + " vs " +refMSname 
	//
	
	
	string popvalue
	//check plot type with controlInfo of ADB_displayPlot
	controlInfo/W=AMS_MS_Comparisons ADB_displayPlot
	String plotType = S_value
		

	
	//remove existing traces on graph (use traceNameList)
	//RemoveTracesFromGraph(MSPLOT)
	controlInfo Check_Individual_cal
	variable ExponentCheck = v_value
	
	
	//if/elseif statements to figure out plot type
	if(ExponentCheck == 0)
		variable minMz = getminMz()
		variable maxMz = getmaxMz()
		
		if(dimsize(columnlabel_sort,0) == 1)		
			if(stringmatch(plotType, "Sample MS") == 1)	
				//v3.4D
				Dowindow/F UMR_graph1
				if(V_flag==0)	
					Display/N=UMR_graph1 MSExpCalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph1, graph_title1
				elseif(V_flag==1)
					Dowindow/T UMR_graph1, graph_title1
				endif
				//
				Modifygraph mode=1
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				Legend /K/N=text0
				appendMSTags(MSExpCalc,"pop")
				TextBox/K/N=text1//2.01
			else
				RemoveTracesFromGraph(MSPLOT)
			endif
		else
			if(stringmatch(plotType, "Sample MS") == 1)	
				//v3.4D	
				Dowindow/F UMR_graph1
				if(V_flag==0)	
					Display/N=UMR_graph1 MSExpCalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph1, graph_title1
				elseif(V_flag==1)
					Dowindow/T UMR_graph1, graph_title1
				endif
				//
				Modifygraph mode=1
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				Legend /K/N=text0
				appendMSTags(MSExpCalc,"pop")	
				TextBox/K/N=text1//2.01
			
			elseif(stringmatch(plotType, "Reference MS") == 1)
				//v3.4D	
				Dowindow/F UMR_graph2
				if(V_flag==0)	
					Display/N=UMR_graph2 refMSExpCalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph2, graph_title2
				elseif(V_flag==1)
					Dowindow/T UMR_graph2, graph_title2
				endif
				//
				Modifygraph mode=1, rgb=(0,0,0)
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				Legend /K/N=text0
				appendMSTags(refMSExpCalc,"pop")	
				TextBox/K/N=text1//2.01		
			
			elseif(stringmatch(plotType, "Sample and Reference MS") == 1)//graph 3
				//v3.4D	
				Dowindow/F UMR_graph3
				if(V_flag==0)	
					Display/N=UMR_graph3 MSExpCalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph3, graph_title3
				elseif(V_flag==1)
					Dowindow/T UMR_graph3, graph_title3
				endif
				//
				AppendtoGraph refMSExpCalc vs mzvalue
				Modifygraph mode=1
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				ModifyGraph rgb(refMSExpCalc)=(0,0,0)
				Legend /C/N=text0/J/A=MC "\\s(MSExpCalc) MS\r\\s(refMSExpCalc) refMS\\Z12"
				Legend /C/N=text0 /X=44.38 /Y=43.78
				ModifyGraph muloffset(refMSExpCalc)={0,-1}
				appendMSTags(MSExpCalc,"pop")
				appendMSTags(refMSExpCalc,"pop")
				TextBox/K/N=text1//2.01
		
			elseif(stringmatch(plotType, "Sample MS - Reference MS") == 1)
				//v3.4D	
				Dowindow/F UMR_graph4
				if(V_flag==0)	
					Display/N=UMR_graph4 sampleMSsubRefMSExpCalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph4, graph_title4
				elseif(V_flag==1)
					Dowindow/T UMR_graph4, graph_title4
				endif
				//
				Modifygraph mode=1, rgb=(29524,1,58982)
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				Legend /K/N=text0
				appendMSTags(sampleMSsubRefMSExpCalc,"pop")
				NegAppendMSTags(sampleMSsubRefMSExpCalc,"pop")
				TextBox/K/N=text1//2.01
		
			elseif(stringmatch(plotType, "Sample MS vs Reference MS") == 1)
				//v3.4D	
				Dowindow/F UMR_graph5
				if(V_flag==0)	
					Display/N=UMR_graph5 MSExpCalc vs refMSExpCalc//v3.4D add window name
					Dowindow/T UMR_graph5, graph_title5
				elseif(V_flag==1)
					Dowindow/T UMR_graph5, graph_title5
				endif
				//		
				Modifygraph mode=3, textMarker(MSExpCalc)={textmz,"default",0,0,5,0.00,0.00}, rgb=(0,0,65535)
				Label bottom "refMS"
				Label left "Selected MS"
				Legend /K/N=text0
				Make/O/N=2 OneToOne
				OneToOne[0] = 0
				variable MSmaxValue = waveMax(MSExpCalc)
				variable RefMSmaxValue = waveMax(RefMSExpCalc)
				
				if(MSmaxValue > RefMSmaxValue)
					OneToOne[1] = MSmaxValue
				elseif(RefMSmaxValue > MSmaxValue)
					OneToOne[1] = RefMSmaxValue
				endif
				AppendtoGraph OneToOne vs OneToOne
				//Legend /C/N=text0/F=2/G=(0,0,0)/B=(65535,65535,65535) /X=84.34 /Y=-1.01 "1:1 line\\Z14\\k(65535,0,0)\\s(OneToOne)"
				CurveFit/Q/M=2/W=0 line, MSExpCalc/X=refMSExpCalc/D//v2.01

				wave W_coef = root:databasePanel:W_coef//v2.01  //r001
				wave fit_MSExpCalc = root:databasePanel:fit_MSExpCalc//2.01 //r001
				fit_MSExpCalc=W_coef[0]+W_coef[1]*x//v2.01
				//appendtograph fit_MSExpCalc//v2.01
				Legend /C/N=text0/J "\\s(OneToOne)\\Z10 1:1 line\\k(65535,0,0)\r\\s(fit_MSExpCalc)\\Z10 Regression"//v2.01
				Legend /C/N=text0/J/A=LT/X=0.77/Y=0.00//v2.01
				ModifyGraph lstyle(OnetoOne)=3//v2.01
				TextBox /C/N=text1/F=0/A=RB/X=73.59/Y=65.15 "\\Z10y="+num2str(W_coef[1])+"x+"+num2str(W_coef[0])+"\rR2 ="+num2str(V_r2)//v2.01
				TextBox/C/N=text1/X=2.68/Y=0.90//v2.01
				ModifyGraph rgb(fit_MSExpCalc)=(21845,21845,21845)//v2.01
				
			endif
		endif
	elseif(ExponentCheck == 1)	
		controlinfo ADB_mzMin_Individual_Calc
		minMz = v_value
		controlinfo ADB_mzMax_Individual_Calc
		maxMz = v_value
		
		if(dimsize(columnlabel_sort,0) == 1)		
			if(stringmatch(plotType, "Sample MS") == 1)
				//v3.4D
				Dowindow/F UMR_graph1
				if(V_flag==0)	
					Display/N=UMR_graph1 MS_Recalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph1, graph_title1
				elseif(V_flag==1)
					Dowindow/T UMR_graph1, graph_title1
				endif
				//		
				//Display MS_Recalc vs mzvalue
				Modifygraph mode=1
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				Legend /K/N=text0
				appendMSTags(MS_Recalc,"pop")
				TextBox/K/N=text1//2.01
			else
				RemoveTracesFromGraph(MSPLOT)
			endif
		else
			if(stringmatch(plotType, "Sample MS") == 1)
				//v3.4D
				Dowindow/F UMR_graph1
				if(V_flag==0)	
					Display/N=UMR_graph1 MS_Recalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph1, graph_title1
				elseif(V_flag==1)
					Dowindow/T UMR_graph1, graph_title1
				endif
				//	
				//Display MS_Recalc vs mzvalue
				Modifygraph mode=1
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				Legend /K/N=text0
				appendMSTags(MS_Recalc,"pop")
				TextBox/K/N=text1//2.01
			
			elseif(stringmatch(plotType, "Reference MS") == 1)
				//v3.4D	
				Dowindow/F UMR_graph2
				if(V_flag==0)	
					Display/N=UMR_graph2 refMS_ReCalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph2, graph_title2
				elseif(V_flag==1)
					Dowindow/T UMR_graph2, graph_title2
				endif
				//			
				//Display refMS_Recalc vs mzvalue
				Modifygraph mode=1, rgb=(0,0,0)
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				Legend /K/N=text0
				appendMSTags(refMS_Recalc,"pop")
				TextBox/K/N=text1//2.01
			
			elseif(stringmatch(plotType, "Sample and Reference MS") == 1)
				//v3.4D	
				Dowindow/F UMR_graph3
				if(V_flag==0)	
					Display/N=UMR_graph3 MS_ReCalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph3, graph_title3
				elseif(V_flag==1)
					Dowindow/T UMR_graph3, graph_title3
				endif
				//			
				//Display MS_Recalc vs mzvalue
				Appendtograph refMS_Recalc vs mzvalue
				Modifygraph mode=1
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				ModifyGraph rgb(refMS_Recalc)=(0,0,0)
				Legend /C/N=text0/J/A=MC "\\s(MS_Recalc) MS\r\\s(refMS_Recalc) refMS\\Z12"
				Legend /C/N=text0 /X=44.38 /Y=43.78
				appendMSTags(MS_Recalc,"pop")
				appendMSTags(refMS_Recalc,"pop")
				TextBox/K/N=text1//2.01
		
			elseif(stringmatch(plotType, "Sample MS - Reference MS") == 1)
				//v3.4D	
				Dowindow/F UMR_graph4
				if(V_flag==0)	
					Display/N=UMR_graph4 sampleMSsubRefMS_ReCalc vs mzvalue//v3.4D add window name
					Dowindow/T UMR_graph4, graph_title4
				elseif(V_flag==1)
					Dowindow/T UMR_graph4, graph_title4
				endif
				//			
				//Display sampleMSsubRefMS_Recalc vs mzvalue
				Modifygraph mode=1, rgb=(29524,1,58982)
				Label bottom "m/z"
				Label left "Relative Abundance"
				SetAxis bottom minMz, maxMz
				Legend /K/N=text0
				appendMSTags(sampleMSsubRefMS_Recalc,"pop")
				NegAppendMSTags(sampleMSsubRefMS_Recalc,"pop")
				TextBox/K/N=text1//2.01
		
			elseif(stringmatch(plotType, "Sample MS vs Reference MS") == 1)
				//v3.4D	
				Dowindow/F UMR_graph5
				if(V_flag==0)	
					Display/N=UMR_graph5 MS_ReCalc vs refMSExpCalc//v3.4D add window name
					Dowindow/T UMR_graph5, graph_title5
				elseif(V_flag==1)
					Dowindow/T UMR_graph5, graph_title5
				endif
				//
				//Display MS_Recalc vs refMS_Recalc
				Modifygraph mode=3, textMarker(MS_Recalc)={textmz,"default",0,0,5,0.00,0.00}, rgb=(0,0,65535)
				Label bottom "refMS"
				Label left "Selected MS"
				Legend /K/N=text0
				Make/O/N=2 OneToOne
				OneToOne[0] = 0
				MSmaxValue = waveMax(MS_Recalc)
				RefMSmaxValue = waveMax(RefMS_Recalc)
				
				if(MSmaxValue > RefMSmaxValue)
					OneToOne[1] = MSmaxValue
				elseif(RefMSmaxValue > MSmaxValue)
					OneToOne[1] = RefMSmaxValue
				endif
				AppendtoGraph OneToOne vs OneToOne
				//Legend /C/N=text0/F=2/G=(0,0,0)/B=(65535,65535,65535) /X=84.34 /Y=-1.01 "1:1 line\\Z14\\k(65535,0,0)\\s(OneToOne)"
				CurveFit/Q/M=2/W=0 line, MS_ReCalc/X=refMS_Recalc/D//v2.01

				wave W_coef = root:databasePanel:W_coef//v2.01  //r001
				wave fit_MS_Recalc = root:databasePanel:fit_MS_Recalc//2.01  //r001
				fit_MS_Recalc=W_coef[0]+W_coef[1]*x//v2.01
				//appendtograph fit_MS_ReCalc//v2.01
				Legend /C/N=text0/J "\\s(OneToOne)\\Z10 1:1 line\\k(65535,0,0)\r\\s(fit_MS_ReCalc)\\Z10 Regression"//v2.01
				Legend /C/N=text0/J/A=LT/X=0.77/Y=0.00//v2.01
				ModifyGraph lstyle(OnetoOne)=3//v2.01
				TextBox /C/N=text1/F=0/A=RB/X=73.59/Y=65.15 "\\Z10y="+num2str(W_coef[1])+"x+"+num2str(W_coef[0])+"\rR2 ="+num2str(V_r2)//v2.01
				TextBox/C/N=text1/X=2.68/Y=0.90//2.01
				ModifyGraph rgb(fit_MS_ReCalc)=(21845,21845,21845)//v2.01
				
				
			endif
		endif

	
	endif

End


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////MS_origin TAGS//////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function/S gen_dataFolderList_wCurrDF(CurrentDF) //for selection of new MS_origin
	string CurrentDF //"root:"
	
	string existingDFName, existingDFList=""
	variable index

	setDataFolder $CurrentDF

	// make list of DFs in root:, since I can't find a command to do this
	
	index=0
	do
		existingDFName = GetIndexedObjName("root:", 4, index)
		if (strlen(existingDFName) == 0) // no more DFs
			break
//		elseif(WhichListItem(existingDFName, BAD_DATA_FOLDER_LIST)>=0  )		//3.00C
//			index += 1
//			continue
		else
//		if (!stringmatch("pmf_Plot_globals", existingDFName) )
			existingDFName += ":" // need trailing : for paths to work
			existingDFList = AddListItem(existingDFName, existingDFList) // add DF to list
		endif
		index += 1
	while(1)

	// put the list in alphabetical order, 4 = case insensitive
	existingDFList = sortlist(existingDFList, ";", 4)
	
	// put the current DataFolder at the top of the list and return list
	existingDFList = AddListItem(currentDF,existingDFList)

	return(existingDFList)
	
End
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function/S gen_dataWaveList_wCurrDF() //for selection of new MS_origin
	controlInfo ADB_tabs
	string TabStr = S_value
			
	strswitch (TabStr)
		case "UMR Data comparison":
			controlInfo vw_pop_dataDFSel
			break
			
		case "HR Data Comparison":
			controlInfo HR2UMR_vw_pop_dataDFSel
			break
		
		default:
			break
	endswitch
	
	string CurrentDF = S_value //It's from data folder popoup menu.
	
	string existingWVName, existingWVList=""
	variable index
	
	string CurrentPath = "root:" + CurrentDF

	setDataFolder $CurrentPath

	// make list of DFs in root:, since I can't find a command to do this
	
	index=0
	do
		existingWVName = GetIndexedObjName(":", 1, index)
		if (strlen(existingWVName) == 0) // no more DFs
			break
//		elseif(WhichListItem(existingDFName, BAD_DATA_FOLDER_LIST)>=0  )		//3.00C
//			index += 1
//			continue
		else
//		if (!stringmatch("pmf_Plot_globals", existingDFName) )
			//existingWVName += ":" // need trailing : for paths to work
			existingWVList = AddListItem(existingWVName, existingWVList) // add DF to list
		endif
		index += 1
	while(1)

	// put the list in alphabetical order, 4 = case insensitive
	existingWVList = sortlist(existingWVList, ";", 4)
	//print existingWVList
	// put the current DataFolder at the top of the list and return list
	existingWVList = AddListItem(currentDF,existingWVList)

	return(existingWVList)
	
End
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function/S gen_datamzWaveList() //for selection of new MS_origin
	controlInfo ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)
		case "UMR Data comparison":
			controlInfo vw_pop_dataDFSel
			string CurrentDF = S_value //It's from data folder popoup menu.
			
			controlInfo vw_pop_MSSel
			string SelectedMS = S_value

			break
			
		case "HR Data Comparison":
			controlInfo HR2UMR_vw_pop_dataDFSel
			CurrentDF = S_value //It's from data folder popoup menu.
			
			controlInfo HR2UMR_vw_pop_MSSel
			SelectedMS = S_value
			break
		
		default:
			break
	endswitch
	
		
	string existingWVName, existingWVList=""
	variable index
	string CurrentPath = "root:" + CurrentDF
	
	string MSpath = CurrentPath + SelectedMS
	wave SelectedWV = $MSpath
	
	
	
	setDataFolder $CurrentPath

	// make list of DFs in root:, since I can't find a command to do this
	
	index=0
	do
		existingWVName = GetIndexedObjName(":", 1, index)
		string existingWVpath = CurrentPath + existingWVName
		wave existingWV = $existingWVpath
		if (strlen(existingWVName) == 0) // no more DFs
			break
//		elseif(WhichListItem(existingDFName, BAD_DATA_FOLDER_LIST)>=0  )		//3.00C
//			index += 1
//			continue
		else
			if (!stringmatch(existingWVName, SelectedMS) && dimsize(existingWV,0) == dimsize(SelectedWV,0) )
			//existingWVName += ":" // need trailing : for paths to work
				existingWVList = AddListItem(existingWVName, existingWVList) // add DF to list
			endif
		endif
		index += 1
	while(1)

	// put the list in alphabetical order, 4 = case insensitive
	existingWVList = sortlist(existingWVList, ";", 4)
	//print existingWVList
	// put the current DataFolder at the top of the list and return list
	//existingWVList = AddListItem(currentDF,existingWVList)
	//print existingWVList
	return(existingWVList)
	
End
//v2.02
Function/S gen_newdataSpeciesList() //for selection of spectra Name wave
	controlInfo ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)
		case "UMR Data comparison":
			controlInfo vw_pop_dataDFSel //data folder selection
			string CurrentDF = S_value
			controlInfo vw_pop_SpeciesWaveSel //Spectra name wave selection
			string SelectedMS = S_value //Name usually would be "SpectraName"
			
			break
			
		case "HR Data Comparison":
			controlInfo HR2UMR_vw_pop_dataDFSel //data folder selection
			CurrentDF = S_value
			controlInfo HR2UMR_vw_pop_SpeciesWaveSel //Spectra name wave selection
			SelectedMS = S_value //Name usually would be "SpectraName"
			break
		
		default:
			break
	endswitch
	
	
	 //It's from data folder popoup menu.
	
	string existingWVName, existingWVList=""
	variable index
	string CurrentPath = "root:" + CurrentDF //save file path of selected data folder for New MS
	
	
	string SpeciesNamepath = CurrentPath + SelectedMS //ex) root:A_NP_Dec_AT_UMR_S_myPMF:SpectraName
	wave/T SelectedWV = $SpeciesNamepath
	
	string existingSpeciesName, existingSpeciesList=""
	variable i
	
	if(dimsize(selectedWv,0) > 1)//when selected spectra wave includes several spectra
		for(i=0;i<dimsize(selectedWV,0);i++)
			existingSpeciesName = selectedWv[i]//num2str(i+1) + "_"+ selectedWv[i] //210916
			existingSpeciesList = AddListItem(existingSpeciesName, existingSpeciesList,";")
		endfor
	else	
		existingSpeciesList=selectedWv[0]  //r001
	endif
	
	//existingSpeciesList = sortlist(existingSpeciesList, ";", 4) //210916
	return(existingSpeciesList)
	
End

Function appendMSTags(SelectedMS, windowStr)
	wave selectedMS
	string windowStr
	//string windowStr = "AMS_MS_Comparisons#G0"
	
	//string oneOrTwoStr = MSStr[strLen(MSStr)-1]
	//wave MS_origin = root:database:MS_origin
	wave mzValues = root:databasePanel:mzvalue
	
//	ControlInfo VFE_mzMin
//	variable mzMin = V_Value
//	ControlInfo VFE_mzMax
//	variable mzMax = V_Value
//	
//	ControlInfo $"VFE_HR" + oneOrTwoStr
//	variable HR = V_Value
//	ControlInfo $"VFE_UMR" + oneOrTwoStr
//	variable UMR = V_Value
//	
//	if(!UMR && !HR)
//		abort "Select either UMR or HR for sample " + oneOrTwoStr
//	elseif(UMR)
//		wave mzValues = $"root:Vapograms:MZ" + oneOrTwoStr
//	elseif(HR)
//		wave mzValues = $"root:Vapograms:HRMZ" + oneOrTwoStr
//	endif
//	
//3.0
	controlInfo/W=AMS_MS_Comparisons ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)
		case "UMR Data Comparison":
			variable mzMin = getminMz()
			variable mzMax = getmaxMz()
			
			break
		case "HR Data Comparison":			 
			controlInfo/W=AMS_MS_Comparisons HR2UMR_mzMin
			mzMin = V_value
			controlInfo/W=AMS_MS_Comparisons HR2UMR_mzMax
			mzMax = V_value
	
	return mzMin
			break
		case "UMR Database":
			mzMin = 1
			mzMax = 600
			break
			
		default:
			break
	endswitch
	

	variable mzStartIndex = binarySearch(mzValues,mzMin)
	variable mzEndIndex = binarySearch(mzValues,mzMax)


//      if (numpnts(MS_origin)== 0)

//             return ""

//      endif
//	
	Duplicate/FREE/O/R=[mzStartIndex,mzEndIndex] SelectedMS, tempwave, tempPos
	tempwave = tempwave[p] == 0 ? nan : tempwave[p]// DTS  2.1.7
	tempPos=p+mzMin
	sort/R tempwave, tempPos, tempwave
	Wavestats/q/M=1/q tempwave
	deletepoints 0, V_numNans, tempPos
	string wName = NameofWave(SelectedMS)
	string QualIons = ""
	variable n; string tagName, tagStr
//	n = Wavemax(MS_origin) // DTS  2.1.7 begin
//	if (n>0)
//	 	MS_origin/=n
//	endif
	
	
	//wave mz = $"root:Vapograms:MZ" + oneOrTwoStr
	strswitch (TabStr)
		case "UMR Data Comparison":
			ControlInfo/W=AMS_MS_Comparisons ADB_NumTag
			variable numTags = V_Value
			break
		case "HR Data Comparison":
			
			break
		case "UMR Database":
			ControlInfo/W=AMS_MS_Comparisons UMRDB_NumTag
			numTags = V_value
			break
			
		default:
			break
	endswitch
	
	
//	variable i
//	
//	if(strSearch(windowStr,"pop",0) == -1)
//		string tagList = annotationList(windowStr)
//		for(i=0;i<itemsInList(tagList);i+=1)
//			//tagStr = stringFromList(i,tagList,";")
//			if(strSearch(stringFromList(i,tagList,";"),"peak",0) >= 0)
//				Tag/K/N=$stringFromList(i,tagList,";")/W=$windowStr
//			endif
//			//Tag/C/N=$(wName+"peak" + num2str(i+1))/F=0/S=3/L=0/TL=0/X=0/Y=2 $wName, 0, ""
//		endfor
//		
//	endif
	if(dimsize(tempPos,0) > 0)
		for (n=0;n < numTags; n += 1)
			if(n < dimsize(tempPos,0))
				tagName = wName + "peak" + num2str(n+1)
				tagStr=num2str(tempPos[n])
				QualIons = AddListItem(num2str(tempPos[n]+1), QualIons)
				
				if(strSearch(windowStr,"pop",0) >= 0)
					Tag/C/N=$tagName/F=0/S=3/L=0/TL=0/X=0/Y=2 $wName, tempPos[n]-1,tagStr
				else
					Tag/C/N=$tagName/F=0/S=3/L=0/TL=0/X=0/Y=2/W=$windowStr $wName, tempPos[n]-1,tagStr
				endif
			else
				break
			endif
		endFor
	endif

End

Function NegAppendMSTags(SelectedMS, windowStr)
	wave selectedMS
	string windowStr// = "AMS_MS_Comparisons#G0"
	
	//string oneOrTwoStr = MSStr[strLen(MSStr)-1]
	//wave MS_origin = root:database:MS_origin
	wave mzValues = root:databasePanel:mzvalue
	
//	ControlInfo VFE_mzMin
//	variable mzMin = V_Value
//	ControlInfo VFE_mzMax
//	variable mzMax = V_Value
//	
//	ControlInfo $"VFE_HR" + oneOrTwoStr
//	variable HR = V_Value
//	ControlInfo $"VFE_UMR" + oneOrTwoStr
//	variable UMR = V_Value
//	
//	if(!UMR && !HR)
//		abort "Select either UMR or HR for sample " + oneOrTwoStr
//	elseif(UMR)
//		wave mzValues = $"root:Vapograms:MZ" + oneOrTwoStr
//	elseif(HR)
//		wave mzValues = $"root:Vapograms:HRMZ" + oneOrTwoStr
//	endif
//	
	variable mzMin = getminMz()
	variable mzMax = getmaxMz()

	variable mzStartIndex = binarySearch(mzValues,mzMin)
	variable mzEndIndex = binarySearch(mzValues,mzMax)


//      if (numpnts(MS_origin)== 0)

//             return ""

//      endif
//	
	Duplicate/FREE/O/R=[mzStartIndex,mzEndIndex] SelectedMS, tempwave, tempPos
	tempwave = tempwave[p] == 0 ? nan : tempwave[p]// DTS  2.1.7
	tempPos=p+mzMin
	sort tempwave, tempPos, tempwave
	//Wavestats/q/M=1/q tempwave
	//deletepoints 0, V_numNans, tempPos
	string wName = NameofWave(SelectedMS)
	string QualIons = ""
	variable n; string tagName, tagStr
//	n = Wavemax(MS_origin) // DTS  2.1.7 begin
//	if (n>0)
//	 	MS_origin/=n
//	endif
	
	
	//wave mz = $"root:Vapograms:MZ" + oneOrTwoStr
	ControlInfo/W=AMS_MS_Comparisons ADB_NumTag
	variable numTags = V_Value
	
//	variable i
//	
//	if(strSearch(windowStr,"pop",0) == -1)
//		string tagList = annotationList(windowStr)
//		for(i=0;i<itemsInList(tagList);i+=1)
//			//tagStr = stringFromList(i,tagList,";")
//			if(strSearch(stringFromList(i,tagList,";"),"peak",0) >= 0)
//				Tag/K/N=$stringFromList(i,tagList,";")/W=$windowStr
//			endif
//			//Tag/C/N=$(wName+"peak" + num2str(i+1))/F=0/S=3/L=0/TL=0/X=0/Y=2 $wName, 0, ""
//		endfor
//		
//	endif
	
	for (n=0;n < numTags; n += 1)
	
		tagName = wName + "neg_peak" + num2str(n+1)
		tagStr=num2str(tempPos[n])
		QualIons = AddListItem(num2str(tempPos[n]+1), QualIons)
		
		if(strSearch(windowStr,"pop",0) >= 0)
			Tag/C/N=$tagName/F=0/S=3/L=0/TL=0/X=0/Y=2 $wName, tempPos[n]-1,tagStr
		else
			Tag/C/N=$tagName/F=0/S=3/L=0/TL=0/X=0/Y=2/W=$windowStr $wName, tempPos[n]-1,tagStr
		endif
		
	endFor

End


Function/WAVE columnlabelExtracted()
				
	string columnlabel_extractlist = ""
	string sampletypeList = MakeCheckedListSampleType()
	string perturbList = MakeCheckedListPerturb()
	string deconList = MakeCheckedListDecon()	
	string InstList = MakeCheckedListInst()
	string Reslist = MakeCheckedListRes()
	string vaplist = MakeCheckedListVap()
	string FalseMSlist = MakeCheckedListFalseMS()//v3.4G
	SVAR mainlist = root:globals:mainlist
	
	variable i, j


	columnlabel_extractlist = SampletypeList + perturblist
	columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
	columnlabel_extractlist = columnlabel_extractlist + deconList
	columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
	columnlabel_extractlist = columnlabel_extractlist + InstList
	columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
	columnlabel_extractlist = columnlabel_extractlist + ResList
	columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
	columnlabel_extractlist = columnlabel_extractlist + VapList
	columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
	columnlabel_extractlist = columnlabel_extractlist + FalseMSList//v3.4G
	columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)//v3.4G
	

	variable numItems = ItemsInList(columnlabel_extractlist)
	string separator = ";"
	variable separatorLen = strLen(separator)
	variable offset = 0
	
	
	Make/T/O/Free/N=(numItems,0) columnlabel_extracted = stringFromList(p,columnLabel_extractList,";")
	//Make/O/Free/N=0 score_extracted
	
//	if(numItems > 0)
//		for(i=0;i<dimsize(columnlabel_extracted,0);i+=1)
//			string item = stringFromlist(0,columnlabel_extractList,separator,offset)
//			offset += strlen(item) + separatorLen
//			//check duplicate cmpStr(spectra_ID[dimsize(spectra_ID,0)-i],spectraStr) == 0
//			//if(dimsize(columnlabel_extracted,0) == 0)
//				//Redimension/N=(dimsize(columnlabel_extracted,0)+1) columnlabel_extracted
//				columnlabel_extracted[i] = item
//			//elseif(cmpstr(columnlabel_extracted[dimsize(columnlabel_extracted,0)-i],item) != 0)
//				//Redimension/N=(dimsize(columnlabel_extracted,0)+1) columnlabel_extracted
//				//columnlabel_extracted[i] = item
//			//endif
//						
//		endfor
//	endif
	
	return columnlabel_extracted
		
End

Function/s checkboxlist() //v1.5 modified to prevent from duplicating samples when change the enable box checking.
	string columnlabel_extractlist = ""
	string sampletypeList = MakeCheckedListSampleType()
	string perturbList = MakeCheckedListPerturb()
	string deconList = MakeCheckedListDecon()	
	string InstList = MakeCheckedListInst()
	string Reslist = MakeCheckedListRes()
	string vaplist = MakeCheckedListVap()
	string FalseMSlist = MakeCheckedListFalseMS()//v3.4G
	SVAR mainlist = root:globals:mainlist
	
	controlInfo ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)
		case "UMR Data Comparison":	
			columnlabel_extractlist = SampletypeList + perturblist
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
			columnlabel_extractlist = columnlabel_extractlist + deconList
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
			columnlabel_extractlist = columnlabel_extractlist + InstList
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
			columnlabel_extractlist = columnlabel_extractlist + ResList
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
			columnlabel_extractlist = columnlabel_extractlist + VapList
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
			columnlabel_extractlist = columnlabel_extractlist + FalseMSList//v3.4G
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)//v3.4G
			
			break
			
		case "HR Data Comparison":
			columnlabel_extractlist = SampletypeList + Reslist
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
			columnlabel_extractlist = columnlabel_extractlist + perturbList
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
			columnlabel_extractlist = columnlabel_extractlist + deconList
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
			columnlabel_extractlist = columnlabel_extractlist + VapList
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)
			columnlabel_extractlist = columnlabel_extractlist + FalseMSList//v3.4G
			columnlabel_extractlist = ExtractStringListDuplicates(columnlabel_extractlist)//v3.4G
			
			break
		
		default:
			break
	Endswitch
	
	
	return columnlabel_extractlist
End

Function/t ExtractStringListDuplicates(theListStr)
    String theListStr

    String retStr = ""
    variable i
    for(i = 0 ; i < itemsinlist(theListStr) ; i+=1)
    	variable foundindex = whichlistitem(stringfromlist(i,theListStr),theListStr)
        if(whichlistitem(stringfromlist(i , theListStr), theListStr) != -1 && whichlistitem(stringfromlist(i , theListStr), theListStr) != i && whichlistitem(stringfromlist(i , theListStr), theListStr) != i-1)
            retStr = addlistitem(stringfromlist(i, theListStr), retStr, ";", inf)
        endif
    endfor
    return retStr
End

Function/T MakeCheckedListsampleType()
	svar Alist = $ARoot
	svar NAlist = $NARoot
	
	string newstring=""
	variable sampletype = SampletypeCheck()
	
	if(sampletype == 1) //when A or NA or both is checked
		controlInfo ADB_tabs
		string TabStr = S_value
	
		strswitch (TabStr)
			case "UMR Data Comparison":
				controlInfo db_static_searchLimAmb
				if(V_value == 1)
					newstring += Alist
				endif
				
				controlInfo db_static_searchLimNonAmbient
				if(V_value == 1)
					newstring += NAlist
				endif
				
				break
			case "HR Data Comparison":
				controlInfo HR2UMR_searchLimAmb
				if(V_value == 1)
					newstring += Alist
				endif
				
				controlInfo HR2UMR_searchLimNonAmbient
				if(V_value == 1)
					newstring += NAlist
				endif
				
				break
			default:
				break
		endswitch
	else
		newstring=""
	endif
	
	return newstring

end

Function SampletypeCheck()
	variable sampleType = 0
	
	controlInfo ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)
		case "UMR Data Comparison":	
			controlInfo db_static_searchLimAmb
			if(V_value == 1) //meaning check Ambient
				SampleType = 1
			else
				controlInfo db_static_searchLimNonAmbient
				if(V_value == 1)
					SampleType = 1
				endif
			endif
			
			break
		case "HR Data Comparison":
			controlInfo HR2UMR_searchLimAmb
			if(V_value == 1) //meaning check Ambient
				SampleType = 1
			else
				controlInfo HR2UMR_searchLimNonAmbient
				if(V_value == 1)
					SampleType = 1
				endif
			endif
			
			break
		default:
			break
	endswitch
	
	return Sampletype
End

Function/T MakeCheckedListPerturb()
	svar Plist = $proot
	svar NPlist = $NProot
	
	string newstring = ""
	variable Perturb = PerturbCheck()
	
	if(Perturb == 1) //when A or NA or both is checked
		controlInfo ADB_tabs
		string TabStr = S_value
	
		strswitch (TabStr)
			case "UMR Data Comparison":
				controlInfo db_static_searchLim_Perturbed
				if(V_value == 1)
					newstring += Plist
				endif
				
				controlInfo db_static_searchLimLNonPerturb  //
				if(V_value == 1)
					newstring += NPlist
				endif
				
				break
			case "HR Data Comparison":
				controlInfo HR2UMR_searchLim_Perturbed
				if(V_value == 1)
					newstring += Plist
				endif
				
				controlInfo HR2UMR_searchLimLNonPerturbed
				if(V_value == 1)
					newstring += NPlist
				endif
				
				break
			default:
				break
		endswitch
	else
		newstring=""
	endif
	
	return newstring
	
end

Function PerturbCheck()
	variable var = 0
	controlInfo ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)
		case "UMR Data Comparison":
			controlInfo db_static_searchLim_Perturbed
			if(V_value == 1) //meaning check 
				var = 1
			else
				controlInfo db_static_searchLimLNonPerturb  //r001 db_static_searchLimLNonPerturb to be < 32 char len
				if(V_value == 1)
					var = 1
				endif
			endif
			break
		case "HR Data Comparison":
			controlInfo HR2UMR_searchLim_Perturbed
			if(V_value == 1) //meaning check 
				var = 1
			else
				controlInfo HR2UMR_searchLimLNonPerturbed
				if(V_value == 1)
					var = 1
				endif
			endif
			break
		default:
			break
	endswitch
	
	return var
End

Function/T MakeCheckedListDecon()
	svar DEClist = $DECroot
	svar NDEClist = $NDECroot
	
	string newstring = ""
	variable Decon = DeconCheck()
	
	if(Decon == 1) //when DEC or NDEC or both is checked
		controlInfo ADB_tabs
		string TabStr = S_value
	
		strswitch (TabStr)//v3.0
			case "UMR Data Comparison":
				controlInfo db_static_searchLimLSubDEC
				if(V_value == 1)
					newstring += DEClist
				endif
					
				controlInfo db_static_searchLimLSubNDEC
				if(V_value == 1)
					newstring += NDEClist
				endif
				break
				
			case "HR Data Comparison":
				controlInfo HR2UMR_searchLimLSubDEC
				if(V_value == 1)
					newstring += DEClist
				endif
					
				controlInfo HR2UMR_searchLimLSubNDEC
				if(V_value == 1)
					newstring += NDEClist
				endif
				break
				
			default:
				break
		endswitch
		
	else
		newstring=""
	endif
	
	return newstring
	
end

Function DeconCheck()
	variable var = 0
	
	controlInfo ADB_tabs//v3.0
	string TabStr = S_value//v3.0
	
	strswitch (TabStr)//add strswitch statements for HR2UMR v3.0
		case "UMR Data Comparison":
		
			controlInfo db_static_searchLimLSubDEC
	
			if(V_value == 1) //meaning check 
				var = 1
			else
				controlInfo db_static_searchLimLSubNDEC
				if(V_value == 1)
					var = 1
				endif
			endif
			
		case "HR Data Comparison":
		
			controlInfo HR2UMR_searchLimLSubDEC
	
			if(V_value == 1) //meaning check 
				var = 1
			else
				controlInfo HR2UMR_searchLimLSubNDEC
				if(V_value == 1)
					var = 1
				endif
			endif
			
			break
		default:
			break
	endswitch
		
	return var
End

Function/T MakeCheckedListInst()
	SVAR AQList = $AQRoot
	SVAR ATList = $ATRoot	
	SVAR QList = $QRoot
	SVAR Clist = $CRoot
	SVAR Vlist = $VRoot
	SVAR Wlist = $WRoot
	SVAR LVList = $LVRoot
	SVAR LWList = $LWRoot
	SVAR MList = $MRoot

	string newstring=""
	
	
/////Instrument and Detectors

	controlInfo ADB_tabs
	string TabStr = S_value
	
	if(cmpstr(TabStr, "UMR Data Comparison") == 0) //on UMR tab
		variable inst = InstCheck()
	endif
	
	strswitch (TabStr)//v3.0
		case "UMR Data Comparison":
			if(inst == 1)
				controlInfo db_static_searchLim_Inst_ALL
				if(V_value == 1)
					newstring = newstring + AQlist + ATlist + Qlist + Clist+ VList + WList + LVlist + LWlist + Mlist
				else
					controlInfo db_static_searchLimAQ
					if(V_value == 1)
						newstring = newstring + AQlist
					endif
					
					controlInfo db_static_searchLimAT
					if(V_value == 1)
						newstring = newstring + ATlist
					endif
					
					controlInfo db_static_searchLimQAMS
					if(V_value == 1)
						newstring = newstring + Qlist
					endif
					
					controlInfo db_static_searchLimCAMS
					if(V_value == 1)
						newstring = newstring + Clist
					endif
					
					controlInfo db_static_searchLimVHR
					if(V_value == 1)
						newstring = newstring + Vlist
					endif
					
					controlInfo db_static_searchLimWHR
					if(V_value == 1)
						newstring = newstring + Wlist
					endif
					
					controlInfo db_static_searchLimLVHR
					if(V_value == 1)
						newstring = newstring + LVlist
					endif
					
					controlInfo db_static_searchLimLWHR
					if(V_value == 1)
						newstring = newstring + LWlist
					endif
					
					controlInfo db_static_searchLim_Multiple
					if(V_value == 1)
						newstring = newstring + Mlist
					endif
					
				endif
			endif
						
			break
		
		case "HR Data Comparison"://When HR2UMR instrument is alwasy set as 'All'
			newstring = newstring + AQlist + ATlist + Qlist + Clist+ VList + WList + LVlist + LWlist + Mlist
		break
		
		default:
			break
	endswitch
	
	return newstring
	
End

Function InstCheck()
	variable Inst = 0
	/////Instrument and Detectors
	controlInfo db_static_searchLim_Inst_ALL
	if(V_value == 1)
		Inst = 1
	else
		controlInfo db_static_searchLimAQ
	 	if(V_value == 1)
	 		Inst = 1
		endif
	
		controlInfo db_static_searchLimAT
	 	if(V_value == 1)
	 		Inst = 1
		endif
	
		controlInfo db_static_searchLimQAMS
	 	if(V_value == 1)
	 		Inst = 1
		endif
	
		controlInfo db_static_searchLimCAMS
	 	if(V_value == 1)
	 		Inst = 1
		endif
	
		controlInfo db_static_searchLimVHR
	 	if(V_value == 1)
	 		Inst = 1
		endif
	
		controlInfo db_static_searchLimWHR
	 	if(V_value == 1)
	 		Inst = 1
		endif
		
		controlInfo db_static_searchLimLVHR
	 	if(V_value == 1)
	 		Inst = 1
		endif
		
		controlInfo db_static_searchLimLWHR
	 	if(V_value == 1)
	 		Inst = 1
		endif		
		
		controlInfo db_static_searchLim_Multiple
	 	if(V_value == 1)
	 		Inst = 1
		endif
	endif
	
	Return Inst
	
End

Function/T MakeCheckedListRes()
	
	SVAR UMRlist = $UMRRoot
	SVAR HRlist = $HRRoot
	SVAR HR2UMRlist = $HR2UMRRoot
	svar comlist = $comRoot
	
	string newstring=""
	
	controlInfo ADB_tabs
	string TabStr = S_value
	
	if(cmpstr(TabStr, "UMR Data comparison") == 0)
		variable res = ResCheck()
	endif
	
	//////MS_origin resolution
	strswitch (TabStr)
		case "UMR Data Comparison":
			if(res == 1)
				controlInfo db_static_searchLim_Res_ALL
				if(V_value == 1)
					newstring = newstring + UMRlist + HR2UMRlist + Comlist
				else
					controlInfo db_static_searchLimHRD1
				 	if(V_value == 1)
				 		newstring = newstring + UMRlist
					endif
					
					controlInfo db_static_searchLimHRD
				 	if(V_value == 1)
				 		newstring = newstring + HR2UMRlist
					endif
					
					controlInfo db_static_searchLimCOM
					if(V_value == 1)
						newstring = newstring + Comlist
					endif
				endif
			endif
			
			break
		case "HR Data Comparison"://on HR2UMR, Res list is always set as "HR2UMR list"
			newstring = newstring + HR2UMRlist
			
			break
		default:
			break
	endswitch
	
	return newstring

End

Function ResCheck()
	Variable Res = 0
	//////MS_origin resolution
	controlInfo db_static_searchLim_Res_ALL
	if(V_value == 1)
		Res = 1
	else
		controlInfo db_static_searchLimHRD1
	 	if(V_value == 1)
	 		Res = 1
		endif
		
		controlInfo db_static_searchLimHRD
	 	if(V_value == 1)
	 		Res = 1
		endif	
		
		controlInfo db_static_searchLimCOM
	 	if(V_value == 1)
	 		Res = 1
		endif
	endif
	
	Return Res
End

Function/T MakeCheckedListVap()
	
	SVAR SVlist = $SVRoot
	SVAR CVList = $CVRoot
	string newstring=""
	variable vap = VapCheck()
	
	controlInfo ADB_tabs
	string TabStr = S_value
	
	//////Vaporizer Type
	if(vap == 1)
		strswitch (TabStr)
			case "UMR Data Comparison":
				controlInfo db_static_searchLimCVM1
			 	if(V_value == 1)
			 		newstring = newstring + SVlist
				endif
				
				controlInfo db_static_searchLimCVM
			 	if(V_value == 1)
			 		newstring = newstring + CVlist
				endif
				break
			case "HR Data Comparison":
				controlInfo HR2UMR_searchLimSV
				if(V_value == 1)
			 		newstring = newstring + SVlist
				endif
				
				controlInfo HR2UMR_searchLimCV
			 	if(V_value == 1)
			 		newstring = newstring + CVlist
				endif
				break
			default:
				break
		endswitch
	endif
//	if(sampletype + vap + res + inst > 1)
//		if(newstring != "" && vap == 1)
//			newstring = ExtractStringListDuplicates(newstring)
//		endif
//		//columnlabel_extrctlist = RemoveStringListDuplicates(columnlabel_extrctlist)
//	endif
	
	return newstring

End

Function VapCheck()
	variable Vap = 0
	//////Vaporizer Type
	controlInfo ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)
		case "UMR Data Comparison":
			controlInfo db_static_searchLimCVM1
		 	if(V_value == 1)
		 		Vap = 1
			endif
			
			controlInfo db_static_searchLimCVM
		 	if(V_value == 1)
		 		Vap = 1
			endif
			break
		case "HR Data Comparison":
			controlInfo HR2UMR_searchLimSV
		 	if(V_value == 1)
		 		Vap = 1
			endif
			
			controlInfo HR2UMR_searchLimCV
		 	if(V_value == 1)
		 		Vap = 1
			endif
			break
		default:
			break
	endswitch

	
	Return vap
End

Function/T MakeCheckedListFalseMS()//v3.4G
	
	SVAR FalseMSlist = $FalseMSRoot
	SVAR TrueMSlist = $TrueMSRoot
	string newstring=""
	variable FalseMS = FalseMSCheck()
	
	controlInfo ADB_tabs
	string TabStr = S_value
	
	//////False MS
	if(FalseMS == 1)
		strswitch (TabStr)
			case "UMR Data Comparison":
				controlInfo db_static_searchLimFalseCOCO2
			 	if(V_value == 1)//if FalseMS is selected
			 		newstring = newstring + FalseMSlist
				endif
				
				break
			case "HR Data Comparison":
				controlInfo HR2UMR_searchLimFalseCOCO2
				if(V_value == 1)
			 		newstring = newstring + FalseMSlist
				endif
				
				break
			default:
				break
		endswitch
	elseif(FalseMS == 0)//FalseMS is not selected
		strswitch (TabStr)
			case "UMR Data Comparison":
				controlInfo db_static_searchLimFalseCOCO2
			 	if(V_value == 0)//if FalseMS is not selected
			 		newstring = newstring + TrueMSlist
				endif
				
				break
			case "HR Data Comparison":
				controlInfo HR2UMR_searchLimFalseCOCO2
				if(V_value == 0)
			 		newstring = newstring + TrueMSlist
				endif
				
				break
			default:
				break
		endswitch
	endif
//	if(sampletype + vap + res + inst > 1)
//		if(newstring != "" && vap == 1)
//			newstring = ExtractStringListDuplicates(newstring)
//		endif
//		//columnlabel_extrctlist = RemoveStringListDuplicates(columnlabel_extrctlist)
//	endif
	
	return newstring

End

Function FalseMSCheck()//v3.4G
	variable FalseMS = 0
	//////False MS (The abundance of m/z28 and 44 is not equal)
	controlInfo ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)
		case "UMR Data Comparison":
			controlInfo db_static_searchLimFalseCOCO2
		 	if(V_value == 1)
		 		FalseMS = 1
			endif
			
			break
		case "HR Data Comparison":
			controlInfo HR2UMR_searchLimFalseCOCO2
		 	if(V_value == 1)
		 		FalseMS = 1
			endif
			
			break
		default:
			break
	endswitch

	
	Return FalseMS
End

Function GenFilterList()
	Wave/T AerosolOrigin=root:database:AerosolOrigin
	Wave/T AerosolPerturbation = root:database:AerosolPerturbation
	Wave/T Analysis = root:database:Analysis
	Wave/T Instrument = root:database:Instrument
	Wave/T Resolution = root:database:Resolution
	Wave/T Vaporizer = root:database:Vaporizer
	Wave/T ShortFileDescriptor = root:database:ShortFileDescriptor//v3.4G
	
	wave/T columnLabel = root:Database:columnlabel
	wave columnlabel_index = root:Database:columnlabel_index
	
	SVAR Alist=$Aroot
	svar NAlist = $NAroot
	svar Plist = $Proot
	svar NPlist = $NProot
	svar DEClist = $DECroot
	svar NDEClist = $NDECroot
	svar AQlist = $AQRoot
	svar ATlist = $ATroot
	svar Qlist = $Qroot
	svar Clist = $Croot
	svar Vlist = $VRoot
	svar Wlist = $Wroot
	svar LVlist = $LVroot
	svar LWlist = $LWroot
	svar Mlist = $MRoot
	svar UMRlist = $UMRRoot
	svar HRlist = $HRRoot
	svar HR2UMRlist = $HR2UMRroot
	svar ComList = $ComRoot
	svar SVList = $SVRoot
	svar CVList = $CVRoot
	svar FalseMSlist = $FalseMSRoot//v3.4G
	svar TrueMSlist = $TrueMSRoot//v3.4G
	svar allspectralist = root:globals:allspectralist
	svar HR2UMR_allspectralist = root:globals:HR2UMR_allspectralist//v3.4
	
	variable i
	for(i=0;i<dimsize(columnlabel,0);i++)
		variable index = columnlabel_index[i]
		if(cmpstr(AerosolOrigin[index],"A",2) == 0)
			Alist += columnlabel[i]+";"		
		elseif(cmpstr(AerosolOrigin[index],"NA",2) == 0)
			NAList += columnlabel[i]+";"
		endif
			
		if(cmpstr(AerosolPerturbation[index],"P") == 0)
			Plist += columnlabel[i]+";"			
		elseif(cmpstr(AerosolPerturbation[index],"NP") == 0)
			NPlist += columnlabel[i]+";"
		endif
			
		if(cmpstr(Analysis[index],"DEC",2) == 0)
			DEClist += columnlabel[i]+";"			
		elseif(cmpstr(Analysis[index], "NDEC",2) == 0)
			NDEClist += columnlabel[i]+";"
		endif
			
		if(cmpstr(Instrument[index], "AQ",2) == 0)
			AQlist += columnlabel[i]+";"			
		elseif(cmpstr(Instrument[index], "AT",2) == 0)
			ATlist += columnlabel[i]+";"			
		elseif(cmpstr(Instrument[index], "Q",2) == 0)
			Qlist += columnlabel[i]+";"			
		elseif(cmpstr(Instrument[index], "C",2) == 0)
			Clist += columnlabel[i]+";"			
		elseif(cmpstr(Instrument[index], "V",2) == 0)
			Vlist += columnlabel[i]+";"			
		elseif(cmpstr(Instrument[index], "W",2) == 0)
			Wlist += columnlabel[i]+";"			
		elseif(cmpstr(Instrument[index], "LV",2) == 0)
			LVlist += columnlabel[i]+";"			
		elseif(cmpstr(Instrument[index], "LW",2) == 0)
			LWlist += columnlabel[i]+";"			
		elseif(cmpstr(Instrument[index], "M",2) == 0)
			Mlist += columnlabel[i]+";"
		endif
			
		if(cmpstr(Resolution[index], "UMR",2) == 0)
			UMRlist += columnlabel[i]+";" 			
		elseif(cmpstr(Resolution[index], "HR",2) == 0)
			HRlist += columnlabel[i]+";" 		
			HR2UMR_allspectralist += columnlabel[i]+";"//v3.4	
		elseif(cmpstr(Resolution[index], "HR2UMR",2) == 0)
			HR2UMRlist += columnlabel[i]+";" 
			HR2UMR_allspectralist += columnlabel[i]+";"//v3.4			
		elseif(cmpstr(Resolution[index], "Com",2) == 0)
			Comlist += columnlabel[i]+";" 
		endif
			
		if(cmpstr(vaporizer[index],"S",2) == 0)
			SVList += columnlabel[i]+";"			
		elseif(cmpstr(vaporizer[index],"C",2) == 0)
			CVList += columnlabel[i]+";"
		endif
		
		//v3.4G
		if(stringmatch(ShortFileDescriptor[index],"*False MS*") == 1)
			FalseMSlist += columnlabel[i] + ";"
		else
			TrueMSlist += columnlabel[i]+";"
		endif
		//
	
		allspectralist += columnlabel[i]+";"
	endfor
		
	
End

Function GenDBH5()
	Wave/T AerosolOrigin=root:database:AerosolOrigin
	Wave/T AerosolPerturbation = root:database:AerosolPerturbation
	Wave/T Analysis = root:database:Analysis
	Wave/T Instrument = root:database:Instrument
	Wave/T Resolution = root:database:Resolution
	Wave/T Vaporizer = root:database:Vaporizer
	Wave/T ShortFileDescriptor = root:database:ShortFileDescriptor
	Wave EIEnergy = root:database:EIEnergy
	Wave VaporizerTempC = root:database:VaporizerTempC
	Wave/T CommentDAQ = root:database:CommentDAQ
	wave/T NonAmbientType = root:database:NonAmbientType
	wave/T CommentNonAmbient = root:Database:CommentNonAmbient
	wave/T PerturbedType = root:Database:PerturbedType
	wave/T CommentPerturbed = root:Database:CommentPerturbed
	wave/T ExperimenterName = root:Database:ExperimenterName
	wave/T GroupStr = root:Database:GroupStr
	wave/T CitationUrl = root:Database:CitationUrl
	wave/T CitationStr = root:Database:CitationStr
	wave/T CitationFigStr = root:Database:CitationFigStr
	wave/T CommentAnalysis = root:Database:CommentAnalysis
	
	wave/T columnlabel = root:database:columnlabel
	wave columnlabel_index = root:database:columnlabel_index
	wave wholewave = root:database:wholewave
		
	
	NewPath/O/Q/C/M="Folder to Save Exported Data" exportPath
	
	string exportName = "database"
	
	Prompt exportName,"Name for exported .h5 file:"
	DoPrompt "Export results", exportName
	if(V_Flag)
		return -1
	endif
	
	if(cmpStr(exportName[strLen(exportName)-3,strLen(exportName)-1],".h5") != 0)
		exportName += ".h5"
	endif 
	
	variable tempVar,i
	variable result = 0
	HDF5CreateFile/O/P=exportPath tempVar as exportName
	HDF5SaveData/LAYO={2,dimsize(wholewave,0),dimsize(wholewave,1)}/MAXD={-1,-1}/GZIP={9,0} wholewave, tempVar
	HDF5SaveData/LAYO={2,dimsize(columnlabel,0)}/MAXD={-1}/GZIP={9,0} columnlabel, tempVar
	HDF5SaveData/LAYO={2,dimsize(columnlabel_index,0)}/MAXD={-1}/GZIP={9,0} Columnlabel_index, tempVar
	
	HDF5SaveData/LAYO={2,dimsize(AerosolOrigin,0)}/MAXD={-1}/GZIP={9,0} AerosolOrigin, tempVar
	HDF5SaveData/LAYO={2,dimsize(AerosolPerturbation,0)}/MAXD={-1}/GZIP={9,0} AerosolPerturbation, tempVar
	HDF5SaveData/LAYO={2,dimsize(Analysis,0)}/MAXD={-1}/GZIP={9,0} Analysis, tempVar
	HDF5SaveData/LAYO={2,dimsize(Instrument,0)}/MAXD={-1}/GZIP={9,0} Instrument, tempVar
	HDF5SaveData/LAYO={2,dimsize(Resolution,0)}/MAXD={-1}/GZIP={9,0} Resolution, tempVar
	HDF5SaveData/LAYO={2,dimsize(Vaporizer,0)}/MAXD={-1}/GZIP={9,0} Vaporizer, tempVar
	HDF5SaveData/LAYO={2,dimsize(ShortFileDescriptor,0)}/MAXD={-1}/GZIP={9,0} ShortFileDescriptor, tempVar
	HDF5SaveData/LAYO={2,dimsize(EIEnergy,0)}/MAXD={-1}/GZIP={9,0} EIEnergy, tempVar
	HDF5SaveData/LAYO={2,dimsize(VaporizerTempC,0)}/MAXD={-1}/GZIP={9,0} VaporizerTempC, tempVar
	HDF5SaveData/LAYO={2,dimsize(CommentDAQ,0)}/MAXD={-1}/GZIP={9,0} CommentDAQ, tempVar	
	HDF5SaveData/LAYO={2,dimsize(NonAmbientType,0)}/MAXD={-1}/GZIP={9,0} NonAmbientType, tempVar	
	HDF5SaveData/LAYO={2,dimsize(CommentNonAmbient,0)}/MAXD={-1}/GZIP={9,0} CommentNonAmbient, tempVar
	HDF5SaveData/LAYO={2,dimsize(PerturbedType,0)}/MAXD={-1}/GZIP={9,0} PerturbedType, tempVar
	HDF5SaveData/LAYO={2,dimsize(CommentPerturbed,0)}/MAXD={-1}/GZIP={9,0} CommentPerturbed, tempVar
	HDF5SaveData/LAYO={2,dimsize(ExperimenterName,0)}/MAXD={-1}/GZIP={9,0} ExperimenterName, tempVar
	HDF5SaveData/LAYO={2,dimsize(GroupStr,0)}/MAXD={-1}/GZIP={9,0} GroupStr, tempVar
	HDF5SaveData/LAYO={2,dimsize(CitationUrl,0)}/MAXD={-1}/GZIP={9,0} CitationUrl, tempVar
	HDF5SaveData/LAYO={2,dimsize(CitationStr,0)}/MAXD={-1}/GZIP={9,0} CitationStr, tempVar
	HDF5SaveData/LAYO={2,dimsize(CitationFigStr,0)}/MAXD={-1}/GZIP={9,0} CitationFigStr, tempVar
	HDF5SaveData/LAYO={2,dimsize(CommentAnalysis,0)}/MAXD={-1}/GZIP={9,0} CommentAnalysis, tempVar

		
	if (V_flag != 0)
		Print "HDF5SaveData failed"
		result = -1
	endif
	
	//string path = "root:globals:"


	HDF5CloseFile/A tempVar
		
	print "Pertinent waves exported."
	
End

Function Add_UMRDataToDB() //add data by using .h5 file v2.01
	Wave/T AerosolOrigin=root:database:AerosolOrigin
	Wave/T AerosolPerturbation = root:database:AerosolPerturbation
	Wave/T Analysis = root:database:Analysis
	Wave/T Instrument = root:database:Instrument
	Wave/T Resolution = root:database:Resolution
	Wave/T Vaporizer = root:database:Vaporizer
	Wave/T ShortFileDescriptor = root:database:ShortFileDescriptor
	Wave EIEnergy = root:database:EIEnergy
	Wave VaporizerTempC = root:database:VaporizerTempC
	Wave/T CommentDAQ = root:database:CommentDAQ
	wave/T NonAmbientType = root:database:NonAmbientType
	wave/T CommentNonAmbient = root:Database:CommentNonAmbient
	wave/T PerturbedType = root:Database:PerturbedType
	wave/T CommentPerturbed = root:Database:CommentPerturbed
	wave/T ExperimenterName = root:Database:ExperimenterName
	wave/T GroupStr = root:Database:GroupStr
	wave/T CitationUrl = root:Database:CitationUrl
	wave/T CitationStr = root:Database:CitationStr
	wave/T CitationFigStr = root:Database:CitationFigStr
	wave/T CommentAnalysis = root:Database:CommentAnalysis
	
	wave/T columnlabel = root:database:columnlabel
	wave columnlabel_index = root:database:columnlabel_index
	wave wholewave = root:database:wholewave
	
	string S_path
	
	variable tempVar, i
	HDF5OpenFile tempVar as ""
	
	newdatafolder/O root:temph5
	setdatafolder root:temph5
	
	HDF5LoadData/O/Q tempVar, "Spectra"
	HDF5LoadData/O/Q tempVar, "SpectraComments"
	HDF5LoadData/O/Q tempVar, "SpectraMetaData"
	HDF5LoadData/O/Q tempVar, "SpectraName"
	HDF5LoadData/O/Q tempVar, "mz"
	HDF5LoadData/O/Q tempVar, "mzlabel"
	
	wave Spectra = root:temph5:Spectra
	wave/T SpectraComments = root:temph5:SpectraComments
	wave/T SpectraMetaData = root:temph5:SpectraMetaData
	wave/T SpectraName = root:temph5:SpectraName
	wave mz=root:temph5:mz
	wave/T mzlabel=root:temph5:mzlabel
	
	//update spectrum information
	variable k
	for(k=1; k<dimsize(SpectraMetaData,0); k++) //why k=1? Becasue SpectraMetaData[0][0] is numberSpectra
		if(cmpstr(SpectraMetaData[0][k],"",2) == 1)
			string Databasepath = "root:database:"+SpectraMetaData[0][k]
			wave/T Infowave = $databasepath
			redimension/n=(dimsize(infowave,0)) Infowave
			Infowave[dimsize(infowave,0)-1] = SpectraMetaData[1][k]
		else
			break
		endif
	endfor	
	
	//determine columnlabel, shortFileDescriptor + SpectraName
	variable j
	for(j=0; j<str2num(SpectraMetaData[1][1]); j++)
		string Name = replacestring(".h5", spectraMetaData[0][7],"")
		string Spectralabel = Name+"_"+SpectraName[j]
		redimension/n=(dimsize(columnlabel,0)+1) columnlabel
		columnlabel[dimsize(columnlabel,0)-1] = SpectraLabel
		redimension/n=(dimsize(columnlabel_index,0)+1) columnlabel_index
		columnlabel_index[dimsize(columnlabel_index,0)-1] = dimsize(AerosolOrigin,0)
		
		//add mass spectrum to the wholewave spectra database
		redimension/n=(dimsize(wholewave,0),dimsize(wholewave,1)+1) wholewave
		variable l
		for(l=0;l<dimsize(mz,0);l++)
			variable unitMass = mz[l]
			variable SpectraSum = sum(spectra)//v3.4A
			wholewave[dimsize(wholewave,1)-1][l]=spectra[j][l]/SpectraSum //v3.4A
		endfor
	endfor
	
End

Function renumbering()//v2.01
	wave/T columnlabel = root:database:columnlabel
	
	variable i
	
	setdatafolder root:
	for(i=0;i<dimsize(columnlabel,0);i++)
		variable startindex = strsearch(columnlabel[i],"_",0)
		variable endindex = strlen(columnlabel[i])
		string columnlabelstr = columnlabel[i]
		string finalstr = columnlabelstr[startindex+1,endindex]
		columnlabel[i] = finalstr
		columnlabel[i] = num2str(p+1)+"_"+columnlabel[i]
	endfor

ENd

//v3.4B
Function ADB_menu_convert()
	string datafolderpath
	
	Prompt datafolderpath, "Enter HR data folder path. (e.g.) root:A_NP_Dec_V_HR_S_myPMF:"
	DoPrompt "Enter HR data folder path", datafolderpath
	if(V_flag)
		return -1 //user canceled
	endif
	
	ADB_convert_MyHR2UMR(datafolderpath)
	HR2UMR_genMyHRFamilywave(datafolderpath)
	
End
//Convert HR data to UMR for PMF h5 file v2.02
Function ADB_Convert_MyHR2UMR(datafolderpath)//v3.4B change the function name from Add_MyHR2UMR(datafolderpath)
	string datafolderpath//copy current folder path
	string HRSpectrapath = datafolderpath+"Spectra"
	string HRmzPath = datafolderpath + "mz"
	string SpectraNamePath = datafolderpath + "SpectraName"
	
	wave HRSpectra = $HRSpectraPath
	wave HRmz = $HRmzPath
	wave/T SpectraName = $SpectraNamePath

	
	setdatafolder datafolderpath
	
	variable i, column
	
	make/O/n=0 myHR2UMRmz
	make/o/n=(0,dimsize(HRSpectra,1)) myHR2UMRSpectra
	
	for(column=0;column<dimsize(HRSpectra,1);column++)
		//string myHR2UMRSpectraName = "myHR2UMRSpectra_"+SpectraName[column]
		//make/O/n=0 $myHR2UMRSpectraName
		//string myHR2UMRSpectraNamePath = datafolderpath + myHR2UMRSpectraName
		//wave myHR2UMRSpectra = $myHR2UMRSpectraNamePath
		
		for(i=0;i<dimsize(HRmz,0);i++)
			variable UMRmass = round(HRmz[i])
			variable check = binarysearch(myHR2UMRmz,UMRmass)
			if(column == 0)
				if(check < 0)//the rounded mass does not exist in the myHR2UMRmz waves	
					redimension/n=(dimsize(myHR2UMRmz,0)+1) myHR2UMRmz
					myHR2UMRmz[dimsize(myHR2UMRmz,0)-1]=UMRmass
	
					redimension/n=(dimsize(myHR2UMRSpectra,0)+1,dimsize(myHR2UMRSpectra,1)) myHR2UMRSpectra
					myHR2UMRSpectra[dimsize(myHR2UMRSpectra,0)-1][column] = HRSpectra[i][column]
					
				else //the rounded mass already exist in th myHR2UMRmz waves
					myHR2UMRSpectra[dimsize(myHR2UMRSpectra,0)-1][column] += HRSpectra[i][column]
				endif
			else
				//redimension/n=(dimsize(myHR2UMRmz,0)) myHR2UMRSpectra
				myHR2UMRSpectra[check][column] += HRSpectra[i][column]
			endif
		endfor
		
	endfor
	
	setdatafolder root:
		

End


//v2.03
Function ADB_Butt_AddMyMstoDB(controlname) :ButtonControl
	string controlname
	
	AddMyMstoDB()
	
End


//v2.03
Function AddMyMStoDB()
	wave MS_origin = root:databasePanel:MS_origin
	
	Wave/T AerosolOrigin=root:database:AerosolOrigin
	Wave/T AerosolPerturbation = root:database:AerosolPerturbation
	Wave/T Analysis = root:database:Analysis
	Wave/T Instrument = root:database:Instrument
	Wave/T Resolution = root:database:Resolution
	Wave/T Vaporizer = root:database:Vaporizer
	Wave/T ShortFileDescriptor = root:database:ShortFileDescriptor
	Wave EIEnergy = root:database:EIEnergy
	Wave VaporizerTempC = root:database:VaporizerTempC
	Wave/T CommentDAQ = root:database:CommentDAQ
	wave/T NonAmbientType = root:database:NonAmbientType
	wave/T CommentNonAmbient = root:Database:CommentNonAmbient
	wave/T PerturbedType = root:Database:PerturbedType
	wave/T CommentPerturbed = root:Database:CommentPerturbed
	wave/T ExperimenterName = root:Database:ExperimenterName
	wave/T GroupStr = root:Database:GroupStr
	wave/T CitationUrl = root:Database:CitationUrl
	wave/T CitationStr = root:Database:CitationStr
	wave/T CitationFigStr = root:Database:CitationFigStr
	wave/T CommentAnalysis = root:Database:CommentAnalysis
	
	wave/T columnlabel = root:database:columnlabel
	wave columnlabel_index = root:database:columnlabel_index
	wave wholewave = root:database:wholewave
	
	setdatafolder root:globals:
	SVAR AddAerosolOrigin, AddAerosolPerturbation, AddAnalysis, AddCitationFigStr
	SVAR AddCitationStr, AddCitationUrl 
	SVAR AddCommentAnalysis,AddCommentDAQ,AddCommentNonAmbient, AddCommentPerturbed
	SVAR AddExperimenterName, AddGroupStr, AddInstrument
	SVAR AddNonAmbientType, AddPerturbedType, AddResolution, AddShortFileDescriptor, AddVaporizer
	NVAR AddEIEnergy, AddVaporizerTempC
	
	InsertPoints dimsize(AerosolOrigin,0)+1,1, ::Database:AerosolOrigin,::Database:AerosolPerturbation
	InsertPoints dimsize(AerosolOrigin,0)+1,1, ::Database:Analysis,::Database:CitationFigStr,::Database:CitationStr,::Database:CitationUrl
	InsertPoints dimsize(AerosolOrigin,0)+1,1, ::Database:CommentAnalysis,::Database:CommentDAQ,::Database:CommentNonAmbient,::Database:CommentPerturbed
	InsertPoints dimsize(AerosolOrigin,0)+1,1, ::Database:EIEnergy,::Database:ExperimenterName,::Database:GroupStr,::Database:Instrument
	InsertPoints dimsize(AerosolOrigin,0)+1,1, ::Database:NonAmbientType,::Database:PerturbedType,::Database:Resolution
	InsertPoints dimsize(AerosolOrigin,0)+1,1, ::Database:ShortFileDescriptor,::Database:Vaporizer,::Database:VaporizerTempC

	variable RowNum = dimsize(AerosolOrigin,0)-1
	
	controlinfo popup_1_AerosolOrigin//AerosolOrigin A/NA
	AddAerosolOrigin = S_value
	if(cmpstr(AddAerosolOrigin,"Ambient") == 0)
		AerosolOrigin[Rownum] = "A"
	elseif(cmpstr(AddAerosolOrigin,"NonAmbient") == 0)
		AerosolOrigin[Rownum] = "NA"
	endif
		
	controlinfo popup_1_NA_type //NonAmbientType NA type
	AddNonAmbientType = S_value
	NonAmbientType[RowNum] = AddNonAmbientType
	
	controlinfo setvar_1_NA_Comment //CommentNonAmbient _ NA comment
	AddCommentNonAmbient = S_value
	CommentNonAmbient[RowNum] = AddCommentNonAmbient
	
	controlinfo popup_1_AerosolTreatment //AerosolPerturbation P/NP
	AddAerosolPerturbation = S_value
	if(cmpstr(AddAerosolPerturbation,"Perturbed") == 0)
		AerosolPerturbation[RowNum] = "P"
	elseif(cmpstr(AddAerosolPerturbation,"Non-perturbed") == 0)
		AerosolPerturbation[RowNum] = "NP"
	endif
	
	controlinfo popup_1_Pert_Type //PerturbedType perturbation type ex. thermodenuder 
	AddPerturbedType = S_value
	PerturbedType[RowNum] = AddPerturbedType
	
	controlinfo setvar_1_Pert_Comment //CommentPerturbed
	AddCommentPerturbed = S_value
	CommentPerturbed[RowNum] = AddCommentPerturbed
	
	controlinfo popup_1_Analysis//Analysis DEC/NDEC
	AddAnalysis = S_value
	if(cmpstr(AddAnalysis, "Deconvolved") == 0)
		Analysis[RowNum] = "DEC"
	elseif(cmpstr(AddAnalysis, "NonDeconvolved") == 0)
		Analysis[RowNum] = "NDEC"
	endif
	
	controlinfo popup_1_Instrument//Instrument AQ/AT/Q/C/V/W/M, LW and LV don't exist
	AddInstrument = S_value
	variable tempvar
	tempvar = V_value
	if(tempvar == 2)
		Instrument[RowNum] = "AQ"
	elseif(tempvar == 3)
		Instrument[RowNum] = "AT"
	elseif(tempvar == 4)
		Instrument[RowNum] ="Q"
	elseif(tempvar == 5)
		Instrument[RowNum] = "C"
	elseif(tempvar == 6)
		Instrument[RowNum] = "V"
	elseif(tempvar == 7)
		Instrument[RowNum] = "W"
	elseif(tempvar == 8)
		Instrument[RowNum] = "M"
	endif	
	
	controlinfo popup_1_Resolution//Resolution UMR/HR/Com
	AddResolution = S_value
	if(cmpstr(AddResolution,"UMR") == 0)
		Resolution[RowNum] = "UMR"
	elseif(cmpstr(AddResolution, "HR") == 0)
		Resolution[RowNum] = "HR"
	elseif(cmpstr(AddResolution, "Combo HR+UMR") == 0)
		Resolution[RowNum] = "Com"
	endif
	
	controlinfo popup_1_Vaporizer//Vaporizer CV/SV
	AddVaporizer = S_value
	if(cmpstr(AddVaporizer, "Standard") == 0)
		Vaporizer[RowNum] = "SV"
	elseif(cmpstr(AddVaporizer, "Capture") == 0)
		Vaporizer[RowNum] = "CV"
	endif
	
	controlinfo setvar_1_ShortFileDescriptor//ShortFileDescriptor
	AddShortFileDescriptor = S_value
	ShortFileDescriptor[RowNum] = AddShortFileDescriptor
	
	controlinfo setvar_1_VT//VaporizerTempC 600
	AddVaporizerTempC = V_value
	VaporizerTempC[RowNum] = AddVaporizerTempC
	
	controlinfo setvar_1_EI//EIEnergy 70
	AddEIEnergy = V_value
	EIEnergy[RowNum] = AddEIEnergy
	
	controlinfo setvar_1_OptIns_Comment//CommentDAQ
	AddCommentDAQ = S_value
	CommentDAQ[RowNum] = AddCommentDAQ
	
	controlinfo setvar_2_ExperimenterName1//ExperimenterName
	AddExperimenterName = S_value
	ExperimenterName[RowNum] = AddExperimenterName
	
	controlinfo setvar_2_GroupStr1//GroupStr
	AddGroupStr = S_value
	GroupStr[RowNum] = AddGroupStr
	
	controlinfo setvar_2_CitationStr1//CitationStr
	AddCitationStr = S_value
	CitationStr[RowNum] = AddCitationStr
	
	controlinfo setvar_2_CitationUrl1//CitationUrl
	AddCitationUrl = S_value
	CitationUrl[RowNum] = AddCitationUrl
	
	controlinfo setvar_2_CitationFigStr1//CitationFigStr
	AddCitationFigStr = S_value
	CitationFigStr[RowNum] = AddCitationFigStr
	
	controlinfo setvar_2_commentAnalysis1//CommentAnalysis
	AddCommentAnalysis = S_value
	CommentAnalysis[RowNum] = AddCommentAnalysis
	
	
	InsertPoints dimsize(columnlabel,0)+1,1, ::Database:columnlabel, ::Database:columnlabel_index
	controlinfo setvar_SpectraName
	string SpectraName
	SpectraName = S_value
	columnlabel[dimsize(columnlabel,0)-1] = SpectraName
	columnlabel_index[dimsize(columnlabel_index,0)-1] = dimsize(AerosolOrigin,0)-1
	Renumbering()
	
	InsertPoints/M=1 dimsize(wholewave,1)+1,1, root:Database:wholewave
	wholewave[][dimsize(wholewave,1)-1]=MS_origin[p]


End

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////PANEL/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Window AMS_MS_Comparisons() : Panel
//	wave MSExpCalc = root:databasePanel:MSExpCalc
//	wave mzvalue = root:databasePanel:mzvalue
//	wave/T columnlabel_sort = root:databasePanel:columnlabel_sort
//	wave score_sort = root:databasePanel:score_sort
//	wave/T HR_familyName = root:HR:HR_familyName
//	wave HR_family_R = root:HR:HR_family_R
//	wave HR_family_G = root:HR:HR_family_G
//	wave HR_family_B = root:HR:HR_family_B
//	wave/T HR2UMR_columnlabel_sort=root:databasePanel:HR2UMR:HR2UMR_columnlabel_sort
//	wave HR2UMR_score_sort=root:databasePanel:HR2UMR:HR2UMR_score_sort
//	wave HR2UMR_mzvalue=root:databasePanel:HR2UMR:HR2UMR_mzvalue
	string PanelName = "AMS_MS_Comparisons"//v3.4D
	DoWindow/F $PanelName//v3.4D
	
	if(v_flag==0)//v3.4D
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(309,100,1708,797)/N=AMS_MS_Comparisons as "AMS_Mass_Spectral_Comparisons"//v3.4D replace space to "_"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 28,fstyle= 1
	DrawText 6,40,"AMS MS Comparisons Tool (v3.4G)"//v3.4G
	//DrawText 27,117,"Sample Mass Spectrum"
	Groupbox ADB_GB_SampleMassSpectrum, title="Sample Mass Spectrum", fsize=14, fstyle=1,pos={10.00,144.00},size={312.00,381.00}//v3.0
	SetDrawEnv fsize= 14,fstyle= 1,textxjust= 1,textyjust= 1
	//DrawText 357,111,"Database Reference Mass Spectra"
	SetDrawEnv fsize= 14,fstyle= 1
	TabControl ADB_tabs,pos={0.00,46.00},size={1394.00,647.00},proc=TabProc,fSize=14, fstyle=1//v3.0
	TabControl ADB_tabs,tabLabel(0)="UMR Data Comparison",tabLabel(1)="UMR Database"//v3.0
	TabControl ADB_tabs,tabLabel(2)="HR Data Comparison"//v3.0
	TabControl ADB_tabs,tabLabel(3)="HR Database",value= 0//v3.0
	ListBox ADB_traceSelection,pos={18.00,165.00},size={295.00,348.00},disable=2,proc=selectMSwave
	ListBox ADB_traceSelection,listWave=root:Database:columnlabel
	ListBox ADB_traceSelection,colorWave=root:Database:wholewave,mode= 2,selRow= 0
	ListBox ADB_traceSelection,editStyle= 2
	SetVariable ADB_mzMin,pos={354.00,626.00},size={97.00,18.00},proc=MassRangeset,title="m/z Min"
	SetVariable ADB_mzMin,limits={1,600,1},value=root:Globals:mzmin//v2.03
	SetVariable ADB_mzMax,pos={352.00,648.00},size={98.00,18.00},proc=MassRangeset,title="m/z Max"
	SetVariable ADB_mzMax,limits={1,600,1},value=root:Globals:mzmax//v2.03
	SetVariable ADB_mzExponent,pos={469.00,625.00},size={115.00,18.00},proc=MassRangeset,title="m/z Exponent "
	SetVariable ADB_mzExponent,limits={-inf,inf,0.5},value=root:Globals:mz_exp//v2.03
	SetVariable ADB_intExponent,pos={478.00,647.00},size={106.00,18.00},proc=MassRangeset,title="Int Exponent "
	SetVariable ADB_intExponent,limits={-inf,inf,0.5},value=root:Globals:int_exp//v2.03
	TitleBox ADB_citationOne,pos={16.00,544.00},size={298.00,23.00},disable=2,title="****No selected Comparison Constraints****"
	TitleBox ADB_citationOne,frame=2,fixedSize=1
	TitleBox ADB_citationTwo,pos={16.00,599.00},size={297.00,23.00},disable=2,title="****No selected Comparison Constraints****"//v2.03 disable when panel is open
	TitleBox ADB_citationTwo,frame=2,fixedSize=1
	Button ADB_popPlot,pos={1286.00,153.00},size={60.00,18.00},proc=PopupTheGraph,title="Pop"
	PopupMenu ADB_displayPlot,pos={759.00,152.00},size={132.00,19.00},proc=updateGraphPopMenu,title="Plot Type"
	PopupMenu ADB_displayPlot,mode=1,popvalue="Sample MS",value= #"\"Sample MS;Reference MS;Sample And Reference MS;Sample MS - Reference MS;Sample MS vs Reference MS\""
	//SetVariable db_us_threshold,pos={272.00,58.00},size={84.00,18.00},disable=1,proc=UserThresholdSet,title="Threshold"
	//SetVariable db_us_threshold,limits={0,1,0.05},value= _NUM:0.3
	CheckBox db_static_searchLimCOM,pos={1120.00,591.00},size={86.00,15.00},proc=DisplayLimChecks,title="Combination"
	CheckBox db_static_searchLimCOM,value= 1, disable = 2
	CheckBox db_static_searchLimAmb,pos={748.00,497.00},size={62.00,15.00},proc=DisplayLimChecks,title="Ambient"
	CheckBox db_static_searchLimAmb,value= 1
	CheckBox db_static_searchLimNonAmbient,pos={849.00,498.00},size={90.00,15.00},proc=DisplayLimChecks,title="Non-Ambient"
	CheckBox db_static_searchLimNonAmbient,value= 1
	TitleBox db_static_displayLimitations,pos={965.00,452.00},size={159.00,19.00},proc=DisplayLimChecks,title="Comparison Constraints"
	TitleBox db_static_displayLimitations,fSize=14,frame=0,fStyle=1
	CheckBox db_static_searchLimLNonPerturb,pos={849.00,552.00},size={96.00,15.00},proc=DisplayLimChecks,title="Non-Perturbed"  //r001
	CheckBox db_static_searchLimLNonPerturb,value= 1
	CheckBox db_static_searchLimLSubDEC,pos={748.00,604.00},size={90.00,15.00},proc=DisplayLimChecks,title="Deconvoluted"
	CheckBox db_static_searchLimLSubDEC,value= 1
	CheckBox db_static_searchLimLSubNDEC,pos={849.00,604.00},size={111.00,15.00},proc=DisplayLimChecks,title="Non-Deconvoluted" //r001
	CheckBox db_static_searchLimLSubNDEC,value= 1
	CheckBox db_static_searchLimAQ,pos={992.00,495.00},size={108.00,15.00},proc=DisplayLimChecks,title="Air Quality ACSM"
	CheckBox db_static_searchLimAQ,value= 1, disable = 2
	CheckBox db_static_searchLimAT,pos={1120.00,496.00},size={72.00,15.00},proc=DisplayLimChecks,title="ToF-ACSM"
	CheckBox db_static_searchLimAT,value= 1, disable = 2
	CheckBox db_static_searchLimQAMS,pos={1248.00,497.00},size={75.00,15.00},proc=DisplayLimChecks,title="Quad-AMS"
	CheckBox db_static_searchLimQAMS,value= 1, disable = 2
	CheckBox db_static_searchLimCAMS,pos={993.00,516.00},size={77.00,15.00},proc=DisplayLimChecks,title="C-ToF-AMS"
	CheckBox db_static_searchLimCAMS,value= 1, disable = 2
	CheckBox db_static_searchLimVHR,pos={1120.00,516.00},size={101.00,15.00},proc=DisplayLimChecks,title="HR-ToF V-Mode"
	CheckBox db_static_searchLimVHR,value= 1, disable = 2
	CheckBox db_static_searchLimWHR,pos={1248.00,517.00},size={105.00,15.00},proc=DisplayLimChecks,title="HR-ToF W-Mode"
	CheckBox db_static_searchLimWHR,value= 1, disable = 2
	CheckBox db_static_searchLimCVM,pos={1240.00,609.00},size={109.00,15.00},proc=DisplayLimChecks,title="Capture Vaporizer"
	CheckBox db_static_searchLimCVM,value= 1
	CheckBox db_static_searchLimHRD,pos={993.00,609.00},size={75.00,15.00},proc=DisplayLimChecks,title="HR to UMR"
	CheckBox db_static_searchLimHRD,value= 1, disable = 2
	GroupBox ADB_sampleTypesGB,pos={734.00,478.00},size={237.00,43.00},title="1. Database Reference Sample Type(s)"
	GroupBox ADB_VaporizerTempGB,pos={1225.00,570.00},size={150.00,62.00},title="6. Vaporizer Type(s)"
	CheckBox db_static_searchLimCVM1,pos={1240.00,589.00},size={114.00,15.00},proc=DisplayLimChecks,title="Standard Vaporizer"
	CheckBox db_static_searchLimCVM1,value= 1
	GroupBox ADB_MSResGB,pos={983.00,571.00},size={237.00,61.00},title="5. MS Resolution(s)"//v2.05 change the title
	CheckBox db_static_searchLimHRD1,pos={993.00,590.00},size={119.00,15.00},proc=DisplayLimChecks,title="Unit Mass Res. Data"
	CheckBox db_static_searchLimHRD1,value= 1, disable = 2
	GroupBox ADB_InstrumentGB,pos={983.00,474.00},size={389.00,86.00},title="4. Instrument"
	Button ADB_citation1,pos={15.00,568.00},size={145.00,20.00},disable=2,proc=getCitation1,title="Open metadata table"//v3.4D change label
	Button ADB_citation1,fStyle=1
	Button ADB_citation2,pos={16.00,626.00},size={143.00,20.00},disable=2,proc=getCitation2,title="Open metadata table"//v2.03 disable when open it//v3.4D change label
	Button ADB_citation2,fStyle=1
	GroupBox ADB_calcGB,pos={330.00,602.00},size={392.00,75.00},title="Mass Spectra Rescaling Options (all)"//v2.05 change the title
	CheckBox db_static_searchLim_Perturbed,pos={748.00,552.00},size={68.00,15.00},proc=DisplayLimChecks,title="Perturbed"
	CheckBox db_static_searchLim_Perturbed,value= 1
	CheckBox db_static_searchLim_Multiple,pos={1248.00,537.00},size={60.00,15.00},proc=DisplayLimChecks,title="Multiple"
	CheckBox db_static_searchLim_Multiple,value= 1, disable = 2
	CheckBox db_static_searchLim_Res_ALL,pos={1120.00,610.00},size={30.00,15.00},proc=DisplayLimChecks,title="All"
	CheckBox db_static_searchLim_Res_ALL,value= 1
	CheckBox db_static_searchLim_Inst_ALL,pos={1325.00,538.00},size={30.00,15.00},proc=DisplayLimChecks,title="All"
	CheckBox db_static_searchLim_Inst_ALL,value= 1
	CheckBox Check_NewMS,pos={20.00,81.00},size={60.00,15.00},proc=DisplayNewMSChecks,title="New MS"
	CheckBox Check_NewMS,value= 0
	CheckBox Check_ExistingMS,pos={107.00,81.00},size={77.00,15.00},proc=DisplayExistingMSChecks,title="Existing MS"
	CheckBox Check_ExistingMS,value= 0
	PopupMenu vw_pop_dataDFSel,pos={19.00,103.00},size={238.00,19.00},disable=2,title="Folder"
	PopupMenu vw_pop_dataDFSel,mode=6,popvalue="Select",value= #"gen_dataFolderList_wCurrDF(\"root:\")"//v3.4D change popvalue from "NewMS:" to "Select"
	PopupMenu vw_pop_MSSel,pos={301.00,103.00},size={146.00,19.00},disable=2,title="MS"
	PopupMenu vw_pop_MSSel,mode=3,popvalue="Spectra wave",value= #"gen_dataWaveList_wCurrDF()"
	PopupMenu vw_pop_mzValueSel,pos={487.00,102.00},size={158.00,19.00},disable=2,title="m/z value"
	PopupMenu vw_pop_mzValueSel,mode=1,popvalue="amus",value= #"gen_datamzWaveList()"
	PopupMenu vw_pop_SpeciesSel,pos={301.00,125.00},size={116.00,19.00},disable=2, title="Species"//v2.02
	PopupMenu vw_pop_SpeciesSel,mode=1,popvalue="Species",value= #"gen_newdataSpeciesList()"//v2.02
	PopupMenu vw_pop_SpeciesWaveSel,pos={18.00,126.00},size={165.00,19.00},disable=2,title="Species wave"//2.02
	PopupMenu vw_pop_SpeciesWaveSel,mode=4,popvalue="Species Wave",value= #"gen_dataWaveList_wCurrDF()"//v2.02
	Button ADB_NewdataCalculateButton, pos={663.00,99.00},size={60.00,23.00}, proc=ADB_Butt_DisplayNewMS_MS, title="Compare", disable=2//2.02  //r001//v3.4G change the button title
	GroupBox ADB_sampleInfoGB1,pos={11.00,527.00},size={309.00,127.00},title="Mass Spectra Info"
	SetVariable ADB_NumTag,pos={992.00,153.00},size={120.00,18.00},proc=SetTagNum,title="Number of Tags"
	SetVariable ADB_NumTag,limits={0,600,1},value= _NUM:0, bodyWidth=50  //r001
	CheckBox Check_Individual_Cal,pos={757.00,81.00},size={341.00,15.00},proc=DisplayIndividualCalChecks,title="Use Mass Spectra Rescaling Options for selected reference MS"//v2.05
	CheckBox Check_Individual_Cal,value= 0
	SetVariable ADB_mzExponent_individual_cal,pos={970.00,119.00},size={120.00,18.00},disable=2,proc=runIndividualCal,title="m/z Exponent "
	SetVariable ADB_mzExponent_individual_cal,value=root:Globals:mz_expRe//v2.03
	SetVariable ADB_intExponent_individual_cal,pos={1095.00,119.00},size={114.00,18.00},disable=2,proc=runIndividualCal,title="Int Exponent "
	SetVariable ADB_intExponent_individual_cal,value=root:Globals:int_expRe//v2.03
	ValDisplay Display_Recalculated_score,pos={1217.00,120.00},size={121.00,17.00},disable=2,title="Recalc score"
	ValDisplay Display_Recalculated_score,limits={0,0,0},barmisc={0,1000}
	ValDisplay Display_Recalculated_score,value= #"individualcal()"
	SetVariable ADB_mzMin_Individual_Calc,pos={763.00,119.00},size={97.00,18.00},disable=2,proc=runIndividualCal,title="m/z Min"
	SetVariable ADB_mzMin_Individual_Calc,limits={1,600,1},value=root:Globals:mzminRe//v2.03
	GroupBox Group_Individual_Calc,pos={755.00,100.00},size={591.00,44.00},title="Mass Spectra Rescaling Options (selected MS)"
	SetVariable ADB_mzMax_Individual_Calc,pos={866.00,119.00},size={98.00,18.00},disable=2,proc=runIndividualCal,title="m/z Max"
	SetVariable ADB_mzMax_Individual_Calc,limits={1,600,1},value=root:Globals:mzmaxRe//v2.03
	Button ADB_Open_URL1,pos={163.00,568.00},size={151.00,21.00},disable=2,proc=ADB_butt_publication1,title="Open article URL"//v3.4, v3.4D change the label
	Button ADB_Open_URL1,fStyle=1
	Button ADB_Open_URL2,pos={162.00,626.00},size={150.00,20.00},disable=2,proc=ADB_butt_publication2,title="Open article URL"//v2.03 disable when open the panel//v3.4D change the label
	Button ADB_Open_URL2,fStyle=1
	Button ADB_Open_DB_webpages,pos={14.00,657.00},size={304.00,21.00},proc=ADB_butt_DB_webpages,title="Open UMR AMS database webpage"  //r001
	Button ADB_Open_DB_webpages,fStyle=1
	GroupBox ADB_sampleTypes2,pos={734.00,533.00},size={236.00,44.00},title="2. Perturbation?"
	GroupBox ADB_sampleTypes3,pos={734.00,584.00},size={237.00,44.00},title="3. Deconvoluted?"
	CheckBox db_static_searchLimLVHR,pos={993.00,536.00},size={112.00,15.00},proc=DisplayLimChecks,title="L-ToF V-Mode"//v3.4G Long -> L
	CheckBox db_static_searchLimLVHR,value= 1, disable=2
	CheckBox db_static_searchLimLWHR,pos={1120.00,536.00},size={116.00,15.00},proc=DisplayLimChecks,title="L-ToF W-Mode"//v3.4G Long -> L
	CheckBox db_static_searchLimLWHR,value= 1, disable=2
	Button ADB_calculateButton,pos={1275.00,455.00},size={92.00,24.00},proc=Calculate_score,title="Apply"
	GroupBox ADB_sampleTypes7,pos={734.00,633.00},size={237.00,44.00},disable=1,title="Others"//v3.4F
	CheckBox db_static_searchLimFalseCOCO2,pos={749.00,654.00},size={189.00,15.00},disable=1,proc=DisplayLimChecks,title="False MS (m/z 28 ≠ 44)"//v3.4F
	CheckBox db_static_searchLimFalseCOCO2,help={""},value= 0//v3.4F, v3.4G (V=value 1 -> 0)
	
	
	//v2.03 add help description
	TitleBox db_static_displayLimitations help={"Please click 'Apply' button after selection"}
	CheckBox Check_ExistingMS help={"Compare existing mass spectrum in DB with other mass spectrum in DB"}
	CheckBox Check_NewMS help={"Compare user's own data with mass spectrum in DB."}
	GroupBox ADB_sampleTypesGB help={"Select origin of the aerosols"}
	CheckBox db_static_searchLimAmb help={"Immediate ingestion of ambient air to the instrument"}
	CheckBox db_static_searchLimNonAmbient help={"All chamber studies, any measurement whereby the spectrum is a specific source or a standard, collected on filters as a preliminary step"}
	CheckBox db_static_searchLim_Perturbed help={"OFR, TD, sample collected on filters, etc"}
	CheckBox db_static_searchLimLNonPerturb help={"No perturbation"}  //r001
	CheckBox db_static_searchLimLSubDEC help={"i.e. PMF, ME2"}
	GroupBox Group_Individual_Calc help={"Calculate cosine similarity between target mass spectrum and selected reference mass spectrum with new mass range and exponent value."}
	GroupBox ADB_calcGB help={"The parameter change is automatically applied and calculated.\n The scaled mass spectrum is calculated by the formula - Scaled mass spectrum = (m/z)^(m/z exp)*(Relative abundance of m/z)^(int exp)"}
	PopupMenu vw_pop_MSSel help={"Choose mass spectrum wave in the folder."}
	PopupMenu vw_pop_mzValueSel help={"Choose m/z wave corresponding to the mass spectrum wave."}
	PopupMenu vw_pop_SpeciesWaveSel help={"Choose the name wave corresponding to the mass spectrum."}
	PopupMenu vw_pop_SpeciesSel help={"Choose the mass spectrum that you want to compare."}
	////
	
	CheckBox Check_NewMS help={"Compare user's own data with mass spectrum in DB. The data have to be UMR or HR2UMR spectrum."}
	SetWindow kwTopWin,hook(MyHook)=MywindowHook
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:databasePanel:
	Display/W=(748,177,1365,438)/HOST=#  MSExpCalc vs mzvalue
	SetDataFolder fldrSav0
	ModifyGraph frameStyle=2
	ModifyGraph mode=1
	Label left "Relative Abundance"
	Label bottom "m/z"
	SetAxis bottom 1,300
	RenameWindow #,G0
	SetActiveSubwindow ##
	String fldrSav1= GetDataFolder(1)
	SetDataFolder root:databasePanel:
	Edit/W=(332,163,724,587)/HOST=#  columnlabel_sort,score_sort
	ModifyTable title(:columnlabel_sort)="Reference MS"
	ModifyTable title(:score_sort)="Score"
	ModifyTable alignment=0,format(Point)=1,width(Point)=36,width(columnlabel_sort)=247//v3.4D change width
	ModifyTable width(score_sort)=69//v3.4D change width
	ModifyTable statsArea=85
	ModifyTable format(score_sort)=3,digits(score_sort)=4	//r001
	SetDataFolder fldrSav1
	RenameWindow #,T0
	SetActiveSubwindow ##
	
	//v3.0 HR2UMR tab
	CheckBox HR2UMR_Check_NewMS,pos={20.00,81.00},size={60.00,15.00},title="New MS",proc=HR2UMR_DisplayExistingMSChecks
	CheckBox HR2UMR_Check_NewMS,value= 0, disable=1
	CheckBox HR2UMR_Check_ExistingMS,pos={107.00,81.00},size={77.00,15.00},title="Existing MS",proc=HR2UMR_DisplayExistingMSChecks
	CheckBox HR2UMR_Check_ExistingMS,value= 0, disable=1
	GroupBox HR2UMR_sampleInfoGB1,pos={12.00,527.00},size={311.00,129.00},title="Mass Spectra Info", disable=1
	TitleBox HR2UMR_citationOne,pos={17.00,544.00},size={300.00,23.00},disable=1,title="****No selected Comparison Constraints****"
	TitleBox HR2UMR_citationOne,fixedSize=1
	Button HR2UMR_citation1,pos={16.00,568.00},size={150.00,20.00},disable=1,proc=HR2UMR_getCitation1,title="Open metadata table"//v3.4D
	Button HR2UMR_citation1,fStyle=1
	Button HR2UMR_Open_URL1,pos={167.00,568.00},size={150.00,20.00},disable=1,proc=HR2UMR_butt_publication1,title="Open article URL"//v3.4D
	Button HR2UMR_Open_URL1,fStyle=1
	TitleBox HR2UMR_citationTwo,pos={17.00,600.00},size={298.00,23.00},disable=1,title="****No selected Comparison Constraints****"
	TitleBox HR2UMR_citationTwo,fixedSize=1
	Button HR2UMR_citation2,pos={16.00,626.00},size={150.00,20.00},disable=1,proc=HR2UMR_getCitation2,title="Open metadata table"//v3.4D
	Button HR2UMR_citation2,fStyle=1
	Button HR2UMR_Open_URL2,pos={167.00,626.00},size={150.00,20.00},disable=1,proc=HR2UMR_butt_publication2,title="Open article URL"//v3.4D
	Button HR2UMR_Open_URL2,fStyle=1
	Button HR2UMR_Open_DB_webpages,pos={17.00,660.00},size={300.00,21.00},proc=HR2UMRdb_butt_DB_webpages,title="Open HR AMS database webpage"  //r001
	Button HR2UMR_Open_DB_webpages,fStyle=1, disable=1
	ListBox HR2UMR_ADB_traceSelection pos={14.00,152.00},size={308.00,362.00}, proc=HR2UMR_List_selectMSwave,listWave=::databaseHR2UMR:HRMS_columnlabel,mode=2,colorWave=::databaseHR2UMR:HRMS_All,userColumnResize=1//v3.4 change the proc
	ListBox HR2UMR_ADB_traceSelection disable=1
	//v3.4F add 'False MS' option and change the position of checkbox and groupbox
	GroupBox HR2UMR_group_HRfamily,pos={1225.00,72.00},size={156.00,254.00},title="HR family selection", disable=1
	GroupBox HR2UMR_group_HRfamily,fSize=13,fStyle=1
	CheckBox HR2UMR_Check_HRFamilyAll,pos={1235.00,91.00},size={33.00,17.00},proc=HR2UMR_HRfamilyChecks,title="All"
	CheckBox HR2UMR_Check_HRFamilyAll,fSize=13,fStyle=1,value= 1, disable=1
	CheckBox HR2UMR_Check_HRFamilyTungsten,pos={1235.00,284.00},size={73.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="Tungsten (0 values)"//v3.4G
	CheckBox HR2UMR_Check_HRFamilyTungsten,fSize=13,fStyle=1,value= 1
	CheckBox HR2UMR_Check_HRFamilySO,pos={1301.00,264.00},size={33.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="SO"
	CheckBox HR2UMR_Check_HRFamilySO,fSize=13,fStyle=1,fColor=(65280,0,0),value= 1
	CheckBox HR2UMR_Check_HRFamilyOther,pos={1235.00,305.00},size={51.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="Other"
	CheckBox HR2UMR_Check_HRFamilyOther,fSize=13,fStyle=1,fColor=(16384,16384,39168)
	CheckBox HR2UMR_Check_HRFamilyOther,value= 1
	CheckBox HR2UMR_Check_HRFamilyNO,pos={1235.00,264.00},size={36.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="NO"
	CheckBox HR2UMR_Check_HRFamilyNO,fSize=13,fStyle=1,fColor=(0,65280,65280)
	CheckBox HR2UMR_Check_HRFamilyNO,value= 1
	CheckBox HR2UMR_Check_HRFamilyNH,pos={1235.00,244.00},size={36.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="NH"
	CheckBox HR2UMR_Check_HRFamilyNH,fSize=13,fStyle=1,fColor=(65280,43520,0)
	CheckBox HR2UMR_Check_HRFamilyNH,value= 1
	CheckBox HR2UMR_Check_HRFamilyHO,pos={1301.00,200.00},size={36.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="HO"
	CheckBox HR2UMR_Check_HRFamilyHO,fSize=13,fStyle=1,value= 1
	CheckBox HR2UMR_Check_HRFamilyCx,pos={1235.00,112.00},size={31.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="Cx"
	CheckBox HR2UMR_Check_HRFamilyCx,fSize=13,fStyle=1,value= 1
	CheckBox HR2UMR_Check_HRFamilyCSi,pos={1301.00,305.00},size={35.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="CSi"
	CheckBox HR2UMR_Check_HRFamilyCSi,fSize=13,fStyle=1,value= 1
	CheckBox HR2UMR_Check_HRFamilyCS,pos={1235.00,200.00},size={31.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="CS"
	CheckBox HR2UMR_Check_HRFamilyCS,fSize=13,fStyle=1,fColor=(8192,8192,65280)
	CheckBox HR2UMR_Check_HRFamilyCS,value= 1
	CheckBox HR2UMR_Check_HRFamilyCl,pos={1301.00,244.00},size={28.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="Cl"
	CheckBox HR2UMR_Check_HRFamilyCl,fSize=13,fStyle=1,fColor=(65280,0,52224)
	CheckBox HR2UMR_Check_HRFamilyCl,value= 1
	CheckBox HR2UMR_Check_HRFamilyCHO1N,pos={1301.00,156.00},size={61.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="CHO1N"
	CheckBox HR2UMR_Check_HRFamilyCHO1N,fSize=13,fStyle=1,fColor=(8192,24448,32640)
	CheckBox HR2UMR_Check_HRFamilyCHO1N,value= 1
	CheckBox HR2UMR_Check_HRFamilyCHO1,pos={1235.00,134.00},size={51.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="CHO1"
	CheckBox HR2UMR_Check_HRFamilyCHO1,fSize=13,fStyle=1,fColor=(32640,0,29440)
	CheckBox HR2UMR_Check_HRFamilyCHO1,value= 1
	CheckBox HR2UMR_Check_HRFamilyCHOgt1N,pos={1235.00,178.00},size={74.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="CHOgt1N"
	CheckBox HR2UMR_Check_HRFamilyCHOgt1N,fSize=13,fStyle=1
	CheckBox HR2UMR_Check_HRFamilyCHOgt1N,fColor=(16384,48896,65280),value= 1
	CheckBox HR2UMR_Check_HRFamilyCHOgt1,pos={1301.00,134.00},size={64.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="CHOgt1"
	CheckBox HR2UMR_Check_HRFamilyCHOgt1,fSize=13,fStyle=1,fColor=(65280,0,58880)
	CheckBox HR2UMR_Check_HRFamilyCHOgt1,value= 1
	CheckBox HR2UMR_Check_HRFamilyCHN,pos={1235.00,156.00},size={44.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="CHN"
	CheckBox HR2UMR_Check_HRFamilyCHN,fSize=13,fStyle=1,fColor=(36864,14592,58880)
	CheckBox HR2UMR_Check_HRFamilyCHN,value= 1
	CheckBox HR2UMR_Check_HRFamilyCH,pos={1301.00,112.00},size={34.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="CH"
	CheckBox HR2UMR_Check_HRFamilyCH,fSize=13,fStyle=1,fColor=(0,39168,0),value= 1
	CheckBox HR2UMR_Check_HRFamilyAir,pos={1235.00,222.00},size={34.00,17.00},disable=3,proc=HR2UMR_HRfamilyChecks,title="Air (0 values)"//v3.4G
	CheckBox HR2UMR_Check_HRFamilyAir,fSize=13,fStyle=1,fColor=(36864,36864,36864)
	CheckBox HR2UMR_Check_HRFamilyAir,value= 1
	
	CheckBox HR2UMR_searchLimAmb,pos={1237.00,409.00},size={62.00,15.00},proc=DisplayLimChecks,title="Ambient"
	CheckBox HR2UMR_searchLimAmb,help={"Immediate ingestion of ambient air to the instrument"}
	CheckBox HR2UMR_searchLimAmb,value= 1, disable=1
	CheckBox HR2UMR_searchLimNonAmbient,pos={1237.00,429.00},size={90.00,15.00},proc=DisplayLimChecks,title="Non-Ambient"
	CheckBox HR2UMR_searchLimNonAmbient,help={"All chamber studies, any measurement whereby the spectrum is a specific source or a standard, collected on filters as a preliminary step"}
	CheckBox HR2UMR_searchLimNonAmbient,value= 1, disable=1
	CheckBox HR2UMR_searchLimLNonPerturbed,pos={1237.00,490.00},size={96.00,15.00},proc=DisplayLimChecks,title="Non-Perturbed"
	CheckBox HR2UMR_searchLimLNonPerturbed,help={"No perturbation"},value= 1, disable=1
	CheckBox HR2UMR_searchLimLSubDEC,pos={1237.00,530.00},size={90.00,15.00},proc=DisplayLimChecks,title="Deconvoluted"
	CheckBox HR2UMR_searchLimLSubDEC,help={"i.e. PMF, ME2"},value= 1, disable=1
	CheckBox HR2UMR_searchLimLSubNDEC,pos={1237.00,550.00},size={111.00,15.00},proc=DisplayLimChecks,title="Non-Deconvluted"
	CheckBox HR2UMR_searchLimLSubNDEC,value= 1, disable=1
	GroupBox HR2UMR_sampleTypesGB,pos={1226.00,389.00},size={152.00,61.00},title="1. Sample Type(s)"
	GroupBox HR2UMR_sampleTypesGB,help={"Select origin of the aerosols"}, disable=1
	CheckBox HR2UMR_searchLim_Perturbed,pos={1237.00,470.00},size={68.00,15.00},proc=DisplayLimChecks,title="Perturbed"
	CheckBox HR2UMR_searchLim_Perturbed,help={"OFR, TD, sample collected on filters, etc"}, disable=1
	CheckBox HR2UMR_searchLim_Perturbed,value= 1
	GroupBox HR2UMR_PerturbationGB,pos={1226.00,452.00},size={152.00,61.00},title="2. Perturbation?", disable=1
	GroupBox HR2UMR_DeconGB,pos={1226.00,513.00},size={153.00,59.00},title="3. Deconvoluted?", disable=1
	CheckBox HR2UMR_searchLimCV,pos={1237.00,612.00},size={109.00,15.00},proc=DisplayLimChecks,title="Capture Vaporizer"
	CheckBox HR2UMR_searchLimCV,value= 1, disable=1
	GroupBox HR2UMR_VaporizerTempGB,pos={1226.00,573.00},size={154.00,63.00},title="4. Vaporizer Type(s)", disable=1
	CheckBox HR2UMR_searchLimSV,pos={1237.00,592.00},size={114.00,15.00},proc=DisplayLimChecks,title="Standard Vaporizer", disable=1
	CheckBox HR2UMR_searchLimSV,value= 1, disable=1
	TitleBox HR2UMR_displayLimitations,pos={1226.00,366.00},size={88.00,19.00},proc=DisplayLimChecks,title="Filter options"
	TitleBox HR2UMR_displayLimitations,fSize=14,frame=0,fStyle=1, disable=1
	Button HR2UMR_calculateButton,pos={1324.00,366.00},size={53.00,22.00},proc=HR2UMR_Calculate_score,title="Apply", disable=1
	Button HR2UMR_popMS,pos={1145.00,81.00},size={70.00,19.00},proc=HR2UMR_Butt_PopupMS,title="Pop Top", disable=1
	Button HR2UMR_poprefMS,pos={1138.00,386.00},size={76.00,19.00},proc=HR2UMR_Butt_PopuprefMS,title="Pop Bottom", disable=1
	SetVariable HR2UMR_mzMin,pos={354.00,629.00},size={97.00,18.00},proc=MassRangeset,title="m/z Min"
	SetVariable HR2UMR_mzMin,limits={1,600,1},value= root:Globals:HR2UMR_mzmin, disable=1
	SetVariable HR2UMR_mzMax,pos={352.00,651.00},size={98.00,18.00},proc=MassRangeset,title="m/z Max"
	SetVariable HR2UMR_mzMax,limits={1,600,1},value= root:Globals:HR2UMR_mzmax, disable=1
	SetVariable HR2UMR_mzExponent,pos={466.00,629.00},size={115.00,18.00},proc=MassRangeset,title="m/z Exponent "
	SetVariable HR2UMR_mzExponent,limits={0,600,0.5},value= root:Globals:HR2UMR_mz_exp, disable=1
	SetVariable HR2UMR_intExponent,pos={475.00,651.00},size={106.00,18.00},proc=MassRangeset,title="Int Exponent "
	SetVariable HR2UMR_intExponent,limits={0,600,0.5},value= root:Globals:HR2UMR_int_exp, disable=1
	GroupBox HR2UMR_calcGB,pos={341.00,604.00},size={249.00,70.00},title="Mass Spectra Rescaling Options (all)", disable=1
	PopupMenu HR2UMR_vw_pop_dataDFSel,pos={19.00,103.00},size={238.00,19.00},disable=1,title="Folder"
	PopupMenu HR2UMR_vw_pop_dataDFSel,mode=6,popvalue="Select",value= #"gen_dataFolderList_wCurrDF(\"root:\")"//v3.4D change popvalue from "NewMS:" to "Select"
	PopupMenu HR2UMR_vw_pop_MSSel,pos={311.00,103.00},size={146.00,19.00},disable=1,title="MS"
	PopupMenu HR2UMR_vw_pop_MSSel,help={"Choose mass spectrum wave in the folder."}
	PopupMenu HR2UMR_vw_pop_MSSel,mode=3,popvalue="Spectra wave",value= #"gen_dataWaveList_wCurrDF()"
	PopupMenu HR2UMR_vw_pop_mzValueSel,pos={500.00,102.00},size={158.00,19.00},disable=1,title="m/z value"
	PopupMenu HR2UMR_vw_pop_mzValueSel,help={"Choose m/z wave corresponding to the mass spectrum wave."}
	PopupMenu HR2UMR_vw_pop_mzValueSel,mode=1,popvalue="amus",value= #"gen_datamzWaveList()"
	PopupMenu HR2UMR_vw_pop_SpeciesSel,pos={311.00,125.00},size={116.00,19.00},disable=1,title="Species"
	PopupMenu HR2UMR_vw_pop_SpeciesSel,help={"Choose the mass spectrum that you want to compare."}
	PopupMenu HR2UMR_vw_pop_SpeciesSel,mode=1,popvalue="Species",value= #"gen_newdataSpeciesList()"
	PopupMenu HR2UMR_vw_pop_SpeciesWaveSel,pos={18.00,126.00},size={165.00,19.00},disable=1,title="Species wave"
	PopupMenu HR2UMR_vw_pop_SpeciesWaveSel,help={"Choose the name wave corresponding to the mass spectrum."}
	PopupMenu HR2UMR_vw_pop_SpeciesWaveSel,mode=4,popvalue="Species Wave",value= #"gen_dataWaveList_wCurrDF()"
	Button HR2UMR_NewdataCalculateButton,pos={667.00,102.00},size={60.00,23.00},disable=1,proc=ADB_Butt_DisplayNewMS_MS,title="Compare"
	Button HR2UMR_butt_CalcScoreHRfamily,pos={1227.00,328.00},size={154.00,36.00},proc=ADB_Butt_DisplayNewMS_MS,title="Calculate score with\r selected HR families",disable=1//3.4F change the position and size the button
	Button HR2UMR_butt_sortUMR,pos={517.00,128.00},size={80.00,21.00},proc=HR2UMR_butt_sort_UMR,title="UMR score",disable=1//v3.4B
	Button HR2UMR_butt_sortHRfamily,pos={599.00,128.00},size={128.00,21.00},proc=HR2UMR_butt_sort_HRfam,title="Score with HR family",disable=1//v3.4B
	TitleBox HR2UMR_sortTItle,pos={464.00,128.00},size={47.00,19.00},proc=DisplayLimChecks,title="Sort by:",disable=1//v3.4B
	TitleBox HR2UMR_sortTItle,fSize=14,frame=0,fStyle=0//v3.4B
	TitleBox HR2UMR_title_sampleMSplot,pos={742.00,82.00},size={75.00,19.00},proc=DisplayLimChecks,title="Sample MS"//v3.4B
	TitleBox HR2UMR_title_sampleMSplot,fSize=14,frame=0,fStyle=1,disable=1//v3.4B
	TitleBox HR2UMR_title_refMSplot,pos={739.00,387.00},size={150.00,19.00},proc=DisplayLimChecks,title="Selected reference MS"//3.4B
	TitleBox HR2UMR_title_refMSplot,fSize=14,frame=0,fStyle=1,disable=1//3.4B
	GroupBox HR2UMR_GroupBox_Others,pos={1228.00,635.00},size={154.00,49.00},title="Others"//v3.4F
	CheckBox HR2UMR_searchLimFalseCOCO2,pos={1237.00,657.00},size={111.00,30.00},proc=DisplayLimChecks,title="False MS (m/z 28 ≠ 44)"//v3.4F
	CheckBox HR2UMR_searchLimFalseCOCO2,value= 0//v3.4F, v3.4G (V_value = 1 -> 0)
	
	
	String fldrSav2= GetDataFolder(1)
	SetDataFolder root:databasePanel:HR2UMR:
	Edit/W=(343,153,727,593)/HOST=# /Hide=1  HR2UMR_columnlabel_sort,HR2UMR_score_sort, HR2UMR_scoreHRfam_sort//v3.4
	ModifyTable title(:HR2UMR_columnlabel_sort)="Reference MS"
	ModifyTable title(:HR2UMR_score_sort)="UMR Score"//v3.4B change 'score' -> 'UMR score'
	ModifyTable title(:HR2UMR_scoreHRfam_sort)="Score with HR family"//v3.4B change 'by' -> 'with'
	ModifyTable format(HR2UMR_score_sort)=3,digits(HR2UMR_score_sort)=4  //r001
	ModifyTable format(HR2UMR_scoreHRfam_sort)=3,digits(HR2UMR_scoreHRfam_sort)=4  //r001
	ModifyTable width(Point)=36, width(HR2UMR_columnlabel_sort)=170, width(HR2UMR_score_sort)=60//v3.4D
	ModifyTable format(Point)=1
	ModifyTable statsArea=85
	SetDataFolder fldrSav2
	RenameWindow #,T1
	SetActiveSubwindow ##
	String fldrSav3= GetDataFolder(1)
	SetDataFolder root:databasePanel:HR2UMR
	Hr2UMR_PlotMS()
	SetDataFolder fldrSav3
	ModifyGraph frameStyle=2
	RenameWindow #,G1
	SetActiveSubwindow ##
	
	String fldrSav4= GetDataFolder(1)
	SetDataFolder root:databasePanel:HR2UMR:
	HR2UMR_PlotrefMS()
	SetDataFolder fldrSav4
	ModifyGraph frameStyle=2
	RenameWindow #,G2
	SetActiveSubwindow ##
	
	//UMR database tab
	ListBox UMRDB_listbox,pos={14.00,103.00},size={377.00,579.00},disable=1,proc=UMRDB_selectMSwave
	ListBox UMRDB_listbox,listWave=root:database:columnlabel,mode= 1,selRow= 0
	SetVariable UMRDB_NumTag,pos={1248.00,83.00},size={120.00,18.00},proc=SetTagNum,title="Number of Tags"
	SetVariable UMRDB_NumTag,limits={0,600,1},value= _NUM:0, disable=1, bodyWidth=50  //r001
	TitleBox UMRDB_Titlebox,pos={16.00,69.00},size={351.00,28.00},title="Unit Mass Resolution Mass Spectrum"
	TitleBox UMRDB_Titlebox,fSize=20,frame=0,fStyle=1, disable=1
	Button UMRDB_butt_openWebpage,pos={413.00,83.00},size={178.00,19.00},proc=ADB_butt_DB_webpages,title="Open UMR DB webpage"
	Button UMRDB_butt_openWebpage,fStyle=1,fColor=(49151,65535,65535), disable=1
	TitleBox UMRDB_title_AerOri,pos={415.00,409.00},size={98.00,19.00},title="Aerosol Origin:"
	TitleBox UMRDB_title_AerOri,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_AerPer,pos={415.00,527.00},size={126.00,19.00},title="Aerosol Perturbation:"
	TitleBox UMRDB_title_AerPer,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_Analysis,pos={415.00,651.00},size={126.00,19.00},title="Analysis:"
	TitleBox UMRDB_title_Analysis,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_Citation,pos={808.00,525.00},size={126.00,19.00},title="Citation:"
	TitleBox UMRDB_title_Citation,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_EI,pos={808.00,476.00},size={126.00,19.00},title="EI energy:"
	TitleBox UMRDB_title_EI,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_Group,pos={828.00,553.00},size={126.00,19.00},title="Group:"
	TitleBox UMRDB_title_Group,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_Inst,pos={808.00,409.00},size={126.00,19.00},title="Instrument:"
	TitleBox UMRDB_title_Inst,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_Res,pos={1030.00,409.00},size={126.00,19.00},title="Resolution:"
	TitleBox UMRDB_title_Res,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_Descr,pos={808.00,621.00},size={126.00,19.00},title="Description:"
	TitleBox UMRDB_title_Descr,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_Vap,pos={808.00,442.00},size={126.00,19.00},title="Vaporizer:"
	TitleBox UMRDB_title_Vap,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_VapTemp,pos={1030.00,440.00},size={126.00,19.00},title="Vaporizer Temp (C):"
	TitleBox UMRDB_title_VapTemp,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_AerPerType,pos={436.00,556.00},size={126.00,19.00},title="Type:"
	TitleBox UMRDB_title_AerPerType,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_AerPerCom,pos={436.00,588.00},size={126.00,19.00},title="Comment:"
	TitleBox UMRDB_title_AerPerCom,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_AerOriType,pos={432.00,440.00},size={126.00,19.00},title="Type:"
	TitleBox UMRDB_title_AerOriType,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_AerOriCom,pos={432.00,471.00},size={126.00,19.00},title="Comment:"
	TitleBox UMRDB_title_AerOriCom,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_ExpName,pos={828.00,585.00},size={126.00,19.00},title="Experimenter Name"
	TitleBox UMRDB_title_ExpName,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	TitleBox UMRDB_title_DAQcom,pos={1030.00,475.00},size={126.00,19.00},title="Comment:"
	TitleBox UMRDB_title_DAQcom,fSize=13,frame=0,fStyle=0,fixedSize=1, disable=1
	
// r001 changed frames to be single, frame=2, so little boxes do not show up in Igor 7,8
	TitleBox UMRDB_titleDesc_AerOri,pos={542.00,406.00},size={251.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_AerOri,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_AerOriType,pos={542.00,436.00},size={251.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_AerOriType,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_AerOriCom,pos={542.00,466.00},size={251.00,52.00},title="No selection"
	TitleBox UMRDB_titleDesc_AerOriCom,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_AerPer,pos={542.00,522.00},size={250.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_AerPer,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_AerPerType,pos={542.00,553.00},size={250.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_AerPerType,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_AerPerCom,pos={542.00,583.00},size={250.00,53.00},title="No selection"
	TitleBox UMRDB_titleDesc_AerPerCom,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_Analysis,pos={542.00,647.00},size={122.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_Analysis,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_Inst,pos={888.00,406.00},size={122.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_Inst,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_Vap,pos={888.00,438.00},size={122.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_Vap,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_VapTemp,pos={1151.00,438.00},size={152.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_VapTemp,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_Res,pos={1151.00,406.00},size={153.00,26.00},title="No selection"
	TitleBox UMRDB_titleDesc_Res,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_EI,pos={888.00,471.00},size={122.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_EI,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_Cit,pos={888.00,521.00},size={415.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_Cit,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_Group,pos={888.00,551.00},size={416.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_Group,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_ExpName,pos={965.00,582.00},size={122.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_ExpName,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_Desc,pos={888.00,617.00},size={415.00,57.00},title="No selection"
	TitleBox UMRDB_titleDesc_Desc,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	TitleBox UMRDB_titleDesc_DAQcom,pos={1151.00,471.00},size={153.00,27.00},title="No selection"
	TitleBox UMRDB_titleDesc_DAQcom,fSize=13,frame=2,fStyle=0,fixedSize=1, disable=0
	Button UMRDB_Open_URL,pos={1307.00,520.00},size={64.00,25.00},proc=UMRdb_butt_publication1,title="Open URL"
	Button UMRDB_Open_URL,fStyle=1, disable=1
	Button UMRDB_butt_citation,pos={1308.00,617.00},size={66.00,55.00},proc=UMRdb_getCitation1,title="Open\rTable"
	Button UMRDB_butt_citation,fStyle=1, disable=1
	
	String fldrSav5= GetDataFolder(1)
	SetDataFolder root:databasePanel:
	Display/W=(414,107,1372,394)/HOST=# /Hide=1  UMRDB_MS_origin vs mzvalue
	SetDataFolder fldrSav5
	ModifyGraph frameStyle=2, nticks(bottom)=15//v3.4D increase grid ticks
	ModifyGraph mode=1
	Label left "Relative Abundance"
	Label bottom "m/z"
	RenameWindow #,G3
	SetActiveSubwindow ##
//	String fldrSav6= GetDataFolder(1)
//	SetDataFolder root:databasePanel:
//	Edit/W=(413,433,778,670)/HOST=# /Hide=1  UMRDB_citation1info
//	ModifyTable format(Point)=1
//	ModifyTable statsArea=85
//	SetDataFolder fldrSav6
//	RenameWindow #,T2
//	SetActiveSubwindow ##
	
	//HR2UMR database tab
	ListBox HR2UMRDB_listbox,pos={11.00,104.00},size={366.00,572.00},proc=HR2UMRdb_selectMSwave
	ListBox HR2UMRDB_listbox,listWave=root:databaseHR2UMR:HRMS_columnlabel,mode= 1
	ListBox HR2UMRDB_listbox,selRow= 0, disable=1
	TitleBox HR2UMRDB_Titlebox,pos={14.00,70.00},size={302.00,28.00},title="High Resolution Mass Spectrum"
	TitleBox HR2UMRDB_Titlebox,fSize=20,frame=0,fStyle=1, disable=1
	Button HR2UMRDB_butt_openWebpage,pos={395.00,77.00},size={223.00,23.00},proc=HR2UMRdb_butt_DB_webpages,title="Open HR database webpage"
	Button HR2UMRDB_butt_openWebpage,fStyle=1,fColor=(49151,65535,65535), disable=1
	Button HR2UMRDB_butt_colorlegend,pos={624.00,77.00},size={186.00,23.00},proc=HR2UMR_butt_familyTableLegend,title="HR family color legend plot", disable=1
	GroupBox HR2UMRDB_group_HRfamily,pos={1225.00,101.00},size={155.00,306.00},title="HR family selection"
	GroupBox HR2UMRDB_group_HRfamily,fSize=13,fStyle=1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyAll,pos={1236.00,127.00},size={33.00,17.00},proc=HR2UMR_HRfamilyChecks,title="All"
	CheckBox HR2UMRdb_Check_HRFamilyAll,fSize=13,fStyle=1,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyTungsten,pos={1236.00,353.00},size={73.00,17.00},proc=HR2UMR_HRfamilyChecks,title="Tungsten"
	CheckBox HR2UMRdb_Check_HRFamilyTungsten,fSize=13,fStyle=1,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilySO,pos={1302.00,305.00},size={33.00,17.00},proc=HR2UMR_HRfamilyChecks,title="SO"
	CheckBox HR2UMRdb_Check_HRFamilySO,fSize=13,fStyle=1,fColor=(65280,0,0),value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyOther,pos={1236.00,379.00},size={51.00,17.00},proc=HR2UMR_HRfamilyChecks,title="Other"
	CheckBox HR2UMRdb_Check_HRFamilyOther,fSize=13,fStyle=1
	CheckBox HR2UMRdb_Check_HRFamilyOther,fColor=(16384,16384,39168),value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyNO,pos={1236.00,328.00},size={36.00,17.00},proc=HR2UMR_HRfamilyChecks,title="NO"
	CheckBox HR2UMRdb_Check_HRFamilyNO,fSize=13,fStyle=1,fColor=(0,65280,65280)
	CheckBox HR2UMRdb_Check_HRFamilyNO,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyNH,pos={1236.00,303.00},size={36.00,17.00},proc=HR2UMR_HRfamilyChecks,title="NH"
	CheckBox HR2UMRdb_Check_HRFamilyNH,fSize=13,fStyle=1,fColor=(65280,43520,0)
	CheckBox HR2UMRdb_Check_HRFamilyNH,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyHO,pos={1302.00,254.00},size={36.00,17.00},proc=HR2UMR_HRfamilyChecks,title="HO"
	CheckBox HR2UMRdb_Check_HRFamilyHO,fSize=13,fStyle=1,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCx,pos={1236.00,152.00},size={31.00,17.00},proc=HR2UMR_HRfamilyChecks,title="Cx"
	CheckBox HR2UMRdb_Check_HRFamilyCx,fSize=13,fStyle=1,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCSi,pos={1302.00,381.00},size={35.00,17.00},proc=HR2UMR_HRfamilyChecks,title="CSi"
	CheckBox HR2UMRdb_Check_HRFamilyCSi,fSize=13,fStyle=1,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCS,pos={1236.00,253.00},size={31.00,17.00},proc=HR2UMR_HRfamilyChecks,title="CS"
	CheckBox HR2UMRdb_Check_HRFamilyCS,fSize=13,fStyle=1,fColor=(8192,8192,65280)
	CheckBox HR2UMRdb_Check_HRFamilyCS,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCl,pos={1302.00,279.00},size={28.00,17.00},proc=HR2UMR_HRfamilyChecks,title="Cl"
	CheckBox HR2UMRdb_Check_HRFamilyCl,fSize=13,fStyle=1,fColor=(65280,0,52224)
	CheckBox HR2UMRdb_Check_HRFamilyCl,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCHO1N,pos={1302.00,203.00},size={61.00,17.00},proc=HR2UMR_HRfamilyChecks,title="CHO1N"
	CheckBox HR2UMRdb_Check_HRFamilyCHO1N,fSize=13,fStyle=1
	CheckBox HR2UMRdb_Check_HRFamilyCHO1N,fColor=(8192,24448,32640),value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCHO1,pos={1236.00,177.00},size={51.00,17.00},proc=HR2UMR_HRfamilyChecks,title="CHO1"
	CheckBox HR2UMRdb_Check_HRFamilyCHO1,fSize=13,fStyle=1,fColor=(32640,0,29440)
	CheckBox HR2UMRdb_Check_HRFamilyCHO1,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCHOgt1N,pos={1237.00,227.00},size={74.00,17.00},proc=HR2UMR_HRfamilyChecks,title="CHOgt1N"
	CheckBox HR2UMRdb_Check_HRFamilyCHOgt1N,fSize=13,fStyle=1
	CheckBox HR2UMRdb_Check_HRFamilyCHOgt1N,fColor=(16384,48896,65280),value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCHOgt1,pos={1302.00,179.00},size={64.00,17.00},proc=HR2UMR_HRfamilyChecks,title="CHOgt1"
	CheckBox HR2UMRdb_Check_HRFamilyCHOgt1,fSize=13,fStyle=1,fColor=(65280,0,58880)
	CheckBox HR2UMRdb_Check_HRFamilyCHOgt1,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCHN,pos={1236.00,202.00},size={44.00,17.00},proc=HR2UMR_HRfamilyChecks,title="CHN"
	CheckBox HR2UMRdb_Check_HRFamilyCHN,fSize=13,fStyle=1,fColor=(36864,14592,58880)
	CheckBox HR2UMRdb_Check_HRFamilyCHN,value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyCH,pos={1302.00,152.00},size={34.00,17.00},proc=HR2UMR_HRfamilyChecks,title="CH"
	CheckBox HR2UMRdb_Check_HRFamilyCH,fSize=13,fStyle=1,fColor=(0,39168,0),value= 1, disable=1
	CheckBox HR2UMRdb_Check_HRFamilyAir,pos={1236.00,278.00},size={34.00,17.00},proc=HR2UMR_HRfamilyChecks,title="Air"
	CheckBox HR2UMRdb_Check_HRFamilyAir,fSize=13,fStyle=1,fColor=(36864,36864,36864)
	CheckBox HR2UMRdb_Check_HRFamilyAir,value= 1, disable=1
	TitleBox HR2UMRDB_title_AerOri,pos={394.00,418.00},size={98.00,19.00},title="Aerosol Origin:"
	TitleBox HR2UMRDB_title_AerOri,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_AerPer,pos={394.00,536.00},size={126.00,19.00},title="Aerosol Perturbation:"
	TitleBox HR2UMRDB_title_AerPer,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_Analysis,pos={394.00,660.00},size={126.00,19.00},title="Analysis:"
	TitleBox HR2UMRDB_title_Analysis,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_Citation,pos={787.00,534.00},size={126.00,19.00},title="Citation:"
	TitleBox HR2UMRDB_title_Citation,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_EI,pos={787.00,485.00},size={126.00,19.00},title="EI energy:"
	TitleBox HR2UMRDB_title_EI,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_Group,pos={807.00,562.00},size={126.00,19.00},title="Group:"
	TitleBox HR2UMRDB_title_Group,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_Inst,pos={787.00,418.00},size={126.00,19.00},title="Instrument:"
	TitleBox HR2UMRDB_title_Inst,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_Res,pos={1009.00,418.00},size={126.00,19.00},title="Resolution:"
	TitleBox HR2UMRDB_title_Res,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_Descr,pos={787.00,630.00},size={126.00,19.00},title="Description:"
	TitleBox HR2UMRDB_title_Descr,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_Vap,pos={787.00,451.00},size={126.00,19.00},title="Vaporizer:"
	TitleBox HR2UMRDB_title_Vap,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_VapTemp,pos={1009.00,449.00},size={126.00,19.00},title="Vaporizer Temp (C):"
	TitleBox HR2UMRDB_title_VapTemp,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_AerPerType,pos={415.00,565.00},size={126.00,19.00},title="Type:"
	TitleBox HR2UMRDB_title_AerPerType,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_AerPerCom,pos={415.00,597.00},size={126.00,19.00},title="Comment:"
	TitleBox HR2UMRDB_title_AerPerCom,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_AerOriType,pos={411.00,449.00},size={126.00,19.00},title="Type:"
	TitleBox HR2UMRDB_title_AerOriType,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_AerOriCom,pos={411.00,480.00},size={126.00,19.00},title="Comment:"
	TitleBox HR2UMRDB_title_AerOriCom,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_ExpName,pos={807.00,594.00},size={126.00,19.00},title="Experimenter Name"
	TitleBox HR2UMRDB_title_ExpName,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1
	TitleBox HR2UMRDB_title_DAQcom,pos={1009.00,484.00},size={126.00,19.00},title="Comment:"
	TitleBox HR2UMRDB_title_DAQcom,fSize=13,frame=0,fStyle=0,fixedsize=1, disable=1

	TitleBox HR2UMRDB_titleDesc_AerOri,pos={521.00,415.00},size={251.00,27.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_AerOri,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_AerOriType,pos={521.00,445.00},size={251.00,27.00}
	TitleBox HR2UMRDB_titleDesc_AerOriType,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_AerOriCom,pos={521.00,475.00},size={251.00,52.00}
	TitleBox HR2UMRDB_titleDesc_AerOriCom,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_AerPer,pos={521.00,531.00},size={250.00,27.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_AerPer,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_AerPerType,pos={521.00,562.00},size={250.00,27.00}
	TitleBox HR2UMRDB_titleDesc_AerPerType,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_AerPerCom,pos={521.00,592.00},size={250.00,53.00}
	TitleBox HR2UMRDB_titleDesc_AerPerCom,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_Analysis,pos={521.00,656.00},size={122.00,27.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_Analysis,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_Inst,pos={867.00,415.00},size={122.00,27.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_Inst,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_Vap,pos={867.00,447.00},size={122.00,27.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_Vap,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_VapTemp,pos={1130.00,447.00},size={152.00,27.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_VapTemp,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_Res,pos={1130.00,415.00},size={153.00,26.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_Res,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_EI,pos={867.00,480.00},size={122.00,27.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_EI,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_Cit,pos={867.00,530.00},size={415.00,27.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_Cit,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_Group,pos={867.00,560.00},size={416.00,27.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_Group,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_ExpName,pos={944.00,591.00},size={122.00,27.00}
	TitleBox HR2UMRDB_titleDesc_ExpName,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_Desc,pos={867.00,626.00},size={415.00,57.00},title="No selection"
	TitleBox HR2UMRDB_titleDesc_Desc,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	TitleBox HR2UMRDB_titleDesc_DAQcom,pos={1130.00,480.00},size={153.00,27.00}
	TitleBox HR2UMRDB_titleDesc_DAQcom,fSize=13,frame=2,fStyle=0,fixedsize=1, disable=0
	
	Button HR2UMRDB_Open_URL,pos={1286.00,529.00},size={64.00,25.00},proc=HR2UMRdb_butt_publication1,title="Open URL"
	Button HR2UMRDB_Open_URL,fStyle=1, disable=1
	Button HR2UMRDB_butt_citation,pos={1287.00,626.00},size={66.00,55.00},proc=HR2UMRdb_getCitation1,title="Open\rTable"
	Button HR2UMRDB_butt_citation,fStyle=1, disable=1

	String fldrSav7= GetDataFolder(1)
	SetDataFolder root:databasePanel:HR2UMR:HR2UMRdb:
	Hr2UMRdb_PlotMS()
	SetDataFolder fldrSav7
	ModifyGraph frameStyle=2, nticks(bottom)=15//v3.4D increase grid ticks
	RenameWindow #,G4
	SetActiveSubwindow ##
//	String fldrSav8= GetDataFolder(1)
//	SetDataFolder root:databasePanel:HR2UMR:HR2UMRdb:
//	Edit/W=(392,435,776,678)/HOST=# /Hide=1  HR2UMRdb_citation1Info
//	ModifyTable format(Point)=1
//	ModifyTable statsArea=85
//	SetDataFolder fldrSav8
//	RenameWindow #,T3
//	SetActiveSubwindow ##
		
	initializaDBPanel()
	
	Endif //v3.4D add Dowindow and if(v_flag==0)
EndMacro

function initializaDBPanel()

	//r001 DTS initialize by calling the tab function
	Struct WMTabControlAction tca
	tca.eventCode=2
	tca.tab=0  // presumes that the first tab is selected first
	TabProc(tca) 
End


