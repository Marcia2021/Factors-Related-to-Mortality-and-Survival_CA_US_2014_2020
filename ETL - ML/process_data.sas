options mprint mlogic nocenter;

%let root=...;
%let pgm=process_data;

/*
proc printto new; run; 
proc printto print="&root.\&pgm._&sysdate..lst"
               log="&root.\&pgm._&sysdate..log"
new;
run;

ods html close;
ods _all_ close;
ods html body="&root.\&pgm._&sysdate..html" style=HTMLBlue;
*/

libname lib "&root.";

data Cal_county_geo;
    infile "&root.\Cal_county_geo.csv"
	delimiter = ","
	missover 
	dsd
	firstobs=2;
 
	informat County $20.;
	informat Description $20.;

	format County $20.;
	format Description $20.;

	input
        County $
	Description $;
run;

%macro process(dt=,fl=,cntvar=,catvar=);

data &dt.;
    infile "&root.\&dt..csv"
	delimiter = ","
	missover 
	dsd
	firstobs=2;
 
	informat Year_of_Death best12.;
	informat County_of_Residence $20.;
	informat Age $100.;
	informat &catvar. $100.;
	informat &cntvar. best12.;

	format Year_of_Death best12.;
	format County_of_Residence $20.;
	format Age $100.;
	format &catvar. $100.;
	format &cntvar. best12.;

	input
	Year_of_Death 
        County_of_Residence $
	Age $
	&catvar. $
	&cntvar.;
run;

proc freq data=&dt.;
   tables &catvar. / list missing;
run;

proc sql verbose;
   create table &fl._recode as
   select  *
          ,case when age="Less than 1 year" then 1
		        when age="1 - 4 years" then 2
		        when age="5 - 9 years" then 3
		        when age="10 - 14 years" then 4
		        when age="15 - 19 years" then 5
		        when age="20 - 24 years" then 6
		        when age="25 - 29 years" then 7
		        when age="30 - 34 years" then 8
		        when age="35 - 39 years" then 9
		        when age="40 - 44 years" then 10
		        when age="45 - 49 years" then 11
		        when age="50 - 54 years" then 12
		        when age="55 - 59 years" then 13
		        when age="60 - 64 years" then 14
		        when age="65 - 69 years" then 15
		        when age="70 - 74 years" then 16
		        when age="75 - 79 years" then 17
		        when age="80 - 84 years" then 18
		        when age="85 - 89 years" then 19
		        when age="90 - 94 years" then 20
		        when age="95 - 99 years" then 21
		        when age="100 years and over" then 22 end
		   as age_cat
     
           %if &fl.=education %then %do;
		  ,case when &catvar.="Bachelor's Degree" then 1
		        when &catvar.="Graduate Degree" then 2
				when &catvar.="High School Graduate or GED Completed" then 3
				when &catvar.="Less than High School" then 4
				when &catvar.="Some College Credit, No 4-Year Degree" then 5
				when &catvar.="Unknown" then 6 end
		   as &fl._cat
		   %end;

           %if &fl.=race_ethnicity %then %do;
		  ,case when &catvar.="Asian" then 1
                when &catvar.="Black/African-American" then 2
                when &catvar.="Hispanic" then 3
                when &catvar.="Multi-Race" then 4
                when &catvar.="Native American/Alaskan Native" then 5
                when &catvar.="Other/Unknown" then 6
                when &catvar.="Pacific Islander/Native Hawaiian" then 7
                when &catvar.="White" then 8 end
		   as &fl._cat
		   %end;

           %if &fl.=immigration %then %do;
		  ,case when &catvar.="Foreign Born" then 1
                when &catvar.="United States" then 2
                when &catvar.="Unknown" then 3 end
		   as &fl._cat
		   %end;

           %if &fl.=marital %then %do;
		  ,case when &catvar.="Divorced" then 1
                when &catvar.="Married (including SRDP)" then 2
                when &catvar.="Never Married" then 3
                when &catvar.="Unknown" then 4
                when &catvar.="Widowed" then 5 end
		   as &fl._cat
		   %end;

           %if &fl.=sex %then %do;
          ,case when &catvar.="Female" then 1
                when &catvar.="Male" then 2 end
		   as &fl._cat
		   %end;
		   
           %if &fl.=veteran %then %do;
          ,case when &catvar.="No" then 1
                when &catvar.="Unknown" then 2
                when &catvar.="Yes" then 3 end
		   as &fl._cat
		   %end;

   from &dt.
   where Year_of_Death<=2020;
