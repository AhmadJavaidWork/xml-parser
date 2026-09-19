const std = @import("std");

pub const Type = enum(u8) {
    lt,
    gt,
    slash,
    bang,
    dash,
    question_mark,
    equal,
    left_bracket,
    right_bracket,
    unknown,
};

token_type: Type,
literal: []const u8,

const Self = @This();

pub fn format(self: *const Self, writer: *std.Io.Writer) !void {
    try writer.print("{{ type: {any}, literal: {s} }}", .{ self.token_type, self.literal });
}
