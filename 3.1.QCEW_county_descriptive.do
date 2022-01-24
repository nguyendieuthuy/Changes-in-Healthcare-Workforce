
/* Start log */
capture log close
log using "${logdir}/2.3.Final_Results$S_DATE.log", replace

		
/// exporting data  
	use  "${intdir}/qcew_2011_2021yq_nation_covid.dta",clear
	
	sort yq 
	gen year =year(dofq(yq))
	keep if yq>=yq(2018,1)	
	
    local IND Healthcare ambHCservice Physician dentoffice otheoffice outpatient medlab homehealth otheambHC Hospital genhospital SUDhospital spechospital ///
	nurseResid SNF residcare retirecom otherresid other All
  		
	keep yq year *Healthcare *Physician *dentoffice *homehealth *Hospital *SNF *other *All
	order yq year USemp*
	export excel using $tabledir/qcew_2018_2021yq_nation_by_industry, replace firstrow(var)	
	
/// nationwide trends	
	use  "${intdir}/qcew_2011_2021yq_nation_covid.dta",clear	
	sort yq 
	keep if yq>=yq(2019,1) & yq<=yq(2019,4)	
	collapse USemp_* USwage_* USest_*
	ren (USemp_* USwage_* USest_*) (BUSemp_* BUSwage_* BUSest_*)
	save  "${intdir}/qcew_2019yq_nation_covid.dta",replace 
	
	use  "${intdir}/qcew_2011_2021yq_nation_covid.dta",clear	
	keep if yq>=yq(2019,4)	
	append using "${intdir}/qcew_2019yq_nation_covid.dta"
	foreach var in USemp_Healthcare USemp_ambHCservice USemp_Physician USemp_dentoffice USemp_otheoffice USemp_outpatient USemp_medlab USemp_homehealth USemp_otheambHC USemp_Hospital USemp_genhospital USemp_SUDhospital USemp_spechospital USemp_nurseResid USemp_SNF USemp_residcare USemp_retirecom USemp_otherresid USemp_other USwage_Healthcare USwage_ambHCservice USwage_Physician USwage_dentoffice USwage_otheoffice USwage_outpatient USwage_medlab USwage_homehealth USwage_otheambHC USwage_Hospital USwage_genhospital USwage_SUDhospital USwage_spechospital USwage_nurseResid USwage_SNF USwage_residcare USwage_retirecom USwage_otherresid USwage_other USest_Healthcare USest_ambHCservice USest_Physician USest_dentoffice USest_otheoffice USest_outpatient USest_medlab USest_homehealth USest_otheambHC USest_Hospital USest_genhospital USest_SUDhospital USest_spechospital USest_nurseResid USest_SNF USest_residcare USest_retirecom USest_otherresid USest_other {
	egen mB`var'=mean(B`var')
	replace B`var'=	mB`var'
	
	replace `var'=B`var' if yq==yq(2019,4)
	}
	
	
	drop if yq==. 
	

    local IND Healthcare ambHCservice Physician dentoffice otheoffice outpatient medlab homehealth otheambHC Hospital genhospital SUDhospital spechospital ///
	nurseResid SNF residcare retirecom otherresid other
	
	foreach var in `IND' {
	gen GUSemp_`var'=USemp_`var'/BUSemp_`var'*100
	gen GUSwage_`var'=USwage_`var'/BUSwage_`var'*100
	}	

	
	foreach var in `IND' {
	replace USemp_`var'=USemp_`var'/1000000
	replace USest_`var'=USest_`var'/1000000
	}	
	
	
    local IND Physician dentoffic homehealth Hospital SNF other  	

	foreach X in `IND' {			
	dis "===============`X'====================="
	sum BUSemp_`X' // average 2019
	sum USemp_`X' if yq>=yq(2020,1) & yq<=yq(2020,4)
	sum USemp_`X' if yq>=yq(2021,1)
	
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
	sum BUSwage_`X'
	sum USwage_`X' if yq==yq(2020,2)	
	sum USwage_`X' if yq==yq(2020,4)		
	dis "=========="	

	sum BUSest_`X' 
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

// percent change compared to average 2019 

	twoway (connected GUSemp_Physician yq if tag, lwidth(0.25) lc(cranberry) mcolor(cranberry%80) msymbol(dh) msize(1) ) ///	
	 (connected GUSemp_dentoffice yq if tag, lwidth(0.25) lc(midblue) mcolor(midblue%80) msymbol(oh) msize(1) ) ///
	 (connected GUSemp_Hospital yq if tag, lwidth(0.25) lc(dkgreen) mcolor(dkgreen%80) msymbol(th) msize(1) ) ///
	 (connected GUSemp_SNF yq if tag, lwidth(0.25) lc(navy) mcolor(navy%80) msymbol(sh) msize(1) ) /// 
	 (connected GUSemp_homehealth yq if tag, lwidth(0.25) lc(mint) mcolor(mint%80) msymbol(o) msize(1) ) /// 
	 (connected GUSemp_other yq if tag, lwidth(0.25) lc(dkorange) mcolor(dkorange%80) msymbol(X) msize(1) ) /// 
	 , ///	
	legend(rows(2) order(1 "Offices of physicians" 2 "Offices of dentists" 3 "Hospitals" ///
	4 "SNFs" 5 "Home health care services"  6 "Other healthcare sectors") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	yline(100,lcolor(gs14) lwidth(0.4)) ///
	ylabel(85(5)115, labsize(3) angle(0)) ///
	ytitle("Percent, relative to 2019",s(3)) ///	
	xtitle("") xlabel(239 "Average 2019" `=yq(2020,1)'(1)`=yq(2021,2)' , labsize(3)  angle(30) tposition(inside)) ///
	title("A. Employment level", pos(11) size(3) color(black)) graphregion(color(white)) name(GUSemp, replace)	

	twoway (connected GUSwage_Physician yq if tag, lwidth(0.25) lc(cranberry) mcolor(cranberry%80) msymbol(dh) msize(1) ) ///	
	 (connected GUSwage_dentoffice yq if tag, lwidth(0.25) lc(midblue) mcolor(midblue%80) msymbol(oh) msize(1) ) ///
	 (connected GUSwage_Hospital yq if tag, lwidth(0.25) lc(dkgreen) mcolor(dkgreen%80) msymbol(th) msize(1) ) ///
	 (connected GUSwage_SNF yq if tag, lwidth(0.25) lc(navy) mcolor(navy%80) msymbol(sh) msize(1) ) /// 
	 (connected GUSwage_homehealth yq if tag, lwidth(0.25) lc(mint) mcolor(mint%80) msymbol(o) msize(1) ) /// 
	 (connected GUSwage_other yq if tag, lwidth(0.25) lc(dkorange) mcolor(dkorange%80) msymbol(X) msize(1) ) /// 
	 , ///	
	legend(rows(2) order(1 "Offices of physicians" 2 "Offices of dentists" 3 "Hospitals" ///
	4 "SNFs" 5 "Home health care services"  6 "Other healthcare sectors") size(3) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	yline(100,lcolor(gs14) lwidth(0.4)) ///
	ylabel(70(10)130, labsize(3) angle(0)) ///
	ytitle("",s(3)) ///	
	xtitle("") xlabel(239 "Average 2019" `=yq(2020,1)'(1)`=yq(2021,2)' , labsize(3)  angle(30) tposition(inside)) ///
	title("B. Average weekly wages", pos(11) size(3) color(black)) graphregion(color(white)) name(GUSwage, replace)	

	
	
	grc1leg GUSemp GUSwage, cols(2) ///
imargin(0 3 0 0) legendfrom(GUSemp) graphregion(color(white)) xsize(5) ysize(8) ///
			title("", color(black)   size(5)) 
	graph export "${tabledir}/Exhibit1_employment_percent.png",  replace width(4000)  
	graph export "${tabledir}/Exhibit1_employment_percent.tif",  replace   


	
	
	

	
********************************************************************************	
********************************************************************************	
******************** crossectional analysis - decline in employment in 2020q2
	
 
	clear all
	use "${intdir}/QCEW_county_regression2018_2021_covid.dta", clear 

	keep if yq==yq(2020,2)
	

	local IND Healthcare Physician dentoffice outpatient medlab homehealth Hospital SNF other
  	
	
	foreach X in `IND' {			
	dis "===============`X'====================="
	codebook area_fips if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace emp_`X'=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace emp_`X'_pop=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace Demp_`X'_pop=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace BDemp_`X'_pop=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace Bemp_`X'_pop=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace wage_`X'=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace Dwage_`X'=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	dis "===================================="	
	}
		

	recode HPSACodePrimaryCare (0=3)
	label define PCP 3 "No shortage"  2 "Partial shortage" 1 "Full shortage"
	label values HPSACodePrimaryCare PCP 
	tab HPSACodePrimaryCare

	/*
	gen HPSACode2 = HPSACodePrimaryCare
	recode HPSACodePrimaryCare (0=1) (2=0)
	label define PCP2 1 "No/partial shortage" 0 "Full shortage"
	label values HPSACodePrimaryCare PCP2 
	tab HPSACodePrimaryCare	
	*/
	foreach var in black_ratio rural_ratio unemploy16 pct_insured_18_64 cases_pop_q2 cases_pop_2021q2 activeMDs_pop {
		sum 
	xtile D`var' = -`var' , nq(5)
	}
		
		
	sum Demp_*
	sum i.Dcases_pop_q2 i.DactiveMDs_pop black_ratio  age65_ratio   hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation rural_ratio

	
foreach outcome in `IND' {
	if "`outcome'" == "Healthcare" local Sector "Healthcare"	
	if "`outcome'" == "Physician" local Sector "Offices of physicians"
	if "`outcome'" == "dentoffice" local Sector "Offices of dentists"
	if "`outcome'" == "Hospital" local Sector "Hospitals"
	if "`outcome'" == "SNF" local Sector "Skilled nursing facilities"	
	if "`outcome'" == "outpatient" local Sector "Outpatient care centers"	
	if "`outcome'" == "medlab" local Sector "Medical and Diagnostic Labs"	
	if "`outcome'" == "homehealth" local Sector "Home health care services"	
	if "`outcome'" == "other" local Sector "Other healthcare sectors"	

	label var wage_`outcome' "Average weekly wage - `Sector'" 
	label var Dwage_`outcome' "12-month change in average weekly wage - `Sector'" 

	label var est_`outcome' "Establishments - `Sector'" 
	label var est_`outcome'_pop "Establishments per 100k persons - `Sector'" 
	label var Dest_`outcome'_pop "12-month change in establishments per 100k persons - `Sector'" 
	label var Dest_`outcome' "12-month change in establishments - `Sector'" 
	
	label var emp_`outcome' "Employment - `Sector'" 
	label var emp_`outcome'_pop "Employment per 100k persons - `Sector'" 
	label var BDemp_`outcome'_pop "12-month change in employment per 100k persons - `Sector'" 
	label var Bemp_`outcome'_pop "Percent change in employment per 100k persons - `Sector'" 
	label var Demp_`outcome' "12-month change in employment - `Sector'" 

	local Q1 "By quintile of COVID-19 burden"
	local Q2 "By quintile of active MDs per residents"
	
	foreach var in Bemp_`outcome'_pop  /// 
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
	if "`var'" == "BDemp_`outcome'_pop" local nY "12-month change in employment"		
	if "`var'" == "Bemp_`outcome'_pop" local nY "Employment level relative to June 2019"		

			
	quiet reghdfe `var' i.Dcases_pop_q2 i.DactiveMDs_pop black_ratio  age65_ratio   hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation rural_ratio , noabsorb vce(cluster statecode)   
	eststo `var'PCP
        estadd ysumm	
	margins DactiveMDs_pop, atmeans post
	eststo M`var'PCP
	marginsplot, recast(bar) plotopts(barw(0.6) bc(cranberry%60)) xlabel(,angle() labsize(3) nogrid )  ///
	ylabel(,angle(90) labsize(3) ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector' (June 2020)",size(3)) graphregion(col(white)) ytitle("Percent",size(3)) xtitle("`Q2'",size(3)) ///
	name(`var'PCP, replace)		
	
	quiet reghdfe `var' i.Dcases_pop_q2 i.DactiveMDs_pop black_ratio  age65_ratio   hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation rural_ratio , noabsorb vce(cluster statecode) 
	eststo `var'cases
        estadd ysumm	
	margins Dcases_pop_q2, atmeans post
	eststo M`var'cases
	marginsplot, recast(bar) plotopts(barw(0.6) bc(dkorange%60)) xlabel(,angle() labsize(3) nogrid )  ///
	ylabel(,angle(90) labsize(3) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector' (June 2020)",size(3)) graphregion(col(white)) ytitle("Percent",size(3)) xtitle("`Q1'",size(3)) ///
	name(`var'cases, replace)		
	
	quiet reghdfe `var' i.Dcases_pop_q2 i.DactiveMDs_pop black_ratio  age65_ratio   hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation rural_ratio , noabsorb vce(cluster statecode)   
 	gen include`var'=e(sample)==1 		
			
	}
	}

	
	foreach var in Bemp_ {		
	esttab `var'SNF_popPCP `var'Physician_popPCP `var'dentoffice_popPCP `var'homehealth_popPCP `var'Hospital_popPCP  `var'other_popPCP using "${tabledir}/Table2_margins_2020q2_`var'pop_PCP_combined.rtf",   ///
	replace  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ymedian ysd N,fmt(%3.2f %3.2f  %3.2f  0)  ///
	label("Dep. Variable Mean"  "Dep. Variable Median" "Dep. Variable SD" "Observations (N counties)" )) 	
	
		
	esttab M`var'SNF_popPCP M`var'Physician_popPCP M`var'dentoffice_popPCP M`var'homehealth_popPCP M`var'Hospital_popPCP  M`var'other_popPCP using "${tabledir}/Table2_margins_2020q2_`var'pop_PCP_combined.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ymedian ysd N,fmt(%3.2f %3.2f  %3.2f  0)  ///
	label("Dep. Variable Mean"  "Dep. Variable Median" "Dep. Variable SD" "Observations (N counties)" )) 	
	
		
	esttab M`var'SNF_popcases M`var'Physician_popcases M`var'dentoffice_popcases M`var'homehealth_popcases M`var'Hospital_popcases  M`var'other_popcases using "${tabledir}/Table2_margins_2020q2_`var'pop_PCP_combined.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ymedian ysd N,fmt(%3.2f %3.2f  %3.2f  0)  ///
	label("Dep. Variable Mean"  "Dep. Variable Median" "Dep. Variable SD" "Observations (N counties)" )) 	

	}
		
		
	grc1leg Bemp_SNF_popPCP Bemp_Physician_popPCP Bemp_dentoffice_popPCP Bemp_homehealth_popPCP Bemp_Hospital_popPCP  Bemp_other_popPCP, cols(3) ///
