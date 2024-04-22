/*
Note: 

The do files involved are cited from by Yaxi and by Siyu

*/

clear all
set matsize 3956, permanent
set more off, permanent
set maxvar 32767
capture log close
sca drop _all
matrix drop _all
macro drop _all

******************************
*** Define main root paths ***
******************************
//NOTE FOR WINDOWS USERS : use "\" instead of "/" in your paths
global root "/Users/x152/Library/CloudStorage/Box-Box/项目/Frailty Traj/Data Analyses/" 					// adjust 

* Define path for data sources
global SOURCE "${root}raw"

* Define path for general output data: 
global OUT "${root}output"

* Define path for intermediate data
global INT "${root}intermediate"

* Define path for result
global RSL "${root}result"


* Define path for do-files
global DO "${root}do"


