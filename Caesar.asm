.486
.model flat, stdcall
option casemap :none

 
        include C:\masm32\include\windows.inc 
        include C:\masm32\include\user32.inc
        include C:\masm32\include\kernel32.inc
        include C:\masm32\include\masm32.inc 
        includelib C:\masm32\lib\user32.lib
        includelib C:\masm32\lib\kernel32.lib
        includelib C:\masm32\lib\masm32.lib
.data
        aszGetMessage   db      0Dh, 0Ah, 'Enter the message: ', 0
        aszPressEnter   db      0Dh, 0Ah, 0Dh, 0Ah, "Press ENTER to exit", 0
        aszChooseCipDec db      0Dh, 0Ah, '1 - Cipher, 2 - Decipher', 0Dh, 0Ah, 0
        aszChooseLang   db      0Dh, 0Ah, '1 - Russian, 2 - English', 0Dh, 0Ah, 0
        aszErrorCipher  db      0Dh, 0Ah, 'Cipher error', 0
        aszErrodDec     db      0Dh, 0Ah, 'Decipher error', 0 
.data?
        hConsoleOutput  HANDLE  ?
        hConsoleInput   HANDLE  ?
        Language        dd      ?
        Mode            dd      ?
        Message         db      1024 dup(?)
        Buffer          db      1024 dup(?)
        mesLen          dd      ?
        BufLen          dd      ?
.code
 
;ввод целого числа

start: 
        call main
        
ReadUInt    proc lptrUInt:DWORD
 
        invoke  ReadConsole, hConsoleInput, ADDR Buffer,\
                LENGTHOF Buffer, ADDR BufLen, NULL
        lea     esi,    [Buffer]        ;удаление из буфера
        add     esi,    [BufLen]        ;символов перевода строки
        mov     [esi-2],word ptr 0
        invoke  atodw,  ADDR Buffer
        mov     esi,    [lptrUInt]
        mov     [esi],  eax
        ret
ReadUInt        endp



main    proc
        invoke   SetConsoleOutputCP,1251
        invoke   SetConsoleCP,1251 
        ; Получение описателей ввода и вывода консоли
        invoke  GetStdHandle,   STD_INPUT_HANDLE
        mov     hConsoleInput,  eax
 
        invoke  GetStdHandle,   STD_OUTPUT_HANDLE
        mov     hConsoleOutput, eax
 
        ;invoke  ClearScreen
        ;   Выбираем режим работы
        invoke  WriteConsole, hConsoleOutput, ADDR aszChooseCipDec,\
                LENGTHOF aszChooseCipDec - 1, ADDR BufLen, NULL
        invoke  ReadUInt, ADDR  Mode    
        ;   Выбираем язык с которым будем работать       
        invoke  WriteConsole, hConsoleOutput, ADDR aszChooseLang,\
                LENGTHOF aszChooseLang - 1, ADDR BufLen, NULL
        invoke  ReadUInt, ADDR  Language     
        
        invoke  WriteConsole, hConsoleOutput, ADDR aszGetMessage,\
                LENGTHOF aszGetMessage - 1, ADDR BufLen, NULL 
        ; Ввод изначальной строки
        invoke  ReadConsole, hConsoleInput, ADDR Message,\
                LENGTHOF Message, ADDR mesLen, NULL
        cmp Mode, 1
        je cipher
        cmp Mode, 2
        jne exit       
        call caesar_decipher
        jmp final
        
cipher: 
        call caesar_cipher                                                                                               
        ; Вывод результата
final:
        invoke  WriteConsole, hConsoleOutput, ADDR Message,\
                LENGTHOF Message - 1, ADDR mesLen, NULL
        
        
        invoke  WriteConsole, hConsoleOutput, ADDR aszPressEnter,\
                LENGTHOF aszPressEnter - 1, ADDR BufLen, NULL
        invoke  ReadConsole, hConsoleInput, ADDR Buffer,\
                LENGTHOF Buffer, ADDR BufLen, NULL
exit:
        invoke  ExitProcess, 0
main    endp


caesar_cipher proc
       cmp Language, 1
       je  RU
       cmp Language, 2
       jne ER
        
       lea esi, Message
next_en:
       mov al, [esi]
       cmp al, 0
       je  exit 
       cmp al,'z' 
       ja next_sym_en                             
       cmp al,'A'  
       jb next_sym_en     
       cmp al,'Z' 
       je mv_en   
       cmp al,'z' 
       je mv_en   
       cmp al,'Y' 
       je mv_en   
       cmp al,'y' 
       je mv_en   
       cmp al,'X' 
       je mv_en   
       cmp al,'x' 
       je mv_en
inc_en:
       add al, 3
       mov [esi], al
       inc esi
       jmp next_en       
             
