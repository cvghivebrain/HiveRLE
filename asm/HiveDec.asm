; ---------------------------------------------------------------------------
; Decompress HiveRLE archive to RAM

; input:
;	a1 = source address
;	a2 = destination address

;	uses d0.w, d1.b, a1, a2, a3, a4

; usage:
;	lea	(source).l,a1
;	lea	(destination).w,a2
;	bsr.w	HiveDec
; ---------------------------------------------------------------------------

HiveDec:
		lea	HiveDec_Copy_Table_End(pc),a3
		lea	HiveDec_Repeat_Table_End(pc),a4
		;moveq	#-1,d0					; d0 = $FFnn
		move.w	#$FF00,d0

HiveDec_Next:
		move.b	(a1)+,d0				; get n byte
		add.b	d0,d0					; multiply by 2, to both properly adjust to 68K opcode sizes...
		bcs.s	HiveDec_Repeat				; ...and put repeat flag into the carry flag, hence the byte size
		beq.s	HiveDec_End				; branch if 0 (including repeat flag)

; HiveDec_Copy:
		neg.b	d0					; turn n into -n
		jmp	(a3,d0.w)				; copy n bytes to destination
	
HiveDec_Repeat:
		move.b	(a1)+,d1				; get byte to write
		jmp	(a4,d0.w)				; write byte n times to destination
	
HiveDec_End:
		rts
	
HiveDec_Copy_Table:
		rept	127
		move.b	(a1)+,(a2)+				; copy byte from source to destination
		endr
	HiveDec_Copy_Table_End:
		bra.w	HiveDec_Next
	
HiveDec_Repeat_Table:
		rept	128
		move.b	d1,(a2)+				; write byte to destination
		endr
	HiveDec_Repeat_Table_End:
		bra.w	HiveDec_Next

; ---------------------------------------------------------------------------
; Decompress HiveRLE archive to VRAM

; input:
;	a1 = source address
;	a2 = RAM buffer address (make sure enough space is set aside)
;	d0.l = destination address (HiveDecVRAM)
;	d0.l = destination address preconverted to VDP instruction (HiveDecVRAM_Quick)

;	uses d0.l, d1.b, d2.l, a1, a2, a3, a4, a6

; usage:
;	lea	(source).l,a1
;	lea	(rambuffer).w,a2
;	move.l	#destination,d0
;	bsr.w	HiveDecVRAM
; ---------------------------------------------------------------------------

HiveDecVRAM:
		lsl.l	#2,d0					; move top 2 bits into hi word
		lsr.w	#2,d0					; return other bits to correct position
		add.w	#$4000,d0				; set VRAM write
		swap	d0					; swap hi/low words
		
HiveDecVRAM_Quick:
		lea	($C00000).l,a6				; VDP data port
		move.l	d0,4(a6)				; set VRAM destination
;		move.w	#$8F02,4(a6)				; set VDP increment to 2 bytes (if not already)
		move.l	a2,d2					; save start address for buffer
		bsr.w	HiveDec					; decompress to buffer
		
		move.w	a2,d0					; get end address for buffer
		sub.w	d2,d0					; d0 = size of data
		lsr.w	#5,d0					; divide by 32
		subq.w	#1,d0					; minus 1 for loop count
		movea.l	d2,a2					; back to start of buffer
		
HiveDecVRAM_Loop:
		move.l	(a2)+,(a6)				; copy from buffer to VRAM
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		dbf	d0,HiveDecVRAM_Loop			; repeat for all data
		rts
