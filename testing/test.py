from time import sleep
import time
from uint16 import uint16
from ser import Ser
import random

# protocall:
# wait for MCU to send 0x1
# send n,arr
# n = number of uint16 numbers
# arr = consecutive uint16 numbers, sending low byte first
# wait for MCU to send 0x1, indicating data recived and test startj
ser = Ser(9600)
# max uint16s on atmega328PB is ~1000, with 2K SRAM
testMax = 810
testCount = int(testMax / 10)
repeatCount = 10
while ser.serial.read_all().hex() != "f0":
    pass
ser.uint16_TxACK(testCount*repeatCount)
fileString = ""
for n in range(10, testMax + 10, 10):
    totalTimes = 0
    for i in range(repeatCount):
        li = random.sample(range(1, 65000), n)
        testTime = ser.test(li)
        totalTimes += testTime
    curString = f"""{n},{totalTimes/repeatCount}\n"""
    fileString += curString
    timeStamp = time.time()
    with open(f"testResults/testResults{timeStamp}.csv", "w") as file:
        file.write(fileString)
