package main

import "core:os"
import "core:strings"
import "core:strconv"

import aoc ".."

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 9, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 9, Part 2", part_2)
	}
}

Direction :: enum {
	Front,
	Back,
}

solve :: proc(buf: ^[dynamic]int, dir: Direction) -> int {
	same := true
	for n in buf[1:] {
		if n != buf[0] {
			same = false
			break
		}
	}

	if same {
		return buf[0]
	}

	acc := buf[0 if dir == .Front else len(buf)-1]

	// appending differences to the end, then
	// copying them to the front and resizing.
	n := len(buf)
	for i in 0..<n-1 {
		append(buf, buf[i+1] - buf[i])
	}
	resize(buf, copy(buf[:n], buf[n:]))

	add := solve(buf, dir)
	return acc - add if dir == .Front else acc + add
}

part_1 :: proc() -> (next_sum: int) {
	input := #load("input.txt", string)
	buf := make([dynamic]int, 0, 8)
	for sequence in strings.split_lines_iterator(&input) {
		sequence := sequence
		for val_str in strings.split_iterator(&sequence, " ") {
			append(&buf, strconv.atoi(val_str))
		}
		next_sum += solve(&buf, .Back)
		clear(&buf)
	}
	return
}

part_2 :: proc() -> (next_sum: int) {
	input := #load("input.txt", string)
	buf := make([dynamic]int, 0, 8)
	for sequence in strings.split_lines_iterator(&input) {
		sequence := sequence
		for val_str in strings.split_iterator(&sequence, " ") {
			append(&buf, strconv.atoi(val_str))
		}
		next_sum += solve(&buf, .Front)
		clear(&buf)
	}
	return
}
