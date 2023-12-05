package main

import "core:os"
import "core:strings"
import "core:strconv"

import aoc ".."

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 5, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 5, Part 2", part_2)
	}
}

Mapping :: struct {
	dst_start: int,
	src_start: int,
	length:    int,
}

do_mapping :: proc(mappings: []Mapping, v: int) -> int {
	// PERF: could sort the mappings and do a binary search,
	// but there don't seem to be that many where it will actually benefit.

	for m in mappings {
		if v >= m.src_start && v < m.src_start + m.length {
			return m.dst_start + v - m.src_start
		}
	}
	return v
}

parse_seeds :: proc(input: string) -> ([]int, string) {
	nl         := strings.index_byte(input, '\n')
	seeds_line := input[len("seeds: "):nl]
	// PERF: could count spaces to see how many we need to allocate.
	seeds      := make([dynamic]int)
	for seed_str in strings.split_iterator(&seeds_line, " ") {
		append(&seeds, strconv.atoi(seed_str))
	}
	return seeds[:], input[nl+2:]
}

parse_maps :: proc(input: string) -> (out: [7][]Mapping) {
	input := input
	input  = input[strings.index_byte(input, '\n')+1:]
	curr_map := 0
	maps: [7][dynamic]Mapping
	for line in strings.split_lines_iterator(&input) {
		if line == "" {
			out[curr_map] = maps[curr_map][:]
			curr_map += 1
			// PERF: could count newlines to see how many mappings we need to allocate.
			lb := strings.index_byte(input, '\n')
			if lb == -1 do break
			input = input[lb+1:]
			continue
		}

		dst_start, _, rest   := strings.partition(line, " ")
		src_start, _, length := strings.partition(rest, " ")
		append(&maps[curr_map], Mapping{
			strconv.atoi(dst_start),
			strconv.atoi(src_start),
			strconv.atoi(length),
		})
	}
	out[6] = maps[6][:]
	return
}

part_1 :: proc() -> (lowest: int) {
    input := #load("input.txt", string)

	seeds, maps_input := parse_seeds(input)
	defer delete(seeds)

	maps := parse_maps(maps_input)
	defer { for m in maps do delete(m) }

	lowest = max(int)
	for seed in seeds {
		result := seed
		for m in maps {
			result = do_mapping(m, result)
		}
		lowest = min(lowest, result)
	}
    return
}

part_2 :: proc() -> (lowest: int) {
    input := #load("input.txt", string)

	seeds, maps_input := parse_seeds(input)
	defer delete(seeds)

	maps := parse_maps(maps_input)
	defer { for m in maps do delete(m) }

	lowest = max(int)
	for i := 0; i < len(seeds); i += 2 {
		start_seed := seeds[i]
		length     := seeds[i+1]

		for seed in start_seed..<start_seed+length {
			result := seed
			for m in maps {
				result = do_mapping(m, result)
			}
			lowest = min(lowest, result)
		}
	}
    return
}
