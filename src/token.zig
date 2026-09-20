const std = @import("std");

pub const Type = enum(u8) {
    start_element,
    end_element,
    value,
    double_quotes,
    gt,
    bang,
    dash,
    question_mark,
    equal,
    left_bracket,
    right_bracket,
    text,
    unknown,
};

token_type: Type,
literal: []const u8,

const Self = @This();

pub fn format(self: *const Self, writer: *std.Io.Writer) !void {
    try writer.print("{{ type: {any}, literal: {s} }}", .{ self.token_type, self.literal });
}
