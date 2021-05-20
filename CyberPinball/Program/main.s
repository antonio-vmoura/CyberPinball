##################################################################
#  			- CyberPinball -		 	 #
#  Antonio Vinicius de Moura Rodrigues				 #
#  Gabriel Pinheiro da Conceicao				 #
#  Leandro de Sousa Monteiro		  		         #
##################################################################

.data

.include "menu.s"
.include "level1.s"
.include "level2.s"
.include "help.s"
.include "credits.s"
.include "pin.s"

.include "f1d.s"
.include "f2d.s"
.include "f3d.s"

.include "f1e.s"
.include "f2e.s"
.include "f3e.s"

.include "f1d2.s"
.include "f2d2.s"
.include "f3d2.s"

.include "f1e2.s"
.include "f2e2.s"
.include "f3e2.s"

pos_opcao: .word 0xFF009ec8, 0xff00b908, 0xff00d348, 0xff00ed88, 0xff010688
opcao: .word 0

NUM: .word 42
# lista de nota,duracao,nota,duracao,nota,duracao,...
NOTAS:	50,250,57,500,50,250,57,250,50,250,55,250,54,250,45,250,52,500,45,250,52,250,45,250,50,250,49,250,50,250,57,500,50,250,57,250,50,250,55,250,54,250,45,250,52,500,45,250,52,250,45,250,50,250,49,250,50,250,57,500,50,250,57,250,50,250,55,250,54,250,45,250,52,500,45,250,52,250,45,250,50,250,49,250

.macro printIMG(%img)
	la a0, %img		# qual img vai imprimir
	lw a2, 4(a0) 		# altura
	lw a3, 0(a0) 		# largura
	srli a3, a3, 2		# largura // 4 == largura >> 2
	addi a0, a0, 8		# vetor de bytes origem 
	print_linhas:
		blez a2, print_fim	# enquanto a2 > 0
		mv t0, a1		# endere�o do inicio linha atual
		mv t1, a3		# t1 = largura
		print_colunas:
			blez t1, print_out	# enquanto t1 > 0
			lw t2, 0(a0)		# le uma word do vetor
			sw t2, 0(t0)		# Salva no display a word lida do vetor 
			addi a0, a0, 4
			addi t0, t0, 4
			addi t1, t1, -1 	# t1 --
			j print_colunas
		print_out:
		addi a1, a1, 320
		addi a2, a2, -1 	# a2--
		j print_linhas
	print_fim:
.end_macro

.text
	li a1, 0xFF000000	# endereco inicial
	printIMG(menu) 		# imprime fundo
	
	li a1, 0xFF009EC8	
	printIMG(pin)		# imprime qbert
	
	jal musica
	
	la tp,KDInterrupt	# Le teclado
 	csrrw zero,5,tp 	
 	csrrsi zero,0,1 	
	li tp,0x100
 	csrrw zero,4,tp		

 	li t5,0xFF200000	
	li t0,0x02		
	sw t0,0(t5)   		
  
	li s0,0			
CONTA:	addi s0,s0,1 		
	j CONTA			

KDInterrupt:	
	csrrci zero,0,1 	# clear o bit de habilitacao de interrupcao global em ustatus (reg 0)
	
	lw t2,4(t5)  		# le a tecla

	addi t6, zero, 122	# t6 = Z
 	beq t2, t6, z_menu	# Se apertou Z

  	addi t6, zero, 120	# t6 = X
  	beq t2, t6, x_menu	# Se apertou X
  	
  	addi t6, zero, 27	# t6 = Esc
  	beq t2, t6, volta_menu	# Se apertou Esc
  
  	addi t6, zero, 10	# t6 = Line Feed
  	beq t2, t6, enter_menu	# Se apertou enter

leteclafora:
	csrrsi zero,0,0x10 	# seta o bit de habilitacao de interrupcao em ustatus 
	uret			# retorna PC=uepc
	
musica:
	la s0,NUM		# define o endereco do numero de notas
	lw s1,0(s0)		# le o numero de notas
	la s0,NOTAS		# define o endereco das notas
	li t0,0			# zera o contador de notas
	li a2,68		# define o instrumento
	li a3,40		# define o volume

