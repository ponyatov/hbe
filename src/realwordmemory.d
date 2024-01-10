module realwordmemory;

/// Memory manager for x86 real mode (emulated)

enum Segment : ushort {
    /// number of sequential segments * SegmentSize = 1Mb
    Count = 16, // 16384 = 1Gb
    /// segment size /in 16-bit words/ = 65536
    Size = ushort.max
}

import objmemory;

class RealWordMemory {
public:

    /// RealWordMemory() {}
    this() {
    }

    ushort segment_word(ushort s, ushort w) {
        assert(s < Segment.Count);
        // assert(w < Segment.Size);
        return memory[s][w];
    }

    // // The most significant bit in a word will be referred to with the index 0
    // // and the least significant with the index 15. G&R p.657
    //  ushort segment_word_bits_to(ushort s, ushort w, BitIndex first,
    //                                 BitIndex last) {
    //     assert(s < Segment.Count);
    //     assert(w < Segment.Size);

    //     ushort shift = memory[s][w] >> (15 - last);
    //     ushort mask = (1 << (last - first + 1)) - 1;

    //     return shift & mask;
    // }

private:
    ushort[Segment.Count][Segment.Size] memory;
}
