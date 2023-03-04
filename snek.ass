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
	
whileTrue:
	jmp whileTrue	; NIE tu jest gra
	
NMI:
	rti
	
  .bank 1
  .org $fffa		; IDT
  .dw NMI			; jeśli NMI
  .dw RESET			; jeśli reset
  .dw 0				; zewnętrzne przerwania trudne
  
  .bank 2
  .org $0
  .incbin "snek.chr"
	
