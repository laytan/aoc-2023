package main

import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

import sa "core:container/small_array"

import aoc ".."

main :: proc() {
	if len(os.args) < 2 || os.args[1] == "1" {
		aoc.run("Day 7, Part 1", part_1)
	}

	if len(os.args) < 2 || os.args[1] == "2" {
		aoc.run("Day 7, Part 2", part_2)
	}
}

Round :: struct {
	score: u64be,
	bid:   int,
}

Card :: struct {
	label: rune,
	num:   int,
}

Cards :: sa.Small_Array(5, Card)

Rank :: enum {
	None,
	High_Card,
	One_Pair,
	Two_Pair,
	Three_Of_A_Kind,
	Full_House,
	Four_Of_A_Kind,
	Five_Of_A_Kind,
}

card_ranks: [86]u8 = {
	'A' = 13,
	'K' = 12,
	'Q' = 11,
	// 'J' = 10 (part 1) or 0 (part 2),
	'T' = 9,
	'9' = 8,
	'8' = 7,
	'7' = 6,
	'6' = 5,
	'5' = 4,
	'4' = 3,
	'3' = 2,
	'2' = 1,
}

rank_card :: proc(cards: Cards) -> (r: Rank) {
	switch {
	case cards.len == 1: return .Five_Of_A_Kind
	case cards.len == 2:
		a, b := cards.data[0], cards.data[1]
		switch {
		case a.num == 4 || b.num == 4: return .Four_Of_A_Kind
		case a.num == 3 && b.num == 2: return .Full_House
		case a.num == 2 && b.num == 3: return .Full_House
		case:                          unreachable()
		}

	case cards.len == 3:
		has_three: bool
		pairs: int
		for i in 0..<3 {
			card := cards.data[i]
			if card.num == 3 {
				has_three = true
			} else if card.num == 2 {
				pairs += 1
			}
		}
		switch {
		case has_three && pairs == 0: return .Three_Of_A_Kind
		case pairs == 2:              return .Two_Pair
		case:                         unreachable()
		}

	case cards.len == 4: return .One_Pair
	case:                return .High_Card
	}
}

sum_cards :: proc(hand: string) -> (cards: Cards) {
	cards_loop: for c in hand {
		for &card in cards.data[:] {
			if card.label == c {
				card.num += 1
				continue cards_loop
			}
		}
		sa.append(&cards, Card{ c, 1 })
	}
	return
}

parse_rounds :: proc(input: string, ranker: proc(Cards) -> Rank) -> []Round {
	input := input
	rounds := make([dynamic]Round, 0, 1000)
	for round_str in strings.split_lines_iterator(&input) {
		hand_str, _, bid_str := strings.partition(round_str, " ")

		cards := sum_cards(hand_str)
		bid   := strconv.atoi(bid_str)

		// The buffer we will use to sort, first byte is the rank of the hand
		// with later bytes the rank of each card. Which is also the criteria
		// for sorting.
		// 8 bytes so it fits in a u64 for when we compare.
		score: [8]byte
		score[0] = u8(ranker(cards))
		for i in 1..<6 {
			score[i] = card_ranks[hand_str[i-1]]
		}

		append(&rounds, Round{
			score = transmute(u64be)score,
			bid   = bid,
		})
	}
	return rounds[:]
}

rounds_less :: proc(a: Round, b: Round) -> bool {
	return a.score < b.score
}

part_1 :: proc() -> (total: int) {
	input := #load("input.txt", string)

	card_ranks['J'] = 10

	rounds := parse_rounds(input, rank_card)
	defer delete(rounds)

	slice.sort_by(rounds[:], rounds_less)

	for round, i in rounds {
		total += round.bid * (i+1)
	}
	return
}

part_2 :: proc() -> (total: int) {
	input := #load("input.txt", string)

	card_ranks['J'] = 0


	// Original solution:
	// @static subs: [12]byte = {
	// 	'A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2',
	// }
	// // Just recursively try changing each joker to each card lol.
	// rank_jokers :: proc(hand: string) -> Rank {
	// 	i := strings.index_byte(hand, 'J')
	// 	if i == -1 {
	// 		return rank_card(sum_cards(hand))
	// 	}
	//
	// 	buf: [5]byte
	// 	copy(buf[:], hand)
	//
	// 	r := Rank.None
	// 	for s in subs {
	// 		buf[i] = s
	// 		r = max(r, rank_jokers(string(buf[:])))
	// 	}
	// 	return r
	// }

	// Adding the jokers to the card of the highest value makes it the highest
	// possible value card.
	rank_jokers :: proc(cards: Cards) -> Rank {
		cards := cards

		jokers_idx: int
		jokers, highest: ^Card
		for i in 0..<cards.len {
			card := &cards.data[i]
			if card.label == 'J' {
				jokers_idx = i
				jokers     = card
			} else if highest == nil || card.num >= highest.num {
				highest = card
			}
		}

		if jokers != nil {
			if highest == nil {
				// 5 Jokers.
				cards.data[0].label = 'A'
			} else {
				highest.num += jokers.num
				sa.unordered_remove(&cards, jokers_idx)
			}
		}

		return rank_card(cards)
	}

	rounds := parse_rounds(input, rank_jokers)
	defer delete(rounds)

	slice.sort_by(rounds[:], rounds_less)

	for round, i in rounds {
		total += round.bid * (i+1)
	}
	return
}
