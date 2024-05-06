const std = @import("std");
const net = std.net;
const print = std.debug.print;

pub fn main() anyerror!void {
    const sock_addr = try net.Ip4Address.parse("127.0.0.1", 8080);
    const host = net.Address{ .in = sock_addr };
    var server = try host.listen(.{
        .reuse_port = true,
    });
    defer server.deinit();
    print("Server listening at {!}.\n", .{host.in});

    while (true) {
        const connection = try server.accept();
        defer connection.stream.close();
        print("Connection established.\n", .{});

        read: while (true) {
            var buffer: [128]u8 = undefined;
            _ = connection.stream.read(&buffer) catch {
                break :read;
            };
            _ = connection.stream.writer().print("{s}\n", .{buffer}) catch {
                break :read;
            };

            continue :read;
        }

        print("Cnnection lost.\n", .{});
    }
    return;
}
