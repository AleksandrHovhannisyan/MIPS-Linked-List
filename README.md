# MIPS Linked List Implementation

Written for the course CDA3101 Intro to Computer Organization at the University of Florida.

This source code provides a full implementation of a linked list in the MIPS assembly language, complete with a command-line menu for user input.

Known drawback: because SPIM only supports the allocation of dynamic memory but does not support the deallocation of said memory,
this program inevitably runs into memory leaks when nodes are created and subsequently "deleted." 

### Demonstration

Here's a brief demo going through some of the menu interactions:

![](screenshots/demo.gif)

### Running
Download the [QtSPIM](http://spimsimulator.sourceforge.net/) simulator. Then, download the source file, 
load it into QtSPIM, and run the program.