LOOP:	beq t0,s1, musica_fim	# contador chegou no final? entao  va para FIM
	lw a0,0(s0)		# le o valor da nota
	lw a1,4(s0)		# le a duracao da nota
	li a7,31		# define a chamada de syscall
	ecall			# toca a nota
	mv a0,a1		# passa a duracao da nota para a pausa
	li a7,32		# define a chamada de syscal 
	ecall			# realiza uma pausa de a0 ms
	addi s0,s0,8		# incrementa para o endereco da proxima nota
	addi t0,t0,1		# incrementa o contador de notas
	j LOOP			# volta ao loop
	
musica_fim: ret

som_z:   
	li a0,69      		# define a nota
    	li a1,150        	# define a duracao da nota em ms
    	li a2,24       		# define o instrumento
    	li a3,60        	# define o volume
    	li a7,33        	# define o syscall
    	ecall            	# toca a nota
    	ret

som_x:  
	li a0,57     	# define a nota
    	li a1,150       	# define a dura��o da nota em ms
   	li a2,24        	# define o instrumento
    	li a3,60       	# define o volume
    	li a7,33       	# define o syscall
    	ecall           	# toca a nota
    	ret
    
som_e:   
	li a0,81      # define a nota
    	li a1,150        	# define a dura��o da nota em ms
    	li a2,24        	# define o instrumento
    	li a3,60        	# define o volume
    	li a7,33        	# define o syscall
    	ecall            	# toca a nota
    	ret
 
som_flipper:  
	li a0,50        # define a nota
   	 li a1,150        # define a dura��o da nota em ms
    	li a2,115        # define o instrumento
    	li a3,60        # define o volume
    	li a7,33        # define o syscall
    	ecall            # toca a nota
    	ret

volta_menu:
	li a1, 0xFF000000	# endereco inicial
	printIMG(menu) 		#imprime fundo
	
	la t0, opcao
	li t1, 0		#retornando a opcao para o 0
	sw t1, 0(t0)

	li a1, 0xFF009EC8	
	printIMG(pin)		# imprime qbert	
	
	la tp,KDInterrupt	# Le teclado
 	csrrw zero,5,tp 	
 	csrrsi zero,0,1 	
	li tp,0x100
 	csrrw zero,4,tp		

 	li t5,0xFF200000	
	li t0,0x02		
	sw t0,0(t5)   		
  
	li s0,0			
CONTA2:	addi s0,s0,1 		
	j CONTA2
										
z_menu:
	li a1, 0xFF000000	# endereco inicial
	printIMG(menu) 		#imprime fundo
	
	la t0, opcao
	lw t1, 0(t0)
	addi t1, t1, -1
	sw t1, 0(t0)
	li t4, 4
	mul t1, t1, t4
	la t0, pos_opcao
	add t0, t0, t1
	lw a1, 0(t0)
	printIMG(pin)
	
	jal som_z
	
	j leteclafora

x_menu:	
	li a1, 0xFF000000	# endereco inicial
	printIMG(menu) 		#imprime fundo
	
	la t0, opcao
	lw t1, 0(t0)
	addi t1, t1, 1
	sw t1, 0(t0)
	li t4, 4
	mul t1, t1, t4
	la t0, pos_opcao
	add t0, t0, t1
	lw a1, 0(t0)
	printIMG(pin)
	
	jal som_x
	
	j leteclafora
	
enter_menu:
	la t0, opcao
	lw t1, 0(t0)
	
	jal som_e
	
	addi t6, zero, 0	
  	beq t1, t6, iniciar_level1
  	
  	addi t6, zero, 1	
  	beq t1, t6, iniciar_level2
  
  	addi t6, zero, 2	
  	beq t1, t6, help_tela
  	
  	addi t6, zero, 3	
  	beq t1, t6, credit_tela
  	
  	addi t6, zero, 4	
  	beq t1, t6,fim	


############# FASE 1 ############# 
iniciar_level1:
	li a1, 0xFF000000	# endereco inicial
	printIMG(level1) 	#imprime fundo
	
	li a1, 0xFF00E240	# endereco inicial
	printIMG(f3d2) 		#imprime flipper direito
	
	li a1, 0xFF00E240	# endereco inicial
	printIMG(f3e2) 		#imprime flipper esquerdo
	
	la tp,KDInterrupt2	# Le teclado
 	csrrw zero,5,tp 	
 	csrrsi zero,0,1 	
	li tp,0x100
 	csrrw zero,4,tp		

 	li t5,0xFF200000	
	li t0,0x02		
	sw t0,0(t5)   		
  
	li s0,0			
CONTA3:	addi s0,s0,1 		
	j CONTA3

