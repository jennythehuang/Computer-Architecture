 #include<stdio.h>

struct HoopsPlayer{
	int playerNumber;
	float avgPoints;
};

/* bubble sort method */
/*use HoopsPlayer* to pass player as a pointer */
void sortList(HoopsPlayer* player){
    int i,j;
    HoopsPlayer a;
	for (i=0; i<10; i++) {
		for (j = i+1; j < 10; j++ ) {
            if(player[i].playerNumber==-1 || player[j].playerNumber==-1) break;
			if (player[i].avgPoints > player[j].avgPoints) {
				a = player[i];
				player[i] = player[j];
				player[j] = a;
            }}}
    for(int i=0;i<10;i++){
        if(player[i].playerNumber == -1) break;
        /* \n makes new line for each print statement */
        printf("%d \n",player[i].playerNumber);
    }
}

int main(){
	struct HoopsPlayer player[10];

	for(int i=0;i<10;i++){
		int playerNum;
		float pts;

		printf("Enter player number: \n");
		scanf("%d", &playerNum);
        player[i].playerNumber = playerNum;
        if(playerNum == -1)break;
		printf("Enter player average points: \n");
		scanf("%f", &pts);
		player[i].avgPoints = pts;
	}

	sortList(player);

	return 0;
}
