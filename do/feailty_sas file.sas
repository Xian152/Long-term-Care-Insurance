/*****************************************************************************************************************
 
sas file name: feailty_sas file.sas
file location: C:\Users\ding\Desktop\frailty
__________________________________________________________________________________________________________________
 
purpose: dual_traj of lifestyle and tyg with cvd
author: Xiong Ding
creation date: 5 November,2023
copyright by Xiong Ding.


__________________________________________________________________________________________________________________
 
changes:
 
date: 
modifyer name: 
description: 
 
*****************************************************************************************************************/

/*---------------------------------------------------------------------------------------------------------------
|                                    the location of the sas output file                                         |
-----------------------------------------------------------------------------------------------------------------*/

%let job= C:\Users\ding\Desktop;/*the location of the sas outfile*/
data time;
  format t $8.;
  t=compress(year(today())*10000+month(today())*100+day(today()));
  call symput('t',t);
run;

data _null_;
  new0=dcreate("frailty","&job.");
  new=dcreate("results","&job.\frailty");
  new1=dcreate("&t.","&job.\frailty\results");
  new11=dcreate("out_results","&job.\frailty\results\&t.");
  new11=dcreate("out_pdf","&job.\frailty\results\&t.");
  new11=dcreate("out_log","&job.\frailty\results\&t.");
  new11=dcreate("out_log_warning_error","&job.\frailty\results\&t.");
  new11=dcreate("out_data","&job.\frailty\results\&t.");
run;
%let out_results=&job.\frailty\results\&t.\out_results;
%let out_pdf=&job.\frailty\results\&t.\out_pdf;
%let out_log=&job.\frailty\results\&t.\out_log;
%let out_log_warning_error=&job.\frailty\results\&t.\out_log_warning_error;
%let out_data=&job.\frailty\results\&t.\out_data;

proc import datafile="&job.\frailty\analyses_frailty.csv" out=a replace;run;


proc means data=a min max; 
  var frailID1998 frailID2000 frailID2002 frailID2005
      frailID2008 frailID2011 frailID2014 frailID2018;
run;

/*==============================================================================================================
| Aim:   lifestyle trajectory                                                                                |
===============================================================================================================*/
%macro gen_traj(inputdata=,var1=,  time1=,aic=,var1min=, var1max=,order1=,multgroups=,
                 outplot1=,outstat1=,figtitle1=, ylab1=,specific_grp=,number_grp=,avge_prob=); 
  proc traj data=&inputdata out=of outest=&aic outplot=&outplot1 outstat=&outstat1;
    id pe_id;
    var  &var1;indep &time1;  model cnorm;  min &var1min;    max &var1max;      order &order1;
    multgroups &multgroups;
  run;
  %trajplotnew(plotfile=&outplot1,statfile=&outstat1,title1="&figtitle1",ylab="&ylab1",xlab="follow-up time (years)");

  data of1;set of;
    array g(&multgroups) (&number_grp);
    array prb_group(&multgroups) &specific_grp;

    do i=1 to &multgroups;
      if group=g[i] then prb=prb_group[i];
    end;
  run;
  proc sort data=of1;by group;run;
  proc means data=of1 mean n max min; var prb; by group;
    ods output summary=&avge_prob;run;
/*  proc print data=&avge_prob;run;*/
%mend;

%macro gen_traj_frailty(order1=,multgroups=,grpprb=,number_grp=,aic=,avge_prob=);
%gen_traj(inputdata=a,
			var1=frailID1998 frailID2000 frailID2002 frailID2005 frailID2008 frailID2011 frailID2014 frailID2018, 
			time1=t1 t2 t3 t4 t5 t6 t7 t8,
			aic=&aic,
			var1min=/*change*/, 
			var1max=/*change*/, 
			order1=&order1,
			multgroups=&multgroups,
			outplot1=op,
			outstat1=os,
			figtitle1=mon trajectory, 
			ylab1=mon,
			specific_grp=&grpprb,
			number_grp=&number_grp,
			avge_prob=&avge_prob); 
%mend;


/*===group 2===*/
dm 'log;clear;  output;clear;';
ods listing file="&out_results\grp2_frailty.txt";
%let as=1 2 3 4;
%let orders1=2 2 1 1;
%let orders2=2 1 2 1;

