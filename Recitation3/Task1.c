#include <stdio.h>
#include <stdlib.h>

int sumArray(int* ptr){
	int sum = 0;
	for(int i=0; i<100;i++){
		sum += ptr[i];
	}
	printf("%d\n",sum);
	return sum;
}
/* output */
int main(){ /* lets main take in arguments */
	/* dynamically allocated array */
    int* myArray = (int *)malloc(100*sizeof(int));
	for(int i=0; i<100; i++){
		myArray[i]=i;
	}
	sumArray(myArray); /* passed as int* into sumArray even though not *myArray */
	free(myArray);
	return 0;
}

