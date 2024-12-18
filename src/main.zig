const std = @import("std");

const bf_interpreter = struct {
    var dp: u64 = 0;
    var ip: u64 = 0;
    var lc: u64 = 0;
    var data = std.mem.zeroes([65535]u8);

    fn start(buf: []const u8, stdin: *const std.io.AnyReader, stdout: *const std.io.AnyWriter) !void {
        while (ip < buf.len) : (ip += 1) {
            try switch (buf[ip]) {
                '>' => dp +%= 1,
                '<' => dp -%= 1,
                '+' => data[dp] +%= 1,
                '-' => data[dp] -%= 1,
                '.' => stdout.print("{c}", .{data[dp]}),
                ',' => data[dp] = try stdin.readByte(),
                '[' => {
                    if (data[dp] == 0) {
                        lc += 1;
                        while (lc > 0) {
                            ip += 1;
                            if (buf[ip] == '[') {
                                lc += 1;
                            } else if (buf[ip] == ']') {
                                lc -= 1;
                            }
                        }
                    }
                },
                ']' => {
                    if (data[dp] != 0) {
                        lc += 1;
                        while (lc > 0) {
                            ip -= 1;
                            if (buf[ip] == ']') {
                                lc += 1;
                            } else if (buf[ip] == '[') {
                                lc -= 1;
                            }
                        }
                    }
                },
                else => dp += 0,
            };
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.openFileAbsolute(args[args.len - 1], .{});
    defer file.close();

    const stat = try file.stat();
    const buf = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buf);

    const stdout = std.io.getStdOut().writer().any();
    const stdin = std.io.getStdIn().reader().any();

    try bf_interpreter.start(buf, &stdin, &stdout);
}

test "hello world" {
    const test_alloc = std.testing.allocator;
    var string = std.ArrayList(u8).init(test_alloc);
    defer string.deinit();
    const out = string.writer().any();
    const in = std.io.getStdIn().reader().any();
    try bf_interpreter.start(">++++++++[<+++++++++>-]<.>++++[<+++++++>-]<+.+++++++..+++.>>++++++[<+++++++>-]<++.------------.>++++++[<+++++++++>-]<+.<.+++.------.--------.>>>++++[<++++++++>-]<+.", &in, &out);
    try std.testing.expectEqualStrings(string.items, "Hello, World!");
}
