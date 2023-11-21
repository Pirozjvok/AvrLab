 .include "m2560def.inc"
 .def temp = r16
 .def temp2 = r17
 
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
	out PORTB, temp
	rjmp main

handle_pd2:
	in temp2, PINC ; Записывыем в регистр r16 состояние входов порта C 
	and temp, temp2 ; Применяем операцию логического или 
	reti ; Выходим из прерывания

handle_pd3:
	ser temp ; Устанавливаем все биты на 1
	reti ; Выходим из прерывания