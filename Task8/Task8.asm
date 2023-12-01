 .include "m2560def.inc"
 .def temp = r16
 .def temp2 = r17
 .def temp3 = r18
 .def dir = r19
 .def inv = r20
 .def rab = r21

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

	ser temp ; ������������� ��� ���� �������� r16 �� 1
	out PORTD, temp ; �������� ���������� ������������� ��������� ��� ������
	out DDRA, temp ; ������������� ��� ���� ����� A �� �����, ��� ��� �����������

 main:
	sbrc dir, 0
	rjmp m3

; ------- ����� ������ -----------
m1: 
	ldi rab, 0b10000000
m2:
	ldi temp, 0xFF
	mov temp2, rab
	sbrc inv, 0
	eor temp2, temp
	out PORTA, temp2
	rcall delay
	lsr rab
	brcc m2
	rjmp main

	; ------- ����� ����� -----------
m3: 
	ldi rab, 0b00000001
m4:
	ldi temp, 0xFF
	mov temp2, rab
	sbrc inv, 0
	eor temp2, temp
	out PORTA, temp2
	rcall delay
	lsl rab
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
	reti ; ������� �� ����������

handle_pd3:
	push temp
	in temp, SREG
	push temp
	ldi temp, 0xFF
	eor inv, temp
	pop temp
	out SREG, temp
	pop temp
	reti ; ������� �� ����������

delay: ; ��������
	ldi temp, 0x10
	d0:
		ldi temp2, 0xFF
	d1: 
		ldi temp3, 0xFF
	d2:
		dec temp3
		brne d2
	d3: 
		dec temp2
		brne d1
	dec temp
	brne d0
	ret