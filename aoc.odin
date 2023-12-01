package aoc

import "core:fmt"
import "core:runtime"
import "core:time"

run :: proc(name: string, fn: proc() -> $T) {
	context.allocator = context.temp_allocator
	defer free_all(context.allocator)

	start := time.tick_now()

	result := fn()

	dur := time.tick_since(start)
	usage := runtime.global_default_temp_allocator_data.arena.total_used

	fmt.printf("[%s | %s | %m]: %v\n", name, dur, usage, result)
}
