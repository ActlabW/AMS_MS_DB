#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// r001 DTS 20230322
// 		Added the function HR2UMRdb_getCitation1 which seems to have been missing.
//		Added the static function DescriptionFormatting for formatting the description string with carriage returns
//		Modified UMRdb_updateInfo and HR2UMRDB_updateinfo to use global strings so that they could be formatted nicely
//		Fixed typo in HR2UMR_getNewMS_MS



strConstant HR2UMRMSPlot = "AMS_MS_Comparisons#G1"
strConstant HR2UMRrefMSPlot = "AMS_MS_Comparisons#G2"
strConstant HR2UMRdbMSPlot = "AMS_MS_Comparisons#G4"

function matchingColumnlabel()
	wave/T columnlabel = root:database:columnlabel
	wave columnlabel_index = root:database:columnlabel_index
	
	make/T/n=445 matchedColumnlabel
	
	variable i
	
	for(i=0;i<dimsize(columnlabel,0);i++)
		variable index = columnlabel_index[i]
		matchedcolumnlabel[i] = columnlabel[index]
	
	endfor	


end


Function TabProc(tca) : TabControl
	Struct WMTabControlAction &tca
	
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName

	string ctrlList = controlNameList(""), ctrlHide = "", ctrlShow = ""
	variable i
	variable tabNum = tca.tab
	
	switch (tca.eventCode)
		case 2:
			controlInfo ADB_tabs
			string TabStr = S_value
			
			strswitch (TabStr)
				case "UMR Data comparison":
					for(i=0;i<itemsInlist(ctrlList);i++)
						if(strSearch(stringFromList(i,ctrlList,";"), "HR2UMR_",0,2) == 0)// || cmpstr(stringFromList(i,ctrlList,";"),"ADB_tabs") == 0)
							ctrlhide += stringFromList(i, ctrlList, ";") + ";"
						elseif(strSearch(stringFromList(i,ctrlList,";"), "HR2UMRDB_",0,2) == 0 || strSearch(stringFromList(i,ctrlList,";"), "UMRDB_",0,2) == 0)
							ctrlhide += stringFromList(i, ctrlList, ";") + ";"
						else
							ctrlshow += stringFromList(i, ctrlList, ";") + ";"
						endif
					endfor			
					
					modifyControlList/Z ctrlShow, disable=0
					modifyControlList/Z ctrlHide, disable=1
					
//					ListBox UMRDB_listbox, disable=1
//					SetVariable UMRDB_NumTag, disable=1
//					TitleBox UMRDB_Titlebox, disable=1
//					Button UMRDB_butt_openWebpage, disable=1
//					
//					ListBox HR2UMRDB_listbox, disable=1
//					TitleBox HR2UMRDB_Titlebox, disable=1
//					Button HR2UMRDB_butt_openWebpage, disable=1
//					Button HR2UMRDB_butt_colorlegend, disable=1
//					CheckBox HR2UMRdb_Check_HRfamilyAll, disable=1
//					GroupBox HR2UMRDB_group_HRfamily, disable=1
//					
//					string HR2UMRPath = "HR2UMRdb_Check_HRfamily"
//					variable j
//					for(j=0;j<dimsize(HR_familyName,0);j++)
//						string HR2UMRdbCheckName = HR2UMRPath + HR_familyName[j]
//						CheckBox $HR2UMRdbCheckName, disable=1		
//					endfor
//					
//					
//					
//					Popupmenu HR2UMR_vw_pop_dataDFSel, disable=1
//					Popupmenu HR2UMR_vw_pop_MSSel, disable=1
//					Popupmenu HR2UMR_vw_pop_mzValueSel, disable=1
//					Popupmenu HR2UMR_vw_pop_SpeciesWaveSel, disable=1
//					Popupmenu HR2UMR_vw_pop_SpeciesSel, disable=1
					
					EnableNewMsCheckBOX()
					EnableIndvidualCal()
					
					controlinfo db_static_searchLim_Inst_ALL
					variable Inst_Check = V_value
					EnableCheckBox(Inst_Check,"db_static_searchLim_Inst_ALL")
					controlInfo db_static_searchLim_Res_ALL
					variable Res_check = V_value
					EnableCheckBox(Res_check,"db_static_searchLim_Res_ALL")
					
					Setwindow AMS_MS_Comparisons#T0, hide=0
					SetWindow AMS_MS_Comparisons#G0, hide=0
					SetWIndow AMS_MS_Comparisons#T1, hide=1
					SetWindow AMS_MS_Comparisons#G1, hide=1
					SetWindow AMS_MS_Comparisons#G2, hide=1
					SetWindow AMS_MS_Comparisons#G3, hide=1
					//SetWindow AMS_MS_Comparisons#T2, hide=1
					SetWindow AMS_MS_Comparisons#G4, hide=1
					//SetWindow AMS_MS_Comparisons#T3, hide=1
					
					break
					
				case "HR Data Comparison"://When HR2UMR instrument is alwasy set as 'All'
					for(i=0;i<itemsInlist(ctrlList);i++)
						if(strSearch(stringFromList(i,ctrlList,";"), "HR2UMR_",0,2) == 0 || cmpstr(stringFromList(i,ctrlList,";"),"ADB_tabs") == 0)
							ctrlshow += stringFromList(i, ctrlList, ";") + ";"
						else
							ctrlhide += stringFromList(i, ctrlList, ";") + ";"
						endif
					endfor
				
					modifyControlList/Z ctrlShow, disable=0
					modifyControlList/Z ctrlHide, disable=1
					
					HR2UMR_EnableNewMSCheckBox()
					HR2UMR_EnableCheckbox()//v3.4
					
					Setwindow AMS_MS_Comparisons#T0, hide=1
					Setwindow AMS_MS_Comparisons#G0, hide=1
					SetWindow AMS_MS_Comparisons#T1, hide=0
					SetWindow AMS_MS_Comparisons#G1, hide=0
					SetWindow AMS_MS_Comparisons#G2, hide=0
					SetWindow AMS_MS_Comparisons#G3, hide=1
					//SetWindow AMS_MS_Comparisons#T2, hide=1
					SetWindow AMS_MS_Comparisons#G4, hide=1
					//SetWindow AMS_MS_Comparisons#T3, hide=1
											
					break
				case "UMR Database":
					for(i=0;i<itemsInlist(ctrlList);i++)
						if(strSearch(stringFromList(i,ctrlList,";"), "UMRDB_",0,2) == 0 ||cmpstr(stringFromList(i,ctrlList,";"),"ADB_tabs") == 0)
							ctrlshow += stringFromList(i, ctrlList, ";") + ";"
						else
							ctrlhide += stringFromList(i, ctrlList, ";") + ";"
						endif
					endfor
					
					modifyControlList/Z ctrlShow, disable=0
					modifyControlList/Z ctrlHide, disable=1
					
					Setwindow AMS_MS_Comparisons#T0, hide=1
					Setwindow AMS_MS_Comparisons#G0, hide=1
					SetWindow AMS_MS_Comparisons#T1, hide=1
					SetWindow AMS_MS_Comparisons#G1, hide=1
					SetWindow AMS_MS_Comparisons#G2, hide=1
					SetWindow AMS_MS_Comparisons#G3, hide=0
					//SetWindow AMS_MS_Comparisons#T2, hide=0
					SetWindow AMS_MS_Comparisons#G4, hide=1
					//SetWindow AMS_MS_Comparisons#T3, hide=1
					
					break
				case "HR Database":
					for(i=0;i<itemsInlist(ctrlList);i++)
						if(strSearch(stringFromList(i,ctrlList,";"), "HR2UMRDB_",0,2) == 0 || cmpstr(stringFromList(i,ctrlList,";"),"ADB_tabs") == 0)
							ctrlshow += stringFromList(i, ctrlList, ";") + ";"
						else
							ctrlhide += stringFromList(i, ctrlList, ";") + ";"
						endif
					endfor
					
					modifyControlList/Z ctrlShow, disable=0
					modifyControlList/Z ctrlHide, disable=1
					
					Setwindow AMS_MS_Comparisons#T0, hide=1
					Setwindow AMS_MS_Comparisons#G0, hide=1
					SetWindow AMS_MS_Comparisons#T1, hide=1
					SetWindow AMS_MS_Comparisons#G1, hide=1
					SetWindow AMS_MS_Comparisons#G2, hide=1
					SetWindow AMS_MS_Comparisons#G3, hide=1
					//SetWindow AMS_MS_Comparisons#T2, hide=1
					SetWindow AMS_MS_Comparisons#G4, hide=0
					//SetWindow AMS_MS_Comparisons#T3, hide=0
				
					break
				default:
					break
					
			endswitch
			
	endswitch
	
	return 0
	
End	


Function HR2UMR_PlotMS()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B
	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
	
	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax
	
	string HR2UMRMSPath = "root:databasepanel:HR2UMR:HR2UMR_MS_"
	string wave2Plotlist=""
	variable i
	variable yaxisMax = 0//v3.4 autoscale yaix when mass range changed.
	
	make/Free/O/n=600 temp=0//v3.4 temporary wave to calculate yaix maximum value
	
	for(i=0;i<dimsize(HR_familyName,0);i++)
		string HR2UMRMSwave = HR2UMRMSPath + HR_familyName[i]+"_ExpCalc"
		string HR2UMRName = "HR2UMR_MS_"+HR_familyName[i]+"_ExpCalc"
		wave2Plotlist += HR2UMRName + ";"
		string wave2PlotStr = stringfromlist(i,wave2Plotlist)
		wave Hr2UMRMS = $HR2UMRMSwave
		if(i==0)
			Display/W=(741,103,1216,376)/HOST=# /Hide=1  HR2UMRMS vs HR2UMR_mzvalue
			Modifygraph/Z/W=$HR2UMRMSPlot mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
			Label/W=$HR2UMRMSPlot bottom "m/z\\Z14" 
			Label/W=$HR2UMRMSPlot left "Fraction of Signal\\Z14"
			SetAxis/W=$HR2UMRMSPlot bottom HR2UMR_mzmin,HR2UMR_mzmax
			ModifyGraph/W=$HR2UMRMSPlot nticks(bottom)=20
		else
			Appendtograph $HR2UMRMSwave vs HR2UMR_mzvalue
			Modifygraph/Z/W=$HR2UMRMSPlot mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
			Label/W=$HR2UMRMSPlot bottom "m/z\\Z14" 
			Label/W=$HR2UMRMSPlot left "Fraction of Signal\\Z14"
			SetAxis/W=$HR2UMRMSPlot bottom HR2UMR_mzmin,HR2UMR_mzmax
		endif
	endfor

end

Function HR2UMR_UpdateMS()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B
	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
	
	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax
	
	string HR2UMRMSPath = "root:databasepanel:HR2UMR:HR2UMR_MS_"
	string wave2Plotlist=""
	string HRFamilyCHeckList = HR2UMR_GenHRfamilyChecklist()
	string HRFamilyCheck = "HR2UMR_Check_HRFamily"
	controlinfo HR2UMR_Check_HRFamilyAll
	variable CheckAll=V_value //if 0: HR family is selected, 1: All HR family
	
	variable i
	variable yaxisMax = 0//v3.4 autoscale yaix when mass range changed.
	
	make/Free/O/n=600 temp=0//v3.4 temporary wave to calculate yaix maximum value
	
	for(i=0;i<dimsize(HR_familyName,0);i++)
		string HR2UMRMSwavePath = HR2UMRMSPath + HR_familyName[i] +"_ExpCalc"
		string HR2UMRName = "HR2UMR_MS_"+HR_familyName[i] +"_ExpCalc"
		wave2Plotlist += HR2UMRName + ";"
		string wave2PlotStr = stringfromlist(i,wave2Plotlist)
		wave HR2UMRMSwave = $HR2UMRMSwavePath
		
		temp += HR2UMRMSwave//v3.4
		
		RemoveFromGraph/Z/W=$HR2UMRMSPlot $wave2plotstr
		Appendtograph/W=$HR2UMRMSPlot HR2UMRMSwave vs HR2UMR_mzvalue
		Modifygraph/Z/W=$HR2UMRMSPlot mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
		Label/W=$HR2UMRMSPlot bottom "m/z\\Z14" 
		Label/W=$HR2UMRMSPlot left "Fraction of Signal\\Z14"
		Setaxis/W=$HR2UMRMSPlot bottom HR2UMR_mzmin,HR2UMR_mzmax
		ModifyGraph/W=$HR2UMRMSPlot nticks(bottom)=20
		
		if(CheckAll == 0)
			string CheckHRfamily = stringfromlist(i,HRFamilyChecklist,";")
			if(cmpstr(CheckHRfamily,"0") == 0) //The given HRfamily is not selected
				RemoveFromGraph/Z/W=$HR2UMRMSPlot $wave2plotstr
				temp -= HR2UMRMSwave//v3.4
			endif
		endif
		
	endfor
	
	yaxisMax = wavemax(temp,HR2UMR_mzmin-1, HR2UMR_mzmax-1)//v3.4
	Setaxis/W=$HR2UMRMSPlot left 0,yaxisMax//v3.4
	

end

