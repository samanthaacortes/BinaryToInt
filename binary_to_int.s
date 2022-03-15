# Author Samantha Cortes
# Assembly Language
# Converts user binary input to int
# Compares int with list of 32 32-bit entries
# Returns index of closest match or -1 if none are close

#---variable key---	
# $a0 = string input
# $a1 = patterns[i]
# $t0 = $a0
# $t1 = read byte from array
# $s0 = converted string to int
# $s1 = address of patterns

.globl main			

.text	

main:
	li $v0, 4
	la $a0, s_prompt           # print prompt
	syscall
	
	li $v0, 8	               # read string (into $v0)
	la $a0, s_input            # space to store user input
	li $a1, 34                 # byte space for the string
	
    move $t0, $a0	           # string in $t0
	syscall

  	la $s1, patterns           # load address of patterns into $s2 
	
  	move $s0, $zero            # initialize $s0 to zero
  
int_conversion:
	 
  	lb $t1, 0($t0)             # $t1 = read byte from array
  	addi $t0, $t0, 1           # $t0++
  	                          
  	beq $t1, 10, done          # branch to when the byte value is a newline char

  	addi $t1, $t1, -48         # convert ascii value to decimal

  	beq $t1, $zero, if_zero    # branch to if_zero if a character in string is zero
  	beq $t1, 1, if_one         # branch to if_one if a character in string is one
  
if_zero:
  	sll $s0, $s0, 1            # reg $s0 = $s0 << 1 bit
  	add $s0, $s0, $zero        # add 0 to $s0
  	j int_conversion           # jump to int_conversion

if_one:
  	sll $s0, $s0, 1            # reg $s0 = $s0 << 1 bit
  	addi $s0, $s0, 1           # add 1 to $s0
  	j int_conversion           # jump to int_conversion

done:
  	move $a0, $s0              # $a0 = $s0
  
  	jal fn_index_finder        # call index finder function

	move $a0, $v0			   # $a0 = $v0
	                           # $a0 = index with lowest difference
	                           
	li $v0, 1				   # print result
	syscall
	
	li $v0, 4	
	la $a0, s_newline		   # print newline
	syscall

	li $v0, 10                 # exit
	syscall


#---function index finder---
# argument: integer value $a0
# iterate through array of patterns (int)
# calls helper function
# finds index that has the lowest distance with user input
# return value:	index of closest distance in $v0
#
#---variable key---	
# $a0 = int user input
# $a1 = patterns[i]
# $s1 = pointer to array of 32 ints
# $s2 = lowest bits of difference
# $s3 = index of the lowest 
# $s4 = i 
# $s5 = exit condition

fn_index_finder:

	addi $sp, $sp, -4          # make room on stack for 1 register
  	sw $ra, 0($sp)             # save $ra on stack

  	li $s2, 8                  # $s2 = difference of bits
  	                           # initialize $s2 to 8
  	                           
  	                           # $s3 = index of lowest bit difference
  	li $s3, -1                 # initialize $s3 to -1
  	
  	li $s4, 0                  # i = 0
  	                           # initialize $s4 to 0
  	                           
	li $s5, 32                 # initialize $s5 to 32
	                           # $s5 = exit condition
	
  	la $s1, patterns           # load address of array
  
loop1:
	beq $s4, $s5, return_index  # branch to return_index if i = 32
    sll $t1, $s4, 2    	       # $t1 = i * 4
    add $t1, $t1, $s1  	       # $t1 = patterns[i]
    lw $a1, 0($t1)     	       # $a1 = patterns[4 * 0] + $t1

    jal fn_helper              # returns bit difference from helper function

	move $t2, $v0              # $t2 = $v0
	slt $t3, $t2, $s2          # $t3 = 1 if $t2 < $s3
	beq $t3, $zero, next       # branch to next if $t3 = 0

	move $s2, $t2              # $s2 = $t2
	move $s3, $s4              # $s3 = $t4
	addi $s4, $s4, 1           # i++
	
	j loop1                    # jump to loop1
	
next:
	addi $s4, $s4, 1           # i++
	j loop1                    # jump to loop1

return_index: 

	move $v0, $s3              # $v0 = $s3
	
	lw $ra, 0($sp)			   # read registers from stack
	addi $sp, $sp, 4		   # bring back stack pointer

	jr $ra                     # return lowest bits

#---function helper---
# argument: integer value $a0, array[i] in $a1
# iterate through user input to compare each digit with index
# counts shared bits between them
# return value:	shared bits in $v0
#
#---variable key---	
# $a0 = int user input
# $a1 = patterns[i]
# $t0 = j
# $t1 = number of times looping through $a0
# $t2 = $a0
# $t3 = $a1
# $t4 = lsb of $a0
# $t5 = lsb of $a1
# $t6 = total mismatched bits

fn_helper:

	li $t0, 0			           # j = 0
	li $t1, 31			           # initialize $t1 to 31
	move $t2, $a0                  # $t2 = $a0
	move $t3, $a1                  # $t3 = $a1
	li $t6, 0                      # initialize $t6 to 0
	
loop2:
	beq $t0, $t1, exit_helper      # branch to exit_helper if $t0 = 31
	andi $t4, $t2, 1               # $t4 = $t2 & 1
	
	andi $t5, $t3, 1               # $t5 = $t3 & 1

	bne $t4, $t5 next2             # branch to next2 if $t4 = $t5
	
	srl $t2, $t2, 1                # $t2 = $t2 >> 1
	srl $t3, $t3, 1                # $t3 = $t3 >> 1
    addi $t0, $t0, 1               # j++
	
	j loop2                        # jump to loop2

next2:
	addi $t6, $t6, 1               # $t6++
	srl $t2, $t2, 1                # $t2 = $t2 >> 1
	srl $t3, $t3, 1                # $t3 = $t3 >> 1
	addi $t0, $t0, 1               # j++
	j loop2                        # jump to loop2

exit_helper:
	move $v0, $t6                  # $v0 = $t6
	jr $ra                         # returns bit difference

.data
patterns: .word 0
	.word 1431655765
	.word 858993459
	.word 1717986918
	.word 252645135
	.word 1515870810
	.word 1010580540
	.word 1768515945
	.word 16711935
	.word 1437226410
	.word 869020620
	.word 1721329305
	.word 267390960
	.word 1520786085
	.word 1019428035
	.word 1771465110
	.word 65535
	.word 1431677610
	.word 859032780
	.word 1718000025
	.word 252702960
	.word 1515890085
	.word 1010615235
	.word 1769576086
	.word 16776960
	.word 1437248085
	.word 869059635
	.word 1721342310
	.word 267448335
	.word 1520805210
	.word 1019462460
	.word 1771476585
							
s_prompt:	.asciiz "Enter a 32-bit binary number: "
s_input:	.space 34
s_newline:	.asciiz "\n"
