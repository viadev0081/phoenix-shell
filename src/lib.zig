const std = @import("std");

// --- Цвета --- //
pub const RESET = "\x1b[0m";
pub const RED = "\x1b[31m";
pub const GREEN = "\x1b[32m";
pub const YELLOW = "\x1b[33m";
pub const BLUE = "\x1b[34m";
pub const MAGENTA = "\x1b[35m";
pub const CYAN = "\x1b[36m";

pub const help_table = [_]struct {
    usage: []const u8,
    desc: []const u8
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
    .{ .usage = "list",             .desc = "выводит файлы в текущей папке" },
    .{ .usage = "create <-f/-d> <name>", .desc = "создание файла или папки" },
    .{ .usage = "delete <-f/-d> <name>", .desc = "удаление файла или папки" }
};

pub const banner =
    \\ |=========================================|
    \\ |  PhoenixShell v0.2.0 (на Zig 0.17.0)    |
    \\ |  Введите 'help', чтобы увидеть команды. |
    \\ |=========================================|
    \\
;

pub const prompt = "> ";

pub const Command = enum {
    help,
    echo,
    addition,
    create,
    delete,
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
    list
};

