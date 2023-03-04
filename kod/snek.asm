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
petlaPalet:
	lda paletyTla, x
	sta $2007		; zapisz kolor w PPU
	inx
	cpx #$10		; 16 kolorów, po 4 na paletę
	bne petlaPalet
	
whileTrue:
	jmp whileTrue	; NIE tu jest gra
	
NMI:
	rti
	
  .bank 1
  .org $e000
  
paletyTla:
  .db $22,$29,$1A,$0F
  .db $22,$36,$17,$0F	
  .db $22,$30,$21,$0F	
  .db $22,$27,$17,$0F	
  
paletyObiektow: 
  .db $22,$16,$27,$18
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
	
