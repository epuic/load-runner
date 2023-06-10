.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 1079
area_height EQU 599
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
lungime_simbol EQU 40
state_height EQU 13
state_width EQU 17




include digits.inc
include letters.inc
include forme.inc
include starematrice.inc

buton_x_st EQU 760
buton_y_st EQU 240
buton_size_st EQU 80

buton_x_dr EQU 920
buton_y_dr EQU 240
buton_size_dr EQU 80

buton_x_sus EQU 840
buton_y_sus EQU 160
buton_size_sus EQU 80

buton_x_jos EQU 840
buton_y_jos EQU 320
buton_size_jos EQU 80

poz_player_x DD 4
poz_player_y DD 11

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_simboluri proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	lea esi, forme

desenare_block:
	mov ebx, lungime_simbol
	mul ebx
	mov ebx, lungime_simbol
	mul ebx
	add esi, eax
	mov ecx, lungime_simbol
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, lungime_simbol
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, lungime_simbol
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je pixel_caramida_margini
	cmp byte ptr [esi], 1
	je pixel_caramida_umplutura
	cmp byte ptr [esi], 2
	je pixel_fundal
	cmp byte ptr [esi], 3
	je pixel_scara
	cmp byte ptr [esi], 4
	je pixel_fundal
	cmp byte ptr [esi], 5
	je pixel_contur_caracter
pixel_fundal:
	mov dword ptr [edi], 000B2FAh
	jmp urmatorul_pixel
pixel_caramida_margini:
	mov dword ptr [edi], 0C54D04h
	jmp urmatorul_pixel
pixel_caramida_umplutura:
	mov dword ptr [edi], 0C0BFBFh
	jmp urmatorul_pixel
pixel_scara:
	mov dword ptr [edi], 03D2807h
	jmp urmatorul_pixel
pixel_contur_caracter:
	mov dword ptr [edi], 0
	jmp urmatorul_pixel
urmatorul_pixel:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_simboluri endp

make_forma_macro macro symbol, drawArea, x, y
    push y
    push x
    push drawArea
    push symbol
    call make_simboluri
    add esp, 16
endm



stare_matrice proc
	push ebp
	mov ebp, esp
	pusha
	lea esi, starematrice

desenare_block:
	mov ebx, state_width
	mul ebx
	mov ebx, state_height
	mul ebx
	add esi, eax
	mov ecx, state_height
	mov EAX,0
	mov edx,79
bucla_simbol_linii:
	push ecx
	mov ecx, state_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je caramida
	cmp byte ptr [esi], 1
	je scara
	cmp byte ptr [esi], 2
	je fundal
	cmp byte ptr [esi], 3
	je caracter
caramida:
	make_forma_macro 0,area,EAX,edx
	jmp urmatorul_pixel
scara:
	make_forma_macro 1,area,EAX,edx
	jmp urmatorul_pixel
fundal:
	make_forma_macro 2,area,EAX,edx
	jmp urmatorul_pixel
caracter:
	make_forma_macro 3,area,EAX,edx
	jmp urmatorul_pixel
urmatorul_pixel:
	inc esi
	add edi, 4
	add EAX,40
	loop bucla_simbol_coloane
	mov EAX,0
	add edx,40
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
stare_matrice endp

exemplumacro macro
    call stare_matrice
endm

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm





; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y

linie_orizontala macro x, y, len, color
local bucla_linie
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2    ;eax=(y*area_width+x)*4
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_linie
endm

linie_verticala macro x, y, len, color
local bucla_linie
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2   ;eax=(y*area_width+x)*4
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr[eax], color
	add eax, area_width * 4
	loop bucla_linie
endm

ia_pozitia_jucatorului macro
	lea ebp, starematrice
	mov eax, poz_player_y
	mov ebx, state_width
	mul ebx
	add eax, poz_player_x
	add eax, ebp
endm

draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	mov eax,[ebp+arg2]
	cmp eax, buton_x_dr
	jl try_buton_st
	cmp eax, buton_x_dr + buton_size_dr
	jg try_buton_st
	mov eax,[ebp+arg3]
	cmp eax, buton_y_dr
	jl try_buton_st
	cmp eax, buton_y_dr + buton_size_dr
	jg try_buton_st
	
	ia_pozitia_jucatorului
	mov bh, [eax+1]
	mov bl, [eax]
	
	cmp byte ptr[eax+1], 0
	je interzis
	cmp byte ptr[eax+1], 2
	je verif
  verif:
	cmp byte ptr[eax+1+state_width], 2
	je interzis
	jmp continue
  continue:
	mov [eax],bh
	mov [eax+1],bl
	add poz_player_x, 1
	
	jmp afisare_litere

