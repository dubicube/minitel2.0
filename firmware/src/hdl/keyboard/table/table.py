f = open("table.csv", "r")
data = f.read().split('\n')[:-1]
f.close()

data = [i.split(';')[1:] for i in data]
data0 = [i[0:8] for i in data]
data1 = [i[8:]+['','','',''] for i in data]

result0 = []
for l in data0:
    for i in range(8):
        result0+=[int(l[i])|0x100 if l[i]!='' else 0]

result1 = []
for l in data1:
    for i in range(8):
        result1+=[int(l[i])|0x100 if l[i]!='' else 0]

result = result0+result1

for i in range(len(result)//32):
    print(result[i*32:(i+1)*32])
