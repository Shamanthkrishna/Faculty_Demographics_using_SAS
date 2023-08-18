* Problem Statement: Watch Video in Moodle before you start with next line 		*;
* This code need NOT be printed for Lab Report 									*;
*********************************************************************************;
* Created by: Dr. Venkatesh Kamath H, Asst Prof, Dept. of BTE, NMMAIT 			*;
*********************************************************************************;
* Last downloaded file from Moodle: 					 						*;
%let UpDate = 12APR2021 ;
*********************************************************************************;
* Description: 															*;
* This program creates attendance report based on videos watched by 	*;
* students in Moodle EVS course. Only sample 1 week video watch data is	*;
* is used for demonstration purpose. 									*;
* To understand the codes used, it is suggested to first look into the 	*;
* Excel files (input) Student_List & W1_Video_data. 					*;
* Read the comments given for better understanding.						*;
*********************************************************************************;
* Execute the set of codes between starred lines 								*;
*********************************************************************************;
/* Create a Library EVS and link it to DEMO folder	*/
/* Note: Change the FILEPATH 						*/
libname EVS "/home/u47462745/Batch_18BT/DEMO";

/* Student list excel file is imported */
/* Note: Change the FILEPATH to Student_List.xlsx	*/
options validvarname=v7;
proc import datafile="/home/u47462745/Batch_18BT/DEMO/Student_List.xlsx" 
			dbms=xlsx out=evs.student_list replace; 
	format SN 2.0;		/*Serial Number is 2 digit integer*/
run;
/* Check the contents of the Student_List sas table */
/* Check for variable list & type, format, label etc*/
proc contents data=evs.student_list;
run;
*********************************************************************************;
/* Open Student_List excel file from your computer (not within SAS studio)*/
/* to understand PROC FREQ & DATA step */
/* Variable that are not having unique data are: section, branch*/
proc freq data=evs.student_list;
	tables section branch;
run;
/* Observation: Section: A to H*/
/* In student list, some branch are written in 2 different forms*/
/* SAS considers them as different data but they are same */
/* DATA step below makes them uniform & saves permanently */
/* in the same original SAS table - check I/P & O/P filename*/
*********************************************************************************;
data evs.student_list;
	set evs.student_list;
	if branch = "AI and ML" or branch="AI & ML" then branch="AIML";
	if branch = "Comp. & Comn." or branch = "CC" then branch="CC";
	if branch = "E & C" or branch = "E&C" then branch="EC";
	if branch = "E & E" or branch = "E&E" then branch="EE";
	Name = upcase (Name);
run;
*********************************************************************************;
/* cross verify the Branch correction done in previous step */
proc freq data=evs.student_list;
	tables section branch;
run;
/* Sort the SAS table according to Reg_No */
/* This is needed because it is key unique identifier of a student & */
/* easy to handle datatype */
proc sort data=evs.student_list;
	by Reg_No;
run;				
/* If a table is already sorted, it will not sort again */
/* If you try to SORT repeatedly same table, 2nd time output will not be there */
/* REF LOG NOTES if you encounter this situation */
**********************************************************************************;
/* Master student list is ready which will be used as reference list */
/* Import list of watched video - week 1 to compare with reference list */
/* Note: Change the FILEPATH to W1_Video_data.xlsx	*/
options validvarname=v7;
proc import datafile="/home/u47462745/Batch_18BT/DEMO/W1_Video_data.xlsx" 
			dbms=xlsx out=evs.video_W1 replace; 
run;
/* Check the contents of the W1_Video_data sas table */
/* Check for variable list & type, format, label etc*/
proc contents data=evs.video_W1;
run;
/* Observation: description table looks complex and many unnecessary info are there*/
/* Open W1_Video_data.xlsx file from your computer (not within SAS studio)*/
/* to understand better.*/
/* From excel file: User_Full_Name variable is useful to create required output. */
/* All other information are unnecessary, so is PROC FREQ step. */
**********************************************************************************;
/* Observe the User_Full_Name in SAS table VIDEO_W1. It has Reg_No within it. */
/* Strategy: Sort & List unique User_Full_Name and extract required information. */
/* Use DATA step to extract Reg_No (new variable) from User_Full_Name */
/* Sort the video_w1 table as per Reg_no. and Remove duplicates */
/* Note that all names in this list have watched video. Compared to master list, */
/* missing names in this list have not watched video (absent) */

data evs.video_w1;
	set evs.video_w1;
	Length Reg_No $10 Section $1 ;				/* Executed in Compilation phase */
	format SN 2.0;								/* Executed in Compilation phase */	
	if substr(User_full_name, 1, 2) = "20" then
		Reg_No = substr(User_full_name, 1, 7);  /* Excludes all names other than "20...."*/
	else if delete;								/* Deletes all other values */
	Section = substr(Reg_No, 5, 1);				/* Extracts section from Name */
	Wk_1= 1;									/* Assigns Attendance value 1 for Wk 1 */
	keep Reg_No Section Wk_1;
