const std = @import("std");

test "use memory pool" {
    var pool = std.heap.MemoryPool(u32).init(std.heap.page_allocator);
    defer pool.deinit();

    // 连续申请三个对象
    const p1 = try pool.create();
    const p2 = try pool.create();
    const p3 = try pool.create();

    // 回收p2
    pool.destroy(p2);
    // 再申请一个新的对象
    const p4 = try pool.create();
    // 注意，此时p2和p4指向同一块内存, 因为pool直接复用了刚才destroy的p2对象
    //这里有一个问题值得深思，为什么p2被destroy了还能用来运算比较
    try std.testing.expect(p2 == p4);
    _ = p1;
    _ = p3;
}

test "MemoryPool uninitialized vs initialized" {
    var pool = std.heap.MemoryPool(u32).init(std.heap.page_allocator);
    defer pool.deinit();

    // 分配 p1 和 p2
    const p1 = try pool.create();
    const p2 = try pool.create();

    // 给 p2 一个确定的值
    p2.* = 42;

    // 分配 p3（为了和 p2 中间隔一点）
    const p3 = try pool.create();

    // 释放 p2
    pool.destroy(p2);

    // 再申请一块（会复用 p2 的地址）
    const p4 = try pool.create();
    std.debug.print("\np2 地址: {p}\n", .{p2}); // u32@1ed44e70018 当然每台机器上运行的结果都不同
    std.debug.print("\np2 当前值(未初始化): {}\n", .{p2.*}); // 2863311530 当然每台机器上运行的结果都不同
    std.debug.print("\np4 地址: {p}\n", .{p4}); // u32@1ed44e70018 当然每台机器上运行的结果都不同
    std.debug.print("p4 当前值(未初始化): {}\n", .{p4.*}); //2863311530  一个随机值，同样每台机器上也不相同

    // 初始化 p4
    p4.* = 99;
    try std.testing.expect(p4.* == 99);
    try std.testing.expect(p2.* == 99);
    try std.testing.expect(p2.* != 42);

    _ = p1;
    _ = p3;
}
