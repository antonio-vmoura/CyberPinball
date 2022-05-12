##################################################################
#  laboratorio 01 - Grupo 09					 #
#  Antônio Vinicius de Moura Rodrigues				 #
#  Gabriel Pinheiro da Conceição				 #
#  Leandro de Sousa Monteiro		  		         #
##################################################################

.data
.include "different_mazes/maze.s"
#CAMINHO: .space 153600 #Estimativa de pior caso: 4x 320x240/2 tamanho do maior labirinto

.text
MAIN:	add a6,zero,zero

	la a1,maze
	lw a2,0(a1)		#Pegando o quantidade de colunas
	lw a3,4(a1)		#Pegando o quantidade de linhas
 	jal DRAW_MAZE
 	la a4,maze		#caminho
 	add a5,zero,a4
 	
 	jal START_SOLVE_MAZE
 	jal DRAW_PATH
 	
	li a7,10
	ecall
	
DRAW_MAZE:
#Preenche a tela de Preto
	li t1,0xFF000000	#Endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	#Endereco final 
	li t3,0xFFFFFFFF	#Preenche a tela de branco
LOOP1: 	beq t1,t2,OUT		#Se for o ultimo endereco entao sai do loop
	sw t3,0(t1)		#Escreve a word na memoria VGA
	addi t1,t1,4		#Soma 4 ao endereco
	j LOOP1			#Volta a verificar
	
#Carrega o Labirinto
OUT:	#eixo X
	srli t4, a2, 1 		#dividindo a quantidade de colunas do labirinto por 2
	addi t5,zero,160 	#Adicionando 160 ao t5
	sub t6,t5, t4 		#subtraindo a (qtd de col)/2 de 160
	
	li t1,0xFF000000	#Endereco inicial da Memoria VGA - Frame 0
	add t1,t1,t6		#adicionando o endereço inicial com o resultado de t6
	
	#eixo Y
	srli t4, a3, 1 		#dividindo a quantidade de linhas do labirinto por 2
	addi t5,zero,119 	#Adicionando 120 ao t5
	sub t6,t5, t4 		#subtraindo a (qtd de linhas)/2 de 120
	
	addi t4,zero,320	#Adicionando 320 ao t5 para pular as linhas necessarias
	mul t5,t4,t6		#Multiplicando 320 pelo numero de vezes necessarias pra chegar ao centro
	
	add t1,t1,t5		#adicionando o endereço inicial com o resultado de t5
	
	#Printando o labirinto no bitmap
	li t2,0xFF012C00	#Endereco final 
	la s1,maze		#Endereco dos dados da tela na memoria
	addi s1,s1,8		#Primeiro pixels depois das informacoes de nlin ncol
	addi s4,zero,0
	
	add s2,zero,a2 		#Adiciona ncol ao s2
LOOP2: 	beq t1,t2,EXIT1		#Se for o ultimo endereco entao sai do loop
	
	beq s2,s4,EXIT1		#Se terminar de printar o labirinto sai do loop
	addi s4,s4,1
	
	addi s3,zero,-1		#Adiciona 0 ao s3
	
LINE:   bge s3,s2,BLACK		#Testa se s2<=s3, se for imprime preto, sen�o imprime bit
	
	lb t3,0(s1)		#Le um conjunto de 4 pixels : word
	sb t3,0(t1)		#Escreve a word na memoria VGA
	addi t1,t1,1		#Soma 4 ao endereco
	addi s1,s1,1
	addi s3,s3,1
	j LINE			#Volta a verificar
	
	
BLACK:	addi t4,zero,319
	sub t5,t4,a2
	add t1,t1,t5		#320-ncol (bitmap(y) = 320) Pula os bits depois de prencher todas as culunas do labirinto
	j LOOP2

#Resolvendo o Labirinto
START_SOLVE_MAZE: 
	addi,s1,zero,0		#Adicionando a cor preta no s1
	addi,s2,zero,255	#Adicionando a cor branca no s2
	addi,s3,zero,60		#Adicionando a cor Roxa no s3 (Ja esteve)
	
	addi a4,a4,8		#Primeiro pixels depois das informacoes de nlin ncol
	
	add t2,zero,a4		#Pegando o primeiro endereco do maze
	mul t3,a2,a3		#multiplicando colunaxlinha	
	add s4,t2,t3		#adicionando s4 o endereco inicial do maze mais a multiplicacao de colunaxlinha
	add s4,s4,a3		#somando a coluna extra
	addi s4,s4, -1		#retirando 1 pra pegar o ultimo endereco do labirinto

LOOP3: 	lbu t4,0(s4)		
	addi s4,s4,-1		#voltando 1 no endereco
	beq t4,s1,LOOP3		#Se for preto, busca o proximo endereco ate encontrar o branco
	
