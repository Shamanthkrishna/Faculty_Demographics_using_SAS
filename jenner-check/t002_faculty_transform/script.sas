/* The Cadre must be in the order Professor,Associate Professor and Assistant Professor. */
/* This can be done by assigning them with values and later sorting these values. */
data rawdata;
	set rawdata;
	if Cadre="PROFESSOR" then Cadre="Professor";
	if Cadre="Professor" then rank=1;
	else if Cadre="Associate Professor" then rank=2;
	else rank=3;
run;

/* Name and Surname are concatenated using the catx function. */
/* Since the default lenght of Name is 9 after concatenating the values will be truncated. */
/* To overcome this issue the length of the Name is set to 50 */
data rawdata;
	length Name $50;
	format Name $50.;
	set rawdata;
	Name=catx(' ',name,surname);
run;

/* This data steps assigns the specific title for specific names based on their Qualification and Gender. */
/* Faculties with a PHD Degree is assigned with Dr. title in front of their Name. */
/* Male and Female Faculties who don't have PHD degree are assinged with Mr. and Ms. respectively. */
data rawdata;
	set rawdata;
	if Qualification="PHD" then Name="Dr. " || Name;
	else if gender="Male" and Qualification ne "PHD" then Name="Mr. "|| Name;
	else Name="Ms. " || Name;
run;

/* New column is created called Department for full forms of the column Dept */
data rawdata;
	set rawdata;
	length Department $50;			/*Setting the length and format of the new column*/
	format Department $50.;
		if dept="BTE" then Department="Biotechnology Engineering";
		else if dept="CSE" then Department="Computer Science Engineering";
		else if dept="ECE" then Department="Electronics & Communication Engineering";
		else if dept="CVE" then Department="Civil Engineering";
		else if dept="MEC" then Department="Mechanical Engineering";
run;

/* Show the derived Name, rank and Department columns */
title "Faculty names, rank and department (derived columns)";
proc print data=rawdata noobs label;
	var Staff_Id Name Cadre rank Department;
run;
title;
