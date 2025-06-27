.data
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
    # Inicialización de registros
    li $s2, 0                  # Puntaje jugador 1
    li $s3, 0                  # Puntaje jugador 2
    li $s4, 0                  # Índice del mazo (no usado ahora)

    # Cartas iniciales
    jal repartir_cartas

game_loop:
    # Turno jugador humano
    jal jugador1_turno
    bgt $s2, 21, jugador1_pasado  # Si se pasa, pierde

    # Turno máquina
    jal jugador2_turno
    bgt $s3, 21, jugador2_pasado  # Si se pasa, ganas

    # Continuar juego
    j game_loop

repartir_cartas:
    li $t5, 2                # 2 cartas por jugador

repartir_j1:
    li $v0, 42               # Random int [1-10]
    li $a1, 10
    syscall  
    addi $t1, $a0, 1
    add $s2, $s2, $t1
    
    addi $t5, $t5, -1
    bnez $t5, repartir_j1
    
    li $t5, 2                # Reset contador
    
repartir_j2:
    li $v0, 42               # Random int [1-10]
    li $a1, 10
    syscall  
    addi $t1, $a0, 1
    add $s3, $s3, $t1
    
    addi $t5, $t5, -1
    bnez $t5, repartir_j2
    
    jr $ra

jugador1_turno:
    # Mostrar info
    li $v0, 4
    la $a0, mensaje_turno_jugador1
    syscall
    
    li $v0, 4
    la $a0, mensaje_puntaje
    syscall
    
    li $v0, 1
    move $a0, $s2
    syscall
    
    # Pedir decisión
    li $v0, 4
    la $a0, mensaje_decision
    syscall
    
    li $v0, 5
    syscall
    
    beq $v0, 1, robar_j1
    j plantarse_j1

robar_j1:
    li $v0, 42               # Random card [1-10]
    li $a1, 10
    syscall  
    addi $t1, $a0, 1
    
    add $s2, $s2, $t1
    
    li $v0, 4
    la $a0, mensaje_acción_jugador_roba
    syscall
    
    li $v0, 1
    move $a0, $t1
    syscall
    
    jr $ra

plantarse_j1:
    li $v0, 4
    la $a0, mensaje_acción_jugador_planta
    syscall
    
    # Si ambos plantados, comparar
    bnez $s6, comparar_puntajes
    
    li $s6, 1                # Marcar que J1 se plantó
    jr $ra

jugador2_turno:
    # Mostrar info
    li $v0, 4
    la $a0, mensaje_turno_jugador2
    syscall
    
    li $v0, 4
    la $a0, mensaje_puntaje_jugador2
    syscall
    
    li $v0, 1
    move $a0, $s3
    syscall
    
    # Lógica IA
    blt $s3, 15, robar_j2    # <15 siempre roba
    
    li $v0, 42               # 15-17: 70% robar
    li $a1, 100
    syscall
    li $t0, 70
    blt $a0, $t0, robar_j2
    
    j plantarse_j2           # ?18 siempre planta

robar_j2:
    li $v0, 42               # Random card [1-10]
    li $a1, 10
    syscall  
    addi $t1, $a0, 1
    
    add $s3, $s3, $t1
    
    li $v0, 4
    la $a0, mensaje_acción_jugador2_roba
    syscall
    
    li $v0, 1
    move $a0, $t1
    syscall
    
    jr $ra

plantarse_j2:
    li $v0, 4
    la $a0, mensaje_acción_jugador2_planta
    syscall
    
    # Si ambos plantados, comparar
    bnez $s6, comparar_puntajes
    
    li $s6, 1                # Marcar que J2 se plantó
    jr $ra

jugador1_pasado:
    li $v0, 4
    la $a0, mensaje_perdedor_juego
    syscall
    j fin

jugador2_pasado:
    li $v0, 4
    la $a0, mensaje_ganador_juego
    syscall
    j fin

comparar_puntajes:
    bgt $s2, 21, jugador1_pasado
    bgt $s3, 21, jugador2_pasado
    
    beq $s2, $s3, empate
    bgt $s2, $s3, jugador1_gana
    j jugador2_gana

jugador1_gana:
    li $v0, 4
    la $a0, mensaje_ganador_juego
    syscall
    j fin

jugador2_gana:
    li $v0, 4
    la $a0, mensaje_perdedor_juego
    syscall
    j fin

empate:
    li $v0, 4
    la $a0, mensaje_empate
    syscall

fin:
    li $v0, 10
    syscall