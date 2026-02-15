;; Demonstration of the csound semi-physical model opcode PREPIANO
;;
;; The idea is to generate chords starting from a melody.
;; 
;; Press any key to start a pattern. You will hear a sequence of chords at a certain pulse or a two sequences at different rates. The notes of the melody are sequentially overlapped to create a chord. Occasionally some of these notes are sent to the string resonator (instr 60).
;; 
;; This version uses the terminal to send some information. This was tested only in MacOS but should work fine for Linux users. Windows users please consider changing the system_i 1, {{clear}} calls — the clear command is Unix/macOS only. On Windows, the equivalent is cls. The clear command is for cosmetic purposes and isn't essential to the music. The prints statements will still work fine without them.
;;
;; Change the melody notes at gift "Table with stored midi notes" to use your own melodies.
;;
;; Author: Luis Antunes Pena
;;
;; License: The code in this project is licensed under the GNU General Public License v3.0
;; (https://www.gnu.org/licenses/gpl-3.0.html). You are free to use, modify, and
;; distribute the code, provided that derivative works remain under the same license.
;; Please let the author know if you use the code. See LICENSE for the full terms.
<CsoundSynthesizer>

<CsOptions>
-odac -A -d -m0  -+msg_color=0
</CsOptions>
;orchestra
<CsInstruments>
;global variables
sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1
seed 0

;user global variables
garev1 init 0
garev2 init 0
gares1 init 0
gares2 init 0
gicounter init 0
gkenv init 0

;Table with stored midi notes
gift ftgen 0, 0, 39, -2, 59, 64, 67, 71, 76, 71, 67, 64, 59, 64, 67, 71, 76, 71, 74, 78, 83, 86, 83, 86, 78, 74, 71, 74, 78, 83, 86,  87, 86, 85, 74, 86, 74, 75, 74, 73, 73, 73, 74 

instr 1 ;control instrument
  ifreq = p4
  itrans = p5
  iftstart = p6
  gicounter = iftstart

  idur = 1/ifreq
  ktrig metro ifreq
  kwhen randomh 0, 0.01, 1
  schedkwhen ktrig, 0, 0, 10, kwhen, idur, itrans, iftstart

  ires system_i 1, {{clear}}
  prints "\n\n"
  prints "\t instr \t min:sec \t freq \t midi \t counter\n"

  ktime times
  gktime = ktime

endin


instr 10 ;; sound production prepared piano
  indur = p3 + 0.1

  p3 = indur
  itrans = p4

  indx = gicounter

  ;read table
  imode = 0;raw
  imidi table indx, gift, imode 

  ifreq = cpsmidinn(imidi) * itrans * 0.5

  itime = i(gktime)
  imin = round(itime/60)
  isec = itime%60

  iftlen = ftlen(gift)
  if gicounter == 0 then
    
    ires system_i 1, {{clear}}
    prints "\n\n"
    prints "\n\t Verticalize this melody (%d notes): ", iftlen
    iindx init 0
    while iindx < iftlen do
      prints " %d", table(iindx, gift, imode)
      iindx += 1
    od
    prints "\n\n\t Press any key to change randomly the pattern\n\n"
    prints "\t instr \t\t min:sec \t freq \t\t midi \t\t counter\n"
  endif

  prints "\t 10 \t\t %d:%d \t\t %.2f \t %d \t\t %d\n", imin, isec, ifreq, imidi, gicounter

  iK = 1
  ipos random 0.05, 0.055
  ivel random 50, 60
  ihvfreq random 1000, 8000
  iNS = 3
  iD random  5, 6
  imass = 1
  ;al,ar prepiano ifreq, iNS, iD, iK, iT30,	iB, 	kbcl, kbcr, imass, ihvfreq, 	iinit, ipos, ivel, isfreq, isspread[, irattles, irubbers]
  aa,ab prepiano ifreq,	iNS, iD, iK, 3,         0.003, 	3, 	3, imass, ihvfreq,      -0.01, ipos, ivel, 0,	   0.2,       1, 	   2

  ;envelope
  iatt = 0.001
  isus = 0.1
  inull = 0.0001
  aenv expseg inull, iatt, 1,  isus, 0.7, p3-isus-iatt*2, inull

  iamp = db(-6)
  aout1 = aa * iamp * aenv * gkenv
  aout2 = ab * iamp * aenv * .75 * gkenv

  outs aout1, aout2

  gicounter = gicounter + 1

  if gicounter > (iftlen-1) then
   gicounter = 0
  endif

  ;send audio to reverb
  isend = random(0.001, 0.25)
  aoutr1, aoutr2 pan2 0.5*(aout1+aout2), random:i(0,1)
  garev1 = garev1 + aoutr1 * isend
  garev2 = garev2 + aoutr2 * isend

  ;send audio to resonance
  isendr = 0.9
  aoutr1, aoutr2 pan2 sum(aout1, aout2), random:i(0,1)
  gares1 += aoutr1 * isendr
  gares2 += aoutr2 * isendr

  
endin

instr 11 ;create some multiple events

  innotes = p4
  idur init p3
  ipulse init p5 ;; in Hz
  itrans init p6 ;; transposition
  inotestart init p7 ;; index of the midi notes array

  inn init 0
  
  while inn < innotes do
    idurr = idur/ipulse;; * random(1, 3)
    ipulser = ipulse * random(0.999, 1.001) ;; in Hz
    itransr = itrans ;; transposition
    inotestartr = inotestart ;; index of the midi notes array
    schedule 1, 0, idur, ipulser, itransr, inotestartr

    inn += 1
    
    prints "\n new event i11: dur: %.2f pulse: %.2f trans: %.2f index: %d", idur, ipulse, itrans, inotestart
  od

  turnoff
endin

instr 20;; some random triggering of events
  inn init 0
  ipulse = p4
  itrans = p5
  inotestart = p6
  iact = p7
  imode = round(random(0,10))
  
  if imode == 0 then  ;; 2/3 notes simultaneous
  ;; i11  0  5    3                   2       1       0
    schedule 11, 0, p3, round(random(2,3)), ipulse, itrans, inotestart
  elseif imode == 1 then ;; 1 note in one pulse 1 note in another pulse
    schedule 11, 0, p3,  round(random(1,2)), ipulse, itrans, inotestart
    schedule 11, 0, p3,  round(random(2,3)), ipulse+1, itrans, inotestart
  elseif imode == 2 then ;;
    schedule 11, 0, p3, round(random(3,5)), ipulse, itrans, inotestart
  elseif imode == 3 then
    while inn < round(random(2, 3)) do
      schedule 11, 0, p3, round(random(1,2)), ipulse+inn, itrans, inotestart
      inn += 1
    od
  else
    while inn < round(random(2,5)) do
      schedule 11, 0, p3, round(random(1, 3)), round(random(ipulse, ipulse*2)), round(random(itrans/2, itrans*2)), inotestart
      inn += 1
    od    
  endif

endin


instr 50 ;control surface

  i20 active 20 ;check if instr 20 is active

  if i20 == 2 then
    iact = 2
  else
    iact = 1
  endif
  
  ires system_i 1, {{clear}}
  prints "\n Press any key to start / stop new event"
  kres sensekey
  ktrig trigger kres, 0.5, 0

  schedkwhen ktrig, 0, 0, 51, 0, 0.05, iact
  
endin

instr 51 ;; turn off instruments
  prints "\n\n\t\t STOP all ..."
  idur1 = p3*0.9
  gkenv linseg 1, idur1, 0, p3*0.1, 0
  imode = 1; 0, 1, or 2: turn off all instances (0), oldest only (1), or newest only (2) 
  turnoff2 20, imode, 0
  turnoff2 11, imode, 0
;;  turnoff2 10, imode, idur1
  turnoff2 1, imode, 0
  ;gkstartstop = 0
  schedule 52, p3+0.01, p3, p4 ;;p4=iact
endin

instr 52 ;; turn on instruments
  prints "\n\n\t Play all ..."
  gkenv linseg 0, p3*0.9, 1, p3*0.1, 1
  iinstr = 20 + p4 * 0.1
  ;;               p1  p2  p3  p4  p5  p6  p7 
  schedule iinstr, 0, 1000, 2, 1,  0,  0,  p4 ;;(p4 = iact)
  gkstartstop = 1
endin

instr 60 ;resonance

  kfdbgain1 lfo 0.99, randomh:k(0.1, 1, 3), 1;;;;randomi:k(0.6, 0.99, 1) ;;kfdbgain1 * 0.5 + 0.5
  kfdbgain1 = kfdbgain1 * .5 + .5
  ktrig1 trigger kfdbgain1, 0.1, 1 ;; if kfdbgain1 crosses the threshold up-to-down then calculate new frequency

  ;read table
  imode = 0;raw
  kndx phasor 0.1
  kndx = kndx * (ftlen(gift)-1)
  kmidi table kndx, gift, imode 
  kfreq = cpsmidinn(kmidi) * 0.5

  ;;repeat until freq is between defined range
  repeat:
  
  if kfreq > 220 then
    kfreq = kfreq * .5 
    kgoto repeat
  endif

  kfreq1 samphold kfreq, ktrig1  

  ast1 streson gares1, kfreq1, kfdbgain1
  ast2 streson gares2, kfreq1, kfdbgain1

  iamp = db(0)
  aout1 = tanh(ast1 * iamp)
  aout2 = tanh(ast2 * iamp)
  outs aout1, aout2

  printf "\t new resonance frequency: %.2f \n", ktrig1, kfreq1

  ;send audio to reverb
  isend = random(0.5, 0.75)
  garev1 = garev1 + aout1 * isend
  garev2 = garev2 + aout2 * isend

  
endin

instr 999
  arev1, arev2 reverbsc garev1, garev2, 0.85, sr/8
  outs arev1, arev2
  clear garev1, garev2, gares1, gares2
endin

</CsInstruments>


;score
<CsScore>
f1 0 8 2 1 0.6 10 100 0.001 ;; 1 rattle
f2 0 8 2 1 0.7 50 500 1000  ;; 1 rubber

i50 0 36000 ;;keyboard control start/stop of events
i60 0 36000 ;;string resonance 
i999 0 36000 ;;reverb
e
</CsScore>

</CsoundSynthesizer>

