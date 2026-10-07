const std = @import("std");

// --- Цвета --- //
const RESET = "\x1b[0m";
const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const BLUE = "\x1b[34m";
const MAGENTA = "\x1b[35m";
const CYAN = "\x1b[36m";

const help_table = [_]struct {
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

const banner =
    \\ |=========================================|
    \\ |  PhoenixShell v0.2.0 (на Zig 0.16.0)    |
    \\ |  Введите 'help', чтобы увидеть команды. |
    \\ |=========================================|
    \\
;

const prompt = "> ";

const Command = enum {
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

