package main

import "core:os"
import "core:strings"

import aoc ".."

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 1, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 1, Part 2", part_2)
	}
}

part_1 :: proc() -> int {
	digit :: #force_inline proc(v: byte) -> u8 {
		switch v {
		case '1'..='9': return v - '0'
		case:           return 0
		}
	}

	input: string = #load("input.txt")
	sum: int
	for line in strings.split_lines_iterator(&input) {
		left, right: u8
		left_idx, right_idx := 0, len(line)-1
		for left == 0 || right == 0 {
			if left == 0 {
				left = digit(line[left_idx])
				left_idx += 1
			}
			if right == 0 {
				right = digit(line[right_idx])
				right_idx -= 1
			}
		}

		sum += int(left) * 10 + int(right)
	}

	return sum
}

part_2 :: proc() -> uint {
	digit :: #force_inline proc(l: string, i: int) -> uint {
		pre :: strings.has_prefix
		v, rest := l[i], l[i+1:]
		switch v {
		case '1'..='9': return uint(v - '0')
		case 'o':      	return 1 if pre(rest, "ne")   else 0
		case 't':       return 2 if pre(rest, "wo")   else 3 if pre(rest, "hree") else 0
		case 'f':       return 4 if pre(rest, "our")  else 5 if pre(rest, "ive")  else 0
		case 's':       return 6 if pre(rest, "ix")   else 7 if pre(rest, "even") else 0
		case 'e':       return 8 if pre(rest, "ight") else 0
		case 'n':       return 9 if pre(rest, "ine")  else 0
		case:           return 0
		}
	}

	input: string = #load("input.txt")
	sum: uint
	for line in strings.split_lines_iterator(&input) {
		left, right: uint
		left_idx, right_idx := 0, len(line)-1
		for left == 0 || right == 0 {
			if left == 0 {
				left = digit(line, left_idx)
				left_idx += 1
			}
			if right == 0 {
				right = digit(line, right_idx)
				right_idx -= 1
			}
		}

		sum += left * 10 + right
	}
	
	return sum
}
