# MIPS Linked List Implementation

**Author**: Aleksandr Hovhannisyan

**Course**: CDA3101 Intro to Computer Organization (@ the University of Florida)

This source code provides a full implementation of a MIPS assembly linked list, complete with a command-line menu for user input. Ample inline comments are provided 
to make the code easier to follow/decipher. 

Known drawback: because SPIM only supports the allocation of dynamic memory but does not support the deallocation of said memory,
this program inevitably runs into memory leaks when nodes are created and subsequently "deleted." 

### Demonstration

Here's a brief demo going through some of the menu interactions:

![](screenshots/demo.gif)

### Running
Be sure to download the [QtSPIM](http://spimsimulator.sourceforge.net/) simulator. Then, simply download the source file, 
load it into QtSPIM, and run.
