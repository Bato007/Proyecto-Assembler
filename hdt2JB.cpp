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
  
void serie() 
{ 
    int fd[2];
    int numB;
    
    pipe(fd); // Se define el pipe de comunicacion
    
	pid_t pid;
	int status;
	pid = fork();
    double x = 0, x1 = 0, r = 0;
  
    if (pid == 0) {
	    x = 2+4+6;
        printf("HIJO: Valor de variable x = %f\n", x); 
        close(fd[0]);
        write(fd[1], &x, sizeof(x));
        close(fd[1]);
		_exit(0);
	}
    else {
	    x1 = 1+3+5;
        printf("PADRE: Valor de variable x1 = %f\n", x1); 
		
	    waitpid(pid,&status,0);
	
        close(fd[1]);
        numB = read(fd[0], &x, sizeof(x));
        printf("El padre lee %d bytes: %f \n", numB, x);
        close(fd[0]);
        
        r = x + x1;
        printf("TOTAL: Valor de la suma es = %f\n", r); 
	
	}
}

int main() 
{ 
    serie(); 
    return 0; 
} 