LOOP4:	lbu t1,0(a4)		#Guardando em t1 a informacao do byte contida no endereço a4
	addi a4,a4,1		#Adiciona 1 ao endereco
	beq t1,s1,LOOP4		#Se for preto, busca o proximo endereco ate encontrar o branco
	
	sb s3,-1(a4)		#Fechando a entrada do labirinto com o roxo para o algoritimo não sair mais pela entrada, tirando 1 que foi acrescentado
	add a4,a4,a2		#Adiciona o ncol ao endereco pra pegar o branco de baixo da entrada do labirinto #nos garantimos que sempre o endereco de baixo da entrada tambem e branco	
	
	j SOLVE_MAZE	

SOLVE_MAZE:			#Agora que estamos dentro do labirinto podemos resolver utilizando nosso algoritmo 
	add t1,zero,a4		#Colocando o endereco de a4 no t1
	
	bge a4,s4,FINAL_GREEN 
	
	#Baixo (Branco)
	add t3,zero,a2		#Adicionando a quantidade de colunas ao t3
	addi t3,t3,1		#adicionando um pra pular a coluna extra
	add t1,a4,t3		#Adicionando a o numero de colunas ao endereco pra saber qual o valor esta embaixo
	lbu t2,0(t1)		#Pegando o valor que esta embaixo
	beq t2,s2,WHITE		#Se o endereco debaixo for branco ele chama WHITE
	
	#Esquerda (Branco)
	addi t3,zero,-1		#Adicionando -1 ao t3
	add t1,a4,t3		#Adicionando o -1 ao endereco pra saber qual o valor esta na esquerda
	lbu t2,0(t1)		#Pegando o valor que esta na esquerda
	beq t2,s2,WHITE		#Se o endereco na esquerda for branco ele chama WHITE
	
	#Direita (Branco)
	addi t3,zero,1		#Adicionando 1 ao t3
	add t1,a4,t3		#Adicionando o 1 ao endereco pra saber qual o valor esta na direita
	lbu t2,0(t1)		#Pegando o valor que esta na direita
	beq t2,s2,WHITE		#Se o endereco na direita for branco ele chama WHITE
	
	#Cima (Branco)
	sub t3,zero,a2		#Adicionando a quantidade de colunas ao t3
	addi t3,t3,-1		#subtraindo um pra pular a coluna extra
	add t1,a4,t3		#Subtraindo o numero de colunas ao endereco pra saber qual o valor esta acima
	lbu t2,0(t1)		#Pegando o valor que esta acima
	beq t2,s2,WHITE		#Se o endereco acima for branco ele chama WHITE
	
	#Baixo (Roxo)
	add t3,zero,a2		#Adicionando a quantidade de colunas ao t3
	addi t3,t3,1		#adicionando um pra pular a coluna extra
	add t1,a4,t3		#Adicionando a o numero de colunas ao endereco pra saber qual o valor esta embaixo
	lbu t2,0(t1)		#Pegando o valor que esta embaixo
	beq t2,s3,GREEN		#Se o endereco debaixo for roxo ele chama Purple
	
	#Esquerda (Roxo)
	addi t3,zero,-1		#Adicionando a -1 ao t3
	add t1,a4,t3		#Adicionando o -1 ao endereco pra saber qual o valor esta na esquerda
	lbu t2,0(t1)		#Pegando o valor que esta na esquerda
	beq t2,s3,GREEN		#Se o endereco na esquerda for roxo ele chama Purple
	
	#Direita (Roxo)
	addi t3,zero,1		#Adicionando 1 ao t3
	add t1,a4,t3		#Adicionando 1 ao endereco pra saber qual o valor esta na direita
	lbu t2,0(t1)		#Pegando o valor que esta na direita
	beq t2,s3,GREEN		#Se o endereco na direita for roxo ele chama Purple
	
	#Cima (Roxo)
	sub t3,zero,a2		#Adicionando 1 ao t3
	addi t3,t3,-1		#subtraindo um pra pular a coluna extra
	add t1,a4,t3		#Adicionando 1 ao endereco pra saber qual o valor esta acima
	lbu t2,0(t1)		#Pegando o valor que esta acima
	beq t2,s3,GREEN		#Se o endereco acima for roxo ele chama Purple

WHITE:	sb s3,0(a4)		#Adicionando roxo ao endereco a4 (s3 = roxo)
	add a4,a4,t3		#Adicionando a quantidade de colunas que foram puladas
	j SOLVE_MAZE
	
GREEN: 	sb s1,0(a4)		#Adicionando ao campo anterior que ja esteve la
	add a4,a4,t3		#Adicionando a quantidade de colunas que foram puladas
	j SOLVE_MAZE
	