Function HR2UMR_PopupMS()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B
	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax
	
	SVAR HR2UMR_MSname = root:globals:HR2UMR_MSname//v3.4D
	string HR2UMR_graph_title1 = "HR_" + HR2UMR_MSname//v3.4D	
	
	string HR2UMRMSPath = "root:databasepanel:HR2UMR:HR2UMR_MS_"
	string wave2Plotlist=""
	string HRFamilyCHeckList = HR2UMR_GenHRfamilyChecklist()
	string HRFamilyCheck = "HR2UMR_Check_HRFamily"
	controlinfo HR2UMR_Check_HRFamilyAll
	variable CheckAll=V_value //if 0: HR family is selected, 1: All HR family
	
	variable i
	variable yaxisMax = 0//v3.4 autoscale yaxis when mass range changed.
	
	make/Free/O/n=600 temp=0//v3.4 temporary wave to calculate yaix maximum value
	
	for(i=0;i<dimsize(HR_familyName,0);i++)
		string HR2UMRMSwavePath = HR2UMRMSPath + HR_familyName[i]+"_ExpCalc"
		string HR2UMRName = "HR2UMR_MS_"+HR_familyName[i]+"_ExpCalc"
		wave2Plotlist += HR2UMRName + ";"
		string wave2PlotStr = stringfromlist(i,wave2Plotlist)
		wave HR2UMRMSwave = $HR2UMRMSwavePath
		
		temp += HR2UMRMSwave//v3.4
		
		//RemoveFromGraph/Z/W=$HR2UMRMSPlot $wave2plotstr
		if(i == 0)
			Display/N=HR2UMR_graph1, HR2UMRMSwave vs HR2UMR_mzvalue			
			Modifygraph mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
			Label bottom "m/z\\Z14" 
			Label left "Fraction of Signal\\Z14"
			Setaxis bottom HR2UMR_mzmin,HR2UMR_mzmax
			ModifyGraph nticks(bottom)=20
		else
			Appendtograph HR2UMRMSwave vs HR2UMR_mzvalue
			Modifygraph mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
		endif
		
		if(CheckAll == 0)
			string CheckHRfamily = stringfromlist(i,HRFamilyChecklist,";")
			if(cmpstr(CheckHRfamily,"0") == 0) //The given HRfamily is not seleced
				RemoveFromGraph $wave2plotstr
				temp -= HR2UMRMSwave//v3.4
			endif
		endif		
		
	endfor
	
	yaxisMax = wavemax(temp,HR2UMR_mzmin-1, HR2UMR_mzmax-1)//v3.4
	Setaxis left 0,yaxisMax//v3.4
	
	//v3.4D
	Dowindow/T HR2UMR_graph1, HR2UMR_graph_Title1
	////

end


Function HR2UMR_PlotrefMS()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B
	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
	
	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax
	

	string Hr2UMRrefMSPath = "root:databasepanel:HR2UMR:HR2UMR_refMS_"
	string wave2PlotlistRef=""
	variable j
	for(j=0;j<dimsize(HR_familyName,0);j++)
		string HR2UMRrefMSwave = HR2UMRrefMSPath + HR_familyName[j]+"_ExpCalc"
		string HR2UMRRefName = "HR2UMR_refMS_"+HR_familyName[j]+"_ExpCalc"
		wave2PlotlistRef += HR2UMRrefName + ";"
		string wave2PlotStrRef = stringfromlist(j,wave2PlotlistRef)
		wave HR2UMRrefMS = $HR2UMRrefMSwave
		if(j==0)
			Display/W=(739,408,1213,682)/HOST=# /Hide=1 HR2UMRrefMS vs HR2UMR_mzvalue
			Modifygraph/Z/W=$HR2UMRrefMSPlot mode = 1, lsize=2, toMode($wave2PlotStrRef)=3, rgb($wave2PlotStrRef)=(HR_Family_R[j],HR_Family_G[j],HR_Family_B[j])
			Label/W=$HR2UMRrefMSPlot bottom "m/z\\Z14" 
			Label/W=$HR2UMRrefMSPlot left "Fraction of Signal\\Z14"
			SetAxis/W=$HR2UMRrefMSPlot bottom HR2UMR_mzmin,HR2UMR_mzmax
			ModifyGraph/W=$HR2UMRrefMSPlot nticks(bottom)=20
		else
			Appendtograph $HR2UMRrefMSwave vs HR2UMR_mzvalue
			Modifygraph/Z/W=$HR2UMRrefMSPlot mode = 1, lsize=2, toMode($wave2PlotStrRef)=3, rgb($wave2PlotStrRef)=(HR_Family_R[j],HR_Family_G[j],HR_Family_B[j])
			Label/W=$HR2UMRrefMSPlot bottom "m/z\\Z14" 
			Label/W=$HR2UMRrefMSPlot left "Fraction of Signal\\Z14"
			SetAxis/W=$HR2UMRrefMSPlot bottom HR2UMR_mzmin,HR2UMR_mzmax
		endif
	endfor
	

End

Function HR2UMR_UpdaterefMS()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B
	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
	
	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax
	
	string Hr2UMRrefMSPath = "root:databasepanel:HR2UMR:HR2UMR_refMS_"
	string wave2PlotlistRef=""
	string HRFamilyCHeckList = HR2UMR_GenHRfamilyChecklist()
	string HRFamilyCheck = "HR2UMR_Check_HRFamily"
	controlinfo HR2UMR_Check_HRFamilyAll
	variable CheckAll=V_value //if 0: HR family is selected, 1: All HR family
	
	variable yaxisMax = 0//v3.4 autoscale yaxis when mass range changed.
	
	make/Free/O/n=600 temp=0//v3.4 temporary wave to calculate yaix maximum value
	
	//RemoveTracesFromGraph(HR2UMRrefMSPlot)
	
	variable j
	for(j=0;j<dimsize(HR_familyName,0);j++)
		string HR2UMRrefMSwave = HR2UMRrefMSPath + HR_familyName[j] +"_ExpCalc"
		string HR2UMRRefName = "HR2UMR_refMS_"+HR_familyName[j] +"_ExpCalc"
		wave2PlotlistRef += HR2UMRrefName + ";"
		string wave2PlotStrRef = stringfromlist(j,wave2PlotlistRef)
		wave HR2UMRrefMS = $HR2UMRrefMSwave
		temp += HR2UMRrefMS//v3.4
		
		RemoveFromGraph/Z/W=$HR2UMRrefMSPlot $wave2plotstrRef
		Appendtograph/W=$HR2UMRrefMSPlot $HR2UMRrefMSwave vs HR2UMR_mzvalue
		Modifygraph/Z/W=$HR2UMRrefMSPlot mode = 1, lsize=2, toMode($wave2PlotStrRef)=3, rgb($wave2PlotStrRef)=(HR_Family_R[j],HR_Family_G[j],HR_Family_B[j])
		Label/W=$HR2UMRrefMSPlot bottom "m/z\\Z14" 
		Label/W=$HR2UMRrefMSPlot left "Fraction of Signal\\Z14"
		Setaxis/W=$HR2UMRrefMSPlot bottom HR2UMR_mzmin,HR2UMR_mzmax
		ModifyGraph/W=$HR2UMRrefMSPlot nticks(bottom)=20
		
		if(CheckAll == 0)//All is not checked
			string CheckHRfamily = stringfromlist(j,HRFamilyChecklist,";")
			if(cmpstr(CheckHRfamily,"0") == 0) //The given HRfamily is not selected
				RemoveFromGraph/Z/W=$HR2UMRrefMSPlot $wave2plotstrRef
				temp -= HR2UMRrefMS
			endif
		endif
	endfor
	
	yaxisMax = wavemax(temp, HR2UMR_mzmin-1,HR2UMR_mzmax-1) //v3.4
	Setaxis/W=$HR2UMRrefMSPlot left 0, yaxisMax//v3.4
	

End

Function HR2UMR_PopuprefMS()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B
	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
	
	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax
	
	SVAR HR2UMR_refMSname = root:globals:HR2UMR_refMSname//v3.4D	
	string HR2UMR_graph_title2 = "HR_" + HR2UMR_refMSname//v3.4D
	
	string Hr2UMRrefMSPath = "root:databasepanel:HR2UMR:HR2UMR_refMS_"
	string wave2PlotlistRef=""
	string HRFamilyCHeckList = HR2UMR_GenHRfamilyChecklist()
	string HRFamilyCheck = "HR2UMR_Check_HRFamily"
	controlinfo HR2UMR_Check_HRFamilyAll
	variable CheckAll=V_value //if 0: HR family is selected, 1: All HR family
	
	//RemoveTracesFromGraph(HR2UMRrefMSPlot)
	
	variable j
	
	variable yaxisMax = 0//v3.4 autoscale yaxis when mass range changed.
	
	make/Free/O/n=600 temp=0//v3.4 temporary wave to calculate yaix maximum value
	
	for(j=0;j<dimsize(HR_familyName,0);j++)
		string HR2UMRrefMSwave = HR2UMRrefMSPath + HR_familyName[j]+"_ExpCalc"
		string HR2UMRRefName = "HR2UMR_refMS_"+HR_familyName[j]+"_ExpCalc"
		wave2PlotlistRef += HR2UMRrefName + ";"
		string wave2PlotStrRef = stringfromlist(j,wave2PlotlistRef)
		wave HR2UMRrefMS = $HR2UMRrefMSwave
		temp += HR2UMRrefMS//v3.4
		
		//RemoveFromGraph/Z/W=$HR2UMRrefMSPlot $wave2plotstrRef
		if(j==0)
			Display/N=HR2UMR_graph2, $HR2UMRrefMSwave vs HR2UMR_mzvalue
			Modifygraph mode = 1, lsize=2, toMode($wave2PlotStrRef)=3, rgb($wave2PlotStrRef)=(HR_Family_R[j],HR_Family_G[j],HR_Family_B[j])
			Label bottom "m/z\\Z14" 
			Label left "Fraction of Signal\\Z14"
			Setaxis bottom HR2UMR_mzmin,HR2UMR_mzmax
			ModifyGraph/W=$HR2UMRrefMSPlot nticks(bottom)=20
		else
			Appendtograph $HR2UMRrefMSwave vs HR2UMR_mzvalue
			Modifygraph mode = 1, lsize=2, toMode($wave2PlotStrRef)=3, rgb($wave2PlotStrRef)=(HR_Family_R[j],HR_Family_G[j],HR_Family_B[j])
			
		endif
		
		if(CheckAll == 0)//All is not checked
			string CheckHRfamily = stringfromlist(j,HRFamilyChecklist,";")
			if(cmpstr(CheckHRfamily,"0") == 0) //The given HRfamily is not selected
				RemoveFromGraph $wave2plotstrRef
				temp -= HR2UMRrefMS//v3.4
			endif
		endif
	endfor	
	
	yaxisMax = wavemax(temp, HR2UMR_mzmin-1,HR2UMR_mzmax-1) //v3.4
	Setaxis left 0, yaxisMax//v3.4
	
	Dowindow/T HR2UMR_graph2, HR2UMR_graph_Title2//v3.4D


End


Function HR2UMR_List_selectMSwave(lba) : ListboxControl//v3.0
	STRUCT WMListBoxaction &lba
	
	variable row = lba.row
	variable col = lba.col
//	string ctrlName			// name of this control
//	variable row			// row if click in interior, -1 if click in title
//	variable col			// column number
//	variable event			// event code
//	variable RowforRefMS
 
	
	
	switch(lba.eventCode)
		case -1:
			break
		case 4: //when cell selection
			HR2UMR_selectMSwave(row,col)//v3.4 make a seperated function for HR2UMR_selectMSwave
		default:
			break
			
		//setdatafolder root:	
	Endswitch
	
	

End

