const std = @import("std");

const zul = @import("zul");
pub const Format = zul.Time.Format;

zul_time: zul.Time,

const Time = @This();

pub fn init(hour: u8, min: u8, sec: u8, micros: u32) !Time {
    return .{ .zul_time = try .init(hour, min, sec, micros) };
}

pub fn parse(input: []const u8, fmt: Format) !Time {
    return .{ .zul_time = try .parse(input, fmt) };
}
