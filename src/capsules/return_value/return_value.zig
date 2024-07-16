pub const return_value = enum(u8) {
    success = 0,
    internal_error = 15,
    thread_error = 255,
};
