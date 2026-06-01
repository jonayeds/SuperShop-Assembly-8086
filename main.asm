.model small
.stack 100h

.data
     intro           DB '-------WELLCOME to SUPER SHOP-------$'
     instructions    DB 'Select categories to view product$'
     select_category DB 'Select Category: $'
     invalid_input   DB 'Invalid Input || Try again!!$'
     cat1            DB 'SNACKS$'
     cat2            DB 'VEGETABLES$'
     cat3            DB 'FRUITES$'
     catPtrs         DW OFFSET cat1, OFFSET cat2, OFFSET cat3
     num_of_category DB 3


.code
next_line proc
                      MOV  AH, 02h
                      MOV  DL, 10
                      INT  21h
                      ret
next_line endp

print_string proc
                      MOV  dx, si
                      mov  ah, 09h
                      int  21h
                      ret
print_string endp

display_list proc                                         ; Required: list offset in the DI register && each element = 16 bit && CX= Number of elements
                      mov  bl, 1
     l1:
                      ; print number and separator
                      mov  dl, bl
                      add  dl, '0'
                      mov  ah, 02h
                      int  21h
                      mov  dl, '.'
                      mov  ah, 02h
                      int  21h
                      mov  dl, ' '
                      mov  ah, 02h
                      int  21h

                      ; print category string
                      mov  si, [di]
                      call print_string
                      call next_line

                      add  di, 2
                      inc  bl
                      loop l1
                      ret
                      endp display_list

main proc
                      mov  AX, @data
                      mov  ds, ax
                      MOV  si, OFFSET intro
                      call print_string
                      call next_line
                      mov  si, offset instructions
                      call print_string
                      call next_line
                      ; Display the categories numbered
                      mov  di, OFFSET catPtrs
                      mov  cl, [num_of_category]
                      call display_list

     ; take input
     select_category_input:
                      mov  si, OFFSET select_category
                      call print_string
                      mov  cx,3
                      mov  dl,0
                      mov  al,0
                      mov  bl,10
     l2:
                      mov  ah, 01h
                      int  21h
                      cmp  al, 0Dh                        ; if pressed enter, then exit input
                      je   exit_input
                      mov bh, al
                      sub bh, 30h
                      mov al, dl
                      mul bl
                      add  dl, bh                         ; input stored in dl as Hex
                      LOOP l2
     exit_input:
                    mov bl, [num_of_category]
                      cmp  dl, bl
                      jle   valid_category
                      mov  si, OFFSET invalid_input
                      call print_string
                      call next_line
                      jmp select_category_input

     valid_category:

     ex:
                      MOV  AH, 4Ch
                      INT  21h
main endp
end main