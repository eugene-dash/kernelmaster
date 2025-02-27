const std = @import("std");
const kernelmaster = @import("kernelmaster");

fn example_kernel(thread_info: kernelmaster.thread_info, comptime debug: bool) void {
    std.time.sleep(1_000_000_00 * @as(u64, thread_info.thread_id));
    if (!debug)
        return;
    std.debug.print("_ {}_id :: {} --> {}\n", .{ thread_info.thread_id, thread_info.kernel_begin, thread_info.kernel_end });
    for (thread_info.kernel_begin..thread_info.kernel_end) |k| {
        std.debug.print("|-{}\n", .{k});
    }
    std.debug.print("^\n", .{});
    return;
}

fn kernelmaster_example(comptime debug: bool) !void {
    var op = try kernelmaster.operation.launch(std.heap.c_allocator, .{
        .nthreads = 7,
    }, 12, example_kernel, .{debug});
    try op.sync();
    std.debug.print(">>break<<\n", .{});
    op = try kernelmaster.operation.launch(std.heap.c_allocator, .{
        .nthreads = 124,
    }, 2, example_kernel, .{debug});
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
