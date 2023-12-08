package main

import "core:math"
import "core:os"
import "core:strings"

import aoc ".."

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 8, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 8, Part 2", part_2)
	}
}

part_1 :: proc() -> int {
    input := #load("input.txt", string)

	dirs, _, nodes := strings.partition(input, "\n\n")

	m: map[string][2]string
	for line in strings.split_lines_iterator(&nodes) {
		m[line[0:3]] = { line[7:10], line[12:15] }
	}

	next := "AAA"
	step: int
	for next != "ZZZ" {
		defer step += 1

		switch dirs[step % len(dirs)] {
		case 'L': next = m[next].x
		case 'R': next = m[next].y
		case:     unreachable()
		}
	}

    return step
}

part_2 :: proc() -> int {
    input := #load("input.txt", string)

	dirs, _, nodes_str := strings.partition(input, "\n\n")

	nodes: [dynamic]string
	defer delete(nodes)

	m: map[string][2]string
	defer delete(m)

	for line in strings.split_lines_iterator(&nodes_str) {
		m[line[0:3]] = { line[7:10], line[12:15] }
		if line[2] == 'A' do append(&nodes, line[0:3])
	}

	total := 1
	for node in nodes {
		steps: int
		next := node
		for next[2] != 'Z' {
			defer steps += 1

			switch dirs[steps % len(dirs)] {
			case 'L': next = m[next].x
			case 'R': next = m[next].y
			case:     unreachable()
			}
		}

		total = math.lcm(total, steps)
	}

    return total
}