next_sym_en:    
       inc esi
       jmp next_en
mv_en:
       sub al, 23
       mov [esi], al
       inc esi
       jmp next_en    
               
RU:
       lea esi, Message
next_ru:      
       mov al, [esi]
       cmp al, 0
       je  exit
       cmp al, 127
       jbe next_sym
       cmp al, 221;Э
       je mv_ru
       cmp al, 253
       je mv_ru
       cmp al, 222;Ю
       je mv_ru
       cmp al, 254
       je mv_ru
       cmp al, 223;Я
       je mv_ru
       cmp al, 255
       je mv_ru
       cmp al, 168;Ё
       je  chng1
       cmp al, 184
       je  chng2
       cmp al, 196;Д
       je  chng3
       cmp al, 197;Е
       je  chng3
       cmp al, 228;д
       je  chng3
       cmp al, 229;е
       je  chng3
       cmp al, 195;Г
       je  chng4
       cmp al, 227
       je  chng5
inc_ru:      
       add al, 3      
       mov [esi], al
       inc  esi
       jmp next_ru
       
next_sym:
       inc esi
       jmp next_ru       
mv_ru: 
       sub al, 29
       mov [esi], al
       inc esi
       jmp next_ru

chng1:
       mov al, 200       
       mov [esi], al
       inc esi
       jmp next_ru
chng2:
       mov al, 232
       mov [esi], al
       inc esi
       jmp next_ru       
chng3:
       add al,2
       mov [esi], al
       inc esi
       jmp next_ru
chng4:
       mov al, 168
       mov [esi], al
       inc esi
       jmp next_ru  
chng5:
       mov al, 184
       mov [esi], al
       inc esi
       jmp next_ru                                                                                                                                                                                        
exit:       
       ret
                             
ER:     

       invoke  WriteConsole, hConsoleOutput, ADDR aszErrorCipher,\
                LENGTHOF aszErrorCipher - 1, ADDR BufLen, NULL
       invoke  ExitProcess, 0 
caesar_cipher endp




caesar_decipher proc
       cmp Language, 1
       je  RU
       cmp Language, 2
       jne ER
        
       lea esi, Message
next_en:
       mov al, [esi]
       cmp al, 0
       je  exit 
       cmp al,'z' 
       ja next_sym_en                             
       cmp al,'A'  
       jb next_sym_en     
       CMP AL,'A' 
       je mv_en   
       cmp al,'a' 
       je mv_en   
       cmp al,'B' 
       je mv_en   
       cmp al,'b' 
       je mv_en   
       cmp al,'C' 
       je mv_en   
       cmp al,'c' 
       je mv_en
inc_en:
       sub al, 3
       mov [esi], al
       inc esi
       jmp next_en       
             
next_sym_en:    
       inc esi
       jmp next_en
mv_en:
       add al, 23
       mov [esi], al
       inc esi
       jmp next_en    
            

RU:
       lea esi, Message
next_ru:      
       mov al, [esi]
       cmp al, 0
       je  exit
       cmp al, 127
       jbe next_sym
       cmp al, 192;А
       je mv_ru
       cmp al, 224
       je mv_ru
       cmp al, 193;Б
       je mv_ru
       cmp al, 225
       je mv_ru
       cmp al, 194;В
       je mv_ru
       cmp al, 226
       je mv_ru
       cmp al, 200;И
       je  chng1
       cmp al, 232
       je  chng2
       cmp al, 198;Ж
       je  chng3
       cmp al, 199;З
       je  chng3
       cmp al, 230;ж
       je  chng3
       cmp al, 231;з
       je  chng3
       cmp al, 168;Ё
       je  chng4
       cmp al, 184
       je  chng5
inc_ru:      
       sub al, 3      
       mov [esi], al
       inc  esi
       jmp next_ru
       
next_sym:
       inc esi
       jmp next_ru       
mv_ru: 
       add al, 29
       mov [esi], al
       inc esi
       jmp next_ru

chng1:
       mov al, 168       
       mov [esi], al
       inc esi
       jmp next_ru
chng2:
       mov al, 184
       mov [esi], al
       inc esi
       jmp next_ru       
chng3:
       sub al,2
       mov [esi], al
       inc esi
       jmp next_ru
chng4:
       mov al, 195
       mov [esi], al
       inc esi
       jmp next_ru  
chng5:
       mov al, 227
       mov [esi], al
       inc esi
       jmp next_ru
                                                                                                                                         
exit:       
       ret
                             
ER:     

       invoke  WriteConsole, hConsoleOutput, ADDR aszErrorCipher,\
                LENGTHOF aszErrorCipher - 1, ADDR BufLen, NULL
       invoke  ExitProcess, 0 


caesar_decipher endp

end     start