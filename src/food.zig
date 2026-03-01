const std = @import("std");
const rl = @import("raylib");
const color = @import("colors.zig");
const screen = @import("screen.zig");
const Deque = @import("deque.zig").Deque;

pub const Food = struct {
    position: rl.Vector2,
    texture: rl.Texture2D,

    pub fn init() !Food {
        const image = try rl.loadImage("graphics/food.png");
        defer image.unload();

        return Food {
            .position = getRandomPosition(),
            .texture = try rl.loadTextureFromImage(image)
        };
    }

    fn getRandomPosition() rl.Vector2 {
        const seed: u64 = @as(u64, @intCast(std.time.milliTimestamp()));
        var prng = std.Random.DefaultPrng.init(seed);
        const rand = prng.random();

        const x: f32 = @floatFromInt(rand.intRangeAtMost(u8, 0, screen.cellCount - 1));
        const y: f32 = @floatFromInt(rand.intRangeAtMost(u8, 0, screen.cellCount - 1));
        return .{.x = x, .y = y};
    }

    fn positionInDeque(snakeBody: *Deque(rl.Vector2), newPosition: rl.Vector2) bool {
        for (0..snakeBody.*.len()) |i| {
            const position = snakeBody.*.get(i);
            if (position.?.x == newPosition.x and position.?.y == newPosition.y) return true;
        }
        return false;
    }

    pub fn deinit(self: *Food) void {
        rl.unloadTexture(self.texture);
    }

    pub fn draw(self: *Food) void {
        const x: i32 = @intFromFloat(self.position.x);
        const y: i32 = @intFromFloat(self.position.y);

        rl.drawTexture(
            self.texture,
            x * screen.cellSize,
            y * screen.cellSize,
            .white
        );
    }

    pub fn isColided(self: *Food, snakeHeadkPos: rl.Vector2) bool {
        return snakeHeadkPos.x == self.position.x and snakeHeadkPos.y == self.position.y;
    }

    pub fn changePosition(self: *Food, snakeBody: *Deque(rl.Vector2)) void {
        var position = getRandomPosition();
        while (positionInDeque(snakeBody, position)) {
            position = getRandomPosition();
        }
        self.position = position;
    }
};
