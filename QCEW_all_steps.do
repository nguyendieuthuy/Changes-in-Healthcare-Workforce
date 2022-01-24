* 		File Description
*************************************************
*Author: Thuy Nguyen
*Date created: 10/01/2021
*Date modified: 12/07/2021
*Purpose: master file to replicate the results for the paper: US Health Care Workforce Changes During the First and Second Years of the COVID-19 Pandemic. 

clear
cap clear matrix
/*Working Directories*/
* change to your working directory
* you need intermediate_results, plot, source, log, data folders

	global Rootdatadir "/media/thuy/13c83ca8-25b7-471b-a983-b67d635be41c/DataSets"		
	global QCEWbasedir "${Rootdatadir}/DataSets-other/QCEWprep"
	global QCEWintdir "${QCEWbasedir}/intermediate_results"
	global QCEWsourcedir "${QCEWbasedir}/Script"
	global QCEWlogdir "${QCEWbasedir}/log"
	global QCEWdatadir "${QCEWbasedir}/RawData"
	global QCEWcleandatadir "${QCEWbasedir}/CleanData"

	
	global basedir "/media/thuy/13c83ca8-25b7-471b-a983-b67d635be41c/Projects/QCEW-Pandemic"        // change project name here 
	global intdir "${basedir}/intermediate_results"
	global plotdir "${basedir}/writeup/plot"
	global tabledir "${basedir}/writeup/table"
	global sourcedir "${basedir}/source-QCEW-Pandemic"
	global logdir "${basedir}/log"
	
	
	global datadir "${Rootdatadir}/DataSets-other/QCEWdatasets"


/* Start log */
capture log close
log using "${logdir}/QCEW_allstep.log", replace

clear
set matsize 11000
clear mata
set maxvar 32767

clear
cd "${basedir}"

***************************************************************************
* reading files and create stata versions of data:                        *
***************************************************************************
	do "${sourcedir}/1.0.QCEW_cleaning.do" 

***************************************************************************
* Compiling data                                                          *
***************************************************************************
	do "${sourcedir}/2.1.QCEW_county_compiling.do" 
	do "${sourcedir}/2.2.QCEW_county_generate_vars.do"   //  	
***************************************************************************
* Analysis                                                                *
***************************************************************************
	do "${sourcedir}/3.1.QCEW_county_descriptive.do" 
	
