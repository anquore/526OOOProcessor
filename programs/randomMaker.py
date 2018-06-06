import math
import random
#import numpy as np

#math op codes
AND = '100_0101_0000'
ADD = '100_0101_1000'
ADDS = '101_0101_1000'
SUB = '110_0101_1000'
SUBS = '111_0101_1000'
OR = '101_0101_0000'
XOR = '110_0101_0000'
BR = '110_1011_0000'
MULT = '100_1101_1000'
DIV = '100_1101_0110'

#conditional branching opcodes
BCOND = '010_1010_0'
CBZ = '101_1010_0'
EQ = '00000'
NE = '00001'
GE = '01010'
LT = '01011'
GT = '01100'
LE = '01101'

#basic branch
B = '000_101'
BL = '100_101'

#memory commands
LDUR = '111_1100_0010'
STUR = '111_1100_0000'

#immediate commands
ADDI = '100_1000_100'

#shift commands
LSL = '110_1001_1011'
LSR = '110_1001_1010'

def main():
  
  #clear the file
  theFile = open('randomTest.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('randomTest.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 1, 0, 31, theFile)
  immediateCommand('ADDI', ADDI, 2, 1, 31, theFile)
  immediateCommand('ADDI', ADDI, 3, 2, 31, theFile)
  immediateCommand('ADDI', ADDI, 4, 3, 31, theFile)
  immediateCommand('ADDI', ADDI, 5, 4, 31, theFile)
  immediateCommand('ADDI', ADDI, 6, 5, 31, theFile)
  immediateCommand('ADDI', ADDI, 7, 6, 31, theFile)
  immediateCommand('ADDI', ADDI, 8, 7, 31, theFile)
  immediateCommand('ADDI', ADDI, 9, 8, 31, theFile)
  immediateCommand('ADDI', ADDI, 10, 9, 31, theFile)
  immediateCommand('ADDI', ADDI, 11, 10, 31, theFile)
  immediateCommand('ADDI', ADDI, 12, 11, 31, theFile)
  immediateCommand('ADDI', ADDI, 13, 12, 31, theFile)
  immediateCommand('ADDI', ADDI, 14, 13, 31, theFile)
  immediateCommand('ADDI', ADDI, 15, 14, 31, theFile)
  immediateCommand('ADDI', ADDI, 16, 15, 31, theFile)
  immediateCommand('ADDI', ADDI, 17, 16, 31, theFile)
  immediateCommand('ADDI', ADDI, 18, 17, 31, theFile)
  immediateCommand('ADDI', ADDI, 19, 18, 31, theFile)
  immediateCommand('ADDI', ADDI, 20, 19, 31, theFile)
  immediateCommand('ADDI', ADDI, 21, 20, 31, theFile)
  immediateCommand('ADDI', ADDI, 22, 21, 31, theFile)
  immediateCommand('ADDI', ADDI, 23, 22, 31, theFile)
  immediateCommand('ADDI', ADDI, 24, 23, 31, theFile)
  immediateCommand('ADDI', ADDI, 25, 24, 31, theFile)
  immediateCommand('ADDI', ADDI, 26, 25, 31, theFile)
  immediateCommand('ADDI', ADDI, 27, 26, 31, theFile)
  immediateCommand('ADDI', ADDI, 28, 27, 31, theFile)
  immediateCommand('ADDI', ADDI, 29, 28, 31, theFile)
  immediateCommand('ADDI', ADDI, 30, 29, 31, theFile)
  immediateCommand('ADDI', ADDI, 31, 30, 31, theFile)
  
  #define the arm commands as arrays
  mathOps = [AND, ADD, ADDS, SUB, SUBS, OR, XOR, MULT, DIV]
  condOps = [BCOND, CBZ]
  condOpsSpecial = [EQ, NE, GE, LT, GT, LE]
  branchOps = [B, BL]
  memoryOps = [LDUR, STUR]
  immeOps = [ADDI]
  shiftOps = [LSL, LSR]
  
  #setup some variables
  highestAddress = 250
  lowAddress = 31;
  
  #create a program of the specified length
  while (lowAddress < highestAddress):
    #choose a random command
    command = random.randint(0, 5)
    
    if(command == 0):
      #a math command
      RD = random.randint(0, 31)
      RN = random.randint(0, 31)
      RM = random.randint(0, 31)
      op = random.randint(0, 8)
      opcode = mathOps[op]
      mathCommand('math', opcode, RD, RM, RN, theFile)
      lowAddress += 1
    elif(command == 1): 
      #a shift command
      RD = random.randint(0, 31)
      RN = random.randint(0, 31)
      SHAMT = random.randint(0, 63)
      op = random.randint(0, 1)
      opcode = shiftOps[op]
      shiftCommand('shift', opcode, RD, SHAMT, RN, theFile)
      lowAddress += 1
    elif(command == 2):
      #a memory command, restricted to only access memory between 0 and 200
      RN = 31
      RD = random.randint(0, 31)
      address = random.randint(0, 25)
      address = address * 8;
      op = random.randint(0, 1)
      opcode = memoryOps[op]
      memoryCommand('mem', opcode, address, RD, RN, theFile)
      lowAddress += 1
    elif(command == 3):
      #an immediate command, restricted to only add a value between 0 and 1000
      RN = random.randint(0, 31)
      RD = random.randint(0, 31)
      immediate = random.randint(0, 1000)
      op = 0
      opcode = immeOps[op]
      immediateCommand('ADDI', opcode, immediate, RD, RN, theFile)
      lowAddress += 1
    elif(command == 4):
      farBack = -lowAddress + 2
      farForward = highestAddress - lowAddress - 2
      address = random.randint(farBack, farForward)
      op = random.randint(0, 1)
      opcode = branchOps[op]
      branchCommand('Branch', opcode, address, theFile)
      mathCommand('SUBS', SUBS, 31, 31, 31, theFile)
      lowAddress += 2
    else:
      farBack = -lowAddress + 2
      farForward = highestAddress - lowAddress - 2
      address = random.randint(farBack, farForward)
      op = random.randint(0, 1)
      opcode = condOps[op]
      randomRT = random.randint(0, 5)
      RT = condOpsSpecial[randomRT]
      RN = random.randint(0, 31)
      RM = random.randint(0, 31)
      
      mathCommand('SUBS', SUBS, 31, RM, RN, theFile)
      condBranchCommand('cond', opcode, address, RT, theFile)
      mathCommand('SUBS', SUBS, 31, 31, 31, theFile)
      lowAddress += 3
  
    #final infinite loop branch
  branchCommand('B', B, 0, theFile) #B. end
  mathCommand('SUBS', SUBS, 31, 31, 31, theFile)  
  
  theFile.close()

