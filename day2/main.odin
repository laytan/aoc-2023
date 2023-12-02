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

// 'green' is 5 bytes.
Color :: distinct [5]byte

// 'r' is 98 and b is 114 so we can subtract 98 and store in an array of 17.
Colors :: [17]u8

color_store :: proc {
	color_store_color,
	color_store_byte,
}

color_store_color :: #force_inline proc(color: Color) -> u8 {
	return color_store_byte(color[0])
}

// 'r' is 98 and b is 114 so we can subtract 98 and store in an array of 17.
color_store_byte :: #force_inline proc(b: byte) -> u8 {
	assert(b == 'r' || b == 'g' || b == 'b')
	return b - 98
}

part_1 :: proc() -> (sum: uint) {
	MAX_RED   :: 12
	MAX_GREEN :: 13
	MAX_BLUE  :: 14

	// 'r' is 98 and b is 114 so we can subtract 98 and store in an array of 17.
	maxes := [17]u8{('r' - 98) = MAX_RED, ('g' - 98) = MAX_GREEN, ('b' - 98) = MAX_BLUE}
	color_store :: #force_inline proc(color: Color) -> u8 {
		assert(color[0] == 'r' || color[0] == 'g' || color[0] == 'b')
		return color[0] - 98
	}

    input := #load("input.txt")
	for line in bytes.split_after_iterator(&input, {'\n'}) {
		game_id:   uint
		num:       u8
		color:     Color
		color_idx: uint
		colors:    [17]u8
		outcomes_loop: for i := 0; i < len(line); i += 1 {
			c := line[i]
			switch c {
			case ':':
				game_id = uint(num)
				color, color_idx, num = 0, 0, 0

			case '0'..='9':
				num = num * 10 + (c - '0')

			case ' ': // no-op
			case ',':
				store := color_store(color)
				colors[store] += num

				if colors[store] > maxes[store] do break outcomes_loop

				color, color_idx, num = 0, 0, 0

			case ';', '\n':
				store := color_store(color)
				colors[store] += num

				if colors[store] > maxes[store] do break outcomes_loop

				if c == '\n' {
					sum += game_id
					break outcomes_loop
				}

				colors, color, color_idx, num = 0, 0, 0, 0

			case:
				color[color_idx] = c
				color_idx += 1
			}
		}
	}
    return
}

part_2 :: proc() -> (sum: uint) {
    input := #load("input.txt")
	for line in bytes.split_after_iterator(&input, {'\n'}) {
		num:       u8
		color:     Color
		color_idx: uint
		colors:    [17]u8
		outcomes_loop: for i := 0; i < len(line); i += 1 {
			c := line[i]
			switch c {
			case ':':
				color, color_idx, num = 0, 0, 0

			case '0'..='9':
				num = num * 10 + (c - '0')

			case ' ': // no-op

			case ',', ';', '\n':
				store := color_store(color)
				colors[store] = max(colors[store], num)
				color, color_idx, num = 0, 0, 0

			case:
				color[color_idx] = c
				color_idx += 1
			}
		}
		sum += uint(colors['r' - 98]) * uint(colors['g' - 98]) * uint(colors['b' - 98])
	}
    return
}
