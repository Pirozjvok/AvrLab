 .include "m2560def.inc"
 .def temp = r16
 .def temp2 = r17
 .def rab = r18
 .def start = r19

 rjmp reset

 .org INT0addr 
	rjmp handle_pd2

 .org INT1addr
	rjmp handle_pd3

 reset: ;Подпрограмма в которой мы инизицализируем все

	;; Настраиваем прерывания
	ldi temp, (1<<ISC01) | (1<<ISC11) ; Заносим флаги настроек прерываний по нисходящему фронту
	sts EICRA, temp ; Заносим эти флаги в регистр EICRA

	;; Разрешаем прерывания
	ldi temp, (1<<INT0) | (1<<INT1) ; Заносим флаги резрешения прерываний INT0 и INT1
	out EIMSK, temp ; Заносим эти флаги в регистр EIMSK
	sei ; Разрешаем все прерывания, установка 7 разряда регистра SREG в 1

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
	out DDRD, temp ; Устанавливаем все выводы порта D на вход, это для кнопок
	out DDRC, temp ; Устанавливаем все выводы порта C на вход, это для переключателей

	ser start
	ser temp ; Устанавливаем все биты регистра r16 на 1
	out PORTD, temp ; Включаем внутренние подтягивающие резисторы для кнопок
	out DDRA, temp ; Устанавливаем все пины порта A на выход, это для светодиодов
	out PORTC, temp ; Включаем внутренние подтягивающие резисторы для переключателей

 main:
	sbrc start, 0
	rjmp main

; ------- Сдвиг вправо -----------
m1: 
	ldi rab, 0b10000000
m2:
	ldi temp, 0xFF
	out PORTA, rab
	rcall delay
	lsr rab
	brcc m2
	in temp, PINC ; Записывыем в регистр r16 состояние входов порта C 
	clr temp2 ; Очищаем temp2
	cp temp, start ; Сравниваем с 0, т.к start на данный момент обнулен
	breq m4 ; Если 0 то переходим в m4
	ldi temp2, 0x01 ; Загружаем еденицу в регистр temp2
m3:
	lsl temp2
	dec temp
	brne m3
	dec temp2
m4:
	out PORTA, temp2
	ser start
	rjmp main

handle_pd2:
	push temp
	in temp, SREG
	push temp
	in temp, PINC ; Записывыем в регистр r16 состояние входов порта C 
	out PORTA, temp ; Записываем в PORTA регистр temp
	pop temp
	out SREG, temp
	pop temp
	reti ; Выходим из прерывания

handle_pd3:
	push temp
	in temp, SREG
	push temp
	clr start ; Очищаем регистр start
	pop temp
	out SREG, temp
	pop temp
	reti ; Выходим из прерывания

delay: ; Задержка
	ldi temp, 0xFF
	d0:
		ldi temp2, 0xFF
	d2:
		dec temp2
	brne d2
	dec temp
	brne d0
	ret