const std = @import("std");

const optimize_matrix: []const std.builtin.OptimizeMode = &.{
    .Debug,
    .ReleaseSmall,
};

const targets_matrix: []const std.Target.Query = &.{
    .{ .cpu_arch = .x86_64, .os_tag = .windows, .abi = .msvc },
    .{ .cpu_arch = .aarch64, .os_tag = .windows, .abi = .gnu },

    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .gnu },

    .{ .cpu_arch = .x86_64, .os_tag = .macos },
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
};

fn lib(
    b: *std.Build,
    target_opt: []const u8,
    target: std.Target.Query,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
    macros: []const struct { []const u8, []const u8 },
    includes: []const std.Build.LazyPath,
    files: []const struct { std.Build.LazyPath, []const []const u8 },
) !void {
    const triple = target.zigTriple(b.allocator) catch "";

    const module = b.createModule(.{
        .target = b.resolveTargetQuery(target),
        .optimize = optimize,
        .sanitize_c = .off,
        .stack_check = false,
        .stack_protector = false,
        .single_threaded = true,
    });

    module.linkSystemLibrary("c", .{});

    for (macros) |m| {
        module.addCMacro(m[0], m[1]);
    }

    for (includes) |i| {
        module.addIncludePath(i);
    }

    for (files) |f| {
        module.addCSourceFiles(.{
            .root = f[0],
            .files = f[1],
        });
    }

    const library_name = switch (optimize) {
        .Debug => try std.fmt.allocPrint(b.allocator, "{s}_d", .{name}),
        else => name,
    };

    const library = b.addLibrary(.{
        .name = library_name,
        .linkage = .static,
        .root_module = module,
    });

    const target_output = b.addInstallArtifact(library, .{
        .dest_dir = .{
            .override = .{
                .custom = triple,
            },
        },
    });

    if (std.mem.eql(u8, target_opt, "") or std.mem.eql(u8, target_opt, triple)) {
        b.getInstallStep().dependOn(&target_output.step);
    }
}

pub fn build(b: *std.Build) !void {
    const target: []const u8 = b.option([]const u8, "target", "specify target triple") orelse "";
    const upstream = b.dependency("upstream", .{});

    for (optimize_matrix) |o| {
        for (targets_matrix) |t| {
            try lib(
                b,
                target,
                t,
                o,
                "cjson",
                &.{},
                &.{upstream.path("")},
                &.{
                    .{
                        upstream.path(""),
                        &.{
                            "cJSON.c",
                        },
                    },
                },
            );

            try lib(
                b,
                target,
                t,
                o,
                "cjson_utils",
                &.{},
                &.{upstream.path("")},
                &.{
                    .{
                        upstream.path(""),
                        &.{
                            "cJSON_Utils.c",
                        },
                    },
                },
            );
        }
    }
}
