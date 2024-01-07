    .var music = LoadSid("Danger_zone.sid")
    BasicUpstart2(main)
    
main:
    lda #music.startSong-1
    jsr music.init
loop:
    inc $d020
    inc $d021
    lda $f0
    cmp $d012
    bne loop
    jsr music.play
    jmp loop

 *=music.location "Music"
.fill music.size, music.getData(i)