run;

proc freq data=&fl._recode;
   tables &catvar. * &fl._cat / list missing;
run;

proc sql verbose;
   select max(&fl._cat) into :maxn separated by " "
   from &fl._recode;
quit;

%do i=1 %to &maxn. %by 1;
data &fl._sub_&i.(drop=&catvar. 
                  rename=(&cntvar.=&fl._cat_&i._count));
   set &fl._recode;
   if &fl._cat=&i. then output;
run;

proc sort data=&fl._sub_&i.;
   by Year_of_Death County_of_Residence Age;
run;
%end;

data &fl._reshape(drop=&fl._cat);
   merge %do i=1 %to &maxn. %by 1;
         &fl._sub_&i.
		 %end;;
   by Year_of_Death County_of_Residence Age;
run;

proc datasets library=work nolist;
   delete &fl._sub_:;
run;

/* Add the GEO to each table */
proc sql verbose;
   create table &fl._add_geo as
   select  a.*
          ,b.Description
   from &fl._recode a
        left join
        Cal_county_geo b
   on a.County_of_Residence=b.County
   order by Year_of_Death,County_of_Residence,age_cat;
quit;

%mend process;

%process(dt=Cal_Education_final, fl=education,      cntvar=Total_Deaths_Education,  catvar=Education_level);
%process(dt=Cal_ethnicity_final, fl=race_ethnicity, cntvar=Total_Deaths_ethnicity,  catvar=Race_Ethnicity);
%process(dt=Cal_immigrants_final,fl=immigration,    cntvar=Total_Deaths_immigration,catvar=US_or_Foreign_Born);
%process(dt=Cal_marital_final,   fl=marital,        cntvar=Total_Deaths_marital,    catvar=Marital_Status);
%process(dt=Cal_sex_final,       fl=sex,            cntvar=Total_Deaths_sex,        catvar=Sex);
%process(dt=Cal_veteran_final,   fl=veteran,        cntvar=Total_Deaths_veteran,    catvar=Veteran_Status);


/*Merge all tables together*/
data final_table;
   retain Year_of_Death County_of_Residence Age age_cat;
   merge education_reshape
         race_ethnicity_reshape
		 immigration_reshape
		 marital_reshape
		 sex_reshape
		 veteran_reshape;
   by Year_of_Death County_of_Residence Age;

   rename education_cat_1_count = bachelors_degree
          education_cat_2_count = graduate_degree
		  education_cat_3_count = high_school_or_GED
		  education_cat_4_count = less_than_high_school
		  education_cat_5_count = some_college_credit
		  education_cat_6_count = edu_unknown

		  race_ethnicity_cat_1_count = asian
		  race_ethnicity_cat_2_count = black_african_american
		  race_ethnicity_cat_3_count = hispanic
		  race_ethnicity_cat_4_count = multi_race
		  race_ethnicity_cat_5_count = native_american
		  race_ethnicity_cat_6_count = other_unknown
		  race_ethnicity_cat_7_count = pi_native_hawaiian
		  race_ethnicity_cat_8_count = white

		  immigration_cat_1_count = foreign_born
		  immigration_cat_2_count = united_states
		  immigration_cat_3_count = immigration_unknown

		  marital_cat_1_count = divorced
		  marital_cat_2_count = married
		  marital_cat_3_count = never_married
		  marital_cat_4_count = marital_unknown
		  marital_cat_5_count = widowed

		  sex_cat_1_count = female
		  sex_cat_2_count = male

		  veteran_cat_1_count = veteran_no
		  veteran_cat_2_count = veteran_unknown
		  veteran_cat_3_count = veteran_yes;

