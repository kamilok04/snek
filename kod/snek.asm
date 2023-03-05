; DO ZROBIENIA
; -- wymyślić sprity i palety
; -- zrozumieć architekturę NES
; -- napić się z kimś

  .inesprg 1	; kod programu 1x 16KB
  .ineschr 1	; sprite 1x 8KB
  .inesmap 0	; bez banków
  .inesmir 1	; kopia tła
  
  .bank 0
  .org $C000	; pierwszy bank

RESET:
	sei			; przerwania nahui
	cld			; praca w trybie hex
	ldx #$40
	stx $4017	; wyłącz przerwania APU
	ldx #$ff
	txs			; zrób stos
	inx			; x == 0
	stx $2000	; wyłącz NMI
	stx $2001	; wyłącz renderowanie
	stx $4010	; wyłącz przerwania DMC

czekaj1:
	bit $2002
	bpl czekaj1

czyscmem:
	lda #$00
	sta $0000,x
	sta $0100,x
	sta $0200,x
	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700,x
	lda #$fe
	sta $0300,x
	inx
	bne czyscmem

czekaj2:
	bit $2002
	bpl czekaj2
	
wczytajPalety:
	lda $2002		; przygotuj PPU
	lda #$3f
	sta $2006		; wysoki bajt adresu
	lda #$00
	sta $2006		; niski bajt adresu
	ldx #$0
	
petlaPaletTel:
	lda paletyTla, x
	sta $2007		; zapisz kolor w PPU
	inx
	cpx #$10		; 16 kolorów, po 4 na paletę
	bne petlaPaletTel
	ldx #$0

petlaPaletObiektow:
	lda paletyObiektow, x
	sta $2007		; zapisz kolor w PPU
	inx
	cpx #$10		; 16 kolorów, po 4 na paletę
	bne petlaPaletObiektow
	
	lda #%10000000 	; włącz NMI, obiekty z tabeli 0
	sta $2000
	
	lda #%00010000	; włącz renderowanie obiektów
	sta $2001
	
whileTrue:
	jmp whileTrue	; NIE tu jest gra
	
NMI:
	lda #$0
	sta $2003		; niski bajt  adresu tabeli obiektów
	lda #$2
	sta $4014		; wysoki bajt ==||==
					; adres tabeli: $0200
					
rysuj:				; kod NMI tu wpada

	; WSPÓŁRZĘDNE Y
	
	lda #$8			; ósmy piksel z góry 
					; (pierwsze 8px jest specjalne)
	sta $200		; ogon
	sta $204		; ciało
	sta $208		; ciało2
	sta $20c		; łeb
	
	; KOORDYNATY TABELI OBIEKTÓW (snek.chr)
	
	lda #$10		; ogon
	sta $201
	lda #$11		; ciało
	sta $205
	sta $209
	lda #$12		; łeb
	sta $20d
	
	; SPECJALNE ŻYCZENIA (patrz cheatsheet.txt)
	
	lda #$0			; brak
	sta $202
	sta $206
	sta $20e
	lda #%01000000	; odbij w pionie
	sta $20a
	
	; WSPÓŁRZĘDNE X
	
	lda #$8			; ósmy piksel z lewej
					; (pierwsze 8px jest specjalne)
	sta $203		; ogon
	lda #$10		; szesnasty piksel z lewej itd..
	sta $207		; ciało
	lda #$18
	sta	$20b		; ciało2
	lda #$20
	sta $20f		; łeb
	
	; KONIEC RYSOWANIA (i NMI)
	
	rti
	
  .bank 1
  .org $e000
  
paletyTla:
  .db $22,$29,$1A,$0F
  .db $22,$36,$17,$0F	
  .db $22,$30,$21,$0F	
  .db $22,$27,$17,$0F	
  
paletyObiektow: 
  .db $a,$13,$20,$e		; zielony, fiolet, biały, czarny
  .db $22,$1A,$30,$27
  .db $22,$16,$30,$27
  .db $22,$0F,$36,$17 


  .org $fffa		; IDT
  .dw NMI			; jeśli NMI
  .dw RESET			; jeśli reset
  .dw 0				; zewnętrzne przerwania trudne
  
  .bank 2
  .org $0
  .incbin "snek.chr"
	
