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
    LDR R0, =title
    BL puts

fin:
    MOV R7, #1      /* R7 = 1 : Salida SO */
    SWI 0

@SUBRUTINAS LOCALES


@DATOS
.data

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