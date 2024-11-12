
# vett = [5, 4, 7], con 0x120 primo elemento del vettore

addi x10, x0, 0x120 # base address
addi x11, x0, 3     # length
addi x12, x0, 5     # popolamento del vettore
sw x12, 0(x10)
addi x12, x0, 4
sw x12, 4(x10)
addi x12, x0, 7
sw x12, 8(x10)

lw x5, 0(x10) # registro che contiene il massimo, inizializzato a vett[0]
loop:
    beq x11, x0, end_loop
    lw x6, 0(x10)
    bge x5, x6, no_change
    addi x5, x6, 0
no_change:
    addi x11, x11, -1
    addi x10, x10, 4
    jal x0, loop
end_loop:
    ret