KDInterrupt2:	
	csrrci zero,0,1 		# clear o bit de habilitacao de interrupcao global em ustatus (reg 0)
	
	lw t2,4(t5)  			# le a tecla
	
	addi t6, zero, 122		# t6 = Z
 	beq t2, t6, flipper_esquerdo	# Se apertou Z

  	addi t6, zero, 120		# t6 = X
  	beq t2, t6, flipper_direito	# Se apertou X
  	
  	addi t6, zero, 27		# t6 = Esc
  	beq t2, t6, volta_menu		# Se apertou Esc	
	
flipper_direito:
	li a1, 0xFF00E240		# endereco inicial
	printIMG(f2d2) 			#imprime fundo
	
	li a1, 0xFF00E240		# endereco inicial
	printIMG(f1d2) 			#imprime fundo
	
	li a1, 0xFF00E240		# endereco inicial
	printIMG(f2d2) 			#imprime fundo
	
	li a1, 0xFF00E240		# endereco inicial
	printIMG(f3d2) 			#imprime fundo
	
	jal som_flipper
	
	j leteclafora
	
flipper_esquerdo:
	li a1, 0xFF00E240		# endereco inicial
	printIMG(f2e2) 			#imprime fundo
	
	li a1, 0xFF00E240		# endereco inicial
	printIMG(f1e2) 			#imprime fundo
	
	li a1, 0xFF00E240		# endereco inicial
	printIMG(f2e2) 			#imprime fundo
	
	li a1, 0xFF00E240		# endereco inicial
	printIMG(f3e2) 			#imprime fundo
	
	jal som_flipper
	
	j leteclafora


############# FASE 2 ############# 
iniciar_level2:
	li a1, 0xFF000000	# endereco inicial
	printIMG(level2) 	#imprime fundo
	
	li a1, 0xFF00E880	# endereco inicial
	printIMG(f3d) 		#imprime flipper direito
	
	li a1, 0xFF00E880	# endereco inicial
	printIMG(f3e) 		#imprime flipper esquerdo
	
	la tp,KDInterrupt3	# Le teclado
 	csrrw zero,5,tp 	
 	csrrsi zero,0,1 	
	li tp,0x100
 	csrrw zero,4,tp		

 	li t5,0xFF200000	
	li t0,0x02		
	sw t0,0(t5)   		
  
	li s0,0			
CONTA4:	addi s0,s0,1 		
	j CONTA4
	
KDInterrupt3:	
	csrrci zero,0,1 		# clear o bit de habilitacao de interrupcao global em ustatus (reg 0)
	
	lw t2,4(t5)  			# le a tecla
	
	addi t6, zero, 122		# t6 = Z
 	beq t2, t6, flipper_esquerdo2	# Se apertou Z

  	addi t6, zero, 120		# t6 = X
  	beq t2, t6, flipper_direito2	# Se apertou X
  	
  	addi t6, zero, 27		# t6 = Esc
  	beq t2, t6, volta_menu		# Se apertou Esc	
	
flipper_direito2:
	li a1, 0xFF00E880		# endereco inicial
	printIMG(f2d) 			#imprime fundo
	
	li a1, 0xFF00E880		# endereco inicial
	printIMG(f1d) 			#imprime fundo
	
	li a1, 0xFF00E880		# endereco inicial
	printIMG(f2d) 			#imprime fundo
	
	li a1, 0xFF00E880		# endereco inicial
	printIMG(f3d) 			#imprime fundo
	
	jal som_flipper
	
	j leteclafora
	
flipper_esquerdo2:
	li a1, 0xFF00E880		# endereco inicial
	printIMG(f2e) 			#imprime fundo
	
	li a1, 0xFF00E880		# endereco inicial
	printIMG(f1e) 			#imprime fundo
	
	li a1, 0xFF00E880		# endereco inicial
	printIMG(f2e) 			#imprime fundo
	
	li a1, 0xFF00E880		# endereco inicial
	printIMG(f3e) 			#imprime fundo
	
	jal som_flipper
	
	j leteclafora
	
help_tela:
	li a1, 0xFF000000	# endereco inicial
	printIMG(help) 		#imprime fundo
	
	j leteclafora

credit_tela:
	li a1, 0xFF000000	# endereco inicial
	printIMG(credits) 	#imprime fundo
	
	j leteclafora

fim:	li a7,10		# syscall de exit
	ecall
