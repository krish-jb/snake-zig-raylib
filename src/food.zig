const std = @import("std");
const rl = @import("raylib");
const color = @import("colors.zig");
const screen = @import("screen.zig");

pub const Food = struct {
    position: rl.Vector2,
    texture: rl.Texture2D,

    pub fn init() !Food {
        const image = try rl.loadImage("graphics/food.png");
        defer rl.unloadImage(image);

        return Food {
            .position = getRandomPosition(),
            .texture = try rl.loadTextureFromImage(image)
        };
    }

    fn getRandomPosition() rl.Vector2 {
        const seed: u64 = @as(u64, @intCast(std.time.milliTimestamp()));
        var prng = std.Random.DefaultPrng.init(seed);
        const rand = prng.random();

        const x: f32 = @floatFromInt(rand.intRangeAtMost(u8, 0, 25));
        const y: f32 = @floatFromInt(rand.intRangeAtMost(u8, 0, 25));
        return .{.x = x, .y = y};
    }

    pub fn deinit(self: Food) void {
        rl.unloadTexture(self.texture);
    }

    pub fn draw(self: Food) void {
        const x: i32 = @intFromFloat(self.position.x);
        const y: i32 = @intFromFloat(self.position.y);
        rl.drawTexture(
            self.texture,
            x * screen.cellSize,
            y * screen.cellSize,
            .white
        );
    }
};
