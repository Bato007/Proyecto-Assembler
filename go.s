/*
    Universidad del Valle de Guatemala
    Organizacion de Computadoras y Assembler
    Seccion 10

    Julio Herrera 19402
    Brandon Hernandez 19376

    Juego GO!
    Este juego consiste en que dos jugadores tendran fichas, uno "X" y el otro "O".
    El objetivo es convertir las fichas del otro jugador en fichas tuyas.
    Para ello debes de encerrar las fichas del otro jugador de manera horizontal o vertical.
    Proximamente... diagonal
*/

@PROGRAMA
.global main
.func main
main:


    /* Imprime el menu */
    /*LDR R0, =draw
    BL puts
    LDR R0, =title
    BL puts
*/
    @--Alias principales--
    cont_main .req R8

	@ Moviendo el valor 1 al contador r8
	mov cont_main, #1

@---EMPIEZA EL JUEGO---
ciclo:

    @--Imprimir tablero--
    LDR R0, =f_enter
    BL puts
    MOV R0, cont_main
    BL get_player_by_turn
	mov r10, r0				@Se obtiene el turno del jugador para utilizarlo mas adelante
    MOV R1, R0
    LDR R0, =turno_player
    BL printf
    MOV R1, cont_main
    LDR R0, =turno_no
    BL printf
    LDR R0, =f_enter
    BL puts
    BL imprimir_tablero

	@--Pidiendole al usuario la fila y columna--
    LDR R0, =msg_ingreso
    BL puts

	LDR R0,=f_entrada_s         /* R0 contiene el formato de ingreso */
	LDR R1,=entrada_actual    /* R1 contiene direccion donde almacena dato leido */
	BL scanf
    
    @--Para saber si se escribieron mas de 2 caracteres
    @--si el numero Hex en la direccion no es 0, es porque se escribio algo mas
    LDR R1,=entrada_actual
    LDRB R1, [R1, #2]
    CMP R1, #0
    BNE ingreso_cantidad_invalida

    @--Obteniendo las posiciones de lo ingresado por el usuario
    BL get_positions        /* R0 obtiene la fila, R1 obtiene la columna */
    CMP R0, #9
    BEQ ingreso_casilla_invalida
    CMP R1, #9
    BEQ ingreso_casilla_invalida
	
    MOV R9, R0      /* Para usarlo en el siguiente bloque, y determinar que direccion de fila cargar */
	mov r12, r1
	
	add r9, #1
	mov r1, r9
	ldr r0, =pos_lateral
	bl printf
	
	mov r1, r12
	ldr r0, =pos_lateral
	bl printf

	mov r1, r12

	@--Metiendo los datos al tablero
	/*
	r9 el numero de fila que eligio el usuario - 1 (ejm. A2 -> r9 = 1)
	r10 el numero del turno
	*/
	@-Fila uno-
	cmp r9, #0
	ldreq r0, =fila_uno
		
	@-Fila dos-
	cmp r9, #1
	ldreq r0, =fila_dos
	
	@-Fila tres-
	cmp r9, #2
	ldreq r0, =fila_tres
	
	@-Fila cuatro-
	cmp r9, #3
	ldreq r0, =fila_cuatro
	
	@-Fila cinco-
	cmp r9, #4
	ldreq r0, =fila_cinco
	
	@--MOVIENDO LA POSICION DEL VECTOR--
	mov r2, #4			
	sub r1, r1, #1	@ Se le resta 1, porque el usuario ingresa (columna 1)
	mul r2, r1		@ Indica cuanto se tiene que mover 
	add r0, r2		@ Se mueve n espacios por el arrego r0
	
	ldr r4, [r0]	@ Moviendo el valor actual en memoria a r0
	
	cmp r4, #0x2D		@ Verificando que no este ocupada
	bne ingreso_ocupado
	
	@ Agregando al tablero una X o una O
	cmp r10, #1
	ldreq r10, = ficha_uno		@ 'X'
	ldrne r10, = ficha_dos		@ 'O'
	
	ldr r10, [r10]				@ Obteniendo el valor 
	str	r10, [r0]				@ Metiendo 'X' o 'O' al arreglo 
	
	@ Pasando los datos para poder cambiar las 'fichas'
	mov r2, r10	@ Mete el valor de la ficha
	mov r0, r11	@ Metiendo la fila que corresponde
	
	@ Cambiando las fichas por fila
	@bl cambio_fila
	
	
	
	@--Sumandole 1 al turno y comparando si ya llego a 25--
	add cont_main, #1
	cmp cont_main, #26

	
	bne ciclo
	beq fin

@---INGRESO INVALIDO---
ingreso_casilla_invalida:
	ldr r0, =mensaje_error_casilla
	bl puts

	b ciclo

ingreso_cantidad_invalida:
	ldr r0, =mensaje_error_cantidad
	bl puts

    LDR R1,=entrada_actual
    MOV R2, #0
    STRB R2, [R1, #2]

	b ciclo

ingreso_ocupado:
	ldr r0, =mensaje_error_ocupado
	bl puts

	b ciclo

@---FIN DEL PROGRAMA---
fin:

	.unreq cont_main

    MOV R7, #1      /* R7 = 1 : Salida SO */
    SWI 0

@SUBRUTINAS LOCALES

/*
	Cambia las fichas de dicha fila
	Param: r0 -> La direccion de memoria del arreglo (fila)
	r1 -> La columna en la que esta (en este caso no sirve, pero es para el resto)
	r2 -> El tipo de ficha que se puso en este turno 
	r3 -> *No hay requerimiento
	Autor: Brandon Hern?ndez
	Return: no retorna nada, pero si cambia algo en direccion
*/
cambio_fila:
	push {r4-r12, lr}

	@ Guardando esto para poder manipular luego r0 
	mov r4, r0
	mov r5, #0		@ Contador
	mov r6, #5		@ Primer dato que se parece a la ficha
	mov r7, #0		@ Ultimo dato qeu se parece a la ficha

	cambio_ficha:
		
		ldr r9, [r4]	@ Obteniendo el valor en memoria de r0
		
		cmp r9, r2		@ Comparando para ver si es la ficha buscada
		bne skip
		
		@ Aqu? ya se sabe que es la ficha buscada
		cmp r6, r5		@ Comparando el contador para saber si es mas peque?o
		movgt r6, r5	@ Moviendo si r6 > r5, entonces r6 = r5
		
		cmp r7, r5 		@ Comprobando el contador para saber si es mas grande
		movlt r7, r5 	@ Moviendo si r7 < r5, entonces r7 = r5
	
	skip:	
		add r5, r5, #1	@ Sumandole uno al contador
		cmp r5, #5
		addne r4, #4		@ Agregandole 4 a la direccion de memoria 
		bne cambio_ficha

	@ Ahora se cambian las fichas
	mov r4, r0				@ Regresando a r0 la posicion original
	mov r10, #4			@ Moviendo a r10 #4 porque la pendejada no deja multiplicar solo asi
	mul r6, r10			@ Para saber cuanto se tiene que mover 
	mul r7, r10			@ Para saber hasta donde se tiene que mover 
	add r4, r6
	
	ciclo_cambio_fila:
		add r4, #4		@ Cambiando de posicion de r0 al siguiente valor
				
		cmp r7, r6		@ Verificando si ya esta en la misma posicion 
		beq fin_cambio_filas
		
		add r6, #4		@ Sumandole al contador 
		
		@--Comparando si esta vacia o no--
		ldr r9, [r4]		@ Obteniendo el valor en memoria de r0
		cmp r9, #0x2D		@ Verificando que no este ocupada
		strne r2, [r4]		@ Guardando la nueva ficha
		
		b ciclo_cambio_fila
	
	fin_cambio_filas:
		pop {r4-r12, pc}


/*
Subrutina que imprime la informacion del tablero actual
*/
imprimir_tablero:
    cont_arr_it .req R7
    cont_pos_it .req R4             /* Contador de posiciones (por cada arreglo) */
    dir_arr_it .req R5
    MOV cont_arr_it, #0
    LDR dir_arr_it, =columnas_indice
    ciclo_column_ind:
        LDRB R1, [dir_arr_it]
        LDR R0, =encabezado_tablero
        PUSH {LR}
        BL printf
        POP {LR}
        ADD dir_arr_it, #2
        ADD cont_arr_it, #1
        CMP cont_arr_it, #6
        BLT ciclo_column_ind
    PUSH {LR}
    LDR R0, =separacion
    BL puts
    POP {LR}
    MOV cont_arr_it, #1
    MOV cont_pos_it, #1
    LDR dir_arr_it, =fila_uno
    ciclo_matriz:
        @--Imprimir indicador de fila
        CMP cont_pos_it, #1
        BNE contenido_tbl
        MOV R1, cont_arr_it
        LDR R0, =pos_lateral
        PUSH {LR}
        BL printf
        POP {LR}
        ADD cont_pos_it, #1
        B ciclo_matriz
        @--Imprimir celdas
        contenido_tbl:
            LDR R1, [dir_arr_it]
            LDR R0, =casilla
            PUSH {LR}
            BL printf
            POP {LR}
            ADD dir_arr_it, #4
            @--Comprobar final e imprimir separador
            ADD cont_pos_it, #1
            CMP cont_pos_it, #7
            BLT ciclo_matriz
            MOV cont_pos_it, #1
            ADD cont_arr_it, #1
            PUSH {LR}
            LDR R0, =separacion
            BL puts
            POP {LR}
            CMP cont_arr_it, #6
            BLT ciclo_matriz
    MOV PC, LR

/*
Subrutina que devuelve el turno del jugador segun el numero de turno
R0 <- El numero de turno
R0 -> 1 si es turno de Player1 y 2 si es turno de Player2
*/
get_player_by_turn:
    AND R2, #0              /* Contador de n divisores */
    AND R3, #0              /* Inicializa el cociente */
    
    ciclo_division:
        ADD R2, #2          /* Suma para encontrar el maximo */
        ADD R3, #1          /* Va contando las veces que cabe el divisor en el dividendo */
        CMP R2, R0          /* Compara el divisor con el dividendo */
        BLT ciclo_division  /* Si es menor el dividendo vuelve al ciclo */
        SUBGT R3, #1        /* Solo si es mayor le resta 1 al contador ya que se habia pasado */
        SUBGT R2, #2
 
    SUB R0, R2          /* Devuelve el residuo */
    CMP R0, #0
    MOVEQ R0, #2
    MOV PC, LR              /* Regresa Link Register en Program Counter */

/*
Subrutina que convierte lo ingresado por el usuario a posiciones de array y en array y a la direccion especifica
R0 -> numero de fila (array que se eligio)
R1 -> numero de columna (posicion en array que se eligio)
NOTA: Devuelve index desde cero, ej. Si se ingresa C4, para C devuelve 2 y para 4 devuelve 3.
NOTA: Si devuelve 9 en alguna de las filas o columnas, significa que se ingreso invalida.
*/
get_positions:
    LDR R2, =entrada_actual
    LDRB R2, [R2, #1]
    @--Obtener numero de fila (array que se eligio)
    SUB R3, R2, #0x31      /* Se le resta en Hex para obtener bien el index del arreglo */
    CMP R3, #4
    MOVGT R3, #9
    CMP R3, #0
    MOVLT R3, #9
    CMP R3, #9
    BEQ fin_gp
    @--Obtener numero de columna (posicion en array), por medio de la letra
    LDR R2, =entrada_actual
    LDRB R2, [R2]
    LDR R4, =columnas_indice
    MOV R5, #0      /* Contador */
    ciclo_gp:
        CMP R5, #5
        MOVEQ R5, #9
        BEQ fin_gp
        LDRB R6, [R4]
        CMP R6, R2
        ADDNE R5, #1
        ADDNE R4, #2
        BNE ciclo_gp
    fin_gp:
        MOV R0, R3
        MOV R1, R5
        CMP R1, #9      /* Cuando el usuario solo ingresa un caracter, R1 termina siendo el numero 70032 */
        MOVGT R1, #9    /* Entonces se comprueba si es mayor a 9 y si lo es, se coloca 9 */
        MOV PC, LR

@---DATOS----------------------------------------------------------------------------
.data
	
	@---TABLERO GO----------
    @---0x2D = Un guion ' - ' en ASCII
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
    turno_no:
        .asciz  "\t\tTurno Nº. %d"
	
	@--Fichas--
	ficha_uno:
		.asciz "X"
	ficha_dos:
		.asciz "O"
	
    @--Mensajes--
	mensaje_error_casilla:
		.asciz "Ingreso invalido. La casilla que ingresaste no existe"
    mensaje_error_cantidad:
		.asciz "Ingreso invalido. Ingresaste mas caracteres de los debidos"
    mensaje_error_ocupado:
		.asciz "Ingreso invalido. Esta casilla esta ocupada"
    msg_ingreso:
        .asciz  "\nIngresa la direccion de la casilla que quieres ingresar (ej. B3)"

    entrada_actual:
        .asciz "Z9"
    catch_error:
        .word 0

    @--Formatos de salida--
    f_entrada_2s:
        .asciz  "%2s"
    f_entrada_s:
        .asciz  "%s"
    f_enter:
        .asciz  "\n"

/*
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
*/