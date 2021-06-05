# CS152 Project Phase 3: Code Generation
This is Phase 3 for a compiler project for CS152. Original specifications are authored by the TA for the course.


## Prerequisites

Run the Makefile to generate the necessary files. 
- Example: `make`

## Usage
The parser can be invoked by the following command. This will then generate the MIL code of the chosen .min file.
- Example: `cat [.min file] | parser`

The MIL code can then be executed with the given MIL interpreter `mil_run`.
- Example: `mil_run mil_code.mil`

The MIL code requires input data which can be written to a file. For example, the input values can be written to a file named `input.txt`.
- Example: `mil_run mil_code.mil < input.txt`