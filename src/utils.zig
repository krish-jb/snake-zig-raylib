const std = @import("std");
const rl = @import("raylib");

pub fn interval(
    intervalTime: f64,
    lastUpdatedTime: *f64,
    context: anytype,
    callback: fn (@TypeOf(context)) anyerror!void
) !void {
    const currentTime = rl.getTime();
    if (currentTime - lastUpdatedTime.* >= intervalTime) {
        try callback(context);
        lastUpdatedTime.* = currentTime;
    }
}
