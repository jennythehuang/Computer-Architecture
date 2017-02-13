#include <stdio.h>
#include <stdlib.h>
#include <string.h> 

struct node{
	char name[50];
	int number;
	int gradYear;
	node* link; /* use this as next in linkedList */
};

//swap data in two nodes
void swap(struct node* p1, struct node* p2){
    char tempName[50];
    strcpy(tempName, p1->name);     
    int tempNumber = p1->number;
    int tempGrad = p1-> gradYear;

    strcpy(p1->name,p2->name);   
    p1->number = p2->number;
    p1->gradYear = p2->gradYear;

    strcpy(p2->name,tempName); 
    p2->number = tempNumber;
    p2->gradYear = tempGrad;
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
            if (ptr1->gradYear > ptr1->link->gradYear) {
                swap(ptr1, ptr1->link);
                swapped = 1;
            }
            else if(ptr1->gradYear==ptr1->link->gradYear){
            	int cmp = strcmp(ptr1->name, ptr1->link->name);
            	if(cmp>0){
            		swap(ptr1, ptr1->link);
            	}
            }
            ptr1 = ptr1->link;
        }
        lptr = ptr1;
    } while (swapped);

     /* print sorted list */
    while(start){
        printf("%s %d\n",start->name, start->number);
        start = start->link;
    }
}

int main(int argc, char* argv[]){
    char *filename = argv[1];
    FILE *file = fopen(filename, "r"); //r opens a file for reading
	
	char playerName[50];
	int playerNum;
	int playerGradYear;

	struct node* head;
	node* prev = NULL; /* need to initialize as NULL otherwise head becomes NULL */

	while (true) {
		/* first line is player name */
		fscanf(file, "%s", &playerName);
		if (strcmp(playerName, "DONE") == 0) break;

		fscanf(file, "%d", &playerNum);
		fscanf(file, "%d", &playerGradYear);

		/* allocate memory for nodes, create linkedList */
		node* temp = (node*)malloc(sizeof(struct node));
		strcpy(temp->name,playerName);
		temp->number = playerNum;
		temp->gradYear = playerGradYear;
		temp->link = NULL; /* we are making an empty node to add on to */

		if(prev!=NULL) prev->link = temp; /* only first node won't have a previous */
		else head = temp; /* set head as the first node, we know its first since it has no previous */

		prev = temp; 
	}

	sortList(head); /* pass as pointer, not passing as value */

	/* free all nodes in loop */
	struct node* temp;
	while(head!=NULL){
		temp = head;
		head = head->link;
		free(temp);
	}

	fclose(file);
	return 0;
}
