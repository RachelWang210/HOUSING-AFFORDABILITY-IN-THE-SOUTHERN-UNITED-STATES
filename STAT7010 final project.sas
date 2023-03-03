ods rtf file="I:\project\7030\SASOUTPUT.rtf" style=phil;
proc import out=house
 datafile='I:\project\7010\house1.csv' 
 dbms=csv replace;
run;

/*numbering the data*/
data h;
 set house;
 logV=log(VALUE);
 if location = 'Central City' then loca=1;
 if location = 'Suburb' then loca=2;
 if location = 'Nonmetro' then loca=3;
 keep VALUE logV Nroom Insurance Year loca ;
 label loca='Location';
 if value='1' then delete;
run;

/*matrix plot*/
proc sgscatter data=h;
 matrix value year nroom loca Insurance/
diagonal=(histogram kernel);
title'Matrix plot';
run;

/*test of normaly for value*/
proc glm noprint data=h;
 model value=Nroom Insurance Year loca;
 output out =diag1 R=residual P=pred;
run; quit;
Proc univariate data=diag1 normal;
 var residual;
 title'QQ-plot before transformation';
 qqplot residual/normal(l=1 mu=est sigma=est);
ods select TestsForNormality QQPlot;
run; quit;

/*histo for VALUE*/
proc sgplot data =h;
title'Histogram of Value';
 histogram value;
run;

/*test of normal for logvalue*/
proc glm noprint data=h;
 model logV=Nroom Insurance Year loca;
 output out =diag2 R=residual P=pred;
run; quit;
Proc univariate data=diag2 normal;
 var residual;
 title'QQ-plot after transformation';
 qqplot residual/normal(l=1 mu=est sigma=est);
ods select TestsForNormality QQPlot;
run; quit;

/*histo for LOGVALUE*/
proc sgplot data=h;
 histogram logV;
 title'Histogram of LOG(Value)';
run;

/*graph of constance varance*/
proc reg data= h;
 model logV=Nroom Insurance Year loca;
 plot r.*p.;
 output out=diag3 r=residual p=pred;
 title 'Residual vs. Predicted';
run; quit;

/*regular model*/
ods trace on;
proc glm data=h;
 class loca nroom insurance year;
 model logV= Year Nroom Insurance  loca ;
 random nroom insurance year;
run; quit;

/*fit the regular again*/
proc glm data=h;
 class loca nroom insurance;
 model logV= Nroom Insurance  loca ;
 random nroom insurance;
run; quit;

/*create interaction*/
data h1;
 set h;
 YR=year*Nroom;
 YI=year*insurance;
 RI=nroom*insurance;
 YRI=year*nroom*insurance;
run;

/*model with interaction*/
proc glm data=h1;
 class loca nroom insurance year;
 model logV=Year Nroom Insurance loca YR YI RI YRI ;
 random nroom insurance year;
run; quit;

/*fit the interaction model again*/
proc glm data=h1;
 class loca nroom insurance year;
 model logV=Year Nroom Insurance loca RI;
 random nroom insurance year;
run; quit;
/*only insurance & location are significant*/
/*remove year*/
proc glm data=h1;
 class loca insurance;
 model logV=Insurance loca;
 random insurance ;
run; quit;

ods rtf close;

