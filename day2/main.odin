package main

import "core:bytes"
import "core:os"
import "core:strings"
import "core:strconv"

import aoc ".."

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 2, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 2, Part 2", part_2)
	}

	if len(os.args) < 2 || os.args[1] == "2_extra" {
		aoc.run("Day 2, Part 2 Short but Sweet", part_2_short_but_sweet)
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

// Easy to write version, using the Odin core packages a lot.
// Still 0 allocations but there is more iteration logic.
part_2_short_but_sweet :: proc() -> (sum: int) {
	s :: strings

	input := #load("input.txt", string)
	for line in s.split_lines_iterator(&input) {
		maxes: [3]int
		game := line[s.index_byte(line, ':')+2:]
		for roll in s.split_iterator(&game, "; ") {
			roll := roll
			for dice in s.split_iterator(&roll, ", ") {
				_num, _, color := s.partition(dice, " ")
				num := strconv.atoi(_num)

				mi := color[0] % 3
				maxes[mi] = max(num, maxes[mi])
			}
		}

		sum += maxes.r * maxes.g * maxes.b
	}
	return
}

// This version does everything in one pass, even skipping a majority of the input by manually
// controlling the `i` variable.
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
