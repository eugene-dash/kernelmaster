const std = @import("std");
const testing = std.testing;
//
pub const runtiem_consts = @import("./capsules/runtime_consts/runtime_consts.zig");
pub const error_sets = @import("./capsules/error_sets/error_sets.zig");
pub const return_value = @import("./capsules/return_value/return_value.zig").return_value;
// bellow consts are defined to make it simpler to set a thread's return variable
pub const thread_success = return_value.success;
pub const thread_error = return_value.thread_error;
pub const thread_info = @import("./capsules/thread_info/thread_info.zig").thread_info;
pub const operation = @import("./capsules/operation/operation.zig").operation;
pub const launch = operation.launch;
//
test {
    _ = @import("./capsules/tests/tests.zig");
}
