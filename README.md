# Informe del Proyecto: Blackjack en Ensamblador Objetivo del Proyecto
El proyecto consiste en desarrollar un juego de Blackjack en lenguaje ensamblador (MIPS). 
Se implementará un juego entre un solo jugador y el crupier, donde el mazo de cartas será representado 
como un arreglo y se usarán números pseudo-aleatorios para repartir las cartas. 
Inicialmente, el mazo tendrá 26 cartas, con la posibilidad de escalar a 52 cartas si se dispone de tiempo adicional.
El puntaje objetivo para ganar será 17 o 18 puntos al principio, con la opción de cambiar a 21 puntos si el tiempo lo permite.


# Blackjack Simplificado

## Descripción
Un juego de Blackjack improvisado y optimizado donde:
- **Tú (Jugador 1)** decides si **pedir carta** o **plantarte**.
- **La máquina (Jugador 2)** juega automáticamente con una estrategia semi-aleatoria.
- **Gana quien se acerque más a 21 sin pasarse**.

## Reglas del Juego

1. **Objetivo**:  
   Sumar **21 puntos o el más cercano** sin pasarse.  
   Si te pasas de 21 (**"bust"**), pierdes automáticamente.

2. **Turnos**:  
   - **Jugador 1 (Tú)**:  
     - Ingresa `1` para **robar carta** o `0` para **plantarte**.  
   - **Jugador 2 (Máquina)**:  
     - **Si tiene <15 puntos**: Siempre roba.  
     - **Si tiene 15-17 puntos**: 70% de probabilidad de robar, 30% de plantarse.  
     - **Si tiene ≥18 puntos**: Siempre se planta.

3. **Fin del juego**:  
   - Cuando alguien se pasa de 21.  
   - Si ambos se plantan o se acaban los **10 turnos máximos**, gana quien tenga más puntos.

## Ejemplo de partida

--- Turno del Jugador 1 
Tu puntaje actual es: 12  
¿Qué deseas hacer? (1 = Pedir carta, 0 = Plantarse): 1  
Robaste una carta. Valor: 5  

--- Turno del Jugador 2 
Puntaje de la Máquina: 16  
La Máquina robó una carta. Valor: 8  (24 -> ¡Se pasó!)  

¡Ganaste!  