Function HR2UMR_selectMSwave(row,col)//v3.4
	variable row,col
	
	SVAR HR2UMR_citation1list=root:globals:citation1list
	SVAR HR2UMR_mainlist = root:globals:HR2UMR_mainlist
	SVAR HR2UMR_scorelist = root:globals:HR2UMR_scorelist
	SVAR HR2UMR_MSname = root:globals:HR2UMR_MSname//v3.4D
 
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
 
	wave/T HRMS_columnlabel = root:databaseHR2UMR:HRMS_columnlabel
	wave HRMS_columnlabel_index = root:databaseHR2UMR:HRMS_columnlabel_index
	wave HRMS_All = root:databaseHR2UMR:HRMS_All//HR2UMR mass spectrum to calculate cosine similarity and sort by score
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
			
	if(row >= 0)
		variable index = HRMS_columnlabel_index[row]
	endif
	
	//if(event == 4) //cell selection
		//variable startTime = dateTime
		HR2UMR_citation1list = ""
		HR2UMR_citation1list += AerosolOrigin[index]+"|"+AerosolPerturbation[index]+"|"
		HR2UMR_citation1list += Analysis[index] + "|" + Instrument[index] +"|"
		HR2UMR_citation1list += Resolution[index] + "|" + Vaporizer[index]+"|"
		HR2UMR_citation1list += ShortFileDescriptor[index] + "|" + num2str(EIEnergy[index])+"|"
		HR2UMR_citation1list += num2str(VaporizerTempC[index]) + "|" + CommentDAQ[index]+"|"		
		HR2UMR_citation1list += NonAmbientType[index] + "|" + CommentNonAmbient[index]+"|"	
		HR2UMR_citation1list += PerturbedType[index] + "|" + CommentPerturbed[index]+"|"	
		HR2UMR_citation1list += ExperimenterName[index] + "|" + GroupStr[index]+"|"	
		HR2UMR_citation1list += CitationUrl[index] + "|" + CitationStr[index]+"|"
		HR2UMR_citation1list += CitationFigStr[index] + "|" + CommentAnalysis[index]+"|"
	
		variable listNum = ItemsInList(HR2UMR_citation1list,"|")
		string separator = "|"
		variable separatorLen = strLen(separator)
		variable offset = 0
		
		setdatafolder root:databasePanel:HR2UMR
		Make/T/O/N=(20,2) HR2UMR_citation1Info
		HR2UMR_citation1Info[0][0] = "AerosolOrigin", HR2UMR_citation1Info[1][0] = "AerosolPerturbation", HR2UMR_citation1Info[2][0] = "Analysis"
		HR2UMR_citation1Info[3][0] = "Instrument"
		HR2UMR_citation1Info[4][0] = "Resolution", HR2UMR_citation1Info[5][0] = "Vaporizer", HR2UMR_citation1Info[6][0] = "ShortFileDescriptor"
		HR2UMR_citation1Info[7][0] = "EI Energy", HR2UMR_citation1Info[8][0] = "Vaporizer Temp(C)", HR2UMR_citation1Info[9][0]="CommentDAQ"		
		HR2UMR_citation1Info[10][0] = "NonAmbient Type", HR2UMR_citation1Info[11][0] = "Comment NonAmbient", HR2UMR_citation1Info[12][0]="Perturbed Type"
		HR2UMR_citation1Info[13][0] = "Comment Perturbed", HR2UMR_citation1Info[14][0] = "Experimenter Name", HR2UMR_citation1Info[15][0]="Group Str"
		HR2UMR_citation1Info[16][0] = "CitationUrl", HR2UMR_citation1Info[17][0] = "CitationStr"
		HR2UMR_citation1Info[18][0] = "Citation Fig", HR2UMR_citation1Info[19][0] = "CommentAnalysis"
		
		variable j
		for(j=0;j<listNum;j+=1)
			//Redimension/N=(1,dimsize(HR2UMR_citation1Info,1)+1) HR2UMR_citation1Info
			string item = stringFromlist(0,HR2UMR_citation1list,separator,offset)
			offset += strlen(item) + separatorLen
			HR2UMR_citation1Info[j][1] = item
		endfor
		
		setdatafolder root:databasePanel:HR2UMR
		Make/O/N=(dimsize(HRMS_All,0)) HR2UMR_MS_origin = HRMS_All[p][row]
		variable k
		for(k=0;k<dimsize(HR_familyName,0);k++)
			string HR2UMRMSName = "HR2UMR_MS_" + HR_familyName[k]//wave to be saved and plotted on the plot
			make/O/n=(dimsize(HRMS_All,0)) $HR2UMRMSName
			string HR2UMRMSDBPath = "root:databaseHR2UMR:HRMS_" + HR_familyName[k]//Family wave from database, 2D wave
			wave HR2UMRMSDB = $HR2UMRMSDBpath
			wave HR2UMRMS = $HR2UMRMSName
			HR2UMRMS = 0
			HR2UMRMS = HR2UMRMSDB[p][row]
			
			
		endfor
		Make/O/N=(dimsize(HRMS_All,0)) HR2UMR_compMS
		Make/O/N=0 HR2UMR_score_extracted
		
		variable startTime = datetime
		wave/T columnlabel_extracted = columnlabelExtracted()
		//print "Time to extract the list: "+num2str(datetime-startTime)+"seconds."
		Make/O/N=(dimsize(columnlabel_extracted,0)) HR2UMR_score_extracted
		Make/O/N=0 HR2UMR_score_extracted_HRFam=0
		
		variable i 
		
		HR2UMR_mainlist = ""
		HR2UMR_scorelist = ""
		
		//setdatafolder root:database
		startTime = datetime
		if(dimsize(columnlabel_extracted,0)>0)
			for(i=0;i<dimsize(columnlabel_extracted,0);i+=1)
				HR2UMR_mainlist += columnlabel_extracted[i] + ";"
				redimension /n=(dimsize(HR2UMR_score_extracted_HRFam,0)+1) HR2UMR_score_extracted_HRFam
				for(j=0;j<dimsize(HRMS_columnlabel,0);j+=1)
					if(cmpstr(columnlabel_extracted[i],HRMS_columnlabel[j]) == 0)
						HR2UMR_compMS = HRMS_All[p][j]
						HR2UMR_genSelHRFamSumMS(j)
						string resultlist=getMSSim(HR2UMR_compMS,HR2UMR_MS_origin)
						HR2UMR_score_extracted[i]=str2num(stringfromlist(0,resultlist,";"))
						HR2UMR_score_extracted_HRFam[dimsize(HR2UMR_score_extracted_HRFam,0)-1]=str2num(stringfromlist(1,resultlist,";"))//HRfamilyscore
						string HR2UMR_score_extractedStr = num2str(HR2UMR_score_extracted[i])
						HR2UMR_scorelist += HR2UMR_score_extractedStr + ";"
						break					
					endif					
				endfor
					
			endfor
		endif
		//print "Time to calculate scores when click the list: "+num2str(datetime-startTime)+"seconds."
		
		if(dimsize(HR2UMR_score_extracted,0) != 0)
			
			Make/T/O/N=(dimsize(columnlabel_extracted,0)) HR2UMR_columnlabel_sort=columnlabel_extracted
			Make/O/N=(dimsize(HR2UMR_score_extracted,0)) HR2UMR_score_sort=HR2UMR_score_extracted
			Make/O/N=(dimsize(HR2UMR_score_extracted_HRfam,0)) HR2UMR_scoreHRfam_sort=HR2UMR_score_extracted_HRfam//v3.4B added
			sort/R HR2UMR_score_sort, HR2UMR_score_sort, HR2UMR_columnlabel_sort, HR2UMR_scoreHRfam_sort//v3.4B HR2UMR_score_extracted_HRFam
		else
			Redimension/N=1 HR2UMR_columnlabel_sort
			HR2UMR_columnlabel_sort = "****No selected Comparison Constraints****"
			Redimension/N=1 HR2UMR_score_sort
			HR2UMR_score_sort = 0
			Redimension/N=1 HR2UMR_scoreHRfam_sort//v3.4B
			HR2UMR_scoreHRfam_sort = 0//v3.4B
		endif
		
		controlinfo HR2UMR_ADB_traceSelection
		variable SampleRow = V_value
		
		if(cmpstr(HRMS_columnlabel[SampleRow],HR2UMR_columnlabel_sort[0]) == 0)
			Deletepoints 0,1,HR2UMR_columnlabel_sort
			DeletePoints 0,1,HR2UMR_score_sort
			DeletePoints 0,1,HR2UMR_scoreHRfam_sort//v3.4B_extracted_HRFam
		endif
		
		//updategraph()
		//print dateTime-startTIme
//	endif
	
//	Make/O/N = 600 mzvalue=p+1
//	for(i=0;i<600;i+=1)
//		mzvalue[i] = i+1
//	endfor
	
	//updategraph()
	HR2UMR_updateMS()
	titlebox HR2UMR_citationOne, title = HRMS_columnlabel[row]
	
	//v3.4D
	HR2UMR_MSname = HRMS_columnlabel[row]//v3.4D
	string tabletitle = "Metadata_table_HR_"+HR2UMR_MSname
	Dowindow/F HR2UMR_table_cit1
	If(v_flag==1)
		Dowindow/C/T HR2UMR_tablecit1, tabletitle
	endif
	
	Dowindow/F HR2UMR_graph1
	string HR2UMR_graph_title1="HR_"+HR2UMR_MSName
	if(v_flag==1)
		Dowindow/C/T HR2UMR_graph1, HR2UMR_graph_title1
		Dowindow/B=AMS_MS_Comparisons HR2UMR_graph1
	endif
	//////
	
	
end

