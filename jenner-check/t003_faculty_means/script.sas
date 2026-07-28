/* Copy into masterdata for analysis without manipulating the original (author's approach) */
data masterdata;
	set rawdata;
run;

/* Average Experience of faculty department wise using PROC MEANS. */
/* class Dept performs the analysis separately for each department; */
/* var Total_Exp is the numeric variable summarised; */
/* output out= creates a dataset with the mean stored in AvgExp. */
proc means data=masterdata;
  class Dept;
  var  Total_Exp;
  output out=dept_avg_exp mean=AvgExp;
  label Dept="Department" AvgExp="Average Experience (Years)";
run;

/* Print only the per-department summary rows (_TYPE_=1). */
title "Table 3. Average Experience of faculty department wise";
proc print data=dept_avg_exp label noobs;
	format AvgExp 5.1;
	var  Dept AvgExp;
	where  _TYPE_=1;
run;
title;
