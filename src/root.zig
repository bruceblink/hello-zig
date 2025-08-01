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

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}

test "array length" {
    const string_object = "This is an example of string literal in Zig";
    try std.testing.expect(string_object.len == 43);
}
