package main

import "core:os"

import aoc ".."

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 3, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 3, Part 2", part_2)
	}
}

WIDTH :: 140
vec2 :: distinct [2]int

coords :: proc(m: []byte, i: int) -> (v: vec2) {
	// + 1 to account for newlines.
	v.y = i / (WIDTH + 1)
	v.x = i % (WIDTH + 1)
	return
}

index :: proc(m: []byte, v: vec2) -> Maybe(int) {
	// + v.y to account for newlines.
	i := v.y * WIDTH + v.x + v.y
	if i < 0 || i >= len(m) do return nil
	return i
}

at :: proc(m: []byte, v: vec2) -> Maybe(byte) {
	i, ok := index(m, v).?
	return m[i] if ok else nil
}

part_1 :: proc() -> (sum: int) {
    input := #load("input.txt")

	is_symbol :: proc(m: []byte, v: vec2) -> bool {
		switch at(m, v).? or_else '0' {
		case '0'..='9', '.', '\n': return false
		case:                      return true
		}
	}

	is_part :: proc(m: []byte, start: vec2, length: int) -> bool {
		assert(length > 0 && length < 4)

		{ // To the left.
			pos := start
			pos.x -= 1
			if is_symbol(m, pos) do return true
		}

		{ // To the right.
			pos := start
			pos.x += length
			if is_symbol(m, pos) do return true
		}

		{ // Row above.
			pos := start - 1
			for _ in 0..<length+2 {
				defer pos.x += 1
				if is_symbol(m, pos) do return true
			}
		}

		{ // Row below.
			pos := start
			pos.y += 1
			pos.x -= 1
			for _ in 0..<length+2 {
				defer pos.x += 1
				if is_symbol(m, pos) do return true
			}
		}

		return false
	}

	n:     int
	n_len: int
	for c, i in input {
		switch c {
		case '0'..='9':
			n = n * 10 + int(c - '0')
			n_len += 1

		case:
			defer n, n_len = 0, 0
			if n_len > 0 {
				c := coords(input, i - n_len)
				if is_part(input, c, n_len) {
					sum += n
				}
			}
		}
	}
    return
}

part_2 :: proc() -> (sum: int) {
    input := #load("input.txt")

	number_at :: proc(m: []byte, v: vec2) -> (n: int, ok: bool) {
		c := at(m, v).? or_return
		switch c {
		case '0'..='9': return int(c - '0'), true
		case:           return
		}
	}

	check_number :: proc(m: []byte, v: vec2) -> (n: int, ok: bool) {
		lv := v
		n = number_at(m, lv) or_return
		ok = true

		// Consume number chars to the left.
		for multi := 10; ; multi *= 10 {
			lv.x -= 1
			nn := number_at(m, lv) or_break
			n = nn * multi + n
		}

		// Consume number chars to the right.
		rv := v
		for {
			rv.x += 1
			nn := number_at(m, rv) or_break
			n = n * 10 + nn
		}

		return
	}

	gear_ratio :: proc(m: []byte, gear: vec2) -> (res: int, ok: bool) {
		found: int
		res = 1

		check :: #force_inline proc(m: []byte, pos: vec2, found: ^int, res: ^int) -> (n_found: bool, ok: bool) {
			ok = true
			ratio: int
			if ratio, n_found = check_number(m, pos); n_found {
				found^ += 1
				if found^ == 3 {
					ok = false
					return
				}
				res^ *= ratio
			}
			return
		}

		check(m, {gear.x-1, gear.y}, &found, &res) or_return
		check(m, {gear.x+1, gear.y}, &found, &res) or_return
		has_above := check(m, {gear.x, gear.y-1}, &found, &res) or_return
		has_below := check(m, {gear.x, gear.y+1}, &found, &res) or_return

		// If there is a number on top of the gear, it would have taken any numbers besides it and
		// this would be duplicating results.
		if !has_above {
			check(m, {gear.x-1, gear.y-1}, &found, &res) or_return
			check(m, {gear.x+1, gear.y-1}, &found, &res) or_return
		}

		// If there is a number below the gear, it would have taken any numbers besides it and
		// this would be duplicating results.
		if !has_below {
			check(m, {gear.x-1, gear.y+1}, &found, &res) or_return
			check(m, {gear.x+1, gear.y+1}, &found, &res) or_return
		}

		if found == 2 do ok = true
		return
	}

	for c, i in input {
		switch c {
		case '*':
			sum += gear_ratio(input, coords(input, i)) or_break
		}
	}

    return
}
