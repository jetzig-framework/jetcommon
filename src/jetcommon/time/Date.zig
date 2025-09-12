const std = @import("std");
const Writer = std.Io.Writer;

const zul = @import("zul");

zul_date: zul.Date,

const Date = @This();

const Format = enum { rfc3339, iso8601 };

pub fn init(year: i16, month: u8, day: u8) !Date {
    const zul_date = try zul.Date.init(year, month, day);
    return .{ .zul_date = zul_date };
}

pub fn parse(input: []const u8, fmt: Format) !Date {
    return switch (fmt) {
        .rfc3339 => .{ .zul_date = try zul.Date.parse(input, .rfc3339) },
        .iso8601 => .{ .zul_date = try zul.Date.parse(input, .iso8601) },
    };
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
