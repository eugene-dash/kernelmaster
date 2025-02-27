const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    //
    const kernelmaster_zig = b.addModule("kernelmaster", .{
        .root_source_file = b.path("./src/kernelmaster.zig"),
    });
    //
    const exe = b.addExecutable(.{
        .name = "kernelmaster",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    exe.root_module.addImport("kernelmaster", kernelmaster_zig);
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    //
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_unit_tests.linkLibC();
    exe_unit_tests.root_module.addImport("kernelmaster", kernelmaster_zig);
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    run_exe_unit_tests.has_side_effects = true;
    //
    const kernelmaster_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/kernelmaster.zig"),
        .target = target,
        .optimize = optimize,
    });
    kernelmaster_unit_tests.linkLibC();
    const run_kernelmaster_unit_tests = b.addRunArtifact(kernelmaster_unit_tests);
    run_kernelmaster_unit_tests.has_side_effects = true;

    //
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
    test_step.dependOn(&run_kernelmaster_unit_tests.step);
}