%macro gen_traj_2;
  %do i=1 %to 4;
    %let order1=%scan(&orders1,&i);
    %let order2=%scan(&orders2,&i);
	%let a=%scan(&as,&i);
    %gen_traj_frailty(order1=&order1 &order2,multgroups=2,grpprb=grp1prb grp2prb,number_grp=1 2,
                      aic=aic&a,avge_prob=avg_prob&a);
	data aic&a;set aic&a;format label $32.;label="aic&a";run;
	data avg_prob&a;set avg_prob&a;format label $32.;label="avg_prob&a";run;
  %end;
  data aic;set aic1-aic4;run;
  data avg_prob;set avg_prob1-avg_prob4;run;
  proc export data=aic outfile="&out_results\grp2_lifstyle_aic.csv" replace;run;quit;
  proc export data=avg_prob outfile="&out_results\grp2_lifstyle_avg_prob.csv" replace;run;quit;
%mend;
%gen_traj_2;
proc delete data=aic1-aic4;run;
proc delete data=avg_prob1-avg_prob4;run;
ods listing close;


/*===group 3===*/
dm 'log;clear;  output;clear;';
ods listing file="&out_results\grp3_frailty.txt";
%let as=1	2	3	4	5	6	7	8;
%let orders1=2	2	2	2	1	1	1	1;
%let orders2=2	2	1	1	2	2	1	1;
%let orders3=2	1	2	1	2	1	2	1;

%macro gen_traj_3;
  %do i=1 %to 8;
    %let order1=%scan(&orders1,&i);
    %let order2=%scan(&orders2,&i);
    %let order3=%scan(&orders3,&i);
	%let a=%scan(&as,&i);
    %gen_traj_frailty(order1=&order1 &order2 &order3,multgroups=3,grpprb=grp1prb grp2prb grp3prb,number_grp=1 2 3,
                      aic=aic&a,avge_prob=avg_prob&a);
	data aic&a;set aic&a;format label $32.;label="aic&a";run;
	data avg_prob&a;set avg_prob&a;format label $32.;label="avg_prob&a";run;
  %end;
  data aic;set aic1-aic8;run;
  data avg_prob;set avg_prob1-avg_prob8;run;
  proc export data=aic outfile="&out_results\grp3_lifstyle_aic.csv" replace;run;quit;
  proc export data=avg_prob outfile="&out_results\grp3_lifstyle_avg_prob.csv" replace;run;quit;
%mend;
%gen_traj_3;
proc delete data=aic1-aic8;run;
proc delete data=avg_prob1-avg_prob8;run;
ods listing close;


/*===group 4===*/
dm 'log;clear;  output;clear;';
ods listing file="&out_results\grp4_frailty.txt";
%let as=1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16;
%let orders1=2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1;
%let orders2=2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1;
%let orders3=2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1;
%let orders4=2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1;

%macro gen_traj_4;
  %do i=1 %to 16;
    %let order1=%scan(&orders1,&i);
    %let order2=%scan(&orders2,&i);
    %let order3=%scan(&orders3,&i);
	%let order4=%scan(&orders4,&i);
	%let a=%scan(&as,&i);
    %gen_traj_frailty(order1=&order1 &order2 &order3 &order4,multgroups=4,grpprb=grp1prb grp2prb grp3prb grp4prb,number_grp=1 2 3 4,
                      aic=aic&a,avge_prob=avg_prob&a);
	data aic&a;set aic&a;format label $32.;label="aic&a";run;
	data avg_prob&a;set avg_prob&a;format label $32.;label="avg_prob&a";run;
  %end;
  data aic;set aic1-aic16;run;
  data avg_prob;set avg_prob1-avg_prob16;run;
  proc export data=aic outfile="&out_results\grp4_lifstyle_aic.csv" replace;run;quit;
  proc export data=avg_prob outfile="&out_results\grp4_lifstyle_avg_prob.csv" replace;run;quit;
%mend;
%gen_traj_4;
proc delete data=aic1-aic16;run;
proc delete data=avg_prob1-avg_prob16;run;
ods listing close;


/*===group 5===*/
dm 'log;clear;  output;clear;';
ods listing file="&out_results\grp5_frailty.txt";
%let as=1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32;
%let orders1=2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
%let orders2=2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1;
%let orders3=2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1;
%let orders4=2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1;
%let orders5=2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1;

%macro gen_traj_5;
  %do i=1 %to 32;
    %let order1=%scan(&orders1,&i);
    %let order2=%scan(&orders2,&i);
    %let order3=%scan(&orders3,&i);
	%let order4=%scan(&orders4,&i);
	%let order5=%scan(&orders5,&i);
	%let a=%scan(&as,&i);
    %gen_traj_frailty(order1=&order1 &order2 &order3 &order4 &order5,multgroups=5,grpprb=grp1prb grp2prb grp3prb grp4prb grp5prb,number_grp=1 2 3 4 5,
                      aic=aic&a,avge_prob=avg_prob&a);
	data aic&a;set aic&a;format label $32.;label="aic&a";run;
	data avg_prob&a;set avg_prob&a;format label $32.;label="avg_prob&a";run;
  %end;
  data aic;set aic1-aic32;run;
  data avg_prob;set avg_prob1-avg_prob32;run;
  proc export data=aic outfile="&out_results\grp5_lifstyle_aic.csv" replace;run;quit;
  proc export data=avg_prob outfile="&out_results\grp5_lifstyle_avg_prob.csv" replace;run;quit;
