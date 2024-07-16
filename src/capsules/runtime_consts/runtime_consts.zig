const std = @import("std");

pub const ncpus_default: usize = 4;
var ncpus: usize = undefined;
var ncpus_set: bool = false;
pub fn get_ncpus() usize {
    if (ncpus_set)
        return ncpus;
    ncpus =
        std.Thread.getCpuCount()
            catch {
                ncpus_set = true;
                ncpus = ncpus_default;
                return ncpus;
            };
    if (ncpus == 0) {
        ncpus = ncpus_default;
    }
    ncpus_set = true;
    return ncpus;
}
