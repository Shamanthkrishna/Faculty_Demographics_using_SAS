/* Library is created and linked to the data folder which can be accessed in the future */
libname bsaspro "/home/u59606296/BSAS MINOR PROJECT/Data";

/* Raw Data excel file is converted into a sas table which is saved in the data folder and also can be accessed 
form the library */
options validvarname=v7;
proc import datafile="/home/u59606296/BSAS MINOR PROJECT/Data/Faculty_Demographics_RawData.xlsx" 
			dbms=xlsx out=bsaspro.rawdata 
			replace;
run;

**********************************************************************************;
**********************************************************************************;
/* Checking the contents of the raw data sas table. */
/* Checking for various variables present in the raw data sas table */
proc contents data=bsaspro.rawdata;
run;

/* Dept, Cadre, Qualification and Residence variables do not have unique values */
proc freq data=bsaspro.rawdata;
	tables  Dept Cadre Qualification Residence / nocum nopercent; 
run;	/*NOCUM and NOPERCENT is used to remove unnecessary values from ouput*/

/* Observation: */
/* 	There are 5 Dept.They are BTE,CSE,CVE,ECE and MEC. */
/* 	There are 4 types of Cadre.They are Professor, PROFESSOR ,Associate Professor and Assistant Professor.*/
/* 	Here Professor is repeated twice since some are in Upper case and some in proper case. 
Hence 4 types of cadres 
are displayed */
/* 	There are 2 Qualifications. They are PG and PHD. */
/* 	Faculties reside in 5 different locations. They are Mangalore, Karkala, Padubidre, Nitte, Kundapur 
and Udupi. */
**********************************************************************************;
**********************************************************************************;
/* Resolving the issue of the value 'PROFESSOR'&'Professor' */
data bsaspro.rawdata;
	set bsaspro.rawdata;
	if Cadre="PROFESSOR" then Cadre="Professor";
run;
/* Cross-checking the values again */
proc freq data=bsaspro.rawdata;
	tables Cadre; 
run;

/* Observation: */
/* Since Professor and PROFESSOR both are same, this issue has been resolved uisng an IF condition. */
/* Now there are only 3 types of Cadre. */

/* The Cadre must be in the order Professor,Associate Professor and Assistant Professor. */
/* This can be done by assigning them with values and later sorting these values. */
data bsaspro.rawdata;
	set bsaspro.rawdata;
	if Cadre="Professor" then rank=1;
	else if Cadre="Associate Professor" then rank=2;
	else rank=3;
run;

/* Name and Surname are concatenated using the catx function. */
/* Since the default lenght of Name is 9 after concatenating the values will be truncated. */
/* To overcome this issue the length of the Name is set to 50 */
data bsaspro.rawdata;
	length Name $50;
	format Name $50.;
	set bsaspro.rawdata;
	Name=catx(' ',name,surname);
run;


/* This data steps assigns the specific title for specific names based on their Qualification and Gender. */
/* Faculties with a PHD Degree is assigned with Dr. title in front of their Name. */
/* Male and Female Faculties who don't have PHD degree are assinged with Mr. and Ms. respectively. */
data bsaspro.rawdata;
	set bsaspro.rawdata;
	if Qualification="PHD" then Name="Dr. " || Name;
	else if gender="Male" and Qualification ne "PHD" then Name="Mr. "|| Name;
	else Name="Ms. " || Name;
run;


/* Labels are assigned to the Column names which will be displayed in the Results */
data bsaspro.rawdata;
	set bsaspro.rawdata;
	label 	DOB="Date of Birth" DOJ="Date of Joining" 
			Total_Exp="Experience (Years)"  Salary_Monthly="Salary per Month";
run;

/* Age of the Faculties is calculated using the intck function by extracting the year from their 
Date of Birth. */
data bsaspro.rawdata;
	set bsaspro.rawdata;
	Age = intck('YEAR',DOB,today());
	format age 2.;
run;

/* New column is created called Department for full forms of the column Dept which tells us the 
department to which a faculty belongs */
data bsaspro.rawdata;
	set bsaspro.rawdata;
	length Department $50;			/*Setting the length and format of the new column*/
	format Department $50.;
		if dept="BTE" then Department="Biotechnology Engineering";
		else if dept="CSE" then Department="Computer Science Engineering";
		else if dept="ECE" then Department="Electronics & Communication Engineering";		
		else if dept="CVE" then Department="Civil Engineering";
		else if dept="MEC" then Department="Mechanical Engineering";
