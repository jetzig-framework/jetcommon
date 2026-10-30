/// Common types used in various libraries within the Jetzig Web Framework.
const std = @import("std");

pub const types = @import("jetcommon/types.zig");
pub const fmt = @import("jetcommon/fmt.zig");

pub const DateTime = types.DateTime;
pub const Time = types.Time;
pub const Date = types.Date;
pub const Operator = enum { equal, less_than, greater_than, less_or_equal, greater_or_equal };

test {
    _ = @import("jetcommon/time/Date.zig");
    _ = @import("jetcommon/time/DateTime.zig");
}