def mathCommand(name, opcode, RD, RM, RN, theFile):
  #generate the opcode
  #opcode = '100_0101_0000'
  
  #convert the inputs to binary
  zeroString = '00000'
  RMinBinary = "{0:b}".format(RM)
  RNinBinary = "{0:b}".format(RN)
  RDinBinary = "{0:b}".format(RD)
  
  #merge the string
  RMinBinary1 = zeroString + RMinBinary
  RNinBinary1 = zeroString + RNinBinary
  RDinBinary1 = zeroString + RDinBinary
  
  #get the lengths
  numRM = len(RMinBinary1)
  numRN = len(RNinBinary1)
  numRD = len(RDinBinary1)
   
  #strip them to the correct length
  numRM1 = numRM - 5
  numRN1 = numRN - 5
  numRD1 = numRD - 5
  RMcorrect = RMinBinary1[numRM1:]
  RNcorrect = RNinBinary1[numRN1:]
  RDcorrect = RDinBinary1[numRD1:]
  
  #assign SHAMT
  SHAMT = '000000'
  
  #combine for full command
  cmd = opcode + '_' + RMcorrect + '_' + SHAMT + '_' + RNcorrect + '_' + RDcorrect
  
  #write to file
  theFile.write('//' + name + '\n')
  theFile.write(cmd + '\n')
  
def shiftCommand(name, opcode, RD, SHAMT, RN, theFile):
  #generate the opcode
  #opcode = '100_0101_0000'
  
  #convert the inputs to binary
  zeroString = '00000'
  shiftString = '000000'
  SHAMTinBinary = "{0:b}".format(SHAMT)
  RNinBinary = "{0:b}".format(RN)
  RDinBinary = "{0:b}".format(RD)
  
  #merge the string
  SHAMTinBinary1 = shiftString + SHAMTinBinary
  RNinBinary1 = zeroString + RNinBinary
  RDinBinary1 = zeroString + RDinBinary
  
  #get the lengths
  numSHAMT = len(SHAMTinBinary1)
  numRN = len(RNinBinary1)
  numRD = len(RDinBinary1)
   
  #strip them to the correct length
  numSHAMT1 = numSHAMT - 6
  numRN1 = numRN - 5
  numRD1 = numRD - 5
  SHAMTcorrect = SHAMTinBinary1[numSHAMT1:]
  RNcorrect = RNinBinary1[numRN1:]
  RDcorrect = RDinBinary1[numRD1:]
  
  #assign RM
  RM = '00000'
  
  #combine for full command
  cmd = opcode + '_' + RM + '_' + SHAMTcorrect + '_' + RNcorrect + '_' + RDcorrect
  
  #write to file
  theFile.write('//' + name + '\n')
  theFile.write(cmd + '\n')
  
def memoryCommand(name, opcode, address, RD, RN, theFile):
  #generate the opcode
  #opcode = '100_0101_0000'
  
  #convert the inputs to binary
  zeroString = '00000'
  zeroStringLong = '000000000'
  oneString = '111111111'
  addressinBinary = "{0:b}".format(address)
  RNinBinary = "{0:b}".format(RN)
  RDinBinary = "{0:b}".format(RD)
  
  #merge the string
  if address < 0:
    negString = convertToNeg(addressinBinary[1:])
    addressinBinary1 = oneString + negString
  else:
    addressinBinary1 = zeroStringLong + addressinBinary
  RNinBinary1 = zeroString + RNinBinary
  RDinBinary1 = zeroString + RDinBinary
  
  #get the lengths
  numaddress = len(addressinBinary1)
  numRN = len(RNinBinary1)
  numRD = len(RDinBinary1)
   
  #strip them to the correct length
  numaddress1 = numaddress - 9
  numRN1 = numRN - 5
  numRD1 = numRD - 5
  addresscorrect = addressinBinary1[numaddress1:]
  RNcorrect = RNinBinary1[numRN1:]
  RDcorrect = RDinBinary1[numRD1:]
  
  #combine for full command
  cmd = opcode + '_' + addresscorrect + '_' + '00' + '_' + RNcorrect + '_' + RDcorrect
  
  #write to file
  theFile.write('//' + name + '\n')
  theFile.write(cmd + '\n')
  
