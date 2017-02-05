#include <stdio.h>
#include <stdlib.h>

void fib(int n){
	/* base case */
	int fib1=2, fib2=2, fib3;

	printf("%d", fib1);
	printf("\n%d", fib2);

	/* iteration */
	int count = 2;
	while(count<n){
		fib3=fib2+fib1;
		printf("\n%d", fib3);
		fib1=fib2;
		fib2=fib3;
		count++;
	}
}
/* output */
int main(int argc, char * argv[]){ /* lets main take in arguments */
	 fib(atoi(argv[1]));
	 return 0;
}


