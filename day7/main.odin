package main

import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

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
	hand:  string,
	cards: Cards,
	rank:  Rank,
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

card_ranks: [86]int = {
	'A' = 1,
	'K' = 2,
	'Q' = 3,
	// 'J' = 4 or 14,
	'T' = 5,
	'9' = 6,
	'8' = 7,
	'7' = 8,
	'6' = 9,
	'5' = 10,
	'4' = 11,
	'3' = 12,
	'2' = 13,
}

subs: [12]byte = {
	'A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2',
}

rank_card :: proc(cards: Cards) -> (r: Rank) {
	switch {
	case sa.len(cards) == 1: return .Five_Of_A_Kind
	case sa.len(cards) == 2:
		a, b := sa.get(cards, 0), sa.get(cards, 1)
		switch {
		case a.num == 4 || b.num == 4: return .Four_Of_A_Kind
		case a.num == 3 && b.num == 2: return .Full_House
		case a.num == 2 && b.num == 3: return .Full_House
		case:                          return .None
		}

	case sa.len(cards) == 3:
		has_three: bool
		pairs: int
		for i in 0..<3 {
			card := sa.get(cards, i)
			if card.num == 3 do has_three = true
			if card.num == 2 do pairs += 1
		}
		switch {
		case has_three && pairs == 0: return .Three_Of_A_Kind
		case pairs == 2:              return .Two_Pair
		case:                         return .None
		}

	case sa.len(cards) == 4: return .One_Pair
	case:                    return .High_Card
	}
}

sum_cards :: proc(hand: string) -> (cards: Cards) {
	cards_loop: for c in hand {
		for i := 0; i < sa.len(cards); i += 1 {
			card := sa.get_ptr(&cards, i)
			if card.label == c {
				card.num += 1
				continue cards_loop
			}
		}
		sa.append(&cards, Card{ c, 1 })
	}
	return
}

parse_rounds :: proc(input: string, ranker: proc(string) -> Rank) -> []Round {
	input := input
	rounds: [dynamic]Round
	for round_str in strings.split_lines_iterator(&input) {
		hand_str, _, bid_str := strings.partition(round_str, " ")
		cards := sum_cards(hand_str)
		bid   := strconv.atoi(bid_str)
		append(&rounds, Round{
			hand  = hand_str,
			cards = cards,
			bid   = bid,
			rank  = ranker(hand_str),
		})
	}
	return rounds[:]
}

// print_round :: proc(round: Round) {
//	fmt.printf("%v\n", round.rank)
//	for i := 0; i < sa.len(round.cards); i += 1 {
//		card := sa.get(round.cards, i)
//		fmt.printf("%d %c\n", card.num, card.label)
//	}
//	fmt.println()
// }

cmp_rounds :: proc(a: Round, b: Round) -> slice.Ordering {
	switch {
	case a.rank == b.rank:
		for ac, i in a.hand {
			bc := b.hand[i]
			ar, br := card_ranks[ac], card_ranks[bc]
			switch {
			case ar == br: continue
			case ar > br:  return .Less
			case:          return .Greater
			}
		}
		unreachable()

	case a.rank > b.rank: return .Greater
	case:                 return .Less
	}
}

part_1 :: proc() -> (total: int) {
	input := #load("input.txt", string)

	card_ranks['J'] = 4

	rounds := parse_rounds(input, proc(hand: string) -> Rank {
		return rank_card(sum_cards(hand))
	})
	defer delete(rounds)

	slice.sort_by_cmp(rounds[:], cmp_rounds)

	for round, i in rounds {
		assert(round.rank != .None)
		// fmt.printf("%d * %d\n", round.bid, i + 1)
		// print_round(round)
		total += round.bid * (i+1)
	}
	return
}

part_2 :: proc() -> (total: int) {
	input := #load("input.txt", string)

	card_ranks['J'] = 14

	// Just recursively try changing each joker to each card lol.
	rank_jokers :: proc(hand: string) -> Rank {
		i := strings.index_byte(hand, 'J')
		if i == -1 {
			return rank_card(sum_cards(hand))
		}

		buf: [5]byte
		copy(buf[:], hand)

		r := Rank.None
		for s in subs {
			buf[i] = s
			r = max(r, rank_jokers(string(buf[:])))
		}
		return r
	}

	rounds := parse_rounds(input, rank_jokers)
	defer delete(rounds)

	slice.sort_by_cmp(rounds[:], cmp_rounds)

	for round, i in rounds {
		assert(round.rank != .None)
		// fmt.printf("%d * %d\n", round.bid, i + 1)
		// print_round(round)
		total += round.bid * (i+1)
	}
	return
}
