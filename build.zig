const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib = b.addLibrary(.{
        .name = "jetcommon",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/jetcommon.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const jetcommon_module = b.addModule("jetcommon", .{
        .root_source_file = b.path("src/jetcommon.zig"),
    });

    const zul_module = b.dependency("zul", .{
        .target = target,
        .optimize = optimize,
    }).module("zul");

    jetcommon_module.addImport("zul", zul_module);
    lib.root_module.addImport("zul", zul_module);

    b.installArtifact(lib);
    const lib_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/jetcommon.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    lib_unit_tests.root_module.addImport("zul", zul_module);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
