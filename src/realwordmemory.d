module realwordmemory;

/// Memory manager for x86 real mode (emulated)
class RealWordMemory {
public:
    /// number of sequential segments * SegmentSize = 1Mb
    static const int SegmentCount = 16;
    /// segment size /in 16-bit words/ = 65536
    static const int SegmentSize = ushort.max;
}
