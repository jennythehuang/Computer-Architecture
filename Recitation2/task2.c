#include<stdio.h>

int main(){
	char player[300];
	int height;
	int points;

	printf("Enter name of favorite player: \n");
	scanf("%s", player);

	printf("Player's height: \n");
	scanf("%d", &height);

	printf("Average number of points scored per game: \n");
	scanf("%d", &points);

	printf("%s scored an average of %f points per inch.",player,(float)points/height);

	return 0;
}
