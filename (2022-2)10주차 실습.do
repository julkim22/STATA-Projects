*** 7. 로지스틱 회귀분석 ***
clear
cd "/Users/julia/Desktop/Лена/klowf08_p.dta"

*** 데이터 열기 ***
use klowf08_p, clear
keep OPID P99AG P99ML01 PP99ED15 P07ML07B P08ST10 PP15CN P27AF01-P27AF08 P27AM01-P27AM04 W01MD01 H05FC 

*** 변수 설정 ***
rename P99AG age
rename P99ML01 msts
rename PP99ED15 edu
rename P07ML07B mhp
rename P08ST10 hhwsat
rename PP15CN chn
forvalues i=1 (1) 8 {
	rename P27AF0`i' famrole`i'
}
forvalues i=1 (1) 4 {
	rename P27AM0`i' famspt`i'
}
rename W01MD01 jobsts
rename H05FC ecosts

drop if edu==-9
drop if mhp==-9
drop if hhwsat==-9

recode hhwsat (1=5) (2=4) (3=3) (4=2) (5=1), gen(hhwsat_r)
recode chn (0=0) (1/9=1), gen(chn_d)
recode chn (0=0) (1=1) (2=2) (3/9=3), gen(chn_c)
recode famrole2 famrole4-famrole8 (1=4) (2=3) (3=2) (4=1)
recode famspt1-famspt4 (1=4) (2=3) (3=2) (4=1)
recode jobsts (1=1) (2/18=0), gen(jobsts_d)
recode ecosts (1=5) (2=4) (3=3) (4=2) (5=1), gen(ecosts_r)

egen famrole=rowmean(famrole1-famrole8)
egen famspt=rowmean(famspt1-famspt4)

label var hhwsat_r "남편 가사노동분담에 대한 만족도(역코딩)"
label var chn_d "자녀 유무"
label var chn_c "자녀 수(범주)"
label var famrole "가족 내 역할 인식(평균)"
label var famspt "가족부양 인식(평균)"
label var jobsts_d "취업 여부"
label var ecosts_r "현재경제상태(역코딩)"

label define hhwsat_l 1 "전혀 만족하지 않는다" 2 "별로 만족하지 않는다" 3 "보통이다" 4 "대체로 만족한다" 5 "매우 만족한다"
label values hhwsat_r hhwsat_l
label define chn_l 0 "없음" 1 "있음"
label values chn_d chn_l
label define chn_l2 0 "없음" 1 "1명" 2 "2명" 3 "3명 이상"
label values chn_c chn_l2
label define famval_l 1 "전혀 그렇지 않다" 2 "별로 그렇지 않다" 3 "조금 그렇다" 4 "매우 그렇다"
label values famrole2 famval_l
label values famrole4-famrole8 famval_l
label values famspt1-famspt4 famval_l
label define jobsts_l 0 "일 안했음" 1 "일 했음"
label values jobsts_d jobsts_l
label define ecosts_l 1 "매우 어렵다" 2 "조금 어려운 편이다" 3 "보통이다" 4 "여유가 있는 편이다" 5 "매우 여유가 있다"
label values ecosts_r ecosts_l

keep if msts==2

*** 로지스틱 회귀분석 ***
logit chn_d age edu jobsts_d ecosts_r famrole famspt hhwsat_r

*** 로지스틱 회귀분석: 오즈비 ***
logit chn_d age edu jobsts_d ecosts_r famrole famspt hhwsat_r, or
logistic chn_d age edu jobsts_d ecosts_r famrole famspt hhwsat_r

*** 로지스틱 회귀분석의 분류 정확도 ***
logistic chn_d age edu jobsts_d ecosts_r famrole famspt hhwsat_r
estat class

*** Hosmer & Lemeshow's test ***
logistic chn_d age edu jobsts_d ecosts_r famrole famspt hhwsat_r
estat gof, group(10) table

*** 다항 로지스틱 회귀분석 ***
mlogit chn_c age edu jobsts_d ecosts_r famrole famspt hhwsat_r
mlogit chn_c age edu jobsts_d ecosts_r famrole famspt hhwsat_r, rrr
mlogit chn_c age edu jobsts_d ecosts_r famrole famspt hhwsat_r, rrr base(1)

*** 순서형 로지스틱 회귀분석 ***
ologit chn_c age edu jobsts_d ecosts_r famrole famspt hhwsat_r

*** 평행성 검정 ***
net search oparallel

ologit chn_c age edu jobsts_d ecosts_r famrole famspt hhwsat_r
oparallel

net install spost13_ado, from("https://jslsoc.sitehost.iu.edu/stata/") replace

ologit chn_c age edu jobsts_d ecosts_r famrole famspt hhwsat_r
brant, detail

*** 일반화 순서형 로지스틱 회귀분석 ***
gologit2 chn_c age edu jobsts_d ecosts_r famrole famspt hhwsat_r
