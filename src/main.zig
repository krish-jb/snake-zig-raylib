const std = @import("std");
const rl = @import("raylib");
const game = @import("game");
const util = @import("utils.zig");
const color = @import("colors.zig");
const screen = @import("screen.zig");
const Food = @import("food.zig").Food;
const Snake = @import("snake.zig").Snake;

pub fn main() !void {
    var lastUpdatedTime: f64 = 0.0;
    rl.initWindow(screen.size, screen.size, "Snake");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var food = try Food.init();
    defer food.deinit();

    var snake = try Snake.init(allocator);
    defer snake.deinit();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        try util.interval(0.2, &lastUpdatedTime, &snake, Snake.update);

        if (rl.isKeyPressed(.up) and snake.direction.y != 1) {
            snake.direction = .{ .x = 0, .y = -1 };
        }

        if (rl.isKeyPressed(.down) and snake.direction.y != -1) {
            snake.direction = .{ .x = 0, .y = 1 };
        }

        if (rl.isKeyPressed(.left) and snake.direction.x != 1) {
            snake.direction = .{ .x = -1, .y = 0 };
        }

        if (rl.isKeyPressed(.right) and snake.direction.x != -1) {
            snake.direction = .{ .x = 1, .y = 0 };
        }

        // Drawing
        rl.clearBackground(color.green);
        food.draw();
        snake.draw();
    }
}
