package main

import "core:os"
import "core:strconv"
import "core:strings"

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

	Seed :: struct {
		start: int,
		length: int,
	}

	raw_seeds, maps_input := parse_seeds(input)
	defer delete(raw_seeds)

	seeds := make([dynamic]Seed, len(raw_seeds)/2)
	defer delete(seeds)
	for i := 0; i < len(raw_seeds); i += 2 {
		seeds[i / 2] = { raw_seeds[i], raw_seeds[i+1] }
	}

	maps := parse_maps(maps_input)
	defer { for m in maps do delete(m) }

	do_mapping :: proc(result: ^[dynamic]Seed, mappings: []Mapping, seed: Seed) {
		seed := seed
		for m in mappings {
			seed_end := seed.start  + seed.length
			map_end  := m.src_start + m.length

			// Check overlaps, if it does, add that part to the results and keep going with the rest.
			if seed.start < map_end && seed_end > m.src_start {
				inter_start := max(seed.start, m.src_start)
				inter_end   := min(seed_end, map_end)
				offset      := m.dst_start - m.src_start
				length      := inter_end - inter_start

				// Add mapped part to the result.
				in_mapping := Seed{ inter_start + offset, length }
				append(result, in_mapping)

				rem_length := seed.length - length

				// The seed was fully mapped.
				if rem_length <= 0 {
					return
				}

				// Check if remainder is at the beginning or end.
				if inter_start == seed.start {
					do_mapping(result, mappings, Seed{seed.start + length, rem_length})
					return
				} else {
					// Map the remaining part at the start.
					start := Seed{seed.start, inter_start - seed.start}
					do_mapping(result, mappings, start)
					rem_length -= start.length

					// Map the remaining part at the end.
					if rem_length > 0 {
						end := Seed{inter_end, rem_length}
						do_mapping(result, mappings, end)
					}
					return
				}
			}
		}

		// Seed didn't map to any mapping, it stays the same.
		append(result, seed)
	}

	lowest = max(int)
	for m, i in maps {
		length := len(seeds)
		for i in 0..<length {
			seed := seeds[i]
			do_mapping(&seeds, m, seed)
		}
		remove_range(&seeds, 0, length)
	}

	for seed in seeds {
		lowest = min(lowest, seed.start)
	}
    return
}
