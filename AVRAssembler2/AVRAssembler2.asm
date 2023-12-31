 .include "m2560def.inc"
 .def temp = r16
 .def temp2 = r17
 
 rjmp reset

 ; ������ ���������� ���������� INT0
 .org INT0addr 
	rjmp handle_pd2

; ������ ���������� ���������� INT1
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
	
	;����������� ������
	
	clr temp ; ������������� ��� ���� �������� r16 �� 0
	out DDRD, temp ; ������������� ��� ������ ����� D �� ����, ��� ��� ������
	out DDRC, temp ; ������������� ��� ������ ����� C �� ����, ��� ��� ��������������

	ser temp ; ������������� ��� ���� �������� r16 �� 1
	out PORTD, temp ; �������� ���������� ������������� ��������� ��� ������
	out PORTC, temp ; �������� ���������� ������������� ��������� ��� ��������������
	out DDRA, temp ; ������������� ��� ���� ����� A �� �����, ��� ��� �����������

 main:
 	out PORTA, temp
	rjmp main

handle_pd2:
	in temp2, PINC ; ���������� � ������� r16 ��������� ������ ����� C 
	and temp, temp2 ; ��������� �������� ����������� ��� 
	reti ; ������� �� ����������

handle_pd3:
	ser temp ; ������������� ��� ���� �� 1
	reti ; ������� �� ����������