const std = @import("std");

pub fn Deque(comptime T: type) type {
    return struct {
        buffer: []T,
        allocator: std.mem.Allocator,
        head: usize,
        tail: usize,
        count: usize,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator, initial_capacity: ?usize,) !Self {
            const buffer = try allocator.alloc(T,
                initial_capacity orelse 8
            );

            return Self{
                .buffer = buffer,
                .allocator = allocator,
                .head = 0,
                .tail = 0,
                .count = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        fn capacity(self: *const Self) usize {
            return self.buffer.len;
        }

        fn grow(self: *Self) !void {
            const new_capacity = self.capacity() * 2;
            const new_buffer = try self.allocator.alloc(T, new_capacity);

            var idx = self.head;
            for (0..self.count) |i| {
                new_buffer[i] = self.buffer[idx];
                idx = (idx + 1) % self.capacity();
            }

            self.allocator.free(self.buffer);
            self.buffer = new_buffer;
            self.head = 0;
            self.tail = self.count;
        }

        pub fn pushBack(self: *Self, item: T) !void {
            if (self.count >= self.capacity()) {
                try self.grow();
            }

            self.buffer[self.tail] = item;
            self.tail = (self.tail + 1) % self.capacity();
            self.count += 1;
        }

        pub fn popBack(self: *Self) ?T {
            if (self.count == 0) return null;
            self.tail = if (self.tail == 0) self.capacity() - 1 else self.tail - 1;
            self.count -= 1;
            return self.buffer[self.tail];
        }

        pub fn pushFront(self: *Self, item: T) !void {
            if (self.count >= self.capacity()) {
                try self.grow();
            }

            self.head = if (self.head == 0) self.capacity() - 1 else self.head - 1;
            self.buffer[self.head] = item;
            self.count += 1;
        }

        pub fn popFront(self: *Self) ?T {
            if (self.count == 0) return null;
            const item = self.buffer[self.head];
            self.head = (self.head + 1) % self.capacity();
            self.count -= 1;
            return item;
        }

        pub fn peekFront(self: *Self) ?T {
            if (self.count == 0) return null;
            return self.buffer[self.head];
        }

        pub fn peekBack(self: *Self) ?T {
            if (self.count == 0) return null;
            const idx = if (self.tail == 0) self.capacity() - 1 else self.tail - 1;
            return self.buffer[idx];
        }

        pub fn get(self: *Self, index: usize) ?T {
            if (self.count == 0 or index >= self.count) return null;
            const idx = (self.head + index) % self.capacity();
            return self.buffer[idx];
        }

        pub fn len(self: *Self) usize {
            return self.count;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.count == 0;
        }

        pub fn clear(self: *Self) void {
            self.head = 0;
            self.tail = 0;
            self.count = 0;
        }
    };
}

// Test helper
fn expectEqual(expected: anytype, actual: @TypeOf(expected)) !void {
    if (expected != actual) {
        std.debug.print("FAIL: expected {any}, got {any}\n", .{ expected, actual });
        return error.TestFailed;
    }
}

test "deque initialization" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try expectEqual(@as(usize, 0), deque.len());
    try expectEqual(true, deque.isEmpty());
    try expectEqual(@as(?i32, null), deque.peekFront());
    try expectEqual(@as(?i32, null), deque.peekBack());
}

test "pushBack basic" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try deque.pushBack(1);
    try deque.pushBack(2);
    try deque.pushBack(3);

    try expectEqual(@as(usize, 3), deque.len());
    try expectEqual(@as(?i32, 1), deque.get(0));
    try expectEqual(@as(?i32, 2), deque.get(1));
    try expectEqual(@as(?i32, 3), deque.get(2));
}

test "pushFront basic" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try deque.pushFront(1);
    try deque.pushFront(2);
    try deque.pushFront(3);

    try expectEqual(@as(usize, 3), deque.len());
    try expectEqual(@as(?i32, 3), deque.get(0));
    try expectEqual(@as(?i32, 2), deque.get(1));
    try expectEqual(@as(?i32, 1), deque.get(2));
}

test "popBack basic" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try deque.pushBack(1);
    try deque.pushBack(2);
    try deque.pushBack(3);

    try expectEqual(@as(?i32, 3), deque.popBack());
    try expectEqual(@as(?i32, 2), deque.popBack());
    try expectEqual(@as(usize, 1), deque.len());
    try expectEqual(@as(?i32, 1), deque.popBack());
    try expectEqual(@as(?i32, null), deque.popBack());
}

