# il numero di input è nel registro x10
addi x10, x0, 100
# poniamo a zero i due registri da dover utilizzare per il conteggio dei bit
addi x11, x0, 0     # bit a 0
addi x12, x0, 0     # bit a 1
addi x5, x0, 32     # registro di appoggio che ci permette di contare il numero di bit letti

loop:
    beq x5, x0, end_loop
    andi x6, x10, 1         # x6 = x10 & 1
    beq x6, x0, zero_bit
    addi x12, x12, 1
    jal x0, next_bit 
zero_bit:
    addi x11, x11, 1
next_bit:
    srli x10, x10, 1    # shift di uno verso destra
    addi x5, x5, -1
    jal x0, loop
end_loop:
    ret