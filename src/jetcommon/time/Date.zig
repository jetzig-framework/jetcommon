const std = @import("std");
const Writer = std.Io.Writer;

const zul = @import("zul");
const Format = zul.Date.Format;

zul_date: zul.Date,

const Date = @This();

pub fn init(year: i16, month: u8, day: u8) !Date {
    return .{ .zul_date = try .init(year, month, day) };
}

pub fn parse(input: []const u8, fmt: Format) !Date {
    return .{ .zul_date = try .parse(input, fmt) };
}

pub fn format(
    self: Date,
    writer: *Writer,
) !void {
    try self.zul_date.format(writer);
}

test {
    _ = try Date.init(2024, 9, 24);
}
