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
