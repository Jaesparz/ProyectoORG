.data
mazo:   .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10  # Mazo de 22 cartas (2 copias de cada carta)

mensaje_decision: .asciiz "\n¿Qué deseas hacer? (1 = Pedir carta, 0 = Plantarse): "
mensaje_turno_jugador1: .asciiz "\n--- Turno del Jugador 1 (Tú) \n"
mensaje_turno_jugador2: .asciiz "\n--- Turno del Jugador 2 (Máquina) \n"
mensaje_ganador_juego: .asciiz "\n¡Ganaste! ¡Felicidades! \n"
mensaje_perdedor_juego: .asciiz "\nPerdiste. ¡Intenta de nuevo! \n"
mensaje_puntaje: .asciiz "Tu puntaje actual es: "
mensaje_puntaje_jugador2: .asciiz "Puntaje de la Máquina: "
mensaje_acción_jugador_roba: .asciiz "\nRobaste una carta. Valor: "
mensaje_acción_jugador_planta: .asciiz "\nTe has plantado.\n"
mensaje_acción_jugador2_roba: .asciiz "\nLa Máquina robó una carta. Valor: "
mensaje_acción_jugador2_planta: .asciiz "\nLa Máquina se planta.\n"
mensaje_empate: .asciiz "\n¡Empate!\n"

.text
.globl main

main:
    # Inicialización
    li $s2, 0                  # Puntaje del jugador 1 (Usuario)
    li $s3, 0                  # Puntaje del jugador 2 (Máquina)
    li $s4, 0                  # Índice de la carta actual en el mazo
    li $s5, 0                  # Contador de turnos (máximo de turnos)
    li $t0, 10                 # Límite de turnos (10 turnos en total)

    # Repartir 2 cartas al jugador 1 y jugador 2
    jal repartir_cartas

game_loop:
    # Turno del jugador 1 (Usuario)
    jal manejar_decision_jugador1

    # Verificar si el jugador 1 se pasó de 21
    bgt $s2, 21, mensaje_perdedor

    # Turno del jugador 2 (Máquina)
    jal manejar_decision_jugador2

    # Verificar si el jugador 2 se pasó de 21
    bgt $s3, 21, mensaje_ganador

    # Incrementar contador de turnos
    addi $s5, $s5, 1

    # Si se alcanza el límite de turnos, comparar puntajes
    bge $s5, $t0, comparar_puntajes

    # Volver al inicio del bucle
    j game_loop

repartir_cartas:
    # Reparte 2 cartas a cada jugador
    lw $t1, mazo($s4)
    add $s2, $s2, $t1
    addi $s4, $s4, 4

    lw $t2, mazo($s4)
    add $s3, $s3, $t2
    addi $s4, $s4, 4

    lw $t3, mazo($s4)
    add $s2, $s2, $t3
    addi $s4, $s4, 4

    lw $t4, mazo($s4)
    add $s3, $s3, $t4
    addi $s4, $s4, 4

    jr $ra

manejar_decision_jugador1:
    # Mostrar turno y puntaje
    li $v0, 4
    la $a0, mensaje_turno_jugador1
    syscall

    li $v0, 4
    la $a0, mensaje_puntaje
    syscall

    li $v0, 1
    move $a0, $s2
    syscall

    # Pedir decisión al usuario
    li $v0, 4
    la $a0, mensaje_decision
    syscall

    li $v0, 5
    syscall
    move $t1, $v0

    beq $t1, 1, pedir_carta1
    beq $t1, 0, plantarse1

pedir_carta1:
    lw $t2, mazo($s4)
    add $s2, $s2, $t2
    addi $s4, $s4, 4

    li $v0, 4
    la $a0, mensaje_acción_jugador_roba
    syscall

    li $v0, 1
    move $a0, $t2
    syscall

    jr $ra

plantarse1:
    li $v0, 4
    la $a0, mensaje_acción_jugador_planta
    syscall

    jr $ra

manejar_decision_jugador2:
    # Mostrar turno y puntaje
    li $v0, 4
    la $a0, mensaje_turno_jugador2
    syscall

    li $v0, 4
    la $a0, mensaje_puntaje_jugador2
    syscall

    li $v0, 1
    move $a0, $s3
    syscall

    # Lógica de decisión automática para la máquina
    blt $s3, 15, pedir_carta2  # Si <15, siempre pide carta

    # Si el puntaje está entre 15 y 18
    li $v0, 42                 # Syscall para obtener un número aleatorio
    li $a1, 100                # Rango de 0 a 99
    syscall

    li $t0, 70                 # 70% de probabilidad de robar
    blt $a0, $t0, pedir_carta2 # Si el número aleatorio es menor que 70, pide carta

    # Si el puntaje es 18 o más, se planta
    j plantarse2

pedir_carta2:
    lw $t3, mazo($s4)
    add $s3, $s3, $t3
    addi $s4, $s4, 4

    li $v0, 4
    la $a0, mensaje_acción_jugador2_roba
    syscall

    li $v0, 1
    move $a0, $t3
    syscall

    jr $ra

plantarse2:
    li $v0, 4
    la $a0, mensaje_acción_jugador2_planta
    syscall

    jr $ra

comparar_puntajes:
    bgt $s2, 21, mensaje_perdedor
    bgt $s3, 21, mensaje_ganador

    beq $s2, $s3, empate
    bgt $s2, $s3, mensaje_ganador
    blt $s2, $s3, mensaje_perdedor

empate:
    li $v0, 4
    la $a0, mensaje_empate
    syscall
    j fin

mensaje_perdedor:
    li $v0, 4
    la $a0, mensaje_perdedor_juego
    syscall
    j fin

mensaje_ganador:
    li $v0, 4
    la $a0, mensaje_ganador_juego
    syscall
    j fin

fin:
    li $v0, 10
    syscall