run;

/* The Data is sorted by Department, after sorting Department wise it is again sorted by Rank and at 
last it is sorted by Experience. */
/* Descending option is used to sort Experience form highest to lowest. */
/* Sorting again to avoid any errors in upcoming procedures but using the Department 
and not Dept Column*/
proc sort data=bsaspro.rawdata;
	by  Department Rank descending Total_Exp ;
run;

/* The data is copied into another sas table so that the copied data can be used for further 
analysis without manipulating the original data */
data bsaspro.masterdata;
	set bsaspro.rawdata;
run;

/* Before the Final Print all the coding required for Analytics is done in upcoming lines */
/* Necessary titles are given before the proc step making the titles global statement*/
title1"NMAM Institute of Technology, Nitte, Karkala" ;
title2 "Faculty Demographics" ;
title3 "Table 1. Department wise faculty list";

proc print 	data=bsaspro.masterdata label noobs
			STYLE(header)={backgroundcolor=lightblue color=black};
			by  Department;
			var  Staff_Id Name Cadre Qualification Total_Exp;
run;
title1;
title2;
title3;

**********************************************************************************;
**********************************************************************************;
/* Proc freq step has been carried out using the masterdata sas table. */
/* Gender column is selected for the summary statistics to be carried out to produce frequency tables. */
/* The output table is saved in the bsaspro library for further use. */

proc freq data=bsaspro.masterdata notitle;
	table  Gender / nocum out=bsaspro.summary;
	by department;
run;

/* Necessary Titles are given. */
title1 "Table 2. Summary Statistics of Faculty";
title2 "A. Gender Distribution";
/* The output table from the previous proc freq step is printed here.
Labels are given for the column names. */
proc print data=bsaspro.summary noobs label;
	where gender;
	by department;
	var  Gender COUNT PERCENT;
	label Gender="Gender" Count="Number of Faculties" Percent="Percentage %";
	format Percent 5.2;
run;
title1;
title2;

**********************************************************************************;
**********************************************************************************;
/* Pie Chart */
/* Pie Chart is created using the GUIs in Tasks and Utilities */
/* Department wise total faculty no. is visualized using a Pie Chart */

proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		entrytitle "Pie Chart" / textattrs=(size=15) ;
		entryfootnote halign=center "Figure 1. Dept wise for number of faculty" / 
			textattrs=(size=13);
		layout region;
		piechart category=Dept /  datalabellocation=callout datalabelattrs=(size=13) 
			dataskin=pressed;
		endlayout;
		endgraph;
	end;
run;

ods graphics / reset width=6in height=5in imagemap;

proc sgrender template=SASStudio.Pie data=BSASPRO.MASTERDATA;
run;

ods graphics / reset;
**********************************************************************************;
**********************************************************************************;
/* Clustered Bar Chart */
/* Clustered Bar Chart is plotted using GUIs in Tasks and Utilities. */
/* This is done by selecting Category as Dept and Subcategory as Cadre */
/* This gives the visualization of Count of faculties in each Department which is again branched 
based on their Cadre */

ods graphics / reset width=6in height=5in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=15pt "Clustered Bar Chart";
	footnote2 justify=center height=13pt "Figure 2. Dept wise cadre distribution";
	hbar Dept / group=Cadre groupdisplay=cluster datalabel dataskin=crisp;
	yaxis label="Department";
	xaxis max=10 grid label="Count (n)";
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
**********************************************************************************;
/* Average Experience of faculty department wise */
/* This is done using the proc means procedure. */
/* Proc means initiates the PROC MEANS procedure to calculate summary statistics for the masterdata 
dataset. */
/* "class Dept" specifies the variable "Dept" as a classification variable, indicating that 
the analysis  */
/* should be performed separately for each unique value of the variable. */
/* "var Total_Exp" specifies the variable "Total_Exp" as the numeric variable  */
/* for which the summary statistics are to be calculated. */
/* output out creates a new output dataset. */
/* "mean=AvgExp" calculates the mean (average) Total_Exp  */
/* for each unique value of "Dept" and stores the result in a new variable called "AvgExp". */

