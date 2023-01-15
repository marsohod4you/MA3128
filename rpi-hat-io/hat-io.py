import sys
import signal
import RPi.GPIO as GPIO
import time

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

# Raspberry GPIO pins for write word 10bits, write register selector and write impulse
bits10 = [ 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 ]
bits8  = [ 10, 11, 12, 13, 14, 15, 16, 17 ]
bits4  = [ 10, 11, 12, 13 ]

#CPLD project gives 7 output registers selected by "sel" RPI GPIO pins:
#	0: led_reg
#	1: ioa_reg
#	2: iob_reg
#	3: ma_reg
#	4: mb_reg
#	5: mc_reg
#	6: md_reg
sel    = [ 20, 21, 22 ]

#RPI GPIO pin acts as write signal on raise edge
wr     = [ 23 ]

def set_pins_dir( pins, dir ) :
	for pin in pins :
		GPIO.setup( pin, dir )

set_pins_dir( bits10, GPIO.OUT )
set_pins_dir( sel,  GPIO.OUT )
set_pins_dir( wr,   GPIO.OUT )

def set_bits( pins, word ):
	for pin in pins :
		if word & 1 :
			GPIO.output(pin, GPIO.HIGH)
		else :
			GPIO.output(pin, GPIO.LOW)
		word = word >> 1


def write_word2reg( word, reg ) :
	global wr, sel, bits10, bits8, bits4
	GPIO.output( wr[0], GPIO.LOW)
	if reg==0 :
		bits = bits8
	elif reg == 1 or reg == 2 :
		bits = bits10
	else :
		bits = bits4
	set_bits( sel, reg )
	set_bits( bits, word )
	GPIO.output( wr[0], GPIO.HIGH)
	
def stepperHalf(cnt):
	if   cnt==0 :
		word=0b1100
	elif cnt==1 :
		word=0b0100
	elif cnt==2 :
		word=0b0110
	elif cnt==3 :
		word=0b0010
	elif cnt==4 :
		word=0b0011
	elif cnt==5 :
		word=0b0001
	elif cnt==6 :
		word=0b1001
	else :
		word=0b1000
	return word

def stepperFull(cnt):
	cnt=cnt&3
	if   cnt==0 :
		word=0b1100
	elif cnt==1 :
		word=0b0110
	elif cnt==2 :
		word=0b0011
	else :
		word=0b1001
	return word

#catch CTRL+C
def handler(signum, frame) :
	print("")
	print("Exit by CTRL+C")
	write_word2reg( 0, 0 )
	write_word2reg( 0, 1 )
	write_word2reg( 0, 2 )
	write_word2reg( 0, 3 )
	write_word2reg( 0, 4 )
	write_word2reg( 0, 5 )
	write_word2reg( 0, 6 )
	exit(1)
 
signal.signal(signal.SIGINT, handler)

#three types of RPI HAT IO DEMO: LED counter, LED bit move or Step motor drive
if len(sys.argv)<2 :
	print ('Need argument: "counter" or "bitmove" or "stepmotor"')
	exit(0)

if sys.argv[1]=="counter" :
	N=0
	while 1 :
		print( bin(N)[2:].zfill(8), end="\r" )
		write_word2reg( N, 0 )
		N=N+1
		time.sleep(0.1)
elif sys.argv[1]=="bitmove" :
	N=1
	DIR=1
	while 1 :
		print( bin(N)[2:].zfill(8), end="\r" )
		write_word2reg( N, 0 )
		if DIR :
			if N==128 :
				N=64
				DIR=0
			else :
				N=N<<1
		else:
			if N==1 :
				N=2
				DIR=1
			else :
				N=N>>1
		time.sleep(0.2)
elif sys.argv[1]=="stepmotor" :
	motor_dir = 1
	if len(sys.argv)==3 :
		if   sys.argv[2]=="F" :
			motor_dir = -1
			print("Forward")
		elif sys.argv[2]=="B" :
			motor_dir = 1
			print("Backward")
	#motor_port = 3 #PortA
	#motor_port = 4 #PortB
	#motor_port = 5 #PortC
	motor_port = 6 #PortD
	cnt=0
	while 1:
		#word=stepperFull(cnt)
		word=stepperHalf(cnt)
		print( bin(word)[2:].zfill(4), end="\r" )
		#print( bin(word)[2:].zfill(4))
		write_word2reg( word, motor_port )
		cnt=cnt+motor_dir
		cnt=cnt&7
		time.sleep(0.002)
