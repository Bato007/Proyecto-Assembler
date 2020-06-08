/*
    Universidad del Valle de Guatemala
    Organizacion de Computadoras y Assembler
    Seccion 10

    Julio Herrera 19402
    Brandon Hernandez 19376

    Proyecto 3
    Temario - Juego GO!
    Este juego consiste en que dos jugadores tendran fichas, uno "X" y el otro "O".
    El objetivo es convertir las fichas del otro jugador en fichas tuyas.
    Para ello debes de encerrar las fichas del otro jugador de manera horizontal o vertical.
*/

@PROGRAMA
.global main
.func main
main:

    @--Imprime el menu--
    LDR R0, =draw
    BL puts
    LDR R0, =title
    BL puts

    @--Alias principales--
    cont_main .req R8
    fila .req R9
    columna .req R11
    turno_actual .req R10

	@--Moviendo el valor 1 al contador R8--
	MOV cont_main, #1

@---EMPIEZA EL JUEGO---
ciclo:

    @--IMPRIME EL TABLERO--
    LDR R0, =f_enter            @ Imprime un enter
    BL puts
    MOV R0, cont_main           @ Envia el numero de turno actual
    BL get_player_by_turn       @ Subrutina que devuelve qué turno de jugador es (1 o 2)
	MOV turno_actual, R0		@ Se obtiene el turno del jugador para utilizarlo mas adelante
    MOV R1, R0
    LDR R0, =turno_player       @ Se imprime que turno de jugador es
    BL printf
    MOV R1, cont_main
    CMP turno_actual, #1        @ Se compara si el turno es del jugador con ficha 'X'
    LDREQ R0, =ficha_uno
    LDRNE R0, =ficha_dos        @ Si no lo es, la ficha actual es 'O'
    LDRB R1, [R0]
    LDR R0, =turno_ficha        @ Se imprime la ficha del jugador actual
    BL printf
    MOV R1, cont_main
    LDR R0, =turno_no           @ Se imprime que turno del juego es
    BL printf
    LDR R0, =f_enter            @ Imprime un enter
    BL puts
    BL imprimir_tablero         @ Imprime el resto del tablero

	@--Pidiendole al usuario la fila y columna--
    LDR R0, =msg_ingreso        @ Imprime mensaje de ingreso de datos
    BL puts

	LDR R0, =f_entrada_2s       @ R0 contiene el formato de ingreso
	LDR R1, =entrada_actual     @ R1 contiene direccion donde almacena dato leido
	BL scanf
    
    /* Para saber si se escribieron mas de 2 caracteres.
    Si el numero Hex en la direccion indicada (2 adelante de lo ingresado por el usuario) no es 0,
    es porque se escribio algo mas */
    LDR R0, =entrada_actual
    LDRB R1, [R0, #2]               @ Dos posiciones adelante de lo ingresado por el usuario
    CMP R1, #0                      @ Comparar. Si no es 0, es porque se escribio de mas
    BNE ingreso_cantidad_invalida   @ Vuelve a colocar el espacio en memoria anterior a 0

    @--Obteniendo las posiciones de lo ingresado por el usuario--
    BL get_positions                @ R0 obtiene la fila, R1 obtiene la columna
    CMP R0, #9                      @ Si en la fila se obtiene 9, se ingreso una fila invalida
    BEQ ingreso_casilla_invalida
    CMP R1, #9                      @ Si en la columna se obtiene 9, se ingreso una columna invalida
    BEQ ingreso_casilla_invalida
	
    MOV fila, R0                    @ La fila la obtiene desde 0, ej. 1 = 0 ; 2 = 1 ...
	MOV columna, R1                 @ La columna la obtiene desde 1, ej. A = 1 ; B = 2 ...

	@--Obteniendo direccion ingresada por el usuario--

	@-Fila uno-
	CMP fila, #0
	LDREQ R0, =fila_uno

	@-Fila dos-
	CMP fila, #1
	LDREQ R0, =fila_dos

	@-Fila tres-
	CMP fila, #2
	LDREQ R0, =fila_tres

	@-Fila cuatro-
	CMP fila, #3
	LDREQ R0, =fila_cuatro

	@-Fila cinco-
	CMP fila, #4
	LDREQ R0, =fila_cinco

	MOV R12, R0 		@ Para saber la fila en la que esta 

	@--MOVIENDO LA POSICION DEL VECTOR--
	MOV R2, #4          @ Multiplicador para aumentar debidamente en la direccion
	SUB columna, #1	    @ Se le resta 1, porque el usuario ingresa (columna 1)
	MUL R2, columna		@ Indica cuanto se tiene que mover 
	ADD R0, R2		    @ Se mueve n espacios por el arrego R0
	
	LDR R4, [R0]	    @ Moviendo el valor actual en memoria a R0
	
	CMP R4, #0x2D		@ Verificando que no este ocupada
	BNE ingreso_ocupado
	
	@--Agregando al tablero una X o una O--
	CMP turno_actual, #1
	LDREQ turno_actual, =ficha_uno		@ Si es 1 es 'X'
	LDRNE turno_actual, =ficha_dos		@ Si es 2 es 'O'
	
	LDR R2, [turno_actual]				@ Obteniendo el valor 
	STR	R2, [R0]						@ Metiendo 'X' o 'O' al arreglo 
	
	@--Pasando los datos para poder cambiar las 'fichas'--
	MOV R0, R12	                    	@ Metiendo la fila que corresponde
	
	@-CAMBIO DE LAS FICHAS POR FILA
	LDR R2, [turno_actual]				@ Obteniendo el valor 
	BL cambio_fila
	
	@--CAMBIO DE LAS FICHAS POR COLUMNA
	MOV R1, columna
	BL convertir_columnas_a_filas		
	LDR R0, =fila_aux					@ Se obtiene la fia aux
	LDR R2, [turno_actual]				@ Obteniendo el valor
	BL cambio_fila						@ Se ordena la fila aux
	BL cambio_columna					@ Se cambia la fila por columna
	
	
	@--Sumandole 1 al turno y comparando si ya llego a 25--
	ADD cont_main, #1
	CMP cont_main, #26

	BNE ciclo   @ Mientras no haya llegado a 25, volver al ciclo
	BEQ fin

@---INGRESO INVALIDO---
ingreso_casilla_invalida:
	LDR R0, =msg_error_casilla
	BL puts

	B ciclo

ingreso_cantidad_invalida:
	LDR R0, =msg_error_cantidad
	BL puts

    LDR R1, =entrada_actual
    MOV R2, #0
    STRB R2, [R1, #2]

    LDR R0, =f_entrada_s      @ R0 contiene el formato de ingreso
	LDR R1, =catch_error      @ R1 contiene direccion para obtener todos los caracteres que se ingresaron de mas
	BL scanf

	B ciclo

ingreso_ocupado:
	LDR R0, =msg_error_ocupado
	BL puts

	B ciclo

@---FIN DEL PROGRAMA---
fin:

    BL imprimir_tablero     @ Imprime el tablero final
    BL who_won              @ Imprimir mensajes de ganador
    LDR R0, =f_enter        @ Imprime un enter
    BL puts

	.unreq cont_main
    .unreq fila
    .unreq columna
    .unreq turno_actual

    MOV R7, #1      @ R7 = 1 : Salida SO
    SWI 0


@SUBRUTINAS LOCALES

/*
	Cambia las fichas de dicha fila
	R0 <- La direccion de memoria del arreglo (fila)
	R1 <- La columna en la que esta (en este caso no sirve, pero es para el resto)
	R2 <- El tipo de ficha que se puso en este turno
	Autor: Brandon Hernandez
	Return: no retorna nada, pero si cambia algo en direccion
*/
cambio_fila:
	PUSH {R4-R12, LR}

	@ Guardando esto para poder manipular luego R0 
	MOV R4, R0
	MOV R5, #0		@ Contador
	MOV R6, #5		@ Primer dato que se parece a la ficha
	MOV R7, #0		@ Ultimo dato qeu se parece a la ficha

	cambio_ficha:
		
		LDR R9, [R4]	@ Obteniendo el valor en memoria de R0
		
		CMP R9, R2		@ Comparando para ver si es la ficha buscada
		BNE skip
		
		@ Aqu? ya se sabe que es la ficha buscada
		CMP R6, R5		@ Comparando el contador para saber si es mas peque?o
		MOVGT R6, R5	@ Moviendo si R6 > R5, entonces R6 = R5
		
		CMP R7, R5 		@ Comprobando el contador para saber si es mas grande
		MOVLT R7, R5 	@ Moviendo si R7 < R5, entonces R7 = R5
	
	skip:	
		ADD R5, R5, #1	@ Sumandole uno al contador
		CMP R5, #5
		ADDNE R4, #4	@ Agregandole 4 a la direccion de memoria 
		BNE cambio_ficha

	@ Ahora se cambian las fichas
	MOV R4, R0			@ Regresando a R0 la posicion original
	MOV R10, #4			@ Moviendo a R10 #4 porque la pendejada no deja multiplicar solo asi
	MUL R6, R10			@ Para saber cuanto se tiene que mover 
	MUL R7, R10			@ Para saber hasta donde se tiene que mover 
	ADD R4, R6
	
	ciclo_cambio_fila:	
		CMP R7, R6		@ Verificando si ya esta en la misma posicion 
		BEQ fin_cambio_filas
		
		ADD R4, #4		@ Cambiando de posicion de R0 al siguiente valor
		ADD R6, #4		@ Sumandole al contador 
		
		@--Comparando si esta vacia o no--
		LDR R9, [R4]		@ Obteniendo el valor en memoria de R0
		CMP R9, #0x2D		@ Verificando que no este ocupada
		STRNE R2, [R4]		@ Guardando la nueva ficha
		
		B ciclo_cambio_fila
	
	fin_cambio_filas:
		POP {R4-R12, PC}

@---CAMBIO DE COLUMNAS---

/*
	Se encarga de convertir la columna en fila 
	Param: r0 -> La direccion de memoria del arreglo (fila, pero es para el resto)
	r1 -> La columna en la que esta 
	r2 -> El tipo de ficha que se puso en este turno 
	r3 -> *No hay requerimiento
	Autor: Brandon Hernández
	Return: No retorna nada D:
*/
convertir_columnas_a_filas:
	PUSH {R4-R12, LR}
	
	@ Obteniendo la cantidad de movimientos que se deben de mover
	MOV R4, #4			@ Servira para mover por el arreglo
	MUL R4, r1
	
	@ Moviendo todas las filas a la columna correspondiente
	LDR R5, =fila_aux
	
	LDR R6, =fila_uno	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R6, [R6]
	STR R6, [R5]		@ Guardando un valor
	ADD R5, R5, #4		@ Pasando a la siguiente posicion
	
	LDR R6, =fila_dos	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R6, [R6]
	STR R6, [R5]		@ Guardando un valor
	ADD R5, R5, #4		@ Pasando a la siguiente posicion
	
	LDR R6, =fila_tres	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R6, [R6]
	STR R6, [R5]		@ Guardando un valor
	ADD R5, R5, #4		@ Pasando a la siguiente posicion
	
	LDR R6, =fila_cuatro	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R6, [R6]
	STR R6, [R5]		@ Guardando un valor
	ADD R5, R5, #4		@ Pasando a la siguiente posicion
	
	LDR R6, =fila_cinco	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R6, [R6]
	STR R6, [R5]		@ Guardando un valor
	
	POP {R4-R12, PC}

/*
	Cambia las fichas de dicha columna
	Param: r0 -> La direccion de memoria del arreglo (fila, pero es para el resto)
	r1 -> La columna en la que esta 
	r2 -> El tipo de ficha que se puso en este turno 
	r3 -> *No hay requerimiento
	Autor: Brandon Hernández
	Return: no retorna nada, pero si cambia algo en direccion
*/
cambio_columna:
	PUSH {R4-R12, LR}
	
	@ Obteniendo la cantidad de movimientos que se deben de mover
	MOV R4, #4			@ Servira para mover por el arreglo
	MUL R4, r1
	
	@ Moviendo todas las filas a la columna correspondiente
	LDR R5, =fila_aux
	
	LDR R6, =fila_uno	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R9, [R5]		@ Obteniendo el valor de la variable aux
	STR R9, [R6]		@ Guardando el valor en la fila correspondiente
	ADD R5, R5, #4		@ Pasando a la siguiente posicion
	
	LDR R6, =fila_dos	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R9, [R5]		@ Obteniendo el valor de la variable aux
	STR R9, [R6]		@ Guardando el valor en la fila correspondiente
	ADD R5, R5, #4		@ Pasando a la siguiente posicion
	
	LDR R6, =fila_tres	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R9, [R5]		@ Obteniendo el valor de la variable aux
	STR R9, [R6]		@ Guardando el valor en la fila correspondiente
	ADD R5, R5, #4		@ Pasando a la siguiente posicion
	
	LDR R6, =fila_cuatro	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R9, [R5]		@ Obteniendo el valor de la variable aux
	STR R9, [R6]		@ Guardando el valor en la fila correspondiente
	ADD R5, R5, #4		@ Pasando a la siguiente posicion
	
	LDR R6, =fila_cinco	@ Obteniendo la direccion y moviendos la cantidad deseada
	ADD R6, R6, R4		
	LDR R9, [R5]		@ Obteniendo el valor de la variable aux
	STR R9, [R6]		@ Guardando el valor en la fila correspondiente
	
	POP {R4-R12, PC}



/*
Subrutina que imprime la informacion del tablero actual.
No requiere parametros.
No retorna nada.
No hace cambios en memoria.
Autor: Julio Herrera
*/
imprimir_tablero:
    cont_arr_it .req R7                 @ Contador de arreglos
    cont_pos_it .req R4                 @ Contador de posiciones (por cada arreglo)
    dir_arr_it .req R5                  @ Direccion del arreglo
    MOV cont_arr_it, #0                 @ Se inicializa el contador de arreglos en 0, uso momentaneo
    LDR dir_arr_it, =columnas_indice    @ Primero se imprime el encabezado de las letras, por eso se apunta a ese arreglo

    @--Imprimiendo el indice de columnas -> A B C D E
    ciclo_column_ind:
        LDRB R1, [dir_arr_it]           @ Se carga el unico byte con la letra
        LDR R0, =encabezado_tablero     @ Formato para imprimir
        PUSH {LR}
        BL printf                       @ Se imprime guardando LR
        POP {LR}
        ADD dir_arr_it, #2              @ Cantidad a sumar para apuntar a la siguiente letra
        ADD cont_arr_it, #1             @ Se le suma al contador
        CMP cont_arr_it, #6             @ Para saber cuando ya se imprimieron las 5 letras
        BLT ciclo_column_ind

    @--Se imprime una separacion entre el indice de columnas y el resto del tablero
    PUSH {LR}
    LDR R0, =separacion
    BL puts
    POP {LR}

    @--Se imprime el resto del tablero
    MOV cont_arr_it, #1             @ Se reinicializa el contador en 1 (porque sirve tambien para el indice de filas)
    MOV cont_pos_it, #1             @ Se inicializa el contador en 1
    LDR dir_arr_it, =fila_uno       @ Apunta al primer arreglo (Primera fila)
    ciclo_matriz:
        @--Imprimir indicador de fila--
        CMP cont_pos_it, #1         @ Compara si es la primera posicion de cada arreglo
        BNE contenido_tbl           @ Si no lo es, ir a imprimir el contenido del tablero
        @ Si sí lo es, imprimir el indice de fila
        MOV R1, cont_arr_it         @ Se imprime segun el contador de arreglos
        LDR R0, =pos_lateral
        PUSH {LR}
        BL printf                   @ Se imprime guardando LR
        POP {LR}
        ADD cont_pos_it, #1         @ De igual forma se suma 1 al contador de posiciones del arreglo
        B ciclo_matriz

        @--Imprimir celdas--
        contenido_tbl:
            LDR R1, [dir_arr_it]    @ Carga el contenido en memoria de la direccion actual
            LDR R0, =casilla
            PUSH {LR}
            BL printf               @ Se imprime guardando LR
            POP {LR}
            ADD dir_arr_it, #4      @ Se suma para apuntar a la siguiente posicion del arreglo (fila) .word
            @--Comprobar final e imprimir separador--
            ADD cont_pos_it, #1     @ Sumar al contador de posiciones del arreglo
            CMP cont_pos_it, #7     @ Comparar con la ultima posicion del arreglo...
            BLT ciclo_matriz        @ Si no es la ultima posicion del arreglo, volver a imprimir
            @ Si es la ultima posicion del arreglo hacer...
            MOV cont_pos_it, #1     @ Volver a iniciar el contador de posiciones por arreglo
            ADD cont_arr_it, #1     @ Sumara al contador de arreglos
            PUSH {LR}
            LDR R0, =separacion
            BL puts                 @ Imprimir separacion, guardando LR
            POP {LR}
            CMP cont_arr_it, #6     @ Comparar si es el ultimo arreglo
            BLT ciclo_matriz        @ Si no es el ultimo arreglo, volver a imprimir

    .unreq cont_arr_it
    .unreq cont_pos_it
    .unreq dir_arr_it
    MOV PC, LR

/*
Subrutina que devuelve el turno del jugador segun el numero de turno
Practicamente se hace una division del turno en 2, si es par o impar. Con el residuo se determina de quien es el turno
R0 <- El numero de turno
R0 -> 1 si es turno de Player1 y 2 si es turno de Player2
Autor: Julio Herrera
*/
get_player_by_turn:
    AND R2, #0              @ Contador de n divisores
    AND R3, #0              @ Inicializa el cociente
    
    ciclo_division:
        ADD R2, #2          @ Suma para encontrar el maximo
        ADD R3, #1          @ Va contando las veces que cabe el divisor en el dividendo
        CMP R2, R0          @ Compara el divisor con el dividendo
        BLT ciclo_division  @ Si es menor el dividendo vuelve al ciclo
        SUBGT R3, #1        @ Solo si es mayor le resta 1 al contador ya que se habia pasado
        SUBGT R2, #2
 
    SUB R0, R2              @ Devuelve el residuo, si es impar el residuo es 1
    CMP R0, #0              @ Si es par, el residuo es 0
    MOVEQ R0, #2            @ Entonces es turno del jugador 2 y se mueve el valor 2
    MOV PC, LR              @ Regresa Link Register en Program Counter

/*
Subrutina que convierte lo ingresado por el usuario a posiciones de fila y columna
No requiere parametros, se toma el valor de memoria =entrada_actual.
R0 -> numero de fila (array que se eligio)
R1 -> numero de columna (letras) (posicion en array que se eligio)
NOTA: Devuelve index desde cero, ej. Si se ingresa C4, para C devuelve 2 y para 4 devuelve 3.
NUEVA NOTA: Para columnas, devuelve index desde 1. Si se ingresa C4, para C devuelve 3.
NOTA: Si devuelve 9 en alguna de las filas o columnas, significa que se ingreso invalida.
Autor: Julio Herrera
*/
get_positions:
    LDR R2, =entrada_actual @ Obtiene la direccion de lo ingresado por el usuario
    LDRB R2, [R2, #1]       @ Obtiene el numero que ingreso el usuario (fila)
    @--Obtener numero de fila (array que se eligio)
    SUB R3, R2, #0x31       @ Se le resta en Hex para obtener bien el index del arreglo
    CMP R3, #4              @ Si es mayor a 4, la fila no existe
    MOVGT R3, #9            @ Y se regresara 9
    CMP R3, #0              @ Si es menor a 0, la fila no existe
    MOVLT R3, #9            @ Y se regresara 9
    CMP R3, #9
    BEQ fin_gp              @ Si no existe la fila, ir a fin de una vez.

    @--Obtener numero de columna (posicion en array), por medio de la letra--
    LDR R2, =entrada_actual     @ Obtiene la direccion de lo ingresado por el usuario
    LDRB R2, [R2]               @ Obtiene la letra ingresada por el usuario (columna)
    LDR R4, =columnas_indice    @ Apunta al array de letras
    MOV R5, #1                  @ Contador de posicion. REGRESAR A 0 SI SE QUIERE VOLVER A CONTAR DESDE 0
    ciclo_gp:
        CMP R5, #6              @ Si ya se recorrio el arreglo y ninguna letra conincide...
        MOVEQ R5, #9            @ Lo ingresado es invalido y se regresa 9...
        BEQ fin_gp              @ Y se va a fin
        @--Si todavia esta buscando
        LDRB R6, [R4]           @ Obtener la letra del arreglo segun la direccion + offset
        CMP R6, R2              @ Si la letra ingresada por el usuario coincide con la letra del arreglo
                                @ no hacer nada, el contador indica la posicion de lo ingresado por el usuario
        ADDNE R5, #1            @ Si no coincide sumar 1 al contador
        ADDNE R4, #2            @ Si no coincide sumar 2 al arreglo para apuntar a la siguiente letra
        BNE ciclo_gp            @ Si no coincide, buscar en la siguiente letra del arreglo
    
    @--Fin de subrutina--
    fin_gp:
        MOV R0, R3      @ Mover lo encontrado para la posicion de fila a R0
        MOV R1, R5      @ Mover lo encontrado para la posicion de columna (el contador) a R1
        CMP R1, #9      @ Cuando el usuario solo ingresa un caracter, R1 termina siendo el numero 70032
        MOVGT R1, #9    @ Entonces se comprueba si es mayor a 9 y si lo es, se coloca 9
        MOV PC, LR

/*
Subrutina para determinar quien gana o pierde el juego.
Se cuentan la cantidad de cada tipo de fichas en cada posicion de los 5 arreglos
No requiere parametros.
No devuelve nada.
No hace cambios en memoria.
Autor: Julio Herrera
*/
who_won:
    LDR R0, =fila_uno   @ Apunta a la primera direccion
    MOV R4, #0          @ Contador de 'X'
    MOV R5, #0          @ Contador de 'O'
    MOV R3, #0          @ Contador de casillas

    @--Ciclo para contar las 'X' y 'O'
    ciclo_ww:
        LDRB R6, [R0]    @ Carga el contenido de la casilla actual
        CMP R6, #0x58   @ Compara si lo encontrado es una 'X'
        ADDEQ R4, #1    @ Si lo es, suma al contador de 'X'
        ADDNE R5, #1    @ Si no lo es, suma al contador de 'O'
        ADD R0, #4      @ Suma para apuntar a la siguiente casilla o arreglo (.word)
        ADD R3, #1      @ Suma 1 al contador de casillas
        CMP R3, #25     @ Comparar el contador con las 25 casillas
        BLT ciclo_ww    @ Mientras sea menor, seguir contando
    
    @--Imprimir resultados--
    @--Imprimir ganador o empate--
    CMP R4, R5              @ Comparar cantidad de 'X' con cantidad de 'O'
    MOVGT R1, #1            @ Si 'X' es mayor, mover 1 porque el jugador 1 gano
    MOVLT R1, #2            @ Si 'X' es menor, mover 2 porque el jugador 2 gano
    LDR R0, =msg_ganador
    LDREQ R0, =msg_empate   @ Si la cantidad de 'X' y 'O' son iguales, imprimir mensaje de empate
    PUSH {LR}
    BL printf               @ Imprimir lo debido, guardando LR
    POP {LR}
    @--Imprimir resultado para 'X'--
    MOV R1, R4              @ Mover la cantidad de 'X' a imprimir
    LDR R0, =msg_cant_p1
    PUSH {LR}
    BL printf               @ Imprimir lo debido, guardando LR
    POP {LR}
    @--Imprimir resultado para 'O'--
    MOV R1, R5              @ Mover la cantidad de 'O' a imprimir
    LDR R0, =msg_cant_p2
    PUSH {LR}
    BL printf               @ Imprimir lo debido, guardando LR
    POP {LR}
    @--Imprimir mensaje final--
    LDR R0, =msg_fin
    PUSH {LR}
    BL puts                 @ Imprimir lo debido, guardando LR
    POP {LR}
    MOV PC, LR

@DATOS
.data
	
	@---TABLERO GO----------
    @ 0x2D = Un guion ' - ' en ASCII
	fila_uno:
		.word 0x2D, 0x2D, 0x2D, 0x2D, 0x2D
	fila_dos:
		.word 0x2D, 0x2D, 0x2D, 0x2D, 0x2D
	fila_tres:
		.word 0x2D, 0x2D, 0x2D, 0x2D, 0x2D
	fila_cuatro:
		.word 0x2D, 0x2D, 0x2D, 0x2D, 0x2D
	fila_cinco:
		.word 0x2D, 0x2D, 0x2D, 0x2D, 0x2D

	@ Fila Auxiliar
	fila_aux:
		.word 0x2D, 0x2D, 0x2D, 0x2D, 0x2D

	@--Mostrar tablero go--
    columnas_indice:
        .asciz  "A","B","C","D","E"
	separacion:
		.asciz "\n--------------------------------------------"
    encabezado_tablero:
        .asciz  "\t%c"
    pos_lateral:
        .asciz  " %d "
    casilla:
        .asciz  " |   %c  "
    turno_player:
        .asciz  "Turno del jugador %d"
    turno_ficha:
        .asciz  "\tFicha: %c"
    turno_no:
        .asciz  "\tTurno Nº. %d"
	
	@--Fichas--
	ficha_uno:
		.word 0x58  @ La X
	ficha_dos:
		.word 0x4F  @ La O
	
    @--Mensajes--
	msg_error_casilla:
		.asciz "Ingreso invalido. La casilla que ingresaste no existe"
    msg_error_cantidad:
		.asciz "Ingreso invalido. Ingresaste mas caracteres de los debidos"
    msg_error_ocupado:
		.asciz "Ingreso invalido. Esta casilla esta ocupada"
    msg_ingreso:
        .asciz  "\nIngresa la direccion de la casilla que quieres ingresar (ej. B3)"

    @--Entrada actual del usuario por cada turno--
    entrada_actual:
        .asciz "Z9"
    catch_error:
        .word 0

    @--Resultados--
    msg_ganador:
        .asciz  "\nEl ganador es el jugador %d !"
    msg_empate:
        .asciz  "\Ha habido un empate!"
    msg_cant_p1:
        .asciz  "\nEl jugador 1 termino con %d fichas en el tablero"
    msg_cant_p2:
        .asciz  "\nEl jugador 2 termino con %d fichas en el tablero"
    msg_fin:
        .asciz  "\nSe acabo el juego. Gracias por jugar"

    @--Formatos de entrada/salida--
    f_entrada_s:
        .asciz  "%s"
    f_entrada_2s:
        .asciz  "%2s"
    f_enter:
        .asciz  "\n"

	@--ASCIIART--
	title:
        .asciz  "
   __          ________ _      _____ ____  __  __ ______   _______ ____  
   \\ \\        / /  ____| |    / ____/ __ \\|  \\/  |  ____| |__   __/ __ \\ 
    \\ \\  /\\  / /| |__  | |   | |   | |  | | \\  / | |__       | | | |  | |
     \\ \\/  \\/ / |  __| | |   | |   | |  | | |\\/| |  __|      | | | |  | |
      \\  /\\  /  | |____| |___| |___| |__| | |  | | |____     | | | |__| |
       \\/  \\/   |______|______\\_____\\____/|_|  |_|______|    |_|  \\____/ 
                                __________  __
                               / ____/ __ \\/ /
                              / / __/ / / / / 
                             / /_/ / /_/ /_/  
                             \\____/\\____(_)   
  _  ____  _____    _    ______   __  _____ ___    ____  _        _ __   _____ 
 (_)|  _ \\| ____|  / \\  |  _ \\ \\ / / |_   _/ _ \\  |  _ \\| |      / \\\\ \\ / /__ \\
 | || |_) |  _|   / _ \\ | | | \\ V /    | || | | | | |_) | |     / _ \\\\ V /  / /
/ /_|  _ <| |___ / ___ \\| |_| || |     | || |_| | |  __/| |___ / ___ \\| |  |_| 
\\___|_| \\_\\_____/_/   \\_\\____/ |_|     |_| \\___/  |_|   |_____/_/   \\_\\_|  (_) "

    draw:
        .asciz  "
                    ////////////////////////////////////////
                    ////////////////////////////////////////
                    ///////////////////////....:////////////
                    ////////////////////:........../////////
                    ///////////////////.............////////
                    //////////////////............,:.///////
                    //////////////////...............///////
                    //////////////////,..............///////
                    ///////////////////.............////////
                    /////////////////////.........8888888888
                    ///////8888888/////////////8888888888888
                    /////88888888888///////88888888888888888
                    ///888888888888888////888888888888888888
                    ///888888888888888../8888888888888888888
                    /////888888888888.//88888888888888888888
                    ///////88888888////888888888888888888888
                    //////==========///888888888888888888888
                    /////============//888888888888888888888
                    ////////======//////88888888888888888888"
