CREATE TABLE education(
	Year_of_Death INT NOT NULL,  
  	County_of_Residence VARCHAR, 
  	Age VARCHAR,
  	Education_Level VARCHAR,
  	Total_Deaths_Education int
);
CREATE TABLE ethnicity(
	Year_of_Death INT NOT NULL,  
  	County_of_Residence VARCHAR, 
  	Age VARCHAR,
  	Race_Ethnicity VARCHAR,
  	Total_Deaths_ethnicity int
);
CREATE TABLE immigration(
	Year_of_Death INT NOT NULL,  
  	County_of_Residence VARCHAR, 
  	Age VARCHAR,
  	US_or_Foreign_Born VARCHAR,
  	Total_Deaths_immigration int
);

CREATE TABLE marital(
	Year_of_Death INT NOT NULL,  
  	County_of_Residence VARCHAR, 
  	Age VARCHAR,
  	Marital_Status VARCHAR,
  	Total_Deaths_marital int
);

CREATE TABLE sex(
	Year_of_Death INT NOT NULL,  
  	County_of_Residence VARCHAR, 
  	Age VARCHAR,
  	Sex VARCHAR,
  	Total_Deaths_sex int
);

CREATE TABLE veteran(
	Year_of_Death INT NOT NULL,  
  	County_of_Residence VARCHAR, 
  	Age VARCHAR,
  	Veteran_Status VARCHAR,
  	Total_Deaths_veteran int
);

CREATE TABLE county_info(
  	County VARCHAR, 
  	Description VARCHAR,
  	County_Size int,
	PRIMARY KEY(County)
);

CREATE TABLE population(
  	County VARCHAR, 
  	pop_2014 float,
  	pop_2015 float,
	pop_2016 float,
	pop_2017 float,
	pop_2018 float,
	pop_2019 float,
	per_2014 float,
	per_2015 float,
	per_2016 float,
	per_2017 float,
	per_2018 float,
	per_2019 float,
	PRIMARY KEY(County)
);

CREATE TABLE total_by_age(
	Year_of_Death INT NOT NULL,  
  	County_of_Residence VARCHAR, 
  	Age VARCHAR,
  	Total_Deaths int
);

select * from county_info;
select * from education;
select * from ethnicity;
select * from immigration;
select * from marital;
select * from veteran;
select * from total_by_age;
select * from sex;
select * from population