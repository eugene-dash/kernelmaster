const std = @import("std");
const return_value = @import("../return_value/return_value.zig").return_value;
const thread_info = @import("../thread_info/thread_info.zig").thread_info;
const error_sets = @import("../error_sets/error_sets.zig");

pub const operation = struct {
    thread: std.Thread,
    result: *return_value,
    allocator: std.mem.Allocator,

    fn primary_thread(allocator: std.mem.Allocator, result: *return_value,nthreads: usize, nkernels: u128, comptime kernel: anytype, args: anytype) void {
        result.* = return_value.success;
        if (nthreads == 0) {
            result.* = return_value.internal_error;
            return;
        }
        const threads =
            allocator.alloc(std.Thread, nthreads)
                catch {
                    result.* = return_value.internal_error;
                    return;
                };
        defer allocator.free(threads);
        const thread_returns =
            allocator.alloc(return_value, nthreads)
                catch {
                    result.* = return_value.internal_error;
                    return;
                };
        defer allocator.free(thread_returns);

        const thread_info_gen = thread_info.generator.init(nthreads, nkernels, thread_returns);
        for (0.., thread_returns, threads) |nthreads_launched, *this_thread_return, *this_thread| {
            this_thread_return.* = return_value.success;
            this_thread.* =
                std.Thread.spawn(.{}, kernel, .{thread_info_gen.gen(nthreads_launched)} ++ args)
                    catch {
                        for (threads[0..nthreads_launched]) |thread| {
                            thread.join();
                        }
                        result.* = return_value.internal_error;
                        return;
                    };
        }

        for (0.., thread_returns, threads) |i, thread_returned, thread| {
            thread.join();
            if (thread_returned != return_value.success) {
                result.* = return_value.thread_error;
                for (threads[i..]) |thread_quickjoin| {
                    thread_quickjoin.join();
                }
                return;
            }
        }
        return;
    }
    pub fn launch(allocator: std.mem.Allocator, nthreads: usize, nkernels: u128, comptime kernel: anytype, args: anytype) error_sets.kernelmaster_error!operation {
        const result: *return_value = allocator.create(return_value) catch return error.kernelmaster_internal_error;
        errdefer allocator.destroy(result);
        return .{
            .thread = std.Thread.spawn(
                .{},
                primary_thread,
                .{
                    allocator,
                    result,
                    nthreads,
                    nkernels,
                    kernel,
                    args,
                }
            ) catch return error.kernelmaster_internal_error,
            .result = result,
            .allocator = allocator,
        };
    }
    pub fn sync(op: operation) !void {
        std.Thread.join(op.thread);
        const r: return_value = op.result.*;
        op.allocator.destroy(op.result);
        switch (r) {
            return_value.success => return,
            return_value.thread_error => return error.kernelmaster_thread_error,
            else => return error.kernelmaster_internal_error,
        }
    }
};
