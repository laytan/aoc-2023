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
	maxes := Colors{12, 13, 14}
    input := #load("input.txt")
	for line in bytes.split_after_iterator(&input, {'\n'}) {
		game_id: uint
		num:     u8
		color:   byte
		colors:  Colors
		
		outcomes := line[5:]
		outcomes_loop: for i := 0; i < len(outcomes); i += 1 {
			c := outcomes[i]
			switch c {
			case 'r':
				color = c
				i += 2

			case 'g':
				color = c
				i += 4

			case 'b':
				color = c
				i += 3

			case '0'..='9':
				num = num * 10 + (c - '0')

			case ' ': // no-op

			case ',':
				store := color_store(color)
				colors[store] += num

				if colors[store] > maxes[store] do break outcomes_loop

				num = 0

			case ';', '\n':
				store := color_store(color)
				colors[store] += num

				if colors[store] > maxes[store] do break outcomes_loop

				if c == '\n' {
					sum += game_id
					break outcomes_loop
				}

				colors, num = 0, 0

			case ':':
				game_id = uint(num)
				num = 0

			case:
				unreachable()
			}
		}
	}
    return
}

part_2 :: proc() -> (sum: uint) {
    input := #load("input.txt")
	for line in bytes.split_after_iterator(&input, {'\n'}) {
		num:    u8
		color:  byte
		colors: Colors

		outcomes := line[7:]
		outcomes_loop: for i := 0; i < len(outcomes); i += 1 {
			c := outcomes[i]
			switch c {
			case 'r':
				color = c
				i += 2

			case 'g':
				color = c
				i += 4

			case 'b':
				color = c
				i += 3

			case '0'..='9':
				num = num * 10 + (c - '0')

			case ' ': // no-op

			case ',', ';', '\n':
				store := color_store(color)
				colors[store] = max(colors[store], num)
				num = 0

			case ':':
				num = 0

			case:
				unreachable()
			}
		}

		sum += uint(colors.r) * uint(colors.g) * uint(colors.b)
	}
    return
}