FINAL_GREEN:
	sb s3,0(a4)		#Adicionando ao campo anterior que ja esteve la
	add a4,a4,t3		#Adicionando a quantidade de colunas que foram puladas
	ret
	
DRAW_PATH:
	li t1,0xFF000000	#Endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	#Endereco final
	addi,s5,zero,0		#Adicionando a cor preta no s1
	addi,s6,zero,60		#Adicionando a cor verde no s6 (Ja esteve)
	addi,s7,zero,240		#Adicionando a cor verde no s6 (Ja esteve)

	#eixo X
	srli t4, a2, 1 		#dividindo a quantidade de colunas do labirinto por 2
	addi t5,zero,160 	#Adicionando 160 ao t5
	sub t6,t5, t4 		#subtraindo a (qtd de col)/2 de 160
	
	add t1,t1,t6		#adicionando o endereço inicial com o resultado de t6
	
	#eixo Y
	srli t4, a3, 1 		#dividindo a quantidade de linhas do labirinto por 2
	addi t5,zero,119 	#Adicionando 120 ao t5
	sub t6,t5,t4 		#subtraindo a (qtd de linhas)/2 de 120
	
	addi t4,zero,320	#Adicionando 320 ao t5 para pular as linhas necessarias
	mul t5,t4,t6		#Multiplicando 320 pelo numero de vezes necessarias pra chegar ao centro
	
	add t1,t1,t5		#adicionando o endereço inicial com o resultado de t5
	
	#Printando o labirinto no bitmap
	add s1,zero,a5		#Endereco dos dados da tela na memoria
	addi s1,s1,8		#Primeiro pixels depois das informacoes de nlin ncol
	
	add t2,zero,s1		#Pegando o primeiro endereco do maze
	mul t3,a2,a3		#multiplicando colunaxlinha	
	add s4,t2,t3		#adicionando s4 o endereco inicial do maze mais a multiplicacao de colunaxlinha
	add s4,s4,a3		#somando a coluna extra
	addi s4,s4, -1		#retirando 1 pra pegar o ultimo endereco do labirinto
	
LOOP5: 	lbu t4,0(s4)		
	addi s4,s4,-1		#voltando 1 no endereco
	beq t4,s5,LOOP5		#Se for verde, busca o proximo endereco ate encontrar o verde
	
LOOP6:	lbu t4,0(s1)		
	addi s1,s1,1		
	addi t1,t1,1
	beq s5,t4,LOOP6		
	
	addi t1,t1,-1
	addi s1,s1,-1

	j ANIMATE
	
ANIMATE:
	sb s7,0(t1)		#Escreve na memoria VGA
	
	bge s1,s4,EXIT1 	#Sai do loop caso chegue na saida do labirinto
	
	addi a0,zero,20		#Sleep(20ms) #ANIMACAO
	li a7,32		
	ecall
	
	#Baixo (Branco)
	addi t5,zero,320
	add t3,zero,a2		#Adicionando a quantidade de colunas ao t3
	addi t3,t3,1		#adicionando um pra pular a coluna extra
	add t4,s1,t3		#Adicionando a o numero de colunas ao endereco pra saber qual o valor esta embaixo
	lbu t2,0(t4)		#Pegando o valor que esta embaixo
	beq t2,s6,PATH		#Se o endereco debaixo for branco ele chama WHITE
	
	#Esquerda (Branco)
	addi t5,zero,-1
	addi t3,zero,-1		#Adicionando -1 ao t3
	add t4,s1,t3		#Adicionando o -1 ao endereco pra saber qual o valor esta na esquerda
	lbu t2,0(t4)		#Pegando o valor que esta na esquerda
	beq t2,s6,PATH		#Se o endereco na esquerda for branco ele chama WHITE
	
	#Direita (Branco)
	addi t5,zero,1
	addi t3,zero,1		#Adicionando 1 ao t3
	add t4,s1,t3		#Adicionando o 1 ao endereco pra saber qual o valor esta na direita
	lbu t2,0(t4)		#Pegando o valor que esta na direita
	beq t2,s6,PATH		#Se o endereco na direita for branco ele chama WHITE
	
	#Cima (Branco)
	addi t5,zero,-320
	sub t3,zero,a2		#Adicionando a quantidade de colunas ao t3
	addi t3,t3,-1		#subtraindo um pra pular a coluna extra
	add t4,s1,t3		#Subtraindo o numero de colunas ao endereco pra saber qual o valor esta acima
	lbu t2,0(t4)		#Pegando o valor que esta acima
	beq t2,s6,PATH		#Se o endereco acima for branco ele chama WHITE
	
PATH:	
	sb s7,0(s1)		#Adicionando ao campo anterior outra cor
	add t1,t1,t5		#Soma 4 ao endereco
	add s1,s1,t3
	
	j ANIMATE		#volta para o ANIMATE
	
EXIT1: ret 