imargin(0 0 0 0) xcommon legendfrom(Bemp_Physician_popPCP) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q2_Bemp_pop_PCP_combined.png",  replace width(4000)  


	grc1leg Bemp_SNF_popcases Bemp_Physician_popcases Bemp_dentoffice_popcases Bemp_homehealth_popcases Bemp_Hospital_popcases  Bemp_other_popcases, cols(3) ///
imargin(0 0 0 0) xcommon legendfrom(Bemp_Physician_popcases) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2020q2_Bemp_pop_cases_combined.png",  replace width(4000)  
		


		
		
	foreach outcome in `IND' {
	sum Bemp_`outcome'_pop if includeBemp_`outcome'_pop==1,detail
	}		

////////////////////////////////////////////////////////////////////////////////////////////////////
		
********************************************************************************	
********************************************************************************	
******************** crossectional analysis - decline in employment in 2021q2	 

	use "${intdir}/QCEW_county_regression2018_2021_covid.dta", clear 

	keep if yq==yq(2021,2)
		
	local IND Healthcare Physician dentoffice outpatient medlab homehealth Hospital SNF other 	
	
	foreach X in `IND' {			
	dis "===============`X'====================="
	codebook area_fips if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace emp_`X'=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace emp_`X'_pop=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace Demp_`X'_pop=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace BDemp_`X'_pop=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace Bemp_`X'_pop=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace wage_`X'=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	replace Dwage_`X'=. if (est_`X' !=. & est_`X'>0 ) &  (emp_`X' ==. | emp_`X'==0)
	dis "===================================="	
	}
		

	recode HPSACodePrimaryCare (0=3)
	label define PCP 3 "No shortage"  2 "Partial shortage" 1 "Full shortage"
	label values HPSACodePrimaryCare PCP 
	tab HPSACodePrimaryCare


	foreach var in black_ratio rural_ratio unemploy16 pct_insured_18_64 cases_pop_q2 cases_pop_2021q2 activeMDs_pop {
		sum 
	xtile D`var' = -`var' , nq(5)
	}
				
	sum Demp_*
	sum i.Dcases_pop_q2 i.DactiveMDs_pop black_ratio  age65_ratio   hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation rural_ratio

	
