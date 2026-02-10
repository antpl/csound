<CsoundSynthesizer>
<CsOptions>
-m0 -d -odac -A -+msg_color=0
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 256
nchnls = 2
0dbfs = 1.0
seed 0

garev1 init 0
garev2 init 0
gkdamp init 1

;; create an empty table
isize = 2^10 ;; SIZE OF THE TABLE
gisamp ftgen 0, 0, isize, 7, 0, isize, 0

instr 1 ;; main instrument

  ;; load a sample here .....
  Sample = "your_sample.wav"
  Sdir = "./samples/"
  Sfile strcat Sdir, Sample

  ;; table info for the sample
  itlen =ftlen(gisamp)
  itfreq = sr/itlen
  ittim = itlen/sr
  inchnls filenchnls Sfile

  ;; print some info
  prints "\n +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  prints "\n Sample "
  prints Sample
  prints " is playing in loop.\n Press any key to load %d sample of audio file into the table\n", itlen

  ;; check if sample is mono or stereo
  if inchnls == 2 then
    a1, a2 diskin2 Sfile, 1, 0, 1
    ga1 sum a1, a2
  else
    ga1 diskin2 Sfile, 1, 0, 1
  endif

  ;; keyboard key sense
  kres, kkeydown sensekey
  ktrig = kkeydown
  
  ;; trigger two events if key is pressed:
  idur = ittim
  schedkwhen ktrig, 0.1, 10, 2, 0, idur, itlen ;; event 1 to write the sample to table
  schedkwhen ktrig, 0.1, 10, 3, idur, randomh:k(3, 12, 4) ;;event 2 to play the table via an oscillator

endin


instr 2 ;write to table
  iphf = 1/p3
  itlen = p4
  prints "\n write to table p3 = %.4f iphf = %.2f itlen = %.2f", p3, iphf, itlen
  ;;write to buffer
  aph phasor iphf
  andx = aph * itlen
  ixmode = 0   ;; 0 = xndx and ixoff ranges match the length of the table.
  tablew ga1, andx, gisamp, ixmode
endin

instr 3 ;; play table via oscillator
  
  ii3 active 3 ;; check how many instances are activated

  ifn = gisamp ;; table name
  
  kamp = port(db(randomh:k(-18, -6, 4)), 0.1) ;; add amplitude variation 4/sec to event

  ;; control structure for the frequency
  ;; creates a certain kind of scale or pattern
  ifreq = 55*(round(random(1, 7))) ;; randomly create harmonic 1 to 7 of 55 Hz
  kfreq = 220 + 220 * samphold((0.5+0.5*lfo:k(1, 1, 1)), metro(5))
  asin poscil kamp, kfreq, ifn

  ;;envelope
  iatt = 0.1
  isus = p3/2
  idec = p3-iatt-isus
  kenv expseg 0.001, iatt, 1, isus, 0.7, idec, 0.0001

  gkamp = port(db(ii3*-1), .5) ;; decrease amplitude if more instances are activated
  
  aout1, aout2 pan2 asin*kenv*gkdamp, random(0, 1) ;; L/R

  outs aout1, aout2

prints "\n playing instr 3 (freq: %.2f) for %.2f seconds ... (%d instances | amplitude: %.2f) \n", ifreq, p3, ii3, i(gkamp)

  ;send to reverb
  ksend randomi 0.1, 0.4, 3
  garev1 += ksend * aout1
  garev2 += ksend * aout2
  
endin

instr 99;reverb
  ar1, ar2 reverbsc garev1, garev2, 0.85, sr/4
  outs ar1, ar2
  clear garev1, garev2
endin

</CsInstruments>
<CsScore>
i1 0 1000
i99 0 1000
e
</CsScore>
</CsoundSynthesizer>
