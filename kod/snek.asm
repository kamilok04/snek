; DO ZROBIENIA
; -- wymyślić sprity i palety
; -- zrozumieć architekturę NES
; -- napić się z kimś

  .inesprg 1	; kod programu 1x 16KB
  .ineschr 1	; sprite 1x 8KB
  .inesmap 0	; bez banków
  .inesmir 1	; kopia tła
  
  ; ZMIENNE
  .rsset $0
pX  .rs 1
  ; -------
  
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
	
	ldx #$0
	
rysujObiekty:
	lda obiekty,x
	sta $200,x
	inx
	cpx #$10
	bne rysujObiekty
	
	lda #%10000000 	; włącz NMI, obiekty z tabeli 0
	sta $2000
	
	lda #%00010000	; włącz renderowanie obiektów
	sta $2001
	
	lda $020f
	sta pX
	
whileTrue:
	jmp whileTrue	; NIE tu jest gra
	
NMI:
	lda #$0
	sta $2003		; niski bajt  adresu tabeli obiektów
	lda #$2
	sta $4014		; wysoki bajt ==||==
					; adres tabeli: $0200
	lda pX			; obecna pozycja prawej strony węża
	tax
	clc
	adc #$8
	sta $20f
	sbc #$8
	sta $20b
	sbc #$8
	sta $207
	sbc #$8
	sta $203
	inx 
	stx pX
	
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

obiekty:
  .db $8,$10,$0,$8
  .db $8,$11,$0,$10
  .db $8,$11,%01000000,$18
  .db $8,$12,$0,$20

  .org $fffa		; IDT
  .dw NMI			; jeśli NMI
  .dw RESET			; jeśli reset
  .dw 0				; zewnętrzne przerwania trudne
  
  .bank 2
  .org $0
  .incbin "snek.chr"
	