foreach outcome in `IND' {
	if "`outcome'" == "Healthcare" local Sector "Healthcare"	
	if "`outcome'" == "Physician" local Sector "Offices of physicians"
	if "`outcome'" == "dentoffice" local Sector "Offices of dentists"
	if "`outcome'" == "Hospital" local Sector "Hospitals"
	if "`outcome'" == "SNF" local Sector "Skilled nursing facilities"	
	if "`outcome'" == "outpatient" local Sector "Outpatient care centers"	
	if "`outcome'" == "medlab" local Sector "Medical and Diagnostic Labs"	
	if "`outcome'" == "homehealth" local Sector "Home health care services"	
	if "`outcome'" == "other" local Sector "Other healthcare sectors"	
	
	label var wage_`outcome' "Average weekly wage - `Sector'" 
	label var Dwage_`outcome' "12-month change in average weekly wage - `Sector'" 

	label var est_`outcome' "Establishments - `Sector'" 
	label var est_`outcome'_pop "Establishments per 100k persons - `Sector'" 
	label var Dest_`outcome'_pop "12-month change in establishments per 100k persons - `Sector'" 
	label var Dest_`outcome' "12-month change in establishments - `Sector'" 
	
	label var emp_`outcome' "Employment - `Sector'" 
	label var emp_`outcome'_pop "Employment per 100k persons - `Sector'" 
	label var BDemp_`outcome'_pop "12-month change in employment per 100k persons - `Sector'" 
	label var Bemp_`outcome'_pop "Percent change in employment per 100k persons - `Sector'" 
	label var Demp_`outcome' "12-month change in employment - `Sector'" 

	local Q1 "By quintile of COVID-19 burden"
	local Q2 "By quintile of active MDs per residents"
	
	foreach var in Bemp_`outcome'_pop  /// 
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
	if "`var'" == "BDemp_`outcome'_pop" local nY "12-month change in employment"		
	if "`var'" == "Bemp_`outcome'_pop" local nY "Employment level relative to June 2019"		

			
	quiet reghdfe `var' i.Dcases_pop_2021q2 i.DactiveMDs_pop black_ratio  age65_ratio   hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation rural_ratio , noabsorb vce(cluster statecode)   
	eststo `var'PCP
        estadd ysumm	
	margins DactiveMDs_pop, atmeans post
	eststo M`var'PCP
	marginsplot, recast(bar) plotopts(barw(0.6) bc(cranberry%60)) xlabel(,angle() labsize(3) nogrid )  ///
	ylabel(,angle(90) labsize(3) ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector' (June 2021)",size(3)) graphregion(col(white)) ytitle("Percent",size(3)) xtitle("`Q2'",size(3)) ///
	name(`var'PCP_b, replace)		
	
	quiet reghdfe `var' i.Dcases_pop_2021q2 i.DactiveMDs_pop black_ratio  age65_ratio   hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation rural_ratio , noabsorb vce(cluster statecode) 
	eststo `var'cases
        estadd ysumm	
	margins Dcases_pop_2021q2, atmeans post
	eststo M`var'cases
	marginsplot, recast(bar) plotopts(barw(0.6) bc(dkorange%60)) xlabel(,angle() labsize(3) nogrid )  ///
	ylabel(,angle(90) labsize(3) nogrid ) ///
	legend(rows(1) order(1 "Adjusted mean (`nY')" 2 "95% CI") size(2.5) symxsize(5) bmargin(zero) region(lc(none)) colgap(2) rowgap(0) pos(12) ) ///
	title("`Sector' (June 2021)",size(3)) graphregion(col(white)) ytitle("Percent",size(3)) xtitle("`Q1'",size(3)) ///
	name(`var'cases_b, replace)		
	
	quiet reghdfe `var' i.Dcases_pop_2021q2 i.DactiveMDs_pop black_ratio  age65_ratio   hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation rural_ratio , noabsorb vce(cluster statecode)   
 	gen include`var'=e(sample)==1 		
				
	}
	}

	
	foreach var in Bemp_ {		
	esttab `var'SNF_popPCP `var'Physician_popPCP `var'dentoffice_popPCP `var'homehealth_popPCP `var'Hospital_popPCP  `var'other_popPCP using "${tabledir}/Table2_margins_2021q2_`var'pop_PCP_combined.rtf",   ///
	replace  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ymedian ysd N,fmt(%3.2f %3.2f  %3.2f  0)  ///
	label("Dep. Variable Mean"  "Dep. Variable Median" "Dep. Variable SD" "Observations (N counties)" )) 	
	
		
	esttab M`var'SNF_popPCP M`var'Physician_popPCP M`var'dentoffice_popPCP M`var'homehealth_popPCP M`var'Hospital_popPCP  M`var'other_popPCP using "${tabledir}/Table2_margins_2021q2_`var'pop_PCP_combined.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)star) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ymedian ysd N,fmt(%3.2f %3.2f  %3.2f  0)  ///
	label("Dep. Variable Mean"  "Dep. Variable Median" "Dep. Variable SD" "Observations (N counties)" )) 	
	
		
	esttab M`var'SNF_popcases M`var'Physician_popcases M`var'dentoffice_popcases M`var'homehealth_popcases M`var'Hospital_popcases  M`var'other_popcases using "${tabledir}/Table2_margins_2021q2_`var'pop_PCP_combined.rtf",   ///
	append  modelwidth(8) ///
	keep(*) ///
	label onecell ///
	starlevels(* 0.05 ** 0.01 *** 0.001) ///
	cells(b(fmt(a2)) ci(fmt(a2) par("(" " to " ")")) p(fmt(3) par("["  "]")) )   ///
	stats(ymean ymedian ysd N,fmt(%3.2f %3.2f  %3.2f  0)  ///
	label("Dep. Variable Mean"  "Dep. Variable Median" "Dep. Variable SD" "Observations (N counties)" )) 	

	
	
	}
		
		
	grc1leg Bemp_SNF_popPCP_b Bemp_Physician_popPCP_b Bemp_dentoffice_popPCP_b Bemp_homehealth_popPCP_b Bemp_Hospital_popPCP_b Bemp_other_popPCP_b, cols(3) ///
imargin(0 0 0 0) xcommon legendfrom(Bemp_Physician_popPCP_b) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2021q2_Bemp_pop_PCP_combined.png",  replace width(4000)  


	grc1leg Bemp_SNF_popcases_b Bemp_Physician_popcases_b Bemp_dentoffice_popcases_b Bemp_homehealth_popcases_b Bemp_Hospital_popcases_b Bemp_other_popcases_b, cols(3) ///
imargin(0 0 0 0) xcommon legendfrom(Bemp_SNF_popcases_b) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_2021q2_Bemp_pop_cases_combined.png",  replace width(4000)  

	
	grc1leg Bemp_SNF_popcases  Bemp_SNF_popcases_b Bemp_SNF_popPCP Bemp_SNF_popPCP_b , cols(2) ///
imargin(0 4 0 0) xcommon legendfrom(Bemp_SNF_popcases) graphregion(color(white)) xsize(5) ysize(15) ///
			title("", color(black)   size(2.5)) 
	graph export "${tabledir}/Fig_margins_SNF_2020_2021.png",  replace width(4000)  


		
		
	foreach outcome in `IND' {
	sum Bemp_`outcome'_pop if includeBemp_`outcome'_pop==1,detail
	}

	
	clear all
	
	exit
