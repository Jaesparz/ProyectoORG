.data
mazo:   .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10  # Mazo de 22 cartas (2 copias de cada carta)

mensaje_decision: .asciiz "�Qu� deseas hacer? (1 = Pedir carta, 0 = Plantarse): "
mensaje_turno_jugador1: .asciiz "Es el turno del Jugador 1.\n"
mensaje_turno_jugador2: .asciiz "Es el turno del Jugador 2 (M�quina).\n"
mensaje_ganador_juego: .asciiz "�Ganaste! �Felicidades! \n"
mensaje_perdedor_juego: .asciiz "Perdiste. �Intenta de nuevo! \n"
mensaje_puntaje: .asciiz "Tu puntaje actual es: "
mensaje_puntaje_jugador2: .asciiz "El puntaje de Jugador 2 es: "
mensaje_acci�n_jugador_roba: .asciiz "El jugador rob� una carta. "
mensaje_acci�n_jugador_planta: .asciiz "El jugador se planta. "
mensaje_acci�n_jugador2_roba: .asciiz "La m�quina rob� una carta. "
mensaje_acci�n_jugador2_planta: .asciiz "La m�quina se planta. "

.text
.globl main

# Funci�n principal
main:
    # Inicializaci�n
    li $s2, 0                  # Puntaje del jugador 1 (Usuario)
    li $s3, 0                  # Puntaje del jugador 2 (M�quina)
    li $s4, 0                  # �ndice de la carta actual en el mazo
    li $s5, 0                  # Contador de turnos (m�ximo de turnos)
    li $t0, 10                 # L�mite de turnos (10 turnos en total)

    # Repartir 2 cartas al jugador 1 y jugador 2
    jal repartir_cartas

game_loop:
    # Turno del jugador 1 (Usuario)
    jal manejar_decision_jugador1

    # Verificar si el jugador 1 se pas� de 21
    bgt $s2, 21, mensaje_perdedor  # Si el puntaje es mayor que 21, el jugador 1 pierde

    # Incrementar el contador de turnos
    addi $s5, $s5, 1

    # Si el turno alcanza el l�mite, se compara los puntajes
    bge $s5, $t0, comparar_puntajes

    # Turno del jugador 2 (M�quina)
    jal manejar_decision_jugador2

    # Verificar si el jugador 2 se pas� de 21
    bgt $s3, 21, mensaje_ganador  # Si el puntaje es mayor que 21, el jugador 2 pierde

    # Incrementar el contador de turnos
    addi $s5, $s5, 1

    # Si el turno alcanza el l�mite, se compara los puntajes
    bge $s5, $t0, comparar_puntajes

    # Volver al turno de jugador 1
    j game_loop

# Funci�n para repartir cartas
repartir_cartas:
    # Carta 1 al jugador 1
    lw $t0, mazo($s4)          # Cargar carta desde el mazo
    add $s2, $s2, $t0          # Sumar al puntaje del jugador 1
    addi $s4, $s4, 4           # Mover al siguiente �ndice en el mazo (avanzar 4 bytes)

    # Carta 1 al jugador 2
    lw $t1, mazo($s4)          # Cargar carta al jugador 2
    add $s3, $s3, $t1          # Sumar al puntaje del jugador 2
    addi $s4, $s4, 4           # Mover al siguiente �ndice en el mazo (avanzar 4 bytes)

    # Carta 2 al jugador 1
    lw $t2, mazo($s4)          # Cargar carta al jugador 1
    add $s2, $s2, $t2          # Sumar al puntaje del jugador 1
    addi $s4, $s4, 4           # Mover al siguiente �ndice en el mazo (avanzar 4 bytes)

    # Carta 2 al jugador 2
    lw $t3, mazo($s4)          # Cargar carta al jugador 2
    add $s3, $s3, $t3          # Sumar al puntaje del jugador 2
    addi $s4, $s4, 4           # Mover al siguiente �ndice en el mazo (avanzar 4 bytes)

    jr $ra

# Funci�n para manejar la decisi�n del jugador 1 (Usuario)
manejar_decision_jugador1:
    # Mostrar mensaje indicando que es el turno del jugador 1
    li $v0, 4                  # Syscall para imprimir cadena
    la $a0, mensaje_turno_jugador1    # Direcci�n del mensaje
    syscall

    # Mostrar el puntaje actual del jugador 1
    li $v0, 4                  # Syscall para imprimir cadena
    la $a0, mensaje_puntaje    # Direcci�n del mensaje
    syscall
    li $v0, 1                  # Syscall para imprimir entero
    move $a0, $s2              # Puntaje del jugador 1
    syscall

    # Mostrar mensaje para que el jugador decida
    li $v0, 4                  # Syscall para imprimir cadena
    la $a0, mensaje_decision   # Direcci�n de la cadena
    syscall

    # Leer la decisi�n del jugador 1 (1 = pedir carta, 0 = plantarse)
    li $v0, 5                  # Syscall para leer un entero
    syscall
    move $t0, $v0              # Guardar la decisi�n del jugador 1 (1 = pedir, 0 = plantarse)

    beq $t0, 1, pedir_carta1    # Si el jugador 1 elige "Pedir carta" (1)
    beq $t0, 0, plantarse1      # Si el jugador 1 elige "Plantarse" (0)

