const std = @import("std");

pub const Type = enum(u8) {
    lt,
    gt,
    double_quotes,
    slash,
    bang,
    dash,
    question_mark,
    equal,
    left_bracket,
    right_bracket,
    word,
    unknown,
};

token_type: Type,
literal: []const u8,

const Self = @This();

pub fn format(self: *const Self, writer: *std.Io.Writer) !void {
    try writer.print("{{ type: {any}, literal: {s} }}", .{ self.token_type, self.literal });
}
