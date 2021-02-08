# 6502 SpASM (6502 Spreadsheet Assembler) v1.1.2
![!test](6502_assembler.png)

This is a proof-of-concept 6502 assembler in a spreadsheet (works with Excel, Libre Office, etc.)

The XLSX file is the latest release. Instructions included in the spreadsheet.

## Features
- all the 6502 instructions plus a couple of pseudo-instructions
- all addressing modes
- global and local labels
- EQUs to declare constants
- use of +/- offsets with constants/labels
- use of "#" to reference values
- decimal notation by default (0-65535)
- use of "$" for hexadecimal notation (2 bytes max)
- use of "%" for binary notation (16 bits max)
- use of ">" and "<" to point to MSB and LSB (2 bytes only)
- display cycle count
- ORG within code to define different starting addresses for modules
- HEX pseudo-instruction to define HEX data
- ASC/STR pseudo-instructions to define text constants (with ASC, hi-bit is unset, while with STR, it is)
- syntax highlighting

## Revisions
### v1.0 (Jan 31, 2021)
- initial release

### v1.0.1 (Jan 31, 2021)
- fixed zp jmp/jsr
- fixed ld_ #> and ld_ #<

### v1.1 (Feb 6, 2021)
- fixed bytes needed for some opcodes
- added cycles display
- added support of ORG in the middle of the code
- added support for #label and #<label and #>label for HEX opcode

### v1.1.1 (Feb 8, 2021)
- fixed more bytes count for some opcodes
- rewrote the byte count detection in order to avoid possible circular references
- column D is now colored as comments, it's meant to be used as full-line comments
- new official name "SpASM" !

### v1.1.2 (Feb 8, 2021)
- fixed instructions because columns were shifted with latest release
- added syntax highlighting for SUBs
- deleted Excel external link

## Licence
You may freely use, copy (etc) this spreadsheet for your own creations and you may also redistribute it on any kind of media as long as the "instructions" sheet is included and not modified.
If you mention this file or distribute it elsewhere, please send me a message. I'm on Facebook's "Apple II Software Enthusiasts" and "Apple II Enthusiasts" groups, among others.
