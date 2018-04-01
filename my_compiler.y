%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include<iostream>


extern int yylex();
extern int yyparse();
extern FILE *yyin;
void yyerror(const char *s);
char *temp;
char *new_line;


int id_count=1;
int label_count = 1;
char buff_id_count[10];
char buff_label_count[10];

struct label_code{
	char *addr;
	char *code;	
}lc_temp;


char * gen_id(){
	
	char *newid = (char *)malloc(20);
	strcpy(newid,"t");
	snprintf(buff_id_count, 10,"%d",id_count);
	strcat(newid,buff_id_count);		
	id_count++;
	return newid;
}

char * gen_label(){
	
	char *newLabel = (char *)malloc(20);
	strcpy(newLabel,"L");
	snprintf(buff_label_count, 10,"%d",label_count);
	strcat(newLabel,buff_label_count);	
	label_count++;
	return newLabel;
}


struct label_code *rtn_ptr;


label_code* arithmetic_operation(char* left_code,char* right_code,char *left_addr,char *right_addr,char* optr)
{
    	                                        rtn_ptr= (struct label_code *)malloc(sizeof(struct label_code));
																							rtn_ptr->addr = (char *)malloc(20);
																							rtn_ptr->addr = gen_id();
																						  new_line = (char *)malloc(20);
																							new_line[0] = 0;
																							strcat(new_line,rtn_ptr->addr);
																							strcat(new_line,"=");																							
																							strcat(new_line,left_addr);
																							strcat(new_line,optr);
																							strcat(new_line,right_addr);
																							printf("new line added is = \n");
																							puts(new_line);
																							temp = (char *)malloc(strlen(right_code)+strlen(left_code)+6);
		                                          temp[0] = 0;	
		                                          if (left_code!=0){
																								strcat(temp,left_code);
																								strcat(temp,"\n");
																								}		
		                                          if (right_code!=0){
																								strcat(temp,right_code);
																								strcat(temp,"\n");
																								}																																														
																							strcat(temp,new_line);
																							printf("Code generated till now is = \n");
																							puts(temp);
																							rtn_ptr->code = temp;  
																							return rtn_ptr;   																					
}

using namespace std;
%}

%union{
char* str;
int i_num;
float f_num;
char * final_int_code;
struct label_code* Lc_ptr;}


%token <i_num> DIGIT
%token <f_num> FLOAT
%token <str> TYPE
%token <str> ID
%type <str> identifier number declaration 
%type <Lc_ptr> statement expression
%right '='
%left '+' '-' 
%left '*' '/' '%'
%right '^'


%%

statement :	
           declaration '=' expression ';' { printf("Assignment statement along with declaration\n");
           																  rtn_ptr= (struct label_code *)malloc(sizeof(struct label_code));
																						rtn_ptr->addr = (char *)malloc(20);
																						rtn_ptr->addr =gen_id();
																						new_line = (char *)malloc(20);
																						new_line[0] = 0;
																						strcat(new_line,$1);
																						strcat(new_line,"=");
																						strcat(new_line,$3->addr);
																						printf("new line added is = \n");
																						puts(new_line);
																						temp = (char *)malloc(strlen($3->code)+strlen(new_line)+6);
		                                        temp[0] = 0;		
																						if ($3->code[0]!=0){
																								strcat(temp,$3->code);
																								strcat(temp,"\n");
																						    }
																						strcat(temp,new_line);
																						printf("Code generated till now is = \n");
																						puts(temp);
																						rtn_ptr->code = temp;
     																				$$ =rtn_ptr;
           																     																
           																}
          | identifier '=' expression ';'  {  printf("Assignment statement \n");
          																		rtn_ptr= (struct label_code *)malloc(sizeof(struct label_code));
																							rtn_ptr->addr = (char *)malloc(20);
																							rtn_ptr->addr = gen_id();
																						   new_line = (char *)malloc(20);
																							 new_line[0] = 0;
																							strcat(new_line,$1);
																							strcat(new_line,"=");
																							strcat(new_line,$3->addr);
																							printf("new line added is = \n");
																							puts(new_line);
																							temp = (char *)malloc(strlen($3->code)+strlen(new_line)+6);
		                                          temp[0] = 0;		
																							if ($3->code[0]!=0){
																								strcat(temp,$3->code);
																								strcat(temp,"\n");
																								}
																							strcat(temp,new_line);
																							printf("Code generated till now is = \n");
																							puts(temp);
																							rtn_ptr->code = temp;
     																					$$ =rtn_ptr;      																		
          																		}
					;

declaration :   TYPE identifier  { printf("Declaration \n");
																	 $$=$2; }

						;
						
expression  : '(' expression ')' { $$=$2;} 
       
            | expression '^' expression {printf("exp power exp \n");
          															 $$ =arithmetic_operation($1->code,$3->code,$1->addr,$3->addr,"^");																					
																							}
						| expression '*' expression {printf("exp multiplication exp \n");
          															 $$ =arithmetic_operation($1->code,$3->code,$1->addr,$3->addr,"*");	}
						| expression '/' expression {printf("exp division exp \n");
          															 $$ =arithmetic_operation($1->code,$3->code,$1->addr,$3->addr,"/");	}
						| expression '%' expression {printf("exp module exp \n");
          															 $$ =arithmetic_operation($1->code,$3->code,$1->addr,$3->addr,"%");	}						
						| expression '+' expression {printf("exp addition exp \n");
          															 $$ =arithmetic_operation($1->code,$3->code,$1->addr,$3->addr,"+");	}
						| expression '-' expression {printf("exp substraction exp \n");
          															 $$ =arithmetic_operation($1->code,$3->code,$1->addr,$3->addr,"-");	}						
             | number    { printf("Expression (exp=number) \n");
														rtn_ptr= (struct label_code *)malloc(sizeof(struct label_code));
													  rtn_ptr->addr = (char *)malloc(20);
														rtn_ptr->addr = $1;
														rtn_ptr->code = (char *)malloc(2);  // no code associated, just add which is the number itself
		                        rtn_ptr->code[0] = 0;
														$$=rtn_ptr;
													}
						;
						
number      : DIGIT  {  printf("DIGIT : %d\n",$1);	
												temp = (char *)malloc(20);
           							snprintf(temp, 10,"%d",$1);
												$$ = temp;}
						| FLOAT  {  printf("FLOAT: %d\n",$1);		
												temp = (char *)malloc(20);
           							snprintf(temp, 10,"%d",$1);
												$$ = temp;}
						;
						
identifier  : ID   { $$=$1; printf("Identifier : %s\n",$1);}
						;			
						
%%

main() {
		FILE *myfile = fopen("input.txt", "r");
		yyin = myfile;
		do { 	yyparse();
				} while (!feof(yyin));
	
}

void yyerror(const char *s) {
	printf("ERROR");
	puts(s);
	exit(-1);
}						
									
						
																										
								
								






