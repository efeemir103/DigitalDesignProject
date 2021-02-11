fname = input()
f = open(fname,"r") # 8-bit input data
fileContents = f.read()
fileLen = len(fileContents)
outFile = open("glyph.bin", "w") # 1-bit output data

for x in range(2048):
    for i in range(8):
        outFile.write('{0:0{1}X}'.format(counter,4))
        outFile.write(' : ')
        outFile.write(fileContents[x*10+i])
        outFile.write(';\n')   

f.close()
outFile.close()