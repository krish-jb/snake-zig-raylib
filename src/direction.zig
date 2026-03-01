const rl = @import("raylib");

pub const Direction = enum(u8) {
    up,
    down,
    left,
    right
};

pub fn getDirection(direction: Direction) rl.Vector2 {
    return switch (direction) {
        .up => .{ .x = 0, .y = -1 },
        .down => .{ .x = 0, .y = 1 },
        .left => .{ .x = -1, .y = 0 },
        .right => .{ .x = 1, .y = 0 },
    };
}

pub fn getRotation(direction: Direction) f32 {
    return switch(direction) {
        .up => 180,
        .right => 270.0,
        .down => 0.0,
        .left => 90.0,
    };
}
