start NOOP ; starting the program
  LDR R0 #32768
  SSVOP R0
  LDR R1 #0 ; Setting all the output signals statuses to zero
  STR R1 $1 ; Storing the statuses of all the output signals in to the dedicated mem space for outputsignals
  LDR R0 #0 ; loading zeros
  STR R0 $2 ; Datalocs init
  LDR R1 #0
  STR R1 $3 ; Setting internal signals to zero
  LDR R1 #0 ; storing zero to pre-insigs
  STR R1 $4
  LDR R1 #0 ; storing zero to pre-osigs
  STR R1 $5
  LDR R1 #0 ; storing zero to pre-dsigs
  STR R1 $6 ; Storing them into the mem
  LDR R0 #0
  STR R0 $7 ; Program Counter : storing zeros in the addresses
  LDR R0 #0
  STR R0 $8 ; Terminate Node stored 0
  LDR R0 #case16 
  STR R0 $9 ; Switch Node

BEGIN0 NOOP ; loading the num which have to be init
  LDR R7 #0
  LDR R8 #0 ; previous clock-domain num
SEOT19 CLFZ
  LDR R0 #0 ; clearing
  LDR R1 #0 ; clearing
  LDR R11 #0 ; clearing (This register will always contain zeroes !)
LERR19  LER R0 ; loading the EREADY bit which is set from ENV
  PRESENT R0 LERR19
FER19 SEOT ; This is basically the SEOT tick
  CER ; clear the EREADY bit
  LDR R0 $0001 ; loading the output signals
  AND R1 R0 #$7fff ; clearing output sig fields
  STR R1 $1
  AND R0 R0 #$8000
  SSOP R0 ; throwing output signals to env
; Updating pre sigs - Delayed semantics
  STR R0 $5 ; store it to pre-osig of this CD
; Setting the declared signals and terminate node to 0
  STR R11 $3 ; DSigs
  STR R11 $7 ; PC
  LSIP R0 ; getting input signals from SIP
  AND R0 R0 #$8000
  LDR R1 $0000
  AND R2 R1 #$8000
  STR R2 $4 ; storing insigs to delayed
  AND R1 R1 #$7fff
  OR R0 R0 R1
  STR R0 $0000 ; storing SIP signals in mem
  STR R11 $2 ; thread is now locked
  LDR R0 #$8000
  DCALLNB R0 ; casenumber 0
HOUSEKEEPING0 LDR R0 $2
  PRESENT R0 HOUSEKEEPING0 ; House-Keeping code needs to be completed before proceeding
  CEOT ; now start processing
RUN0 NOOP ; the locks need to be inside the memory since if they are here then I am just eating up logic
  STR R11 $8 ; storing zero to this CD's Terminate Node
  LDR R7 #0
  LDR R8 #0 ; previous clock-domain num
  CLFZ
  SUB R12 #0 ; if the previous DCALL is not finished
  SZ NORMALEXECUTION0
  JMP R12 ; Data-call still pending, jump to this address
NORMALEXECUTION0 NOOP
  LDR R0 $9
  JMP R0 ; SwitchNode unconditional jump
case15 NOOP ; Switch Child branch
  LDR R0 #case15
  STR R0 $9 ; EnterNode storing statecode : 0
  JMP END0 ; Jumping to END
  JMP ENDS130
case16 NOOP ; Switch Child branch
  LDR R0 #case17
  STR R0 $9 ; EnterNode storing statecode : 2
  LDR R0 #case17
  STR R0 $9 ; EnterNode storing statecode : 2
  STR R11 $2 ; thread is now locked
  LDR R0 #32769 ; loading case number
  DCALLNB R0 ; casenumber 1
  STRPC $7
TEN22 LDR R0 $2
  PRESENT R0 EL23 ; checking whether data-call has been completed
  JMP END0 ; Jumping to END
  JMP OVERELSE24
EL23 CLFZ
  JMP END0 ; Jumping to END without storing PC (inf)
OVERELSE24 NOOP
  JMP ENDS131
case17 NOOP ; Switch Child branch
  LDR R0 $4 ; Loaded the input signals into register
  AND R0 R0 #32768 ; Got the required signal in R0
  PRESENT R0 else26 ; checking if the signal is present increment
  STR R11 $2 ; thread is now locked
  LDR R0 #32770 ; loading case number
  DCALLNB R0 ; casenumber 2
  STRPC $7
TEN27 LDR R0 $2
  PRESENT R0 EL28 ; checking whether data-call has been completed
  JMP END0 ; Jumping to END
  JMP OVERELSE29
EL28 CLFZ
  JMP END0 ; Jumping to END without storing PC (inf)
OVERELSE29 NOOP
  JMP OVERELSE30
else26 NOOP
  JMP END0 ; Jumping to END
OVERELSE30 NOOP
  JMP ENDS132
ENDS130 NOOP
ENDS131 NOOP
ENDS132 NOOP
END0 LDR R12 $7 ; next cd's PC
  CLFZ
  SUB R12 #0
  SZ ENDPCCHECK00
  JMP RUN0
ENDPCCHECK00 JMP BEGIN0
  ENDPROG
