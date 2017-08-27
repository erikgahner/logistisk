/*
Do-fil til: 'Logistisk regression med binært udfald'

Alle analyser er kørt i Stata 14.1

Kræver data der kan hentes fra: europeansocialsurvey.org
*/

* Åben datasæt
use "ESS7DK.dta", clear

* Omkod parti variabel
recode clsprty (1=1 "Ja") (2=0 "Nej") (else=.), g(parti)
label variable parti "Partitilknytning"

* Omkod tillidsvariabel
recode trstprl (88=.), g(folketing)
label variable folketing "Tillid (Folketinget)"

* Omkod kønsvariabel
g kvinde = gndr - 1
label variable kvinde "Køn (kvinde)"

* Omkod aldersvariabel
clonevar alder = agea
label variable alder "Alder"

* Omkod indkomstvariabel
recode hinctnta (77 88 99=.), g(indkomst)
label variable indkomst "Indkomst"

* Omkod uddannelsesvariabel
recode eisced (55 99=.), g(uddannelse)
label variable uddannelse "Uddannelse"

* Lav deskriptiv statistik -- se evt. https://www.ssc.wisc.edu/sscc/pubs/stata_tables.htm
estpost su parti folketing kvinde alder indkomst uddannelse
esttab using 01-deskriptiv.rtf, modelwidth(10 18) cell((mean(fmt(%9.1f) label(Gennemsnit)) sd(fmt(%9.2f) label(Standardafvigelse)) min( label(Minimum) fmt(%9.0f)) max( label(Maksimum) fmt(%9.0f)) )) label nomtitle nonumber noobs replace

* Illustrativt eksempel
** OLS regression med parti som afhængig variabel og tillid til folketinget som uafhængig variabel
reg parti folketing

** Marginale effekter fra den lineære regression
margins, over(folketing)

** Binær logistisk regression med parti som afhængig variabel og tillid til folketinget som uafhængig variabel
logit parti folketing

** Marginale effekter fra den logistiske regression
margins, over(folketing)

* Udregn marginale effekter
** Ved værdien 5
di (exp(1)^(.1733704+5*.1162725)) / (1 + (exp(1)^(.1733704+5*.1162725)))

** Kan også bruges:
di invlogit(.1733704+5*.1162725)

* Trin 1:

logit parti folketing kvinde alder indkomst uddannelse


* Kræver SPost pakken. Kan findes ved at bruge findit fitstat
fitstat

margins, dydx(*)

di ln(1.142846)

di exp(.13352164)


* Trin 2:

margins, over(folketing) at(kvinde=0 alder=48 uddannelse=4 indkomst=6)

* Trin 3:

marginsplot, recast(line) recastci(rline) xlabel(0 "Lav" 1 "" 2 "" 3 "" 4 "" 5 "" 6 "" 7 "" 8 "" 9 "" 10 "Høj") ciopts(lpattern(dash)) scheme(s1mono) title("") ytitle(" " "Pr(Partitilknytning = 1)") xtitle(" " "Tillid til Folketinget") legend(off) addplot(hist folketing, bcolor(gs15) ylabel(0(.1)1) below)
graph export fig-pr.png, height(1000) width(1400) replace
