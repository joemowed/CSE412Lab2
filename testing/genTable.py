import random

completeStr = ""
size = int(input("Enter number of uints to genererate"))
completeStr += "table: .DB 0x" + size.to_bytes().hex() + ",0x0,"
for i in range(size * 2):
    ret = ""
    rint = random.randint(0, 255)
    ret += "0x" + rint.to_bytes(1).hex() + ","
    completeStr += ret
print(completeStr)
completeStr = completeStr[:-1]
print(completeStr)
with open("data.asm", "w") as file:
    file.write(completeStr)
