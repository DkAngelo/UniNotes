# vett = [5, 4, 8], con 0x120 primo elemento del vettore

addi x10, x0, 0x120 # base address
addi x11, x0, 3     # length
addi x12, x0, 5     # popolamento del vettore
sw x12, 0(x10)
addi x12, x0, 4
sw x12, 4(x10)
addi x12, x0, 8
sw x12, 8(x10)

addi x28, x0, 0      #x8 andra' a contenere la somma dei numeri pari
loop:
    beq x11, x0, end_loop
    lw x6, 0(x10)
    andi x7, x6, 1
    beq x7, x0, add_number
prep_loop:
    addi x11, x11, -1
    addi x10, x10, 4
    jal x0, loop
add_number:
    add x28, x28, x6
    jal x0, prep_loop
end_loop:
    ret