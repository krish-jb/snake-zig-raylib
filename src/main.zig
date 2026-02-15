const std = @import("std");
const rl = @import("raylib");
const Game = @import("game.zig").Game;
const util = @import("utils.zig");
const color = @import("colors.zig");
const screen = @import("screen.zig");

pub fn main() !void {
    rl.initWindow(screen.size, screen.size, "Snake");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var game = try Game.init(allocator);
    defer game.deinit();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        try game.update();

        // Drawing
        rl.clearBackground(color.green);
        game.draw();
    }
}
