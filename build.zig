const std = @import("std");
const zbh = @import("zbh");

pub fn build(b: *std.Build) !void {
    const upstream = b.dependency("upstream", .{});
    const target = b.option([]const u8, "target", "");

    _ = try zbh.lib(b, .{
        .name = "cJSON",
        .target = target,
        .files = .{
            .root = upstream.path(""),
            .files = &.{
                "cJSON.c",
            },
        },
    });

    _ = try zbh.lib(b, .{
        .name = "cJSON_utils",
        .target = target,
        .files = .{
            .root = upstream.path(""),
            .files = &.{
                "cJSON_utils.c",
            },
        },
    });
}
