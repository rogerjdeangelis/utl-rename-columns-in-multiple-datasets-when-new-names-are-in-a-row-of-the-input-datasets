%let pgm=utl-rename-columns-in-multiple-datasets-when-new-names-are-in-a-row-of-the-input-datasets;

%stop_submission;

Rename columns in multiple datasets when new names are in a row of the input datasets

Use row two in to rename columns

INPUT
====

WORK.HAVE1       | WORK.HAVE2
                 |
ID   X      Y    | ID   X       Y
                 |
a  lunch  dinner | b  dinner  supper
a  xname1 yname1 | b  xname2  yname2 >> New names
a  mary   jane   | b  roger   john


OUTPUT
======

ID XNAME1 YNAME1 | ID XNAME1  YNAME1
                 |
a  lunch  dinner | b  dinner  supper
a  xname1 yname1 | b  xname2  yname2 >> New names
a  mary   jane   | b  roger   john

github
https://tinyurl.com/9vazj4v8
https://github.com/rogerjdeangelis/utl-rename-columns-in-multiple-datasets-when-new-names-are-in-a-row-of-the-input-datasets

stackoverflow
https://tinyurl.com/bdf8kzfw
https://stackoverflow.com/questions/79736319/renaming-columns-within-map-dynamically-using-the-values-from-a-certain-row

/**************************************************************************************************************************/
/* INPUT                                | PROCESS                                               | OUTPUT                  */
/* =====                                | =======                                               | ======                  */
/* WORK.HAVE1       | WORK.HAVE2        | %let old=%utl_varlist(have1,drop=id);                 | WORK.HAVE1              */
/*                  |                   | %put &=old; * OLD=X Y;                                |                         */
/* ID   X      Y    | ID   X       Y    |                                                       | ID XNAME1 YNAME1        */
/*                  |                   | * CREATE THE META DATA;                               |                         */
/* a  lunch  dinner | b  dinner  supper | data chk;                                             | a  lunch  dinner        */
/* a  xname1 yname1 | b  xname2  yname2 |   length dsn $80 new newc $200;;                      | a  xname1 yname1        */
/* a  mary   jane   | b  roger   john   |   retain dsn newc;                                    | a  mary   jane          */
/*                                      |   set have2(firstobs=2 obs=2 drop=id)                 |                         */
/* data have1;                          |       have1(firstobs=2 obs=2 drop=id) indsname=inds;  |                         */
/* input                                |   dsn=catx(' ',dsn,scan(inds,2,'.'));                 | WORK.HAVE2              */
/*  id$ x$ y$;                          |   new=catx(' ',%scan(&old,1),%scan(&old,2));          |                         */
/* cards4;                              |   newc=catx(',',new,newc);                            | ID XNAME2 YNAME2        */
/* a lunch dinner                       |   if _n_=2 then do;                                   |                         */
/* a xname1 yname1                      |      keep dsn newc;                                   | b  dinner supper        */
/* a mary jane                          |      output;                                          | b  xname2 yname2        */
/* ;;;;                                 |      call symputx('new',newc);                        | b  roger  john          */
/* run;quit;                            |      call symputx('dsn',dsn);                         |                         */
/*                                      |   end;                                                | %put &=dsn;             */
/* data have2;                          | run;quit;                                             | %put &=old;             */
/* input                                |                                                       | %put &=new;             */
/*  id$ x$ y$;                          | %put &=dsn;  * DSN = HAVE2             HAVE1    ;     |                         */
/* cards4;                              | %put &=old;  * OLD = X Y  (used twice)          ;     | * DSN=HAVE2 HAVE1 ;     */
/* b dinner supper                      | %put &=new;  * NEW = xname1 yname1,xname2 yname2;     | * OLD=X Y ;             */
/* b xname2 yname2                      |                                                       | * NEW=xname1 yname1     */
/* b roger john                         | %array(_dsn,values=&dsn);                             |    ,xname2 yname2       */
/* ;;;;                                 | %array(_new,values=%str(&new1,&new2),delim=%str(,));  |                         */
/* run;quit;                            |                                                       |                         */
/*                                      | %do_over(_dsn _new,phrase=%nrstr(                     |                         */
/*                                      |   proc datasets nodetails nolist;                     |                         */
/*                                      |     modify ?_dsn;                                     |                         */
/*                                      |     rename                                            |                         */
/*                                      |        %utl_renamel(&old,?_new) ;                     |                         */
/*                                      |   run;quit;                                           |                         */
/*                                      | ));                                                   |                         */
/**************************************************************************************************************************/

data have1;
input
 id$ x$ y$;
cards4;
a lunch dinner
a xname1 yname1
a mary jane
;;;;
run;quit;

data have2;
input
 id$ x$ y$;
cards4;
b dinner supper
b xname2 yname2
b roger john
;;;;
run;quit;

/**************************************************************************************************************************/
/*ID      X         Y    |  ID      X         Y                                                                           */
/*                       |                                                                                                */
/*a     lunch     dinner |  b     dinner    supper                                                                        */
/*a     xname1    yname1 |  b     xname2    yname2  >> the new names                                                      */
/*a     mary      jane   |  b     roger     john                                                                          */
/**************************************************************************************************************************/

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

%let old=%utl_varlist(have1,drop=id);
%put &=old; * OLD=X Y;

* CREATE THE META DATA;
data chk;
  length dsn $80 new newc $200;;
  retain dsn newc;
  set have2(firstobs=2 obs=2 drop=id)
      have1(firstobs=2 obs=2 drop=id) indsname=inds;
  dsn=catx(' ',dsn,scan(inds,2,'.'));
  new=catx(' ',%scan(&old,1),%scan(&old,2));
  newc=catx(',',new,newc);
  if _n_=2 then do;
     keep dsn newc;
     output;
     call symputx('new',newc);
     call symputx('dsn',dsn);
  end;
run;quit;

%put &=dsn;  * DSN=HAVE2             HAVE1    ;
%put &=old;  * OLD=X                  Y       ;
%put &=new;  * NEW=xname1 yname1,xname2 yname2;

%array(_dsn,values=&dsn);
%array(_new,values=%str(&new1,&new2),delim=%str(,));

%do_over(_dsn _new,phrase=%nrstr(
  proc datasets nodetails nolist;
    modify ?_dsn;
    rename
       %utl_renamel(&old,?_new) ;
  run;quit;
));

%arraydelete(_dsn);
%arraydelete(_new);
%symdel old / nowarn;

/**************************************************************************************************************************/
/*  INTERMEDIATE WORK.CHK                                                                                                 */
/*                                                                                                                        */
/*      DSN                   NEWC                                                                                        */
/*                                                                                                                        */
/*  HAVE2 HAVE1    xname1 yname1,xname2 yname2                                                                            */
/*                                                                                                                        */
/*  META MACRO VARIABLES                                                                                                  */
/*                                                                                                                        */
/*  %put &=dsn;    * DSN=HAVE2             HAVE1    ;                                                                     */
/*  %put &=old;    * OLD=X                  Y       ;                                                                     */
/*  %put &=new;    * NEW=xname1 yname1,xname2 yname2;                                                                     */
/*                                                                                                                        */
/*  WORK.HAVE1       | WORK.HAVE2                                                                                         */
/*                   |                                                                                                    */
/*  ID XNAME1 YNAME1 | ID XNAME2    YNAME2                                                                                */
/*                   |                                                                                                    */
/*  a  lunch  dinner | b  dinner  supper                                                                                  */
/*  a  xname1 yname1 | b  xname2  yname2 >> New names                                                                     */
/*  a  mary   jane   | b  roger   john                                                                                    */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
