This portfolio project was the final assignment of Oregon State University's course on computer architecture and assembly language.
CS271: Computer Architecture and Assembly Language, focuses on assembly level programming on x86 architectures.
All coding and debugging was carried out in the Microsoft Visual Studio 2019 IDE.

Description:
  Program accepts 10 numeric values from the user in the form of ASCII strings. The ASCII characters are then converted into
  their equivalent numeric values which are then used to calculate the sum and truncated average of the values. The original numeric values are
  then converted back to ASCII, along with the sum and average, and displayed to the user. All input values are accepted exclusively
  by using the mGetString macro, and all values are displayed back to the user exclusively by using the mDisplayString macro.
  This program features two procedures, readVal and writeVal, that are designed to work in conjunction with the aforementioned macros
  to accept the user inputs, convert the values from ASCII, perform arithmatic, convert the values back to ASCII, and display back to the user. 
  All values entered and displayed must fit into a 32-bit register or a programmed 'error' will occur.
  Program also features a procedure, getMean, that serves as a helper function to generate the truncated average without cluttering up main PROC.