try_buton_st:
	mov eax,[ebp+arg2]
	cmp eax, buton_x_st
	jl try_buton_sus
	cmp eax, buton_x_st + buton_size_st
	jg try_buton_sus
	mov eax,[ebp+arg3]
	cmp eax, buton_y_st
	jl try_buton_sus
	cmp eax, buton_y_st + buton_size_st
	jg try_buton_sus
	
	ia_pozitia_jucatorului
	mov bh, [eax-1]
	mov bl, [eax]
	
	cmp byte ptr[eax-1], 0
	je interzis
	cmp byte ptr[eax-1], 2
	je verificare
  verificare:
	cmp byte ptr[eax-1+state_width], 2
	je interzis
	jmp continuare
  continuare:
	mov [eax],bh
	mov [eax-1],bl
	sub poz_player_x, 1
	
	jmp afisare_litere

try_buton_sus:
	mov eax,[ebp+arg2]
	cmp eax, buton_x_sus
	jl try_buton_jos
	cmp eax, buton_x_sus + buton_size_sus
	jg try_buton_jos
	mov eax,[ebp+arg3]
	cmp eax, buton_y_sus
	jl try_buton_jos
	cmp eax, buton_y_sus + buton_size_sus
	jg try_buton_jos
	
	ia_pozitia_jucatorului
	mov bh, [eax-state_width]
	mov bl, [eax]
	
	cmp byte ptr[eax-state_width], 0
	je interzis
	cmp byte ptr[eax-state_width], 2
	je interzis
	mov [eax],bh
	mov [eax-state_width],bl
	sub poz_player_y, 1
	
	jmp afisare_litere
	
try_buton_jos:
	mov eax,[ebp+arg2]
	cmp eax, buton_x_jos
	jl click_in_afara_butonului
	cmp eax, buton_x_jos + buton_size_jos
	jg click_in_afara_butonului
	mov eax,[ebp+arg3]
	cmp eax, buton_y_jos
	jl click_in_afara_butonului
	cmp eax, buton_y_jos + buton_size_jos
	jg click_in_afara_butonului
	
	ia_pozitia_jucatorului
	mov bh, [eax+state_width]
	mov bl, [eax]
	
	cmp byte ptr[eax+state_width], 0
	je interzis
	cmp byte ptr[eax+state_width], 2
	je interzis
	
	mov [eax],bh
	mov [eax+state_width],bl
	add poz_player_y, 1
	
	jmp afisare_litere
	
click_in_afara_butonului:
	jmp afisare_litere
	
interzis:
	jmp afisare_litere
	
evt_timer:
	
	inc counter
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	make_text_macro 'P', area, 190, 30
	make_text_macro 'R', area, 200, 30
	make_text_macro 'O', area, 210, 30
	make_text_macro 'I', area, 220, 30
	make_text_macro 'E', area, 230, 30
	make_text_macro 'C', area, 240, 30
	make_text_macro 'T', area, 250, 30
	
	make_text_macro 'L', area, 270, 30
	make_text_macro 'A', area, 280, 30
	
	make_text_macro 'A', area, 300, 30
	make_text_macro 'S', area, 310, 30
	make_text_macro 'A', area, 320, 30
	make_text_macro 'M', area, 330, 30
	make_text_macro 'B', area, 340, 30
	make_text_macro 'L', area, 350, 30
	make_text_macro 'A', area, 360, 30
	make_text_macro 'R', area, 370, 30
	make_text_macro 'E', area, 380, 30
	
	exemplumacro

	linie_orizontala buton_x_st, buton_y_st, buton_size_st, 0
	linie_orizontala buton_x_st, buton_y_st + buton_size_st, buton_size_st, 0
	linie_verticala buton_x_st, buton_y_st, buton_size_st, 0
	linie_verticala buton_x_st + buton_size_st, buton_y_st, buton_size_st, 0
	
	linie_orizontala buton_x_dr, buton_y_dr, buton_size_dr, 0
	linie_orizontala buton_x_dr, buton_y_dr + buton_size_dr, buton_size_dr, 0
	linie_verticala buton_x_dr, buton_y_dr, buton_size_dr, 0
	linie_verticala buton_x_dr + buton_size_dr, buton_y_dr, buton_size_dr, 0
	
	linie_orizontala buton_x_sus, buton_y_sus, buton_size_sus, 0
	linie_orizontala buton_x_sus, buton_y_sus + buton_size_sus, buton_size_sus, 0
	linie_verticala buton_x_sus, buton_y_sus, buton_size_sus, 0
	linie_verticala buton_x_sus + buton_size_sus, buton_y_sus, buton_size_sus, 0
	
	linie_orizontala buton_x_jos, buton_y_jos, buton_size_jos, 0
	linie_orizontala buton_x_jos, buton_y_jos + buton_size_jos, buton_size_jos, 0
	linie_verticala buton_x_jos, buton_y_jos, buton_size_jos, 0
	linie_verticala buton_x_jos + buton_size_jos, buton_y_jos, buton_size_jos, 0
	

	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
