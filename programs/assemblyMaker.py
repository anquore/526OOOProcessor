import math
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

'''
#general program format
#clear the file
theFile = open('PROGRAM_NAME.arm','w')
theFile.write("//Starting assembly\n")
theFile.close()

#open the file to append
theFile = open('PROGRAM_NAME.arm','a')

#YOUR PROGRAM COMMANDS

#infinite final loop
branchCommand('B', B, 0, theFile)#96
mathCommand('SUB', SUB, 31, 31, 31, theFile)
'''

def main():
  '''
  #clear the file
  theFile = open('testing.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('testing.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 1, 0, 31, theFile)
  immediateCommand('ADDI', ADDI, 5, 1, 31, theFile)
  immediateCommand('ADDI', ADDI, 8, 2, 31, theFile)
  
  #do the following math
  mathCommand('AND', AND, 3, 2, 1, theFile)
  mathCommand('ADD', ADD, 4, 2, 1, theFile)
  mathCommand('ADDS', ADDS, 5, 2, 1, theFile)
  mathCommand('SUB', SUB, 6, 2, 1, theFile)
  mathCommand('SUBS', SUBS, 7, 2, 1, theFile)
  mathCommand('OR', OR, 8, 2, 1, theFile)
  mathCommand('XOR', XOR, 9, 2, 1, theFile)
  
  #do some memory work
  #memoryCommand('STUR', STUR, 0, 0, 31, theFile)
  #memoryCommand('STUR', STUR, 8, 1, 31, theFile)
  #memoryCommand('LDUR', LDUR, 8, 16, 31, theFile)
  #memoryCommand('LDUR', LDUR, 0, 15, 31, theFile)
  
  #branch testing
  #R1 > R0, success
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('GT', BCOND, 4, GT, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile) #17 * 4 = 68
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #72
  
  #R0 > R1 fail
  mathCommand('SUBS', SUBS, 31, 1, 0, theFile) #76
  condBranchCommand('GT', BCOND, -3, GT, theFile) #80
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #84
  
  
  #R0 < R1, success
  mathCommand('SUBS', SUBS, 31, 1, 0, theFile)
  condBranchCommand('LT', BCOND, 4, LT, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R1 < R0 fail
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('LT', BCOND, -3, LT, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  
  #R1 >= R0, success
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('GE', BCOND, 4, GE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R6 >= R7 success
  mathCommand('SUBS', SUBS, 31, 6, 7, theFile)
  condBranchCommand('GE', BCOND, 4, GE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R0 >= R1 fail
  mathCommand('SUBS', SUBS, 31, 1, 0, theFile)
  condBranchCommand('GT', BCOND, -3, GE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R0 <= R1, success
  mathCommand('SUBS', SUBS, 31, 1, 0, theFile)
  condBranchCommand('LE', BCOND, 4, LE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile) #184/188
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R6 >= R7 success
  mathCommand('SUBS', SUBS, 31, 6, 7, theFile)
  condBranchCommand('LE', BCOND, 4, LE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R1 <= R0 fail
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('LE', BCOND, -3, LE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R6 == R7 success
  mathCommand('SUBS', SUBS, 31, 6, 7, theFile)
  condBranchCommand('EQ', BCOND, 4, EQ, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R1 == R0 fail
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('EQ', BCOND, -3, EQ, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R1 != R0 success
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('NE', BCOND, 4, NE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R6 == R7 fail
  mathCommand('SUBS', SUBS, 31, 7, 6, theFile)
  condBranchCommand('NE', BCOND, -3, NE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #testing shifts
  shiftCommand('LSL', LSL, 10, 3, 1, theFile)#69, 272
  shiftCommand('LSR', LSR, 11, 3, 10, theFile)
  
  #testing multiply
  #send one multiply then an add
  mathCommand('MULT', MULT, 20, 7, 6, theFile) #280
  mathCommand('ADD', ADD, 21, 5, 4, theFile)
  
  #send two multiples then a subs
  mathCommand('MULT', MULT, 22, 7, 6, theFile)#never see, #288
  mathCommand('MULT', MULT, 23, 5, 4, theFile)
  mathCommand('SUBS', SUBS, 31, 6, 7, theFile)
  
  #do a multiply then a branch
  mathCommand('MULT', MULT, 24, 5, 6, theFile)
  condBranchCommand('EQ', BCOND, 4, EQ, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #do an add to check branch happened
  mathCommand('ADD', ADD, 25, 5, 4, theFile)
  
  #check some forwarding
  mathCommand('MULT', MULT, 20, 5, 4, theFile)
  mathCommand('ADD', ADD, 21, 20, 4, theFile)
  mathCommand('ADD', ADD, 22, 5, 20, theFile)
  
  mathCommand('ADD', ADD, 23, 2, 1, theFile)
  mathCommand('MULT', MULT, 24, 23, 4, theFile) #340
  mathCommand('MULT', MULT, 26, 5, 23, theFile)
  
  
  #testing divide
  mathCommand('DIV', DIV, 12, 23, 24, theFile)
  mathCommand('ADD', ADD, 13, 5, 4, theFile)
  
  #send two multiples then a subs
  mathCommand('DIV', DIV, 14, 7, 6, theFile)
  mathCommand('DIV', DIV, 15, 5, 4, theFile)
  mathCommand('SUBS', SUBS, 31, 6, 7, theFile)
  
  #do a multiply then a branch
  mathCommand('DIV', DIV, 16, 5, 6, theFile)
  condBranchCommand('EQ', BCOND, 4, EQ, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #do an add to check branch happened
  mathCommand('ADD', ADD, 17, 5, 4, theFile)
  
  #check some forwarding
  mathCommand('DIV', DIV, 12, 5, 4, theFile)
  mathCommand('ADD', ADD, 13, 12, 4, theFile)
  mathCommand('ADD', ADD, 14, 5, 12, theFile)
  
  mathCommand('ADD', ADD, 15, 2, 1, theFile)
  mathCommand('DIV', DIV, 16, 15, 4, theFile) #408
  mathCommand('DIV', DIV, 18, 5, 15, theFile)#412
  
  #halt
  branchCommand('B', B, 0, theFile)#416
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  
  '''
  '''
  #ROB stalling testing and basic out of order test
  #clear the file
  theFile = open('ROB_stall_test_and_basic_OOO.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('ROB_stall_test_and_basic_OOO.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 1000, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, 3, 1, 31, theFile) #4
  immediateCommand('ADDI', ADDI, 8, 2, 31, theFile)#8
   
  #do the following math
  mathCommand('DIV', DIV, 12, 1, 0, theFile)#12
  mathCommand('AND', AND, 3, 2, 1, theFile)#16
  mathCommand('ADD', ADD, 4, 2, 1, theFile)#20
  mathCommand('ADDS', ADDS, 5, 2, 1, theFile)#24
  mathCommand('SUB', SUB, 6, 2, 1, theFile)#28
  mathCommand('SUBS', SUBS, 7, 2, 1, theFile)#32
  mathCommand('OR', OR, 8, 2, 1, theFile)#36
  mathCommand('XOR', XOR, 9, 2, 1, theFile)#40
  mathCommand('OR', OR, 10, 2, 1, theFile)#44
  mathCommand('XOR', XOR, 11, 2, 1, theFile)#48
  
  #test some stores/loads
  mathCommand('MULT', MULT, 15, 1, 0, theFile)#52
  memoryCommand('STUR', STUR, 0, 10, 3, theFile)#56
  memoryCommand('STUR', STUR, 0, 11, 2, theFile)#60
  memoryCommand('LDUR', LDUR, 0, 12, 3, theFile)#64
  memoryCommand('LDUR', LDUR, 0, 13, 2, theFile)#68
  
  #test branching
  immediateCommand('ADDI', ADDI, 1000, 1, 31, theFile)#72
  immediateCommand('ADDI', ADDI, 3, 0, 31, theFile)#76
  mathCommand('DIV', DIV, 16, 1, 0, theFile)#80
  #R1 > R0, success
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)#84
  condBranchCommand('GT', BCOND, 4, GT, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile) #17 * 4 = 68
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #72
  
  #R0 > R1 fail
  mathCommand('DIV', DIV, 16, 1, 0, theFile)
  mathCommand('SUBS', SUBS, 31, 1, 0, theFile) #76
  condBranchCommand('GT', BCOND, -3, GT, theFile) #80
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #84
  
  
  #R0 < R1, success
  mathCommand('SUBS', SUBS, 31, 1, 0, theFile)
  condBranchCommand('LT', BCOND, 4, LT, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R1 < R0 fail
  mathCommand('DIV', DIV, 16, 1, 0, theFile)
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('LT', BCOND, -3, LT, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  
  #R1 >= R0, success
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('GE', BCOND, 4, GE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R6 >= R7 success
  mathCommand('DIV', DIV, 16, 1, 0, theFile)
  mathCommand('SUBS', SUBS, 31, 6, 7, theFile)
  condBranchCommand('GE', BCOND, 4, GE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R0 >= R1 fail
  mathCommand('SUBS', SUBS, 31, 1, 0, theFile)
  condBranchCommand('GT', BCOND, -3, GE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R0 <= R1, success
  mathCommand('DIV', DIV, 16, 1, 0, theFile)
  mathCommand('SUBS', SUBS, 31, 1, 0, theFile)
  condBranchCommand('LE', BCOND, 4, LE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile) #184/188
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R6 >= R7 success
  mathCommand('SUBS', SUBS, 31, 6, 7, theFile)
  condBranchCommand('LE', BCOND, 4, LE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R1 <= R0 fail
  mathCommand('DIV', DIV, 16, 1, 0, theFile)
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('LE', BCOND, -3, LE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R6 == R7 success
  mathCommand('SUBS', SUBS, 31, 6, 7, theFile)
  condBranchCommand('EQ', BCOND, 4, EQ, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R1 == R0 fail
  mathCommand('DIV', DIV, 16, 1, 0, theFile)
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('EQ', BCOND, -3, EQ, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R1 != R0 success
  mathCommand('SUBS', SUBS, 31, 0, 1, theFile)
  condBranchCommand('NE', BCOND, 4, NE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #fail branch
  branchCommand('B', B, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #R6 == R7 fail
  mathCommand('DIV', DIV, 16, 1, 0, theFile)
  mathCommand('SUBS', SUBS, 31, 7, 6, theFile)
  condBranchCommand('NE', BCOND, -3, NE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #BL and BR test
  branchCommand('BL', BL, 2, theFile)#288
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('ADDI', ADD, 16, 30, 30, theFile)
  mathCommand('BR', BR, 30, 0, 0, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #halt
  branchCommand('B', B, 0, theFile)#288
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  '''
  
  '''
  #multiplication/divide test
  #clear the file
  theFile = open('multAndDiv.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('multAndDiv.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, -1, 1, 31, theFile) #1
  immediateCommand('ADDI', ADDI, 23, 2, 31, theFile) #2
  immediateCommand('ADDI', ADDI, 6, 3, 31, theFile) #3
  immediateCommand('ADDI', ADDI, -37, 4, 31, theFile) #4
  immediateCommand('ADDI', ADDI, -3, 5, 31, theFile) #5
  
  #multiplication tests
  mathCommand('MULT', MULT, 8, 0, 0, theFile) #0*0 = 0
  mathCommand('MULT', MULT, 9, 1, 1, theFile) #-1*-1=1
  mathCommand('MULT', MULT, 10, 2, 3, theFile) #23*6 = 138
  mathCommand('MULT', MULT, 11, 3, 5, theFile) #6*-3 = 18
  mathCommand('MULT', MULT, 12, 5, 3, theFile) #-3*6=-18
  mathCommand('MULT', MULT, 13, 4, 5, theFile)#-37*-3 = 111
  
  
  #divide tests
  mathCommand('DIV', DIV, 14, 3, 2, theFile) #23/6 = 3
  mathCommand('DIV', DIV, 15, 5, 2, theFile) #23/-3 = -7
  mathCommand('DIV', DIV, 16, 3, 4, theFile) #-37/6=-6
  mathCommand('DIV', DIV, 17, 5, 4, theFile)#-37/-3 = 12
  
  mathCommand('DIV', DIV, 18, 2, 3, theFile) #=0
  mathCommand('DIV', DIV, 19, 2, 5, theFile) #=0
  mathCommand('DIV', DIV, 20, 4, 3, theFile) #=0, instr 72
  mathCommand('DIV', DIV, 21, 4, 3, theFile)#=0
  
  mathCommand('DIV', DIV, 22, 2, 2, theFile) #=1
  mathCommand('DIV', DIV, 23, 3, 3, theFile) #=1
  mathCommand('DIV', DIV, 24, 4, 4, theFile) #=1
  mathCommand('DIV', DIV, 25, 4, 4, theFile)#=1
  
  
  #a bunch of mixed up divides and multiplies
  mathCommand('MULT', MULT, 6, 4, 5, theFile) #0*0 = 0
  mathCommand('MULT', MULT, 7, 10, 11, theFile) #-1*-1=1
  mathCommand('DIV', DIV, 4, 7, 9, theFile) #23/6 = 3
  mathCommand('MULT', MULT, 1, 9, 12, theFile) #23/-3 = -7
  mathCommand('DIV', DIV, 8, 6, 4, theFile) #-37/6=-6
  mathCommand('MULT', MULT, 10, 5, 8, theFile)#-37/-3 = 12
  mathCommand('DIV', DIV, 2, 3, 3, theFile) #23/6 = 3
  mathCommand('MULT', MULT, 10, 11, 12, theFile) #23/-3 = -7
  mathCommand('DIV', DIV, 5, 10, 4, theFile) #-37/6=-6
  mathCommand('MULT', MULT, 6, 5, 8, theFile)#-37/-3 = 12
  
  #halt
  branchCommand('B', B, 0, theFile)#288
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #RS filling test
  #clear the file
  theFile = open('RS_filling.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('RS_filling.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, -1, 1, 31, theFile) #1
  immediateCommand('ADDI', ADDI, 23, 2, 31, theFile) #2
  immediateCommand('ADDI', ADDI, 6, 3, 31, theFile) #3
  immediateCommand('ADDI', ADDI, -37, 4, 31, theFile) #4
  immediateCommand('ADDI', ADDI, -3, 5, 31, theFile) #5
  
  #test the RS forwarding
  mathCommand('ADD', ADD, 20, 0, 1, theFile)
  mathCommand('ADD', ADD, 21, 20, 1, theFile)
  mathCommand('ADD', ADD, 22, 20, 1, theFile)
  mathCommand('ADD', ADD, 23, 20, 1, theFile)
  
  #check memory forwarding
  memoryCommand('STUR', STUR, 0, 20, 0, theFile)#16
  memoryCommand('LDUR', LDUR, 0, 24, 0, theFile)#16
  mathCommand('ADD', ADD, 25, 24, 1, theFile)
  mathCommand('ADD', ADD, 26, 24, 1, theFile)
  mathCommand('ADD', ADD, 27, 24, 1, theFile)
  
  #try to fill up the different RS's
  #divide tests
  mathCommand('DIV', DIV, 14, 3, 2, theFile) #23/6 = 3
  mathCommand('DIV', DIV, 15, 5, 2, theFile) #23/-3 = -7
  mathCommand('DIV', DIV, 16, 3, 4, theFile) #-37/6=-6
  
  #multiplication tests
  mathCommand('MULT', MULT, 8, 0, 0, theFile) #0*0 = 0
  mathCommand('MULT', MULT, 9, 8, 1, theFile) 
  mathCommand('MULT', MULT, 10, 9, 3, theFile) 
  
  #shift tests
  shiftCommand('LSL', LSL, 18, 6, 10, theFile)
  shiftCommand('LSR', LSR, 19, 9, 10, theFile)
  
  #additions
  mathCommand('ADD', ADD, 13, 14, 4, theFile)#-34
  mathCommand('ADD', ADD, 14, 5, 14, theFile)#0
  mathCommand('ADD', ADD, 31, 14, 4, theFile)#-34
  mathCommand('ADD', ADD, 31, 5, 14, theFile)#0
  
  #do a bunch of interlinking of different RS's forwarding values
  mathCommand('DIV', DIV, 10, 13, 2, theFile) #23/-34 = 0
  mathCommand('ADD', ADD, 16, 10, 4, theFile) #-37
  mathCommand('MULT', MULT, 9, 10, 1, theFile)#0
  shiftCommand('LSL', LSL, 18, 6, 10, theFile)#0
  
  mathCommand('MULT', MULT, 10, 9, 18, theFile)#0
  mathCommand('DIV', DIV, 12, 13, 10, theFile)#0
  mathCommand('ADD', ADD, 13, 14, 10, theFile)#0
  
  mathCommand('DIV', DIV, 10, 13, 2, theFile)#-1 divided by 0
  shiftCommand('LSR', LSR, 18, 6, 13, theFile)#0
  mathCommand('MULT', MULT, 9, 10, 13, theFile)#0

  mathCommand('ADD', ADD, 16, 9, 4, theFile) #-37
  mathCommand('DIV', DIV, 10, 9, 2, theFile) #-1
  shiftCommand('LSL', LSL, 18, 6, 9, theFile)#0

  
  #additions
  mathCommand('ADD', ADD, 13, 14, 4, theFile)#-37
  mathCommand('ADD', ADD, 14, 5, 14, theFile)#-3
  
  #halt
  branchCommand('B', B, 0, theFile)#288
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #map table testing, reg renaming
  #clear the file
  theFile = open('MT_reg_renaming.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('MT_reg_renaming.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, -1, 1, 31, theFile) #1
  immediateCommand('ADDI', ADDI, 23, 2, 31, theFile) #2
  immediateCommand('ADDI', ADDI, 6, 3, 31, theFile) #3
  
  #send in a slow command
  mathCommand('DIV', DIV, 12, 3, 2, theFile)
  
  #have two read after writes hazards
  mathCommand('AND', AND, 3, 12, 1, theFile)
  mathCommand('ADD', ADD, 4, 12, 1, theFile)
  
  #have a write after read hazard, fairly slow
  mathCommand('MULT', MULT, 1, 2, 2, theFile)
  
  mathCommand('MULT', MULT, 1, 12, 2, theFile)
  
  #have a RAW hazard on that
  mathCommand('SUB', SUB, 6, 2, 1, theFile)
  
  #have a WAW
  mathCommand('SUBS', SUBS, 1, 2, 3, theFile)
  
  
  #make sure MT reset is working
  mathCommand('AND', AND, 15, 2, 3, theFile)#16
  mathCommand('ADD', ADD, 16, 2, 3, theFile)#20
  mathCommand('ADD', ADD, 16, 2, 3, theFile)#20
  mathCommand('ADDS', ADDS, 17, 2, 3, theFile)#24
  mathCommand('SUB', SUB, 18, 2, 3, theFile)#28
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUBS', SUBS, 15, 2, 3, theFile)#32
  mathCommand('OR', OR, 20, 15, 3, theFile)#36
  
  #halt
  branchCommand('B', B, 0, theFile)#288
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #shift testing
  #clear the file
  theFile = open('shifting.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('shifting.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, -1, 1, 31, theFile) #1
  immediateCommand('ADDI', ADDI, 23, 2, 31, theFile) #2
  immediateCommand('ADDI', ADDI, 6, 3, 31, theFile) #3
  
  #shift some stuff left
  shiftCommand('LSL', LSL, 4, 3, 2, theFile)
  shiftCommand('LSL', LSL, 5, 10, 1, theFile)
  shiftCommand('LSL', LSL, 7, 15, 0, theFile)
  shiftCommand('LSL', LSL, 8, 63, 1, theFile)
  
  #shift some stuff right
  shiftCommand('LSR', LSR, 9, 3, 2, theFile)
  shiftCommand('LSR', LSR, 10, 10, 1, theFile)
  shiftCommand('LSR', LSR, 11, 15, 2, theFile)
  shiftCommand('LSR', LSR, 12, 63, 8, theFile)
  
  #halt
  branchCommand('B', B, 0, theFile)#288
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #shift testing
  #clear the file
  theFile = open('branchTest.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('branchTest.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, -1, 1, 31, theFile) #1
  immediateCommand('ADDI', ADDI, 23, 2, 31, theFile) #2
  immediateCommand('ADDI', ADDI, 6, 3, 31, theFile) #3
  
  #send a not taken branch
  #R2 <= R1 fail
  mathCommand('SUBS', SUBS, 31, 1, 2, theFile)
  condBranchCommand('LE', BCOND, -5, LE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #send a taken branch
  mathCommand('SUBS', SUBS, 31, 2, 1, theFile)
  condBranchCommand('LE', BCOND, -8, LE, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  '''
  '''
  #clear the file
  theFile = open('factorizer.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('factorizer.arm','a')
  
  immediateCommand('ADDI', ADDI, 1, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, 45, 1, 31, theFile) #4
  immediateCommand('ADDI', ADDI, 0, 10, 31, theFile) #8
  
  #eachLoop
  immediateCommand('ADDI', ADDI, 1, 0, 0, theFile) #0
  
  #eachLoopFound
  mathCommand('DIV', DIV, 29, 0, 1, theFile)#12
  mathCommand('MULT', MULT, 30, 29, 0, theFile)#16
  #immediateCommand('ADDI', ADDI, 1, 0, 0, theFile) #20
  mathCommand('SUBS', SUBS, 31, 1, 30, theFile)#24
  
  #branch to each loop
  condBranchCommand('LT', BCOND, -4, LT, theFile)#28
  mathCommand('SUB', SUB, 31, 31, 31, theFile)#32
  
  memoryCommand('STUR', STUR, 0, 0, 10, theFile)#36
  immediateCommand('ADDI', ADDI, 8, 10, 10, theFile) #40
  immediateCommand('ADDI', ADDI, 0, 1, 29, theFile) #44
  immediateCommand('ADDI', ADDI, 1, 29, 31, theFile) #48
  mathCommand('SUBS', SUBS, 31, 1, 29, theFile)#52

  #branch to each loop
  condBranchCommand('LT', BCOND, -10, LT, theFile)#56
  mathCommand('SUB', SUB, 31, 31, 31, theFile)#60
  #halt
  branchCommand('B', B, 0, theFile)#288
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #clear the file
  theFile = open('memIter.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('memIter.arm','a')
  
  immediateCommand('ADDI', ADDI, 1, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, 256, 1, 31, theFile) #4
  immediateCommand('ADDI', ADDI, 16, 25, 31, theFile) #8
  immediateCommand('ADDI', ADDI, 16, 10, 31, theFile) #12
  
  #setLoop:
  memoryCommand('STUR', STUR, 0, 1, 10, theFile)#16
  immediateCommand('ADDI', ADDI, 1, 0, 0, theFile) #20
  immediateCommand('ADDI', ADDI, 2, 1, 1, theFile) #24
  immediateCommand('ADDI', ADDI, 8, 10, 10, theFile) #28
  mathCommand('SUBS', SUBS, 31, 25, 0, theFile)#32
  condBranchCommand('LT', BCOND, -5, LT, theFile)#36
  mathCommand('SUB', SUB, 31, 31, 31, theFile)#40

  immediateCommand('ADDI', ADDI, 1, 0, 31, theFile) #44
  immediateCommand('ADDI', ADDI, 16, 10, 31, theFile) #48
  
  #incrLoop:
  memoryCommand('LDUR', LDUR, 0, 1, 10, theFile)#52
  immediateCommand('ADDI', ADDI, 16, 1, 1, theFile) #56
  memoryCommand('STUR', STUR, 0, 1, 10, theFile)#60
  immediateCommand('ADDI', ADDI, 1, 0, 0, theFile) #64
  mathCommand('SUBS', SUBS, 31, 25, 0, theFile)#68
  condBranchCommand('LT', BCOND, -5, LT, theFile)#72
  mathCommand('SUB', SUB, 31, 31, 31, theFile)#76

  immediateCommand('ADDI', ADDI, 1, 0, 31, theFile) #80
  immediateCommand('ADDI', ADDI, 16, 10, 31, theFile) #84

  #incrShift:
  memoryCommand('LDUR', LDUR, 0, 1, 10, theFile)#88
  memoryCommand('STUR', STUR, -8, 1, 10, theFile)#92
  immediateCommand('ADDI', ADDI, 1, 0, 0, theFile) #96
  immediateCommand('ADDI', ADDI, 8, 10, 10, theFile) #100
  mathCommand('SUBS', SUBS, 31, 25, 0, theFile)#104
  condBranchCommand('LT', BCOND, -5, LT, theFile)#108
  mathCommand('SUB', SUB, 31, 31, 31, theFile)#112

  #halt
  branchCommand('B', B, 0, theFile)#116
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #120
  '''
  '''
  #clear the file
  theFile = open('memThrash.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('memThrash.arm','a')
  
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, 256, 1, 31, theFile) #4
  immediateCommand('ADDI', ADDI, 528, 25, 31, theFile) #8
  immediateCommand('ADDI', ADDI, 64, 26, 31, theFile) #12
  immediateCommand('ADDI', ADDI, 16, 10, 31, theFile) #16
  
  #setLoop:
  memoryCommand('STUR', STUR, 0, 1, 10, theFile)#20
  immediateCommand('ADDI', ADDI, 2, 1, 1, theFile) #24
  immediateCommand('ADDI', ADDI, 8, 10, 10, theFile) #28
  mathCommand('SUBS', SUBS, 31, 25, 10, theFile)#32
  condBranchCommand('LT', BCOND, -4, LT, theFile)#36
  mathCommand('SUB', SUB, 31, 31, 31, theFile)#40
  
  immediateCommand('ADDI', ADDI, 16, 10, 31, theFile) #44

  #incrNextNumb:
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile) #48

  #incrPartNumb:
  memoryCommand('LDUR', LDUR, 0, 1, 10, theFile)#52
  immediateCommand('ADDI', ADDI, -1, 1, 1, theFile) #56
  memoryCommand('STUR', STUR, 0, 1, 10, theFile)#60
  immediateCommand('ADDI', ADDI, 1, 0, 0, theFile) #64
  mathCommand('SUBS', SUBS, 31, 26, 0, theFile)#68
  condBranchCommand('LT', BCOND, -5, LT, theFile)#72
  mathCommand('SUB', SUB, 31, 31, 31, theFile)#76

  immediateCommand('ADDI', ADDI, 8, 10, 10, theFile) #80
  mathCommand('SUBS', SUBS, 31, 25, 10, theFile)#84
  condBranchCommand('LT', BCOND, -10, LT, theFile)#88
  mathCommand('SUB', SUB, 31, 31, 31, theFile)#92

  #halt
  branchCommand('B', B, 0, theFile)#96
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #clear the file
  theFile = open('ALUloop.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('ALUloop.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 1000, 1, 31, theFile)
  immediateCommand('ADDI', ADDI, 3, 2, 31, theFile)
  
  #do the following math
  mathCommand('DIV', DIV, 12, 2, 1, theFile)
  mathCommand('ADD', ADD, 31, 31, 31, theFile)
  mathCommand('ADD', ADD, 3, 12, 31, theFile)
  mathCommand('ADD', ADD, 4, 3, 31, theFile)
  
  branchCommand('B', B, 0, theFile)#96
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #clear the file
  theFile = open('moreOOO.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('moreOOO.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 34, 0, 31, theFile)
  immediateCommand('ADDI', ADDI, 3556, 1, 31, theFile)
  immediateCommand('ADDI', ADDI, 142, 2, 31, theFile)
  
  #do the following math
  mathCommand('MULT', MULT, 12, 1, 0, theFile) #18360
  mathCommand('AND', AND, 3, 2, 12, theFile) #8
  mathCommand('ADD', ADD, 4, 2, 1, theFile) #-398
  shiftCommand('LSL', LSL, 5, 6, 2, theFile) #9088
  mathCommand('SUB', SUB, 6, 2, 5, theFile) #8946
  
  #do more math
  mathCommand('DIV', DIV, 13, 1, 12, theFile) #34
  mathCommand('SUBS', SUBS, 7, 2, 1, theFile) #-682
  mathCommand('OR', OR, 8, 2, 4, theFile)
  memoryCommand('STUR', STUR, 0, 0, 13, theFile)             #44
  memoryCommand('STUR', STUR, 8, 4, 0, theFile)
  immediateCommand('ADDI', ADDI, 34, 10, 31, theFile)
  memoryCommand('LDUR', LDUR, 8, 10, 0, theFile) #-398
  memoryCommand('LDUR', LDUR, 0, 20, 13, theFile) #34
  mathCommand('OR', OR, 10, 2, 1, theFile)
  mathCommand('XOR', XOR, 11, 2, 1, theFile)
  
  #do even more math
  mathCommand('MULT', MULT, 15, 8, 0, theFile) #-8772
  mathCommand('XOR', XOR, 3, 15, 12, theFile) #
  mathCommand('ADD', ADD, 23, 2, 1, theFile) #-398
  shiftCommand('LSR', LSR, 21, 3, 3, theFile)#3262
  mathCommand('SUB', SUB, 6, 2, 15, theFile)#-8914
  mathCommand('SUB', SUB, 24, 2, 1, theFile)#-682
  
  #do even more math
  mathCommand('DIV', DIV, 24, 4, 5, theFile)#-22
  shiftCommand('LSR', LSR, 26, 3, 24, theFile) #should be large
  shiftCommand('LSR', LSR, 27, 4, 24, theFile)
  immediateCommand('ADDI', ADDI, 34, 30, 31, theFile)#34
  mathCommand('OR', OR, 12, 2, 1, theFile)#should match 10/11
  mathCommand('XOR', XOR, 13, 2, 1, theFile)
  shiftCommand('LSL', LSR, 27, 4, 24, theFile)
  
  branchCommand('B', B, 0, theFile)#96
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #clear the file
  theFile = open('LSQtesting.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('LSQtesting.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile)
  immediateCommand('ADDI', ADDI, 1, 1, 31, theFile)
  immediateCommand('ADDI', ADDI, 2, 2, 31, theFile)
  immediateCommand('ADDI', ADDI, 3, 3, 31, theFile)
  
  #3 stores then loads, no issues
  memoryCommand('STUR', STUR, 0, 1, 0, theFile)             
  memoryCommand('STUR', STUR, 8, 2, 0, theFile)
  memoryCommand('STUR', STUR, 16, 3, 0, theFile)
  memoryCommand('LDUR', LDUR, 0, 4, 0, theFile)             
  memoryCommand('LDUR', LDUR, 8, 5, 0, theFile)
  memoryCommand('LDUR', LDUR, 16, 6, 0, theFile) #36
  
  #2 stores then load, no forwarding triggers flush
  immediateCommand('ADDI', ADDI, 4, 1, 31, theFile) #40
  immediateCommand('ADDI', ADDI, 5, 2, 31, theFile) #44
  memoryCommand('STUR', STUR, 0, 1, 0, theFile)       #48      
  memoryCommand('STUR', STUR, 8, 2, 0, theFile)       #52
  memoryCommand('LDUR', LDUR, 0, 7, 0, theFile)       #56   
  memoryCommand('LDUR', LDUR, 8, 8, 0, theFile)  #ROB 16, #60
  
  #1 store then 1 load, triggers flush if no forwarding
  immediateCommand('ADDI', ADDI, 6, 1, 31, theFile) #64
  memoryCommand('STUR', STUR, 0, 1, 0, theFile)     #68     
  memoryCommand('LDUR', LDUR, 0, 9, 0, theFile)     #72     
  
  #stalling should always flush
  mathCommand('MULT', MULT, 10, 3, 3, theFile) #76
  memoryCommand('STUR', STUR, 0, 10, 0, theFile) #80           
  memoryCommand('LDUR', LDUR, 0, 11, 0, theFile) #84
  
  #setup up a very slow command
  mathCommand('DIV', DIV, 25, 3, 3, theFile)
  #do a bunch of stores
  memoryCommand('STUR', STUR, 24, 1, 0, theFile)             
  memoryCommand('STUR', STUR, 32, 2, 0, theFile)
  memoryCommand('STUR', STUR, 40, 3, 0, theFile)
  memoryCommand('STUR', STUR, 48, 4, 0, theFile)             
  memoryCommand('STUR', STUR, 56, 5, 0, theFile)
  memoryCommand('STUR', STUR, 64, 6, 0, theFile)
  memoryCommand('STUR', STUR, 72, 7, 0, theFile)             
  memoryCommand('STUR', STUR, 80, 8, 0, theFile)
  
  #do a bunch of loads
  memoryCommand('LDUR', LDUR, 24, 11, 0, theFile)             
  memoryCommand('LDUR', LDUR, 32, 12, 0, theFile)
  memoryCommand('LDUR', LDUR, 40, 13, 0, theFile)
  memoryCommand('LDUR', LDUR, 48, 14, 0, theFile)             
  memoryCommand('LDUR', LDUR, 56, 15, 0, theFile)
  memoryCommand('LDUR', LDUR, 64, 16, 0, theFile)
  memoryCommand('LDUR', LDUR, 72, 17, 0, theFile)             
  memoryCommand('LDUR', LDUR, 80, 18, 0, theFile)
  
  #clear out the queue
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  mathCommand('SUB', SUB, 31, 31, 31, theFile)
  
  #do a load
  memoryCommand('LDUR', LDUR, 0, 20, 0, theFile) 
  
  
  #have activity at all 3 ports of LSQ
  
  
  branchCommand('B', B, 0, theFile)#96
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #clear the file
  theFile = open('RS_filling2.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('RS_filling2.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, -1, 1, 31, theFile) #1
  immediateCommand('ADDI', ADDI, 23, 2, 31, theFile) #2
  
  #check the RS sends values out in the correct order
  mathCommand('MULT', MULT, 3, 1, 2, theFile)
  mathCommand('ADD', ADD, 20, 3, 0, theFile)
  mathCommand('ADD', ADD, 21, 3, 1, theFile)
  mathCommand('ADD', ADD, 22, 3, 2, theFile)
  mathCommand('ADD', ADD, 23, 3, 3, theFile)
  
  mathCommand('ADD', ADD, 25, 1, 1, theFile)
  mathCommand('ADD', ADD, 26, 2, 2, theFile)
  mathCommand('ADD', ADD, 27, 0, 0, theFile)
  
  mathCommand('MULT', MULT, 4, 20, 2, theFile)
  mathCommand('MULT', MULT, 5, 21, 2, theFile)
  mathCommand('MULT', MULT, 6, 22, 2, theFile)
  
  mathCommand('ADD', ADD, 31, 31, 31, theFile)
  mathCommand('ADD', ADD, 31, 31, 31, theFile)
  shiftCommand('LSR', LSR, 7, 3, 20, theFile) #should be large
  shiftCommand('LSL', LSL, 8, 4, 21, theFile)
  shiftCommand('LSR', LSR, 9, 3, 22, theFile)
  
  branchCommand('B', B, 0, theFile)#96
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  '''
  '''
  #clear the file
  theFile = open('branchDelaySlotTest.arm','w')
  theFile.write("//Starting assembly\n")
  theFile.close()
  
  #open the file to append
  theFile = open('branchDelaySlotTest.arm','a')
  
  #setup some starting variables
  immediateCommand('ADDI', ADDI, 0, 0, 31, theFile) #0
  immediateCommand('ADDI', ADDI, 10, 1, 31, theFile) #4
  immediateCommand('ADDI', ADDI, 9, 2, 31, theFile) #8
  immediateCommand('ADDI', ADDI, 20, 3, 31, theFile) #12
  immediateCommand('ADDI', ADDI, 10, 4, 31, theFile) #16
  
  
  #failure tester
  mathCommand('SUBS', SUBS, 31, 1, 0, theFile)#20
  condBranchCommand('BCOND', BCOND, 5, GE, theFile)#24
  immediateCommand('ADDI', ADDI, 1, 0, 0, theFile)#28
  
  mathCommand('SUBS', SUBS, 31, 0, 4, theFile)
  condBranchCommand('BCOND', BCOND, -4, GT, theFile)
  mathCommand('ADD', ADD, 31, 31, 31, theFile)
  
  immediateCommand('ADDI', ADDI, 1, 2, 2, theFile)
  mathCommand('SUBS', SUBS, 31, 3, 2, theFile)
  condBranchCommand('BCOND', BCOND, -8, LT, theFile)
  mathCommand('ADD', ADD, 31, 31, 31, theFile)
  
  branchCommand('B', B, 0, theFile)#96
  mathCommand('SUB', SUB, 31, 31, 31, theFile) #100
  #zero should be 20
  #one is 10
  #2 is 20
  #3 is 20
  #4 is 10
  '''
  
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
