const std = @import("std");
const rl = @import("raylib");

pub fn interval(
    intervalTime: f64,
    lastUpdatedTime: *f64,
    context: anytype,
    comptime callback: anytype
) !void {
    const currentTime = rl.getTime();
    if (currentTime - lastUpdatedTime.* >= intervalTime) {
        const result = callback(&context.snake, context.snakeNextDirection);
        if (@typeInfo(@TypeOf(result)) == .error_union) {
            try result;
        }
        lastUpdatedTime.* = rl.getTime();
    }
}