run; 

proc sql verbose;
   create table final_table_add_geo as
   select  *
          ,case when Description="urban" then 1 else 0 end 
		   as urban
          ,case when Description="rural" then 1 else 0 end 
		   as rural
          ,case when Description="suburban" then 1 else 0 end 
		   as suburban

   from (select  a.*
                ,b.Description
         from final_table a
              left join
              Cal_county_geo b
         on a.County_of_Residence=b.County);
quit;

proc sort data=final_table_add_geo;
   by Year_of_Death County_of_Residence age_cat;
run;

/* aggregate to county and age category level */
proc sql verbose;
   create table agg_final_table as
   select  County_of_Residence 
          ,Age
		  ,age_cat
		  ,sum(bachelors_degree) as bachelors_degree
		  ,sum(graduate_degree) as graduate_degree
		  ,sum(high_school_or_GED) as high_school_or_GED
		  ,sum(less_than_high_school) as less_than_high_school
		  ,sum(some_college_credit) as some_college_credit
		  ,sum(edu_unknown) as edu_unknown
		  ,sum(asian) as asian
		  ,sum(black_african_american) as black_african_american
		  ,sum(hispanic) as hispanic
		  ,sum(multi_race) as multi_race
		  ,sum(native_american) as native_american
		  ,sum(other_unknown) as other_unknown
		  ,sum(pi_native_hawaiian) as pi_native_hawaiian
		  ,sum(white) as white
		  ,sum(foreign_born) as foreign_born
		  ,sum(united_states) as united_states
		  ,sum(immigration_unknown) as immigration_unknown
		  ,sum(divorced) as divorced
		  ,sum(married) as married 
		  ,sum(never_married) as never_married
		  ,sum(marital_unknown) as marital_unknown
		  ,sum(widowed) as widowed
		  ,sum(female) as female
		  ,sum(male) as male
		  ,sum(veteran_no) as veteran_no
		  ,sum(veteran_unknown) as veteran_unknown
		  ,sum(veteran_yes) as veteran_yes
   from final_table
   where Year_of_Death<=2019
   group by County_of_Residence,Age,age_cat
   order by County_of_Residence,Age,age_cat;
quit;

proc sql verbose;
   create table agg_final_table_geo as
   select  a.*
          ,b.Description
		  ,case when b.Description="urban" then 1 else 0 end 
		   as urban
          ,case when b.Description="rural" then 1 else 0 end 
		   as rural
          ,case when b.Description="suburban" then 1 else 0 end 
		   as suburban
   from agg_final_table a
        left join
        Cal_county_geo b
   on a.County_of_Residence=b.County
   order by County_of_Residence,age_cat;
quit;

proc sort data=agg_final_table_geo;
   by County_of_Residence age_cat;
run;

ods html close;
ods _all_ close;

options device=ACTXIMG;
ods csv file="...\Final_clean_table.csv" style=analysis
options(AutoFilter='yes' embedded_titles='yes' frozen_headers="Yes" frozen_rowheaders="1");

ods excel options(sheet_name="Final Table");

proc print data=final_table_add_geo noobs;
run;

ods excel close;

options device=ACTXIMG;
ods csv file="...\Agg_Final_clean_table.csv" style=analysis
options(AutoFilter='yes' embedded_titles='yes' frozen_headers="Yes" frozen_rowheaders="1");

ods excel options(sheet_name="Final Table");

proc print data=agg_final_table_geo noobs;
run;

ods excel close;

%macro exportdt(fl=);
options device=ACTXIMG;
ods csv file="...\&fl._add_geo1.csv" style=analysis
options(AutoFilter='yes' embedded_titles='yes' frozen_headers="Yes" frozen_rowheaders="1");

ods excel options(sheet_name="&fl.");

proc print data=&fl._add_geo noobs;
run;

ods excel close;
%mend exportdt;

%exportdt(fl=education);
%exportdt(fl=race_ethnicity);
%exportdt(fl=immigration);
%exportdt(fl=marital);
%exportdt(fl=sex);
%exportdt(fl=veteran);

proc printto;
run;


