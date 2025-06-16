.data
mazo:   .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10  # Mazo de 20 cartas (2 copias de cada carta)

    .text
    .globl main
    
# Función principal
main:
    # Se inicializa el mazo
    jal inicializar_mazo  

    li $v0, 10            
    syscall             
    
# Función para inicializar el mazo
inicializar_mazo:
    #la: load address -> la carga en $s0 la dirección de memoria de mazo. Este registro $s0 ahora contiene la dirección 
    # donde empieza el arreglo del mazo. Después, puedes acceder a los valores con lw usando esa dirección.
    
    la $s0, mazo          # Cargar la dirección de la variable "mazo" en $s0
   
    # Regresamos a la función que llamó a "inicializar_mazo"
    jr $ra
    
# Función para repartir cartas
repartir_cartas:
    # Inicializamos las manos de jugador y crupier con 0
    li $s2, 0        
    li $s3, 0          

    # Repartir la primera carta al jugador
    lw $t0, 0($s0)     # Cargar la carta ;)
    add $s2, $s2, $t0  # Se agrega el valor al puntaje actual

    # Repartir la segunda carta al crupier
    lw $t1, 4($s0)     
    add $s3, $s3, $t1  

    # Repartir la tercera carta al jugador
    lw $t2, 8($s0)     # Cargar la carta en la tercera posición del mazo en $t2 (jugador recibe carta)
    add $s2, $s2, $t2  # Agregar el valor de la carta al puntaje del jugador

    # Repartir la cuarta carta al crupier
    lw $t3, 12($s0)    # Cargar la carta en la cuarta posición del mazo en $t3 (crupier recibe carta)
    add $s3, $s3, $t3  # Agregar el valor de la carta al puntaje del crupier

    # Terminar la función, regresamos a quien llamó a esta función
    jr $ra
    
    
calcular_puntaje:
    # Verificar si el puntaje del jugador es mayor que 21
    blez $s2, no_ajustar_as_jugador  
    
    # Verificar si el jugador tiene un As (es decir, si su puntaje > 21)
    # Necesitamos saber si alguna carta es un As (11 puntos)
    li $t0, 11              
    divu $s2, $t0           # Dividir el puntaje del jugador por 11
    mfhi $t1                # El residuo nos dice cuántos Ases tiene el jugador
    bnez $t1, ajustar_as_jugador # Si hay un As, pasamos a ajustarlo

no_ajustar_as_jugador:
    # Si no hay As, saltamos a la siguiente parte
    # Si el puntaje del jugador es mayor a 21, necesitamos hacer ajustes de As
    jr $ra    # Salimos 

ajustar_as_jugador:
    # Ajustar el As (convertir de 11 a 1)
    sub $s2, $s2, 10        # Restar 10 del puntaje del jugador para convertir el As de 11 a 1

    # Ahora, lo mismo para el crupier
    blez $s3, no_ajustar_as_crupier   #
    li $t2, 11              
    divu $s3, $t2           
    mfhi $t3                
    bnez $t3, ajustar_as_crupier   

no_ajustar_as_crupier:
    jr $ra    # Salimos 
ajustar_as_crupier:
    sub $s3, $s3, 10        
    jr $ra    # Regresar a la función que llamó
    
    
    
    
 # Función para gestionar la decisión del jugador (Pedir o Plantarse)
manejar_decision_jugador:
    # Mostrar el puntaje actual del jugador
    # (Aquí podríamos agregar un mensaje, pero en MIPS, eso no es tan directo)
    # Suponemos que el puntaje ya está en $s2 (puntaje del jugador)
    
    # Simular la entrada del jugador (Pedir o Plantarse)
    # Vamos a usar un valor fijo para la simulación
    # 1 = Pedir carta (Hit)
    # 0 = Plantarse (Stand)

    li $t0, 1      # Supongamos que el jugador elige "Pedir carta" (1)
    
    # Si el jugador elige "Pedir carta" (1)
    beq $t0, 1, pedir_carta

    # Si el jugador elige "Plantarse" (0)
    beq $t0, 0, plantarse

pedir_carta:
    # El jugador pide carta
    # Aquí simplemente llamamos a la función de repartir cartas
    jal repartir_cartas  # Llamar a la función de repartir cartas

    # Verificar si el puntaje del jugador excede 21 después de pedir la carta
    blez $s2, continuar_juego  # Si el puntaje <= 21, continuar el juego

    # Si el puntaje excede 21, el jugador pierde automáticamente
    # Aquí podríamos agregar un mensaje que indique que el jugador ha perdido.
    # Terminar el juego (el jugador pierde)
    li $v0, 10
    syscall

continuar_juego:
    # Si el jugador no se pasó de 21, regresa a la función principal para seguir jugando
    jr $ra

plantarse:
    # El jugador se planta, su turno termina, ahora es el turno del crupier
    # Aquí llamamos a la función del crupier para que empiece su turno.
    jal turno_crupier

    # Regresamos a la función que llamó a "manejar_decision_jugador"
    jr $ra
