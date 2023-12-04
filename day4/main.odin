package main

import "core:bytes"
import "core:os"

import ba "core:container/bit_array"

import aoc ".."

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 4, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 4, Part 2", part_2)
	}
}

part_1 :: proc() -> (sum: int) {
    input := #load("input.txt")

	set := ba.create(99)
    defer ba.destroy(set)

	for line in bytes.split_after_iterator(&input, {'\n'}) {
		defer ba.clear(set)

        checking: bool
        num: int
        score: int
        for c in line {
            switch c {
            case '0'..='9':
                num = num * 10 + int(c - '0')

            case ':':
                num = 0

            case ' ', '\n':
                if num == 0 do break
                defer num = 0
                assert(num < 100)
                
                // Add to winning numbers.
                if !checking {
                    ba.unsafe_set(set, num)
                    break
                }

                // Check if in winning numbers.
                if ba.unsafe_get(set, num) {
                    if score == 0 {
                        score = 1
                        break
                    }

                    score *= 2
                }

            case '|':
                checking = true
            }
        }

        sum += score
	}

    return
}

part_2 :: proc() -> (sum: int) {
    input := #load("input.txt")

	set := ba.create(99)
    defer ba.destroy(set)

    lines: [dynamic]u8
    defer delete(lines)

	for line in bytes.split_after_iterator(&input, {'\n'}) {
		defer ba.clear(set)

        checking: bool
        num: int
        won: u8
        for c in line {
            switch c {
            case '0'..='9':
                num = num * 10 + int(c - '0')

            case ':':
                num = 0

            case ' ', '\n':
                if num == 0 do break
                defer num = 0
                assert(num < 100)
                
                if !checking {
                    ba.unsafe_set(set, num)
                    break
                }

                if ba.unsafe_get(set, num) {
                    won += 1
                }

            case '|':
                checking = true
            }
        }

        append(&lines, won)
    }

    queue: [dynamic]u32
    defer delete(queue)

    for _, i in lines {
        append(&queue, u32(i))
        for {
            card := pop_safe(&queue) or_break
            won  := u32(lines[card])
            sum  += 1
            for copy in card+1..<card+1+won {
                append(&queue, copy)
            }
        }
    }
    return
}
