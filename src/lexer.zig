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

pub fn nextToken(self: *Self) ?Token {
    var token: ?Token = null;

    self.skipWhiteSpace();

    switch (self.ch) {
        0 => {},
        '<' => {
            token = self.newToken(Token.Type.lt);
        },
        '>' => {
            token = self.newToken(Token.Type.gt);
        },
        '/' => {
            token = self.newToken(Token.Type.slash);
        },
        '"' => {
            token = self.newToken(Token.Type.double_quotes);
        },
        '=' => {
            token = self.newToken(Token.Type.equal);
        },
        '?' => {
            token = self.newToken(Token.Type.question_mark);
        },
        '!' => {
            token = self.newToken(Token.Type.bang);
        },
        '-' => {
            token = self.newToken(Token.Type.dash);
        },
        else => {
            if (utils.isLetter(self.ch)) {
                const start: usize = self.position;
                self.takeWord();
                const end: usize = self.read_position;
                token = .{
                    .token_type = Token.Type.word,
                    .literal = self.input[start..end],
                };
            } else {
                token = self.newToken(Token.Type.unknown);
            }
        },
    }

    self.takeChar();
    return token;
}

fn newToken(self: *Self, token_type: Token.Type) Token {
    return .{
        .token_type = token_type,
        .literal = self.input[self.position..self.read_position],
    };
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
    while (utils.isLetter(self.peekChar())) {
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

test "tokenize valid xml" {
    var l: Self = Self.init(
        \\<book>
        \\  <title>Programming in Go</title>
        \\</book>
    );

    const expected_tokens = [_]Token{
        .{ .token_type = Token.Type.lt, .literal = "<" },
        .{ .token_type = Token.Type.word, .literal = "book" },
        .{ .token_type = Token.Type.gt, .literal = ">" },
        .{ .token_type = Token.Type.lt, .literal = "<" },
        .{ .token_type = Token.Type.word, .literal = "title" },
        .{ .token_type = Token.Type.gt, .literal = ">" },
        .{ .token_type = Token.Type.word, .literal = "Programming" },
        .{ .token_type = Token.Type.word, .literal = "in" },
        .{ .token_type = Token.Type.word, .literal = "Go" },
        .{ .token_type = Token.Type.lt, .literal = "<" },
        .{ .token_type = Token.Type.slash, .literal = "/" },
        .{ .token_type = Token.Type.word, .literal = "title" },
        .{ .token_type = Token.Type.gt, .literal = ">" },
        .{ .token_type = Token.Type.lt, .literal = "<" },
        .{ .token_type = Token.Type.slash, .literal = "/" },
        .{ .token_type = Token.Type.word, .literal = "book" },
        .{ .token_type = Token.Type.gt, .literal = ">" },
    };

    var actual_token: ?Token = null;

    try std.testing.expectEqual(0, l.position);
    try std.testing.expectEqual(1, l.read_position);
    for (expected_tokens) |et| {
        actual_token = l.nextToken();
        try std.testing.expect(actual_token != null);
        if (actual_token) |at| {
            try std.testing.expectEqual(et.token_type, at.token_type);
            try std.testing.expectEqualStrings(et.literal, at.literal);
        }
    }

    actual_token = l.nextToken();
    try std.testing.expect(actual_token == null);
    try std.testing.expect(l.position > l.input.len);
    try std.testing.expect(l.read_position > l.input.len);
    try std.testing.expectEqual(0, l.ch);
}

test "self closing elements with attrs" {
    var l: Self = Self.init("<book id=\"b001\" category=\"programming\"/>");

    const expected_tokens = [_]Token{
        .{ .token_type = Token.Type.lt, .literal = "<" },
        .{ .token_type = Token.Type.word, .literal = "book" },
        .{ .token_type = Token.Type.word, .literal = "id" },
        .{ .token_type = Token.Type.equal, .literal = "=" },
        .{ .token_type = Token.Type.double_quotes, .literal = "\"" },
        .{ .token_type = Token.Type.word, .literal = "b001" },
        .{ .token_type = Token.Type.double_quotes, .literal = "\"" },
        .{ .token_type = Token.Type.word, .literal = "category" },
        .{ .token_type = Token.Type.equal, .literal = "=" },
        .{ .token_type = Token.Type.double_quotes, .literal = "\"" },
        .{ .token_type = Token.Type.word, .literal = "programming" },
        .{ .token_type = Token.Type.double_quotes, .literal = "\"" },
        .{ .token_type = Token.Type.slash, .literal = "/" },
        .{ .token_type = Token.Type.gt, .literal = ">" },
    };

    var actual_token: ?Token = null;

    try std.testing.expectEqual(0, l.position);
    try std.testing.expectEqual(1, l.read_position);
    for (expected_tokens) |et| {
        actual_token = l.nextToken();
        try std.testing.expect(actual_token != null);
        if (actual_token) |at| {
            try std.testing.expectEqual(et.token_type, at.token_type);
            try std.testing.expectEqualStrings(et.literal, at.literal);
        }
    }

    actual_token = l.nextToken();
    try std.testing.expect(actual_token == null);
    try std.testing.expect(l.position > l.input.len);
    try std.testing.expect(l.read_position > l.input.len);
    try std.testing.expectEqual(0, l.ch);
}

test "tokenize xml declarations" {
    var l: Self = Self.init("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");

    const expected_tokens = [_]Token{
        .{ .token_type = Token.Type.lt, .literal = "<" },
        .{ .token_type = Token.Type.question_mark, .literal = "?" },
        .{ .token_type = Token.Type.word, .literal = "xml" },
        .{ .token_type = Token.Type.word, .literal = "version" },
        .{ .token_type = Token.Type.equal, .literal = "=" },
        .{ .token_type = Token.Type.double_quotes, .literal = "\"" },
        .{ .token_type = Token.Type.word, .literal = "1.0" },
        .{ .token_type = Token.Type.double_quotes, .literal = "\"" },
        .{ .token_type = Token.Type.word, .literal = "encoding" },
        .{ .token_type = Token.Type.equal, .literal = "=" },
        .{ .token_type = Token.Type.double_quotes, .literal = "\"" },
        .{ .token_type = Token.Type.word, .literal = "UTF-8" },
        .{ .token_type = Token.Type.double_quotes, .literal = "\"" },
        .{ .token_type = Token.Type.question_mark, .literal = "?" },
        .{ .token_type = Token.Type.gt, .literal = ">" },
    };

    var actual_token: ?Token = null;

    try std.testing.expectEqual(0, l.position);
    try std.testing.expectEqual(1, l.read_position);
    for (expected_tokens) |et| {
        actual_token = l.nextToken();
        try std.testing.expect(actual_token != null);
        if (actual_token) |at| {
            try std.testing.expectEqual(et.token_type, at.token_type);
            try std.testing.expectEqualStrings(et.literal, at.literal);
        }
    }

    actual_token = l.nextToken();
    try std.testing.expect(actual_token == null);
    try std.testing.expect(l.position > l.input.len);
    try std.testing.expect(l.read_position > l.input.len);
    try std.testing.expectEqual(0, l.ch);
}

test "tokenize comments" {
    var l: Self = Self.init("<!-- comment -->");

    const expected_tokens = [_]Token{
        .{ .token_type = Token.Type.lt, .literal = "<" },
        .{ .token_type = Token.Type.bang, .literal = "!" },
        .{ .token_type = Token.Type.dash, .literal = "-" },
        .{ .token_type = Token.Type.dash, .literal = "-" },
        .{ .token_type = Token.Type.word, .literal = "comment" },
        .{ .token_type = Token.Type.dash, .literal = "-" },
        .{ .token_type = Token.Type.dash, .literal = "-" },
        .{ .token_type = Token.Type.gt, .literal = ">" },
    };

    var actual_token: ?Token = null;

    try std.testing.expectEqual(0, l.position);
    try std.testing.expectEqual(1, l.read_position);
    for (expected_tokens) |et| {
        actual_token = l.nextToken();
        try std.testing.expect(actual_token != null);
        if (actual_token) |at| {
            try std.testing.expectEqual(et.token_type, at.token_type);
            try std.testing.expectEqualStrings(et.literal, at.literal);
        }
    }

    actual_token = l.nextToken();
    try std.testing.expect(actual_token == null);
    try std.testing.expect(l.position > l.input.len);
    try std.testing.expect(l.read_position > l.input.len);
    try std.testing.expectEqual(0, l.ch);
}