%mend;
%gen_traj_5;
proc delete data=aic1-aic32;run;
proc delete data=avg_prob1-avg_prob32;run;
ods listing close;


/*===group 6===*/
dm 'log;clear;  output;clear;';
ods listing file="&out_results\grp6_frailty.txt";
%let as=1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	43	44	45	46	47	48	49	50	51	52	53	54	55	56	57	58	59	60	61	62	63	64;
%let orders1=2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
%let orders2=2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
%let orders3=2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1;
%let orders4=2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1;
%let orders5=2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1;
%let orders6=2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1;

%macro gen_traj_6;
  %do i=1 %to 64;
    %let order1=%scan(&orders1,&i);
    %let order2=%scan(&orders2,&i);
    %let order3=%scan(&orders3,&i);
	%let order4=%scan(&orders4,&i);
	%let order5=%scan(&orders5,&i);
	%let order6=%scan(&orders6,&i);
	%let a=%scan(&as,&i);
    %gen_traj_frailty(order1=&order1 &order2 &order3 &order4 &order5 &order6,multgroups=6,grpprb=grp1prb grp2prb grp3prb grp4prb grp5prb grp6prb,number_grp=1 2 3 4 5 6,
                      aic=aic&a,avge_prob=avg_prob&a);
	data aic&a;set aic&a;format label $32.;label="aic&a";run;
	data avg_prob&a;set avg_prob&a;format label $32.;label="avg_prob&a";run;
  %end;
  data aic;set aic1-aic64;run;
  data avg_prob;set avg_prob1-avg_prob64;run;
  proc export data=aic outfile="&out_results\grp6_lifstyle_aic.csv" replace;run;quit;
  proc export data=avg_prob outfile="&out_results\grp6_lifstyle_avg_prob.csv" replace;run;quit;
%mend;
%gen_traj_6;
proc delete data=aic1-aic64;run;
proc delete data=avg_prob1-avg_prob64;run;
ods listing close;


/*===group 7===*/
dm 'log;clear;  output;clear;';
ods listing file="&out_results\grp7_frailty.txt";
%let as=1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	43	44	45	46	47	48	49	50	51	52	53	54	55	56	57	58	59	60	61	62	63	64	65	66	67	68	69	70	71	72	73	74	75	76	77	78	79	80	81	82	83	84	85	86	87	88	89	90	91	92	93	94	95	96	97	98	99	100	101	102	103	104	105	106	107	108	109	110	111	112	113	114	115	116	117	118	119	120	121	122	123	124	125	126	127	128;
%let orders1=2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
%let orders2=2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
%let orders3=2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1;
%let orders4=2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	1	1	1	1	1	1	1	1;
%let orders5=2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1	2	2	2	2	1	1	1	1;
%let orders6=2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1	2	2	1	1;
%let orders7=2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1	2	1;

%macro gen_traj_7;
  %do i=1 %to 128;
    %let order1=%scan(&orders1,&i);
    %let order2=%scan(&orders2,&i);
    %let order3=%scan(&orders3,&i);
	%let order4=%scan(&orders4,&i);
	%let order5=%scan(&orders5,&i);
	%let order6=%scan(&orders6,&i);
	%let order7=%scan(&orders7,&i);
	%let a=%scan(&as,&i);
    %gen_traj_frailty(order1=&order1 &order2 &order3 &order4 &order5 &order6 &order7,multgroups=7,grpprb=grp1prb grp2prb grp3prb grp4prb grp5prb grp6prb grp7prb,number_grp=1 2 3 4 5 6 7,
                      aic=aic&a,avge_prob=avg_prob&a);
	data aic&a;set aic&a;format label $32.;label="aic&a";run;
	data avg_prob&a;set avg_prob&a;format label $32.;label="avg_prob&a";run;
  %end;
  data aic;set aic1-aic128;run;
  data avg_prob;set avg_prob1-avg_prob128;run;
  proc export data=aic outfile="&out_results\grp7_lifstyle_aic.csv" replace;run;quit;
  proc export data=avg_prob outfile="&out_results\grp7_lifstyle_avg_prob.csv" replace;run;quit;
%mend;
%gen_traj_7;
proc delete data=aic1-aic128;run;
proc delete data=avg_prob1-avg_prob128;run;
ods listing close;
