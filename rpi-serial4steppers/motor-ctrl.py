import serial
import time
import threading

from tkinter import *

#serial port command bits can be ORed if neccessary
CMD_BIT_STEP  = 0x01 #mean make single step
CMD_BIT_DIR   = 0x02 #1 mean backward
CMD_BIT_FULL  = 0x04 #1 mean full-step stepper movement, otherwise half-step is used
CMD_BIT_SLEEP = 0x08 #power of from all motor windings
CMD_BIT_RESET = 0x10 #reset motor phase step counter
CMD_BIT_ADDR0 = 0x20 #ADDR[2:0] motor ID
CMD_BIT_ADDR1 = 0x40
CMD_BIT_ADDR2 = 0x80 #in case 2 motor control boards used for 8 motors

#address 4 motors by 2 cmd bits
CMD_ADDR0 = 0x00
CMD_ADDR1 = 0x20
CMD_ADDR2 = 0x40
CMD_ADDR3 = 0x60

slider_value = [0,0,0,0]

def read_slider_val( idx ):
	global slider_value;
	v=int( slider_value[idx] )
	dir = 0
	sleep =	0
	if v<0 :
		dir = CMD_BIT_DIR
		v=-v
	pad=int(10+(100-v)/2)
	if v<5 :
		sleep = CMD_BIT_SLEEP
	return dir, pad, sleep

pads=[0,0,0,0]
def read_sliders():
	global pads
	v0dir,v0pad,v0sleep=read_slider_val(0)
	v1dir,v1pad,v1sleep=read_slider_val(1)
	v2dir,v2pad,v2sleep=read_slider_val(2)
	v3dir,v3pad,v3sleep=read_slider_val(3)
	N=512
	ba = bytearray([0]*N)
	for k in range( int(N/4) ) :
		if pads[0]==0 :
			pads[0]=v0pad
			ba[k*4+0]=v0dir | CMD_BIT_STEP | CMD_ADDR0 | v0sleep
		else :
			pads[0]=pads[0]-1
			ba[k*4+0]=0  | CMD_ADDR0 | v0sleep
		if pads[1]==0 :
			pads[1]=v1pad
			ba[k*4+1]=v1dir | CMD_BIT_STEP  | CMD_ADDR1  | v1sleep
		else :
			pads[1]=pads[1]-1
			ba[k*4+1]=0  | CMD_ADDR1 | v1sleep
		if pads[2]==0 :
			pads[2]=v2pad
			ba[k*4+2]=v2dir | CMD_BIT_STEP   | CMD_ADDR2 | v2sleep
		else :
			pads[2]=pads[2]-1
			ba[k*4+2]=0  | CMD_ADDR2 | v2sleep
		if pads[3]==0 :
			pads[3]=v3pad
			ba[k*4+3]=v3dir | CMD_BIT_STEP  | CMD_ADDR3 | v3sleep
		else :
			pads[3]=pads[3]-1
			ba[k*4+3]=0  | CMD_ADDR3 | v3sleep
	return ba

port = serial.Serial()
port.baudrate=115200
port.port='/dev/ttyAMA0' #Raspberry Pi3
#port.port='/dev/ttyS1'  #OrangePi PC2 uses UART1
port.bytesize=8
port.parity='N'
port.stopbits=1
#port.write_timeout=0;
port.open()
print(port.name)

#disable all motor's windings
ba = bytearray([ CMD_ADDR0|CMD_BIT_SLEEP, CMD_ADDR1|CMD_BIT_SLEEP, CMD_ADDR2|CMD_BIT_SLEEP, CMD_ADDR3|CMD_BIT_SLEEP])
port.write( ba )

SerialPortFeederThreadRun = 1
def SerialPortFeederThread() :
	global SerialPortFeederThreadRun 
	print("SerialPortFeederThread Starts")
	while SerialPortFeederThreadRun :
		ba = read_sliders()
		port.write( ba )
	print("SerialPortFeederThread Ends")

master = Tk()
master.title("Step Motor Controller")
master.geometry("450x350")

def slider0_change(param):
	slider_value[0] = w0.get()

def slider1_change(param):
	slider_value[1] = w1.get()

def slider2_change(param):
	slider_value[2] = w2.get()

def slider3_change(param):
	slider_value[3] = w3.get()

w0 = Scale(master, from_=100, to=-100, length=196, command=slider0_change )
w0.place(x=25, y=25)
l0 = Label(text="Motor0")
l0.place(x=35, y=232)

w1 = Scale(master, from_=100, to=-100, length=196, command=slider1_change )
w1.place(x=25+50, y=25)
l1 = Label(text="Motor1")
l1.place(x=35+50, y=232)

w2 = Scale(master, from_=100, to=-100, length=196, command=slider2_change )
w2.place(x=25+100, y=25)
l2 = Label(text="Motor2")
l2.place(x=35+100, y=232)

w3 = Scale(master, from_=100, to=-100, length=196, command=slider3_change )
w3.place(x=25+150, y=25)
l3 = Label(text="Motor3")
l3.place(x=35+150, y=232)

def slider_poll() :
	print("Sliders: ",slider_value[0],slider_value[1],slider_value[2],slider_value[3] )
	master.after(1000, slider_poll)

serialThread = threading.Thread( target=SerialPortFeederThread )
serialThread.start()

#master.after(1000, slider_poll)
master.mainloop()

print("Main loop ends!")
SerialPortFeederThreadRun=0;
serialThread.join()

ba = bytearray([ CMD_ADDR0|CMD_BIT_SLEEP, CMD_ADDR1|CMD_BIT_SLEEP, CMD_ADDR2|CMD_BIT_SLEEP, CMD_ADDR3|CMD_BIT_SLEEP])
port.write( ba )
port.close()
