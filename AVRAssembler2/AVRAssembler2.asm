 .include "m2560def.inc"
 .def temp = r16
 .def temp2 = r17
 
 rjmp reset

 .org INT0addr 
	rjmp handle_pd2

 .org INT1addr
	rjmp handle_pd3

 reset: ;������������ � ������� �� ��������������� ���
	;; ����������� ����������
	ldi temp, (1<<ISC00) | (1<<ISC01) | (1<<ISC10) | (1<<ISC11) ; ������� ����� �������� ����������
	sts EICRA, temp ; ������������� ���������� �� ����������� ������

	ldi temp, (1<<INT0) | (1<<INT1) ; ���������� � temp �������� 0x00000011
	out EIMSK, temp

	;����������� ������
	
	clr temp ; ������������� ��� ���� �������� r16 �� 0
	out DDRD, temp ; ������������� ��� ������ ����� D �� ����
	out DDRC, temp ; ������������� ��� ������ ����� C �� ����

	ser temp ; ������������� ��� ���� �������� r16 �� 1
	ldi temp, 0xFF
	out DDRB, temp ; ������������� ��� ���� ����� B �� �����
	out PORTC, temp ; �������� ���������� ������������� ���������
	sei ; ��������� ��� ����������, ��������� 7 ������� �������� SREG � 1

 main:
	out PORTB, temp
	rjmp main

handle_pd2:
	in temp2, PINC ; ���������� � ������� r16 ��������� ������ ����� C 
	and temp, temp2 ; ��������� �������� ����������� ��� 
	reti ; ������� �� ����������

handle_pd3:
	ser temp ; ������������� ��� ���� �� 1
	reti ; ������� �� ����������