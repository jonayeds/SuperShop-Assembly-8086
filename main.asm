.model small
.stack 100h

.data
     intro           DB '-------WELLCOME to SUPER SHOP-------$'
     instructions    DB 'Select categories to view product$'
     selected        DB 'Selected : $'
     select_category DB 'Select Category: $'
     select_product DB 'Select Product: $'
     select_quantity DB 'Select Quantity: $'
     product_msg DB 'Product - $'
     quantity_msg DB '|| Quantity - $'
     invalid_input   DB 'Invalid Input || Try again!!$'
     product_price   DB ' - Price: $'
     total_price_msg DB 'Total Price - $'
     
     cat1            DB 'SNACKS$'
     cat2            DB 'VEGETABLES$'
     cat3            DB 'FRUITES$'
     catPtrs         DW OFFSET cat1, OFFSET cat2, OFFSET cat3
     num_of_category DB 3
     ; Product name labels
     fruit1_name     DB 'Mango$'
     fruit2_name     DB 'Banana$'
     fruit3_name     DB 'Lichi$'

     veg1_name       DB 'Salad$'
     veg2_name       DB 'Lemon$'
     veg3_name       DB 'Broccoli$'

     snack1_name     DB 'Dark Chocolate$'
     snack2_name     DB 'Cold Drink$'
     snack3_name     DB 'French Fry$'

     ; Product tables: pairs of WORDs: OFFSET name, price
     fruit_table     DW OFFSET fruit1_name, 100, OFFSET fruit2_name, 200, OFFSET fruit3_name, 350
     veg_table       DW OFFSET veg1_name, 250, OFFSET veg2_name, 200, OFFSET veg3_name, 350
     snack_table     DW OFFSET snack1_name, 550, OFFSET snack2_name, 200, OFFSET snack3_name, 350

     ; Map categories to their product tables
     product_list    DW OFFSET snack_table, OFFSET veg_table, OFFSET fruit_table
     num_of_products DB 3

     total_spend DW 0
     selected_category DB ?
     selected_product DB ?
     selected_product_name DW ?
     selected_product_price DW ?
     quantity DW 0





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

