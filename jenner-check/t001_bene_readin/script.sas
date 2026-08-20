/*-------------------------------------------------------------------*/
/*  Adapted from: DESynPUF_BENE_READIN_20121211.sas                  */
/*  Source repo:  rho-tullis/code_samples                            */
/*                                                                    */
/*  Jenner compatibility bundle -- the macro DESYNPUF_BENE_READIN     */
/*  below is reproduced verbatim from the source file (the "SHOULD   */
/*  NOT BE MODIFIED" section). Only the path/libname assignments at  */
/*  the top were retargeted to a small synthetic sample CSV (written */
/*  to WORK by autoexec.sas, in the same layout as the CMS DE-SynPUF */
/*  download the original script reads), and only subsample 1 for a */
/*  single year is read in, so the bundle runs standalone.           */
/*-------------------------------------------------------------------*/

%global infilepath infilename2008 infilename2009 infilename2010
                   outdsname2008  outdsname2009 outdsname2010;

/* Retargeted to the sample CSV staged into WORK by autoexec.sas */
%let infilepath = %sysfunc(pathname(work));
%let infilename2008=bene_sample_;
%let infilename2009=bene_sample_;
%let infilename2010=bene_sample_;

libname desynpuf "%sysfunc(pathname(work))";

%let outdsname2008=DE1_0_2008_Bene_Sample_;
%let outdsname2009=DE1_0_2009_Bene_Sample_;
%let outdsname2010=DE1_0_2010_Bene_Sample_;

options validvarname=upcase
        compress=binary
        mprint
        ls=100 ps=60;

/*********************************************************************************/
/* Macro DESYNPUF_BENE_READIN reproduced verbatim from the source repo.          */
/*********************************************************************************/

