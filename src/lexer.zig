const std = @import("std");
const Token = @import("token.zig");

input: []const u8,
position: usize = 0,
read_position: usize = 0,
ch: u8 = 0,

const Self = @This();

pub fn init(input: []const u8) Self {
    return .{ .input = input };
}

pub fn nextToken(self: *Self) ?Token {
    var token: ?Token = undefined;

    self.readChar();

    switch (self.ch) {
        0 => {
            token = null;
        },
        '<' => {
            token = .{
                .token_type = Token.Type.lt,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '>' => {
            token = .{
                .token_type = Token.Type.gt,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '/' => {
            token = .{
                .token_type = Token.Type.slash,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '!' => {
            token = .{
                .token_type = Token.Type.bang,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '-' => {
            token = .{
                .token_type = Token.Type.dash,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '?' => {
            token = .{
                .token_type = Token.Type.question_mark,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '=' => {
            token = .{
                .token_type = Token.Type.equal,
                .literal = self.input[self.position..self.read_position],
            };
        },
        '[' => {
            token = .{
                .token_type = Token.Type.left_bracket,
                .literal = self.input[self.position..self.read_position],
            };
        },
        ']' => {
            token = .{
                .token_type = Token.Type.right_bracket,
                .literal = self.input[self.position..self.read_position],
            };
        },

        else => {
            token = .{
                .token_type = Token.Type.unknown,
                .literal = self.input[self.position..self.read_position],
            };
        },
    }

    return token;
}

fn skipWhiteSpace(self: *Self) void {
    while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
        self.readChar();
    }
}

fn readChar(self: *Self) void {
    if (self.read_position == self.input.len) {
        self.ch = 0;
    } else {
        self.skipWhiteSpace();
        self.ch = self.input[self.read_position];
        self.position = self.read_position;
        self.read_position += 1;
    }
}

test "test lexer" {
    var l: Self = Self.init("<>!=?[]-$");

    try std.testing.expectEqual(0, l.position);
    try std.testing.expectEqual(0, l.read_position);
    try std.testing.expectEqual(0, l.ch);

    var token: ?Token = l.nextToken();

    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.lt, t.token_type);
        try std.testing.expectEqualStrings("<", t.literal);
    }

    token = l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.gt, t.token_type);
        try std.testing.expectEqualStrings(">", t.literal);
    }

    token = l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.bang, t.token_type);
        try std.testing.expectEqualStrings("!", t.literal);
    }

    token = l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.equal, t.token_type);
        try std.testing.expectEqualStrings("=", t.literal);
    }

    token = l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.question_mark, t.token_type);
        try std.testing.expectEqualStrings("?", t.literal);
    }

    token = l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.left_bracket, t.token_type);
        try std.testing.expectEqualStrings("[", t.literal);
    }

    token = l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.right_bracket, t.token_type);
        try std.testing.expectEqualStrings("]", t.literal);
    }

    token = l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.dash, t.token_type);
        try std.testing.expectEqualStrings("-", t.literal);
    }

    token = l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.unknown, t.token_type);
        try std.testing.expectEqualStrings("$", t.literal);
    }

    token = l.nextToken();
    try std.testing.expect(token == null);
    try std.testing.expectEqual(l.input.len - 1, l.position);
    try std.testing.expectEqual(l.input.len, l.read_position);
    try std.testing.expectEqual(0, l.ch);
}
