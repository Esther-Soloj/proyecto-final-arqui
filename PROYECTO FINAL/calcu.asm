section .data
    stack db 20        ; tamaño de la pila
    buffer db 20       ; tamaño del buffer
    input db buffer, 0 ; entrada del usuario
    output db buffer, 0 ; salida de la calculadora
    file db 'operaciones.txt', 0 ; nombre del archivo de operaciones
    fp dd 0 ; puntero de archivo
    eof dd 0 ; indicador de final de archivo
    num db 0 ; buffer para convertir de ASCII a número
    num_digits db 0 ; cantidad de dígitos del número
    operandos dd 0 ; cantidad de operandos en la pila
    resultado dd 0 ; resultado de la operación

section .bss
    pila resb stack ; pila para almacenar los operandos

section .text
    global _start

_start:
    ; Abrir archivo
    mov eax, 5 ; sys_open
    mov ebx, file
    mov ecx, 0 ; O_RDONLY
    int 0x80
    mov [fp], eax ; guardar el puntero de archivo

    ; Leer archivo
    lea ebx, [input]
    mov ecx, buffer
    mov edx, buffer
    mov eax, 3 ; sys_read
    mov ebx, [fp]
    int 0x80
    mov ecx, eax ; cantidad de bytes leídos
    mov [input+eax], 0 ; agregar el byte nulo al final de la entrada

    ; Procesar entrada
    lea esi, [input]
    lea edi, [output]
    mov [num_digits], 0
    mov [operandos], 0
    .loop:
        mov al, [esi]
        cmp al, 0
        je .done
        cmp al, 10 ; salto de línea
        je .done
        cmp al, 32 ; espacio
        je .skip
        cmp al, 48 ; '0'
        jl .invalid
        cmp al, 57 ; '9'
        jg .invalid
        mov [num], al
        sub al, 48
        mov bl, [num_digits]
        mov [num+bl], al
        inc byte [num_digits]
        jmp .next
        .invalid:
            cmp al, 43 ; '+'
            je .add
            cmp al, 45 ; '-'
            je .sub
            cmp al, 42 ; '*'
            je .mul
            cmp al, 47 ; '/'
            je .div
            jmp .done
        .add:
            call sumar
            jmp .next
        .sub:
            call restar
            jmp .next
        .mul:
            call multiplicar
            jmp .next
        .div:
            call dividir
            jmp .next
        .next:
            inc esi
            cmp byte [num_digits], 0
            je .loop
        .skip:
            cmp byte [num_digits], 0
            jne .push
            jmp .loop
        .push:
            mov eax, [num]
            mov ebx, 10
            mul ebx
            mov ebx, [operandos]
            mov edi, pila
            add edi, ebx
            add eax, [edi]
            mov [edi], eax
            inc dword [operandos]
            xor
