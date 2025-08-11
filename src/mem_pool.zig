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
