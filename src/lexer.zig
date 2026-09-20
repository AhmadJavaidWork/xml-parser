const std = @import("std");
const Token = @import("token.zig");
const utils = @import("utils.zig");

input: []const u8,
position: usize = 0,
read_position: usize = 0,
ch: u8 = 0,

const Self = @This();

pub fn init(input: []const u8) Self {
    var l: Self = .{
        .input = input,
    };
    l.takeChar();
    return l;
}

pub fn nextToken(self: *Self) !?Token {
    var token: ?Token = null;

    self.skipWhiteSpace();

    switch (self.ch) {
        0 => {},
        '<' => {
            if (utils.isLetter(self.peekChar())) {
                self.takeChar();
                const start: usize = self.position;
                self.takeElement();
                var end: usize = self.position;
                if (self.peekChar() == '>') {
                    end = self.read_position;
                }
                token = .{
                    .token_type = Token.Type.start_element,
                    .literal = self.input[start..end],
                };
            } else if (self.peekChar() == '/') {
                self.takeChar();
                if (utils.isLetter(self.peekChar())) {
                    self.takeChar();
                    const start: usize = self.position;
                    self.takeDelimiter('>');
                    const end: usize = self.read_position;
                    self.takeChar();
                    token = .{
                        .token_type = Token.Type.end_element,
                        .literal = self.input[start..end],
                    };
                } else {
                    return error.InvalidXml;
                }
            } else {
                return error.InvalidXml;
            }
        },
        '>' => {
            token = .{
                .token_type = Token.Type.gt,
                .literal = ">",
            };
        },
        else => {
            if (utils.isLetter(self.ch)) {
                const start: usize = self.position;
                self.takeDelimiter('<');
                const end: usize = self.read_position;
                token = .{
                    .token_type = Token.Type.text,
                    .literal = self.input[start..end],
                };
            } else {
                token = .{
                    .token_type = Token.Type.unknown,
                    .literal = self.input[self.position..self.read_position],
                };
            }
        },
    }

    self.takeChar();
    return token;
}

fn skipWhiteSpace(self: *Self) void {
    while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
        self.takeChar();
    }
}

fn takeChar(self: *Self) void {
    if (self.read_position >= self.input.len) {
        self.ch = 0;
        self.position = self.read_position;
    } else {
        self.ch = self.input[self.read_position];
    }
    self.position = self.read_position;
    self.read_position += 1;
}

fn takeDelimiter(self: *Self, delimiter: u8) void {
    while (self.peekChar() != delimiter) {
        self.takeChar();
    }
}

fn takeWord(self: *Self) void {
    while (self.ch != ' ' and self.ch != '\t' and self.ch != '\n' and self.ch != '\r' and self.ch != 0 and self.peekChar() != '<') {
        self.takeChar();
    }
}

fn peekChar(self: *Self) u8 {
    if (self.read_position >= self.input.len) {
        return 0;
    } else {
        return self.input[self.read_position];
    }
}

fn takeElement(self: *Self) void {
    while (self.ch != ' ' and self.ch != '\t' and self.ch != '\n' and self.ch != '\r' and self.ch != 0 and self.peekChar() != '>') {
        self.takeChar();
    }
}

test "test tokenize valid xml" {
    var l: Self = Self.init(
        \\<book>
        \\  <title>Hello</title>
        \\</book>
    );

    try std.testing.expectEqual(0, l.position);
    try std.testing.expectEqual(1, l.read_position);

    var token: ?Token = try l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.start_element, t.token_type);
        try std.testing.expectEqualStrings("book", t.literal);
    }

    token = try l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.gt, t.token_type);
        try std.testing.expectEqualStrings(">", t.literal);
    }

    token = try l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.start_element, t.token_type);
        try std.testing.expectEqualStrings("title", t.literal);
    }

    token = try l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.gt, t.token_type);
        try std.testing.expectEqualStrings(">", t.literal);
    }

    token = try l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.text, t.token_type);
        try std.testing.expectEqualStrings("Hello", t.literal);
    }

    token = try l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.end_element, t.token_type);
        try std.testing.expectEqualStrings("title", t.literal);
    }

    token = try l.nextToken();
    try std.testing.expect(token != null);
    if (token) |t| {
        try std.testing.expectEqual(Token.Type.end_element, t.token_type);
        try std.testing.expectEqualStrings("book", t.literal);
    }

    token = try l.nextToken();
    try std.testing.expect(token == null);
    try std.testing.expect(l.position > l.input.len);
    try std.testing.expect(l.read_position > l.input.len);
    try std.testing.expectEqual(0, l.ch);
}
