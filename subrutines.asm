asect 0x00
foodGeneration:


# A0 - foodExist
# A1 - foodVal
# A2 - foodStr
ldi r0,0xA0
ld r0,r1
if
tst r1
is eq
# если в A0 лежит ноль, надо сгенерить еду
ldi r1,0xB3 
ld r1,r1 # tailStr
ldi r2, 0xB2
ld r2,r2 #tailVal
rol r2
rol r2
rol r2
rol r2

ld r1,r3 # r3 - текущее состояние строки в которой хвост
move r3,r0 # r0 - tmp для проверки изменений в строке
or r2,r3
xor r3,r0
if
tst r0
is nz # строка поменялась, можем записать
st r1,r3
ldi r0,0xA0
st r0,r1
inc r0
st r0,r2
inc r0
st r0,r1
fi
else
fi

br 0xF8 # тут можно сделать переходы по условиям
		 # в обеих банках

asect 0xF8
br foodGeneration
end