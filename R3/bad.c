#include <stdio.h>
#include <stdlib.h>

int main(){
    int *a; /* pointer variable declaration */
    int b; /* actual variable declaration */
    *a=15;  /* not valid because address where a is pointing to is unknown */
    a=&b; /* store address of b in pointer variable*/
}

