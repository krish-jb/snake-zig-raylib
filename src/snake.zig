const std = @import("std");
const rl = @import("raylib");
const color = @import("colors.zig");
const screen = @import("screen.zig");
const Deque = @import("deque.zig").Deque;

pub const Snake = struct {
    body: Deque(rl.Vector2),
    direction: rl.Vector2,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Snake {
        var body_deque = try Deque(rl.Vector2).init(allocator);

        try body_deque.pushBack(.{ .x = 6, .y = 9});
        try body_deque.pushBack(.{ .x = 5, .y = 9});
        try body_deque.pushBack(.{ .x = 4, .y = 9});

        return Snake{
            .body = body_deque,
            .allocator = allocator,
            .direction = .{ .x = 1, .y = 0}
        };
    }

    pub fn deinit(self: *Snake) void {
        self.body.deinit();
    }

    pub fn draw(self: *Snake) void {
        for (0..self.body.len()) |i| {
            const pos = self.body.get(i).?;
            const segment = rl.Rectangle{
                .x = @mod(pos.x, screen.cellCount) * screen.cellSize,
                .y = @mod(pos.y, screen.cellCount) * screen.cellSize,
                .height = screen.cellSize,
                .width = screen.cellSize,
            };
            rl.drawRectangleRounded(segment, 0.5, 6, color.darkGreen);
        }
    }

    pub fn update(self: *Snake) !void {
        _ = self.body.popBack().?;
        try self.body.pushFront(
            self.body.get(0).?.add(self.direction)
        );
    }
};
