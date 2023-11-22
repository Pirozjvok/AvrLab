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

	ser temp ; Устанавливаем все биты регистра r16 на 1
	out PORTD, temp ; Включаем внутренние подтягивающие резисторы для кнопок
	out DDRA, temp ; Устанавливаем все пины порта A на выход, это для светодиодов

 main:
	sbrc dir, 0
	rjmp m3

; ------- Сдвиг вправо -----------
m1: 
	ldi rab, 0b10000000
m2:
	ldi temp, 0xFF
	sbrc inv, 0
	eor temp, rab
	out PORTA, rab
	rcall delay
	lsr rab
	brcc m2
	rjmp main

	; ------- Сдвиг влево -----------
m3: 
	ldi rab, 0b00000001
m4:
	ldi temp, 0xFF
	sbrc inv, 0
	eor temp, rab
	out PORTA, rab
	rcall delay
	lsr rab
	brcc m4
	rjmp main

handle_pd2:
	push temp
	in temp, SREG
	push temp
	ldi temp, 0xFF
	eor dir, temp
	pop temp
	out SREG, temp
	pop temp
	reti ; Выходим из прерывания

handle_pd3:
	push temp
	in temp, SREG
	push temp
	ldi temp, 0xFF
	eor inv, temp
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