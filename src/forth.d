module forth;
/// @file
/// @brief interactive debugger

import std.stdio;

// https://forum.dlang.org/thread/bjwyvxeygngytyrktcyf@forum.dlang.org
import gnu.readline;

extern (C) void add_history(const char*); // missing from gnu.readline
import std.string : toStringz, fromStringz;

/// `( -- )` no nothing: emptry command
void nop() {
}

/// `( -- )` halt the whole system immediately
void halt() {
}

/// run interactive shell
void repl() {
    while (true) {
        char* cmd = readline("> ");
        if (cmd) {
            add_history(cmd);
            writefln("[%s]", cmd.fromStringz);
        }
    }
}
