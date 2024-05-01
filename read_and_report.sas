***********************************************************************
* sample_file_analysis.sas      Read, make reports and graphs for
*                               sample file.
*
* by Rhonda Tullis
* 5/01/2024
* for Point32Health
***********************************************************************

* PARAMETERS;
%let input_file = "/home/u63541071/point32health/sample3.xlsx";
%let output_file = cost_data;


* READ INPUT FILE;
proc import datafile=&input_file dbms=xlsx out=work.&output_file replace;
run;


* REPORTS;
title1 "&input_file";
title2 "NUMERIC ANALYSIS -- ALL";
proc means data=work.&output_file;
run;

title2 "COST -- PRE AND POST PERIOD BY INTERVENTION STATUS";
proc means data=work.&output_file(keep=intervention_status 
                                       total_cost_post
                                       total_cost_12m_pre);
    class intervention_status;
run;

title2 "FREQUENCIES OF CHARACTER VARIABLES";
proc freq data=work.&output_file;
    tables _character_;
run;


* REPORTS FOR BUSINESS STAKEHOLDER; 
* 1) Compare Gender groups on cost(pre and post), 
     chronic conditions and 5 disease variables 
     of your choice;
%macro(compare_group, disease_vars);
title1 "Cost (Pre and Post), Chronic Conditions";     
title2 "&compare_group and &disease_vars";

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.COST_DATA;
	hbar &compare_group / group= groupdisplay=stack;
	xaxis grid;
run;
%macro dontrun;
ods graphics / reset;
/* Compute axis ranges */
proc means data=WORK.COST_DATA noprint;
	class gender2 prostate_ind / order=data;
	var total_cost_12m_pre total_cost_post;
	output out=_BarLine_(where=(_type_ > 2)) mean(total_cost_12m_pre 
		total_cost_post)=resp1 resp2;
run;

/* Compute response min and max values (include 0 in computations) */
data _null_;
	retain respmin 0 respmax 0;
	retain respmin1 0 respmax1 0 respmin2 0 respmax2 0;
	set _BarLine_ end=last;
	respmin1=min(respmin1, resp1);
	respmin2=min(respmin2, resp2);
	respmax1=max(respmax1, resp1);
	respmax2=max(respmax2, resp2);

	if last then
		do;
			call symputx ("respmin1", respmin1);
			call symputx ("respmax1", respmax1);
			call symputx ("respmin2", respmin2);
			call symputx ("respmax2", respmax2);
			call symputx ("respmin", min(respmin1, respmin2));
			call symputx ("respmax", max(respmax1, respmax2));
		end;
run;

/* Define a macro for offset */
%macro offset ();
	%if %sysevalf(&respmin eq 0) %then
		%do;
			offsetmin=0 %end;

	%if %sysevalf(&respmax eq 0) %then
		%do;
			offsetmax=0 %end;
%mend offset;

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.COST_DATA nocycleattrs;
	vbar gender2 / response=total_cost_12m_pre group=prostate_ind 
		groupdisplay=cluster stat=mean;
	vline gender2 / response=total_cost_post group=prostate_ind stat=mean y2axis;
	yaxis grid min=&respmin1 max=&respmax1 %offset();
	y2axis min=&respmin2 max=&respmax2 %offset();
	keylegend / location=outside;
run;

ods graphics / reset;

proc datasets library=WORK noprint;
	delete _BarLine_;
	run;
%mend dontrun;
/*Compare age groups on cost(pre and post), chronic conditions and 5 disease variables of your choice
Compare the intervention and control groups on cost(pre and post), chronic conditions and 5 disease variables of your choice
*/
