# String Primitives and Macros

**Portfolio assignment for CS 271: Computer Architecture & Assembly Language course at Oregon State University**

### Program Description

Write and test a MASM program to perform the following tasks:
* Implement and test two **macros** for string processing
  * `mGetString`: Display a prompt _(input parameter, by reference)_, then get the user’s keyboard input into a memory location _(output parameter, by reference)_
  * `mDisplayString`: Print the string which is stored in a specified memory location _(input parameter, by reference)_

* Implement and test two **procedures** for signed integers which use string primitive instructions
  * `ReadVal`:
    - Invoke the `mGetString` macro to get user input in the form of a string of digits
    - Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc.)
    - Store this one value in a memory variable _(output parameter, by reference)_
  *  `WriteVal`:
      -  Convert a numeric SDWORD value _(input parameter, by value)_ to a string of ASCII digits
      -  Invoke the `mDisplayString` macro to print the ASCII representation of the SDWORD value to the output

*  Write a test program (in `main`) which uses the `ReadVal` and `WriteVal` procedures above to:
    *  Get 10 valid integers from the user
    *  Stores these numeric values in an array
    *  Displays the integers, their sum, and their truncated average
