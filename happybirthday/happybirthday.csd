<CsoundSynthesizer>
<CsOptions>
-d -odac -A -m0
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1.0

garev1 init 0
garev2 init 0

strset 0, " "
strset 1, "*"

;-----------------------------------------------------------
instr 1
ires system_i 1, {{clear}}
gicount init 0
gicount2 init 0
gicountert init 0
gimidi[] fillarray  60, 60, 62, 0, 	60,	0, 65, 	0, 64, 	0, 0, 	0, 
					60, 60, 62, 0, 	60,	0, 67, 	0, 65, 	0, 0, 	0, 	
					60, 60, 72, 0, 	69,	0, 65, 	0, 64, 	0, 62, 	0, 	
					70, 70, 69, 0, 	65,	0, 67, 	0, 
					65, 0, 	0, 	0, 	0,	0, 0, 	0, 0, 	0, 0, 	0, 
					41, 0, 	0, 	0, 	0,	0, 0, 0, 0, 	0, 	0, 	0,	0, 	0, 	0, 	0
girhy[] fillarray	1, 	1, 	2, 	0, 	2, 	0, 2, 	0, 4, 	0, 0, 	0, 	
					1, 	1, 	2, 	0,	2, 	0, 2, 	0, 4, 	0, 0, 	0, 	
					1, 	1, 	2, 	0, 	2, 	0, 2, 	0, 2, 	0, 2, 	0,
					1, 	1, 	2, 	0, 	2, 	0, 2, 	0, 12, 	0, 0, 	0, 0, 0, 0, 0, 0, 0, 0, 0, 
					1, 0, 0, 0, 0, 0, 0, 0, 0, 	0, 	0, 	0,	0, 	0, 	0, 	0
gimidi2[] fillarray  0, 0, 0, 0, 0,	0, 62, 	62, 60, 60, 
					60, 60, 60, 60, 52, 52, 52,	52, 52,	52, 53, 53, 53, 53, 
					53, 53, 57, 57, 53,	53, 57, 57, 58, 58, 58, 58, 50, 50, 	
					48, 48, 53, 53, 60,	60, 65, 65, 
					65, 65,	65, 65, 0,	0, 0, 	0, 0, 	0, 0, 	0, 
					0, 0, 	0, 	0, 	0,	0, 0, 0, 	0, 	0, 	0, 	0, 	0, 	0
					;H 			A 			P 			P 		Y 			_ 		B 			I 			R 		T 		H 		D 		A 		Y
gitext[] fillarray 	1,0,0,0,1, 0,0,1,0,0, 1,1,1,0,0, 1,1,1,0,0, 1,0,0,0,1, 0,0,0,0,0, 1,1,0,0,0, 0,1,0,0,0,  						1,1,1,0,0, 1,1,1,1,1, 1,0,0,0,1, 1,1,1,0,0, 0,0,1,0,0, 1,0,0,0,1,
					1,0,0,0,1, 0,1,0,1,0, 1,0,0,1,0, 1,0,0,1,0, 0,1,0,1,0, 0,0,0,0,0, 1,0,0,1,0, 0,0,0,0,0, 1,0,0,0,1, 0,0,1,0,0, 1,0,0,0,1, 1,0,0,1,0, 0,1,0,1,0, 0,1,0,1,0,
					1,1,1,1,1, 0,1,1,1,0, 1,1,1,0,0, 1,1,1,0,0, 0,0,1,0,0, 0,0,0,0,0, 1,1,1,0,0, 0,1,0,0,0, 1,1,1,0,0, 0,0,1,0,0, 1,1,1,1,1, 1,0,0,0,1, 0,1,1,1,0, 0,0,1,0,0,
					1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,0, 1,0,0,0,0, 0,0,1,0,0, 0,0,0,0,0, 1,0,1,0,0, 0,1,0,0,0, 1,1,0,0,0, 0,0,1,0,0, 1,0,0,0,1, 1,0,0,1,0, 1,0,0,0,1, 0,0,1,0,0,
					1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,0, 1,0,0,0,0, 0,0,1,0,0, 0,0,0,0,0, 1,1,0,0,0, 0,1,0,0,0, 1,0,1,0,0, 0,0,1,0,0, 1,0,0,0,1, 1,1,1,0,0, 1,0,0,0,1, 0,0,1,0,0

		


