
/* Start log */
capture log close
log using "${logdir}/2.3.Final_Results$S_DATE.log", replace

		
/// exporting data  
	use  "${intdir}/qcew_2011_2020yq_nation_covid.dta",clear

	sort yq 
	gen year =year(dofq(yq))
	keep if yq>=yq(2018,1)	
	
    local IND Healthcare ambHCservice Physician dentoffice otheoffice outpatient medlab homehealth otheambHC Hospital genhospital SUDhospital spechospital ///
	nurseResid SNF residcare retirecom otherresid
  		
	keep yq year *Healthcare *ambHCservice *Physician *dentoffice *otheoffice *outpatient *medlab *homehealth *otheambHC *Hospital *genhospital *SUDhospital *spechospital *nurseResid *SNF *residcare *retirecom *otherresid
	export excel using $tabledir/qcew_2018_2020yq_nation_by_industry, replace firstrow(var)	
	


	clear all
	use "${intdir}/QCEW_county_regression2018_2020_covid.dta", clear 
	keep if year>=2018 
	
	recode HPSACodePrimaryCare (2=1) (1=2)
	label define PCP 0 "No shortage"  1 "Partial shortage" 2 "Full shortage"
	label values HPSACodePrimaryCare PCP 
	tab HPSACodePrimaryCare
	
	codebook fips* // 3,149 counties 
	codebook fips* if Healthcarecensored==1
	codebook fips* if Physician==1
	
	codebook fips_digit  if HPSACodePrimaryCare==0 // 328
	codebook fips_digit  if HPSACodePrimaryCare==1 // 1,946
	codebook fips_digit if HPSACodePrimaryCare==2 // 868

	drop wage_* l* G* D* Any*
	
	keep yq year HPSACodePrimaryCare *Healthcare *ambHCservice *Physician *dentoffice *otheoffice *outpatient *medlab *homehealth *otheambHC *Hospital *genhospital *SUDhospital *spechospital *nurseResid *SNF *residcare *retirecom *otherresid fips_digit
	order fips_digit yq year 
	sort fips_digit yq year
	export excel using $tabledir/qcew_2018_2020yq_county_by_HPSACodePrimaryCare, replace firstrow(var)	
	
	
	
/// nationwide trends	
	use  "${intdir}/qcew_2011_2020yq_nation_covid.dta",clear	
	sort yq 
	keep if yq>=yq(2018,1)	
/*	
	foreach var in USest_62 USest_ambHCservice USest_physoffice USest_MHSpecialist USest_MHPract USest_Outpatient4 USest_Outpatient USest_allHospital USest_SUDHospital USest_Hospital USest_SpecHospital USest_nurseResid USest_nursingcare USest_residcare USest_Residential USest_retirecom USest_otherresid  ///
	USwage_62 USwage_ambHCservice USwage_physoffice USwage_MHSpecialist USwage_MHPract USwage_Outpatient4 USwage_Outpatient USwage_allHospital USwage_SUDHospital USwage_Hospital USwage_SpecHospital USwage_nurseResid USwage_nursingcare USwage_residcare USwage_Residential USwage_retirecom USwage_otherresid {
	replace `var'=`var'/1000
	}	
*/	
	foreach var in `IND' {
	replace USemp_`var'=USemp_`var'/1000000
	replace USest_`var'=USest_`var'/1000000
	}	
	
	sum USemp_Healthcare if yq>=yq(2019,1) & yq<=yq(2019,4)
	sum USemp_Healthcare if yq==yq(2020,1)
	sum USemp_Healthcare if yq==yq(2020,2)
	
    local IND Healthcare Physician dentoffice outpatient medlab homehealth Hospital SNF
  	

	foreach X in `IND' {			
	dis "===============`X'====================="
	sum USemp_`X' if yq>=yq(2019,1) & yq<=yq(2019,4)
	sum USemp_`X' if yq==yq(2020,1)
	sum USemp_`X' if yq==yq(2020,2)	
	sum USemp_`X' if yq==yq(2020,4)		
	dis "===================================="	
	}
	* healthcare vs. 2019 mean
	dis 20.23531/ 22.12319*100-100
	dis (22.12319 - 21.6551 )*1000000
	
	* Physician vs. 2019 mean
	dis 2.475367/ 2.724664*100-100
	* dentoffice vs. 2019 mean
	dis .445647/ .9703803*100-100
	* outpatient vs. 2019 mean
	dis .984444/  1.02302 *100-100
	* medlab vs. 2019 mean
	dis .262066/ .283042*100-100
	* homehealth vs. 2019 mean
	dis 1.423597/  1.512057*100-100
	* Hospital vs. 2019 mean
	dis 6.391314/  6.536453 *100-100
	* SNF vs. 2019 mean
	dis 1.560916/ 1.658434*100-100
						
	foreach X in `IND' {			
	dis "===============`X'====================="
	sum USwage_`X' if yq>=yq(2019,1) & yq<=yq(2019,4)
	sum USwage_`X' if yq==yq(2020,2)	
	sum USwage_`X' if yq==yq(2020,4)		
	dis "=========="	

	sum USest_`X' if yq>=yq(2019,1) & yq<=yq(2019,4)
	sum USest_`X' if yq==yq(2020,2)	
	sum USest_`X' if yq==yq(2020,4)		
	dis "===================================="	
	}
	// wage
	* healthcare (q2) vs. 2019 mean
	dis 1026.856/ 1008.944 *100-100 //q2
	dis 1173.631/ 1008.944 *100-100 //q4 	
	* Physician vs. 2019 mean
	dis 1686.017/ 1773.646 *100-100
	dis 2178.11/ 1773.646 *100-100
	* dentoffice vs. 2019 mean
	dis 842.4915/ 1009.097*100-100
	dis 1212.536 / 1009.097*100-100
	
	* Hospital vs. 2019 mean
	dis 1297.546/  1277.235 *100-100
	dis 1423.633/  1277.235 *100-100	
	* SNF vs. 2019 mean
	dis 761.0594/  689.4719  *100-100	
	dis 800.6994/  689.4719  *100-100	
	
	
	
	// establishment 
	dis 1.738395/ 1.654923 *100-100 //q2
	dis 1.771983/ 1.654923 *100-100 //q4 	
	* Physician vs. 2019 mean
	dis .21907/ .2174915 *100-100
	dis .222629 / .2174915 *100-100
	* dentoffice vs. 2019 mean
	dis .131466 / .131985*100-100
	dis .132897   / .131985*100-100
	* Hospital vs. 2019 mean
	dis .01409 /  .0138113 *100-100
	dis .01466/  .0138113 *100-100	
	* SNF vs. 2019 mean
	dis .018776 /  .0186485  *100-100	
	dis .018964/  .0186485  *100-100	
	
	
	
	
