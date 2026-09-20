pub fn isLetter(ch: u8) bool {
    return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or (ch == '-') or (ch == '_') or (ch >= '0' and ch <= '9') or (ch == '.');
}