run;
proc sort data=evs.video_w1 nodupkey;
	by Reg_No;						/* Sort by Reg_No, repeated values to be deleted */
run;
**********************************************************************************;
/* Merge two SAS tables: evs.student_list & evs.video_w1 through keyvariable Reg_No */
/* Note: Key var name in both SAS tables should be same to merge (Reg_No in this case)*/
data evs.attendance_w1;
	merge evs.student_list evs.video_w1;
	by Reg_No;
	if Wk_1 =. then Wk_1 = 0;
run;						/* Obs: 485 data in ATTENDANCE_W1 & STUDENT_LIST matches */
/* Observe the New SAS Table created. It is prepared out of 2 excel files */
/* A master sheet in which all 485 students names are present. */
/* A video watch excel file which contain names (out of 485) of only those who watched */
/* for whome attendance must be marked as yes */
/* Refer Wk_1 column of EVS.ATTENDANCE_W1 table, it has entries 1 means present */
/* or  . means absent. This file will be used for further analysis & Output. */

**********************************************************************************;
* 								FINAL REPORT PRINT 								 *;
**********************************************************************************;
/* Report required should be Section wise & SN within section */
/* First sort according to Section & then by SN */
proc sort data=evs.attendance_w1;
	by Section SN;
run;

/* Final formatting & calculation of total & percent attendance for tabulation */
data evs.attendance_final;
	set evs.attendance_w1;
	format percent 3.0;				/* percent - max 3 digit value, no decimal */
	total = wk_1;					/* this program is only for 1 wk, more can be added */
	percent = total/1*100;			/* More weeks added, denominator 1 will change */
run;

/* Observe evs.attendance_w1 sas table, last 3 columns */
**********************************************************************************;
/* Write the O/P to both PDF and EXCEL file */
/* Note: Change the FILEPATH 						*/

ods pdf file="/home/u47462745/Batch_18BT/DEMO/EVS_Attendance.pdf"   		
		style=HTMLBlue startpage=now; 			
ods excel file="/home/u47462745/Batch_18BT/DEMO/EVS_Attendance.xlsx"  		
		style=HTMLBlue 
		options (embedded_titles ="on" sheet_name="#byval1");
		
Title "Attendance for watching videos in Moodle: 20ES114 - Env Studies";
Title2 "As on: &UpDate";							
footnote "1 = attended, TA = Total class attended, %A = Attendance %";

/*In the report, if percent attendance is <75 (NE) it is marked Red with Yellow BG */
/* if percent attendance is 75-84 (penalty) it is marked Red with white BG */
/* If percent is 85 to 100 then black color with white BG */
proc format;
value backcolor low - 74 = 'yellow'
 				75 - 100 = 'white';
run;
proc format;
value forecolor low - 84 = 'Red'
 				85 - 100 = 'black';
run;

/* Orientation of PDF file: lndscape, alignment, header */
/* Write the var names in the same order how it should appear */
/* If in between var need formatting options, use multiple var statement */
/* Ex: name, percent are formatted */
/* style(data) means format is applicable to data values (485 rows) of that variable */
options orientation=landscape;
proc print 	data=evs.attendance_final noobs label 
			style(data)=[just=center]
			style(header)=[just=center];
	var SN Reg_No;
	var Name / style(data)= {just=l};
	var Branch Wk_1 total;
	var percent / style (data) = [background = backcolor.
								  foreground = forecolor.
								  font_weight = bold];
	by Section;										/* print by section */
	pageby Section;									/* each page in excel is Section */
	Label 	Reg_No = "Roll No"
			total = "TA"
			percent = '%A'
			Wk_1 = "Week #1";		/* Rename all var in the way you need in report */
run;
footnote;

/* Create Frequency table of attendance level */
ods excel options(sheet_name='Stat');
ods noproctitle;
title3 "Statistics for Attendance" ;
proc freq data = evs.attendance_final;
	tables section*percent /nocol norow nopercent plots=freqplot(orient = horizontal scale=freq);
run;
proc means data = evs.attendance_final mean maxdec=1;
	var percent;
	class section;
run;

title;
footnote;
ods _all_ close;					/* closes all open ODS */
**********************************************************************************;
/* From DEMO folder, download EVS_ATTENDANCE PDF & EXCEL files  */
/* Open and observe them for report style.  */
/* Compare the excel output with master file uploaded. Look at the sheet name */
**********************************************************************************;


