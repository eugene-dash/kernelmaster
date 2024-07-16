const std = @import("std");
const testing = std.testing;
const kernelmaster = @import("../../kernelmaster.zig");

fn internal_test_kernel(ti: kernelmaster.thread_info, a: []usize) void {
    for (@intCast(ti.kernel_begin)..@intCast(ti.kernel_end)) |k| {
        a[k] = k;
    }
}
test "basic kernel functionality" {
    const allocator = std.heap.c_allocator;
    const nkernels: usize = 12_000;
    const array: []usize = try allocator.alloc(usize, nkernels);
    defer allocator.free(array);
    for (array) |*item| {
        item.* = 0;
    }
    const op = try kernelmaster.operation.launch(allocator, 10, nkernels, internal_test_kernel, .{array});
    try op.sync();
    for (0.., array) |index, item| {
        try testing.expect(index == item);
    }
}
