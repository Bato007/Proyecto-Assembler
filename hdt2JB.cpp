/*
Universidad del Valle de Guatemala
CC3056 - Programacion de Microprocesadores
SecciÃ³n 10
Hoja de Trabajo 2 - inciso 4
Julio Herrera 19402
Brandon HernÃ¡ndez 19376

Programa que emplea un proceso padre y uno hijo para determinar si la serie armÃ³nica
de la sumatoria 1/(n)^2 es divergente o convergente.
*/

// Incluyendo las bibliotecas necesarias
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h> 
#include <unistd.h> 
#include <sys/wait.h>
#include <iostream>
#include <math.h>

using namespace std;

/*
	Realiza la sumatoria de la función 1/n^2 desde 0
	Parametro: numero de tipo int, es el ultimo valor que 
			   se remplazara en la función y se sumara con el resto
*/
void serie(int numero) 
{ 
	// Variables utilizadas para la comunicación
    int fd[2];
    int numB;
    
    pipe(fd); // Se define el pipe de comunicacion
    
    // Se preparan las variables del paralelismo y las que guardan
    // los resultados
    pid_t pid;
    int status;
    double x = 0, x1 = 0, r = 0;
    pid = fork();
  
  	// Si es el hijo se ejecuta lo siguiente
    if (pid == 0) {
    	
    	/* Obteniendo la sumatoria de los primeros numeros
		   de la serie y se muestra cuanto es			*/
		for (int i = 1; i < numero; i+=2) {
		    x += 1/pow(i,2);
		}
        printf("HIJO: Valor de la sumatoria = %f\n", x); 
        
        // Comunicación por medio de Pipes
        close(fd[0]); // Se cierra el lado de lectura
        write(fd[1], &x, sizeof(x)); // Metiendo el valor de x en el pipe
        close(fd[1]); // Se cierra el lado de escritura
		_exit(0);
	}
	
	// Si es el padre se ejecuta lo siguiente
    else {
    	
    	/* Obteniendo la sumatoria de la otra mitad de numeros
		   de la serie y se muestra cuanto es			*/
		for (int i = 2; i < numero; i+=2) {
		    x1 += 1/pow(i,2);
		}
        printf("PADRE: Valor de la sumatoria = %f\n", x1); 
		
		waitpid(pid,&status,0); //Se espera a que termine el hijo
	
		// Comunicación por medio de Pipes
        close(fd[1]); // Se cierra el lado de escritura
        numB = read(fd[0], &x, sizeof(x)); // Obteniendo dato del pipe
        printf("El padre lee %d bytes: %f \n", numB, x);
        close(fd[0]); // Se cierra el lado de lectura
        
        // Se muestra el resultado total
        r = x + x1;
        printf("TOTAL: La sumatoria es = %f\n", r); 
	
    }
}

// Función main
int main() 
{ 
	// Obteniendo el ultimo valor de la sumatoria
    int numero = 999998;
    while (numero >= 999998){
		printf("Ingrese el numero n para la sumatoria: ");
		cin>>numero;

		if (numero >= 999998){ // Verificando que no llegue hasta el 'infinito'
		    printf("'n' es muy grande\n");
		}
    }
    serie(numero); // Realizando la sumatoria 
    return 0; 
} 
