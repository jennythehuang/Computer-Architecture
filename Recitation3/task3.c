#include <stdio.h>
#include <stdlib.h>


struct node{
	int playerNumber;
	float avgPoints;
	node* link; /* use this as next in linkedList */
};
void swap(struct node* p1, struct node* p2){
    int tempNumber = p1->playerNumber;
    float tempAvg = p1-> avgPoints;
    p1->playerNumber = p2->playerNumber;
    p1->avgPoints = p2->avgPoints;
    p2->playerNumber = tempNumber;
    p2->avgPoints = tempAvg;
    }
    
/* Bubble sort the given linked list */
void sortList(struct node *start) {
    int swapped, i;
    struct node *ptr1;
    struct node *lptr = NULL;
    
    /* Check if the list is empty first */
    if (start == NULL)
        return;
    
    do {
        swapped = 0;
        ptr1 = start;
        while (ptr1->link != lptr) {
            if (ptr1->avgPoints > ptr1->link->avgPoints) {
                swap(ptr1, ptr1->link);
                swapped = 1;
            }
            ptr1 = ptr1->link;
        }
        lptr = ptr1;
    } while (swapped);
}

void print(struct node* current){
    /* print sorted list */
    while(current){
        printf(" %d",current->playerNumber);
        current = current->link;
    }
}

int main(){
	int playerNum;
	float pts;
	struct node* head;
	node* prev = NULL; /* need to initialize as NULL otherwise head becomes NULL */

	while(true){

		printf("Enter player number: \n");
		scanf("%d", &playerNum);
		if(playerNum==-1) break;

		printf("Enter player points: \n");
		scanf("%d", &pts);

		/* allocate memory for nodes */        
		node* temp = (node*)malloc(sizeof(struct node));
		temp->playerNumber = playerNum;
		temp->avgPoints = pts;
		temp->link = NULL; /* we are making an empty node to add on to */

		if(prev!=NULL) prev->link = temp; /* only first node won't have a previous */
		else head = temp; /* set head as the first node, we know its first since it has no previous */

		prev = temp; 
    }

	sortList(head); /* pass as pointer, not passing as value */
    print(head);
	/* free all nodes in loop */
	struct node* temp;
	while(head!=NULL){
		temp = head;
		head = head->link;
		free(temp);
	}

	/*safety return for main */
	return 0;
}
