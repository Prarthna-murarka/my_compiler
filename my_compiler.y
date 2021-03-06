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
char *label;

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
																							temp = (char *)malloc(strlen(right_code)+strlen(left_code)+20);
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
%token <str> AND OR NOT TRUE FALSE IF ELSE WHILE
%token <str> TYPE
%token <str> ID

%type <str> identifier number rel_exp declaration statement_list blocked_list constructs code
%type <Lc_ptr> statement expression


%left <str>  RELATIONAL_OP;
%right '='
%left '+' '-' 
%left '*' '/' '%'
%right '^'


%%

final_code : code {   cout<<"---------------------INTERMEDIATE CODE GENERATION DONE----------------------"<<endl;
											cout<<endl;
											cout<<$1;
									}

code : constructs {$$=$1; cout<<"code-> constructs";}
     | code code {	 //replacing all the next in code with a new label which is given to start of construct following it
     											 cout<<" code-> code construct "<<endl; 
     											 char *temp1=$1;
     											 char *find = strstr (temp1,"NEXT");
			                     label=gen_label();
														while(find!=NULL){
														strncpy (find,label,strlen(label));
														strncpy (find+strlen(label),"    ",(4-strlen(label)));
														find = strstr (temp1,"NEXT");
														}
     										   new_line=(char*)malloc( strlen($1)+strlen($2)+10);
     										   strcat(new_line,temp1);
     										   strcat(new_line,"\n");
     										   strcat(new_line,label);
     										   strcat(new_line," : ");
     										   strcat(new_line,$2);
     										   strcat(new_line,"\n");
     										   cout<<"AFTER ADDING CONSTRUCT TO code ->"<<endl;
     										   cout<<new_line<<endl;
     										   	$$ = new_line;
     										}				
     
     | statement_list { cout<<"code -> statement_list "<<endl;  }



