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
	digit :: proc(v: byte) -> i8 {
		if v >= '0' && v <= '9' {
			return i8(v) - '0'
		}
		return -1
	}

	input: string = #load("input.txt")
	sum: int
	for line in strings.split_lines_iterator(&input) {
		left, right: i8 = -1, -1
		for i in 0..<len(line) {
			d := digit(line[i])
			if d == -1 do continue

			if left == -1 {
				left = d
			}

			right = d
		}

		sum += int(left) * 10 + int(right)
	}

	return sum
}

part_2 :: proc() -> int {
	// PERF: If it really matters a Trie datastructure would make sense.
	digit :: proc(l: string, i: int) -> i8 {
		pre :: strings.has_prefix
		sl := l[i:]
		switch {
		case l[i] >= '0' && l[i] <= '9': return i8(l[i] - '0')
		case pre(sl, "one"):             return 1
		case pre(sl, "two"):             return 2
		case pre(sl, "three"):           return 3
		case pre(sl, "four"):            return 4
		case pre(sl, "five"):            return 5
		case pre(sl, "six"):             return 6
		case pre(sl, "seven"):           return 7
		case pre(sl, "eight"):           return 8
		case pre(sl, "nine"):            return 9
		case:                            return -1
		}
	}

	input: string = #load("input.txt")
	sum: int
	for line in strings.split_lines_iterator(&input) {
		left, right: i8 = -1, -1
		for i in 0..<len(line) {
			d := digit(line, i)
			if d == -1 do continue

			if left == -1 {
				left = d
			}

			right = d
		}

		sum += int(left) * 10 + int(right)
	}
	
	return sum
}
