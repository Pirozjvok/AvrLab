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

	ser temp ; ������������� ��� ���� �������� r16 �� 1
	out PORTD, temp ; �������� ���������� ������������� ��������� ��� ������
	out PORTC, temp ; �������� ���������� ������������� ��������� ��� ��������������
	out DDRA, temp ; ������������� ��� ���� ����� A �� �����, ��� ��� �����������

main:
	rjmp main

handle_pd2:
	push temp
	in temp, SREG
	push temp
	push temp2
	in temp, PINC ; ���������� � ������� r16 ��������� ������ ����� C 
	ldi temp2, 0x04
	mul temp, temp2
	out PORTA, temp
	pop temp2
	pop temp
	out SREG, temp
	pop temp
	reti ; ������� �� ����������

handle_pd3:
	push temp
	in temp, SREG
	push temp
	in temp, PINC ; ���������� � ������� r16 ��������� ������ ����� C 
	out PORTA, temp
	pop temp
	out SREG, temp
	pop temp
	reti ; ������� �� ����������