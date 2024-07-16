const std = @import("std");
const kernelmaster = @import("kernelmaster");

fn example_kernel(thread_info: kernelmaster.thread_info, comptime debug: bool) void {
    std.time.sleep(1_000_000_00 * @as(u64, thread_info.thread_id));
    if (!debug)
        return;
    std.debug.print("_ {}_id :: {} --> {}\n", .{thread_info.thread_id, thread_info.kernel_begin, thread_info.kernel_end});
    var k: u128 = thread_info.kernel_begin;
    while (k < thread_info.kernel_end) : (k += 1) {
        std.debug.print("|-{}\n", .{k});
    }
    std.debug.print("^\n", .{});
    return;
}

fn kernelmaster_example(comptime debug: bool) !void {
    const op = try kernelmaster.operation.launch(std.heap.c_allocator, 7, 12, example_kernel, .{debug});
    try op.sync();
    return;
}
test "basic kernelmaster functionality" {
    try kernelmaster_example(false);
}

pub fn main() void {
    kernelmaster_example(true) catch return;
    return;
}
