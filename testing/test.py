from time import sleep
import serial
from uint16 import uint16

# protocall:
# wait for MCU to send 0x1
# send n,arr
# n = number of uint16 numbers
# arr = consecutive uint16 numbers, sending low byte first
# wait for MCU to send 0x1, indicating data recived and test startj
ser = serial.Serial(port="COM6", baudrate=20000, timeout=1)
while 1:
    ser.write(uint16(65535))
    sleep(0.5)
