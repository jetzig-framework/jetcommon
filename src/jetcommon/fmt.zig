const std = @import("std");
const ArrayList = std.ArrayList;
const Writer = std.Io.Writer;
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const Ast = std.zig.Ast;

/// Parse and format Zig code from `input`. If errors are detected, the generated code is printed
/// to stderr with error information at the lines that failed. If present, `message` is printed
/// at the end of the error output. Caller owns allocated slice.
pub fn zig(
    io: std.Io,
    allocator: Allocator,
    input: []const u8,
    message: ?[]const u8,
) ![]const u8 {
    var arena: ArenaAllocator = .init(allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var fixups: Ast.Render.Fixups = .{};
    defer fixups.deinit(alloc);

    const ast = try Ast.parse(
        alloc,
        try std.mem.concatWithSentinel(alloc, u8, &.{input}, 0),
        .zig,
    );
    if (ast.errors.len > 0) {
        var write_buf: [256]u8 = undefined;
        var stderr_fw = std.Io.File.stderr().writer(io, &write_buf);
        const writer = &stderr_fw.interface;
        const tty: std.Io.Terminal = .{
            .writer = writer,
            .mode = try .detect(io, std.Io.File.stderr(), false, false),
        };

        var it = std.mem.tokenizeScalar(u8, input, '\n');
        var line_number: usize = 1;
        while (it.next()) |line| : (line_number += 1) {
            const maybe_err = for (ast.errors) |err| {
                if (ast.tokenLocation(0, err.token).line == line_number + 1) break err;
            } else null;
            try tty.setColor(if (maybe_err != null) .red else .cyan);
            const error_message = if (maybe_err) |err| blk: {
                var buf_writer: Writer.Allocating = .init(alloc);
                try buf_writer.writer.writeAll(" // ");
                try ast.renderError(err, &buf_writer.writer);
                break :blk try buf_writer.toOwnedSlice();
            } else "";
            try writer.print("{: <4} {s}{s}\n", .{
                line_number,
                line,
                error_message,
            });
        }
        if (message) |msg| {
            try tty.setColor(.yellow);
            try writer.print("\n{s}\n", .{msg});
        }
        try tty.setColor(.reset);
        return error.JetCommonInvalidZigCode;
    }

    var aw: Writer.Allocating = .init(alloc);
    defer aw.deinit();

    try ast.render(alloc, &aw.writer, fixups);
    const output = try aw.toOwnedSlice();
    defer alloc.free(output);
    return allocator.dupe(u8, output);
}
