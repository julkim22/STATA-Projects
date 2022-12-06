*** 8. 조절효과와 매개효과 ***
clear
cd "/Users/julia/Desktop/Лена/klowf08_p.dta"

*** 데이터 열기 ***
use pskc_w12, clear
keep JCh19ses038 JCh19pss016 JCh19shs000 JCh19sel023 JCh19sfs000 JCh19str000

*** 변수 설정 ***
rename JCh19ses038 ses
rename JCh19pss016 pss
rename JCh19shs000 shs
rename JCh19sel023 sel
rename JCh19sfs000 sfs
rename JCh19str000 str

*** 조절효과 ***
reg shs str
reg shs str ses
reg shs c.str c.ses c.str#c.ses
vif

*** 평균중심화 변수 생성 ***
egen str_m=mean(str)
gen str_ms=str-str_m
egen ses_m=mean(ses)
gen ses_ms=ses-ses_m

*** 조절효과: 평균중심화 ***
reg shs str_ms
reg shs str_ms ses_ms
reg shs c.str_ms c.ses_ms c.str_ms#c.ses_ms
vif

*** 조절효과 그래프 ***
qui reg shs c.str c.ses c.str#c.ses
margins, at(str=(1(1)5) ses=(1(3)10)) atmeans noatlegend
marginsplot, noci recast(line)

*** 3단계 회귀분석을 이용한 매개효과 ***
reg str pss
reg sfs pss
reg sfs pss str

qui reg str pss
estimate store M1
qui reg sfs pss
estimate store M2
qui reg sfs pss str
estimate store M3
estimate table M1 M2 M3, b(%9.2f) stat(r2 N) star(0.001 0.01 0.05) style(column)
estimate table M1 M2 M3, b(%9.2f) se(%9.2f) p(%9.3f) stat(r2 N) style(column)

*** sgmediation 설치 ***
adopath + "c:\ado\plus\s"
help sgmediation

*** 부트스트래핑을 이용한 매개효과 ***
bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation sfs, mv(str) iv(pss)
sgmediation sfs, mv(str) iv(pss)
