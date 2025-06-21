.data
mazo:   .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10  # Mazo de 22 cartas (2 copias de cada carta)

    .text
    .globl main
    
# Función principal
main:
    # Se inicializa el mazo
    jal inicializar_mazo
    
    # Aleatorizar el mazo
    jal aleatorizar_mazo
    
    # Repartir las cartas
    jal repartir_cartas
    
    
    li $v0, 10            
    syscall             
    
# Función para inicializar el mazo
inicializar_mazo:
    #la: load address -> la carga en $s0 la dirección de memoria de mazo. Este registro $s0 ahora contiene la dirección 
    # donde empieza el arreglo del mazo. Después, puedes acceder a los valores con lw usando esa dirección.
    
    la $s0, mazo          # Cargar la dirección de la variable "mazo" en $s0
   
    # Regresamos a la función que llamó a "inicializar_mazo"
    jr $ra

    
# Funcion para aleatorizar el mazo
aleatorizar_mazo: 
	#Obtener el contador de ciclos (Semilla)
	mfc0 $t8, $9
	
	# Definir las constantes para el LCG
    	li $s7, 1664525       # Multiplicador (a)
    	li $s6, 1013904223    # Incremento (c)
    	li $s5, 4294967296    # M�dulo (m)
    	    	    	
    	# Aleatorizar el mazo intercambiando cartas
    	li $t5, 22            # Tama�o del mazo (22 cartas)
    	li $t6, 0             # Contador de intercambios
aleatorizar_mazo_loop:
	# Generar n�mero aleatorio (X_1) usando el contador de ciclos (X_0)
    	mul $t3, $s7, $t8     # X_0 * a
    	add $t3, $t3, $s6     # (X_0 * a + c)
    	divu $t3, $s5         # (X_0 * a + c) / m
    	mfhi $t4              # Obtener el residuo
    	move $t8, $t4         # X_1
    	
    	#Generar el primer indice a partir de (X_1)
    	move $t9, $t8
    	divu $t9, $t5
    	mfhi $t9	# indice entre [0,21]
    	
    	# Generar el segundo numero aleatorio (X_2) tomando como semilla (X_1)
    	mul $t7, $s7, $t8
    	add $t7, $t7, $s6
    	divu $t7, $s5
    	mfhi $t7	# X_2
    	
    	#Generar el segundo indice a partir de (X_2)
    	move $t8, $t7
    	divu $t7, $t5
    	mfhi $t7 	# indice entre [0,21]
    	
    	# Logica de intercambiar las cartas (Falta implementar correctamente) : 
    	#la $s0, mazo          # Direcci�n del mazo
    	#lw $s7, 0($s0)        # Cargar carta en mazo[t9]
    	#lw $s6, 4($s0)        # Cargar carta en mazo[t8]
    	#sw $s6, 0($s0)        # Guardar carta en mazo[t9]
    	#sw $s7, 4($s0)        # Guardar carta en mazo[t8]
    	
    	# Incrementar el contador de intercambios
    	addi $t6, $t6, 1      # Incrementar el contador de intercambios
    	slti $t0, $t6, 15      # Si $t6 < 15, $t0 = 1; de lo contrario, $t0 = 0
	bne $t0, $zero, aleatorizar_mazo_loop  # Si $t0 != 0 (es decir, $t6 < 15), salta a "aleatorizar_mazo_loop"
    	jr $ra                # Regresar a quien llam� a aleatorizar_mazo
    
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
