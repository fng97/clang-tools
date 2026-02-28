# Clang Tools

[`clang-format`](https://clang.llvm.org/docs/ClangFormat.html) binaries built from LLVM 20.1.0 via
[GitHub Actions](https://github.com/fng97/clang-tools/actions/workflows/build.yml), packaged for the
[Zig](https://ziglang.org/) build system.

Inspired by
[muttleyxd/clang-tools-static-binaries](https://github.com/muttleyxd/clang-tools-static-binaries).
Their release artefacts are binaries, not archives, so the Zig build system can't fetch them.

Supported platforms: Linux (x86_64, aarch64), macOS (aarch64), Windows (x86_64, aarch64).

## How to use it

Add this repo as a dependency:

```
zig fetch --save=clang_tools git+https://github.com/fng97/clang-tools
```

You can then access the packaged binaries in your `build.zig` like this (passing `b.graph.host` as
the target since `clang-format` runs on the build machine):

```zig
const fmt_step = b.step("fmt", "Format C/C++ files with clang-format");

const clang_tools_dep =
    b.lazyDependency("clang_tools", .{ .target = b.graph.host }) orelse return;

const git_ls_cmd = b.addSystemCommand(&.{ "git", "ls-files", "*.[ch]pp", "*.[ch]" });
const files_list = git_ls_cmd.captureStdOut();
const clang_format_cmd = std.Build.Step.Run.create(b, "clang-format");
const clang_format_bin =
    clang_tools_dep.builder.named_lazy_paths.get("clang-format") orelse return;
clang_format_cmd.addFileArg(clang_format_bin);
clang_format_cmd.addArg("-i");
clang_format_cmd.addPrefixedFileArg("--files=", files_list);
fmt_step.dependOn(&clang_format_cmd.step);
```
