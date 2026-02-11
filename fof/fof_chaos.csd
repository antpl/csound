;; FOF synthesis driven by a logistic map / chaotic equation
;; Author: Luis Antunes Pena
;; License: This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html). You are free to use, modify, and distribute this work, provided that derivative works remain under the same license. Please let the author know if you use the code. See [LICENSE](LICENSE) for the full terms.

<CsoundSynthesizer>
<CsOptions>
-d -odac -A -m0  -+msg_color=0
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 128
nchnls = 2
0dbfs = 1.0
seed 0

garev1 init 0
garev2 init 0
gkdelta init 0 

;-----------------------------------------------------------

instr 1;control instrument

  ires system_i 1, {{clear}} ;;This runs the shell command clear at initialization — it clears the terminal. May not work for Windows users. 
  
  ;; algorithm: logistic equation xn = delta * xn * (1-xn)
  ix0 = 0.5
  kxn init ix0
  krf randomh .2, 1, .25
  kdelta randomh 3, 4, krf
  kxn = kdelta * kxn * (1 - kxn)
  gkxn = kxn

  ;sent to fof instrument
  kmtrig changed kxn
  imin = 0
  imax = 1
  kfph randomh 0.25, 3, 1
  idmin = 0.125*.5
  idmax = 0.5
  kdur = kfph*(idmax-idmin)+idmin
  schedkwhen kmtrig, imin, imax, 10, 0, kdur

  ;print some info ------
  gkdelta = kdelta
  ktrig changed gkdelta
  schedkwhen ktrig, 0.1, 1, 2, 0, 0.1
endin

instr 2
  prints "\n\t delta = %.4f\n", gkdelta
endin

instr 10
  irhy random 1, 3
  iffff random 0, 5
  if iffff < 3 then
    iff = 1 * irhy 
  elseif iffff < 4 then
    iff = 10
  elseif iffff < 5 then
    iff = 100
  endif

  ifund = i(gkxn)*iff

  prints "\r\t Freq: %.2f Hz          ", ifund

  iform = 800
  ioct = 0
  iband = 80
  kris = 0.01
  kdur = 0.03
  kdec = 0.01
  iolaps = 20*2
  ifna = 1
  ifnb = 2
  itotdur = p3 
  kphs = 0
  kgliss = 1

  ;formants "a"

  iform2 = 1150
  iform3 = 2900
  iform4 = 3900
  iform5 = 4950

  iband = 80
  iband2 = 90
  iband3 = 120
  iband4 = 130
  iband5 = 140

  iamp = db(0)
  iamp2 =  db(-6)
  iamp3 =  db(-32)
  iamp4 =  db(-20)
  iamp5 =  db(-50)

  ;random formant
  ;formant
  ivar = 0.7
  ifor random iform*(1-ivar), iform*(1+ivar)
  kform line iform, p3, ifor

  ifor2 random iform2*(1-ivar), iform2*(1+ivar)
  kform2 line iform2, p3, ifor2

  ifor3 random iform3*(1-ivar), iform3*(1+ivar)
  kform3 line iform3, p3, ifor3

  ifor4 random iform4*(1-ivar), iform4*(1+ivar)
  kform4 line iform4, p3, ifor4

  ifor5 random iform5*(1-ivar), iform5*(1+ivar)
  kform5 line iform5, p3, ifor5

  ;band
  ivarb = 0.7
  iban random iband*(1-ivarb), iband*(1+ivarb)
  kband line iband, p3, iban

  iban2 random iband2*(1-ivarb), iband2*(1+ivarb)
  kband2 line iband2, p3, iban2

  iban3 random iband3*(1-ivarb), iband3*(1+ivarb)
  kband3 line iband3, p3, iban3

  iban4 random iband4*(1-ivarb), iband4*(1+ivarb)
  kband4 line iband4, p3, iban4

  iban5 random iband5*(1-ivarb), iband5*(1+ivarb)
  kband5 line iband5, p3, iban5

  ;amp
  ivara = 0.7
  iam random iamp*(1-ivara), iamp*(1+ivara)
  kamp line iamp, p3, iam

  iam2 random iamp2*(1-ivara), iamp2*(1+ivara)
  kamp2 line iamp2, p3, iam2

  iam3 random iamp3*(1-ivara), iamp3*(1+ivara)
  kamp3 line iamp3, p3, iam3

  iam4 random iamp4*(1-ivara), iamp4*(1+ivara)
  kamp4 line iamp4, p3, iam4

  iam5 random iamp5*(1-ivara), iamp5*(1+ivara)
  kamp5 line iamp5, p3, iam5

  afof1 fof2 kamp, ifund, kform, ioct, kband, kris, kdur, kdec, iolaps, ifna, ifnb, itotdur, kphs, kgliss
  afof2 fof2 kamp2, ifund, kform2, ioct, kband2, kris, kdur, kdec, iolaps, ifna, ifnb, itotdur, kphs, kgliss
  afof3 fof2 kamp3, ifund, kform3, ioct, kband3, kris, kdur, kdec, iolaps, ifna, ifnb, itotdur, kphs, kgliss
  afof4 fof2 kamp4, ifund, kform4, ioct, kband4, kris, kdur, kdec, iolaps, ifna, ifnb, itotdur, kphs, kgliss
  afof5 fof2 kamp5, ifund, kform5, ioct, kband5, kris, kdur, kdec, iolaps, ifna, ifnb, itotdur, kphs, kgliss

  asigl sum afof1, afof3, afof5
  asigr sum afof1, afof2, afof4

  ifpan = 2
  kpan randomi 0, 1, ifpan
  kpan1 = kpan
  kpan2 = 1-kpan
  asig1, asig2 pan2 asigl, kpan1
  asig3, asig4 pan2 asigr, kpan2
  
  iamp = db(-24)
  asig1s sum asig1 * iamp, asig3*iamp
  asig2s sum asig2 * iamp, asig4*iamp

  outs asig1s, asig2s

  ;send to reverb
  isend = db(random(-30, -20))
  garev1=+ asig1s*isend
  garev2=+ asig2s*isend

endin
;-----------------------------------------------------------



instr 999;reverb
  ain1 = garev1
  ain2 = garev2
  kfblvl = 0.75
  kfco = sr/16
  arev1, arev2 reverbsc ain1, ain2, kfblvl, kfco
  outs arev1, arev2
  clear garev1, garev2
endin


</CsInstruments>
<CsScore>
f1 0 8192 10 1 ;sine
f2 0 4096 7 0 4096 1

;p1 	p2 		p3
i1 	0 		100
i999	0		101
e

</CsScore>
</CsoundSynthesizer>