constructs : IF '(' rel_exp ')' blocked_list ELSE blocked_list {

                                                      //1) generate a new label1 2) replace all TRUE with new label1 3)generate next label2      
                                                      // 4) replace all FAIL with label2  
                                                      // 5) structure-> IF '(' rel exp ') label1: blocked_list1 goto next label2: blocked_list2    
                                                      temp = (char *)malloc(strlen($3)+10);
		                                                  temp[0] = 0;		
																						          strcat(temp,$3);                               
                                                                                                  
                                                      // finding and replacing all the TRUE WITH LABEL 1;
                                                      label=gen_label();
                                                      char *find = strstr (temp,"TRUE");
																											while(find!=NULL){
																											strncpy (find,label,strlen(label));
																											strncpy (find+strlen(label),"    ",(4-strlen(label)));
																											find = strstr (temp,"TRUE");
																											                 }
		                                                  // finding and replacing all FAIL with LABEL 2 
																										  char* label2=gen_label();
																										  find = strstr (temp,"FAIL");		
																										  while(find!=NULL){
																											strncpy (find,label2,strlen(label));
																											strncpy (find+strlen(label2),"    ",(4-strlen(label2)));
																											find = strstr (temp,"FAIL");
																											                 }
																											new_line = (char *)malloc(strlen(temp)+20+strlen($5)+strlen($7));
																											strcat(new_line,temp);
																											strcat(new_line,"\n");
																											strcat(new_line,label);
																											strcat(new_line," : ");
																											strcat(new_line,"\n");
																											strcat(new_line,$5);
																											strcat(new_line,"\n");
																											strcat(new_line,"goto NEXT");			
																											strcat(new_line,"\n");
																											strcat(new_line,label2);
																											strcat(new_line," : ");
																											strcat(new_line,"\n");
																											strcat(new_line,$7);
																											strcat(new_line,"\n");
																											cout<<"IF BLOCK GENERATED -> "<<endl;
																											cout<<new_line<<endl;
																											$$ = new_line; 																	                 
                                           				}





						| IF '(' rel_exp ')' blocked_list {  //1) create a new label 2) replace all TRUE with new label 3) replace all FAIL with NEXT 
                                                   // 4) structure-> IF '(' rel exp ') new label: blocked_list
                                                   
                                                      cout<<"rel-op"<<$3<<"ff";
                                                      label=gen_label();    
                                                      temp = (char *)malloc(strlen($3)+10);
		                                                  temp[0] = 0;		
																						          strcat(temp,$3);                               
                                                                                                  
                                                      // finding and replacing all the TRUE;
                                                      char *find = strstr (temp,"TRUE");
																											while(find!=NULL){
																											strncpy (find,label,strlen(label));
																											strncpy (find+strlen(label),"    ",(4-strlen(label)));
																											find = strstr (temp,"TRUE");
																											}
		                                                  // finding and replacing all FAIL with Next ( blocked_list is not to be executed)
																										  cout<<"temp"<<temp<<endl;
																										  find = strstr (temp,"FAIL");		
																										  while(find!=NULL){
																											strncpy (find,"NEXT",4);
																											find = strstr (temp,"FAIL");
																											}
																											
																											new_line = (char *)malloc(strlen(temp)+10+strlen($5));
																											strcat(new_line,temp);
																											strcat(new_line,"\n");
																											strcat(new_line,label);
																											strcat(new_line," : ");
																											strcat(new_line,"\n");
																											strcat(new_line,$5);
																											cout<<"IF BLOCK GENERATED -> "<<endl;
																											cout<<new_line<<endl;
																											$$ = new_line;
		   																						 }
		   			| blocked_list { $$=$1;}
		   			| WHILE '(' rel_exp ')' blocked_list {       temp = (char *)malloc(strlen($3)+10);
		                                                  temp[0] = 0;		
																						          strcat(temp,$3);
		   			                                          char* label_start = gen_label();
																											label = gen_label();

																											// finding and replacing all the TRUE with new label1
                                                      char *find = strstr (temp,"TRUE");
																											while(find!=NULL){
																											strncpy (find,label,strlen(label));
																											strncpy (find+strlen(label),"    ",(4-strlen(label)));
																											find = strstr (temp,"TRUE");
																											}
		                                                  // finding and replacing all FAIL with Next ( blocked_list is not to be executed)
																										  cout<<"temp"<<temp<<endl;
																										  find = strstr (temp,"FAIL");		
																										  while(find!=NULL){
																											strncpy (find,"NEXT",4);
																											find = strstr (temp,"FAIL");
																											}
																											
																											char * temp2 = (char *)malloc(strlen($5)+10);
		                                                  temp2[0] = 0;		
																						          strcat(temp2,$5);
																											
																											find = strstr (temp2,"NEXT");		
																										  while(find!=NULL){
																											strncpy (find,label_start,strlen(label));
																											strncpy (find+strlen(label_start),"    ",(4-strlen(label_start)));
																											find = strstr (temp2,"NEXT");
																											}
																											
																											new_line = (char *)malloc(strlen(temp)+10+strlen($5));
																											strcat(new_line,label_start);
																											strcat(new_line," : ");
																											strcat(new_line,"\n");
																											strcat(new_line,temp);
																											strcat(new_line,"\n");
																											strcat(new_line,label);
																											strcat(new_line," : ");
																											strcat(new_line,"\n");
																											strcat(new_line,temp2);
																											strcat(new_line,"\n");
																											strcat(new_line,"goto ");
																											strcat(new_line,label_start);
																											cout<<"WHILE BLOCK GENERATED -> "<<endl;
																											cout<<new_line<<endl;
																											$$ = new_line;	   			
		   																				}
		   			                                    
																		 
		   																						 
		   			; 																			 



blocked_list : '{' statement_list '}' { cout<<" group of statements i.e list enclosed within parentheses '{ }'"<<endl; 
																			  $$=$2;																			
																			}
					 	  |'{' constructs '}'{$$=$2;}
		     		;
																			              



statement_list : statement {   // forming group of statements
															 $$=$1->code;
														}
								|statement_list statement { // appending the new statement at the end of statement_list<<ENDL;
																	cout<<"STATEMENT LIST (APPENDING)";
																	new_line = (char *)malloc(strlen($1)+strlen($2->code)+10);
																	strcat(new_line,$1);
																	strcat(new_line,"\n");
																	strcat(new_line,$2->code);
								                  cout<<"new list= "<<new_line<<endl;
								                  $$=new_line;
								                 }
								;                       

