
asect 0xe3
	IOReg: # Gives the address 0xf3 the symbolic name IOReg

asect 0xf0
	stack: # Gives the address 0xf0 the symbolic name stack
asect 0xF8
	br 0xAD 
asect 0x00
start:
ldi r0, 0xB0 # adr of storing Head
ldi r1, 0x80
st r0,r1

inc r0       # adr of storing Tail = B1
ldi r1, 0x82
st r0,r1

inc r0       # tailVal = B2
ldi r1, 0b00010000   # будем инвертить и сдвигать как голову
st r0,r1

inc r0       # tailStr = B3
ldi r1, 0xd0
st r0,r1

inc r0       # did we eat smth? = B4
st r0,r1

inc r0		# B5
ldi r1,0x97  # 80 - 97 = кольцевой буфер
st r0,r1 # для кольцевого буфера




ldi r2, 0b00000100 # headVal
ldi r3, 0xd0       # headStr
ldi r0, IOReg      # IO register
clr r1             # rotation = 00

push r1
readkbd:
###############
pop r0
ldi r0, IOReg #
push r1
###############
do
# update Head
pop r1
if
tst r1
is eq
	then
		# >
		shr r2
		jsr forhead		
	else
		ldi r0,1
		if
		cmp r1,r0
		is eq
			then
				# <
				shla r2
				jsr forhead	
			else
				ldi r0,2
				if
				cmp r1,r0
				is eq
					then
						# ^
						dec r3
						jsr forhead
					else
						# \/
						inc r3
						jsr forhead
				fi
		fi
fi





ldi r0,IOReg
# update Tail
push r3
push r0
push r2
push r1

ldi r0,0b00001111
and r0,r3
ldi r0,7
if
	cmp r3,r0		# верхние нижние стены
	is hi
	jsr ban
fi



ldi r1,0xB4  # если в B4 не ноль, обновим значения tailVal/tailStr
ld r1,r1
if
tst r1
is nz



ldi r2, 0xB2 # tailVal
ld r2,r2

ldi r3, 0xB3 # tailStr
ld r3,r3

ldi r1, 0xB1 # направление хвоста
ld r1,r1
ld r1,r1
if
tst r1
is eq
	then
		# >
		jsr fortail
		ldi r0,0xB2
		shr r2
		st r0,r2	
	else
		
		ldi r0,1
		if
		cmp r1,r0
		is eq
			then
				# <
				jsr fortail
				ldi r0,0xB2
				shla r2
				st r0,r2
			else
				ldi r0,2
				if
				cmp r1,r0
				is eq
					then
						# ^
						jsr fortail
						ldi r0,0xB3
						dec r3
						st r0,r3
					else
						# \/
						jsr fortail
						ldi r0,0xB3
						inc r3
						st r0,r3
						
						
				fi
		fi
fi
fi 

#				Переписываем направления
ldi r1,0xB0     # обновляем Head
ld r1,r1 		# теперь в r1 - текущий адрес головы (одна из C0-C5)



pop r0
st r1,r0             # пишем в голову новое направление
push r0

ldi r2,0xB0			 # обновляем новый адрес головы
jsr cycle



inc r2  

ldi r1,0xB4  # если в B4 не ноль, обновим значения tailVal/tailStr
ld r1,r1
if
tst r1
is nz
ld r2,r1 # r1 = текущий адрес хвоста (цэшки)
jsr cycle			 # обновление адреса хвоста
else
ldi r0,0xA0 # отмечаем что еда съедена
clr r1
st r0,r1

ldi r1,0xB4  # иначе скажем что мы обработали эту еду, сделав ненулевой B4
st r1,r1
fi       




# смена банок
br 0xF8

   


pop r1
pop r2
pop r0
pop r3
#################################################
push r1
ld r0,r1
tst r1
until pl
# шаманство чтобы обновить направление
st r0,r1
pop r0
move r1,r0
push r0  # тут текущее направление
################


br readkbd # go back to the start of the keyboard read loop

cycle:
dec r1	
ldi r3,0x80
if
cmp r3,r1
is hi
	then
		ldi r0, 0xB5 # реализация кольцевого буфера
		ld r0,r1
		
fi
st r2,r1
rts

forhead:
push r0
push r1
push r2
ld r3,r0

move r0,r1 # r1 - tmp буфер для проверки, поменяла ли сместившаяся голова строчку

or r2,r0   # r2 - headVal со смещением если было
st r3,r0   # r3 - headStr со смещением если было

xor r0,r1  # проверяем отличия буфера r1 от результата r0
ldi r0,0xB4
st r0,r1 
if
tst r1
is eq
ldi r0,0xA1
ldi r1,0xA2
ld r0,r0
ld r1,r1
if
cmp r0,r2
	is eq
		if
		cmp r1,r3
			is ne
			jsr ban
			fi
	else
		jsr ban
fi
fi


pop r2
pop r1
pop r0
rts

fortail: # r3 = tailStr, r2 = tailVal без смещения
ld r3,r0 # r0 = value of tailStr
not r2
and r2,r0
st r3,r0
not r2
rts      # почистили хвост
ban:
ldi r0,0xB6
ldi r1,0xFF
st r0,r1
rts
end