def immediateCommand(name, opcode, immediate, RD, RN, theFile):
  #generate the opcode
  #opcode = '100_0101_0000'
  
  #convert the inputs to binary
  zeroString = '00000'
  zeroStringLong = '00000000000'
  oneString = '11111111111'
  immediateinBinary = "{0:b}".format(immediate)
  RNinBinary = "{0:b}".format(RN)
  RDinBinary = "{0:b}".format(RD)
  
  #merge the string
  if immediate < 0:
    negString = convertToNeg(immediateinBinary[1:])
    immediateinBinary1 = oneString + negString
  else:
    immediateinBinary1 = zeroStringLong + immediateinBinary
  RNinBinary1 = zeroString + RNinBinary
  RDinBinary1 = zeroString + RDinBinary
  
  #get the lengths
  numimmediate = len(immediateinBinary1)
  numRN = len(RNinBinary1)
  numRD = len(RDinBinary1)
   
  #strip them to the correct length
  numimmediate1 = numimmediate - 12
  numRN1 = numRN - 5
  numRD1 = numRD - 5
  immediatecorrect = immediateinBinary1[numimmediate1:]
  RNcorrect = RNinBinary1[numRN1:]
  RDcorrect = RDinBinary1[numRD1:]
  
  #combine for full command
  cmd = opcode + '_' + immediatecorrect + '_' + RNcorrect + '_' + RDcorrect
  
  #write to file
  theFile.write('//' + name + '\n')
  theFile.write(cmd + '\n')
  
def branchCommand(name, opcode, address, theFile):
  #generate the opcode
  #opcode = '100_1010_0000'
  
  #convert the inputs to binary
  zeroString = '00000000000000000000000000'
  oneString = '11111111111111111111111111'
  addressinBinary = "{0:b}".format(address)
  
  #merge the string
  if address < 0:
    negString = convertToNeg(addressinBinary[1:])
    addressinBinary1 = oneString + negString
  else:
    addressinBinary1 = zeroString + addressinBinary
  
  #get the lengths
  numaddress = len(addressinBinary1)
   
  #strip them to the correct length
  numaddress1 = numaddress - 26
  addresscorrect = addressinBinary1[numaddress1:]
  
  #combine for full command
  cmd = opcode + '_' + addresscorrect
  
  #write to file
  theFile.write('//' + name + '\n')
  theFile.write(cmd + '\n')
  
def condBranchCommand(name, opcode, address, RT, theFile):
  #generate the opcode
  #opcode = '100_1010_0000'
  
  #convert the inputs to binary
  zeroString = '0000000000000000000'
  oneString = '1111111111111111111'
  zeroStringShort = '00000'
  addressinBinary = "{0:b}".format(address)
  #RTinBinary = "{0:b}".format(RT)
  
  #merge the string
  if address < 0:
    negString = convertToNeg(addressinBinary[1:])
    addressinBinary1 = oneString + negString
  else:
    addressinBinary1 = zeroString + addressinBinary
  #RTinBinary1 = zeroStringShort + RTinBinary
  
  #get the lengths
  numaddress = len(addressinBinary1)
  #numRT = len(RTinBinary1)
   
  #strip them to the correct length
  numaddress1 = numaddress - 19
  #numRT1 = numRT - 5
  addresscorrect = addressinBinary1[numaddress1:]
  #RTcorrect = RTinBinary1[numRT1:]
  
  #combine for full command
  cmd = opcode + '_' + addresscorrect + RT
  
  #write to file
  theFile.write('//' + name + '\n')
  theFile.write(cmd + '\n')
  
def convertToNeg(input):
  #invert the string
  newString = []
  
  for i in range(0, len(input)):
    if(input[(len(input) - 1) - i] == '0'):
      newString.append('1')
    else:
      newString.append('0')

      
  #add the 1
  carryin = 1
  for i in range(0, len(input)):
    if(newString[i] == '0' and carryin == 0):
      newString[i] = '0'
      carryin = 0
    elif (newString[i] == '1' and carryin == 0):
      newString[i] = '1'
      carryin = 0
    elif(newString[i] == '0' and carryin == 1):
      newString[i] = '1'
      carryin = 0
    else:
      newString[i] = '0'
      carryin = 1
      
      
  returnString = ""
  for i in range(0, len(input)):
    returnString = newString[i] + returnString
  #print(returnString)    
  return returnString
      
  
if __name__=='__main__':
    main()   