Function HR2UMR_Butt_PopupMS(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	switch(ba.eventCode)
		case 2: //mouse up
	
		case 3:
			HR2UMR_popupMS()	
			
		case -1:
			break
	endswitch
	
	return 0
	

End

Function HR2UMR_Butt_PopuprefMS(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	switch(ba.eventCode)
		case 2: //mouse up
	
		case 3:
			HR2UMR_popuprefMS()	
			
		case -1:
			break
	endswitch
	
	return 0
	

End


//Function HR2UMR_popupGraph()
//	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
//	wave HR_family_R = root:databaseHR2UMR:HR_family_R
//	wave HR_family_G = root:databaseHR2UMR:HR_family_G
//	wave HR_family_B = root:databaseHR2UMR:HR_family_B
//	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
//	
//	string HR2UMRMSPath = "root:databasepanel:HR2UMR:HR2UMR_MS_"
//	string wave2Plotlist=""
//	variable i
//	for(i=0;i<dimsize(HR_familyName,0);i++)
//		string HR2UMRMSwave = HR2UMRMSPath + HR_familyName[i]
//		string HR2UMRName = "HR2UMR_MS_"+HR_familyName[i]
//		wave2Plotlist += HR2UMRName + ";"
//		string wave2PlotStr = stringfromlist(i,wave2Plotlist)
//		wave Hr2UMRMS = $HR2UMRMSwave
//		if(i==0)
//			Display/W=(529,34,1004,307)  HR2UMRMS vs HR2UMR_mzvalue
//			Modifygraph mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
//		else
//			Appendtograph $HR2UMRMSwave vs HR2UMR_mzvalue
//			Modifygraph mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
//		endif
//	endfor
//
//end

Function HR2UMR_getRefMS(RowforRefMS)//v3.0
	variable RowforRefMS
	
	SVAR HR2UMR_citation2list=root:globals:citation1list
	SVAR HR2UMR_mainlist = root:globals:HR2UMR_mainlist
	SVAR HR2UMR_scorelist = root:globals:HR2UMR_scorelist
	SVAR HR2UMR_refMSname = root:globals:HR2UMR_refMSname//v3.4D

	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin//v3.4D
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax//v3.4D
	
	wave/T HR2UMR_columnlabel_sort = root:databasePanel:HR2UMR:HR2UMR_columnlabel_sort
	wave HR2UMR_MS_origin = root:databasePanel:HR2UMR:HR2UMR_MS_origin
	wave HR2UMR_MS_exp = root:databasePanel:HR2UMR:HR2UMR_MS_exp
	wave HR2UMR_MSExpCalc = root:databasePanel:HR2UMR:HR2UMR_MSExpCalc
	
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
	
	wave/T HRMS_columnlabel = root:databaseHR2UMR:HRMS_columnlabel
	wave HRMS_columnlabel_index = root:databaseHR2UMR:HRMS_columnlabel_index
	wave HRMS_All = root:databaseHR2UMR:HRMS_All
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	
	//wave wholewave = root:database:wholewave
	
	 //Rownumber from hook function - follow columnlabel_sort
	variable i
	
	if(RowforRefMs >= 0)
		string MSname = HR2UMR_columnlabel_sort[RowforRefMS] //save selected MS_origin in the table
		HR2UMR_refMSname = MSname//v3.4D
		//find refMS_origin corresponding to selected MS_origin in the table
		for(i=0;i<dimsize(HRMS_columnlabel,0);i+=1)
			if(cmpstr(MSname, HRMS_columnlabel[i]) == 0)
				setdatafolder root:databasePanel:HR2UMR
				Make/O/N=(dimsize(HRMS_All,0)) HR2UMR_refMS_origin = HRMS_All[p][i]
				variable k
				
				for(k=0;k<dimsize(HR_familyName,0);k++)
					string HR2UMRMSName = "HR2UMR_refMS_" + HR_familyName[k]//wave to be saved and plotted on the plot
					make/O/n=(dimsize(HRMS_All,0)) $HR2UMRMSName
					string HR2UMRMSDBPath = "root:databaseHR2UMR:HRMS_" + HR_familyName[k]//Family wave from database, 2D wave
					wave HR2UMRrefMSDB = $HR2UMRMSDBpath
					wave HR2UMRrefMS = $HR2UMRMSName
					HR2UMRrefMS = 0
					HR2UMRrefMS = HR2UMRrefMSDB[p][i]
							
				endfor
				
				
				variable index = HRMS_columnlabel_index[i]
				HR2UMR_citation2list = ""
				HR2UMR_citation2list += AerosolOrigin[index]+"|"+AerosolPerturbation[index]+"|"
				HR2UMR_citation2list += Analysis[index] + "|" + Instrument[index] +"|"
				HR2UMR_citation2list += Resolution[index] + "|" + Vaporizer[index]+"|"
				HR2UMR_citation2list += ShortFileDescriptor[index] + "|" + num2str(EIEnergy[index])+"|"
				HR2UMR_citation2list += num2str(VaporizerTempC[index]) + "|" + CommentDAQ[index]+"|"		
				HR2UMR_citation2list += NonAmbientType[index] + "|" + CommentNonAmbient[index]+"|"	
				HR2UMR_citation2list += PerturbedType[index] + "|" + CommentPerturbed[index]+"|"	
				HR2UMR_citation2list += ExperimenterName[index] + "|" + GroupStr[index]+"|"	
				HR2UMR_citation2list += CitationUrl[index] + "|" + CitationStr[index]+"|"
				HR2UMR_citation2list += CitationFigStr[index] + "|" + CommentAnalysis[index]+"|"
			endif
		
		endfor
		
		variable listNum = ItemsInList(HR2UMR_citation2list,"|")
		string separator = "|"
		variable separatorLen = strLen(separator)
		variable offset = 0
		
		Make/T/O/N=(20,2) HR2UMR_citation2Info
		HR2UMR_citation2Info[0][0] = "AerosolOrigin", HR2UMR_citation2Info[1][0] = "AerosolPerturbation", HR2UMR_citation2Info[2][0] = "Analysis"
		HR2UMR_citation2Info[3][0] = "Instrument"
		HR2UMR_citation2Info[4][0] = "Resolution", HR2UMR_citation2Info[5][0] = "Vaporizer", HR2UMR_citation2Info[6][0] = "ShortFileDescriptor"
		HR2UMR_citation2Info[7][0] = "EI Energy", HR2UMR_citation2Info[8][0] = "Vaporizer Temp(C)", HR2UMR_citation2Info[9][0]="CommentDAQ"		
		HR2UMR_citation2Info[10][0] = "NonAmbient Type", HR2UMR_citation2Info[11][0] = "Comment NonAmbient", HR2UMR_citation2Info[12][0]="Perturbed Type"
		HR2UMR_citation2Info[13][0] = "Comment Perturbed", HR2UMR_citation2Info[14][0] = "Experimenter Name", HR2UMR_citation2Info[15][0]="Group Str"
		HR2UMR_citation2Info[16][0] = "CitationUrl", HR2UMR_citation2Info[17][0] = "CitationStr"
		HR2UMR_citation2Info[18][0] = "Citation Fig", HR2UMR_citation2Info[19][0] = "CommentAnalysis"
		
			
		variable j
		for(j=0;j<listNum;j+=1)
			//Redimension/N=(1,dimsize(HR2UMR_citation2Info,1)+1) HR2UMR_citation2Info
			string item = stringFromlist(0,HR2UMR_citation2list,separator,offset)
			offset += strlen(item) + separatorLen
			HR2UMR_citation2Info[j][1] = item
		endfor
		
		//Make/O/N=(dimsize(MS_origin,0)) sampleMSsubRefMS=0
		//Make/O/N=(dimsize(MS_origin,0)) sampleMSsubRefMS_exp=0
//		Make/O/N=(dimsize(MS_origin,0)) sampleMSsubRefMSExpCalc = 0
//		
//		controlInfo ADB_mzMin
//		variable mzMin = V_value			
//		controlInfo ADB_mzMax
//		variable mzMax = V_value
//		controlInfo ADB_mzExponent
//		variable mzExp = V_value
//		controlInfo ADB_intExponent
//		variable intExp = V_value

		
//		Duplicate/Free/O/R=[mzMin-1,mzMax-1] refMS_origin, refMS_ranged
//		Make/O/N=(dimsize(refMS_ranged,0)) refMS_scaled = refMS_ranged[p]^intExp * (mzMin+p)^mzExp
//		Make/O/N=600 refMSExpCalc=0
//		
//		refMS_scaled/=sum(refMS_scaled)
//		
//		for(i=0;i<dimsize(refMS_scaled,0);i++)
//			refMSExpCalc[mzMin+i-1] = refMS_scaled[i]
//		endfor
		
//		variable refMSSum = sum(refMSExpCalc)
//		if(refMSSum > 0)
//				refMSExpCalc/=refMSsum
//		endif
		
//		for(i=0;i<dimsize(MS_origin,0);i+=1)
//			//sampleMSsubRefMS[i] = MS_origin[i] - refMS_origin[i]
//			sampleMSsubRefMSExpCalc[i] = MSExpCalc[i] - refMSExpCalc[i]
//		endfor
		
		Titlebox/Z HR2UMR_citationTwo, title = MSname
		
		//v3.4D
		HR2UMR_refMSname = MSname
		string tabletitle= "Metadata_table_HR_"+HR2UMR_refMSname
		Dowindow/F HR2UMR_table_cit2
		if(v_flag==1)
			Dowindow/C/T HR2UMR_table_cit2, tabletitle
		endif
		
		Dowindow/F HR2UMR_graph2
		string HR2UMR_graph_title2="HR_"+HR2UMR_refMSName
		if(v_flag==1)
			Dowindow/C/T HR2UMR_graph2, HR2UMR_graph_title2
			SetAxis/W=HR2UMR_graph2 /a=1
			SetAxis/W=HR2UMR_graph2 bottom HR2UMR_mzmin, HR2UMR_mzmax
			Dowindow/B=AMS_MS_Comparisons HR2UMR_graph2
		endif
		//
		
		//updateGraph()

	endif
	
	//return HR2UMR_refMS_origin

End

Function HR2UMR_getCitation1(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	SVAR HR2UMR_MSname = root:globals:HR2UMR_MSname//v3.4D
	
	//wave citation2Info = root:database:citation2Info
	switch( ba.eventCode )
		case 2: // mouse uP
			
		case 3:
			string Tabletitle="Metadata_Table_HR_"+HR2UMR_MSname//v3.4D
			Dowindow/F HR2UMR_table_cit1//v3.4D
			//v3.4D
			if(v_flag==0)//if Popup window doesn't exist
				Edit/W=(40,70,300,550)
				Dowindow/C/T HR2UMR_table_cit1, tabletitle
				Appendtotable root:databasePanel:HR2UMR:HR2UMR_citation1Info
				ModifyTable/W=HR2UMR_table_cit1 title(root:databasePanel:HR2UMR:HR2UMR_citation1Info)="Metadata"//v3.4G
			elseif(v_flag==1)//if Popup window exists
				Dowindow/C/T HR2UMR_table_cit1, tabletitle
			endif
			//
			break
			
		case -1: // control being killed
			break
	endswitch

	return 0

End

Function HR2UMR_getCitation2(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	SVAR HR2UMR_refMSname = root:globals:HR2UMR_refMSname//v3.4D
	
	//wave citation2Info = root:database:citation2Info
	switch( ba.eventCode )
		case 2: // mouse uP
			
		case 3:
			string tabletitle = "Metadata_Table_HR_"+HR2UMR_refMSname//v3.4D
			DoWindow/F HR2UMR_table_cit2//v3.4D
			//v3.4D
			if(V_flag==0)
				Edit/W=(55,85,300,550)
				Dowindow/C/T HR2UMR_table_cit2, tabletitle//v3.4D
				AppendtoTable root:databasePanel:HR2UMR:HR2UMR_citation2Info//v3.4D add Window name
				ModifyTable/W=HR2UMR_table_cit2 title(root:databasePanel:HR2UMR:HR2UMR_citation2Info)="Metadata"//v3.4G
			elseif(V_flag==1)
				Dowindow/C/T HR2UMR_table_cit2, tabletitle//v3.4D
			endif
				
			break
	endswitch

	return 0

End

Function HR2UMR_butt_publication1(ControlName):ButtonControl
	string ControlName
	wave/T citation1info = root:databasePanel:HR2UMR:HR2UMR_citation1Info
	
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
Function HR2UMR_butt_publication2(ControlName):ButtonControl
	string ControlName
	wave/T citation2info = root:databasePanel:HR2UMR:HR2UMR_citation2Info
	
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

Function HR2UMR_butt_sort_UMR(ControlName):ButtonControl //v3.4B
	string controlName
	wave HR2UMR_score_sort = root:databasePanel:HR2UMR:HR2UMR_score_sort
	wave/T HR2UMR_columnlabel_sort = root:databasePanel:HR2UMR:HR2UMR_columnlabel_sort
	wave HR2UMR_scoreHRfam_sort = root:databasePanel:HR2UMR:HR2UMR_scoreHRfam_sort
	
	if(dimsize(HR2UMR_score_sort,0) == 0)
		abort "Please calculate score first!"
	else
		sort/R HR2UMR_score_sort, HR2UMR_score_sort, HR2UMR_columnlabel_sort, HR2UMR_scoreHRfam_sort
	endif
	
End

Function HR2UMR_butt_sort_HRfam(ControlName):ButtonControl //v3.4B
	string controlName
	wave HR2UMR_score_sort = root:databasePanel:HR2UMR:HR2UMR_score_sort
	wave/T HR2UMR_columnlabel_sort = root:databasePanel:HR2UMR:HR2UMR_columnlabel_sort
	wave HR2UMR_scoreHRfam_sort = root:databasePanel:HR2UMR:HR2UMR_scoreHRfam_sort
	
	if(dimsize(HR2UMR_scoreHRfam_sort,0)==0)
		abort "Please calculate score with selected HR families first!"
	else
		sort/R HR2UMR_scoreHRfam_sort, HR2UMR_scoreHRfam_sort, HR2UMR_columnlabel_sort, HR2UMR_score_sort
	endif
End


Function/S HR2UMR_GenHRfamilyChecklist()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName	
	
	string HRfamilyCheckList = ""
	
	controlInfo ADB_tabs
	string TabStr = S_value
	
	strswitch (TabStr)
		case "HR Data Comparison":
			string Hr2UMRPath = "HR2UMR_Check_HRFamily"
			
			variable i
			
			for(i=0;i<dimsize(HR_familyName,0);i++)
				string HR2UMRCheckName = HR2UMRPath + HR_familyName[i]
				controlinfo	$HR2UMRCheckName
				variable check = V_value
				HRFamilyCheckList += num2str(check) + ";"
				
			endfor
			
			break
		case "HR Database":
			Hr2UMRPath = "HR2UMRdb_Check_HRFamily"
			
			for(i=0;i<dimsize(HR_familyName,0);i++)
				HR2UMRCheckName = HR2UMRPath + HR_familyName[i]
				controlinfo	$HR2UMRCheckName
				check = V_value
				HRFamilyCheckList += num2str(check) + ";"
				
			endfor
			
			break
		default:
			break
	endswitch
	

	
	//print HRFamilyCheckList

	return HRFamilyCHeckList
End

Function HR2UMR_HRfamilyChecks(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	switch(cba.eventcode)
		case 2: //Mouse up, when cba.eventcode = 2
			controlInfo ADB_tabs
			string Tabstr = S_value
			strswitch (Tabstr)
				case "HR Data Comparison":
				
					HR2UMR_EnableCheckbox()
					HR2UMR_updateMS()
					HR2UMR_updaterefMS()
					break
				
				case "HR Database":
					HR2UMR_EnableCheckBox()
					HR2UMRdb_updateMS()
					
					break
				
				default:
					break
			endswitch
			
			break
		case -1:
			break
	endswitch
	
	return 0

End

Function HR2UMR_EnableCheckbox()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	
			
	variable i
	
	controlInfo ADB_tabs
	string TabStr = S_value
	
	if(cmpstr(TabStr, "HR Data Comparison") == 0)
		controlinfo HR2UMR_Check_HRFamilyAll
		variable CheckAllNum = V_value
		string Hr2UMRPath = "HR2UMR_Check_HRFamily"
	elseif(cmpstr(TabStr, "HR Database") == 0)
		controlinfo HR2UMRdb_Check_HRFamilyAll
		CheckAllNum = V_value
		HR2UMRPath = "HR2UMRdb_Check_HRFamily"
	endif
	
	
	if(CheckAllNum == 1) //All is checked
		for(i=0;i<dimsize(HR_familyName,0);i++)
			string HR2UMRCheckBox = HR2UMRPath + HR_familyName[i]
			CheckBox $HR2UMRCheckBox disable = 2, value=1
		
		endfor
	elseif(CheckAllNum == 0)
		for(i=0;i<dimsize(HR_familyName,0);i++)
			HR2UMRCheckBox = HR2UMRPath + HR_familyName[i]
			CheckBox $HR2UMRCheckBox disable = 0
		
		endfor
	
	endif
		

End

//Function/T HR2UMR_columnlabelExtracted()
//	wave/T HRMS_columnlabel = root:databaseHR2UMR:HRMS_columnlabel
//	wave HRMS_columnlabel_index = root:databaseHR2UMR:HRMS_columnlabel_index
//	
//	SVAR HR2UMRlist = $HR2UMRRoot
//	
//	variable i, j
//	
//	for(j=0;j<ItemsinList(HR2UMRlist);j++)
//		string HR2UMRName = stringfromlist(j,HR2UMRList)
//	
//		for(i=0;i<dimsize(HRMS_columnlabel,0);i++)
//			if(cmpstr(HRMS_columnlabel[i],HR2UMRName) == 0)//if they matches
//				
//			
//			endif
//		endfor
//		
//	endfor
//End
Function HR2UMR_Calculate_score(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			setdatafolder root:databasePanel:HR2UMR:
			HR2UMR_calc_score()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function HR2UMR_calc_score()//path was changed. variable name is the same as the same function for UMR but the wave is correct.
	wave wholewave = root:databaseHR2UMR:HRMS_All
	wave score_extracted = root:databasePanel:HR2UMR:HR2UMR_score_extracted
	wave/T HR2UMR_columnlabel_sort = root:databasePanel:HR2UMR:HR2UMR_columnlabel_sort
	wave/T HRMS_columnlabel = root:databaseHR2UMR:HRMS_columnlabel
	wave HR2UMR_score_extracted_HRFam = root:databasePanel:HR2UMR:HR2UMR_score_extracted_HRFam//v3.4
	
	setdatafolder root:databasePanel:HR2UMR:
	Make/O/N=(dimsize(wholewave,0)) HR2UMR_compMS
	Make/O/N=0 HR2UMR_score_extracted
	Make/T/O/N=0 HR2UMR_columnlabel_extracted
	Make/O/N=0 HR2UMR_score_extracted_HRfam//v3.4B added
	

	HR2UMR_Applycheckbox()
	
			
	if(dimsize(score_extracted,0) != 0)
		Make/T/O/N=(dimsize(HR2UMR_columnlabel_extracted,0)) HR2UMR_columnlabel_sort=HR2UMR_columnlabel_extracted
		Make/O/N=(dimsize(HR2UMR_score_extracted,0)) HR2UMR_score_sort=HR2UMR_score_extracted
		Make/O/N=0 HR2UMR_scoreHRfam_sort// = HR2UMR_score_extracted_HRfam//v3.4B added
		sort/R HR2UMR_score_sort, HR2UMR_score_sort, HR2UMR_columnlabel_sort//, HR2UMR_scoreHRfam_sort//v3.4B HRfam added
		
		controlinfo HR2UMR_ADB_traceSelection
		variable SampleRow = V_value
	
		if(cmpstr(HRMS_columnlabel[SampleRow],HR2UMR_columnlabel_sort[0]) == 0)
			Deletepoints 0,1,HR2UMR_columnlabel_sort
			DeletePoints 0,1,HR2UMR_score_sort
			//DeletePoints 0,1,HR2UMR_scoreHRfam_sort//v3.4B
		elseif(cmpstr(HRMS_columnlabel[SampleRow],HR2UMR_columnlabel_sort[1]) == 0)
			Deletepoints 1,1,HR2UMR_columnlabel_sort
			Deletepoints 1,1,HR2UMR_score_sort
			//DeletePoints 1,1,HR2UMR_scoreHRfam_sort//v3.4B
		endif
		
	else
		Redimension/N=1 HR2UMR_columnlabel_sort
		HR2UMR_columnlabel_sort = "****No results****"//v3.4
		Redimension/N=1 HR2UMR_score_sort
		HR2UMR_score_sort = 0
		//Redimension/N=1 HR2UMR_scoreHRfam_sort//v3.4B
		//HR2UMR_scoreHRfam_sort = 0 //v3.4B
	endif
	

	variable startTime = datetime
	HR2UMR_getFirstRefMS()
	//print "Time to get first RefMS: "+ num2str(dateTime-startTime)+"seconds"
	HR2UMR_updateRefMS()

End

Function HR2UMR_Applycheckbox()
	wave MS_origin = root:databasePanel:HR2UMR:HR2UMR_MS_origin
	wave compMS = root:databasePanel:HR2UMR:HR2UMR_compMS
	wave/T columnlabel = root:databaseHR2UMR:HRMS_columnlabel
	wave wholewave = root:databaseHR2UMR:HRMS_All
	
	SVAR allSpectraList = root:globals:HR2UMR_allSpectraList
	SVAR mainlist = root:Globals:HR2UMR_mainlist
	SVAR indexList = root:globals:HR2UMR_indexList
	SVAR scorelist = root:globals:HR2UMR_scorelist
	//SVAR scoreHRfamlist = root:globals:HR2UMR_scoreHRfamlist//v3.4B
	
	string checklist = checkboxlist() //v1.5
	string newlist = ""
	string newIndexList = ""
	string newscorelist = ""
	//string newscoreHRfamList = ""//v3.4B
	
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
			//newscoreHRfamList += stringfromlist(listIndex,scoreHRfamlist) + ";"//v3.4B
			
		elseif(whichlistitem(item,mainlist) == -1) // item is not found in the mainlist -> adding to the mainlist and calculation
			newlist += item + ";"
			
//			for(j=0;j<dimsize(columnlabel,0);j+=1)
//				if(cmpstr(item,columnlabel[j]) == 0)
					//compMS = wholewave[p][j]
					compMS = wholewave[p][allSpectraIndex]
					HR2UMR_genSelHRFamSumMS(allSpectraIndex)//v3.4B
					
					string resultlist = getMSSim(compMS,MS_origin)
					variable score_calc= str2num(stringfromlist(0,resultlist,";"))
					string score_calcStr = num2str(score_calc)
					scorelist += score_calcStr + ";"
					//scoreHRfamlist += stringfromlist(1,resultlist,";")+";"//v3.4B decided that 'apply' button doesn't calculate score with HR family 
					mainlist += item + ";"
					indexList += num2str(allSpectraIndex) + ";"
					newscorelist += score_calcStr + ";"
					//newscoreHRfamlist += stringfromlist(1,resultlist,";")+";"//v3.4B decided that 'apply' button doesn't calculate score with HR family
//					break
//				endif			
//			endfor
		endif
	endfor
	
	setdatafolder root:databasePanel:HR2UMR:
	Make/T/O/N=(itemsInlist(newlist)) HR2UMR_columnlabel_extracted = stringfromlist(p,newlist)
	Make/O/N=(itemsInlist(newscorelist)) HR2UMR_score_extracted = str2num(stringfromlist(p,newscorelist))
	//Make/O/N=(itemsInlist(newscoreHRfamlist)) HR2UMR_score_extracted_HRfam = str2num(stringfromlist(p,newscoreHRfamlist))//v3.4B
	

//	for(i=0;i<itemsInlist(newlist);i+=1)
//		columnlabel_extracted[i] = stringFromList(i,newlist)
//		variable score = str2num(stringFromlist(i,newscorelist))
//		score_extracted[i] = score	
//	endfor

	
	//print "Applycheckbox "
	//print "Time to extract list and calculate scores: "+num2str(dateTime-startTime)+"seconds."
End

Function HR2UMR_EnableNewMSCheckBox()
	controlInfo HR2UMR_Check_NewMS
	variable check = v_value
	controlInfo HR2UMR_Check_ExistingMS
	variable check2 = v_value
	
	if(check == 1 && check2 == 1)//When check both of them
		abort "Please select either NewMS or Existing MS"
		
	elseif(check + check2 == 1)//v2.03 only this line
		if(check == 1)//When select NewMS
			Checkbox HR2UMR_Check_ExistingMS disable=2, value=0
			PopupMenu HR2UMR_vw_pop_dataDFSel disable=0
			PopupMenu HR2UMR_vw_pop_MSSel disable=0
			PopupMenu HR2UMR_vw_pop_mzValueSel disable=0
			PopupMenu HR2UMR_vw_pop_SpeciesWaveSel disable=0//
			PopupMenu HR2UMR_vw_pop_SpeciesSel disable=0//
			Button HR2UMR_NewdataCalculateButton disable=0//
			Listbox HR2UMR_ADB_traceSelection disable=2
			TitleBox HR2UMR_citationOne disable=2
			Button HR2UMR_citation1 disable=2
			Button HR2UMR_Open_URL1 disable=2
			TitleBox HR2UMR_citationTwo disable=0//
			Button HR2UMR_citation2 disable=0//
			Button HR2UMR_Open_URL2 disable=0//			

		elseif(check2 == 1) //when select Existing MS
			Checkbox HR2UMR_Check_NewMS disable=2, value=0
			ListBox HR2UMR_ADB_traceSelection disable=0
			TitleBox HR2UMR_citationOne disable=0
			Button HR2UMR_citation1 disable=0
			Button HR2UMR_Open_URL1 disable=0
			TitleBox HR2UMR_citationTwo disable=0
			Button HR2UMR_citation2 disable=0
			Button HR2UMR_Open_URL2 disable=0
			PopupMenu HR2UMR_vw_pop_dataDFSel disable=2
			PopupMenu HR2UMR_vw_pop_MSSel disable=2
			PopupMenu HR2UMR_vw_pop_mzValueSel disable=2
			PopupMenu HR2UMR_vw_pop_SpeciesWaveSel disable=2
			PopupMenu HR2UMR_vw_pop_SpeciesSel disable=2
			Button HR2UMR_NewdataCalculateButton disable=2
		
		endif
	elseif(Check == 0 && check2 == 0)
		PopupMenu HR2UMR_vw_pop_dataDFSel disable=2
		PopupMenu HR2UMR_vw_pop_MSSel disable=2
		PopupMenu HR2UMR_vw_pop_mzValueSel disable=2
		PopupMenu HR2UMR_vw_pop_SpeciesWaveSel disable=2
		PopupMenu HR2UMR_vw_pop_SpeciesSel disable=2
		Button HR2UMR_NewdataCalculateButton disable=2
		Checkbox HR2UMR_Check_NewMS disable=0
		Checkbox HR2UMR_Check_ExistingMS disable=0
		Listbox HR2UMR_ADB_traceSelection disable=2
		TitleBox HR2UMR_citationOne disable=2
		Button HR2UMR_citation1 disable=2
		Button HR2UMR_Open_URL1 disable=2
		TitleBox HR2UMR_citationTwo disable=2
		Button HR2UMR_citation2 disable=2
		Button HR2UMR_Open_URL2 disable=2
	endif
	
End

Function HR2UMR_DisplayExistingMSChecks(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	switch(cba.eventcode)
		case 2:
		
		HR2UMR_EnableNewMSCheckBox()
		
		break
		
		case -1:
			break
	endswitch
	
	return 0
	
End

Function HR2UMR_getFirstRefMS()
	wave HRMS_All = root:databaseHR2UMR:HRMS_All
	wave/T HRMS_columnlabel = root:databaseHR2UMR:HRMS_columnlabel
	wave/T HR2UMR_columnlabel_sort = root:databasePanel:HR2UMR:HR2UMR_columnlabel_sort
	wave HR2UMR_refMSCalc = root:databasePanel:HR2UMR:HR2UMR_refMSCalc
	wave HR2UMR_refMS_origin = root:databasePanel:HR2UMR:HR2UMR_refMS_origin
	wave HR2UMR_MS_origin = root:databasePanel:HR2UMR:MS_origin
	wave HR2UMR_sampleMSsubRefMS = root:databasePanel:HR2UMR:HR2UMR_sampleMSsubRefMS
	wave HR2UMR_sampleMSsubRefMSExpCalc = root:databasePanel:HR2UMR:HR2UMR_sampleMSsubRefMSExpCalc
	wave HR2UMR_MSExpCalc = root:databasePanel:HR2UMR:HR2UMR_MSExpCalc
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	
	string HR2UMRMSPath = "root:databasepanel:HR2UMR:HR2UMR_MS_"
	
	
	variable j
	
	for(j=0;j<dimsize(HRMS_columnlabel,0);j+=1)
		if(cmpstr(HR2UMR_columnlabel_sort[0], HRMS_columnlabel[j]) == 0)
			HR2UMR_refMS_origin = HRMS_All[p][j]
		
		endif
	endfor
	
	controlInfo HR2UMR_mzMin
	variable HR2UMR_mzMin = V_value					
	controlInfo HR2UMR_mzMax
	variable HR2UMR_mzMax = V_value
	controlInfo HR2UMR_mzExponent
	variable HR2UMR_mzExp = V_value
	controlInfo HR2UMR_intExponent
	variable HR2UMR_intExp = V_value
	
	Duplicate/Free/O/R=[HR2UMR_mzMin-1,HR2UMR_mzMax-1] HR2UMR_refMS_origin, HR2UMR_refMS_ranged
	Make/O/FREE/N=(dimsize(HR2UMR_refMS_ranged,0)) HR2UMR_refMS_scaled = HR2UMR_refMS_ranged[p]^HR2UMR_intExp * (HR2UMR_mzMin+p)^HR2UMR_mzExp//indicates HR2UMR_refMS_all
	
	string Hr2UMRrefMSPath = "root:databasepanel:HR2UMR:HR2UMR_refMS_"

	variable k
	for(k=0;k<dimsize(HR_familyName,0);k++)
		string Hr2UMRrefMSorgn = HR2UMRrefMSPath+HR_familyName[k]
		string HR2UMRrefMSwave_scaled = HR2UMRrefMSPath + HR_familyName[k]+"_ExpCalc"
		string HR2UMRrefMSwaveName_scaled = "HR2UMR_refMS_"+HR_familyName[k]+"_ExpCalc"
		wave HR2UMRrefMS = $HR2UMRrefMSorgn
		make/O/N=(600) $HR2UMRrefMSwaveName_scaled = 0
		wave HR2UMRrefMS_scaled = $HR2UMRrefMSwaveName_scaled
		HR2UMRrefMS_scaled = HR2UMRrefMS[p]^HR2UMR_intExp * (HR2UMR_mzMin+p)^HR2UMR_mzExp
		variable HRrefMSSum = sum(HR2UMR_refMS_scaled)//v3.4A
		HR2UMRrefMS_scaled/=HRrefMSSum//v3.4A

	endfor
	
	Make/O/N=600 HR2UMR_refMSExpCalc=0
	
	HRrefMSSum = sum(HR2UMR_refMS_scaled)//v3.4A
	HR2UMR_refMS_scaled /= HRrefMSSum//v3.4A
	
	variable i
	
	for(i=0;i<dimsize(HR2UMR_refMS_scaled,0);i++)
		HR2UMR_refMSExpCalc[HR2UMR_mzMin+i-1] = HR2UMR_refMS_scaled[i]
	endfor
	
//	variable refMSSum = sum(refMSExpCalc)
//	if(refMSSum > 0)
//			refMSExpCalc/=refMSsum
//	endif
	
	Make/O/N=(dimsize(HR2UMR_MSExpCalc,0)) HR2UMR_sampleMSsubRefMSExpCalc
	HR2UMR_sampleMSsubRefMsExpCalc = HR2UMR_MSExpCalc[p] - HR2UMR_refMSExpCalc[p]
	
//	for(i=0;i<dimsize(MS_origin,0);i+=1)
//		//sampleMSsubRefMS[i] = MS_origin[i] - refMS_origin[i]
//		sampleMSsubRefMSExpCalc[i] = MSExpCalc[i] - refMSExpCalc[i]
//	endfor

End

Function UMRDB_selectMSwave(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	variable RowforRefMS
	
	SVAR UMRDB_citation1list=root:globals:UMRDB_citation1list
	
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
		UMRDB_citation1list = ""
		UMRDB_citation1list += AerosolOrigin[index]+"|"+AerosolPerturbation[index]+"|"
		UMRDB_citation1list += Analysis[index] + "|" + Instrument[index] +"|"
		UMRDB_citation1list += Resolution[index] + "|" + Vaporizer[index]+"|"
		UMRDB_citation1list += ShortFileDescriptor[index] + "|" + num2str(EIEnergy[index])+"|"
		UMRDB_citation1list += num2str(VaporizerTempC[index]) + "|" + CommentDAQ[index]+"|"		
		UMRDB_citation1list += NonAmbientType[index] + "|" + CommentNonAmbient[index]+"|"	
		UMRDB_citation1list += PerturbedType[index] + "|" + CommentPerturbed[index]+"|"	
		UMRDB_citation1list += ExperimenterName[index] + "|" + GroupStr[index]+"|"	
		UMRDB_citation1list += CitationUrl[index] + "|" + CitationStr[index]+"|"
		UMRDB_citation1list += CitationFigStr[index] + "|" + CommentAnalysis[index]+"|"
	
		variable listNum = ItemsInList(UMRDB_citation1list,"|")
		string separator = "|"
		variable separatorLen = strLen(separator)
		variable offset = 0
		
		setdatafolder root:databasePanel:
		Make/T/O/N=(20,2) UMRDB_citation1Info
		UMRDB_citation1Info[0][0] = "AerosolOrigin", UMRDB_citation1Info[1][0] = "AerosolPerturbation", UMRDB_citation1Info[2][0] = "Analysis"
		UMRDB_citation1Info[3][0] = "Instrument"
		UMRDB_citation1Info[4][0] = "Resolution", UMRDB_citation1Info[5][0] = "Vaporizer", UMRDB_citation1Info[6][0] = "ShortFileDescriptor"
		UMRDB_citation1Info[7][0] = "EI Energy", UMRDB_citation1Info[8][0] = "Vaporizer Temp(C)", UMRDB_citation1Info[9][0]="CommentDAQ"		
		UMRDB_citation1Info[10][0] = "NonAmbient Type", UMRDB_citation1Info[11][0] = "Comment NonAmbient", UMRDB_citation1Info[12][0]="Perturbed Type"
		UMRDB_citation1Info[13][0] = "Comment Perturbed", UMRDB_citation1Info[14][0] = "Experimenter Name", UMRDB_citation1Info[15][0]="Group Str"
		UMRDB_citation1Info[16][0] = "CitationUrl", UMRDB_citation1Info[17][0] = "CitationStr"
		UMRDB_citation1Info[18][0] = "Citation Fig", UMRDB_citation1Info[19][0] = "CommentAnalysis"
		
		variable j
		for(j=0;j<listNum;j+=1)
			//Redimension/N=(1,dimsize(UMRDB_citation1Info,1)+1) UMRDB_citation1Info
			string item = stringFromlist(0,UMRDB_citation1list,separator,offset)
			offset += strlen(item) + separatorLen
			UMRDB_citation1Info[j][1] = item
		endfor
		
		setdatafolder root:databasePanel:
		Make/O/N=(dimsize(wholewave,0)) UMRDB_MS_origin = wholewave[p][row]
		
		UMRDB_updategraph()
		
	endif

End

Function UMRDB_updategraph()
	wave UMRDB_MS_origin = root:databasePanel:UMRDB_MS_origin
	wave mzvalue = root:databasePanel:mzvalue
	
	RemoveTracesFromGraph(UMRDBPLOT)
	AppendtoGraph/W=$UMRDBPLOT UMRDB_MS_origin vs mzvalue
	Modifygraph/W=$UMRDBPLOT mode=1, nticks(bottom)=15//v3.4D increase grid ticks
	Label/W=$UMRDBPLOT bottom "m/z"
	Label/W=$UMRDBPLOT left "Relative Abundance"
	SetAxis/W=$UMRDBPLOT bottom 1,300					
	appendMSTags(UMRDB_MS_origin,"AMS_MS_Comparisons#G3")
	TextBox/W=$UMRDBPLOT /K/N=text1
	
	UMRDB_updateinfo()

End

Function HR2UMRdb_selectMSwave(lba) : ListboxControl//v3.0
	STRUCT WMListBoxaction &lba
	
	variable row = lba.row
	variable col = lba.col
//	string ctrlName			// name of this control
//	variable row			// row if click in interior, -1 if click in title
//	variable col			// column number
//	variable event			// event code
//	variable RowforRefMS
 
	SVAR HR2UMRdb_citation1list=root:globals:citation1list
//	SVAR HR2UMR_mainlist = root:globals:HR2UMR_mainlist
//	SVAR HR2UMR_scorelist = root:globals:HR2UMR_scorelist
 
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
 
	wave/T HRMS_columnlabel = root:databaseHR2UMR:HRMS_columnlabel
	wave HRMS_columnlabel_index = root:databaseHR2UMR:HRMS_columnlabel_index
	wave HRMS_All = root:databaseHR2UMR:HRMS_All//HR2UMR mass spectrum to calculate cosine similarity and sort by score
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	
	switch(lba.eventCode)
		case -1:
			break
		case 4: //when cell selection
		
		
			if(row >= 0)
				variable index = HRMS_columnlabel_index[row]
			endif
			
			//if(event == 4) //cell selection
				//variable startTime = dateTime
				HR2UMRdb_citation1list = ""
				HR2UMRdb_citation1list += AerosolOrigin[index]+"|"+AerosolPerturbation[index]+"|"
				HR2UMRdb_citation1list += Analysis[index] + "|" + Instrument[index] +"|"
				HR2UMRdb_citation1list += Resolution[index] + "|" + Vaporizer[index]+"|"
				HR2UMRdb_citation1list += ShortFileDescriptor[index] + "|" + num2str(EIEnergy[index])+"|"
				HR2UMRdb_citation1list += num2str(VaporizerTempC[index]) + "|" + CommentDAQ[index]+"|"		
				HR2UMRdb_citation1list += NonAmbientType[index] + "|" + CommentNonAmbient[index]+"|"	
				HR2UMRdb_citation1list += PerturbedType[index] + "|" + CommentPerturbed[index]+"|"	
				HR2UMRdb_citation1list += ExperimenterName[index] + "|" + GroupStr[index]+"|"	
				HR2UMRdb_citation1list += CitationUrl[index] + "|" + CitationStr[index]+"|"
				HR2UMRdb_citation1list += CitationFigStr[index] + "|" + CommentAnalysis[index]+"|"
			
				variable listNum = ItemsInList(HR2UMRdb_citation1list,"|")
				string separator = "|"
				variable separatorLen = strLen(separator)
				variable offset = 0
				
				newdatafolder/O root:databasePanel:HR2UMR:HR2UMRdb
				setdatafolder root:databasePanel:HR2UMR:HR2UMRdb
				Make/T/O/N=(20,2) HR2UMRdb_citation1Info
				HR2UMRdb_citation1Info[0][0] = "AerosolOrigin", HR2UMRdb_citation1Info[1][0] = "AerosolPerturbation", HR2UMRdb_citation1Info[2][0] = "Analysis"
				HR2UMRdb_citation1Info[3][0] = "Instrument"
				HR2UMRdb_citation1Info[4][0] = "Resolution", HR2UMRdb_citation1Info[5][0] = "Vaporizer", HR2UMRdb_citation1Info[6][0] = "ShortFileDescriptor"
				HR2UMRdb_citation1Info[7][0] = "EI Energy", HR2UMRdb_citation1Info[8][0] = "Vaporizer Temp(C)", HR2UMRdb_citation1Info[9][0]="CommentDAQ"		
				HR2UMRdb_citation1Info[10][0] = "NonAmbient Type", HR2UMRdb_citation1Info[11][0] = "Comment NonAmbient", HR2UMRdb_citation1Info[12][0]="Perturbed Type"
				HR2UMRdb_citation1Info[13][0] = "Comment Perturbed", HR2UMRdb_citation1Info[14][0] = "Experimenter Name", HR2UMRdb_citation1Info[15][0]="Group Str"
				HR2UMRdb_citation1Info[16][0] = "CitationUrl", HR2UMRdb_citation1Info[17][0] = "CitationStr"
				HR2UMRdb_citation1Info[18][0] = "Citation Fig", HR2UMRdb_citation1Info[19][0] = "CommentAnalysis"
				
				variable j
				for(j=0;j<listNum;j+=1)
					//Redimension/N=(1,dimsize(HR2UMRdb_citation1Info,1)+1) HR2UMRdb_citation1Info
					string item = stringFromlist(0,HR2UMRdb_citation1list,separator,offset)
					offset += strlen(item) + separatorLen
					HR2UMRdb_citation1Info[j][1] = item
				endfor
				
				setdatafolder root:databasePanel:HR2UMR:HR2UMRdb
				Make/O/N=(dimsize(HRMS_All,0)) HR2UMRdb_MS_origin = HRMS_All[p][row]
				variable k
				for(k=0;k<dimsize(HR_familyName,0);k++)
					string HR2UMRMSName = "HR2UMRdb_MS_" + HR_familyName[k]//wave to be saved and plotted on the plot
					make/O/n=(dimsize(HRMS_All,0)) $HR2UMRMSName
					string HR2UMRMSDBPath = "root:databaseHR2UMR:HRMS_" + HR_familyName[k]//Family wave from database, 2D wave
					wave HR2UMRMSDB = $HR2UMRMSDBpath
					wave HR2UMRMS = $HR2UMRMSName
					HR2UMRMS = 0
					HR2UMRMS = HR2UMRMSDB[p][row]
					
					
				endfor
				
				HR2UMRdb_UpdateMS()
				
				break
			default:
				break
	endswitch

End

Function HR2UMRdb_PlotMS()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B
	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
	
	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax
	
	string HR2UMRMSPath = "root:databasepanel:HR2UMR:HR2UMRdb:HR2UMRdb_MS_"
	string wave2Plotlist=""
	variable i
	for(i=0;i<dimsize(HR_familyName,0);i++)
		string HR2UMRMSwave = HR2UMRMSPath + HR_familyName[i]
		string HR2UMRName = "HR2UMRdb_MS_"+HR_familyName[i]
		wave2Plotlist += HR2UMRName + ";"
		string wave2PlotStr = stringfromlist(i,wave2Plotlist)
		wave Hr2UMRMS = $HR2UMRMSwave
		if(i==0)
			Display/W=(394,105,1213,406)/HOST=# /Hide=1  HR2UMRMS vs HR2UMR_mzvalue
			Modifygraph/Z/W=$HR2UMRdbMSPlot mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
			Label/W=$HR2UMRdbMSPlot bottom "m/z\\Z14" 
			Label/W=$HR2UMRdbMSPlot left "Fraction of Signal\\Z14"
			SetAxis/W=$HR2UMRdbMSPlot bottom HR2UMR_mzmin,HR2UMR_mzmax
		else
			Appendtograph $HR2UMRMSwave vs HR2UMR_mzvalue
			Modifygraph/Z/W=$HR2UMRdbMSPlot mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
			Label/W=$HR2UMRdbMSPlot bottom "m/z\\Z14" 
			Label/W=$HR2UMRdbMSPlot left "Fraction of Signal\\Z14"
			SetAxis/W=$HR2UMRdbMSPlot bottom HR2UMR_mzmin,HR2UMR_mzmax
		endif
	endfor

end

Function HR2UMRdb_UpdateMS()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B
	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
	wave HR2UMRDB_MS_origin = root:databasePanel:HR2UMR:HR2UMR_MS_origin
	
	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax
	
	string HR2UMRMSPath = "root:databasepanel:HR2UMR:HR2UMRdb:HR2UMRdb_MS_"
	string wave2Plotlist=""
	string HRFamilyCHeckList = HR2UMR_GenHRfamilyChecklist()
	string HRFamilyCheck = "HR2UMRdb_Check_HRFamily"
	controlinfo HR2UMRdb_Check_HRFamilyAll
	variable CheckAll=V_value //if 0: HR family is selected, 1: All HR family
	
	variable i
	for(i=0;i<dimsize(HR_familyName,0);i++)
		string HR2UMRMSwavePath = HR2UMRMSPath + HR_familyName[i]
		string HR2UMRName = "HR2UMRdb_MS_"+HR_familyName[i]
		wave2Plotlist += HR2UMRName + ";"
		string wave2PlotStr = stringfromlist(i,wave2Plotlist)
		wave HR2UMRMSwave = $HR2UMRMSwavePath
		
		RemoveFromGraph/Z/W=$HR2UMRdbMSPlot $wave2plotstr
		Appendtograph/W=$HR2UMRdbMSPlot HR2UMRMSwave vs HR2UMR_mzvalue
		Modifygraph/Z/W=$HR2UMRdbMSPlot mode = 1, lsize=2, toMode($wave2plotstr)=3, rgb($wave2plotstr)=(HR_Family_R[i],HR_Family_G[i],HR_Family_B[i])
		Label/W=$HR2UMRdbMSPlot bottom "m/z\\Z14" 
		Label/W=$HR2UMRdbMSPlot left "Fraction of Signal\\Z14"
		Setaxis/W=$HR2UMRdbMSPlot bottom HR2UMR_mzmin,HR2UMR_mzmax
		
		
		if(CheckAll == 0)
			string CheckHRfamily = stringfromlist(i,HRFamilyChecklist,";")
			if(cmpstr(CheckHRfamily,"0") == 0) //The given HRfamily is not seleced
				RemoveFromGraph/Z/W=$HR2UMRdbMSPlot $wave2plotstr
			endif
		endif
		
		
	endfor
	
	HR2UMRDB_updateinfo()
	//appendMSTags(HR2UMRDB_MS_origin,"AMS_MS_Comparisons#G4")

end

Function HR2UMR_updateFamilyColorLegend()

	wave/t HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B

	variable num = numpnts(HR_familyName)

	make/o/n=(num) root:databasePanel:HR2UMR:HR_family_pointNumber
	make/o/n=(num,3) root:databasePanel:HR2UMR:HR_family_2dColorTable

	wave HR_family_pointNumber = root:databasePanel:HR2UMR:HR_family_pointNumber
	wave HR_family_2dColorTable = root:databasePanel:HR2UMR:HR_family_2dColorTable

	HR_family_pointNumber = p+1
	HR_family_2dColorTable[][0] = HR_family_R[p]
	HR_family_2dColorTable[][1] = HR_family_G[p]
	HR_family_2dColorTable[][2] = HR_family_B[p]

End

Function HR2UMR_butt_familyTableLegend(ctrlName) : ButtonControl
	String ctrlName
	
	HR2UMR_updateFamilyColorLegend()
	
	DoWindow /F HRFamilyColorLegend
	if (V_flag==0)
		HR2UMR_plot_HRFamilyColorLegend()
	endif
	
End

Function HR2UMR_plot_HRFamilyColorLegend()

	HR2UMR_makeHRFamilyLegend()
	svar HR_legendStrUnitSticks = root:Globals:HR2UMR_legendStrUnitSticks
	PauseUpdate; Silent 1		// building window...
	Display/N=HRFamilyColorLegend /W=(40,260,130,550)  as "HRFamilyColorLegend"
	ModifyGraph mode=1
	ModifyGraph lSize=4
	ModifyGraph hideTrace=1
	//ModifyGraph zColor(HR_family_pointNumber)={root:HR:HR_family_2dColorTable,*,*,directRGB}
	ModifyGraph nticks=0
//	ModifyGraph axOffset(left)=-3.85714,axOffset(bottom)=-1.66667
//	ModifyGraph axRGB=(65535,65535,65535)
	TextBox/X=0/Y=0  "\\Z14\\f01"+HR_legendStrUnitSticks
	//ColorScale/C/N=text0/A=MC/X=-8.57/Y=0.89 cindex=root:HR:HR_family_2dColorTable, heightPct=100
	//ColorScale/C/N=text0 widthPct=50
	//ColorScale/C/N=text0 userTicks={root:HR:HR_family_pointNumber,root:HR:HR_familyName}
//	ColorScale/C/N=text0 axisRange={1,15,0}
End

Function HR2UMR_makeHRFamilyLegend()

	wave/t HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR_family_R = root:databaseHR2UMR:HR_family_R
	wave HR_family_G = root:databaseHR2UMR:HR_family_G
	wave HR_family_B = root:databaseHR2UMR:HR_family_B

	variable idex, num

	num=numpnts(HR_familyName)
	string/g  root:Int_Sticks:HR_legendStrUnitSticks
	svar HR_legendStrUnitSticks = root:Globals:HR2UMR_legendStrUnitSticks
	
	HR_legendStrUnitSticks="Families:\r\f01"
	for (idex=0;idex<num;idex+=1)
		HR_legendStrUnitSticks+="\\K("+num2str(HR_family_R[idex])+","+num2str(HR_family_G[idex])+","+num2str(HR_family_B[idex])+")"+HR_familyName[idex]+"\r"
	endfor
	HR_legendStrUnitSticks=HR_legendStrUnitSticks[0, strlen(HR_legendStrUnitSticks)-2]

End

Function HR2UMR_genExactMassList()
	setdatafolder root:databaseHR2UMR:
	wave/T ExactMassText = root:databaseHR2UMR:ExactMassText
	wave ExactMassWave = root:databaseHR2UMR:ExactMassWave
	wave/T ExactMassFamilyText = root:databaseHR2UMR:ExactMassFamilyText
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	
	variable i,j
//	for(i=0;i<dimsize(HR_familyName,0);i++)
//		string ExactHRionName = "ExactHRion_"+HR_familyName[i]
//		make/T $ExactHRionName
//		string ExactMassName = "ExactMass_"+HR_familyName[i]
//		make $ExactMassName
//		string path = "root:databaseHR2UMR:"
//		string ExactHRionpath = path + ExactHRionName
//		wave/T ExactHRion = $ExactHRionPath
//		string ExactMassPath = path + ExactMassName
//		wave ExactMass = $ExactMassPath
//		
//		for(j=0;j<dimsize(ExactMassFamilyText,0);j++)
//			if(cmpstr(ExactMassFamilyText[j],HR_familyName[i]) == 0)
//				redimension/n=(dimsize(ExactHRion,0)+1) ExactHRion
//				ExactHRion[dimsize(ExactHrion,0)-1] = ExactMassText[j]
//				redimension/n=(dimsize(ExactMass,0)+1) ExactMass
//				ExactMass[dimsize(Exactmass,0)-1] = ExactMassWave[j]
//				
//			endif
//		
//		endfor
//	endfor
	
	for(i=0;i<dimsize(HR_familyName,0);i++)
		string HRionListname = "ExactHRionList_"+HR_familyName[i] 
		string/g $HRionListName = ""
		string ExactMassListName = "ExactMassList_"+HR_familyName[i]
		string/g $ExactMassListName = ""
		
		string ExactHRionName = "ExactHRion_"+HR_familyName[i]
		string ExactMassName = "ExactMass_"+HR_familyName[i]
		string path = "root:databaseHR2UMR:"
		string ExactHRionpath = path + ExactHRionName
		wave/T ExactHRion = $ExactHRionPath
		string ExactMassPath = path + ExactMassName
		wave ExactMass = $ExactMassPath
		string HRionListPath = path + HRionListName
		svar HRionList = $HRionListPath
		string ExactMassListpath = path + ExactMassListName
		svar ExactMassList = $ExactMassListpath
		
		for(j=0;j<dimsize(ExactMass,0);j++)
			HRionList += ExactHRion[j] + ";"
			ExactMassList += num2str(ExactMass[j]) + ";"
		
		endfor
	
	endfor
End

Function HR2UMR_genMyHRFamilywave(datafolderpath)
	string datafolderpath//copy current folder path
	string HRSpectrapath = datafolderpath+"Spectra"
	string HRmzPath = datafolderpath + "mz"
	string SpectraNamePath = datafolderpath + "SpectraName"
	string HRmzLabelPath = datafolderPath + "mzlabel"
	
	wave HRSpectra = $HRSpectraPath
	wave HRmz = $HRmzPath
	wave/T SpectraName = $SpectraNamePath
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave/T mzlabel = $HRmzlabelpath
	
	setdatafolder datafolderpath
			
	//string myUMRmzpath = datafolderpath + "myHR2UMRmz"
	//wave myHR2UMRmz = $myUMRmzpath
	
	//string HRionPath = "root:databaseHR2UMR:ExactHRion"
	//string ExactMassPath = "root:databaseHR2UMR:ExactMass"
	string HRionListPath = "root:databaseHR2UMR:ExactHRionList_"
	string ExactMassListPath = "root:databaseHR2UMR:ExactMassList_"
	
	variable i, column, j
	
	for(i=0;i<dimsize(HR_familyName,0);i++)
		string HR2UMRwaveName = "myHR2UMRSpectra_"+ HR_familyName[i]
		make/O/n=(600,dimsize(HRSpectra,1)) $HR2UMRwaveName = 0
	endfor
	
	make/O/n=(600,dimsize(HRSpectra,1)) myHR2UMRSpectra_All=0
	
	for(column=0;column<dimsize(HRSpectra,1);column++)
		for(i=0;i<dimsize(HR_familyName,0);i++)
			string HRionListName = HRionListPath + HR_familyName[i]
			svar HRionList = $HRionListName
			string ExactMassListName = ExactMassListPath + HR_familyName[i]
			svar ExactMassList = $ExactMassListName
			
			HR2UMRwaveName = "myHR2UMRSpectra_"+ HR_familyName[i]
			string myspectraPath = datafolderpath + HR2UMRwaveName
			wave MyHR2UMRspectra = $myspectraPath
			
			for(j=0;j<dimsize(HRmz,0);j++)
				//if(whichlistItem(num2str(HRmz[j]),ExactMassList,";") != -1)
				if(whichlistItem(mzlabel[j], HRionList,";") != -1)
					variable UMRmass = round(HRmz[j])
					MyHR2UMRspectra[UMRmass-1][column] += HRSpectra[j][column]
					
				endif
			endfor
			
			//v3.4G
			if(cmpstr(HR_familyName[i],"Air")==0)
				MyHR2UMRspectra = 0
			elseif(cmpstr(HR_familyName[i],"Tungsten")==0)
				MyHr2UMRSpectra = 0
			endif
			//
		
			myHR2UMRSpectra_All += MyHR2UMRspectra
		endfor
		
	endfor

end



Function HR2UMR_getNewMS_MS() //for NewMS checkbox of HR2UMR tab
	wave HR2UMR_MS_origin = root:databasePanel:HR2UMR:HR2UMR_MS_origin
	wave HRMS_All = root:databaseHR2UMR:HRMS_All
	wave/T HRMS_columnlabel = root:databaseHR2UMR:HRMS_columnlabel
	wave/T HR_FamilyName = root:databaseHR2UMR:HR_familyName
	
	//v3.4
	controlInfo HR2UMR_Check_NewMS
	variable NewMScheck = V_value
	controlInfo HR2UMR_Check_ExistingMS
	variable ExistMScheck = V_value
	
	if(NewMSCheck == 1)
		controlInfo HR2UMR_vw_pop_dataDFSel
		string CurrentDF = S_value //It's from data folder popoup menu.
		
		string CurrentPath = "root:" + CurrentDF
		
		controlInfo HR2UMR_vw_pop_MSSel
		string SelectedMS = S_value
		string MSpath = CurrentPath + SelectedMS
		wave SelectedWVTemp = $MSpath//v2.02
		
		
		controlInfo HR2UMR_vw_pop_SpeciesWaveSel
		string SelectedMSname = S_value
		string SpectraNamePath = CurrentPath + SelectedMSname
		wave/T selectedMSnameWV = $SpectraNamePath 	
		
		if(dimsize(selectedWvTemp,1)>1)
			controlInfo HR2UMR_vw_pop_SpeciesSel
			string selectedWVname = S_value
			
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
			wave SelectedWV  = $MSpath  // r001 type SelectedMV = $MSpath
		endif
		/////
		controlInfo HR2UMR_vw_pop_mzValueSel
		string SelectedAMU = S_value
		string AMUwvpath = CurrentPath + SelectedAMU
		wave selectedAMUwv = $AMUwvPath
		
		Redimension/N=(600,0) HR2UMR_MS_origin
		HR2UMR_MS_origin = 0
		
		variable j
		
		if(selectedAMUwv[0] == 0)
			for(j=0;j<dimsize(selectedAMUwv,0)-1;j+=1)										
				//setdatafolder root:database
				variable HRselectedWvsum = sum(SelectedWV)//v3.4A
				HR2UMR_MS_origin[j] = SelectedWV[j+1]/HRselectedWvsum//v3.4A
			endfor
		else
			for(j=0;j<dimsize(selectedAMUwv,0); j+=1) //NOT CONSECUTIVE AMU
				//wave T = $itemwave
				variable unitMass = selectedAMUwv[j]
				HRselectedWvsum = sum(SelectedWV)//v3.4A
				HR2UMR_MS_origin[unitmass-1]=SelectedWV[j]/HRselectedWvsum//v3.4A
			endfor
		endif
		
		//v2.02
		if(dimsize(selectedWvTemp,1)>1)
			KillWaves selectedWV
		endif
		////
		
		setdatafolder root:databasePanel:HR2UMR
			
		for(k=0;k<dimsize(HR_familyName,0);k++)
			string HR2UMRMSName = "HR2UMR_MS_" + HR_familyName[k]//wave to be saved and plotted on the plot
			make/O/n=(600) $HR2UMRMSName
			string myHR2UMRMSPath = currentPath +"myHR2UMRSpectra_" + HR_familyName[k]//Family wave from database, 2D wave
			wave myHR2UMRMS = $myHR2UMRMSpath
			wave HR2UMRMS = $HR2UMRMSName
			HR2UMRMS = myHR2UMRMS[p][columnindex]	
			//HR2UMRMS = HR2UMRMS[p][columnindex]==0? NaN : HR2UMRMS[p][columnindex]	
			
		endfor
		
		Make/O/N=(dimsize(HRMS_All,0)) HR2UMR_compMS
		Make/O/N=0 HR2UMR_score_extracted
		make/o/n=0 HR2UMR_score_extracted_HRfam
			
		wave/T HR2UMR_columnlabel_extracted = columnlabelExtracted()
		
		Redimension/N=(dimsize(HR2UMR_columnlabel_extracted,0)) HR2UMR_score_extracted
		Redimension/N=(dimsize(HR2UMR_columnlabel_extracted,0)) HR2UMR_score_extracted_HRfam
			
		variable i 
	
		if(dimsize(HR2UMR_columnlabel_extracted,0)>0)
			for(i=0;i<dimsize(HR2UMR_columnlabel_extracted,0);i+=1)
				
				for(j=0;j<dimsize(HRMS_columnlabel,0);j+=1)
					if(cmpstr(HR2UMR_columnlabel_extracted[i],HRMS_columnlabel[j]) == 0)
						HR2UMR_compMS = HRMS_All[p][j]
						HR2UMR_genSelHRFamSumMS(j)
						
						string resultlist = getMSSim(HR2UMR_compMS,HR2UMR_MS_origin)
						HR2UMR_score_extracted[i]=str2num(stringfromlist(0,resultlist,";"))
						HR2UMR_score_extracted_HRfam[i]=str2num(stringfromlist(1,resultlist,";"))
					endif
				endfor
				
			endfor
		endif
			
		if(dimsize(HR2UMR_score_extracted,0) != 0)
			Make/T/O/N=(dimsize(HR2UMR_columnlabel_extracted,0)) HR2UMR_columnlabel_sort=HR2UMR_columnlabel_extracted
			Make/O/N=(dimsize(HR2UMR_score_extracted,0)) HR2UMR_score_sort=HR2UMR_score_extracted
			Make/O/N=(dimsize(HR2UMR_score_extracted_HRfam,0)) HR2UMR_scoreHRfam_sort=HR2UMR_score_extracted_HRfam//v3.4B
			sort/R HR2UMR_score_sort, HR2UMR_score_sort, HR2UMR_columnlabel_sort, HR2UMR_scoreHRfam_sort//v3.4B
		else
			Redimension/N=1 HR2UMR_columnlabel_sort
			HR2UMR_columnlabel_sort = "****No selected Comparison Constraints****"
			Redimension/N=1 HR2UMR_score_sort
			HR2UMR_score_sort = 0
			Redimension/N=1 HR2UMR_scoreHRfam_sort//v3.4B
			HR2UMR_scoreHRfam_sort = 0//v3.4B
		endif
	elseif(ExistMSCheck == 1)
		controlinfo HR2UMR_ADB_traceselection
		variable row = v_value
		variable col = v_selcol
		HR2UMR_selectMSwave(row,col)
		
	elseif(NewMSCheck == 0 && ExistMSCheck == 0)
		abort "Please check 'New MS' or 'Existing MS' to be compared"
	endif
	
	
	
	
	setdatafolder root:databasePanel:HR2UMR
End

Function HR2UMR_calcHRfamilyscore()
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	wave HR2UMR_mzvalue = root:databasePanel:HR2UMR:HR2UMR_mzvalue
	wave HR2UMR_refMS_selHRfamilySum = root:databasepanel:HR2UMR:HR2UMR_refMS_selHRfamilySum
	
	NVAR HR2UMR_mzmin = root:globals:HR2UMR_mzmin
	NVAR HR2UMR_mzmax = root:globals:HR2UMR_mzmax
	
	string HR2UMRMSPath = "root:databasepanel:HR2UMR:HR2UMR_MS_"
	string Hr2UMRrefMSPath = "root:databasepanel:HR2UMR:HR2UMR_refMS_"
	string HRFamilyCHeckList = HR2UMR_GenHRfamilyChecklist()
	string HRFamilyCheck = "HR2UMR_Check_HRFamily"
	controlinfo HR2UMR_Check_HRFamilyAll
	variable CheckAll=V_value //if 0: HR family is selected, 1: All HR family
	
	setdatafolder root:databasepanel:HR2UMR
	make/o/n=0 HR2UMR_MS_selHRfamilySum
	//make/o/n=0 HR2UMR_refMS_selHRfamilySum
	variable i
	
	for(i=0;i<dimsize(HR_familyName,0);i++)
		//generate summed mass spectrum of selected HR family
		string HR2UMRMSwavePath = HR2UMRMSPath + HR_familyName[i] +"_ExpCalc"
		string HR2UMRName = "HR2UMR_MS_"+HR_familyName[i] +"_ExpCalc"
		wave HR2UMRMSwave = $HR2UMRMSwavePath
		
//		string HR2UMRrefMSwave = HR2UMRrefMSPath + HR_familyName[i] +"_ExpCalc"
//		string HR2UMRRefName = "HR2UMR_refMS_"+HR_familyName[i] +"_ExpCalc"
//		wave HR2UMRrefMS = $HR2UMRrefMSwave
		
		if(i==0)
			redimension /n=(dimsize(HR2UMRMSwave,0)) HR2UMR_MS_selHRfamilySum
			//redimension /n=(dimsize(HR2UMRMSwave,0)) HR2UMR_refMS_selHRfamilySum
		endif
		
		string CheckHRfamily = stringfromlist(i,HRFamilyChecklist,";")
		if(cmpstr(CheckHRfamily,"1") == 0) //The given HRfamily is selected
			HR2UMR_MS_selHRfamilySum += HR2UMRMSwave
			//HR2UMR_refMS_selHRfamilySum += HR2UMRrefMS
		endif		
		
	endfor
	
	Duplicate/Free/O/R=[HR2UMR_mzMin-1,HR2UMR_mzMax-1] HR2UMR_MS_selHRfamilySum, MS_ranged
	Duplicate/Free/O/R=[HR2UMR_mzMin-1,HR2UMR_mzMax-1] HR2UMR_refMS_selHRfamilySum, refMS_ranged
	
	
	variable numerator = MatrixDot(refMS_ranged,MS_ranged)
	variable denominator = sqrt(MatrixDot(refMS_ranged,refMS_ranged) * MatrixDot(MS_ranged,MS_ranged))
   variable result = numerator/denominator
			
			
   if(numType(result) == 0)		   		
   		return result
   else		   		
       return 0
   endif
   
   
   return result	
   
	
end

Function HR2UMR_genSelHRFamSumMS(j)
	variable j
	wave/T HRMS_columnlabel = root:databaseHR2UMR:HRMS_columnlabel
	wave HRMS_columnlabel_index = root:databaseHR2UMR:HRMS_columnlabel_index
	wave HRMS_All = root:databaseHR2UMR:HRMS_All
	wave/T HR_familyName = root:databaseHR2UMR:HR_familyName
	string HRFamilyCHeckList = HR2UMR_GenHRfamilyChecklist()
	string HRFamilyCheck = "HR2UMR_Check_HRFamily"
	controlinfo HR2UMR_Check_HRFamilyAll
	variable CheckAll=V_value //if 0: specific HR family is selected, 1: All HR family

	controlInfo HR2UMR_mzMin
	variable HR2UMR_mzMin = V_value
						
	controlInfo HR2UMR_mzMax
	variable HR2UMR_mzMax = V_value
			
	variable HR2UMR_range = HR2UMR_mzMax - HR2UMR_mzMin + 1

	controlInfo HR2UMR_mzExponent
	variable HR2UMR_mzExp = V_value
	controlInfo HR2UMR_intExponent
	variable HR2UMR_intExp = V_value	


	variable i
	setdatafolder root:databasePanel:HR2UMR
	variable k
	
	
	make/O/n=(dimsize(HRMS_All,0)) HR2UMR_refMS_SelHRfamilySum=0
	
	for(k=0;k<dimsize(HR_familyName,0);k++)		
		
		string HR2UMRMSDBPath = "root:databaseHR2UMR:HRMS_" + HR_familyName[k]//Family wave from database, 2D wave
		wave HR2UMRrefMSDB = $HR2UMRMSDBpath
		//wave HR2UMRrefMS = $HR2UMRMSName
		//HR2UMRrefMS = 0
		string CheckHRfamily = stringfromlist(k,HRfamilyChecklist,";")
		if(cmpstr(CheckHRfamily, "1" ) == 0)
			make/Free/O/n=(600) HRfamilywave
			HRfamilywave = HR2UMRrefMSDB[p][j] 
			HRfamilywave = HRfamilywave[p]^HR2UMR_intExp*(HR2UMR_mzMin+p)^HR2UMR_mzExp //scaled HR family mass spectrum
			HR2UMR_refMS_SelHRfamilySum += HRfamilywave
		endif
							
	endfor
	
	variable HRrefMSSum = sum(HR2UMR_refMS_SelHRfamilySum)//v3.4A
	HR2UMR_refMS_SelHRfamilySum /= HRrefMSSum//v3.4 add nomalization of SelHRfmilySum wave. v3.4A change sum function to sum variable
	
end

Function UMRdb_updateInfo()
	wave/T citation1info = root:databasePanel:UMRDB_citation1Info
	
	string ctrlPath = "UMRdb_titleDesc_"
	string infolist = "AerOri;AerPer;Analysis;Inst;Res;vap;Desc;EI;VapTemp;DAQCom;AerOriType;AerOriCom;AerPerType;AerPerCom;ExpName;Group;Cit;"
	
	variable i
	for(i=0;i<itemsinlist(infolist,";");i++)
		string ctrlName = ctrlPath + stringfromlist(i,infolist,";")
				
		if(i==16)
			titlebox $ctrlName, title = citation1info[i+1][1]
		elseif(i==6) //r001
			string/g root:databasePanel:UMRDB_MS_Desc="N/A"
			svar UMRDB_MS_Desc=root:databasePanel:UMRDB_MS_Desc
			UMRDB_MS_Desc=DescriptionFormatting(citation1info[i][1])
			titlebox $ctrlName, variable=UMRDB_MS_Desc
		else
			titlebox $ctrlName, title = citation1info[i][1]
		endif
					
	
	endfor

end

Function UMRdb_butt_publication1(ControlName):ButtonControl
	string ControlName
	wave/T citation1info = root:databasePanel:UMRDB_citation1Info
	
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

Function HR2UMRdb_updateInfo()
	wave/T citation1info = root:databasePanel:HR2UMR:HR2UMRdb:HR2UMRdb_citation1Info
	
	string ctrlPath = "HR2UMRdb_titleDesc_"
	string infolist = "AerOri;AerPer;Analysis;Inst;Res;vap;Desc;EI;VapTemp;DAQCom;AerOriType;AerOriCom;AerPerType;AerPerCom;ExpName;Group;Cit;"
	
	variable i
	for(i=0;i<itemsinlist(infolist,";");i++)
		string ctrlName = ctrlPath + stringfromlist(i,infolist,";")
				
		if(i==16)
			titlebox $ctrlName, title = citation1info[i+1][1]
		elseif(i==6) //r001
			string/g root:databasePanel:HR2UMR:HR2UMRdb:HR2UMRDB_MS_Desc="N/A"
			svar HR2UMRDB_MS_Desc=root:databasePanel:HR2UMR:HR2UMRdb:HR2UMRDB_MS_Desc
			HR2UMRDB_MS_Desc=DescriptionFormatting(citation1info[i][1])
			titlebox $ctrlName, variable=HR2UMRDB_MS_Desc
		else
			titlebox $ctrlName, title = citation1info[i][1]
		endif
					
	
	endfor

end

//r001 Format the description string so that it fits.  Titleboxes are limited in line length
static Function/s DescriptionFormatting(DescStr)
string DescStr

	variable maxLen=60		// somewhat 
	string partialStr, returnStr=""
	variable pos1, pos2, n = strlen(DescStr)

	pos1 = 0
	pos2 = min(pos1+maxLen, n-1)

	do
		partialStr = DescStr[pos1, pos2]
		if(strlen(partialStr)<maxLen)	
			returnStr+= partialStr
		else
			pos2=strsearch(partialStr, " ", Inf, 1)    	// find spaces
			if(pos2>=0)
				returnStr+=DescStr[pos1, pos2-1]+"\r"
			else
				returnStr+=partialStr+"\r"
				pos2=pos1+maxLen
			endif
		endif
		pos1 = pos2+1
		pos2 = min(pos1+maxLen, n-1)
	while(pos1<n-1)

	return returnStr

end

Function HR2UMRdb_butt_publication1(ControlName):ButtonControl
	string ControlName
	wave/T citation1info = root:databasePanel:HR2UMR:HR2UMRdb:HR2UMRdb_citation1Info
	
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


Function UMRdb_getCitation1(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	//wave citation2Info = root:database:citation2Info
	switch( ba.eventCode )
		case 2: // mouse uP
			
		case 3:
			Edit/K=0 root:databasePanel:UMRDB_citation1Info
			break
			
		case -1: // control being killed
			break
	endswitch

	return 0

End

Function HR2UMRdb_getCitation1(ba) : ButtonControl  //r001
	STRUCT WMButtonAction &ba
	
	//wave citation2Info = root:database:citation2Info
	switch( ba.eventCode )
		case 2: // mouse uP
			
		case 3:
			Edit/K=0 root:databasePanel:HR2UMR:HR2UMRdb:HR2UMRdb_citation1Info
			break
			
		case -1: // control being killed
			break
	endswitch

	return 0

End


