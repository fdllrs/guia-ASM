extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret








alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[?], x2[?], x3[?], x4[?], x5[?], x6[?], x7[?], x8[?]
alternate_sum_8:

	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[?], x1[?], f1[?]
product_2_f:
  CVTSI2SD xmm1, ESI
  CVTSS2SD xmm0, xmm0
  mulsd xmm1,xmm0
  CVTTSD2SI eax, xmm1

  mov dword [rdi], eax  
	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[?], f2[?], x3[?], f3[?], x4[?], f4[?]
;	, x5[?], f5[?], x6[?], f6[?], x7[?], f7[?], x8[?], f8[?],
;	, x9[?], f9[?]
; dest -> EDI
; x1 -> ESI
; x2 -> EDX
; x3 -> ECX
; x4 -> R8D
; x5 -> R9D
; x6 -> stack(0) -> R10D (v)
; x7 -> stack(1) -> R11D (v)
; x8 -> stack(2) -> R12D (nv)
; x9 -> stack(3) -> R13D (nv)
; f1 -> XMM0
; f2 -> XMM1
; f3 -> XMM2
; f4 -> XMM3
; f5 -> XMM4
; f6 -> XMM5
; f7 -> XMM6
; f8 -> XMM7
; f9 -> stack(4) -> XMM8 (nv)

product_9_f:

  ;prologo
  push RBP
  mov RBP, RSP
  push R12
  push R13
  sub RSP, 16
  movaps [RSP], XMM8

  sub RSP, 16
  movaps [RSP], XMM9
  ;--
  mov R10D, [RBP + 8*2]
  mov R11D, [RBP + 8*3]
  mov R12D, [RBP + 8*4]
  mov R13D, [RBP + 8*5]
  movss XMM8, [RBP + 8*6]

  ;convertimos single precision a double precision
  CVTSS2SD XMM0, XMM0
  CVTSS2SD XMM1, XMM1
  CVTSS2SD XMM2, XMM2
  CVTSS2SD XMM3, XMM3
  CVTSS2SD XMM4, XMM4
  CVTSS2SD XMM5, XMM5
  CVTSS2SD XMM6, XMM6
  CVTSS2SD XMM7, XMM7
  CVTSS2SD XMM8, XMM8


  ; multiplicamos los float
  MULSD XMM0, XMM1
  MULSD XMM0, XMM2
  MULSD XMM0, XMM3
  MULSD XMM0, XMM4
  MULSD XMM0, XMM5
  MULSD XMM0, XMM6
  MULSD XMM0, XMM7
  MULSD XMM0, XMM8


  ;convertimos integer a double precision float
  CVTSI2SD XMM1, ESI
  CVTSI2SD XMM2, EDX
  CVTSI2SD XMM3, ECX
  CVTSI2SD XMM4, R8D
  CVTSI2SD XMM5, R9D
  CVTSI2SD XMM6, R10D
  CVTSI2SD XMM7, R11D
  CVTSI2SD XMM8, R12D
  CVTSI2SD XMM9, R13D


  ; multiplicamos los integer convertidos por XMM0
  MULSD XMM0, XMM1
  MULSD XMM0, XMM2
  MULSD XMM0, XMM3
  MULSD XMM0, XMM4
  MULSD XMM0, XMM5
  MULSD XMM0, XMM6
  MULSD XMM0, XMM7
  MULSD XMM0, XMM8
  MULSD XMM0, XMM9



  movsd [RDI], XMM0

  ;epilogo
  movaps XMM9, [RSP]
  add RSP, 16
  movaps XMM8, [RSP]
  add RSP, 16
  pop R13
  pop R12
  pop RBP
	ret