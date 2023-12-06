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

// Binary search to the first win and calculate the amount we win.
ways_to_win :: proc(time: int, distance: int) -> int {
	half := time / 2 + time % 2
	size  := half
	left  := 0
	right := half
	for left < right {
		hold := left + size / 2

		drive_time := time - hold
		speed      := hold
		driven     := speed * drive_time
		is_win     := driven > distance

		if is_win {
			right = hold
		} else {
			left = hold + 1
		}
		size = right - left
	}
	start_winning := left
	ways := (half - start_winning) * 2
	if time % 2 == 0 do ways += 1
	return ways
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
		ways := ways_to_win(time, distances[i])
		multiplied = max(multiplied, 1) * ways
	}
	return
}

part_2 :: proc() -> int {
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

	return ways_to_win(time, distance)
}
