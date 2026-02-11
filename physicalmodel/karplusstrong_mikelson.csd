;; Karplus-Strong Waveguide Plucked String
;;
;; A generative instrument based on the waveguide plucked bass model
;; by Hans Mikelson, from "Mathematical Modeling with Csound:
;; From Waveguides to Chaos" in The Csound Book (MIT Press, 2000).
;;
;; A control instrument triggers plucked notes from a pitch set,
;; with accelerating repetitions and evolving timbre over time.
;;
;; Author: Luis Antunes Pena
;; Original waveguide model: Hans Mikelson
;; License: This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html). You are free to use, modify, and distribute this work, provided that derivative works remain under the same license. Please let the author know if you use the code. See [LICENSE](LICENSE) for the full terms.

<CsoundSynthesizer>
<CsOptions>
-m0 -d -odac -A -+msg_color=0
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 128
nchnls = 2
0dbfs = 1.0
seed 0

garev1 init 0
garev2 init 0


;; INSTRUMENT Nr. 1901 from Hans Mikelson:
;; Mathematical Modeling with Csound:
;; From Waveguides to Chaos.
;; The Csound Book

ginotes[] fillarray 40, 47, 51, 57, 62, 64, 70, 75, 77, 83, 85 ;midi notes
ginote init 0
gktrig init -1

instr 9
  kfreq = randomh(0.1, .52, 1)
  ktrig metro kfreq
  schedkwhen ktrig, 0, 10, 10, 0, 1/kfreq
endin

instr 10 ;controll 1901

  gktime times
  
  inote = limit(ginote + round(random(0,2)), 0, lenarray(ginotes)-1 ) ;;index of the notes array
  imidi = ginotes[inote] ;; midi note

  itan = taninv(divz((imidi-40), 85, 0))*3+1 ;;the higher the note the higher the frequency of repetition

  prints "\n Playing control instrument for %.2f, note: %d [%d] accel. until: %.2f", p3, imidi, inote, itan

  ;; set the curve for the repetitions 
  idur = p3*.5
  kms expseg 2, idur, 5, idur, 10*itan
  ktrig metro kms
  ;; pan, amplitude, send to reverb  
  ip1 = random(0, 1)
  ip2 = 1 - ip1
  kpan expon ip1, idur, ip2
  kamp expseg 1, p3, db(-24)
  ksend expseg 0.1, p3, 1 ;; the more repetitions and the quieter the sound the more reverb should be heard

  ;; trigger the plucked instrument
  ;;;                                      p4                        p5      p6                  p7    p8
  ;;;                                      amp                       midi    pluck               pan   send to rev
  schedkwhen ktrig, 0, 100, 1901, 0, 1/kms, random(0.2, 0.4)*kamp,  imidi,   random(0.1, 0.8),   kpan, ksend

  ;; reset counter for the notes index array
  ginote += 1
  if ginote >= lenarray(ginotes) then
    ginote = 0
  endif

  if gktrig <= 0 then
    gktrig = 1
  else
    gktrig = 0
  endif

  ;; trigger another instrument to trigger instr 10
  schedkwhen gktrig, 0.2, 3, 9, 0, 10
  
endin

;; Waveguide Plucked Bass from Hans Mikelson
;; with minor changes
instr 1901

  ipan = p7
  isend = p8
  ifqc mtof (2*p5/(round(random(2,3))))
  ipluck = 1/ifqc*p6 * 0.5
  kcount init 0
  adline init 0
  ablock2 init 0
  ablock3 init 0
  afiltr init 0
  afeedbk init 0

  ;;output envelope
  koutenv linseg 0, 0.01, 1, p3-.11, 1, .1, 0
  kfltenv linseg 0, 1.5, 1, 1.5, 0

  ;this envelope loads the string with a triangle wave
  kenvstr linseg 0, ipluck/4, -p4/2, ipluck/2, p4/2, ipluck/4, 0, p3-ipluck, 0
  aenvstr upsamp kenvstr
  ainput tone aenvstr, 200

  ;dc blocker
  ablock2 = afeedbk - ablock3 + .999 * ablock2
  ablock3 = afeedbk
  ablock = ablock2

  ;delay line with filtered feedback
  adline delay ablock + ainput, 1/ifqc/2 - 15/sr ;; changed the original formula 1/fqc to 1/fqc/2
  kffreq = 100 + 7900 * (gktime%60)/60 ;;change timbre every 60 seconds from percussive to string
  afiltr tone adline, kffreq

  ;resonance of the body
  abody1 reson afiltr, 110, 40
  abody1 = abody1 / 5000
  abody2 reson afiltr, 70, 20
  abody2 = abody2 / 5000
  afeedbk = afiltr
  aout = afeedbk
  iamp = db(12)
  aout1 =  iamp * koutenv * (aout+kfltenv*(abody1+abody2))

  a1, a2 pan2 aout1, ipan

  outs a1, a2

  ;;send to reverb
  garev1 += a1 * isend
  garev2 += a2 * isend
  
endin

instr 9998 ;reverb
  ar1, ar2 reverbsc garev1, garev2, 0.85, sr/4
  outs ar1, ar2
  clear garev1, garev2
endin


</CsInstruments>
<CsScore>
i10 0 5
i9998 0 10000
e
</CsScore>
</CsoundSynthesizer>
