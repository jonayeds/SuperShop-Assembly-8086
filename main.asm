.model small
.stack 100h

MAX_BILL_ITEMS EQU 20

.data
       intro                          DB '======= SMART SUPERSHOP =======$'
       instructions                   DB 'Browse products, build your cart, and generate a bill.$'
       selected                       DB 'Selected Category: $'
       select_category                DB 'Choose a category number: $'
       select_product                 DB 'Choose a product number: $'
       select_quantity                DB 'Enter quantity: $'
       product_msg                    DB 'Product: $'
       quantity_msg                   DB ' | Quantity: $'
       invalid_input                  DB 'Invalid input. Please try again.$'
       product_price                  DB ' | Price: $'
       total_price_msg                DB 'Line Total: $'
       exit_msg                       DB '4. Exit$'
       back_msg                       DB '. Go Back$'
       generate_bill_msg              DB '. Generate Bill$'
       main_menu_play_msg             DB '1. Play Discount Quiz$'
       main_menu_buy_msg              DB '2. Browse Products$'
       main_menu_bill_msg             DB '3. View Bill$'
       main_menu_exit_msg             DB '4. Exit$'
       bill_heading_msg               DB '========== BILL SUMMARY ==========$'
       bill_separator_msg             DB '----------------------------------$'
       bill_empty_msg                 DB 'No items have been added yet.$'
       bill_item_total_msg            DB ' | Item Total: $'
       bill_grand_total_msg           DB 'Grand Total: $'
       quiz_heading_msg               DB '========== DISCOUNT QUIZ ==========$'
       quiz_question_msg              DB 'Question: What is the capital of France?$'
       quiz_option_1_msg              DB '1. Berlin$'
       quiz_option_2_msg              DB '2. Paris$'
       quiz_option_3_msg              DB '3. Madrid$'
       quiz_option_4_msg              DB '4. Rome$'
       quiz_correct_option            DB '2'
       quiz_rule_msg                  DB 'Correct answer: +5% discount | Wrong answer: -5% discount$'
       quiz_answer_prompt_msg         DB 'Enter your choice (1-4): $'
       quiz_correct_msg               DB 'Correct! Your discount increased by 5%.$'
       quiz_wrong_msg                 DB 'Wrong! Your discount decreased by 5%.$'
       quiz_current_discount_msg      DB 'Current discount: $'
       quiz_percent_msg               DB '%$'
       quiz_return_msg                DB 'Returning to the main menu...$'
       quiz_participated              DB 0
       quiz_cannot_participate_msg    DB 'You already played the quiz.$'
       your_choice_msg                DB 'Your Choice: $'


       cat1                           DB 'SNACKS$'
       cat2                           DB 'VEGETABLES$'
       cat3                           DB 'FRUITES$'
       catPtrs                        DW OFFSET cat1, OFFSET cat2, OFFSET cat3
       num_of_category                DB 3
       ; Product name labels
       fruit1_name                    DB 'Mango$'
       fruit2_name                    DB 'Banana$'
       fruit3_name                    DB 'Lichi$'

       veg1_name                      DB 'Salad$'
       veg2_name                      DB 'Lemon$'
       veg3_name                      DB 'Broccoli$'

       snack1_name                    DB 'Dark Chocolate$'
       snack2_name                    DB 'Cold Drink$'
       snack3_name                    DB 'French Fry$'

       ; Product tables: pairs of WORDs: OFFSET name, price
       fruit_table                    DW OFFSET fruit1_name, 100, OFFSET fruit2_name, 200, OFFSET fruit3_name, 350
       veg_table                      DW OFFSET veg1_name, 250, OFFSET veg2_name, 200, OFFSET veg3_name, 350
       snack_table                    DW OFFSET snack1_name, 550, OFFSET snack2_name, 200, OFFSET snack3_name, 350

       ; Map categories to their product tables
       product_list                   DW OFFSET snack_table, OFFSET veg_table, OFFSET fruit_table
       num_of_products                DB 3

       total_spend                    DW 0
       bill_item_count                DW 0
       bill_product_names             DW MAX_BILL_ITEMS DUP(0)
       bill_quantities                DW MAX_BILL_ITEMS DUP(0)
       bill_line_totals               DW MAX_BILL_ITEMS DUP(0)
       selected_category              DB ?
       selected_product               DB ?
       selected_product_name          DW ?
       selected_product_price         DW ?
       quantity                       DW 0

       required_spending_for_discount DW 1000
       discount_threshold             DW 200
       discount_percentage            DB 10
       discount_msg                   DB '* Get 20% Discount for spending 1000 or More. Up to 200$'
       discounted                     DW 0
       discount_amount_msg            DB 'Discounted - $'
       final_spending_msg             DB 'Final Spending - $'




