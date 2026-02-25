;; Binary Rhythm Generator
;;
;; Generates rhythmic patterns from random binary numbers.
;; A random integer is converted to its binary representation,
;; and the resulting bit pattern (1s and 0s) drives a plucked
;; string synthesizer to create evolving rhythmic sequences.
;;
;; Author: Luis Antunes Pena
;; License: This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html). You are free to use, modify, and distribute this work, provided that derivative works remain under the same license. Please let the author know if you use the code. See [LICENSE](LICENSE) for the full terms.

<CsoundSynthesizer>
<CsOptions>
-d -odac -W -3 -+msg_color=0 -m0
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1.0
seed 0

garev1 init 0
garev2 init 0

gifn ftgen 0, 0, 128, 7, 0, 128, 0

;;array with 40 bits
gibin[] fillarray 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;

instr 1 ;;trigger 10
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ifm = 2.1 ;; <== change this value to adapt the tempo together with the number of bits 
  ibits = 5 ;; <== Number of Bits
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  km metro ifm
  imin = 0.1
  imax = 10
  schedkwhen km, imin, imax, 10,  0,   0.001,   ibits   ;;generate binary rhythm
  schedkwhen km, imin, imax, 100, 0.001, 1/ifm, ibits   ;;use the binary number to play sound as rhythm generator
endin

instr 10

  ;;number of bits
  ibits = p4
  ;;generate an integer number in the range of ibits
  irn = round(random(0, (2^ibits)-1)) ;; <== Changing the values of the random number will change the kind of rhythm
  idec = irn

  ;;convert the random generated decimal number into binary
  ;;store the binary number in array *gibin*
  icount init 0
  while irn >= 1 do
    ibit = irn % 2
    irn = floor(irn/2)
    gibin[icount]=ibit
    tablew ibit*(random(0.5,1)), icount, gifn
    ;;;prints "\n count: %d ibit = %d", icount, ibit
    icount+=1
  od

  ;;add 0 to MSB to fill the ibits number if necessary
  while icount < ibits do
    gibin[icount]=0
    icount+=1
  od

  ;;print the binary number
  prints "\n %d in bin (%d bits):", idec, ibits
  while  icount > 0  do
    prints " %d", gibin[icount-1]
    icount -= 1
  od
  
  prints "\n\n"
  
endin


instr 100;; trigger events

  ibits = p4
  itime = p3/ibits ;; time in sec per event / per bit
  icount init 0

  while icount < ibits do
    ip2 = itime*icount
    ibit = gibin[icount]
    schedule 101, ip2, itime, ibit
    ;;prints "\n schedule 101, %.2f, %.2f", ip2, itime, ibit
    icount += 1
  od
  
endin


instr 101

  ibit = p4
  if ibit == 0 igoto nosound
  iamp random db(-12), db(-6)
  ifreq random 40, 1000
  icps random 100, 2000
  ifn = 0
  imeth = 5 ;;weighted averaging. As method 1, with iparm1 weighting the current sample (the status quo) and iparm2 weighting the previous adjacent one. iparm1 + iparm2 must be <= 1.
  iparm1 = 0.1
  iparm2 = 0.1
  apluck pluck iamp, ifreq, icps, ifn, imeth , iparm1 , iparm2
  a1, a2 pan2 apluck, random:i(0, 1)
  outs a1, a2

  isend = 0.05
  if ifreq < (random:i(100,200)) then
    isend = 0.3
    prints "\t reverb ..."
  endif

  garev1 += isend * a1
  garev2 += isend * a2
  
  nosound:
endin

instr 999
  a1, a2 reverbsc garev1, garev2, 0.88, sr/8
  outs a1, a2
  clear garev1, garev2
endin
</CsInstruments>
<CsScore>
i1   0 100   ;start all
i999 0 100   ;reverb
</CsScore>
</CsoundSynthesizer>