proc means data=bsaspro.masterdata;
  class Dept;
  var  Total_Exp;
  output out=bsaspro.dept_avg_exp mean=AvgExp;
  label Dept="Department" AvgExp="Average Experience (Years)";
run;

/* The output table is displayed using the proc print procedure. */
/* By using the "where TYPE=1" statement in the "proc print" code, SAS will only print observations  */
/* that correspond to the summary statistics for each department, which is what we are interested in 
for this analysis */

title "Table 3. Average Experience of faculty department wise";
proc print data=bsaspro.dept_avg_exp label noobs;
	format AvgExp 5.1;
	var  Dept AvgExp;
	where  _TYPE_=1;
run;
title;
**********************************************************************************;
**********************************************************************************;
/* Department-wise Comparison of Monthly Salary by Cadre */
ods graphics / reset width=7in height=5in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=14pt "Line Chart";
	footnote2 justify=center height=13pt 
		"Figure 3. Department-wise Comparison of Monthly Salary by Cadre";
	vline Cadre / response=Salary_Monthly group=Dept lineattrs=(thickness=2) 
		stat=mean;
	xaxis display=(nolabel);
	yaxis grid;
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
**********************************************************************************;
/* Relationship between Total Experience and Monthly Salary */
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=14pt "Scatter Plot";
	footnote2 justify=center height=12pt 
		"Figure 4. Relationship between Date of Joining and Monthly Salary";
	scatter x=Total_Exp y=Salary_Monthly / markerattrs=(symbol=circlefilled 
		color=CXff4949 size=8);
	xaxis grid label="Total Experience in Years";
	yaxis grid;
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
**********************************************************************************;
/* Gender Distribution by Residence Location */
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=14pt "Clustered Bar Chart";
	footnote2 justify=center height=13pt 
		"Figure 5. Gender Distribution by Residence Location";
	hbar Gender / group=Residence groupdisplay=cluster datalabel dataskin=pressed;
	yaxis label="Count (n)";
	xaxis grid display=(nolabel);
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
**********************************************************************************;
/* To calculate total number of faculties for each qualification from each daprtment */
proc freq data=bsaspro.masterdata notitle;
	tables Department*Qualification /  nocum nocol nopercent norow out=bsaspro.qualitable;
run;

title1 "Table 4. Department wise Qualification Count";
proc print data=bsaspro.qualitable noobs label STYLE(header)={backgroundcolor=lightblue color=black};
	var  Department Qualification COUNT;
	label Count="Number of Faculties" Percent="Percentage %";
	format Percent 5.2 ;
run;

/* Clustered Bar Chart */
ods graphics / reset width=6in height=5in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=15pt "Clustered Bar Chart";
	footnote2 justify=Center height=12pt 
		"Figure 5. Department-wise Faculty Qualification Count";
	vbar Department / group=Qualification groupdisplay=cluster datalabel 
		dataskin=matte;
	xaxis display=(nolabel);
	yaxis grid label="Number of Faculties";
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
**********************************************************************************;
/* Bubble Plot */
ods graphics / reset width=6in height=5in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=15pt "Bubble Plot";
	footnote2 justify=center height=13pt 
		"Figure 7. Age, Salary, and Experience of Staff Members";
	bubble x=Age y=Salary_Monthly size=Total_Exp/ group=Gender dataskin=sheen 
		bradiusmin=7 bradiusmax=20;
	xaxis grid label="Age (Years)";
	yaxis grid;
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
* 								FINAL REPORT PRINT 								 *;
**********************************************************************************;
ods pdf file="/home/u59606296/BSAS MINOR PROJECT/Output/Faculty Demograpics.pdf"
	style=printer startpage= now pdftoc=1;
options nodate;
options nonumber;
title1"NMAM Institute of Technology, Nitte, Karkala" ;
title2 "Faculty Demographics" ;
title3 "Table 1. Department wise faculty list";

proc print 	data=bsaspro.masterdata label noobs
			STYLE(header)={backgroundcolor=lightblue color=black};
			by  Department;
		var  Staff_Id Name Cadre Qualification Total_Exp;
run;
title1;
title2;
title3;
title4;


**********************************************************************************;
**********************************************************************************;