pedir_carta1:
    # El jugador 1 decide pedir carta
    lw $t1, mazo($s4)          # Cargar la siguiente carta
    add $s2, $s2, $t1          # Sumarla al puntaje del jugador 1
    li $v0, 4                  # Syscall para imprimir cadena
    la $a0, mensaje_acci�n_jugador_roba # Mensaje "El jugador 1 rob� una carta"
    syscall
    li $v0, 1                  # Syscall para imprimir valor de la carta robada
    move $a0, $t1              # Valor de la carta
    syscall
    addi $s4, $s4, 4           # Avanzar al siguiente �ndice en el mazo

    # Verificar si el jugador 1 se pas� de 21
    bgt $s2, 21, mensaje_perdedor  # Si el puntaje es mayor que 21, el jugador 1 pierde

    j game_loop                 # Volver al bucle principal

plantarse1:
    # El jugador 1 decide plantarse, termina su turno
    li $v0, 4                  # Syscall para imprimir cadena
    la $a0, mensaje_acci�n_jugador_planta # Mensaje "El jugador 1 se planta"
    syscall
    j game_loop                 # Ahora es el turno del jugador 2 (M�quina)

# Funci�n para manejar la decisi�n del jugador 2 (M�quina)
manejar_decision_jugador2:
    # Mostrar mensaje indicando que es el turno del jugador 2 (M�quina)
    li $v0, 4                  # Syscall para imprimir cadena
    la $a0, mensaje_turno_jugador2    # Direcci�n del mensaje
    syscall

    # Mostrar el puntaje actual del jugador 2
    li $v0, 4                  # Syscall para imprimir cadena
    la $a0, mensaje_puntaje_jugador2    # Direcci�n del mensaje
    syscall
    li $v0, 1                  # Syscall para imprimir entero
    move $a0, $s3              # Puntaje del jugador 2
    syscall

    # Decisi�n autom�tica: si el puntaje es menor de 17, pide carta
    blt $s3, 17, pedir_carta2

    # Si el puntaje es 17 o m�s, se planta
    j plantarse2

pedir_carta2:
    # El jugador 2 (M�quina) decide pedir carta
    lw $t1, mazo($s4)          # Cargar la siguiente carta
    add $s3, $s3, $t1          # Sumarla al puntaje del jugador 2
    li $v0, 4                  # Syscall para imprimir cadena
    la $a0, mensaje_acci�n_jugador2_roba # Mensaje "La m�quina rob� una carta"
    syscall
    li $v0, 1                  # Syscall para imprimir valor de la carta robada
    move $a0, $t1              # Valor de la carta
    syscall
    addi $s4, $s4, 4           # Avanzar al siguiente �ndice en el mazo

    # Verificar si el jugador 2 se pas� de 21
    bgt $s3, 21, mensaje_ganador  # Si el puntaje es mayor que 21, el jugador 2 pierde

    j game_loop                 # Volver al bucle principal

plantarse2:
    # El jugador 2 (M�quina) decide plantarse, termina su turno
    li $v0, 4                  # Syscall para imprimir cadena
    la $a0, mensaje_acci�n_jugador2_planta # Mensaje "La m�quina se planta"
    syscall
    j game_loop                 # Volver al bucle principal

# Funci�n para comparar puntajes
comparar_puntajes:
    # Verificar si el jugador 1 o jugador 2 se pas� de 21
    bgt $s2, 21, mensaje_perdedor  # Si el jugador 1 se pas�, pierde
    bgt $s3, 21, mensaje_ganador   # Si el jugador 2 se pas�, gana el jugador 1

    # Comparar los puntajes
    bge $s2, $s3, mensaje_ganador   # Si el puntaje del jugador 1 es mayor o igual, gana el jugador 1
    bgt $s3, $s2, mensaje_perdedor  # Si el puntaje del jugador 2 es mayor, gana el jugador 2

    # Si los puntajes son iguales, continuar
    j game_loop

mensaje_perdedor:
    li $v0, 4
    la $a0, mensaje_perdedor_juego
    syscall
    j end_game

mensaje_ganador:
    li $v0, 4
    la $a0, mensaje_ganador_juego
    syscall
    j end_game

end_game:
    # Terminar el juego
    li $v0, 10                 # Syscall para terminar el programa
    syscall

