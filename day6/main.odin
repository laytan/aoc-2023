package main

import "core:os"
import "core:strings"
import "core:strconv"

import aoc ".."

// NOTE: there is probably a formula I don't know but fk that.

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 6, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 6, Part 2", part_2)
	}
}

part_1 :: proc() -> (multiplied: int) {
	input := #load("input.txt", string)

	stimes, _, sdistances := strings.partition(input, "\n")
	stimes     = strings.trim_space(stimes[len("Distance:"):])
	sdistances = strings.trim_space(sdistances[len("Distance:"):])

	times:     [dynamic]int
	for entry in strings.split_iterator(&stimes, " ") {
		if entry == "" do continue
		append(&times, strconv.atoi(entry))
	}

	distances: [dynamic]int
	for entry in strings.split_iterator(&sdistances, " ") {
		if entry == "" do continue
		append(&distances, strconv.atoi(entry))
	}

	for time, i in times {
		// PERF: it is a wave, can only do half and * 2 it.
		ways_to_win := 0
		for hold in 0..=time {
			drive_time := time - hold
			speed      := hold
			distance   := speed * drive_time
			if distance > distances[i] {
				ways_to_win += 1
			}
		}
		multiplied = max(multiplied, 1) * ways_to_win
	}
	return
}

part_2 :: proc() -> (ways_to_win: int) {
	input := #load("input.txt", string)

	stimes, _, sdistances := strings.partition(input, "\n")

	time: int
	for c in stimes {
		switch c {
		case '0'..='9': time = time * 10 + int(c - '0')
		}
	}

	distance: int
	for c in sdistances {
		switch c {
		case '0'..='9': distance = distance * 10 + int(c - '0')
		}
	}

	assert(time % 2 == 0)
	for hold in 0..=time/2 {
		drive_time := time - hold
		speed      := hold
		if speed * drive_time > distance {
			ways_to_win += 2
		}
	}

	return
}
