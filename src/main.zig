const std = @import("std");
const game = @import("game");
const rl = @import("raylib");
const color = @import("colors.zig");
const screen = @import("screen.zig");
const fd = @import("food.zig");


pub fn main() !void {
    rl.initWindow(screen.size, screen.size, "Snake");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var food = try fd.Food.init();
    defer food.deinit();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        // Drawing
        rl.clearBackground(color.green);
        food.draw();
    }
}