* plot each year just once 
egen tag = tag(yq) 
	
set scheme s1color 

* change colours at will, but don't mix red and green 
local colours "cranberry midblue emerald dkorange brown purple navy blue gs7" 
tokenize "`colours'" 

* common options 
local common sort xtitle("") ms(th dh oh X sh th dh oh X sh) lc(`colours') mc(`colours') 
local common `common' legend(off) xsc(r(. 245.5)) 
local common `common' xla(232(1)243, labsize(3.5) ang(60)) 
local j = 1 

*twoway  connected USemp_Healthcare yq if tag, `common' `call' lwidth(0.45..) subtitle("Number of Establishments",size(4)) ytitle("") name(Healthcare, replace) 



	twoway (connected USemp_Healthcare yq if tag, lwidth(0.2) lc(cranberry) mcolor(cranberry%80) msymbol(th) msize(1)) ///
	 (connected USemp_Physician yq if tag, lwidth(0.2) lc(midblue) mcolor(midblue%80) msymbol(dh) msize(1) yaxis(2)) ///	
	 (connected USemp_dentoffice yq if tag, lwidth(0.2) lc(blue) mcolor(blue%80) msymbol(oh) msize(1) yaxis(2)) ///
	 (connected USemp_outpatient yq if tag, lwidth(0.2) lc(dkorange) mcolor(dkorange%80) msymbol(X) msize(1) yaxis(2)) ///
	 (connected USemp_medlab yq if tag, lwidth(0.2) lc(emerald) mcolor(emerald%80) msymbol(sh) msize(1) yaxis(2)) ///
	 (connected USemp_homehealth yq if tag, lwidth(0.2) lc(brown) mcolor(brown%80) msymbol(t) msize(1) yaxis(2)) ///
	 (connected USemp_Hospital yq if tag, lwidth(0.2) lc(purple) mcolor(purple%80) msymbol(d) msize(1) yaxis(2)) ///
	 (connected USemp_SNF yq if tag, lwidth(0.2) lc(navy) mcolor(navy%80) msymbol(o) msize(1) yaxis(2)) /// 
	 , ///	
	legend(rows(2) order(1 "Healthcare" 2 "Physicians" 3 "Dentists" 4 "Outpatient" 5 "Medical labs" 6 "Home health" 7 "Hospitals" ///
	8 "SNFs") size(2) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	ylabel(0(5)25, labsize(2)) ///
	ylabel(0(2)10, labsize(2) axis(2)) ///
	ytitle("Millions of employees (healthcare sector)",s(2.5) color(cranberry)) ///	
	ytitle("Millions of employees (subsectors)",s(2.5) color(black) axis(2)) ///	
	xtitle("") xlabel(`=yq(2018,1)'(1)`=yq(2020,4)',labsize(2)  angle(30)) ///
	title("A. Healthcare employment", pos(11) size(2.5) color(black)) graphregion(color(white)) name(USemp_Healthcare, replace)	
	
	twoway (connected USest_Healthcare yq if tag, lwidth(0.2) lc(cranberry) mcolor(cranberry%80) msymbol(th) msize(1)) ///
	 (connected USest_Physician yq if tag, lwidth(0.2) lc(midblue) mcolor(midblue%80) msymbol(dh) msize(1) yaxis(2)) ///	
	 (connected USest_dentoffice yq if tag, lwidth(0.2) lc(blue) mcolor(blue%80) msymbol(oh) msize(1) yaxis(2)) ///
	 (connected USest_outpatient yq if tag, lwidth(0.2) lc(dkorange) mcolor(dkorange%80) msymbol(X) msize(1) yaxis(2)) ///
	 (connected USest_medlab yq if tag, lwidth(0.2) lc(emerald) mcolor(emerald%80) msymbol(sh) msize(1) yaxis(2)) ///
	 (connected USest_homehealth yq if tag, lwidth(0.2) lc(brown) mcolor(brown%80) msymbol(t) msize(1) yaxis(2)) ///
	 (connected USest_Hospital yq if tag, lwidth(0.2) lc(purple) mcolor(purple%80) msymbol(d) msize(1) yaxis(2)) ///
	 (connected USest_SNF yq if tag, lwidth(0.2) lc(navy) mcolor(navy%80) msymbol(o) msize(1) yaxis(2)) /// 
	 , ///	
	legend(rows(2) order(1 "Healthcare" 2 "Physicians" 3 "Dentists" 4 "Outpatient" 5 "Medical labs" 6 "Home health" 7 "Hospitals" ///
	8 "SNFs") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	ylabel(0(0.5)2, labsize(2)) ///
	ylabel(0(0.05)0.3, labsize(2) axis(2)) ///
	ytitle("Millions of establishments (healthcare sector)",s(2.5) color(cranberry)) ///	
	ytitle("Millions of establishments (subsectors)",s(2.5) color(black) axis(2)) ///	
	xtitle("") xlabel(`=yq(2018,1)'(1)`=yq(2020,4)',labsize(2)  angle(30)) ///
	title("B. Healthcare establishments", pos(11) size(2.5) color(black)) graphregion(color(white)) name(USest_Healthcare, replace)	

	
	twoway (connected USwage_Healthcare yq if tag, lwidth(0.2) lc(cranberry) mcolor(cranberry%80) msymbol(th) msize(1)) ///
	 (connected USwage_Physician yq if tag, lwidth(0.2) lc(midblue) mcolor(midblue%80) msymbol(dh) msize(1) ) ///	
	 (connected USwage_dentoffice yq if tag, lwidth(0.2) lc(blue) mcolor(blue%80) msymbol(oh) msize(1) ) ///
	 (connected USwage_outpatient yq if tag, lwidth(0.2) lc(dkorange) mcolor(dkorange%80) msymbol(X) msize(1) ) ///
	 (connected USwage_medlab yq if tag, lwidth(0.2) lc(emerald) mcolor(emerald%80) msymbol(sh) msize(1) ) ///
	 (connected USwage_homehealth yq if tag, lwidth(0.2) lc(brown) mcolor(brown%80) msymbol(t) msize(1) ) ///
	 (connected USwage_Hospital yq if tag, lwidth(0.2) lc(purple) mcolor(purple%80) msymbol(d) msize(1) ) ///
	 (connected USwage_SNF yq if tag, lwidth(0.2) lc(navy) mcolor(navy%80) msymbol(o) msize(1) ) /// 
	 , ///	
	legend(rows(2) order(1 "Healthcare" 2 "Physicians" 3 "Dentists" 4 "Outpatient" 5 "Medical labs" 6 "Home health" 7 "Hospitals" ///
	8 "SNFs") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	ylabel(0(500)2500, labsize(2)) ///
	ytitle("Dollars",s(2.5) color(black)) ///	
	xtitle("") xlabel(`=yq(2018,1)'(1)`=yq(2020,4)',labsize(2)  angle(30)) ///
	title("C. Average weekly wages", pos(11) size(2.5) color(black)) graphregion(color(white)) name(USwage_Healthcare, replace)	

	
	grc1leg USemp_Healthcare USest_Healthcare  USwage_Healthcare, cols(3) ///
imargin(0 0 0 0) legendfrom(USemp_Healthcare) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Exhibit1_AllIndustry.png",  replace width(4000)  


	
********************************************************************************	
**************** 2020q2
********************************************************************************	

******************** crossectional analysis - decline in employment in 2020q2 
	clear all
	use "${intdir}/QCEW_county_regression2018_2020_covid.dta", clear 

    local IND Healthcare Physician dentoffice outpatient medlab homehealth Hospital SNF
  	
	codebook yq
	keep if yq==yq(2020,2)

	foreach X in `IND' {			
	dis "===============`X'====================="
	codebook area_fips if `X'censored==1 & yq==yq(2020,2)
	tab `X'censored
	replace emp_`X'=. if `X'censored==1
	replace emp_`X'_pop=. if `X'censored==1
	replace Demp_`X'_pop=. if `X'censored==1
	replace wage_`X'=. if `X'censored==1
	replace Dwage_`X'=. if `X'censored==1	
	dis "===================================="	
	}
		

	recode HPSACodePrimaryCare (2=1) (1=2)
	label define PCP 0 "No shortage"  1 "Partial shortage" 2 "Full shortage"
	label values HPSACodePrimaryCare PCP 
	tab HPSACodePrimaryCare
	
	
	gen HPSACode2 = HPSACodePrimaryCare
	recode HPSACode2 (0=1) (2=0)
	label define PCP2 1 "No/partial shortage" 0 "Full shortage"
	label values HPSACode2 PCP2 
	tab HPSACode2	
	
	foreach var in black_ratio pct_insured_18_64 poisoing_dealth rural_ratio unemploy16 cases_pop_q4 cases_pop_q2 {
	xtile D`var' = `var' , nq(5)
	}
		
	
foreach outcome in `IND' {
	if "`outcome'" == "Healthcare" local Sector "Healthcare"	
	if "`outcome'" == "Physician" local Sector "Offices of physicians"
	if "`outcome'" == "dentoffice" local Sector "Offices of Dentists"
	if "`outcome'" == "Hospital" local Sector "Hospitals"
	if "`outcome'" == "SNF" local Sector "Skilled nursing facilities"	
	if "`outcome'" == "outpatient" local Sector "Outpatient care centers"	
	if "`outcome'" == "medlab" local Sector "Medical and Diagnostic Labs"	
	if "`outcome'" == "homehealth" local Sector "Home Helath Care Services"	
	
	label var Any`outcome' "Any establishment - `Sector'" 
	label var wage_`outcome' "Average weekly wage - `Sector'" 
	label var Dwage_`outcome' "12-month change in average weekly wage - `Sector'" 

	label var est_`outcome' "Establishments - `Sector'" 
	label var est_`outcome'_pop "Establishments per 100k persons - `Sector'" 
	label var Dest_`outcome'_pop "12-month change in establishments per 100k persons - `Sector'" 
	label var Dest_`outcome' "12-month change in establishments - `Sector'" 
	
	label var emp_`outcome' "Employment - `Sector'" 
	label var emp_`outcome'_pop "Employment per 100k persons - `Sector'" 
	label var Demp_`outcome'_pop "12-month change in employment per 100k persons - `Sector'" 
	label var Demp_`outcome' "12-month change in employment - `Sector'" 

	
	foreach var in /* Any`outcome' wage_`outcome'  est_`outcome'_pop emp_`outcome'_pop Dest_`outcome' */ Dwage_`outcome' Demp_`outcome'_pop Dest_`outcome'_pop  /// 
		{

	local nY "`var'"
	if "`var'" == "Any`outcome'" local nY "Any establishment"	
	if "`var'" == "wage_`outcome'" local nY "Average wage"
	if "`var'" == "Dwage_`outcome'" local nY "12-month change in wage vs. 2019q2"
	if "`var'" == "est_`outcome'_pop" local nY "Establishments per 100k persons"
	if "`var'" == "Dest_`outcome'_pop" local nY "12-month change in establishments per 100k persons"
	if "`var'" == "Dest_`outcome'" local nY "12-month change in establishments"
	if "`var'" == "emp_`outcome'_pop" local nY "Employment per 100k persons"
	if "`var'" == "Demp_`outcome'_pop" local nY "12-month change in employment"		
	
		
	quiet reghdfe `var' i.Dblack_ratio i.Dcases_pop_q2 i.HPSACode2 hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation URBAN1 , absorb(statecode) vce(cluster statecode) 
	eststo `var'bl
        estadd ysumm	
	margins Dblack_ratio, atmeans post
	eststo M`var'bl
	marginsplot, recast(bar) plotopts(barw(0.6) bc(dkgreen%60)) xlabel(,angle() labsize(2.5) nogrid )  ///
	ylabel(,angle() labsize(2) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector'",size(3)) graphregion(col(white)) ytitle("") xtitle("by quintiles of black populations",size(2)) ///
	name(`var'bl, replace)	
		
	quiet reghdfe `var' i.Dblack_ratio i.Dcases_pop_q2 i.HPSACode2 hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation URBAN1 , absorb(statecode) vce(cluster statecode)   
	eststo `var'PCP
        estadd ysumm	
	margins HPSACode2, atmeans post
	eststo M`var'PCP
	marginsplot, recast(bar) plotopts(barw(0.6) bc(cranberry%60)) xlabel(,angle() labsize(2.5) nogrid )  ///
	ylabel(,angle() labsize(2) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector'",size(3)) graphregion(col(white)) ytitle("") xtitle("",size(2.5)) ///
	name(`var'PCP, replace)		
	
	quiet reghdfe `var' i.Dblack_ratio i.Dcases_pop_q2 i.HPSACode2 hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation URBAN1 , absorb(statecode) vce(cluster statecode) 
	eststo `var'cases
        estadd ysumm	
	margins Dcases_pop_q2, atmeans post
	eststo M`var'cases
	marginsplot, recast(bar) plotopts(barw(0.6) bc(dkorange%60)) xlabel(,angle() labsize(2.5) nogrid )  ///
	ylabel(,angle() labsize(2) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector'",size(3)) graphregion(col(white)) ytitle("") xtitle("Quintiles of COVID-19 cases",size(2)) ///
	name(`var'cases, replace)		
	
	}
	}

	
	foreach var in Demp_ Dest_ {		
	esttab `var'Healthcare_popPCP `var'Physician_popPCP `var'dentoffice_popPCP `var'outpatient_popPCP `var'medlab_popPCP `var'homehealth_popPCP `var'Hospital_popPCP `var'SNF_popPCP using "${tabledir}/Table2_margins_2020q2_`var'pop_PCP_combined.rtf",   ///
	replace  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 
		
	esttab M`var'Healthcare_popPCP M`var'Physician_popPCP M`var'dentoffice_popPCP M`var'outpatient_popPCP M`var'medlab_popPCP M`var'homehealth_popPCP M`var'Hospital_popPCP M`var'SNF_popPCP using "${tabledir}/Table2_margins_2020q2_`var'pop_PCP_combined.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 		
	}
	

foreach var in Dwage_ {		
	esttab `var'HealthcarePCP `var'PhysicianPCP `var'dentofficePCP `var'outpatientPCP `var'medlabPCP `var'homehealthPCP `var'HospitalPCP `var'SNFPCP using "${tabledir}/Table2_margins_2020q2_`var'_PCP_combined.rtf",   ///
	replace  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 
		
	esttab M`var'HealthcarePCP M`var'PhysicianPCP M`var'dentofficePCP M`var'outpatientPCP M`var'medlabPCP M`var'homehealthPCP M`var'HospitalPCP M`var'SNFPCP using "${tabledir}/Table2_margins_2020q2_`var'_PCP_combined.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 		
	}	
	
	
	

		
	grc1leg Demp_Healthcare_popPCP Demp_Physician_popPCP Demp_dentoffice_popPCP Demp_outpatient_popPCP Demp_medlab_popPCP Demp_homehealth_popPCP Demp_Hospital_popPCP Demp_SNF_popPCP, cols(4) ///
imargin(0 0 0 0) xcommon legendfrom(Demp_Healthcare_popPCP) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q2_Demp_pop_PCP_combined.png",  replace width(4000)  


	grc1leg Demp_Healthcare_popcases Demp_Physician_popcases Demp_dentoffice_popcases Demp_outpatient_popcases Demp_medlab_popcases Demp_homehealth_popcases Demp_Hospital_popcases Demp_SNF_popcases, cols(4) ///
imargin(0 0 0 0) xcommon legendfrom(Demp_Healthcare_popcases) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q2_Demp_pop_cases_combined.png",  replace width(4000)  
	
	grc1leg Dwage_HealthcarePCP Dwage_PhysicianPCP Dwage_dentofficePCP Dwage_outpatientPCP Dwage_medlabPCP Dwage_homehealthPCP Dwage_HospitalPCP Dwage_SNFPCP, cols(4) ///
imargin(0 0 0 0) xcommon legendfrom(Dwage_HealthcarePCP) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q2_Dwage_PCP_combined.png",  replace width(4000)  
	
	grc1leg Dwage_Healthcarecases Dwage_Physiciancases Dwage_dentofficecases Dwage_outpatientcases Dwage_medlabcases Dwage_homehealthcases Dwage_Hospitalcases Dwage_SNFcases, cols(4) ///
imargin(0 0 0 0) xcommon legendfrom(Dwage_Healthcarecases) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q2_Dwage_cases_combined.png",  replace width(4000)  
			

// unadjusted tables 	
***************** crossectional analysis - decline in employment in 2020q2 
	clear all
	use "${intdir}/QCEW_county_regression2018_2020_covid.dta", clear 

    local IND Healthcare Physician dentoffice outpatient medlab homehealth Hospital SNF
  	
	codebook yq
	keep if yq==yq(2020,2)

	foreach X in `IND' {			
	dis "===============`X'====================="
	codebook area_fips if `X'censored==1 & yq==yq(2020,2)
	tab `X'censored
	replace emp_`X'=. if `X'censored==1
	replace emp_`X'_pop=. if `X'censored==1
	replace Demp_`X'_pop=. if `X'censored==1
	replace wage_`X'=. if `X'censored==1
	replace Dwage_`X'=. if `X'censored==1	
	dis "===================================="	
	}
		

	recode HPSACodePrimaryCare (2=1) (1=2)
	label define PCP 0 "No shortage"  1 "Partial shortage" 2 "Full shortage"
	label values HPSACodePrimaryCare PCP 
	tab HPSACodePrimaryCare
	
	
	gen HPSACode2 = HPSACodePrimaryCare
	recode HPSACode2 (0=1)
	label define PCP2 1 "No/partial shortage" 2 "Full shortage"
	label values HPSACode2 PCP2 
	tab HPSACode2		

global control AnyPhysician est_Physician est_Physician_pop emp_Physician emp_Physician_pop wage_Physician ///
	Dest_Physician Demp_Physician Demp_Physician_pop  Dwage_Physician ///
	AnyHospital est_Hospital est_Hospital_pop emp_Hospital emp_Hospital_pop wage_Hospital ///
	Dest_Hospital Demp_Hospital Demp_Hospital_pop  Dwage_Hospital ///
	Anyoutpatient est_outpatient est_outpatient_pop emp_outpatient emp_outpatient_pop wage_outpatient ///
	Dest_outpatient Demp_outpatient Demp_outpatient_pop  Dwage_outpatient ///
	AnySNF est_SNF est_SNF_pop emp_SNF emp_SNF_pop wage_SNF ///
	Dest_SNF Demp_SNF Demp_SNF_pop  Dwage_SNF	
	
	
    estpost tabstat $control,  statistics( mean sd p50 min max n) columns(s)
    eststo all: estpost summarize  $control  ///
    if HPSACode2==2 | HPSACode2==1, detail 
    eststo full: estpost summarize $control   ///
    if HPSACode2==2 , detail
    eststo no_full:   estpost summarize $control  ///
    if HPSACode2==1, detail
    eststo diff: estpost ttest $control   ///
    if HPSACode2==2 | HPSACode2==1 , by(HPSACode2) unequal 

    
    esttab all using "${tabledir}/Table1_QCEW_summary_table.rtf",   ///
    replace  ///
    cell((mean(label(Mean) fmt(a2)) sd(par label("Std. Dev") fmt(a2)) min(label(Min)) max(label(Max)) n(label(Obs.)))) ///
    label nogap onecell 
    
                    	
    esttab all full no_full diff  using "${tabledir}/Table2_QCEW_balance_table.rtf", ///
    replace /// 
    starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001) ///
    label nogap onecell ///
    cells( "mean(fmt(a2) pattern(1 1 1 0)) b( star  pattern(0 0 0 1 ) fmt(a2)) " ) 
		
	
	clear all

	
	

	
******************** crossectional analysis - decline in employment in 2020q4 ********************88
	clear all
	use "${intdir}/QCEW_county_regression2018_2020_covid.dta", clear 

    local IND Healthcare Physician dentoffice outpatient medlab homehealth Hospital SNF
  	
	codebook yq
	keep if yq==yq(2020,4)

	foreach X in `IND' {			
	dis "===============`X'====================="
	codebook area_fips if `X'censored==1 & yq==yq(2020,4)
	tab `X'censored
	replace emp_`X'=. if `X'censored==1
	replace emp_`X'_pop=. if `X'censored==1
	replace Demp_`X'_pop=. if `X'censored==1
	replace wage_`X'=. if `X'censored==1
	replace Dwage_`X'=. if `X'censored==1		
	dis "===================================="	
	}
		

	recode HPSACodePrimaryCare (2=1) (1=2)
	label define PCP 0 "No shortage"  1 "Partial shortage" 2 "Full shortage"
	label values HPSACodePrimaryCare PCP 
	tab HPSACodePrimaryCare
	
	
	gen HPSACode2 = HPSACodePrimaryCare
	recode HPSACode2 (0=1) (2=0)
	label define PCP2 1 "No/partial shortage" 0 "Full shortage"
	label values HPSACode2 PCP2 
	tab HPSACode2	
	
	foreach var in black_ratio pct_insured_18_64 poisoing_dealth rural_ratio unemploy16 cases_pop_q4 cases_pop_q2 {
	xtile D`var' = `var' , nq(5)
	}
		
	
foreach outcome in `IND' {
	if "`outcome'" == "Healthcare" local Sector "Healthcare"	
	if "`outcome'" == "Physician" local Sector "Offices of physicians"
	if "`outcome'" == "dentoffice" local Sector "Offices of Dentists"
	if "`outcome'" == "Hospital" local Sector "Hospitals"
	if "`outcome'" == "SNF" local Sector "Skilled nursing facilities"	
	if "`outcome'" == "outpatient" local Sector "Outpatient care centers"	
	if "`outcome'" == "medlab" local Sector "Medical and Diagnostic Labs"	
	if "`outcome'" == "homehealth" local Sector "Home Helath Care Services"	
	
	label var Any`outcome' "Any establishment - `Sector'" 
	label var wage_`outcome' "Average weekly wage - `Sector'" 
	label var Dwage_`outcome' "12-month change in average weekly wage - `Sector'" 

	label var est_`outcome' "Establishments - `Sector'" 
	label var est_`outcome'_pop "Establishments per 100k persons - `Sector'" 
	label var Dest_`outcome'_pop "12-month change in establishments per 100k persons - `Sector'" 
	label var Dest_`outcome' "12-month change in establishments - `Sector'" 
	
	label var emp_`outcome' "Employment - `Sector'" 
	label var emp_`outcome'_pop "Employment per 100k persons - `Sector'" 
	label var Demp_`outcome'_pop "12-month change in employment per 100k persons - `Sector'" 
	label var Demp_`outcome' "12-month change in employment - `Sector'" 

	
	foreach var in /* Any`outcome' wage_`outcome'  est_`outcome'_pop emp_`outcome'_pop Dest_`outcome' */ Dwage_`outcome' Demp_`outcome'_pop Dest_`outcome'_pop  /// 
		{

	local nY "`var'"
	if "`var'" == "Any`outcome'" local nY "Any establishment"	
	if "`var'" == "wage_`outcome'" local nY "Average wage"
	if "`var'" == "Dwage_`outcome'" local nY "12-month change in wage vs. 2019q4"
	if "`var'" == "est_`outcome'_pop" local nY "Establishments per 100k persons"
	if "`var'" == "Dest_`outcome'_pop" local nY "12-month change in establishments per 100k persons"
	if "`var'" == "Dest_`outcome'" local nY "12-month change in establishments"
	if "`var'" == "emp_`outcome'_pop" local nY "Employment per 100k persons"
	if "`var'" == "Demp_`outcome'_pop" local nY "12-month change in employment"		
	
		
	quiet reghdfe `var' i.Dblack_ratio i.Dcases_pop_q4 i.HPSACode2 hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation URBAN1 , absorb(statecode) vce(cluster statecode) 
	eststo `var'bl
        estadd ysumm	
	margins Dblack_ratio, atmeans post
	eststo M`var'bl
	marginsplot, recast(bar) plotopts(barw(0.6) bc(dkgreen%60)) xlabel(,angle() labsize(2.5) nogrid )  ///
	ylabel(,angle() labsize(2) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector'",size(3)) graphregion(col(white)) ytitle("") xtitle("by quintiles of black populations",size(2)) ///
	name(`var'bl, replace)	
		
	quiet reghdfe `var' i.Dblack_ratio i.Dcases_pop_q4 i.HPSACode2 hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation URBAN1 , absorb(statecode) vce(cluster statecode)   
	eststo `var'PCP
        estadd ysumm	
	margins HPSACode2, atmeans post
	eststo M`var'PCP
	marginsplot, recast(bar) plotopts(barw(0.6) bc(cranberry%60)) xlabel(,angle() labsize(2.5) nogrid )  ///
	ylabel(,angle() labsize(2) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector'",size(3)) graphregion(col(white)) ytitle("") xtitle("",size(2.5)) ///
	name(`var'PCP, replace)		
	
	quiet reghdfe `var' i.Dblack_ratio i.Dcases_pop_q4 i.HPSACode2 hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation URBAN1 , absorb(statecode) vce(cluster statecode) 
	eststo `var'cases
        estadd ysumm	
	margins Dcases_pop_q4, atmeans post
	eststo M`var'cases
	marginsplot, recast(bar) plotopts(barw(0.6) bc(dkorange%60)) xlabel(,angle() labsize(2.5) nogrid )  ///
	ylabel(,angle() labsize(2) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector'",size(3)) graphregion(col(white)) ytitle("") xtitle("Quintiles of COVID-19 cases",size(2)) ///
	name(`var'cases, replace)		
	
	}
	}

	
	foreach var in Demp_ Dest_ {		
	esttab `var'Healthcare_popPCP `var'Physician_popPCP `var'dentoffice_popPCP `var'outpatient_popPCP `var'medlab_popPCP `var'homehealth_popPCP `var'Hospital_popPCP `var'SNF_popPCP using "${tabledir}/Table2_margins_2020q4_`var'pop_PCP_combined.rtf",   ///
	replace  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 
		
	esttab M`var'Healthcare_popPCP M`var'Physician_popPCP M`var'dentoffice_popPCP M`var'outpatient_popPCP M`var'medlab_popPCP M`var'homehealth_popPCP M`var'Hospital_popPCP M`var'SNF_popPCP using "${tabledir}/Table2_margins_2020q4_`var'pop_PCP_combined.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 		
	}
	

foreach var in Dwage_ {		
	esttab `var'HealthcarePCP `var'PhysicianPCP `var'dentofficePCP `var'outpatientPCP `var'medlabPCP `var'homehealthPCP `var'HospitalPCP `var'SNFPCP using "${tabledir}/Table2_margins_2020q4_`var'_PCP_combined.rtf",   ///
	replace  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 
		
	esttab M`var'HealthcarePCP M`var'PhysicianPCP M`var'dentofficePCP M`var'outpatientPCP M`var'medlabPCP M`var'homehealthPCP M`var'HospitalPCP M`var'SNFPCP using "${tabledir}/Table2_margins_2020q4_`var'_PCP_combined.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 		
	}	
	
	
	

		
	grc1leg Demp_Healthcare_popPCP Demp_Physician_popPCP Demp_dentoffice_popPCP Demp_outpatient_popPCP Demp_medlab_popPCP Demp_homehealth_popPCP Demp_Hospital_popPCP Demp_SNF_popPCP, cols(4) ///
imargin(0 0 0 0) xcommon legendfrom(Demp_Healthcare_popPCP) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q4_Demp_pop_PCP_combined.png",  replace width(4000)  


	grc1leg Demp_Healthcare_popcases Demp_Physician_popcases Demp_dentoffice_popcases Demp_outpatient_popcases Demp_medlab_popcases Demp_homehealth_popcases Demp_Hospital_popcases Demp_SNF_popcases, cols(4) ///
imargin(0 0 0 0) xcommon legendfrom(Demp_Healthcare_popcases) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q4_Demp_pop_cases_combined.png",  replace width(4000)  
	
	grc1leg Dwage_HealthcarePCP Dwage_PhysicianPCP Dwage_dentofficePCP Dwage_outpatientPCP Dwage_medlabPCP Dwage_homehealthPCP Dwage_HospitalPCP Dwage_SNFPCP, cols(4) ///
imargin(0 0 0 0) xcommon legendfrom(Dwage_HealthcarePCP) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q4_Dwage_PCP_combined.png",  replace width(4000)  
	
	grc1leg Dwage_Healthcarecases Dwage_Physiciancases Dwage_dentofficecases Dwage_outpatientcases Dwage_medlabcases Dwage_homehealthcases Dwage_Hospitalcases Dwage_SNFcases, cols(4) ///
imargin(0 0 0 0) xcommon legendfrom(Dwage_Healthcarecases) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q4_Dwage_cases_combined.png",  replace width(4000)  
			
			
	clear all
	
	
**************** sensitivity analysis: no state FE
******************** crossectional analysis - decline in employment in 2020q2 
	clear all
	use "${intdir}/QCEW_county_regression2018_2020_covid.dta", clear 

    local IND Healthcare Physician dentoffice outpatient medlab homehealth Hospital SNF
  	
	codebook yq
	keep if yq==yq(2020,2)

	foreach X in `IND' {			
	dis "===============`X'====================="
	codebook area_fips if `X'censored==1 & yq==yq(2020,2)
	tab `X'censored
	replace emp_`X'=. if `X'censored==1
	replace emp_`X'_pop=. if `X'censored==1
	replace Demp_`X'_pop=. if `X'censored==1
	replace wage_`X'=. if `X'censored==1
	replace Dwage_`X'=. if `X'censored==1	
	dis "===================================="	
	}
		

	recode HPSACodePrimaryCare (2=1) (1=2)
	label define PCP 0 "No shortage"  1 "Partial shortage" 2 "Full shortage"
	label values HPSACodePrimaryCare PCP 
	tab HPSACodePrimaryCare
	
	
	gen HPSACode2 = HPSACodePrimaryCare
	recode HPSACode2 (0=1) (2=0)
	label define PCP2 1 "No/partial shortage" 0 "Full shortage"
	label values HPSACode2 PCP2 
	tab HPSACode2	
	
	foreach var in black_ratio pct_insured_18_64 poisoing_dealth rural_ratio unemploy16 cases_pop_q4 cases_pop_q2 {
	xtile D`var' = `var' , nq(5)
	}
		
	
