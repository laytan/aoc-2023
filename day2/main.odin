package main

import "core:bytes"
import "core:os"

import aoc ".."

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 2, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 2, Part 2", part_2)
	}
}

#assert('r' % 3 == 0)
#assert('g' % 3 == 1)
#assert('b' % 3 == 2)
Colors :: [3]u8

color_store :: #force_inline proc(b: byte) -> u8 {
	return b % 3
}

part_1 :: proc() -> (sum: uint) {
	input := #load("input.txt")
	maxes := Colors{12, 13, 14}

	game_id: uint
	num:     u8
	color:   byte
	colors:  Colors
		
	for i := 5; i < len(input); {
		c := input[i]
		switch c {
		case 'r':
			color = c
			i += 3

		case 'g':
			color = c
			i += 5

		case 'b':
			color = c
			i += 4

		case '0'..='9':
			num = num * 10 + (c - '0')
			i += 1

		case ',', ';', '\n':
			store := color_store(color)
			colors[store] += num

			if colors[store] > maxes[store] {
				// Find next game starting point.
				i = bytes.index_byte(input[i:], '\n') + i + 6
				num, colors = 0, 0
				break
			}

			switch c {
			case '\n':
				sum += game_id
				i += 4
				fallthrough
			case ';':
				colors = 0
			}

			num = 0
			i += 2

		case ':':
			game_id = uint(num)
			num = 0
			i += 2

		case ' ':
			i += 1

		case:
			unreachable()
		}
	}
    return
}

part_2 :: proc() -> (sum: uint) {
	input := #load("input.txt")

	num:    u8
	color:  byte
	colors: Colors
		
	for i := 6; i < len(input); {
		c := input[i]
		switch c {
		case 'r':
			color = c
			i += 3

		case 'g':
			color = c
			i += 5

		case 'b':
			color = c
			i += 4

		case '0'..='9':
			num = num * 10 + (c - '0')
			i += 1

		case ',', ';':
			store := color_store(color)
			colors[store] = max(colors[store], num)
			num = 0
			i += 2

		case '\n':
			store := color_store(color)
			colors[store] = max(colors[store], num)

			sum += uint(colors.r) * uint(colors.g) * uint(colors.b)

			i += 7
			colors, num = 0, 0

		case ':':
			num = 0
			i += 2

		case ' ':
			i += 1

		case:
			unreachable()
		}
	}
    return
}
