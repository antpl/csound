;; Demonstration of the csound semi-physical model opcode VIB in 4 minutes 
;;
;; A control structure based on the principle of a sample&hold circuit 
;; fed by a sawtooth wave to generate scales or patterns.
;;
;; A more traditional approach using the score to trigger events instead of using other instruments to trigger events
;; 
;; You can run the code also in multichannels by changing the nchnls global variable
;;
;; Author: Luis Antunes Pena
;; 
;; License: This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html). You are free to use, modify, and distribute this work, provided that derivative works remain under the same license. Please let the author know if you use the code. See [LICENSE](LICENSE) for the full terms.

<CsoundSynthesizer>
<CsOptions>
-odac -d -A -m0 -+msg_color=0
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1.0
seed 0

garev1 init 0
garev2 init 0
gktime init 0

alwayson 99 ;; reverb

instr 1 ;make chord
 
  iamp = p4      ;; amplitude
  ifm = p5       ;; frequency of the pulse (metro)
  itime = p6     ;; phasor time
  ifreq1 = p7    ;; from freq
  ifreq2 = p8    ;; until freq
  iint1 = p9     ;; interval from
  iint2 = p10    ;; interval to
  innotes = p11  ;; number of notes in chord

  ;; pulse of the chord
  kfm randomi ifm, ifm*1.05, 1
  km metro kfm
  kdur = 1/kfm + randomh:k(3,7,5)

  ;; sawtooth LFO
  afreq phasor 1/itime
  gkfreq downsamp (ifreq1+afreq*(ifreq2-ifreq1))
  ;;printks "\n freq: %.2f", 1, gkfreq

  ;;                   p1  p2  p3  p4    p5     p6      p7
  schedkwhen km, 0, 0, 10, 0, kdur, iamp, iint1, iint2, innotes
  
endin


instr 10; vibes

  indx init 0
  incr = 1
  imax = p7-1
  iamp = db(p4)

  ifreq = i(gkfreq) ;;main frequency

  ;; generate chord with n (p7-1) number of notes
  ;; interval between the notes is defined randomly between p5 and p6
  loopit:
    
    iint=round(random(p5, p6))
    iint=(indx>0?iint:0)
    iffactor = 2^((iint)/12) ;;interval in semitones
    ifreq = ifreq * iffactor
    iamp random iamp, iamp*1.05
    schedule 11, 0, p3, iamp, ifreq, iint ;;play one note of the chord
    loop_le indx, incr, imax, loopit
    
   prints "\n "
    
endin

instr 11; play one note
  
  iamp = p4
  ifreq = p5
  iint = p6
  ihrd random 0.1, 0.9
  ipos random 0.0, 1
  imp = 1
  kvibf = 6.0
  kvamp = 0.05
  ivibfn = 2
  idec = 0.1

  ares vibes iamp, ifreq, ihrd, ipos, imp, kvibf, kvamp, ivibfn, idec

  ;;damp the output
  ares = ares * db(-3)
  
  if nchnls == 2 then 
    irpan random 0, 1
    aout1, aout2 pan2 ares, irpan
    outch 1, aout1
    outch 2, aout2
  else
    irpan random 1, nchnls  
    ichn = round(irpan)
    outch ichn, ares
    aout1, aout2 pan2 ares, (irpan-1)/nchnls
  endif

  ;;send to reverb
  irsend random 0.2, 0.4
  garev1 += irsend * aout1
  garev2 += irsend * aout2
  
  prints " | %.2f: dur: %.2f freq: %.2f int: %.2f", gktime, p3, ifreq, iint
  
endin

instr 99 ;;; reverb
  gktime timeinsts
  arev1, arev2 reverbsc garev1, garev2, 0.85, sr/2
  ich1 = (nchnls == 2 ? 1: 7)
  ich2 = (nchnls == 2 ? 2: 8)
  outch ich1, arev1
  outch ich2, arev2
  clear garev1, garev2
endin

</CsInstruments>
<CsScore>
;; Table #1, the "marmstk1.wav" audio file.
;; This file ships with Csound's examples. Download it here: https://csound.com/docs/manual/examples/marmstk1.wav
f 1 0 256 1 "marmstk1.wav" 0 0 0
; Table #2, a sine wave for the vibrato.
f 2 0 128 10 1
;;        
;        amp[dB]  metro[Hz] phasor[s]  freq1 freq2  int1 int2 nnotes
i1 0   20   -15      5         3         110   220    5    5    1
i1 9   20   -15      5         2         110   330    5    5    2
i1 18  20   -15      5         1         110   440    5    5    3
i1 30  20   -15      5         0.5       110   550    5    5    4
i1 40  20   -15      5         0.25      220   660    5    5    4
i1 60  20   -15      5         0.5       330   770    5    5    3
i1 70  10   -15      5         1         440   880    5    5    5
;        amp[dB]  metro[Hz] phasor[s]  freq1 freq2  int1 int2 nnotes
i1 80  20   -18      5         1         440   440    5    5    4 
i1 100 10   -15      .         1         55    220    4    5    6 
;        amp[dB]  metro[Hz] phasor[s]  freq1 freq2  int1 int2 nnotes
i1 110   10   -15      5         5        220   220    4    4    2 
i1 120   10   -15      5         5        220   220    3    5    3 
i1 130   20   -12      .         20       330   55     2    8    7 
i1 150   10   -9       2         10       55    55     3    5    3
;          amp[dB]  metro[Hz] phasor[s]  freq1 freq2  int1 int2 nnotes
i1 160 20   -9      6         30          330   330    2    3    2 
i1 180 10   -12     6         10          330   330    1    4    5
i1 190 18   -18     2         10          30    20     4    8    6
i1 200 30   -15     8         1           55    880    4    8    2
i1 202 28   -18     8         2           55    1760   4    8    3
i1 220 12   -21     8         0.5         55    3520   4    8    6
e

</CsScore>
</CsoundSynthesizer>
