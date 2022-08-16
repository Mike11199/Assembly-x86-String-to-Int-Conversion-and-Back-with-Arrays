# Project-6-String-Primitives-and-Macros

This is my submission for CS 271 - Computer Architecture & Assembly Language Project 6, taken Summer 2022 at Oregon State University.  Per the Syllabus, this is the portfolio project, which is allowed to be made public, unlike other projects.  This was coded in Visual Studio in x86 Assembly Language, using the MASM assembler.

<h2> Project Description </h2>

-This program allows numbers to be read/written by the users without Irvine library procedures, using manual conversion of numbers to strings and vice versa.

-This program allows user to enter in a series of numbers as strings.  It then converts the string into a number using the ReadVal procedure.  It accomplishes this without Irvine library procedures, by REPEATEDLY MULTIPLYING each char of the string converted to a number by 10 if necessary, building up a number digit by digit.

-After creating the number, it saves it to an array of numbers.  It then calculates the average and sum of these numbers and displays these to the user.

-Finally, it uses the WriteVal function (also used for the sum/average previously) to loop through each SDWORD integer array and convert that number
back into a string manually wihtout Irvine library procedures.  It does this by REPEATEDLY DIVIDING each number by 10 to build back a string from the
remainder of each division. From this, it uses string primitve instructions to reverse the string, so that it is in the correct order.

-It also makes use of two macros to get and display strings to the user.
