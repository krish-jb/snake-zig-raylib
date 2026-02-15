pub const Direction = enum(u8) {
    up,
    down,
    left,
    right
};

pub fn getRotation(direction: Direction) f32 {
    return switch(direction) {
        .up => 180,
        .right => 270.0,
        .down => 0.0,
        .left => 90.0,
    };
}
