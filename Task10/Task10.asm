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

 reset: ;������������ � ������� �� ��������������� ���

	;; ����������� ����������
	ldi temp, (1<<ISC01) | (1<<ISC11) ; ������� ����� �������� ���������� �� ����������� ������
	sts EICRA, temp ; ������� ��� ����� � ������� EICRA

	;; ��������� ����������
	ldi temp, (1<<INT0) | (1<<INT1) ; ������� ����� ���������� ���������� INT0 � INT1
	out EIMSK, temp ; ������� ��� ����� � ������� EIMSK
	sei ; ��������� ��� ����������, ��������� 7 ������� �������� SREG � 1

	;; ����������� ����
	ldi	temp,LOW(RAMEND)  ; ��������� ������� ���� ��������� RAMEND � ������� r16
	out	SPL,temp			 ; ��������� �������� �� �������� r16 � ������� SPL
	ldi	temp,HIGH(RAMEND) ; ��������� ������� ���� ��������� RAMEND � ������� r16
	out	SPH,temp			 ; ��������� �������� �� �������� r16 � ������� SPH
	/* 
		������ ��� ���� ����� ������ ������� ����� ����� ���������� ��� ����c
		� ���� 8-������ ���������
		SPL (Stack Pointer Low) 
		�
		SPH (Stack Pointer High)
		������� ��������� � ������������ ��������� ����� ������.
		��������� RAMEND ������ ����� �� ������� �����.
		�� ��������� � ����� m328pdef.inc
	*/

	;����������� ������
	
	clr temp ; ������������� ��� ���� �������� r16 �� 0
	out DDRD, temp ; ������������� ��� ������ ����� D �� ����, ��� ��� ������
	out DDRC, temp ; ������������� ��� ������ ����� C �� ����, ��� ��� ��������������

	ser start
	ser temp ; ������������� ��� ���� �������� r16 �� 1
	out PORTD, temp ; �������� ���������� ������������� ��������� ��� ������
	out DDRA, temp ; ������������� ��� ���� ����� A �� �����, ��� ��� �����������
	out PORTC, temp ; �������� ���������� ������������� ��������� ��� ��������������

 main:
	sbrc start, 0
	rjmp main

; ------- ����� ������ -----------
m1: 
	ldi rab, 0b10000000
m2:
	ldi temp, 0xFF
	out PORTA, rab
	rcall delay
	lsr rab
	brcc m2
	in temp, PINC ; ���������� � ������� r16 ��������� ������ ����� C 
	clr temp2 ; ������� temp2
	cp temp, start ; ���������� � 0, �.� start �� ������ ������ �������
	breq m4 ; ���� 0 �� ��������� � m4
	ldi temp2, 0x01 ; ��������� ������� � ������� temp2
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
	in temp, PINC ; ���������� � ������� r16 ��������� ������ ����� C 
	out PORTA, temp ; ���������� � PORTA ������� temp
	pop temp
	out SREG, temp
	pop temp
	reti ; ������� �� ����������

handle_pd3:
	push temp
	in temp, SREG
	push temp
	clr start ; ������� ������� start
	pop temp
	out SREG, temp
	pop temp
	reti ; ������� �� ����������

delay: ; ��������
	ldi temp, 0xFF
	d0:
		ldi temp2, 0xFF
	d2:
		dec temp2
	brne d2
	dec temp
	brne d0
	ret