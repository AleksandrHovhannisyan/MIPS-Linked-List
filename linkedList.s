#=======================================================================================================================#
#															#
#	CDA3101 Programming Assignment 3: MIPS Linked List Implementation						#
#	Author: Aleksandr Hovhannisyan											#
#	Instructor: Dr. Cheryl Resch											#
#															#
#	This source file provides a full implementation of a MIPS linked list, which consists of a series of Node	#
#	objects linked to each other via pointers. Nodes are inserted into the list in ascending order by value,	#
#	and all Nodes are guaranteed to have a unique ID.								#
#															#
#	Due to limitations with the SPIM simulator, the program cannot deallocate any heap memory that it allocates.	#
#	Thus, the program does produce memory leaks. I also chose not to reuse redundant code via procedure calls.	#
#	Admittedly, this significantly increases the size of the source code. At the same time, however, it reduces	#
#	the call stack overhead.											#
#															#
#=======================================================================================================================#


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
	foundNode: .asciiz "\n\tRequested node found:\t"
	alreadyExists: .asciiz "\n\n\tA linked list already exists. Enter 'A' in the menu to add nodes to it or 'L' to display it.\n"
	addingToNullHead: .asciiz "\n\n\tYou must create a linked list before you can insert a new node. See menu option 'C'.\n"
	displayRequiresList: .asciiz "\n\n\tYou must create a linked list before you can print it. See menu option 'C'.\n"
	searchRequiresList: .asciiz "\n\n\tYou must create a linked list before you can search for a node. See menu option 'C'.\n"
	noNodesToDelete: .asciiz "\n\n\tYou must create a linked list before you can delete a node. See menu option 'C'.\n"
	nodeNotFound: .asciiz "\n\n\tThe requested node was not found in the linked list.\n"
	nodeAlreadyExists: .asciiz "\n\tThe node with the requested ID already exists in the linked list.\n"
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
#			Prints the menu options to the console.	          	       #
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
#	     Retrieves the user's menu input, stored in the $v0 register.	       #
#======================================================================================#

GetUserMenuInput:

	li $v0, 12				# syscall code for reading a char
	syscall					# read the char (it's now in $v0)
	jr $ra					# return to caller with that value

#======================================================================================#
#	Creates a new Linked List object, returning the address of the head node.      #
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
#	    Prints the contents of the Nodes in this Linked List object.	       #
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
	jr $ra					# return to caller


#======================================================================================#
#		Returns 1 if the given ID is unique and 0 otherwise.      	       #
#======================================================================================#

IsUniqueID:

	move $t0, $s1				# current = head

	CheckNodes:
	beq $t0, $0, UniqueID			# if current == nullptr, ID is unique
	lw $t1, 0($t0)				# current->ID
	beq $a0, $t1, NotUnique			# break
	lw $t0, 8($t0)				# else, current = current->next
	j CheckNodes				# loop

	UniqueID:
	li $v0, 1				# if we reach this, ID is unique
	jr $ra					# and return

	NotUnique:
	li $v0, 0				# false
	jr $ra					# return


#======================================================================================#
#	Adds a new node to the existing Linked List in sorted fashion (by value).      #
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

	addi $sp, $sp, -12			# stack frame for three words
	sw $t0, 0($sp)				# store current Node
	sw $t1, 4($sp)				# store user's entered ID
	sw $ra, 8($sp)				# store return address
	move $a0, $t1				# load ID argument for function call
	jal IsUniqueID				# check if the ID is unique; answer in $v0 (1 = unique)

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12

	beq $v0, $0, CreatingDuplicateNode	# not unique ID

	# Otherwise, unique ID

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
	jr $ra					# return to caller

	PreviousWasNull:

	# One last thing: we have to check if newNode is being entered before the head (it's the new head),
	# in which case we need to update $s1, the current head, to point to newNode. This happens
	# when previous == nullptr and valueToEnter < valueInCurrent. So now, we check if the 2nd condition
	# caused us to terminate from the 'while' loop above (the other termination condition was current == nullptr).

	bne $t4, $0, InsertionBeforeHead	# if newNode is the new head, update head
	j ReturnFromAddNode			# else, return to caller			

	InsertionBeforeHead:

	move $s1, $v0				# head = newNode
	jr $ra					# return to caller

	AddingToNullHead:

	la $a0, addingToNullHead		# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	jr $ra					# return to caller

	CreatingDuplicateNode:
	
	la $a0, nodeAlreadyExists		# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	jr $ra					# return to caller
	
#======================================================================================#
#	Removes the node with the given ID from this Linked List object.	       #
#======================================================================================#

