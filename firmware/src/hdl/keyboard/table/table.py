f = open("table.csv", "r")
data = f.read().split('\n')[:-1]
f.close()

data = [i.split(';')[1:] for i in data]
data0 = [i[0:8] for i in data]
data1 = [i[8:]+['','','',''] for i in data]

result0 = []
for l in data0:
    for i in range(8):
        v = int(l[i]) if l[i]!='' else 0;
        if i==7 or l[i+1]=='':
            v|=0x100
        result0+=[v]

result1 = []
for l in data1:
    for i in range(8):
        v = int(l[i]) if l[i]!='' else 0;
        if i==7 or l[i+1]=='':
            v|=0x100
        result1+=[v]

result = result0+result1

for i in range(len(result)//32):
    print(result[i*32:(i+1)*32])
