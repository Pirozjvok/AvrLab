 .include "m2560def.inc"
 .def temp = r16
 .def temp2 = r17
 .def dir = r18
 .def inv = r19
 .def rab = r20

 rjmp reset

 .org INT0addr 
	rjmp handle_pd2

 .org INT1addr
	rjmp handle_pd3

 reset: ;Подпрограмма в которой мы инизицализируем все
	;; Настраиваем прерывания
	ldi temp, (1<<ISC00) | (1<<ISC01) | (1<<ISC10) | (1<<ISC11) ; Заносим флаги настроек прерываний
	sts EICRA, temp ; Устанавливаем прерывание по восходящему фронту

	ldi temp, (1<<INT0) | (1<<INT1) ; Запихиваем в temp значение 0x00000011
	out EIMSK, temp


	;; Настраиваем стек
	ldi	temp,LOW(RAMEND)  ; Загружаем младший байт константы RAMEND в регистр r16
	out	SPL,temp			 ; Загружаем значение из регистра r16 в регистр SPL
	ldi	temp,HIGH(RAMEND) ; Загружаем старший байт константы RAMEND в регистр r16
	out	SPH,temp			 ; Загружаем значение из регистра r16 в регистр SPH
	/* 
		Короче для того чтобы задать вершину стека нужно установить его адреc
		в двух 8-битных регистрах
		SPL (Stack Pointer Low) 
		и
		SPH (Stack Pointer High)
		которые находятся в пространстве регистров ввода вывода.
		Константа RAMEND хранит адрес на вершину стека.
		Он определен в файле m328pdef.inc
	*/

	;Настраиваем выводы
	
	clr temp ; Устанавливаем все биты регистра r16 на 0
	out DDRD, temp ; Устанавливаем все выводы порта D на вход
	out DDRC, temp ; Устанавливаем все выводы порта C на вход

	ser temp ; Устанавливаем все биты регистра r16 на 1
	ldi temp, 0xFF
	out DDRB, temp ; Устанавливаем все пины порта B на выход
	out PORTC, temp ; Включаем внутренние подтягивающие резисторы
	sei ; Разрешаем все прерывания, установка 7 разряда регистра SREG в 1

 main:
	rjmp main

handle_pd2:
	push temp
	in temp, SREG
	push temp
	push temp2
	in temp, PINC ; Записывыем в регистр r16 состояние входов порта C 
	ldi temp2, 0x04
	mul temp, temp2
	out PORTB, temp
	pop temp2
	pop temp
	out SREG, temp
	pop temp
	reti ; Выходим из прерывания

handle_pd3:
	push temp
	in temp, SREG
	push temp
	in temp, PINC ; Записывыем в регистр r16 состояние входов порта C 
	out PORTB, temp
	pop temp
	out SREG, temp
	pop temp
	reti ; Выходим из прерывания