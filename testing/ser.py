import serial
import time


class Ser:
    debug = False
    delaySeconds = 0.001

    def __init__(self, baud):
        self.serial = serial.Serial(port="COM6", baudrate=baud)
        self.serial.set_buffer_size(4096,4096)
        self.serial.reset_input_buffer()
        self.serial.reset_output_buffer()
        self.serial.flush()
        self.serial.read_all()

    def uint16_Tx(self,dataSet):
        bin = []
        bin.append(int(len(dataSet)).to_bytes(length=2))
        for each in dataSet:
            bin.append(int(each).to_bytes(length=2))
        for each in bin:
            lower = int(each[1]).to_bytes()
            upper = int(each[0]).to_bytes()
            self.serial.write(lower)
            time.sleep(self.delaySeconds)
            self.serial.write(upper)
            time.sleep(self.delaySeconds)


    def uint16_TxACK(self, i):
        assert i < 65536, "argument i too large for uint16"
        assert i >= 0, "argument i too small for uint16"
        ret = i.to_bytes(length=2)
        lower = int(ret[1]).to_bytes()
        upper = int(ret[0]).to_bytes()
        self.dbgPrint("ACK recived, sending lower")
        time.sleep(6*self.delaySeconds)
        self.serial.write(lower)
        self.dbgPrint("ACK recived, sending upper")
        time.sleep(6*self.delaySeconds)
        self.serial.write(upper)

        if self.debug:
            print(f"sent {i}, upper:{upper.hex()}, lower:{lower.hex()}")

    def dbgPrint(self, string):
        if self.debug:
            print(string)

    def test(self, dataSet: list):
        self.sendList(dataSet)
        while self.serial.read_all().hex() != "f0":
            pass
        startTime = time.time()
        self.serial.read_until(b"\xff")
        stopTime = time.time()
        print(f"Test completed in {stopTime-startTime} seconds")
        return stopTime - startTime

    def sendList(self, dataSet: list):
        while self.serial.read_all().hex() != "f0":
            pass
        self.uint16_Tx(dataSet)
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
