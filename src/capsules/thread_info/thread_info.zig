const return_value = @import("../return_value/return_value.zig").return_value;

const kernel_datatype: type = usize;

pub const thread_info = struct {
    thread_return: *return_value,
    thread_id: usize,
    nthreads: usize,
    kernel_begin: kernel_datatype,
    kernel_end: kernel_datatype,

    pub const generator = struct {
        remainder: usize,
        remainder_end: usize,
        perthread: usize,
        nthreads: usize,
        nkernels: usize,
        thread_returns: []return_value,
        pub fn init(nthreads: usize, nkernels: usize, thread_returns: []return_value) thread_info.generator {
            var r: thread_info.generator = .{
                .remainder = @intCast(nkernels % nthreads),
                .remainder_end = undefined,
                .perthread = nkernels / nthreads,
                .nthreads = nthreads,
                .nkernels = nkernels,
                .thread_returns = thread_returns[0..nthreads],
            };
            r.remainder_end = r.remainder * (1 + r.perthread);
            return r;
        }
        pub fn gen(self: thread_info.generator, i: usize) thread_info {
            if (i < self.remainder) {
                const kernel_begin: usize = (1 + self.perthread) * i;
                return .{
                    .thread_return = @ptrCast(self.thread_returns.ptr+i),
                    .thread_id = i,
                    .nthreads = self.nthreads,
                    .kernel_begin = kernel_begin,
                    .kernel_end = kernel_begin + @as(usize, 1) + self.perthread,
                };
            } else {
                const kernel_begin: usize = self.remainder_end + (self.perthread * (i - self.remainder));
                return .{
                    .thread_return = @ptrCast(self.thread_returns.ptr+i),
                    .thread_id = i,
                    .nthreads = self.nthreads,
                    .kernel_begin = kernel_begin,
                    .kernel_end = kernel_begin + self.perthread,
                };
            }
        }
    };
};