display_number proc
                            push cx                             ; Save CX as it's used for loop counting
                            mov  bx, 10                          ; Set divisor to 10
                            mov  cx, 0                           ; Digit counter
                     CONVERT_LOOP:
                            mov  dx, 0                           ; Clear DX for 16-bit division
                            div  bx                             ; AX = quotient, DX = remainder
                            push dx                              ; Save remainder
                            inc  cx                             ; Increment digit count
                            cmp  ax, 0                           ; Check if quotient is 0
                            jne  CONVERT_LOOP                    ; If not zero, continue dividing
                     DISPLAY_LOOP:
                            pop  dx                              ; Get digit
                            add  dl, '0'                         ; Convert to ASCII
                            mov  ah, 02h                         ; DOS function to display a character
                            int  21h                            ; Call DOS interrupt
                            loop DISPLAY_LOOP                    ; Decrement CX and repeat
                            pop  cx                              ; Restore CX
                            ret
                            endp display_number

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
                           mov ch,0
                            mov   cl, [num_of_category]
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
                            je   exit_input_category
                            cmp  al, '0'
                            jl   invalid_character_category
                            cmp  al, '9'
                            jg   invalid_character_category
                            mov  bh, al
                            sub  bh, 30h
                            mov  al, dl
                            mul  bl
                            add  al, bh
                            mov  dl, al                         ; input stored in dl as decimal value
                            LOOP l2
                            jmp  exit_input_category
     invalid_character_category:                                    ; Restart input if the caracter is invalid
                            mov  si, OFFSET invalid_input
                            call print_string
                            call next_line
                            jmp  select_category_input
     exit_input_category:
                            mov  bl, [num_of_category]
                            cmp  dl, 1
                            jl   invalid_character_category
                            cmp  dl, bl
                            jle  valid_category
                            mov  si, OFFSET invalid_input
                            call print_string
                            call next_line
                            jmp  select_category_input

     valid_category:
                            mov  bl, dl
                            mov selected_category, bl
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
                            mov  bh,2
                            mov  al, bl
                            mul  bh

                            mov  ah,0
                            mov  si, offset product_list
                            add  si, ax
                            mov  di, [si]
                           mov ch,0
                            mov   cl, [num_of_products]
                            mov  bh, 1
     display_products:
                            mov  ah, 02h
                            mov  dl, bh
                            add  dl, '0'
                            int  21h
                            mov  ah, 02h
                            mov  dl, '.'
                            int  21h
                            mov  ah, 02h
                            mov  dl, ' '
                            int  21h
                            inc  bh
                           
                            mov  si, [di]
                            call print_string

                            ; Print " - Price: "
                            mov  si, OFFSET product_price
                            call print_string

                            add  di,2
                            mov  ax, [di]
                            push bx
                            call display_number
                            pop bx


                            call next_line
                            add  di, 2
                            LOOP display_products

                            ; take input
     select_product_input:
                            mov  si, OFFSET select_product
                            call print_string
                            mov  cx,3
                            mov  dl,0
                            mov  al,0
                            mov  bl,10
     l3:
                            mov  ah, 01h
                            int  21h
                            cmp  al, 0Dh                        ; if pressed enter, then exit input
                            je   exit_input_product
                            cmp  al, '0'
                            jl   invalid_character_product
                            cmp  al, '9'
                            jg   invalid_character_product
                            mov  bh, al
                            sub  bh, 30h
                            mov  al, dl
                            mul  bl
                            add  al, bh
                            mov  dl, al                         ; input stored in dl as decimal value
                            LOOP l3
                            jmp  exit_input_product
     invalid_character_product:                                    ; Restart input if the caracter is invalid
                            mov  si, OFFSET invalid_input
                            call print_string
                            call next_line
                            jmp  select_product_input
     exit_input_product:
                            mov  bl, [num_of_category]
                            cmp  dl, 1
                            jl   invalid_character_product
                            cmp  dl, bl
                            jle  valid_product
                            mov  si, OFFSET invalid_input
                            call print_string
                            call next_line
                            jmp  select_product_input
      valid_product:
                            mov selected_product, dl
                            mov bl,2
                            mov al, [selected_category]
                            dec al
                            mov ah,0
                            mul bl
                            mov si, OFFSET product_list
                            add si, ax
                            mov si,[si]
                            mov bl,4
                            mov al, [selected_product]
                            dec al
                            mov ah,0
                            mul bl
                            add si, ax
                            push si
                            mov si,[si]
                            mov selected_product_name, si
                            call print_string
                            mov si, OFFSET product_price
                            call print_string
                            pop si
                            mov ax, [si+2]
                            mov selected_product_price, ax
                            call display_number
                            call next_line




      select_quantity_input:
                            mov  si, OFFSET select_quantity
                            call print_string
                            mov  cx,3
                            mov  dl,0
                            mov  al,0
                            mov  bl,10
     l4:
                            mov  ah, 01h
                            int  21h
                            cmp  al, 0Dh                        ; if pressed enter, then exit input
                            je   exit_input_quantity
                            cmp  al, '0'
                            jl   invalid_character_quantity
                            cmp  al, '9'
                            jg   invalid_character_quantity
                            mov  bh, al
                            sub  bh, 30h
                            mov  al, dl
                            mul  bl
                            add  al, bh
                            mov  dl, al                         ; input stored in dl as decimal value
                            LOOP l4
                            jmp  exit_input_quantity
     invalid_character_quantity:                                    ; Restart input if the caracter is invalid
                            mov  si, OFFSET invalid_input
                            call next_line
                            call print_string
                            call next_line
                            jmp  select_product_input
     exit_input_quantity:
                        mov dh,0
                        mov ax, dx
                        mov quantity, ax
      calculate_total:
                        mov si, offset product_msg
                        call print_string 
                        mov si, [selected_product_name]
                        call print_string
                        
                        mov si, offset quantity_msg
                        call print_string
                        mov ax, quantity
                        call display_number
                        call next_line
                        
                        mov si, offset total_price_msg
                        call print_string
                        mov ax, selected_product_price
                        mov bx, [quantity]
                        mul bx
                        call display_number
                        
                        


                        
                            


     ex:
                            MOV  AH, 4Ch
                            INT  21h
main endp
end main