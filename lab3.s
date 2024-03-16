#---------------------------------------------------------------
# Assignment:           3
# Due Date:             February 18, 2022
# Name:                 Othman Sebti
# Unix ID:              osebti
# Lecture Section:      B1
# Instructor:           Karim Ali
# Lab Section:          (Tuesday, Thursday)
# Teaching Assistant:   Danil Tiganov
#---------------------------------------------------------------


#---------------------------------------------------------------



.text

# Program Description:
# The following MIPS program recursively finds the floored average of positive and negative elements within a section of 
# A cube. It uses edge-size, top-left corner, and base array size as parameters. Lastly, the CubeStats subroutine uses the
# Stack frame in order to save and restore needed registers/variables across the recursive calls. 

#################################################################################################################
# Register Usage:
# Arguments
# $a0 = a non-negative integer that specifies the dimensions of the base array.
# $a1 = a non-negative integer that specified the size of the base array.
# $a2 = the address of the element of the base array that is the top left corner of the cube.
# $a3 = a non-negative integer that specifies the size of the edge of the cube.
# Return Values
# $v0 = a signed integer containing the floor of the average of all negative elements in the specified cube.
# $v1 = a signed integer containing the floor of the average of the positive elements in the specified cube.
# Other: 
# $s0 = Main Loop Counter for edge-size
# $t0-$t7 = temporary registers for computations 
##################################################################################################################


CubeStats: 


StackSave:
addi $sp,$fp,36 # increment stack to save the values 
sw $fp,-4($sp) # storing frame pointer 
move $fp,$sp # moving sp to fp
sw $a2,-8($fp) # storing base address (top-left of the cube)
sw $ra,-12($fp) # storing base address (top-left of the cube)
sw $s0,-16($fp) # storing saved register
sw $a0, -20($fp) # storing current dimension
sw $s1,-24($fp)
sw $s2,-28($fp)
sw $s3,-32($fp)



li $s0,0 # set counter to zero 

beq $a0,1,CalculateRow # 1 dimensional array detected, calculate row elements




MainLoop:
move $t1,$a1 # set base array size 
addi $s5,$a0,-1 # next dimension
bge $s0,$a3, Terminate # setting loop conditions, if bge exit loop 
li $t0,1 # loading the first power



Ploop:
blt $t0,$s5,Power # iterate over loop, exit if condition fails
mul $t1,$t1,4 # multiply by 4
mul $t1,$t1,$s0 # multiplying $t1 by edge counter
add $t1,$t1,$a2 # calculating new address with offset 
j RecursiveCall # exit loop once condition failed 


Power: # Exponential Calculation Block  
mul $t1,$t1,$a1 # multiplying  $a1 by itself 
addi $t0,$t0,1 # increment counter 
j Ploop


RecursiveCall:

addi $a0,$a0,-1 # updating dimension for recursive call
move $a2,$t1 # change $a2 for the next call to Cubestats


jal CubeStats


# restoring elements from the stack here 
lw $a2,-8($fp) # storing base address (top-left of the cube)
lw $ra,-12($fp) # storing base address (top-left of the cube)
lw $a0,-20($fp) # restoring saved register before returning 
addi $s0,$s0,1 # increment loop 


j MainLoop 



CalculateRow:
li $t2,0 # setting counter to zero
move $t3,$a2 # setting address of top left of cube 

Condition:
bge $t2,$a3,Terminate # iterate over n elements; n = edge-size ($a3)
lw $t6,0($t3) # load integer 
addi $t2,$t2,1 # increment counter
addi $t3,$t3,4 # increment offset by integer byte size 

addi $s0,$s0,1 # increment main loop counter 
bgt $t6,0, Positive # count as a positive 
blt $t6,0, Negative # count as negative 
j Condition # iterate again over loop

Positive: 
lw $t5,countPos
addi $t5,$t5,1 # increment count of pos. integers
sw $t5,countPos
lw $v1,totalPos
add $v1,$v1,$t6 #  add number to the sum 
sw $v1,totalPos
j Condition # iterate over loop again

Negative:
lw $t5,countNeg
addi $t5,$t5,1 # increment count of neg. integers
sw $t5,countNeg
lw $v0,totalNeg
add $v0,$v0,$t6 #  add number to the sum 
sw $v0,totalNeg
j Condition # iterate over loop again




Terminate: # Termination Block 
lw $v1,totalPos # calculating average
beq $v1,0,NegAverage
lw $t6,countPos
div $v1,$t6
mflo $v1  

# Calculate Negative Average
NegAverage:
lw $v0,totalNeg # calculating average
beq $v0,0,StackRestore
lw $t6,countNeg
div $v0,$t6
mfhi $t7 # move remainder to $t7

mflo $v0
bnez $t7,Floor
j StackRestore

Floor:
addi $v0,$v0,-1


# Callee- Restration of stack registers
StackRestore:
lw $ra,-12($fp) # restore the $ra before returning 
lw $s1,-24($fp)
lw $s2,-28($fp)
lw $s3,-32($fp)
lw $s0,-16($fp) # restoring saved register before returning 
lw $fp,-4($fp) # restoring the frame pointer

move $sp,$fp 

jr $ra  # return to caller 
