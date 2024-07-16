pub const return_value = enum(u8) {
    success = 0,
    thread_error = 3,
    invalid_options = 15,
    internal_error = 255,
};