test "popFront basic" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try deque.pushBack(1);
    try deque.pushBack(2);
    try deque.pushBack(3);

    try expectEqual(@as(?i32, 1), deque.popFront());
    try expectEqual(@as(?i32, 2), deque.popFront());
    try expectEqual(@as(usize, 1), deque.len());
    try expectEqual(@as(?i32, 3), deque.popFront());
    try expectEqual(@as(?i32, null), deque.popFront());
}

test "peek operations" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try deque.pushBack(1);
    try deque.pushBack(2);
    try deque.pushBack(3);

    try expectEqual(@as(?i32, 1), deque.peekFront());
    try expectEqual(@as(?i32, 3), deque.peekBack());
    try expectEqual(@as(usize, 3), deque.len()); // Peek shouldn't modify
}

test "mixed push operations" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try deque.pushBack(2);
    try deque.pushFront(1);
    try deque.pushBack(3);
    try deque.pushFront(0);

    try expectEqual(@as(usize, 4), deque.len());
    try expectEqual(@as(?i32, 0), deque.get(0));
    try expectEqual(@as(?i32, 1), deque.get(1));
    try expectEqual(@as(?i32, 2), deque.get(2));
    try expectEqual(@as(?i32, 3), deque.get(3));
}

test "dynamic growth" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    // Initial capacity is 8, push more to trigger growth
    var i: i32 = 0;
    while (i < 20) : (i += 1) {
        try deque.pushBack(i);
    }

    try expectEqual(@as(usize, 20), deque.len());
    try std.testing.expect(deque.capacity() >= 20);

    // Verify all elements are intact
    i = 0;
    while (i < 20) : (i += 1) {
        try expectEqual(@as(?i32, i), deque.get(@intCast(i)));
    }
}

test "growth with pushFront" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    var i: i32 = 0;
    while (i < 20) : (i += 1) {
        try deque.pushFront(i);
    }

    try expectEqual(@as(usize, 20), deque.len());

    // Elements should be in reverse order
    i = 19;
    var idx: usize = 0;
    while (idx < 20) : (idx += 1) {
        try expectEqual(@as(?i32, i), deque.get(idx));
        i -= 1;
    }
}

test "wraparound behavior" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    // Fill and drain to create wraparound
    try deque.pushBack(1);
    try deque.pushBack(2);
    try deque.pushBack(3);
    try deque.pushBack(4);

    _ = deque.popFront();
    _ = deque.popFront();

    try deque.pushBack(5);
    try deque.pushBack(6);

    try expectEqual(@as(usize, 4), deque.len());
    try expectEqual(@as(?i32, 3), deque.get(0));
    try expectEqual(@as(?i32, 4), deque.get(1));
    try expectEqual(@as(?i32, 5), deque.get(2));
    try expectEqual(@as(?i32, 6), deque.get(3));
}

test "clear operation" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try deque.pushBack(1);
    try deque.pushBack(2);
    try deque.pushBack(3);

    deque.clear();

    try expectEqual(@as(usize, 0), deque.len());
    try expectEqual(true, deque.isEmpty());
    try expectEqual(@as(?i32, null), deque.peekFront());
}

test "random access out of bounds" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try deque.pushBack(1);
    try deque.pushBack(2);

    try expectEqual(@as(?i32, null), deque.get(5));
    try expectEqual(@as(?i32, null), deque.get(100));
}

test "alternating operations" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    try deque.pushBack(1);
    try expectEqual(@as(?i32, 1), deque.popFront());

    try deque.pushFront(2);
    try expectEqual(@as(?i32, 2), deque.popBack());

    try deque.pushBack(3);
    try deque.pushFront(4);
    try expectEqual(@as(?i32, 4), deque.popFront());
    try expectEqual(@as(?i32, 3), deque.popBack());

    try expectEqual(true, deque.isEmpty());
}

test "stress test - many operations" {
    const allocator = std.testing.allocator;
    var deque = try Deque(i32).init(allocator);
    defer deque.deinit();

    // Push 100 items
    var i: i32 = 0;
    while (i < 100) : (i += 1) {
        if (@mod(i, 2) == 0) {
            try deque.pushBack(i);
        } else {
            try deque.pushFront(i);
        }
    }

    try expectEqual(@as(usize, 100), deque.len());

    // Pop 50 items
    i = 0;
    while (i < 50) : (i += 1) {
        if (@mod(i, 1) == 0) {
            _ = deque.popFront();
        } else {
            _ = deque.popBack();
        }
    }

    try expectEqual(@as(usize, 50), deque.len());
}

test "type safety - different types" {
    const allocator = std.testing.allocator;

    // Test with strings
    var str_deque = try Deque([]const u8).init(allocator);
    defer str_deque.deinit();

    try str_deque.pushBack("hello");
    try str_deque.pushBack("world");

    try expectEqual(@as(usize, 2), str_deque.len());
}