itempo = 240
ifreq = itempo/60
kmetro metro ifreq
idur = 60/itempo
kmetro2 metro ifreq*6

schedkwhen kmetro, 0, 0, 10, 0, idur
schedkwhen kmetro, 0, 0, 11, 0, idur
schedkwhen kmetro2, 0, 0, 12, 0, idur;TEXT
endin



instr 10
imidi = gimidi[gicount]
irhy = girhy[gicount]
idur = p3
iamp random 0.3, 0.5

if imidi == 0 then 
iamp = 0
endif

p3 = idur * irhy

avib init 1
ifreq mtof imidi
kvf init 1

if irhy >= 4 then 
kvf expseg 1, .8, 10, 1, ifreq/2, 1, ifreq, 1, ifreq
avib poscil ifreq*kvf/200, kvf
endif

afreq = ifreq + avib

asin poscil iamp, afreq, 111100
iatt = 0.01
isus = p3*.5-iatt
idec = p3*.5
aenv linseg 0, iatt, 1, isus, 1, idec, 0
irpan random 0.3, 0.7
asig = asin*aenv
aout1, aout2 pan2 asig, irpan
outs aout1, aout2
ksend linseg 0.05, .5, 0.1, .5, 0.4, 1, 0.8, 1, 0.8 
garev1 =+ aout1 * ksend
garev2 =+ aout2 * ksend

nosound:
gicount = gicount + 1
ilen = lenarray(gimidi)

if gicount == (ilen-1) then 
event_i "e", 0, 1, 0
endif

endin

instr 11
imidi = gimidi2[gicount2]
irhy = 1
idur = p3
iamp random 0.5, 0.8

if imidi == 0 then 
iamp = 0
endif

p3 = idur * irhy

avib init 1
ifreq mtof (imidi-12)
kvf init 1

if irhy >= 4 then 
kvf expseg 1, 1, 10, 1, ifreq/2, 1, ifreq, 1, ifreq
avib poscil ifreq*kvf/200, kvf
endif

afreq = ifreq + avib

;print imidi, ifreq
asin poscil iamp, afreq, 111100
iatt = 0.01
isus = p3*.5-iatt
idec = p3*.5
aenv linseg 0, iatt, 1, isus, 1, idec, 0
irpan random 0.3, 0.7

kcf expon 5000, p3, 40
ireso random 0.7, 0.99

afilt moogladder asin, kcf, ireso
asig = afilt*aenv

aout1, aout2 pan2 asig, irpan
outs aout1, aout2
ksend linseg 0.1, 1, 0.2, 1, 0.4, 1, 0.9, 1, 0.9
garev1 =+ aout1 * ksend
garev2 =+ aout2 * ksend

nosound:
gicount2 = gicount2 + 1

ilen = lenarray(gimidi2)

if gicount2 == (ilen-1) then 
event_i "e", 0, 1, 0
endif
endin

instr 999;reverb

ain1 = garev1
ain2 = garev2
kfblvl = 0.85
kfco = sr/2

arev1, arev2 reverbsc ain1, ain2, kfblvl, kfco

outs arev1, arev2

clear garev1, garev2

endin

instr 12
imod = gicountert%70
if imod == 0 then 
prints "\n"
endif
imod2 = gicountert%5 
if imod2 == 0 then
prints " "
endif

ichar = gitext[gicountert]
Schar strget ichar
prints Schar
gicountert = gicountert + 1

ilen = lenarray(gitext)
if gicountert >= ilen then
turnoff2 1, 0, 0
endif

endin

;-----------------------------------------------------------

</CsInstruments>
<CsScore>
f111100 0 2048 10 1 1 1 1 0 0 
i1 0 100
i999 0 100
</CsScore>
</CsoundSynthesizer>