foreach outcome in `IND' {
	if "`outcome'" == "Healthcare" local Sector "Healthcare"	
	if "`outcome'" == "Physician" local Sector "Offices of physicians"
	if "`outcome'" == "dentoffice" local Sector "Offices of Dentists"
	if "`outcome'" == "Hospital" local Sector "Hospitals"
	if "`outcome'" == "SNF" local Sector "Skilled nursing facilities"	
	if "`outcome'" == "outpatient" local Sector "Outpatient care centers"	
	if "`outcome'" == "medlab" local Sector "Medical and Diagnostic Labs"	
	if "`outcome'" == "homehealth" local Sector "Home Helath Care Services"	
	
	label var Any`outcome' "Any establishment - `Sector'" 
	label var wage_`outcome' "Average weekly wage - `Sector'" 
	label var Dwage_`outcome' "12-month change in average weekly wage - `Sector'" 

	label var est_`outcome' "Establishments - `Sector'" 
	label var est_`outcome'_pop "Establishments per 100k persons - `Sector'" 
	label var Dest_`outcome'_pop "12-month change in establishments per 100k persons - `Sector'" 
	label var Dest_`outcome' "12-month change in establishments - `Sector'" 
	
	label var emp_`outcome' "Employment - `Sector'" 
	label var emp_`outcome'_pop "Employment per 100k persons - `Sector'" 
	label var Demp_`outcome'_pop "12-month change in employment per 100k persons - `Sector'" 
	label var Demp_`outcome' "12-month change in employment - `Sector'" 

	
	foreach var in /* Any`outcome' wage_`outcome'  est_`outcome'_pop emp_`outcome'_pop Dest_`outcome' */ Dwage_`outcome' Demp_`outcome'_pop Dest_`outcome'_pop  /// 
		{

	local nY "`var'"
	if "`var'" == "Any`outcome'" local nY "Any establishment"	
	if "`var'" == "wage_`outcome'" local nY "Average wage"
	if "`var'" == "Dwage_`outcome'" local nY "12-month change in wage vs. 2019q2"
	if "`var'" == "est_`outcome'_pop" local nY "Establishments per 100k persons"
	if "`var'" == "Dest_`outcome'_pop" local nY "12-month change in establishments per 100k persons"
	if "`var'" == "Dest_`outcome'" local nY "12-month change in establishments"
	if "`var'" == "emp_`outcome'_pop" local nY "Employment per 100k persons"
	if "`var'" == "Demp_`outcome'_pop" local nY "12-month change in employment"		
	
		
	quiet reghdfe `var' i.Dblack_ratio i.Dcases_pop_q2 i.HPSACode2 hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation URBAN1 , absorb(yq) vce(cluster statecode) 
	eststo `var'bl
        estadd ysumm	
	margins Dblack_ratio, atmeans post
	eststo M`var'bl
	marginsplot, recast(bar) plotopts(barw(0.6) bc(dkgreen%60)) xlabel(,angle() labsize(2.5) nogrid )  ///
	ylabel(,angle() labsize(2) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector'",size(3)) graphregion(col(white)) ytitle("") xtitle("by quintiles of black populations",size(2)) ///
	name(`var'bl, replace)	
		
	quiet reghdfe `var' i.Dblack_ratio i.Dcases_pop_q2 i.HPSACode2 hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation URBAN1 , absorb(yq) vce(cluster statecode)   
	eststo `var'PCP
        estadd ysumm	
	margins HPSACode2, atmeans post
	eststo M`var'PCP
	marginsplot, recast(bar) plotopts(barw(0.6) bc(cranberry%60)) xlabel(,angle() labsize(2.5) nogrid )  ///
	ylabel(,angle() labsize(2) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector'",size(3)) graphregion(col(white)) ytitle("") xtitle("",size(2.5)) ///
	name(`var'PCP, replace)		
	
	quiet reghdfe `var' i.Dblack_ratio i.Dcases_pop_q2 i.HPSACode2 hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation URBAN1 , absorb(yq) vce(cluster statecode) 
	eststo `var'cases
        estadd ysumm	
	margins Dcases_pop_q2, atmeans post
	eststo M`var'cases
	marginsplot, recast(bar) plotopts(barw(0.6) bc(dkorange%60)) xlabel(,angle() labsize(2.5) nogrid )  ///
	ylabel(,angle() labsize(2) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector'",size(3)) graphregion(col(white)) ytitle("") xtitle("Quintiles of COVID-19 cases",size(2)) ///
	name(`var'cases, replace)		
	
	}
	}

	
	foreach var in Demp_ Dest_ {		
	esttab `var'Healthcare_popPCP `var'Physician_popPCP `var'dentoffice_popPCP `var'outpatient_popPCP `var'medlab_popPCP `var'homehealth_popPCP `var'Hospital_popPCP `var'SNF_popPCP using "${tabledir}/Table2_margins_2020q2_`var'pop_PCP_combined_noStateFE.rtf",   ///
	replace  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 
		
	esttab M`var'Healthcare_popPCP M`var'Physician_popPCP M`var'dentoffice_popPCP M`var'outpatient_popPCP M`var'medlab_popPCP M`var'homehealth_popPCP M`var'Hospital_popPCP M`var'SNF_popPCP using "${tabledir}/Table2_margins_2020q2_`var'pop_PCP_combined_noStateFE.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 		
	}
	

foreach var in Dwage_ {		
	esttab `var'HealthcarePCP `var'PhysicianPCP `var'dentofficePCP `var'outpatientPCP `var'medlabPCP `var'homehealthPCP `var'HospitalPCP `var'SNFPCP using "${tabledir}/Table2_margins_2020q2_`var'_PCP_combined_noStateFE.rtf",   ///
	replace  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 
		
	esttab M`var'HealthcarePCP M`var'PhysicianPCP M`var'dentofficePCP M`var'outpatientPCP M`var'medlabPCP M`var'homehealthPCP M`var'HospitalPCP M`var'SNFPCP using "${tabledir}/Table2_margins_2020q2_`var'_PCP_combined_noStateFE.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ysd N r2,fmt(%3.2f %3.2f 0 %3.2f )  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs." "R2" )) 		
	}	
	
	
	clear all
	
	exit
