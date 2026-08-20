/* cap input rows for the captured run */
options obs=100;

/* subset_and_report.sas reads source.de1_0_&year._bene_sample_1 and
   source.de1_0_2008_to_2010_pde_sample_1 from a fixed local libname
   (the CMS DE-SynPUF download). Here "source" is retargeted to WORK,
   and small synthetic bene/PDE datasets -- matching the field layout
   documented in this repo's DESynPUF_BENE_READIN_20121211.sas and
   DESynPUF_PDE_READIN_20121211.sas -- are built inline to stand in
   for that download. Only year 2008 is populated; the script's
   per-year loop for 2009/2010 finds no matching source data and
   simply produces empty subsets, exactly as it would against a real
   DE-SynPUF extract restricted to one year. */
libname source "%sysfunc(pathname(work))";

data source.de1_0_2008_bene_sample_1;
  length DESYNPUF_ID $16 PLAN_CVRG_MOS_NUM $2 SP_STATE_CODE $2;
  input DESYNPUF_ID $ PLAN_CVRG_MOS_NUM $ SP_STATE_CODE $
        SP_ALZHDMTA SP_CHF SP_CHRNKIDN SP_CNCR SP_COPD
        SP_DEPRESSN SP_DIABETES SP_ISCHMCHT SP_OSTEOPRS SP_RA_OA SP_STRKETIA;
  datalines;
00013D2EFD8E45D1 12 39 1 1 2 2 1 2 1 1 2 2
00016F745862898F 12 39 2 2 1 2 2 2 1 1 1 1
00016F745862899A 12 26 2 1 2 2 2 2 2 1 2 1
0001FDD721E223DC 12 45 2 2 2 2 2 1 2 2 2 2
00021CA6FF03E670 06 39 1 1 1 1 1 1 1 1 1 1
00024AC54CFC6A0B 12 05 2 2 2 2 2 2 2 2 2 2
00042C4642781EBA 12 39 2 1 2 1 2 2 1 1 2 1
00042E4F2D3E9970 10 26 2 2 2 2 2 2 2 2 1 1
0004FCE3D34E9346 12 39 2 2 2 2 2 2 2 2 2 2
000542DAF1BF9A1E 04 05 1 2 1 1 1 2 1 1 1 1
;
run;

data source.de1_0_2008_to_2010_pde_sample_1;
  length DESYNPUF_ID $16;
  format SRVC_DT yymmdd10.;
  input DESYNPUF_ID $ SRVC_DT :yymmdd8. TOT_RX_CST_AMT;
  datalines;
00013D2EFD8E45D1 20080115 42.50
00013D2EFD8E45D1 20080302 42.50
00016F745862898F 20080422 180.00
00016F745862899A 20080110 28.00
0001FDD721E223DC 20080619 410.00
00042C4642781EBA 20080825 150.00
00042E4F2D3E9970 20080227 32.00
0004FCE3D34E9346 20080918 60.00
000542DAF1BF9A1E 20080131 140.00
000542DAF1BF9A1E 20081015 140.00
;
run;