title1 "Table 2. Summary Statistics of Faculty";
title2 "A. Gender Distribution";
proc print data=bsaspro.summary noobs label STYLE(header)={backgroundcolor=lightblue color=black};
	where gender;
	by department;
	var  Gender COUNT PERCENT;
	label Gender="Gender" Count="Number of Faculties" Percent="Percentage %";
	format Percent 5.2;
run;
title1;
title2;

**********************************************************************************;
**********************************************************************************;

/* Pie Chart */
proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		entrytitle "Pie Chart" / textattrs=(size=15) ;
		entryfootnote halign=center "Figure 1. Dept wise for number of faculty" / 
			textattrs=(size=13);
		layout region;
		piechart category=Dept /  datalabellocation=callout datalabelattrs=(size=13) 
			dataskin=pressed;
		endlayout;
		endgraph;
	end;
run;

ods graphics / reset width=6in height=5in imagemap;

proc sgrender template=SASStudio.Pie data=BSASPRO.MASTERDATA;
run;

ods graphics / reset;
**********************************************************************************;
**********************************************************************************;
/* Clustered Bar Chart */

ods graphics / reset width=6in height=5in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=15pt "Clustered Bar Chart";
	footnote2 justify=center height=13pt "Figure 2. Dept wise cadre distribution";
	hbar Dept / group=Cadre groupdisplay=cluster datalabel dataskin=crisp;
	yaxis label="Department";
	xaxis max=10 grid label="Count (n)";
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
**********************************************************************************;
title "Table 3. Average Experience of faculty department wise";
proc print data=bsaspro.dept_avg_exp label noobs;
	format AvgExp 5.1;
	var  Dept AvgExp;
	where  _TYPE_=1;
run;
title;
**********************************************************************************;
**********************************************************************************;
/* Department-wise Comparison of Monthly Salary by Cadre */
ods graphics / reset width=7in height=5in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=14pt "Line Chart";
	footnote2 justify=center height=13pt 
		"Figure 3. Department-wise Comparison of Monthly Salary by Cadre";
	vline Cadre / response=Salary_Monthly group=Dept lineattrs=(thickness=2) 
		stat=mean;
	xaxis display=(nolabel);
	yaxis grid;
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
**********************************************************************************;
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=14pt "Scatter Plot";
	footnote2 justify=center height=12pt 
		"Figure 4. Relationship between Total Experience and Monthly Salary";
	scatter x=Total_Exp y=Salary_Monthly / markerattrs=(symbol=circlefilled 
		color=CXff4949 size=8);
	xaxis grid label="Total Experience in Years";
	yaxis grid;
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
**********************************************************************************;
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=14pt "Clustered Bar Chart";
	footnote2 justify=center height=13pt 
		"Figure 5. Gender Distribution by Residence Location";
	hbar Gender / group=Residence groupdisplay=cluster datalabel dataskin=pressed;
	yaxis label="Count (n)";
	xaxis grid display=(nolabel);
run;

ods graphics / reset;
title;
footnote2;



**********************************************************************************;
**********************************************************************************;
title "Table 4. Department wise Qualification Count";
proc print data=bsaspro.qualitable noobs label STYLE(header)={backgroundcolor=lightblue color=black};
	var  Department Qualification COUNT;
	label Count="Number of Faculties" Percent="Percentage %";
	format Percent 5.2 ;
run;
/* Clustered Bar Chart */
ods graphics / reset width=6in height=5in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=15pt "Clustered Bar Chart";
	footnote2 justify=Center height=12pt 
		"Figure 5. Department-wise Faculty Qualification Count";
	vbar Department / group=Qualification groupdisplay=cluster datalabel 
		dataskin=matte;
	xaxis display=(nolabel);
	yaxis grid label="Number of Faculties";
run;

ods graphics / reset;
title;
footnote2;

**********************************************************************************;
**********************************************************************************;
ods graphics / reset width=6in height=5in imagemap;

proc sgplot data=BSASPRO.MASTERDATA;
	title height=15pt "Bubble Plot";
	footnote2 justify=center height=13pt 
		"Figure 7. Age, Salary, and Experience of Staff Members";
	bubble x=Age y=Salary_Monthly size=Total_Exp/ group=Gender dataskin=sheen 
		bradiusmin=7 bradiusmax=20;
	xaxis grid label="Age (Years)";
	yaxis grid;
run;

ods graphics / reset;
title;
footnote2;
**********************************************************************************;
**********************************************************************************;

ods pdf close;

