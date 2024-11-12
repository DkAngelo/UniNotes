# Scrivere un programma in RISC-V assembly che inverta l'ordine dei caratteri di una stringa C. 
# La stringa inizia all'indirizzo di memoria contenuto in x10. La stringa deve essere modificata in place
# (la stringa invertita parte dallo stesso indirizzo di quella di input)

# preparazione della stringa "ciao"
addi x10, x0, 0x120
addi x12, x0, 'c'
sb x12, 0(x10)
addi x12, x0, 'i'
sb x12, 1(x10)
addi x12, x0, 'a'
sb x12, 2(x10)
addi x12, x0, 'o'
sb x12, 3(x10)
sb x0, 4(x10)

addi x11, x10, 0    #puntatore verso destra
addi x12, x10, 0    #puntatore verso sinistra

find_end:
    lb x5, 0(x12)
    beq x5, x0, found
    addi x12, x12, 1
    jal x0, find_end
found:
    addi x12, x12, -1

swap:
    bge x11, x12, end_swap
    lb x5, 0(x11)
    lb x6, 0(x12)
    sb x5, 0(x12)
    sb x6, 0(x11)
    addi x11, x11, 1
    addi x12, x12, -1
    jal x0, swap
end_swap:
    ret