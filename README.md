# Carcará BASIC

Improve speed of MSX BASIC by rewriting parts of the Math-Pack.

## Rationale

The MSX BASIC is somewhat slow and there are many reasons for that. 

* The first and foremost is that the Math-Pack was written in 8080 assembly. It could be made much faster by simply rewriting it to use properly the Z80 features. For example, subtracting two 16-bit integers is made by the routine at 0x3167. It *doesn't* use `SBC HL,DE` as it should, since this opcode was not available in 8080. Instead, it negates the second operand using a pair of 8-bit `SUB` and `SBC` instructions, and then add the negated result. The Math-Pack also doesn't use other Z80 features such as `IX` and `EXX` which could reduce register pressure.
* It was optimized for size, not speed. There are lots of places where clever usage of look-up tables could speed up calculations. For instance, integer multiplication is made by shift-and-add, when it could have been using smarter tricks such as tabulating squares and then using `a*b=((a+b)^2-(a-b)^2)/4`.
* It wasn't updated for newer machines. The MSX turboR, for instance, provides a hardware multiplicator in its R800 processor. This is not used in the Math-Pack. Recent hardware, such as GR8NET, could make it even faster.

The goal of this package is to solve these shortcomings, one step at a time.

## Features

The current version is a proof-of-concept implementation which improves integer multiplication using R800's `muluw` hardware multiplicator. The next versions are going to use GR8NET multiplication to improve single-precision floating point multiplication and division.

## Usage

Just `BLOAD "CARCARA.BIN",R` and use BASIC normally. Code is currently loaded at 0xC800 (this will change soon).

## Results

The following BASIC program presents a 10% speedup when using Carcará:

`TIME=0:FOR N%=-100 TO 100:FOR I%=1 TO 100:A%=I%*I%:NEXT I%,N%:PRINT TIME`

(Even though the multiplication itself is a lot faster than just 10%, the rest of the BASIC around it is still the same. If/when the Math-Pack parser gets rewritten, gains will be greater.)

## Why Carcará?

Carcará is a brazilian bird of prey who flies like a plane.

