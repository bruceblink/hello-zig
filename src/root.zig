//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.fs.File.stdout().deprecatedWriter();
    // Buffering can improve performance significantly in print-heavy programs.
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // Don't forget to flush!
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn read_file(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    return try file.readToEndAlloc(allocator, std.math.maxInt(usize));
}

fn add2(x: *u32) void {
    const d: u32 = 2;
    x.* = x.* + d;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}

test "array length" {
    const string_object = "This is an example of string literal in Zig";
    try std.testing.expect(string_object.len == 43);
}

test "use point" {
    var x: u32 = 4;
    add2(&x);
    try std.testing.expect(x == 6);
}

test "anonymous struct literals" {
    const user = @import("user.zig");

    const eu = user.User{ .id = 1, .name = "Pedro", .email = "someemail@gmail.com" };
    try std.testing.expect(std.mem.eql(u8, eu.name, "Pedro"));
    try std.testing.expect(std.mem.eql(u8, eu.email, "someemail@gmail.com"));
}

test "type casting" {
    const x: usize = 500;
    const y = @as(u32, x);
    try std.testing.expect(@TypeOf(y) == u32);
    const z: f32 = @floatFromInt(x);
    try std.testing.expect(@TypeOf(z) == f32);
}

test "use vector" {
    const ele_4 = @Vector(4, i32);
    const a = ele_4{ 1, 2, 3, 4 };
    const b = ele_4{ 5, 6, 7, 8 };
    const c = a + b;
    std.debug.print("Vector c is {any}\n", .{c});
    const d = ele_4{ 6, 8, 10, 12 };
    // c == d 返回的是 @Vector(4, bool)也就是4个true 不能这么断言，要使用下面的方式
    try std.testing.expect(@reduce(.And, c == d));
}

test "destruct vector" {
    const ele_4 = @Vector(4, i32);
    const a = ele_4{ 1, 2, 3, 4 };
    const b, const c, _, _ = a;
    try std.testing.expect(b == 1);
    try std.testing.expect(c == 2);
}

test "use splat" {
    const scalar: u32 = 5;
    const result: @Vector(4, u32) = @splat(scalar);
    const a: @Vector(4, u32) = .{ 5, 5, 5, 5 };
    try std.testing.expect(@reduce(.And, result == a));
}
