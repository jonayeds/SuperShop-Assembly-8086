.model small
.stack 100h

.data
     intro           DB      '-------WELLCOME to SUPER SHOP-------$'
     instructions    DB      'Select categories to view product$'
     selected        DB      'Selected : $'
     select_category DB      'Select Category: $'
     invalid_input   DB      'Invalid Input || Try again!!$'
     cat1            DB      'SNACKS$'
     cat2            DB      'VEGETABLES$'
     cat3            DB      'FRUITES$'
     catPtrs         DW      OFFSET cat1, OFFSET cat2, OFFSET cat3
     num_of_category DB      3
                         ; Product name labels (dollar-terminated)
     fruit1_name DB 'Mango$'
     fruit2_name DB 'Banana$'
     fruit3_name DB 'Lichi$'

     veg1_name   DB 'Salad$'
     veg2_name   DB 'Lemon$'
     veg3_name   DB 'Broccoli$'

     snack1_name DB 'Dark Chocolate$'
     snack2_name DB 'Cold Drink$'
     snack3_name DB 'French Fry$'

     ; Product tables: pairs of WORDs: OFFSET name, price
     fruit_table DW OFFSET fruit1_name, 100, OFFSET fruit2_name, 200, OFFSET fruit3_name, 350
     veg_table   DW OFFSET veg1_name, 250, OFFSET veg2_name, 200, OFFSET veg3_name, 350
     snack_table DW OFFSET snack1_name, 550, OFFSET snack2_name, 200, OFFSET snack3_name, 350

     ; Map categories to their product tables
     product_list DW OFFSET snack_table, OFFSET veg_table, OFFSET fruit_table
     num_of_products DB 3



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

display_list proc                                               ; Required: list offset in the DI register && each element = 16 bit && CX= Number of elements
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
                            cmp  al, '0'
                            jl   invalid_character
                            cmp  al, '9'
                            jg   invalid_character
                            mov  bh, al
                            sub  bh, 30h
                            mov  al, dl
                            mul  bl
                            add  dl, bh                         ; input stored in dl as Hex
                            LOOP l2
                            jmp  exit_input
     invalid_character:                                    ; Restart input if the caracter is invalid
                            mov  si, OFFSET invalid_input
                            call print_string
                            call next_line
                            jmp  select_category_input
     exit_input:
                            mov  bl, [num_of_category]
                            cmp  dl, 1
                            jl   invalid_character
                            cmp  dl, bl
                            jle  valid_category
                            mov  si, OFFSET invalid_input
                            call print_string
                            call next_line
                            jmp  select_category_input

     valid_category:
                            mov  bl, dl
                            mov  si, offset selected
                            call print_string
                            mov  si, offset catPtrs
                            dec  bl
                            mov  bh, 2
                            mov  al, bl
                            mul  bh
                            mov  ah,0
                            add  si, ax
                            mov  si, [si]
                            call print_string

                            call next_line
                         ;    mov ah, 02h
                         ;    mov dl, bl
                         ;    add dl, '0'
                         ;    int 21h
                         mov bh,2
                         mov al, bl
                         mul bh
                         
                         mov ah,0
                         mov si, offset product_list
                         add si, ax
                         mov di, [si]
                         mov cl, [num_of_products]
                         mov bh, 1
                         l3:
                         mov ah, 02h
                         mov dl, bh
                         add dl, '0'
                         int 21h
                         mov ah, 02h
                         mov dl, '.'
                         int 21h
                         mov ah, 02h
                         mov dl, ' '
                         int 21h
                         inc bh

                         mov si, [di]
                         call print_string
                         call next_line
                         add di, 4
                         LOOP l3


     ex:
                            MOV  AH, 4Ch
                            INT  21h
main endp
end main