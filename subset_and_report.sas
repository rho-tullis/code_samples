*******************************************************************************
* subset_and_report.sas   Subsets plan beneficiaries to those
*                         having 12 member months, 
*                         joins member data w/pharmacy claims,
*                         prints reports to listing.
*
*     NOTE:  uses synthetic data from CMS from location below:
*            https://www.cms.gov/data-research/statistics-trends-and-reports
*                   /medicare-claims-synthetic-public-use-files
*                   /cms-2008-2010-data-entrepreneurs-synthetic-public-use-file-de-synpuf  
*
* --Rhonda Tullis, 6/26/2025                        
*******************************************************************************;
options symbolgen mlogic;

libname source "/home/u63541071/emac293/rxante/created/" access=readonly;

%let pde_file = source.de1_0_2008_to_2010_pde_sample_1;

* Reporting macro called below;
%macro run_means(class_name);
    title2 "Mean gross drug costs by &class_name flag";
        proc means data=work.pde;
            class &class_name;
            var TOT_RX_CST_AMT;
            run;
            
%mend run_means;            


* START MACRO THAT RUNS PER YEAR (YYYY);
%macro run_per_year(year);

* Subset beneficiary file to benes with 12 months coverage;
    data work.benes;
        set source.de1_0_&year._bene_sample_1(where=(PLAN_CVRG_MOS_NUM="12"));
        run;
    
* Look at source beneficiary data;
    title1 "&year -- benes file where 12 months coverage";
    proc contents data=work.benes;
    run;
    
    title2 "Before changing chronic conditions to 0 where 2";    
    proc means data=work.benes(drop=sp_state_code);
        var sp_:;
    run;
    
* Set chronic condition flags to 0 where input value is 2
* Source documentation shows that negative chronic condition = 2;
    data work.benes(drop=i);
        set work.benes(rename=(sp_state_code=state_code));
            array sps(*) sp_:;
            do i = 1 to dim(sps);
                if sps{i} = 2 then sps{i} = 0;
            end;
            run;
            
    title2 "After changing chronic conditions 2s to 0s";
    proc means data=work.benes;
        var sp_:;
    run;
        
* Get PDE (pharmacy claims) data for select beneficiaries;
    data work.pde;
        merge work.benes(in=in_members)
              &pde_file(in=in_pde);
              by DESYNPUF_ID;
              if in_members and in_pde and year(SRVC_DT) = &year;
              run;
        
      
    title1 "&year -- Part D events for included benes";
    proc contents data=work.pde;
    run;
    
    title2 "Overall numeric analysis";
    proc means data=work.pde;
    run;
    
    title2 "Service Dates";
    proc freq data=work.pde;
         tables SRVC_DT / missing;
         format SRVC_DT monyy.;
         run;
    
* Get list of chronic condition variables;
    proc contents data=work.pde noprint out=work.chronic_condition_vars(where=(substr(name,1,3)="SP_")
                                                     keep=name);
                                                     run;
    data _null_;
      set work.chronic_condition_vars;
          call execute('%nrstr(%run_means('||name||'))');
          run;

    
%mend run_per_year;
%run_per_year(year=2008);
%run_per_year(year=2009);
%run_per_year(year=2010);