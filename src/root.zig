//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
//const expect = std.testing.expect;

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

test "use vector splat" {
    const scalar: u32 = 5;
    const result: @Vector(4, u32) = @splat(scalar);
    const a: @Vector(4, u32) = .{ 5, 5, 5, 5 };
    try std.testing.expect(@reduce(.And, result == a));
}

test "use vector shuffle" {
    const a = @Vector(7, u8){ 'o', 'l', 'h', 'e', 'r', 'z', 'w' };
    const b = @Vector(4, u8){ 'w', 'd', '!', 'x' };

    const mask1 = @Vector(5, i32){ 2, 3, 1, 1, 0 };
    const res1: @Vector(5, u8) = @shuffle(u8, a, undefined, mask1);
    // res1 的值是 hello
    const c = @Vector(5, i32){ 'h', 'e', 'l', 'l', 'o' };
    try std.testing.expect(@reduce(.And, res1 == c));
    // Combining two vectors
    const mask2 = @Vector(6, i32){ -1, 0, 4, 1, -2, -3 };
    const res2: @Vector(6, u8) = @shuffle(u8, a, b, mask2);
    // res2 的值是 world!
    const d = @Vector(6, i32){ 'w', 'o', 'r', 'l', 'd', '!' };

    try std.testing.expect(@reduce(.And, res2 == d));
}

test "use vector select" {
    const ele_4 = @Vector(4, i32);

    // 向量必须拥有编译期已知的长度和类型
    const a = ele_4{ 1, 2, 3, 4 };
    const b = ele_4{ 5, 6, 7, 8 };

    const pred = @Vector(4, bool){
        true,
        false,
        false,
        true,
    };

    const c = @select(i32, pred, a, b);
    const res = @Vector(4, i32){ 1, 6, 7, 4 };
    try std.testing.expect(@reduce(.And, c == res));
}

test "test defer1" {
    var x: i16 = 5;
    {
        defer x += 2; // defer是在退出当前代码块时才执行，类比Go中的defer
        try expect(x == 5);
    } // defer x+= 2在这个位置执行,准确说应该是在这个{之前，上面的try之后
    try expect(x == 7);
}

test "test multi defer" {
    var x: f32 = 5;
    {
        defer x += 2; // 然后执行这个
        defer x /= 2; // 先执行这个
    } // 多个defer语句执行顺序是按照栈的出栈顺序来的
    try expect(x == 4.5);
}

fn increment(num: *u8) void {
    num.* += 1;
}

test "test pointers" {
    var x: u8 = 1;
    increment(&x);
    try expect(x == 2);
}

const expect = @import("std").testing.expect;

fn doubleAllManypointer(buffer: [*]u8, byte_count: usize) void {
    var i: usize = 0;
    while (i < byte_count) : (i += 1) buffer[i] *= 2;
}

test "many-item pointers" {
    var buffer: [100]u8 = [_]u8{1} ** 100;
    const buffer_ptr: *[100]u8 = &buffer;

    const buffer_many_ptr = buffer_ptr;
    doubleAllManypointer(buffer_many_ptr, buffer.len);
    for (buffer) |byte| try expect(byte == 2);

    const first_elem_ptr: *u8 = &buffer_many_ptr[0];
    const first_elem_ptr_2: *u8 = @ptrCast(buffer_many_ptr);
    try expect(first_elem_ptr == first_elem_ptr_2);
}

fn sum(values: []const u8) usize {
    var s: usize = 0;
    for (values) |v| s += v;
    return s;
}

test "slice1" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    try expect(sum(slice) == 6);
}

test "slice 2" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    try expect(*const [3]u8 == @TypeOf(slice));
}

fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

test "comptime blocks" {
    const x = comptime fibonacci(10);
    const y = comptime blk: {
        break :blk fibonacci(10);
    };
    try expect(y == 55);
    try expect(x == y);
}
