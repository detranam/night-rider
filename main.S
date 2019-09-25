#Main.S
#Matthew DeTrana
#'slides' lights left
#to right, then right
#to left

#defines our syntax
.syntax unified
#defines our CPU
.cpu cortex-m4
#defines our architecture
.thumb
#makes the code readonly
.section .text

#Lights are on PB5-PB15, PB11 is unused

#constants
	#GPIO B toggle controls
	.equ rcc_base, 0x40023800
	.equ rcc_ahb1enr, 0x30
	.equ rcc_gpiob, 1<<1

	#GPIO B Controls
	.equ gpio_b_base, 0x40020400
	.equ gpio_moder, 0x00
	.equ gpio_odr, 0x14

.global main

main:

	#Turn on GPIO B
	ldr r1, =rcc_base

	ldr r2, [r1, #rcc_ahb1enr]
	orr r2, r2, #rcc_gpiob
	str r2, [r1, #rcc_ahb1enr]

	#Turn PB5-PB10, PB12-PB15 to Output
	ldr r1, =gpio_b_base
	ldr r2, [r1, #gpio_moder]

	movw r3, #0x5400
	movt r3, #0x5515
	orr r2, r2, r3

	movw r3, #0xA800
	movt r3, #0xAA2A
	bic r2, r2, r3

	str r2, [r1, #gpio_moder]
	#Turn on first light
	ldr r2, [r1, gpio_odr]
	orr r2, r2, #0x0020
	str r2, [r1, gpio_odr]

right_to_left:
	ldr r2, [r1, gpio_odr]
	lsl r2, r2, #1
	str r2, [r1, gpio_odr]
	cmp r2, #0x0800
	beq skipleft
cont_rtl:
	bl delay
	cmp r2, 0x8000
	bne right_to_left
	beq left_to_right
	
left_to_right:
	ldr r2, [r1, gpio_odr]
	lsr r2, r2, #1
	str r2, [r1, gpio_odr]
	cmp r2, #0x0800
	beq skipright
cont_ltr:
	bl delay
	cmp r2, 0x0020
	bne left_to_right
	beq right_to_left

skipleft:
	ldr r2, [r1, gpio_odr]
	lsl r2, r2, #1
	str r2, [r1, gpio_odr]
	b cont_rtl

skipright:
	ldr r2, [r1, gpio_odr]
	lsr r2, r2, #1
	str r2, [r1, gpio_odr]
	b cont_ltr

end:
	b end

delay:
	movw r3, #0x0000
	movt r3, #0x0020
1:
	subs r3, r3, #1
	bne 1b
	bx lr
