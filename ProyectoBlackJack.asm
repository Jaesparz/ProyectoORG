#autores: Josue Esparza y Jorge Bravo

# Mensajes de texto para mostrar información al jugador
# Cada etiqueta es la dirección donde comienza la cadena en memoria.
# Utilizamos syscalls para imprimir estas cadenas.

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


#programa principal (el main)
main:
    # Aqui es donde se inicializan los puntajes para cada jugador
    li $s2, 0    #jugador 1
    li $s3, 0    #jugador 2
    li $s4, 0    # para indice del mazo (ya no es usado porque ya no se hace la funcion matematica planeada para lo de raprtir cartas)

    #Se llama a la funcion repartir_cartas para repartir dos cartas iniciales a cada jugador
    jal repartir_cartas


#LAZO para intercambiar turnos
lazo:
    # Turno jugador1 (NOSOTROS :D)
    jal jugador1_turno
    bgt $s2, 21, jugador1_pasado  # verificar si se pasa de 21, si lo hace pierde y la maquina gana :(.

    # Turno de la máquina 
    jal jugador2_turno
    bgt $s3, 21, jugador2_pasado  # verificar si se pasa de 21, si lo hace NOSOTROS GANAMOS y el pierde.

    # Continuar juego con ayuda de este lazo
    j lazo


# Se reparten dos cartas aleatorias (del 1 al 10)  cada jugad
repartir_cartas:
    li $t5, 2                # 2 cartas por jugador (es como un contador de cartas a repartir)

repartir_j1:
    li $v0, 42               # como un Random int [1-10] de python, proporcionado por la ingenieria Arias
    li $a1, 10		     
    syscall                  # [0-9]
    addi $t1, $a0, 1         # [1-10]
    add $s2, $s2, $t1       # Sumar la carta al puntaje
    
    addi $t5, $t5, -1          #decrementar el contador
    bnez $t5, repartir_j1  # si el contador t5 != 0, repetimos la reparticion
    
    li $t5, 2                # Reset contador
    
repartir_j2:
    li $v0, 42               # El mismo proceso aplicado en repartir_j1 aplicamos para el j2
    li $a1, 10
    syscall  
    addi $t1, $a0, 1
    add $s3, $s3, $t1
    
    addi $t5, $t5, -1
    bnez $t5, repartir_j2
    
    jr $ra          #aqui si ya volvemos al main cuando ya se repartio a los dos 



#TURNOS
jugador1_turno:
    # Aqui se muestra el encabezado del turno
    li $v0, 4
    la $a0, mensaje_turno_jugador1     #¿POR QUE USAMOS LOAD ADDRESS?, por que es mas sencillo cargar asi a0 en la direccion de la cadena para imprimirla
    syscall                            #llamamos al sistema de la mano del valor cargado previamente
    
    
    #Aqui se muestra el puntaje actual de NOSOTROS
    li $v0, 4
    la $a0, mensaje_puntaje   
    syscall
    
    li $v0, 1                        
    move $a0, $s2			#Movemos el puntaje que esta en s2 a a0
    syscall                             #e imprimimos ese entero
    
    
    
    # Preuntar la decision, si nos plantamos o pedimos carta 
    
    li $v0, 4
    la $a0, mensaje_decision            # Se ingresa 1 o 0 por conla y se guarda en v0
    syscall
    
    li $v0, 5
    syscall
    
    beq $v0, 1, robar_j1      #Si pone 1, pasamos a la funcion de robar carta
    j plantarse_j1	# si pone 0, nos saltamos a la accion de plantarse	

robar_j1:
    li $v0, 42               # Random card [1-10]
    li $a1, 10
    syscall  
    addi $t1, $a0, 1  # [1-10]
    
    add $s2, $s2, $t1  #se añade al puntaje la carta que nos salga
    
    li $v0, 4
    la $a0, mensaje_acción_jugador_roba   #mostramos los mensajes de las acciones
    syscall
    
    li $v0, 1
    move $a0, $t1   #El valor de carta en t1 lo pasamos a a0
    syscall
    
    jr $ra     #FIN DE TURNO

