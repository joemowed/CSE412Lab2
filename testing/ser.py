import serial
import time


class Ser:
    debug = False
    delaySeconds = 0.05

    def __init__(self, baud):
        self.serial = serial.Serial(port="COM6", baudrate=baud)
        self.serial.flush()
        self.serial.read_all()

    def uint16_Tx(self, i):
        assert i < 65536, "argument i too large for uint16"
        assert i >= 0, "argument i too small for uint16"
        ret = i.to_bytes(length=2)
        lower = int(ret[1]).to_bytes()
        upper = int(ret[0]).to_bytes()
        while self.serial.read_all().hex() != "f0":
            pass
        self.dbgPrint("ACK recived, sending lower")
        time.sleep(self.delaySeconds)
        self.serial.write(lower)
        while self.serial.read_all().hex() != "f0":
            pass
        self.dbgPrint("ACK recived, sending upper")
        time.sleep(self.delaySeconds)
        self.serial.write(upper)

        if self.debug:
            print(f"sent {i}, upper:{upper.hex()}, lower:{lower.hex()}")

    def dbgPrint(self, string):
        if self.debug:
            print(string)

    def test(self, dataSet: list):
        self.sendList(dataSet)
        startTime = time.time()
        self.serial.read_until(b"\xff")
        stopTime = time.time()
        print(f"Test completed in {stopTime-startTime} seconds")
        return stopTime - startTime

    def sendList(self, dataSet: list):
        self.uint16_Tx(len(dataSet))
        for i in dataSet:
            self.uint16_Tx(i)
        print(f"datset of size {len(dataSet)} uploaded", end=" , ")

    def getList(self, dataSetSize):
        self.serial.read_all()
        time.sleep(self.delaySeconds)
        ret = []
        self.uint16_Rx()  # MCU sends dataset size as first uint16, throw this away
        for i in range(dataSetSize):
            ret.append(self.uint16_Rx())
        return ret

    def uint16_Rx(self) -> int:
        data = self.serial.read(2)
        print(data)
        return data
