
# Experimental YASCL

Experimental fork of YASCL to test out features.
Code quality not guaranteed.

## Contribution
Ideas and suggestions are welcome in the issues tab.

## Features
List of currently implemented features:
- Function pointers. `@<function name>` to obtain a function pointer and `@<variable name>(...)` to call a function pointer stored in a variable.
- Float literals by `F` or `#` prefix. Minus symbol after to make a negative float literal.
- Unary minus on leaf expressions.
- Relocatable backend (fancy! but also essential for external linking)
- External functions using the `?` prefix. Call an external function will switch the compiler into object file mode. It will emit an ET_REL elf file and strip the program header.
