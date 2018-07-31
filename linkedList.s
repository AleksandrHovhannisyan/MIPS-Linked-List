.data

	prompt: .asciiz "\nSpecify an action to take for the linked list:"
	create: .asciiz "\n\tC to create the list."
	display: .asciiz "\n\tL to display the list."
	addTo: .asciiz "\n\tA to add a single node."
	delete: .asciiz "\n\tD to delete a node."
	searchID: .asciiz "\n\tS to search for a node with the specified ID."
	searchVal: .asciiz "\n\tF to search for a node with a specified value."
	orTerminate: .asciiz "\nOr X to terminate: "
	askForID: .asciiz "\n\n\tEnter the integer for the ID field: "
	askForValue: .asciiz "\tEnter the node's data field: "
	nextNodeIs: .asciiz "\n\n\tThe next node is:\t"
	alreadyExists: .asciiz "\n\n\tA linked list already exists. Enter 'A' in the menu to add nodes to it or 'L' to display it.\n"
	addingToNullHead: .asciiz "\n\n\tPlease create a linked list before attempting to insert a new node. See menu option 'C'.\n"
	displayRequiresList: .asciiz "\n\n\tPlease create a linked list before attempting to print it. See menu option 'C'."
	tab: .asciiz "\t"
	newline: .asciiz "\n"

.text

#======================================================================================#
#      Entry point of the program. Prompts user input and directs to menu options.     #
#======================================================================================#

main:	li $s1, 0				# head = nullptr
	
loop:	jal PrintMenu				# Prints the menu prompt and options
	jal GetUserMenuInput			# Retrieves user input from console	

	seq $t0, $v0, 'C'
	bne $t0, $zero, C
	seq $t0, $v0, 'L'
	bne $t0, $zero, L
	seq $t0, $v0, 'A'
	bne $t0, $zero, A
	seq $t0, $v0, 'D'
	bne $t0, $zero, D
	seq $t0, $v0, 'S'
	bne $t0, $zero, S
	seq $t0, $v0, 'F'
	bne $t0, $zero, F
	seq $t0, $v0, 'X'
	bne $t0, $zero, Exit
	j loop
	
	C:	jal Create
		j loop
	L:	jal Display
		j loop
	A:	jal AddNode
		j loop
	D:	jal DeleteNode
		j loop
	S:	jal SearchID
		j loop
	F:	jal SearchValue
		j loop


#======================================================================================#
#			Prints the menu options to the console	          	       #
#======================================================================================#

PrintMenu:

	la $a0, prompt				# load prompt into $a0 for printing
	li $v0, 4				# syscall code for printing string
	syscall					# print the string in $a0
	la $a0, create				# load next string
	syscall					# I'm lazy; the rest is straightforward
	la $a0, display				
	syscall
	la $a0, addTo
	syscall
	la $a0, delete
	syscall
	la $a0, searchID
	syscall
	la $a0, searchVal
	syscall
	la $a0, orTerminate
	syscall
	jr $ra

#======================================================================================#
#	Retrieves the user's menu input, stored in the $v0 register		       #
#======================================================================================#

GetUserMenuInput:

	li $v0, 12				# syscall code for reading a char
	syscall					# read the char (it's now in $v0)
	jr $ra					# return to caller with that value

#======================================================================================#
#	Creates a new Linked List object, returning the address of the head node       #
#======================================================================================#

Create:

	bne $s1, $0, AlreadyExists		# if head != nullptr, warn the user

	li $v0, 9				# syscall code (9) for allocating memory	
	li $a0, 12				# twelve bytes needed (3 words)
	syscall					# let there be light	
	move $s1, $v0				# store that address as the head

	la $a0, askForID			# prompt user to enter an ID
	li $v0, 4				# syscall code for printing string
	syscall					# print the prompt

	li $v0, 5				# syscall code for reading int
	syscall					# read the int (ID); it's now in $v0
	sw $v0, 0($s1)				# store the ID in memory, 1st field

	la $a0, askForValue			# prompt user to enter a value
	li $v0, 4				# syscall code for printing string
	syscall					# print the prompt

	li $v0, 5				# syscall code for reading an int
	syscall					# read the int (value); it's now in $v0
	sw $v0, 4($s1)				# store the value in memory, 2nd field
	sw $0, 8($s1)				# next = nullptr for a new LinkedList
	
	jr $ra					# return to caller

	AlreadyExists:
	
	la $a0, alreadyExists			# load string for printing
	li $v0, 4				# syscall code for printing string
	syscall					# print that string
	jr $ra					# and return
	

#======================================================================================#
#	    Prints the contents of the Nodes in this Linked List object		       #
#======================================================================================#

