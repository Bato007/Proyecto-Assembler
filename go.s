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
    LDR R0, =draw
    BL puts
    LDR R0, =title
    BL puts
	
	@ Moviendo el valor 1 al contador r8
	mov r8, #1

@---EMPIEZA EL JUEGO---
ciclo:

	@--Pidiendole al usuario la fila y columna--
	
	
	@--Metiendo los datos al tablero
	
	@-Fila A-
	cmp r9, #0
	ldreq r0, =fila_A
		
	@-Fila B-
	cmp r9, #1
	ldreq r0, =fila_B
	
	@-Fila C-
	cmp r9, #2
	ldreq r0, =fila_C
	
	@-Fila D-
	cmp r9, #3
	ldreq r0, =fila_D
	
	@-Fila E-
	cmp r9, #4
	ldreq r0, =fila_E
	
	@--MOVIENDO LA POSICION DEL VECTOR--
	mov r2, #4			
	sub r1, r1, #1	@ Se le resta 1, porque el usuario ingresa (columna 1)
	mul r2, r1		@ Indica cuanto se tiene que mover 
	add r0, r2		@ Se mueve n espacios por el arrego r0
	
	@--Sumandole 1 al turno y comparando si ya llego a 25--
	add r8, #1
	cmp r8, #26
	bne ciclo
	beq fin

@---INGRESO INVALIDO---
ingreso_invalido:
	ldr r0, =mensaje_error
	bl puts
	b ciclo

@---FIN DEL PROGRAMA---
fin:
    MOV R7, #1      /* R7 = 1 : Salida SO */
    SWI 0

@SUBRUTINAS LOCALES



@---DATOS----------------------------------------------------------------------------
.data
	
	@---TABLERO GO----------
	fila_A:
		.word 0, 0, 0, 0, 0
	fila_B:
		.word 0, 0, 0, 0, 0
	fila_C:
		.word 0, 0, 0, 0, 0
	fila_D:
		.word 0, 0, 0, 0, 0
	fila_E:
		.word 0, 0, 0, 0, 0

	@--Mostrar tablero go--
	columnas_indice:
		.asciz "   1  2  3  4  5\n"
	separacion:
		.asciz "   -------------"
	
	mensaje_error:
		.asciz "Ingreso invalido, vuelva a intentar"
	
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
					