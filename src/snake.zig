const std = @import("std");
const rl = @import("raylib");
const color = @import("colors.zig");
const screen = @import("screen.zig");
const Deque = @import("deque.zig").Deque;
const dir = @import("direction.zig");
const SnakeConstants = @import("constants/snake.zig");

pub const Snake = struct {
    body: Deque(rl.Vector2),
    direction: dir.Direction,
    next_direction: dir.Direction,
    last_updated_time: f64,
    head_texture: rl.Texture2D,
    head_texture_rotation: f32,
    head_origin: rl.Vector2,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Snake {
        const image = try rl.loadImage("graphics/snake_head.png");
        defer image.unload();

        var body_deque = try Deque(rl.Vector2).init(allocator, 100);

        try body_deque.pushBack(.{ .x = 6, .y = 9 });
        try body_deque.pushBack(.{ .x = 5, .y = 9 });
        try body_deque.pushBack(.{ .x = 4, .y = 9 });

        return Snake{
            .body = body_deque,
            .allocator = allocator,
            .last_updated_time = 0.00,
            .head_origin = .{ .x = 0, .y = 0 },
            .direction = SnakeConstants.InitialDirection,
            .next_direction = SnakeConstants.InitialDirection,
            .head_texture = try rl.loadTextureFromImage(image),
            .head_texture_rotation = SnakeConstants.InitailRotation,
        };
    }

    pub fn setDirection(self: *Snake, direction: dir.Direction) void {
        self.direction = direction;
        self.head_texture_rotation = dir.getRotation(direction);
    }

    pub fn deinit(self: *Snake) void {
        self.body.deinit();
    }

    fn drawHead(self: *Snake) void {
        const head = self.body.peekFront().?;

        const src = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = screen.cellSize,
            .height = screen.cellSize,
        };

        const dest = rl.Rectangle{
            .x = head.x * screen.cellSize + screen.cellSizeHalf, // adjustment to match body origin. Nice trick buddy, or is it 😏
            .y = head.y * screen.cellSize + screen.cellSizeHalf,
            .width = screen.cellSize,
            .height = screen.cellSize,
        };

        const origin = rl.Vector2{ .x = screen.cellSizeHalf, .y = screen.cellSizeHalf };

        rl.drawTexturePro(self.head_texture, src, dest, origin, self.head_texture_rotation, .white);
    }

    fn drawBody(self: *Snake) void {
        for (1..self.body.len()) |i| {
            const pos = self.body.get(i).?;
            const segment = rl.Rectangle{
                .x = pos.x * screen.cellSize,
                .y = pos.y * screen.cellSize,
                .height = screen.cellSize,
                .width = screen.cellSize,
            };
            rl.drawRectangleRounded(segment, 0.5, 6, color.darkGreen);
        }
    }

    pub fn draw(self: *Snake) void {
        self.drawHead();
        self.drawBody();
    }

    pub fn update(self: *Snake) !void {
        const currentTime = rl.getTime();
        if (currentTime - self.last_updated_time < SnakeConstants.Interval) return;
        self.last_updated_time = currentTime;

        if (self.direction != self.next_direction) {
            self.setDirection(self.next_direction);
        }
        _ = self.body.popBack().?;

        var head = self
            .body
            .peekFront().?
            .add(dir.getDirection(self.direction));
        head.x = @mod(head.x, screen.cellCount);
        head.y = @mod(head.y, screen.cellCount);

        try self.body.pushFront(head);
    }

    pub fn grow(self: *Snake) !void {
        try self.body.pushBack(
            self.body.peekBack().?.subtract(
                dir.getDirection(self.direction)
            )
        );
    }
};
