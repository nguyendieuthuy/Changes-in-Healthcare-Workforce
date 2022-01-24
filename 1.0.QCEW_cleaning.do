*https://www.bls.gov/cew/release-calendar.htm
*https://www.bls.gov/cew/downloadable-data-files.htm
//The following code creates a dta for each year and saves it in the tempfiles folder

//Create and Format individual stata files for each occupation


capture log close
log using "${QCEWlogdir}/QCEW_reads_`date_string'.log", replace


//Set directory (user will need to change this to match their own directory)
cd "${QCEWbasedir}"

*https://www.bls.gov/cew/downloadable-data-files.htm - download single file -> unzip 

//The following code creates a dta for each year and saves it in the tempfiles folder

//Create and Format individual stata files for each occupation

local allfiles : dir "${QCEWbasedir}/RawData" files "*.csv"
display `allfiles'

foreach list in `allfiles' {
clear 
import delimited "${QCEWdatadir}/`list'"
compress 
save "${intdir}/`list'.dta",replace
	
}


clear
use "${intdir}/2021.q1-q2.singlefile.csv.dta"

forvalues t = 2011/2020 {
append using "${intdir}/`t'.q1-q4.singlefile.csv.dta"	
}
compress 
save "${QCEWcleandatadir}/QCEW_2011_2021-2021-12-01.dta", replace

tab year

log close
exit