plantarse_j1:
    li $v0, 4
    la $a0, mensaje_acción_jugador_planta   #Mensaje que se muestra cuando el jugador se planta
    syscall
    
    #Aqui es donde se guarda en s6 si es que esta plantado (=1)
    
    bnez $s6, comparar_puntajes #Si ya estaba plantado, comparar y  decidir ganador, != 0
    
    li $s6, 1    # Marcar que nos plantamos
    jr $ra   #FIN DEL TURNO DE J1

jugador2_turno:
    # Mostrar info
    li $v0, 4
    la $a0, mensaje_turno_jugador2
    syscall
    
    
    #mostrar puntaje
    li $v0, 4
    la $a0, mensaje_puntaje_jugador2
    syscall
    
    li $v0, 1
    move $a0, $s3
    syscall
    
    # Aqui viene el intento de hacer una IA basica
    
    #jugaremos las logicas a base del puntaje del jugador 2 (s3)
    
    blt $s3, 15, robar_j2    # <15 siempre roba
    
    li $v0, 42               # 15-17: 70% robar
    li $a1, 100
    syscall
    li $t0, 70
    blt $a0, $t0, robar_j2     # <70 se roba, hay que jugar con la suerte
    
    j plantarse_j2         # >= 70, se planta

robar_j2:
    li $v0, 42               # Se usa lo del random card [1-10] y la misma logica usada en robar_j1
    li $a1, 10
    syscall  
    addi $t1, $a0, 1
    
    add $s3, $s3, $t1
    
    #mostrar el mensaje y el valor del puntaje
    li $v0, 4
    la $a0, mensaje_acción_jugador2_roba
    syscall
    
    li $v0, 1
    move $a0, $t1
    syscall
    
    jr $ra

#mensaje de plantarse de la maquina
plantarse_j2:
    li $v0, 4
    la $a0, mensaje_acción_jugador2_planta
    syscall
    
    #Aqui aplicar la logica del s6 = 1 (esta uno plantado)
    bnez $s6, comparar_puntajes     #si ya esta el otro plantado tambien, se procede a la comparacion de puntajes
    
    li $s6, 1                # Marcar que J2 se plantó
    jr $ra


#AQUI SE MANEJARAN LOS CASOS FINALES

#si j1 se pasa
#si j1 se pasa de 21 (puntaje >21) mostrará por pantalla que perdimos y saltará al fin del juego
jugador1_pasado: 
    li $v0, 4
    la $a0, mensaje_perdedor_juego
    syscall
    j fin

#si j2 se pasa
#si j2 se pasa de 21 (puntaje >21) mostrará por pantalla que ganamos y saltará al fin del juego
jugador2_pasado:
    li $v0, 4
    la $a0, mensaje_ganador_juego
    syscall
    j fin

#aqui es donde sucede la comparacion y se decide quien gana
comparar_puntajes:
    bgt $s2, 21, jugador1_pasado
    bgt $s3, 21, jugador2_pasado
    
    beq $s2, $s3, empate
    bgt $s2, $s3, jugador1_gana
    j jugador2_gana


#aqui es donde mostrará el mensaje en caso de que gane el j1 y dará un salto al fin del juego
jugador1_gana:
    li $v0, 4
    la $a0, mensaje_ganador_juego
    syscall
    j fin

#aqui es donde mostrará el mensaje en caso de que gane el j2 y dará un salto al fin del juego
jugador2_gana:
    li $v0, 4
    la $a0, mensaje_perdedor_juego
    syscall
    j fin


#en caso de que el puntaje sea igual en ambos jugadores se dará un mensaje de empate y terminará el juego
empate:
    li $v0, 4
    la $a0, mensaje_empate
    syscall


#Aqui es donde terminan todas mis acciones (en caso de que no haya empate) y se terminará el juego
fin:
    li $v0, 10
    syscall
