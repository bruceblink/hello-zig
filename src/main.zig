const std = @import("std");
const hello_world = @import("hello_world");
const user = @import("user.zig");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    //std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    //try hello_world.bufferedPrint();
    const a = [_]u8{ 1, 2, 3 };
    const b = [_]u8{ 4, 5 };
    const d = b ++ a;
    std.debug.print("{any}\n", .{a ++ b}); // { 1, 2, 3, 4, 5 }
    std.debug.print("{any}\n", .{d}); // { 4, 5, 1, 2, 3 }
    const ns = [4]u8{ 48, 24, 12, 6 };
    const sl = ns[1..3];
    std.debug.print("{any}\n", .{sl}); // { 24, 12 }
    const s2 = ns[1..];
    std.debug.print("{any}\n", .{s2}); // {24, 12, 6}
    const s3 = ns ** 2;
    std.debug.print("{any}\n", .{s3}); // { 48, 24, 12, 6, 48, 24, 12, 6 }

    // read file
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const path = "file-io/test-list.txt";
    const file_contents = try hello_world.read_file(allocator, path);

    std.debug.print("{s}\n", .{file_contents});
    const u: user.User = user.User.init(1, "pedro", "email@gmail.com");
    try u.print_name();
}
