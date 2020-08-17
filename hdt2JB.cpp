/*
Universidad del Valle de Guatemala
CC3056 - Programacion de Microprocesadores
Sección 10
Hoja de Trabajo 2 - inciso 4
Julio Herrera 19402
Brandon Hernández 19376

Programa que emplea un proceso padre y uno hijo para determinar si la serie armónica
de la sumatoria 1/(n)^2 es divergente o convergente.
*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h> 
#include <unistd.h> 
#include <sys/wait.h>
#include <iostream>
#include <math.h>

using namespace std;
  
void serie(int numero) 
{ 
    int fd[2];
    int numB;
    
    pipe(fd); // Se define el pipe de comunicacion
    
    pid_t pid;
    int status;
    double x = 0, x1 = 0, r = 0;
    pid = fork();
  
    if (pid == 0) {
	for (int i = 1; i < numero; i+=2) {
	    x += 1/pow(i,2);
	}
        printf("HIJO: Valor de la sumatoria = %f\n", x); 
        close(fd[0]);
        write(fd[1], &x, sizeof(x));
        close(fd[1]);
		_exit(0);
	}
    else {
	for (int i = 2; i < numero; i+=2) {
	    x1 += 1/pow(i,2);
	}
        printf("PADRE: Valor de la sumatoria = %f\n", x1); 
		
	waitpid(pid,&status,0);
	
        close(fd[1]);
        numB = read(fd[0], &x, sizeof(x));
        printf("El padre lee %d bytes: %f \n", numB, x);
        close(fd[0]);
        
        r = x + x1;
        printf("TOTAL: La sumatoria es = %f\n", r); 
	
    }
}

int main() 
{ 
    int numero;
    printf("Ingrese el numero n para la sumatoria: \n");
    cin>>numero;
    serie(numero); 
    return 0; 
} 
