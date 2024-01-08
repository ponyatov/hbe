module main;

import bitblt;
import oops;
import hal;
import interpreter;
import filesystem;
import posixfilesystem;
import objmemory;
import realwordmemory;

import std.stdio;

void main(string[] arg) {
    writeln(arg);
    writefln("%d %d %d %d", //
            initializeSmallIntegers.MinusOnePointer,
            initializeSmallIntegers.ZeroPointer,
            initializeSmallIntegers.OnePointer,
            initializeSmallIntegers.TwoPointer);
    writefln("RealWordMemory %s", RealWordMemory.SegmentSize);
}