%macro desynpuf_bene_readin(filenumber=,sortds=);

  %local startyear endyear y infilename outdsname;
  %let startyear=2008;
  %let endyear=2008;  /* bundle ships one sample year to keep the run small */

  %let sortds=%upcase(&sortds);

  %do y=&startyear %to &endyear;
    %let infilename=&&infilename&y;
    %let outdsname=&&outdsname&y;
    filename inbene "&infilepath./&infilename&filenumber..csv" ;

    data desynpuf.&outdsname&filenumber(label="&infilename.&filenumber");
      infile inbene dsd dlm=',' lrecl=500 firstobs=2 stopover;

      attrib DESYNPUF_ID     length=$16 format=$16.       label='DESYNPUF: Beneficiary Code'
             BENE_BIRTH_DT   length=4 format=YYMMDDN8. informat=yymmdd8.  label='DESYNPUF: Date of birth'
             BENE_DEATH_DT   length=4 format=YYMMDDN8. informat=yymmdd8.  label='DESYNPUF: Date of death'
             BENE_SEX_IDENT_CD  length=$1 format=$1.      label='DESYNPUF: Sex'
             BENE_RACE_CD    length=$1 format=$1.         label='DESYNPUF: Beneficiary Race Code'
             BENE_ESRD_IND   length=$1 format=$1.         label='DESYNPUF: End stage renal disease Indicator'
             SP_STATE_CODE      length=$2 format=$2.         label='DESYNPUF: State Code'
             BENE_COUNTY_CD  length=$3 format=$3.         label='DESYNPUF: County Code'
             BENE_HI_CVRAGE_TOT_MONS  length=3 format=2.  label='DESYNPUF: Total number of months of part A coverage for the beneficiary.'
             BENE_SMI_CVRAGE_TOT_MONS length=3 format=2.  label='DESYNPUF: Total number of months of part B coverage for the beneficiary.'
             BENE_HMO_CVRAGE_TOT_MONS length=3 format=2.  label='DESYNPUF: Total number of months of HMO coverage for the beneficiary.'
             PLAN_CVRG_MOS_NUM  length=$2 format=$2.      label='DESYNPUF: Total number of months of part D plan coverage for the beneficiary.'
             SP_ALZHDMTA     length=3 format=1.           label='DESYNPUF: Chronic Condition: Alzheimer or related disorders or senile'
             SP_CHF          length=3 format=1.           label='DESYNPUF: Chronic Condition: Heart Failure'
             SP_CHRNKIDN     length=3 format=1.           label='DESYNPUF: Chronic Condition: Chronic Kidney Disease'
             SP_CNCR         length=3 format=1.           label='DESYNPUF: Chronic Condition: Cancer'
             SP_COPD         length=3 format=1.           label='DESYNPUF: Chronic Condition: Chronic Obstructive Pulmonary Disease'
             SP_DEPRESSN     length=3 format=1.           label='DESYNPUF: Chronic Condition: Depression'
             SP_DIABETES     length=3 format=1.           label='DESYNPUF: Chronic Condition: Diabetes'
             SP_ISCHMCHT     length=3 format=1.           label='DESYNPUF: Chronic Condition: Ischemic Heart Disease'
             SP_OSTEOPRS     length=3 format=1.           label='DESYNPUF: Chronic Condition: Osteoporosis'
             SP_RA_OA        length=3 format=1.           label='DESYNPUF: Chronic Condition: RA/OA'
             SP_STRKETIA     length=3 format=1.           label='DESYNPUF: Chronic Condition: Stroke/transient Ischemic Attack'
             MEDREIMB_IP     length=8 format=10.2         label='DESYNPUF: Inpatient annual Medicare reimbursement amount'
             BENRES_IP       length=8 format=10.2         label='DESYNPUF: Inpatient annual beneficiary responsibility amount'
             PPPYMT_IP       length=8 format=10.2         label='DESYNPUF: Inpatient annual primary payer reimbursement amount'
             MEDREIMB_OP     length=8 format=10.2         label='DESYNPUF: Outpatient Institutional annual Medicare reimbursement amount'
             BENRES_OP       length=8 format=10.2         label='DESYNPUF: Outpatient Institutional annual beneficiary responsibility amount'
             PPPYMT_OP       length=8 format=10.2         label='DESYNPUF: Outpatient Institutional annual primary payer reimbursement amount'
             MEDREIMB_CAR    length=8 format=10.2         label='DESYNPUF: Carrier annual Medicare reimbursement amount'
             BENRES_CAR      length=8 format=10.2         label='DESYNPUF: Carrier annual beneficiary responsibility amount'
             PPPYMT_CAR      length=8 format=10.2         label='DESYNPUF: Carrier annual primary payer reimbursement amount'
          ;

      input DESYNPUF_ID
            BENE_BIRTH_DT
            BENE_DEATH_DT
            BENE_SEX_IDENT_CD
            BENE_RACE_CD
            BENE_ESRD_IND
            SP_STATE_CODE
            BENE_COUNTY_CD
            BENE_HI_CVRAGE_TOT_MONS
            BENE_SMI_CVRAGE_TOT_MONS
            BENE_HMO_CVRAGE_TOT_MONS
            PLAN_CVRG_MOS_NUM
            SP_ALZHDMTA
            SP_CHF
            SP_CHRNKIDN
            SP_CNCR
            SP_COPD
            SP_DEPRESSN
            SP_DIABETES
            SP_ISCHMCHT
            SP_OSTEOPRS
            SP_RA_OA
            SP_STRKETIA
            MEDREIMB_IP
            BENRES_IP
            PPPYMT_IP
            MEDREIMB_OP
            BENRES_OP
            PPPYMT_OP
            MEDREIMB_CAR
            BENRES_CAR
            PPPYMT_CAR;

    run;
    filename inbene clear;

    %if &sortds=Y or &sortds=YES %then %do;
      proc sort data=desynpuf.&outdsname&filenumber;
        by desynpuf_id;
      run;
    %end;

    title "Processing &infilename._&filenumber";
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
      table bene_birth_dt bene_death_dt / missing;
      format bene_birth_dt bene_death_dt year4.;
    run;

  %end;

%mend desynpuf_bene_readin;

%desynpuf_bene_readin(filenumber=1,sortds=no)

filename inbene clear;
libname desynpuf clear;

options validvarname=v7 nomprint ;
