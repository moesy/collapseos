; Sets Z is A is ' ' or '\t' (whitespace)
isWS:
	cp	' '
	ret	z
	cp	0x09
	ret

; Copy string from (HL) in (DE), that is, copy bytes until a null char is
; encountered. The null char is also copied.
; HL and DE point to the char right after the null char.
strcpyM:
	ld	a, (hl)
	ld	(de), a
	inc	hl
	inc	de
	or	a
	jr	nz, strcpyM
	ret

; Like strcpyM, but preserve HL and DE
strcpy:
	push	hl
	push	de
	call	strcpyM
	pop	de
	pop	hl
	ret

; Compares strings pointed to by HL and DE until one of them hits its null char.
; If equal, Z is set. If not equal, Z is reset.
strcmp:
	push	hl
	push	de

.loop:
	ld	a, (de)
	cp	(hl)
	jr	nz, .end	; not equal? break early. NZ is carried out
				; to the called
	or	a		; If our chars are null, stop the cmp
	jr	z, .end		; The positive result will be carried to the
	                        ; caller
	inc	hl
	inc	de
	jr	.loop

.end:
	pop	de
	pop	hl
	; Because we don't call anything else than CP that modify the Z flag,
	; our Z value will be that of the last cp (reset if we broke the loop
	; early, set otherwise)
	ret

; Returns length of string at (HL) in A.
; Doesn't include null termination.
strlen:
	push	bc
	push	hl
	ld	bc, 0
	xor	a	; look for null char
.loop:
	cpi
	jp	z, .found
	jr	.loop
.found:
	; How many char do we have? the (NEG BC)-1, which started at 0 and
	; decreased at each CPI call. In this routine, we stay in the 8-bit
	; realm, so C only.
	ld	a, c
	neg
	dec	a
	pop	hl
	pop	bc
	ret

; DE * BC -> DE (high) and HL (low)
multDEBC:
	ld	hl, 0
	ld	a, 0x10
.loop:
	add	hl, hl
	rl	e
	rl	d
	jr	nc, .noinc
	add	hl, bc
	jr	nc, .noinc
	inc	de
.noinc:
	dec a
	jr	nz, .loop
	ret