Display:

	beq $s1, $0, DisplayRequiresList	# code would work without this, but best to inform user

	move $t0, $s1				# current = LinkedList.head

	DisplayLoop:
	beq $t0, $0, ReturnFromDisplay		# check if we're at a null ($0) node
	la $a0, nextNodeIs			# load "The next node is: " string
	li $v0, 4				# syscall code for printing a string
	syscall					# print the string
	
	li $v0, 1				# syscall code for printing an int
	lw $a0, 0($t0)				# load the ID into $a0 for printing
	syscall					# print the ID
	
	li $v0, 4				# syscall code for printing a string
	la $a0, tab				# load the tab into $a0 for printing
	syscall					# print the tab

	li $v0, 1				# syscall code for printing an int
	lw $a0, 4($t0)				# load the value into $a0 for printing
	syscall					# print the value

	lw $t0, 8($t0)				# current = current->next
	j DisplayLoop				# jump to loop

	ReturnFromDisplay:
	li $v0, 4				# syscall code for printing string
	la $a0, newline				# load the newline
	syscall					# print the newline
	jr $ra					# return to caller

	DisplayRequiresList:
	la $a0, displayRequiresList		# load message for printing
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	j ReturnFromDisplay			# return

#======================================================================================#
#	Adds a new node to the existing Linked List in sorted fashion (by value)       #
#======================================================================================#

AddNode:

	beq $s1, $0, AddingToNullHead		# reject insertion of a new node if head is nullptr	

	move $t0, $s1				# current = LinkedList.head
	
	la $a0, askForID			# prompt user to enter an ID
	li $v0, 4				# syscall code for printing string
	syscall					# print the prompt

	li $v0, 5				# syscall code for reading int
	syscall					# read the int (ID); it's now in $v0
	move $t1, $v0				# store the ID in $t1 for use later

	la $a0, askForValue			# prompt user to enter a value
	li $v0, 4				# syscall code for printing string
	syscall					# print the prompt

	li $v0, 5				# syscall code for reading an int
	syscall					# read the int (value); it's now in $v0
	move $t2, $v0				# store the value in $t2 for use later

	li $t3, 0				# to be used as a "previous" Node tracker (Node before current, initially nullptr)

	FindLoop:

	beq $t0, $0, ExitAddNodeLoop		# if current == nullptr, exit loop
	lw $t4, 4($t0)				# t4 = current->value
	slt $t4, $t2, $t4			# record whether valueToStore (t2) < valueInCurrent (t4), and store in t4
	bne $t4, $0, ExitAddNodeLoop		# if t2 is in fact < t4, break

	# Anything below (but before ExitAddNodeLoop) runs when valueToStore (t2) >= valueInCurrent (t4)
	# Since we're storing nodes in ascending order by value, we need to move up one link in this case.
	
	move $t3, $t0				# previous = current
	lw $t0, 8($t0)				# current = current->next
	j FindLoop				# loop again

	ExitAddNodeLoop:
	
	li $v0, 9				# syscall code (9) for allocating memory (new Node)	
	li $a0, 12				# twelve bytes needed (3 words)
	syscall					# let there be light	
	
	sw $t1, 0($v0)				# newNode->id = $t1 (user-entered id from before)
	sw $t2, 4($v0)				# newNode->value = $t2 (user-entered value from before)	
	sw $t0, 8($v0)				# newNode->next = current (either nullptr or a valid Node)

	beq $t3, $0, PreviousWasNull		# if previous == nullptr, we're done w/ above	

	sw $v0, 8($t3)				# else, previous->next = newNode (insertion elsewhere in the list)
	j ReturnFromAddNode			# return to caller

	PreviousWasNull:

	# One last thing: we have to check if newNode is being entered before the head (it's the new head),
	# in which case we need to update $s1, the current head, to point to newNode. This happens
	# when previous == nullptr and valueToEnter < valueInCurrent. So now, we check if the 2nd condition
	# caused us to terminate from the 'while' loop above (the other termination condition was current == nullptr).

	bne $t4, $0, InsertionBeforeHead	# if newNode is the new head, update head
	j ReturnFromAddNode			# else, return to caller			

	InsertionBeforeHead:

	move $s1, $v0				# head = newNode
	
	ReturnFromAddNode:
	jr $ra					# return to caller

	AddingToNullHead:
	la $a0, addingToNullHead		# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	j ReturnFromAddNode			# return

#======================================================================================#
#	Removes the node with the given ID from this Linked List object		       #
#======================================================================================#

DeleteNode:
	
	jr $ra

#======================================================================================#
#	Searches for a Node with the specified ID in this Linked List		       #
#======================================================================================#

SearchID:
	
	jr $ra

#======================================================================================#
#	Searches for a Node with the specified value in this Linked List	       #
#======================================================================================#

SearchValue:
	
	jr $ra

#======================================================================================#
#			Terminates the program entirely				       #
#======================================================================================#

Exit:
	li $v0, 10
	syscall