.code
next_line proc
                                        MOV  AH, 02h
                                        MOV  DL, 10
                                        INT  21h
                                        MOV  AH, 02h
                                        MOV  DL, 13
                                        INT  21h
                                        ret
next_line endp

print_string proc
                                        MOV  dx, si
                                        mov  ah, 09h
                                        int  21h
                                        ret
print_string endp

display_list proc                                                                         ; Required: list offset in the DI register && each element = 16 bit && CX= Number of elements
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
                                        push cx
                                        mov  bx, 10
                                        mov  cx, 0
       CONVERT_LOOP:
                                        mov  dx, 0
                                        div  bx
                                        push dx                                           ; push the reminder of the division to stack
                                        inc  cx                                           ; Counting the number of digits
                                        cmp  ax, 0
                                        jne  CONVERT_LOOP
       DISPLAY_LOOP:
                                        pop  dx                                           ; get the reminder from stack
                                        add  dl, '0'
                                        mov  ah, 02h
                                        int  21h
                                        loop DISPLAY_LOOP
                                        pop  cx
                                        ret
                                        endp display_number

main proc
       start_program:
                                        mov  AX, @data
                                        mov  ds, ax
                                        MOV  si, OFFSET intro
                                        call print_string
                                        call next_line
                                        mov  si, offset instructions
                                        call print_string
                                        call next_line
                                        mov  si, offset discount_msg
                                        call print_string
                                        call next_line
                                        call next_line
                                        mov  si, offset main_menu_play_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset main_menu_buy_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset main_menu_bill_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset main_menu_exit_msg
                                        call print_string
                                        call next_line
                                        jmp  main_menu_input
       display_cannot_participate_quiz:
                                        call next_line
                                        mov  si, offset quiz_cannot_participate_msg
                                        call print_string
                                        call next_line
                                        call next_line
                                        jmp  start_program


       main_menu_input:
                                        mov  si, offset your_choice_msg
                                        call print_string
                                        mov  ax,0
                                        mov  ah, 01h
                                        int  21h
                                        push ax
                                        call next_line
                                        pop  ax
                                        cmp  al, '1'
                                        jne  main_menu_check_buy
                                        push ax
                                        mov  al, [quiz_participated]
                                        cmp  al, 1
                                        pop  ax
                                        je   display_cannot_participate_quiz
                                        jmp  play_quiz_game
       main_menu_check_buy:
                                        cmp  al, '2'
                                        jne  main_menu_check_bill
                                        jmp  select_category_input
       main_menu_check_bill:
                                        cmp  al, '3'
                                        jne  main_menu_check_exit
                                        jmp  generate_bill
       main_menu_check_exit:
                                        cmp  al, '4'
                                        jne  main_menu_invalid
                                        jmp  exit_program
       main_menu_invalid:
                                        mov  si, OFFSET invalid_input
                                        call print_string
                                        call next_line
                                        jmp  start_program

       play_quiz_game:
                                        call next_line
                                        mov  si, offset quiz_heading_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset bill_separator_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset quiz_question_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset quiz_option_1_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset quiz_option_2_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset quiz_option_3_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset quiz_option_4_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset quiz_rule_msg
                                        call print_string
                                        call next_line
       quiz_answer_input:
                                        mov  si, offset quiz_answer_prompt_msg
                                        call print_string
                                        mov  ah, 01h
                                        int  21h
                                        push ax
                                        call next_line
                                        pop  ax
                                        cmp  al, '1'
                                        jb   quiz_answer_invalid
                                        cmp  al, '4'
                                        ja   quiz_answer_invalid
                                        cmp  al, [quiz_correct_option]
                                        je   quiz_answer_correct
                                        jmp  quiz_answer_wrong
       quiz_answer_invalid:
                                        mov  si, offset invalid_input
                                        call print_string
                                        call next_line
                                        jmp  quiz_answer_input
       quiz_answer_correct:
                                        mov  al, [discount_percentage]
                                        add  al, 5
                                        cmp  al, 100
                                        jbe  quiz_store_correct_discount
                                        mov  al, 100
       quiz_store_correct_discount:
                                        mov  [discount_percentage], al
                                        mov  si, offset quiz_correct_msg
                                        call print_string
                                        call next_line
                                        jmp  quiz_show_discount
       quiz_answer_wrong:
                                        mov  al, [discount_percentage]
                                        cmp  al, 5
                                        jae  quiz_reduce_discount
                                        mov  al, 0
                                        jmp  quiz_store_wrong_discount
       quiz_reduce_discount:
                                        sub  al, 5
       quiz_store_wrong_discount:
                                        mov  [discount_percentage], al
                                        mov  si, offset quiz_wrong_msg
                                        call print_string
                                        call next_line
       quiz_show_discount:
                                        mov  si, offset quiz_current_discount_msg
                                        call print_string
                                        mov  al, [discount_percentage]
                                        mov  ah, 0
                                        call display_number
                                        mov  si, offset quiz_percent_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset quiz_return_msg
                                        call print_string
                                        call next_line
                                        mov  quiz_participated, 1
                                        jmp  start_program

       select_category_input:
                                        mov  si, OFFSET select_category
                                        call print_string
                                        call next_line
                                        mov  ax, 0
                                        call display_number
                                        mov  si, offset back_msg
                                        call print_string
                                        call next_line
                                        mov  di, OFFSET catPtrs
                                        mov  ch,0
                                        mov  cl, [num_of_category]
                                        call display_list
                                        mov  al,[num_of_category]
                                        mov  ah,0
                                        inc  ax
                                        call display_number
                                        mov  si, offset generate_bill_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset your_choice_msg
                                        call print_string
                                        mov  cx,3
                                        mov  dl,0
                                        mov  al,0
                                        mov  bl,10
       l2:
                                        mov  ah, 01h
                                        int  21h
                                        cmp  al, 0Dh                                      ; if pressed enter, then exit input
                                        je   exit_input_category

                                        cmp  al, '0'
                                        jl   invalid_character_category
                                        jne  category_digit_check
                                        jmp  start_program
       category_digit_check:
                                        cmp  al, '9'
                                        jg   invalid_character_category
                                        mov  bh, al
                                        sub  bh, 30h
                                        mov  al, dl
                                        mul  bl
                                        add  al, bh
                                        mov  dl, al                                       ; input stored in dl as decimal value
                                        LOOP l2
                                        jmp  exit_input_category
       invalid_character_category:                                                  ; Restart input if the caracter is invalid
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
                                        inc  bl
                                        cmp  dl, bl
                                        jne  invalid_character_category
                                        jmp  generate_bill

       valid_category:
                                        mov  bl, dl
                                        mov  selected_category, bl
                                        call next_line
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
                                        call next_line
                                        mov  ch,0
                                        mov  cl, [num_of_products]
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
                                        pop  bx


                                        call next_line
                                        add  di, 2
                                        LOOP display_products
                                        mov  ah,0
                                        mov  al,[num_of_products]
                                        inc  al
                                        call display_number
                                        mov  si, offset back_msg
                                        call print_string
                                        call next_line

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
                                        cmp  al, 0Dh                                      ; if pressed enter, then exit input
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
                                        mov  dl, al                                       ; input stored in dl as decimal value
                                        LOOP l3
                                        jmp  exit_input_product
       invalid_character_product:                                                  ; Restart input if the caracter is invalid
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
                                        add  bl,1
                                        cmp  dl, bl
                                        jne  skip_go_back
                                        jmp  start_program
       skip_go_back:
                                        mov  si, OFFSET invalid_input
                                        call print_string
                                        call next_line
                                        jmp  select_product_input
       valid_product:
                                        mov  selected_product, dl
                                        mov  bl,2
                                        mov  al, [selected_category]
                                        dec  al
                                        mov  ah,0
                                        mul  bl
                                        mov  si, OFFSET product_list
                                        add  si, ax
                                        mov  si,[si]
                                        mov  bl,4
                                        mov  al, [selected_product]
                                        dec  al
                                        mov  ah,0
                                        mul  bl
                                        add  si, ax
                                        push si
                                        mov  si,[si]
                                        mov  selected_product_name, si
                                        call print_string
                                        mov  si, OFFSET product_price
                                        call print_string
                                        pop  si
                                        mov  ax, [si+2]
                                        mov  selected_product_price, ax
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
                                        cmp  al, 0Dh                                      ; if pressed enter, then exit input
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
                                        mov  dl, al                                       ; input stored in dl as decimal value
                                        LOOP l4
                                        jmp  exit_input_quantity
       invalid_character_quantity:                                                  ; Restart input if the caracter is invalid
                                        mov  si, OFFSET invalid_input
                                        call next_line
                                        call print_string
                                        call next_line
                                        jmp  select_quantity_input
       exit_input_quantity:
                                        cmp  dl, 0
                                        jne  quantity_continue
                                        jmp  start_program
       quantity_continue:
                                        mov  dh,0
                                        mov  ax, dx
                                        mov  quantity, ax
       calculate_total:
                                        call next_line
                                        mov  si, offset product_msg
                                        call print_string
                                        mov  si, [selected_product_name]
                                        call print_string

                                        mov  si, offset quantity_msg
                                        call print_string
                                        mov  ax, quantity
                                        call display_number
                                        call next_line

                                        mov  si, offset total_price_msg
                                        call print_string
                                        mov  ax, selected_product_price
                                        mov  bx, [quantity]
                                        mul  bx
                                        mov  dx, ax
                                        mov  bx, [bill_item_count]
                                        cmp  bx, MAX_BILL_ITEMS
                                        jae  skip_bill_store
                                        shl  bx, 1
                                        mov  si, [selected_product_name]
                                        mov  [bill_product_names+bx], si
                                        mov  ax, [quantity]
                                        mov  [bill_quantities+bx], ax
                                        mov  ax, dx
                                        mov  [bill_line_totals+bx], ax
                                        add  total_spend, ax
                                        inc  word ptr [bill_item_count]
       skip_bill_store:
                                        mov  ax, dx
                                        call display_number
                                        call next_line
                                        jmp  start_program

       generate_bill:

                                        mov  si, offset bill_heading_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset bill_separator_msg
                                        call print_string
                                        call next_line
                                        call next_line
                                        mov  ax, [bill_item_count]
                                        cmp  ax, 0
                                        jne  bill_items_available
                                        mov  si, offset bill_empty_msg
                                        call print_string
                                        call next_line
                                        jmp  start_program

       bill_items_available:
                                        call next_line
                                        mov  cx, [bill_item_count]
                                        mov  bx, 0
       bill_loop:
                                        push bx
                                        mov  ax, bx
                                        shr  ax, 1
                                        inc  ax
                                        call display_number
                                        pop  bx
                                        mov  ah, 02h
                                        mov  dx, '.'
                                        int  21h
                                        mov  ah, 02h
                                        mov  dx, ' '
                                        int  21h
                                        mov  si, offset product_msg
                                        call print_string
                                        mov  si, [bill_product_names+bx]
                                        call print_string
                                        mov  si, offset quantity_msg
                                        call print_string
                                        mov  ax, [bill_quantities+bx]
                                        push bx
                                        call display_number
                                        pop  bx
                                        mov  si, offset bill_item_total_msg
                                        call print_string
                                        mov  ax, [bill_line_totals+bx]
                                        push bx
                                        call display_number
                                        pop  bx
                                        call next_line
                                        add  bx, 2
                                        loop bill_loop
                                        mov  si, offset bill_separator_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset bill_grand_total_msg
                                        call print_string
                                        mov  ax, total_spend
                                        call display_number
                                        call next_line
                                        mov  bx, [required_spending_for_discount]
                                        mov  ax, total_spend
                                        cmp  ax, bx
                                        jge  calculate_discount
                                        jmp  exit_program
       calculate_discount:
                                        mov  ax, [total_spend]
                                        mov  bx, 0
                                        mov  bl, [discount_percentage]
                                        mul  bx
                                        mov  bx, 100
                                        div  bx
                                        mov  bx, [discount_threshold]
                                        cmp  ax, bx
                                        jbe  assign_discount_value
                                        mov  ax, [discount_threshold]
       assign_discount_value:
                                        mov  discounted, ax
                                        jmp  skip_max_discount
       skip_max_discount:
                                        mov  si, offset discount_amount_msg
                                        call print_string
                                        mov  ax, [discounted]
                                        call display_number
                                        call next_line
                                        mov  si, offset bill_separator_msg
                                        call print_string
                                        call next_line
                                        mov  si, offset final_spending_msg
                                        call print_string
                                        mov  ax, [total_spend]
                                        sub  ax, [discounted]
                                        call display_number
                                        call next_line



       exit_program:
                                        MOV  AH, 4Ch
                                        INT  21h
main endp
end main