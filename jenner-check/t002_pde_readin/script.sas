/*-------------------------------------------------------------------*/
/*  Adapted from: DESynPUF_PDE_READIN_20121211.sas                   */
/*  Source repo:  rho-tullis/code_samples                            */
/*                                                                    */
/*  Jenner compatibility bundle -- the macro DESYNPUF_PDE_READIN      */
/*  below is reproduced verbatim from the source file (the "SHOULD   */
/*  NOT BE MODIFIED" section). Only the path/libname assignments at  */
/*  the top were retargeted to a small synthetic sample CSV (written */
/*  to WORK by autoexec.sas, in the same layout as the CMS DE-SynPUF */
/*  Prescription Drug Events download the original script reads), so */
/*  the bundle runs standalone.                                      */
/*-------------------------------------------------------------------*/

%global infilepath infilename outdsname;

/* Retargeted to the sample CSV staged into WORK by autoexec.sas */
%let infilepath= %sysfunc(pathname(work));
%let infilename=pde_sample_;

libname desynpuf "%sysfunc(pathname(work))";

%let outdsname=DE1_0_2008_to_2010_PDE_Sample_;

options validvarname=upcase
        compress=binary
        mprint
        ls=100 ps=60;

/*********************************************************************************/
/* Macro DESYNPUF_PDE_READIN reproduced verbatim from the source repo.           */
/*********************************************************************************/

%macro desynpuf_pde_readin(filenumber=,sortds=);

  %let sortds=%upcase(&sortds);

  filename inpde "&infilepath./&infilename.&filenumber..csv" ;

  data desynpuf.&outdsname&filenumber(label="DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_&filenumber");
    infile inpde dsd dlm=',' lrecl=125 firstobs=2 stopover;

    attrib DESYNPUF_ID     length=$16 format=$16. label='DESYNPUF: Beneficiary Code'
           PDE_ID          length=$15 format=$15. label='DESYNPUF: CCW Part D Event Number'
           SRVC_DT         length=4   informat=yymmdd8. format=yymmddn8. label='DESYNPUF: RX Service Date'
           PROD_SRVC_ID    length=$19 format=$19. label='DESYNPUF: Product Service ID'
           QTY_DSPNSD_NUM  length=8   format=12.3 label='DESYNPUF: Quantity Dispensed'
           DAYS_SUPLY_NUM  length=3   format=3.   label='DESYNPUF: Days Supply'
           PTNT_PAY_AMT    length=8   format=10.2 label='DESYNPUF: Patient Pay Amount'
           TOT_RX_CST_AMT  length=8   format=10.2 label='DESYNPUF: Gross Drug Cost'
        ;

    input desynpuf_id
          pde_id
          srvc_dt
          prod_srvc_id
          qty_dspnsd_num
          days_suply_num
          ptnt_pay_amt
          tot_rx_cst_amt ;
  run;

  filename inpde clear;

  %if &sortds=Y or &sortds=YES %then %do;
    proc sort data=desynpuf.&outdsname&filenumber;
      by desynpuf_id;
    run;
  %end;

  title "Processing DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_&filenumber";
  proc contents data=desynpuf.&outdsname&filenumber varnum;
  run;
  proc print data=desynpuf.&outdsname&filenumber(obs=5);
    title2 'Subsample Listing - First 5 Rows';
  run;
  proc means data=desynpuf.&outdsname&filenumber;
    title2 'Simple Means';
  run;
  proc freq data=desynpuf.&outdsname&filenumber;
    title2 'Simple Frequencies';
    table srvc_dt / missing;
    format srvc_dt year4.;
  run;

%mend desynpuf_pde_readin;

%desynpuf_pde_readin(filenumber=1,sortds=no)

filename inpde clear;
libname desynpuf clear;

options validvarname=v7 nomprint ;
