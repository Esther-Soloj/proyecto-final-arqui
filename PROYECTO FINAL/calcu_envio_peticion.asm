; archivo: rpn.asm
; descripción: calculadora RPN con entrada/salida utilizando llamadas al sistema de Linux

section .data
    stack: resb 1024  ; pila de 1024 bytes
    stack_top:  dd 0  ; puntero a la cima de la pila
    input_buffer: times 256 db 0 ; búfer de entrada
    output_buffer: times 256 db 0 ; búfer de salida

section .text
    global _start

; función para agregar un valor a la pila
push:
    mov eax, [stack_top]
    mov edx, [esp+4]
    mov [stack+eax], edx
    add eax, 4
    mov [stack_top], eax
    ret

; función para obtener un valor de la pila
pop:
    mov eax, [stack_top]
    sub eax, 4
    mov edx, [stack+eax]
    mov [stack_top], eax
    mov [esp+4], edx
    ret

; función para sumar dos valores
add:
    call pop
    mov ebx, [esp+4]
    add eax, ebx
    call push
    ret

; función para restar dos valores
sub:
    call pop
    mov ebx, [esp+4]
    sub eax, ebx
    call push
    ret

; función para multiplicar dos valores
mul:
    call pop
    mov ebx, [esp+4]
    imul ebx
    call push
    ret

; función para dividir dos valores
div:
    call pop
    mov ebx, [esp+4]
    xor edx, edx
    div ebx
    call push
    ret

; función para leer una entrada del usuario
read_input:
    mov eax, 3  ; syscall para leer desde stdin
    mov ebx, 0  ; descriptor de archivo stdin
    mov ecx, input_buffer  ; búfer de entrada
    mov edx, 256  ; longitud máxima de entrada
    int 0x80  ; llamada al sistema
    ret

; función para escribir una salida al usuario
write_output:
    mov eax, 4  ; syscall para escribir en stdout
    mov ebx, 1  ; descriptor de archivo stdout
    mov ecx, output_buffer  ; búfer de salida
    mov edx, 256  ; longitud de la salida
    int 0x80  ; llamada al sistema
    ret

_start:
    ; inicializar la pila
    mov [stack_top], 0

    ; imprimir un mensaje de bienvenida
    mov eax, output_buffer
    mov dword [eax], 'Bien'  ; "Bien"
    mov byte [eax+4], 'v'
    mov byte [eax+5], 'e'
    mov byte [eax+6], 'n'
    mov byte [eax+7], 'i'
    mov byte [eax+8], 'd'
    mov byte [eax+9], 'o'
    mov byte [eax+10], '!'
    mov byte [eax+11], '\n'
    mov edx, 12
    call write_output

    ; bucle principal
    loop:
        ; leer la entrada del usuario
        call read_input

        ; si la entrada es "q", salir del programa
        mov eax, input_buffer
        cmp dword [eax], 'q'  ; "q"
        jz exit

        ; si la entrada es un número
