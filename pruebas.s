
.global main
.func main
main:
	
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

	LDR R0,=f_entrada_s         /* R0 contiene el formato de ingreso */
	LDR R1,=entrada_actual    /* R1 contiene direccion donde almacena dato leido */
	BL scanf
    BL getchar

	mov r1, #2
	mov r9, #0
		
	@--Metiendo los datos al tablero
	
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
	
	mov r11, r0 		@ Para saber la fila en la que esta 
	
	@--MOVIENDO LA POSICION DEL VECTOR--
	mov r2, #4			
	sub r1, r1, #1	@ Se le resta 1, porque el usuario ingresa (fila 1)
	mul r2, r1		@ Indica cuanto se tiene que mover 
	add r0, r2		@ Se mueve n espacios por el arrego r0
	
	ldr r4, [r0]	@ Moviendo el valor actual en memoria a r0
	
	cmp r4, #0x2D		@ Verificando que no este ocupada
	bne ingreso_ocupado
	
	@@@ Agregando al tablero una X o una O
	cmp r10, #1
	ldreq r10, = ficha_uno		@ 'X'
	ldrne r10, = ficha_dos		@ 'O'
	
	ldr r10, [r10]				@ Obteniendo el valor 
	str	r10, [r0]				@ Metiendo 'X' o 'O' al arreglo 
	
	@ Pasando los datos para poder cambiar las 'fichas'
	mov r2, r10	@ Mete el valor de la ficha
	mov r0, r11	@ Metiendo la fila que corresponde
	
	@ Cambiando las fichas por fila
	bl cambio_fila
	
	@@@x
	@--Sumandole 1 al turno y comparando si ya llego a 25--
	add cont_main, #1
	cmp cont_main, #4
	bne ciclo
	beq fin

@---INGRESO INVALIDO---
ingreso_invalido:
	ldr r0, =mensaje_error
	bl puts
	b ciclo

@---INGRESO LUGAR LLENO EN EL TABLERO--- @@@
ingreso_ocupado:
	ldr r0, =mensaje_ocupado
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
	Autor: Brandon Hernández
	Return: no retorna nada, pero si cambia algo en direccion
*/
cambio_fila:
	push {r4-r12, lr}

	mov r12, r1 @X
	@ Guardando esto para poder manipular luego r0 
	mov r4, r0
	mov r5, #0		@ Contador
	mov r6, #5		@ Primer dato que se parece a la ficha
	mov r7, #0		@ Ultimo dato qeu se parece a la ficha

	cambio_ficha:
		
		ldr r9, [r4]	@ Obteniendo el valor en memoria de r0
		
		cmp r9, r2		@ Comparando para ver si es la ficha buscada
		bne skip
		
		@ Aquí ya se sabe que es la ficha buscada
		cmp r6, r5		@ Comparando el contador para saber si es mas pequeño
		movgt r6, r5	@ Moviendo si r6 > r5, entonces r6 = r5
		
		cmp r7, r5 		@ Comprobando el contador para saber si es mas grande
		movlt r7, r5 	@ Moviendo si r7 < r5, entonces r7 = r5
	
	skip:	
		add r5, r5, #1	@ Sumandole uno al contador
		cmp r5, #5
		addne r4, #4		@ Agregandole 4 a la direccion de memoria 
		bne cambio_ficha

	ldr r0, =pos_lateral
	mov r1, r6
	bl printf
	
	ldr r0, =pos_lateral
	mov r1, r7
	bl printf

	@ Ahora se cambian las fichas
	mov r4, r0				@ Regresando a r0 la posicion original
	mov r10, #4			@ Moviendo a r10 #4 porque la pendejada no deja multiplicar solo asi
	mul r6, r10			@ Para saber cuanto se tiene que mover 
	mul r7, r10			@ Para saber hasta donde se tiene que mover 
	add r4, r6
	
	
	ciclo_cambio_fila:
		cmp r7, r6		@ Verificando si ya esta en la misma posicion 
		beq fin_cambio_filas
		
		add r4, #4		@ Cambiando de posicion de r0 al siguiente valor
		add r6, #4		@ Sumandole al contador 
		
		@--Comparando si esta vacia o no--
		ldr r9, [r4]		@ Obteniendo el valor en memoria de r0
		cmp r9, #0x2D		@ Verificando que no este ocupada
		strne r2, [r4]		@ Guardando la nueva ficha
		
		b ciclo_cambio_fila
	
	fin_cambio_filas:
		mov r1, r12 @X
		pop {r4-r12, pc}

/*
Subrutina que imprime la informacion del tablero actual
*/
imprimir_tablero:
    cont_arr_it .req R7
    cont_pos_it .req R4             /* Contador de posiciones (por cada arreglo) */
    dir_arr_it .req R5
    MOV cont_arr_it, #0
    LDR dir_arr_it, =columnas_indice2
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
    columnas_indice2:
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
        .asciz  "\t\tTurno Nยบ. %d"
	
	@@@--Fichas--
	ficha_uno:
		.asciz "X"
	ficha_dos:
		.asciz "O"
	
    @--Mensajes--
	mensaje_error:
		.asciz "Ingreso invalido, vuelva a intentar"
    msg_ingreso:
        .asciz  "\nIngresa la direccion de la casilla que quieres ingresar (ej. B3)"

	@@@
	mensaje_ocupado:
		.asciz "Esta casilla esta ocupada"

    entrada_actual:
        .asciz  "Z0"

    @--Formatos de salida--
    f_entrada_s:
        .asciz  "%s"
    f_enter:
        .asciz  "\n"
