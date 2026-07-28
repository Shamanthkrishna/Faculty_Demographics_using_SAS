/* Derive the full-form Department column (needed for the crosstab), as in the primary script. */
data masterdata;
	set rawdata;
	length Department $50;
	format Department $50.;
		if dept="BTE" then Department="Biotechnology Engineering";
		else if dept="CSE" then Department="Computer Science Engineering";
		else if dept="ECE" then Department="Electronics & Communication Engineering";
		else if dept="CVE" then Department="Civil Engineering";
		else if dept="MEC" then Department="Mechanical Engineering";
run;

/* To calculate total number of faculties for each qualification from each department */
proc freq data=masterdata notitle;
	tables Department*Qualification /  nocum nocol nopercent norow out=qualitable;
run;

title1 "Table 4. Department wise Qualification Count";
proc print data=qualitable noobs label STYLE(header)={backgroundcolor=lightblue color=black};
	var  Department Qualification COUNT;
	label Count="Number of Faculties" Percent="Percentage %";
	format Percent 5.2 ;
run;
title1;
