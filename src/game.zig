const std = @import("std");
const rl = @import("raylib");
const util = @import("utils.zig");
const Food = @import("food.zig").Food;
const Snake = @import("snake.zig").Snake;
const dir = @import("direction.zig");

pub const Game = struct {
    snake: Snake,
    food: Food,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Game {
        return .{
            .snake = try Snake.init(allocator),
            .food = try Food.init(),
            .allocator = allocator,
        };
    }

    pub fn draw(self: *Game) void {
        self.snake.draw();
        self.food.draw();
    }

    pub fn keyInputUpdate(self: *Game) void {
        if (rl.isKeyPressed(.up) and self.snake.direction != .down) {
            self.snake.next_direction = .up;
        }

        if (rl.isKeyPressed(.down) and self.snake.direction != .up) {
            self.snake.next_direction = .down;
        }

        if (rl.isKeyPressed(.left) and self.snake.direction != .right) {
            self.snake.next_direction = .left;
        }

        if (rl.isKeyPressed(.right) and self.snake.direction != .left) {
            self.snake.next_direction = .right;
        }
    }

    fn collitionUpdate(self: *Game) !void {
        if (self.food.isColided(self.snake.body.peekFront().?)) {
            self.food.changePosition(&self.snake.body);
            try self.snake.grow();
        }
    }

    pub fn update(self: *Game) !void {
        self.keyInputUpdate();
        try self.snake.update();
        try self.collitionUpdate();
    }

    pub fn deinit(self: *Game) void {
        self.snake.deinit();
        self.food.deinit();
    }
};
