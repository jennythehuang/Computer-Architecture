#include <stdio.h>
#include <stdlib.h>

int f(int n){
	/* base case */
	if(n==0) return 5;

	/* recursive */
	return 3*(n-1)+(2*f(n-1))-1;
	}

/* output */
int main(int argc, char* argv[]){ /* lets main take in arguments */
	int a = atoi(argv[1]);

	if(a<0) printf("%s\n","Invalid input"); /* input must be > 0 */
    else printf("%d\n",f(a));
	
	return 0;
}
