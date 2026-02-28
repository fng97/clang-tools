const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{}).result;

    const dep_name = switch (target.os.tag) {
        .linux => switch (target.cpu.arch) {
            .x86_64 => "clang_format_x86_64_linux",
            .aarch64 => "clang_format_aarch64_linux",
            else => unsupported(target),
        },
        .macos => switch (target.cpu.arch) {
            .aarch64 => "clang_format_aarch64_macos",
            else => unsupported(target),
        },
        .windows => switch (target.cpu.arch) {
            .x86_64 => "clang_format_x86_64_windows",
            .aarch64 => "clang_format_aarch64_windows",
            else => unsupported(target),
        },
        else => unsupported(target),
    };

    if (b.lazyDependency(dep_name, .{})) |d| {
        const bin_name = if (target.os.tag == .windows) "bin/clang-format.exe" else "bin/clang-format";
        b.addNamedLazyPath("clang-format", d.path(bin_name));
    }
}

fn unsupported(target: std.Target) noreturn {
    std.debug.panic("unsupported clang-format target: {s}-{s}", .{
        @tagName(target.cpu.arch),
        @tagName(target.os.tag),
    });
}
