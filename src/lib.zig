const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

pub const Model = struct {
    count: u32 = 0,
    button: vxfw.Button,

    pub fn widget(self: *Model) vxfw.Widget {
        return .{
            .userdata = self,
            .eventHandler = Model.typeErasedEventHandler,
            .drawFn = Model.typeErasedDrawFn,
        };
    }

    fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
        const self: *Model = @ptrCast(@alignCast(ptr));
        switch (event) {
            .init => return ctx.requestFocus(self.button.widget()),
            .key_press => |key| {
                if (key.matches('c', .{ .ctrl = true })) {
                    ctx.quit = true;
                    return;
                }
            },
            .focus_in => return ctx.requestFocus(self.button.widget()),
            else => {},
        }
    }

    fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
        const self: *Model = @ptrCast(@alignCast(ptr));
        const max_size = ctx.max.size();

        const count_text = try std.fmt.allocPrint(ctx.arena, "{d}", .{self.count});
        const text: vxfw.Text = .{ .text = count_text };

        const text_child: vxfw.SubSurface = .{
            .origin = .{ .row = 0, .col = 0 },
            .surface = try text.draw(ctx),
        };

        const button_child: vxfw.SubSurface = .{
            .origin = .{ .row = 2, .col = 0 },
            .surface = try self.button.draw(ctx.withConstraints(
                ctx.min,
                .{ .width = 16, .height = 3 },
            )),
        };

        const children = try ctx.arena.alloc(vxfw.SubSurface, 2);
        children[0] = text_child;
        children[1] = button_child;

        return .{
            .size = max_size,
            .widget = self.widget(),
            .buffer = &.{},
            .children = children,
        };
    }

    pub fn onClick(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
        const ptr = maybe_ptr orelse return;
        const self: *Model = @ptrCast(@alignCast(ptr));
        self.count +|= 1;
        return ctx.consumeAndRedraw();
    }
};

// --- Цвета --- //
pub const RESET   = "\x1b[0m";
pub const BLACK   = "\x1b[30m";
pub const RED     = "\x1b[31m";
pub const GREEN   = "\x1b[32m";
pub const YELLOW  = "\x1b[33m";
pub const BLUE    = "\x1b[34m";
pub const MAGENTA = "\x1b[35m";
pub const CYAN    = "\x1b[36m";
pub const WHITE   = "\x1b[79m";

pub const help_table = [_]struct { 
    usage: []const u8, desc: []const u8 
} { 
    .{ .usage = "help",             .desc = "показать эту справку" }, 
    .{ .usage = "echo <текст>",     .desc = "напечатать текст обратно" }, 
    .{ .usage = "addition <a> <b>", .desc = "сложить два целых числа" }, 
    .{ .usage = "mul <a> <b>",      .desc = "умножить два целых числа" }, 
    .{ .usage = "upper <текст>",    .desc = "текст В ВЕРХНЕМ РЕГИСТРЕ" }, 
    .{ .usage = "reverse <текст>",  .desc = "перевернуть строку (побайтово)" }, 
    .{ .usage = "lower <текст>",    .desc = "переводит текст в нижний регистр" }, 
    .{ .usage = "len <текст>",      .desc = "длина строки в байтах (UTF-8)" }, 
    .{ .usage = "env <ИМЯ>",        .desc = "показать переменную окружения" }, 
    .{ .usage = "args",             .desc = "показать аргументы командной строки" }, 
    .{ .usage = "run <prog> [arg]", .desc = "запустить внешнюю программу" }, 
    .{ .usage = "clear",            .desc = "очистить экран терминала" }, 
    .{ .usage = "exit",             .desc = "выйти из PhoenixShell" }, 
    .{ .usage = "fetch",            .desc = "как neofetch или nitch но для PhoenixShell" }, 
    .{ .usage = "ver",              .desc = "показывает версию PhoenixShell" }, 
    .{ .usage = "ls",             .desc = "выводит файлы в текущей папке" }, 
    .{ .usage = "create < -f/-d > <name>", .desc = "создание файла или папки" }, 
    .{ .usage = "delete < -f/-d > <name>", .desc = "удаление файла или папки" },
    .{ .usage = "cd <путь>",        .desc = "перейти в другую папку (без аргумента — в домашнюю)" },
    .{ .usage = "pwd",              .desc = "показать путь до текущей папки" },
    .{ .usage = "colors",           .desc = "показывает все цвета в терминале" },
    .{ .usage = "tui",              .desc = "какая-то TUI утилита на зиге?" },
    .{ .usage = "cat",              .desc = "вывод содержимое в файле" },
};

pub const banner =
    \\ |=========================================|
    \\ |  PhoenixShell v0.2.0 (на Zig 0.17.0)    |
    \\ |  Введите 'help', чтобы увидеть команды. |
    \\ |=========================================|
    \\
;

pub const prompt = "$";

pub fn writePrompt(
    writer: *std.Io.Writer,
    io: std.Io,
    home: ?[]const u8,
) !void {
    var buf: [std.fs.max_path_bytes]u8 = undefined;

    try writer.writeAll(BLUE);
    
    if (std.process.currentPath(io, &buf)) |n| {
        try writeShortPath(writer, buf[0..n], home);
    } 
    else |_| {
        try writer.writeAll("?");
    }
    
    try writer.print("{s} {s} {s}", .{ RED, prompt, RESET });
}

fn writeShortPath(
    writer: *std.Io.Writer,
    full_path: []const u8,
    home: ?[]const u8,
) !void {
    if (home) |h| {
        const root = std.mem.trimEnd(u8, h, "/");
        if (root.len != 0 and std.mem.startsWith(u8, full_path, root)) {
            const rest = full_path[root.len..];
            if (rest.len == 0)  {
                return writer.writeAll("~");
            }

            if (rest[0] == '/') {
                return writer.print("~{s}", .{rest});
            }
        }
    }

    try writer.writeAll(full_path);
}

pub const Command = enum { 
    help, 
    echo, 
    addition, 
    create, 
    delete, 
    cd,
    pwd,
    mul, 
    upper, 
    reverse, 
    lower, 
    len, 
    env, 
    args, 
    run, 
    clear, 
    exit, 
    fetch, 
    ver, 
    ls, 
    colors,
    tui,
    cat
};