DeleteNode:
	
	beq $s1, $0, NoNodesToDelete		# if head == nullptr, nothing to delete

	move $t0, $s1				# current = LinkedList->head

	la $a0, askForID			# prompt user to enter an ID
	li $v0, 4				# syscall code for printing string
	syscall					# print the prompt

	li $v0, 5				# syscall code for reading int
	syscall					# read the int (ID); it's now in $v0
	move $t1, $v0				# store the ID in $t1 for use later
	
	li $t2, 0				# previous = nullptr (to be used later in deleting)

	FindNodeToDelete:	

	beq $t0, $0, DeletionNodeNotFound	# if current == nullptr, return
	lw $t3, 0($t0)				# current->ID
	beq $t1, $t3, NodeFoundForDeletion	# else, branch if current->ID == $t1
	move $t2, $t0				# if it doesn't, previous = current
	lw $t0, 8($t0)				# if it doesn't, current = current->next
	j FindNodeToDelete			# and loop	

	NodeFoundForDeletion:
		
	beq $t2, $0, DeleteHead			# if previous == nullptr, then we're deleting the head
	
	# Otherwise, we're not deleting the head. In that case,
	# it doesn't matter what we're deleting; all we need to do
	# is reconnect the broken links. Consider [5]-[8]-[20] and a
	# request to delete [20]. Then [8]->next = [20]->next. Here,
	# [20]->next == nullptr. And so on.	

	# Memory leak here, courtesy of SPIM
	lw $t3, 8($t0)				# current->next
	sw $t3, 8($t2)				# previous->next = current->next
	jr $ra					# return

	DeleteHead:
	
	lw $t2, 8($t0)				# newHead = head->next (overwrite $t2, dont need it anymore)
	move $s1, $t2				# head = newHead (memory leak, yuck... thanks again, SPIM)
	jr $ra

	DeletionNodeNotFound:

	la $a0, nodeNotFound			# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	jr $ra					# return to caller

	NoNodesToDelete:

	la $a0, noNodesToDelete			# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	jr $ra					# and return

#======================================================================================#
#	Searches for a Node with the specified ID in this Linked List.		       #
#======================================================================================#

SearchID:

	beq $s1, $0, NoNodeIDToFind		# if head == nullptr

	move $t0, $s1				# current = head	

	la $a0, askForID			# prompt user to enter an ID
	li $v0, 4				# syscall code for printing string
	syscall					# print the prompt

	li $v0, 5				# syscall code for reading int
	syscall					# read the int (ID); it's now in $v0
	move $t1, $v0				# store the ID in $t1 for use later

	FindID:
	
	beq $t0, $0, NodeIDNotFound		# if current == nullptr, we reached the end w/o finding anything
	lw $t2, 0($t0)				# current->ID
	beq $t1, $t2, NodeIDFound		# found the node
	lw $t0, 8($t0)				# else, current = current->next
	j FindID

	NodeIDFound:

	la $a0, foundNode			# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it

	li $v0, 1				# syscall code for printing an int
	lw $a0, 0($t0)				# load the ID into $a0 for printing
	syscall					# print the ID
	
	li $v0, 4				# syscall code for printing a string
	la $a0, tab				# load the tab into $a0 for printing
	syscall					# print the tab

	li $v0, 1				# syscall code for printing an int
	lw $a0, 4($t0)				# load the value into $a0 for printing
	syscall					# print the value

	la $a0, newline				# load newline
	li $v0, 4				# syscall code for printing string
	syscall					# print the newline
	jr $ra					# return

	NodeIDNotFound:

	la $a0, nodeNotFound			# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	jr $ra					# return

	NoNodeIDToFind:
	
	la $a0, searchRequiresList		# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	jr $ra					# and return

#======================================================================================#
#	Searches for a Node with the specified value in this Linked List.	       #
#======================================================================================#

SearchValue:
	
	beq $s1, $0, NoNodeValToFind		# if head == nullptr

	move $t0, $s1				# current = head	

	la $a0, newline				# load newline
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	syscall					# again

	la $a0, askForValue			# prompt user to enter an ID
	li $v0, 4				# syscall code for printing string
	syscall					# print the prompt

	li $v0, 5				# syscall code for reading int
	syscall					# read the int (val); it's now in $v0
	move $t1, $v0				# store the val in $t1 for use later
	li $t3, 0				# to be used as a flag variable later; see NodeValFound

	FindValue:
	
	beq $t0, $0, Done			# if current == nullptr, exit the loop
	lw $t2, 4($t0)				# current->value
	beq $t1, $t2, NodeValFound		# found the node
	lw $t0, 8($t0)				# if not a match, current = current->next
	j FindValue				# loop

	Done:
	beq $t3, $0, NodeValNotFound		# if the $t3 flag is zero, then we never found a node
	jr $ra					# otherwise, just return

	NodeValFound:

	li $t3, 1				# flag for found
	la $a0, foundNode			# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it

	li $v0, 1				# syscall code for printing an int
	lw $a0, 0($t0)				# load the ID into $a0 for printing
	syscall					# print the ID
	
	li $v0, 4				# syscall code for printing a string
	la $a0, tab				# load the tab into $a0 for printing
	syscall					# print the tab

	li $v0, 1				# syscall code for printing an int
	lw $a0, 4($t0)				# load the value into $a0 for printing
	syscall					# print the value

	la $a0, newline				# load newline
	li $v0, 4				# syscall code for printing string
	syscall					# print the newline
	lw $t0, 8($t0)				# get the next node
	j FindValue				# loop

	NodeValNotFound:

	la $a0, nodeNotFound			# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	jr $ra					# return

	NoNodeValToFind:
	
	la $a0, searchRequiresList		# load message
	li $v0, 4				# syscall code for printing string
	syscall					# print it
	jr $ra					# and return

#======================================================================================#
#			Terminates the program entirely.			       #
#======================================================================================#

Exit:
	li $v0, 10
	syscall
