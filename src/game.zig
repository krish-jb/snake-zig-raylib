const std = @import("std");
const rl = @import("raylib");
const util = @import("utils.zig");
const Food = @import("food.zig").Food;
const Snake = @import("snake.zig").Snake;
const Direction = @import("direction.zig").Direction;

pub const Game = struct {
    snake: Snake,
    food: Food,
    allocator: std.mem.Allocator,
    lastUpdatedTime: f64,

    pub fn init(allocator: std.mem.Allocator) !Game {
        return .{
            .snake = try Snake.init(allocator),
            .food = try Food.init(),
            .allocator = allocator,
            .lastUpdatedTime = 0.0,
        };
    }

    pub fn draw(self: *Game) void {
        self.food.draw();
        self.snake.draw();
    }

    pub fn update(self: *Game) !void {
        try util.interval(0.2, &self.lastUpdatedTime, &self.snake, Snake.update);

        if (rl.isKeyPressed(.up) and self.snake.direction.y != 1) {
            self.snake.setDirection(Direction.up);
        }

        if (rl.isKeyPressed(.down) and self.snake.direction.y != -1) {
            self.snake.setDirection(Direction.down);
        }

        if (rl.isKeyPressed(.left) and self.snake.direction.x != 1) {
            self.snake.setDirection(Direction.left);
        }

        if (rl.isKeyPressed(.right) and self.snake.direction.x != -1) {
            self.snake.setDirection(Direction.right);
        }
    }

    pub fn deinit(self: *Game) void {
        self.snake.deinit();
        self.food.deinit();
    }
};
