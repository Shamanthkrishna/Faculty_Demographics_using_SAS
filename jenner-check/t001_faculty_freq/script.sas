/* Mock faculty raw data substituting for the external xlsx PROC IMPORT.
   Column shape and value domains match Faculty_Demographics_RawData.xlsx.
   Comma-delimited so multi-word Cadre values ("Associate Professor") parse cleanly.
   DOB/DOJ are SAS date values (as the xlsx stored them). */
data rawdata;
    length Staff_Id $6 Name $9 Surname $12 Gender $6 Dept $3
           Qualification $3 Cadre $20 Residence $12;
    format DOB DOJ date9.;
    infile datalines dlm=',';
    input Staff_Id $ Name $ Surname $ Gender $ Dept $ Qualification $
          Cadre $ DOB DOJ Total_Exp Journals Salary_Monthly Residence $;
    datalines;
NM01,Rajesh,Patel,Male,BTE,PHD,Associate Professor,27534,39083,21,56,74500,Padubidre
NM02,Kunal,Sharma,Male,BTE,PHD,Professor,23622,38930,33,151,90500,Nitte
NM03,Suraj,Mukherjee,Male,BTE,PG,Assistant Professor,33855,42583,5,11,41000,Nitte
NM04,Aisha,Khan,Female,CSE,PHD,PROFESSOR,24106,39448,30,120,88000,Mangalore
NM05,Anushka,Rao,Female,CSE,PG,Assistant Professor,34220,43009,4,8,39500,Karkala
NM06,Isha,Nair,Female,CSE,PHD,Associate Professor,28001,40179,19,61,72000,Udupi
NM07,Deepak,Menon,Male,ECE,PHD,Professor,22995,38596,35,160,92000,Nitte
NM08,Suman,Iyer,Female,ECE,PG,Assistant Professor,33490,42248,6,14,42500,Kundapur
NM09,Darshan,Shetty,Male,ECE,PHD,Associate Professor,27900,40057,20,58,73000,Karkala
NM10,Tarun,Gupta,Male,CVE,PG,Assistant Professor,34600,43191,3,6,38000,Mangalore
NM11,Nandini,Reddy,Female,CVE,PHD,Associate Professor,28450,40544,18,52,71000,Udupi
NM12,Bhuvan,Joshi,Male,CVE,PHD,Professor,23300,38747,34,145,89500,Padubidre
NM13,Kavita,Desai,Female,MEC,PG,Assistant Professor,34010,42887,5,10,40000,Nitte
NM14,Shantanu,Bhat,Male,MEC,PHD,Associate Professor,27650,39905,22,64,75500,Karkala
NM15,Nikhil,Pai,Male,MEC,PHD,Professor,22800,38504,36,168,93500,Mangalore
NM16,Pallavi,Kamath,Female,BTE,PG,Assistant Professor,34300,43070,4,7,39000,Kundapur
NM17,Rishi,Hegde,Male,CSE,PHD,Associate Professor,28200,40300,19,55,72500,Nitte
NM18,Sanjay,Prabhu,Male,ECE,PG,Assistant Professor,33700,42430,5,12,41500,Udupi
NM19,Avantika,Bhandary,Female,CVE,PHD,Associate Professor,28600,40650,17,49,70500,Karkala
NM20,Smita,Acharya,Female,MEC,PG,Assistant Professor,34100,42950,4,9,40500,Padubidre
;
run;

/* Dept, Cadre, Qualification and Residence variables do not have unique values */
proc freq data=rawdata;
	tables  Dept Cadre Qualification Residence / nocum nopercent;
run;	/*NOCUM and NOPERCENT is used to remove unnecessary values from ouput*/

/* Resolving the issue of the value 'PROFESSOR'&'Professor' */
data rawdata;
	set rawdata;
	if Cadre="PROFESSOR" then Cadre="Professor";
run;
/* Cross-checking the values again */
proc freq data=rawdata;
	tables Cadre;
run;