statement :	
           declaration '=' expression ';' { cout<<"Assignment statement along with declaration";
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
          																		
           | declaration ';' {                rtn_ptr= (struct label_code *)malloc(sizeof(struct label_code));
																							rtn_ptr->addr = (char *)malloc(20);
																							rtn_ptr->addr = $1;		
																							rtn_ptr->code = (char *)malloc(2);
																							rtn_ptr->code[0] = 0;		
																							$$ = rtn_ptr;
										 				 }
           | expression ';' {$$=$1;}
           																	
					;

declaration :   TYPE identifier  { printf("Declaration \n");
																	 $$=$2; }

						;
						
						
rel_exp :  expression RELATIONAL_OP expression { cout<<"RELATIONAL OPERATOR"<<$2<<endl;
																							new_line = (char *)malloc(30);
																							new_line[0] = 0;																
																							strcat(new_line,"if(");
																							strcat(new_line,$1->addr);
																							strcat(new_line,$2);																							
																							strcat(new_line,$3->addr);
																							strcat(new_line,") goto TRUE \n goto FAIL");
																							printf("new line added is = \n");
																							puts(new_line);																							
																							temp = (char *)malloc(strlen($1->code)+strlen($3->code)+strlen(new_line));
		                                          temp[0] = 0;	
		                                          if ($1->code!=0){
																								strcat(temp,$1->code);
																								strcat(temp,"\n");
																								}		
		                                          if ($3->code!=0){
																								strcat(temp,$3->code);
																								strcat(temp,"\n");
																								}																																														
																							strcat(temp,new_line);
																							printf("Code generated till now is = \n");
																							puts(temp);
																							$$=temp;
																							}
																							
			  |  rel_exp AND rel_exp { cout<<"RELATIONAL OPERATOR -> AND "<<endl;
			  													char *rel_exp1=$1,*rel_exp2=$3;
			  													label = gen_label();
			                            char *find = strstr (rel_exp1,"TRUE");		
			                            // find and replace all the true with new label
																	while(find!=NULL){
																											strncpy (find,label,strlen(label));
																											strncpy (find+strlen(label),"   ",(4-strlen(label)));
	                                                    find= strstr (rel_exp1,"TRUE");}
                                  temp= (char *)malloc(strlen(rel_exp1)+strlen(rel_exp2)+10);
			                            temp[0] = 0;
                                  strcat(temp,rel_exp1);
			                            strcat(temp,"\n");
			                            strcat(temp,label);
																	strcat(temp," : ");
																	strcat(temp,rel_exp2);
																	cout<<"new line= "<<temp<<endl;																	 
																	$$ = temp;}																				
			  |  rel_exp OR rel_exp { cout<<"RELATIONAL OPERATOR -> OR "<<endl;
			  													char *rel_exp1=$1,*rel_exp2=$3;
			  													label =gen_label();
			                            char *find = strstr (rel_exp1,"FAIL");		
			                            // find and replace all the fail with new label
																	while(find!=NULL){
																											strncpy (find,label,strlen(label));
																											strncpy (find+strlen(label),"   ",(4-strlen(label)));
	                                                    find= strstr (rel_exp1,"FAIL");}
                                  temp= (char *)malloc(strlen(rel_exp1)+strlen(rel_exp2)+10);
			                            temp[0] = 0;
                                  strcat(temp,rel_exp1);
                                  strcat(temp,"\n");
			                            strcat(temp,label);
																	strcat(temp," : ");			                           
																	strcat(temp,rel_exp2);
																	cout<<"new line= "<<temp<<endl;																		
																	$$ = temp;}				
			  |  NOT '(' rel_exp ')' {  cout<<"RELATIONAL OPERATOR-> AND "<<endl;    // as the operator is not, all the true will be replaced by flase and false with true
			                                                                         // for this temp. label xxxx is used
			  													puts($3);
																	char *rel_exp= $3;																	                                   
																	label = "xxxx";
																	char *find = strstr (rel_exp,"TRUE");
																		while(find!=NULL){
																		strncpy (find,label,strlen(label));
																		find = strstr (rel_exp,"TRUE");
																		}
		
																	label = "TRUE";
																	find = strstr (rel_exp,"FAIL");		
																	while(find!=NULL){
																		strncpy (find,label,strlen(label));
																		find = strstr (rel_exp,"FAIL");
																		}

																	label = "FAIL";
																	find = strstr (rel_exp,"xxxx");		
																	while(find!=NULL){
																		strncpy (find,label,strlen(label));
																		find = strstr (rel_exp,"xxxx");
																		}		
																	$$ = rel_exp;
			                          }
			  
			  												
			  | '(' rel_exp ')' {$$=$2;}
			  | TRUE { cout<<"TRUE"<<endl;
			           new_line=(char *)malloc(10);
			           new_line[0]=0;
			           strcat(new_line," GOTO TRUE\n");
			           cout<<"new line added= "<<new_line<<endl;
			           $$=new_line;
			  				}
			  | FALSE { cout<<"FALSE"<<endl;
			           new_line=(char *)malloc(10);
			           new_line[0]=0;
			           strcat(new_line," GOTO FAIL\n");
			           cout<<"new line added= "<<new_line<<endl;
			           $$=new_line;
			  
			  				}																			
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
													
   					| identifier { printf("exp equals to identifier which is initialized");    					
   					                rtn_ptr= (struct label_code *)malloc(sizeof(struct label_code));
													  rtn_ptr->addr = (char *)malloc(20);
														rtn_ptr->addr = $1;
														rtn_ptr->code = (char *)malloc(2);  // no code associated, just add which is the number itself
		                        rtn_ptr->code[0] =0;
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
									
						
																										
								
								






