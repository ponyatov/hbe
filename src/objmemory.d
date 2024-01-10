/// @file
module objmemory;

import realwordmemory;
import oops;

alias objectPointer = short;
alias classPointer = objectPointer;
alias SmallInteger = short;
alias BitIndex = ubyte;

/// @defgroup objmemory objmemory
/// @{

/// Mark and sweep collection when memory full
version (GC_MARK_SWEEP) {
}

/// Ref counting
version (GC_REF_COUNT) {
}

// Define to use recursive marking for ref counting/GC
// If undefined the stack space efficient pointer reversal approach described
// on page 678 of G&R is used. Not recommended, and only included for
// completeness.
// version (RECURSIVE_MARKING) {}

/// Perform range checks etc. at runtime
version (RUNTIME_CHECKING) {
}

version (RUNTIME_CHECKING) {
    void RUNTIME_CHECK2(c, f, l) {
        // runtime_check(c, "RUNTIME ERROR: (" c ") at: " f "(" l ")");
    }

    void RUNTIME_CHECK1(c, f, l) {
        RUNTIME_CHECK2(c, f, l);
    }

    void RUNTIME_CHECK(cond) {
        RUNTIME_CHECK1(cond, __FILE__, __LINE__);
    }
} else {
    void RUNTIME_CHECK( /*cond*/ ) {
        // ((void)0)
    }
}

version (GC_MARK_SWEEP) {
    interface IGCNotification {
    public:
        /// About to garbage collect.
        /// Client should call @ref addRoot to specify roots of the world
        void prepareForCollection();
        /// Garbage collection has been completed
        void collectionCompleted();
    }
}

import hal;
import filesystem;

/// @ingroup objmemory
abstract class BCIInterface {
    final int oopsLeft() {
        return freeOops;
    }

    final uint coreLeft() {
        return freeWords;
    }

private:

    /// free words remaining (make primitiveFreeCore "fast")
    int freeWords;

    /// @brief free OT entries (make primitiveFreeOops "fast")
    ///
    /// An a table entry with a free bit set OR that contains a reference to a
    /// free chunk (free bit clear but count field zero) of memory is counted as
    /// a free oop
    int freeOops;

}

enum ObjectTable:ushort{
    Segment=realwordmemory.Segment.Count - 1,
    Start=0
    };

/// @ingroup objmemory
abstract class ObjectMemory : BCIInterface {

public:

    version (GC_MARK_SWEEP) {
        this(IHardwareAbstractionLayer* halInterface,
                IGCNotification* notification = 0);
    } else {
        this(IHardwareAbstractionLayer* halInterface);
    }

    bool loadSnapshot(IFileSystem* fileSystem, const char* imageFileName);
    bool saveSnapshot(IFileSystem* fileSystem, const char* imageFileName);

    void garbageCollect();

    // storePointer:ofObject:withValue:
    int storePointer_ofObject_withValue(int fieldIndex,
            int objectPointer, int valuePointer);

    // storeWord:ofObject:withValue:
    int storeWord_ofObject_withValue(int wordIndex,
            int objectPointer, int valueWord);

    // increaseReferencesTo:
    void increaseReferencesTo(int objectPointer) {
        /* "source"
         self countUp: objectPointer
        */
        version (GC_REF_COUNT)
            countUp(objectPointer);
    }

    // initialInstanceOf:
    int initialInstanceOf(int classPointer);

    // decreaseReferencesTo:
    void decreaseReferencesTo(int objectPointer) {
        /* "source"
         self countDown: objectPointer
        */
        version (GC_REF_COUNT)
            countDown(objectPointer);
    }

    // isIntegerValue:
    bool isIntegerValue(SmallInteger valueWord) {
        /* "source"
         "ERROR: G&R really cock this up"
         "dbanay - still broken in July 1985 ed!"
         ^valueWord >= -16384 and: [valueWord <= 16383]
        */
        return (valueWord & 1) == 1;
        // return valueWord >= -16384 && valueWord <= 16383;
    }

    //  // fetchWord:ofObject:
    //      int fetchWord_ofObject(int wordIndex, int objectPointer) {
    //         /* "source"
    //          ^self heapChunkOf: objectPointer word: HeaderSize + wordIndex
    //         */

    //         assert(wordIndex >= 0 &&
    //                       wordIndex < fetchWordLengthOf(objectPointer));
    //         return heapChunkOf_word(objectPointer, HeaderSize + wordIndex);
    //     }

    /// integerValueOf:
    // int integerValueOf(int objectPointer) {
    SmallInteger integerValueOf(objectPointer op) {
        /* "source"
            ^objectPointer/2
        */
        return op / 2;
        // return cast(short)(objectPointer & 0xfffe) / 2;
        // Right shifting a negative number is undefined.
    }

    // swapPointersOf:and:
    void swapPointersOf_and(int firstPointer, int secondPointer);

    // // fetchWordLengthOf:
    //  int fetchWordLengthOf(int objectPointer) {
    //     /* "source"
    //      ^(self sizeBitsOf: objectPointer) - HeaderSize
    //     */

    //     return sizeBitsOf(objectPointer) - HeaderSize;
    // }

    // instantiateClass:withWords:
    int instantiateClass_withWords(int classPointer, int length);

    // isIntegerObject:
    bool isIntegerObject(int objectPointer) {
        /* "source"
         ^(objectPointer bitAnd: 1) = 1
        */

        return (objectPointer & 1) == 1;
    }

    // instantiateClass:withBytes:
    int instantiateClass_withBytes(int classPointer, int length);

    // hasObject:
    bool hasObject(int objectPointer);

    // instantiateClass:withPointers:
    int instantiateClass_withPointers(int classPointer, int length);

    // // fetchByte:ofObject:
    //  int fetchByte_ofObject(int byteIndex, int objectPointer) {
    //     /* "source"
    //      ^self heapChunkOf: objectPointer byte: (HeaderSize*2 + byteIndex)
    //      */
    //     return heapChunkOf_byte(objectPointer, (HeaderSize * 2 + byteIndex));
    // }

    // // fetchPointer:ofObject:
    //  int fetchPointer_ofObject(int fieldIndex, int objectPointer) {
    //     /* "source"
    //      ^self heapChunkOf: objectPointer word: HeaderSize + fieldIndex
    //      */
    //     assert(fieldIndex >= 0 &&
    //                   fieldIndex < fetchWordLengthOf(objectPointer));
    //     return heapChunkOf_word(objectPointer, HeaderSize + fieldIndex);
    // }

//     // fetchClassOf:
//     //  int fetchClassOf(int objectPointer) {
//         int fetchClassOf(objectPointer op) {
//     //     /* Note that fetchClassOf:objectPointer returns IntegerClass (the object
//     //        table index of SmallInteger) if its argument is an immediate integer.
//     //        G&R pg 686 */
//     //     /* "source"
//     //      (self isIntegerObject: objectPointer)
//     //          ifTrue: [^IntegerClass] "ERROR IntegerClass not defined"
//     //          ifFalse: [^self classBitsOf: objectPointer]
//     //     */

//         if (isIntegerObject(op)) return Class.SmallInteger;
// else return  classBitsOf(op);
//     }

    // integerObjectOf:
    int integerObjectOf(int value) {
        /* "source"
         ^(value bitShift: 1) + 1
        */
        return cast(ushort)((value << 1) | 1);
    }

    // // fetchByteLengthOf:
    //  int fetchByteLengthOf(int objectPointer) {
    //     /* "source"
    //      "ERROR in selector of next line"
    //      ^(self fetchWordLengthOf: objectPointer)*2 - (self oddBitOf:
    //      objectPointer)
    //     */
    //     return fetchWordLengthOf(objectPointer) * 2 - oddBitOf(objectPointer);
    // }

    // instanceAfter:
    int instanceAfter(int objectPointer);

    // // storeByte:ofObject:withValue:
    //  int storeByte_ofObject_withValue(int byteIndex, int objectPointer,
    //                                         int valueByte) {
    //     /* "source"
    //      ^self heapChunkOf: objectPointer
    //          byte: (HeaderSize*2 + byteIndex)
    //          put: valueByte
    //     */

    //     return heapChunkOf_byte_put(objectPointer, HeaderSize * 2 + byteIndex,
    //                                 valueByte);
    // }

    /// @name ObjectPointers

    // cantBeIntegerObject:
    void cantBeIntegerObject(objectPointer op) {
        assert(!isIntegerObject(op));
    }

    version (GC_MARK_SWEEP) {
        void addRoot(int rootObjectPointer) // dbanay
        {
            markObjectsAccessibleFrom(rootObjectPointer);
        }
    }

private:

    /// @name Compaction

    // sweepCurrentSegmentFrom:
    int sweepCurrentSegmentFrom(int lowWaterMark);

    // compactCurrentSegment
    void compactCurrentSegment();

    // releasePointer:
    void releasePointer(int objectPointer);

    // reverseHeapPointersAbove:
    void reverseHeapPointersAbove(int lowWaterMark);

    // abandonFreeChunksInSegment:
    int abandonFreeChunksInSegment(int segment);

    // allocateChunk:
    int allocateChunk(int size);

    version (GC_MARK_SWEEP) {
        /// @name MarkingGarbage

        // reclaimInaccessibleObjects
        void reclaimInaccessibleObjects();

        // markObjectsAccessibleFrom:
        int markObjectsAccessibleFrom(int rootObjectPointer);

        // markAccessibleObjects
        void markAccessibleObjects();

        // rectifyCountsAndDeallocateGarbage
        void rectifyCountsAndDeallocateGarbage();

        // zeroReferenceCounts
        void zeroReferenceCounts();
    }

    /// @name NonpointerObjs 

    // lastPointerOf:
    int lastPointerOf(int objectPointer);

    // spaceOccupiedBy:
    int spaceOccupiedBy(int objectPointer);

    // allocate:odd:pointer:extra:class:
    int allocate_odd_pointer_extra_class(int size, int oddBit,
            int pointerBit, int extraWord, int classPointer);

    /// @name UnallocatedSpc

    // headOfFreePointerList
    int headOfFreePointerList();

    // toFreeChunkList:add:
    void toFreeChunkList_add(int size, int objectPointer);

    // headOfFreeChunkList:inSegment:put:
    int headOfFreeChunkList_inSegment_put(int size,
            int segment, int objectPointer);

    // removeFromFreePointerList
    int removeFromFreePointerList();

    // toFreePointerListAdd:
    void toFreePointerListAdd(int objectPointer);

    // removeFromFreeChunkList:
    int removeFromFreeChunkList(int size);

    // resetFreeChunkList:inSegment:
    void resetFreeChunkList_inSegment(int size, int segment);

    // headOfFreeChunkList:inSegment:
    int headOfFreeChunkList_inSegment(int size, int segment);

    // headOfFreePointerListPut:
    int headOfFreePointerListPut(int objectPointer);

    /// @name RefCntGarbage

    // countDown:
    int countDown(int rootObjectPointer);

    // countUp:
    int countUp(int objectPointer);

    // deallocate:
    void deallocate(int objectPointer);

    // // forAllOtherObjectsAccessibleFrom:suchThat:do:
    // int forAllOtherObjectsAccessibleFrom_suchThat_do(
    //     int objectPointer, const std::function<bool(int)> &predicate,
    //     const std::function<void(int)> &action);

    // // forAllObjectsAccessibleFrom:suchThat:do:
    // int forAllObjectsAccessibleFrom_suchThat_do(
    //     int objectPointer, const std::function<bool(int)> &predicate,
    //     const std::function<void(int)> &action);

    /// @name ObjectTableEnt

    // // segmentBitsOf:
    // Segment segmentBitsOf(objectPointer op) {
    //     /* "source"
    //      ^self ot: objectPointer bits: 12 to: 15
    //     */
    //     return ot_bits_to(op, 12, 15);
    // }

    // // ot:bits:to:
    //  Segment ot_bits_to(objectPointer op, BitIndex first,
    //                       BitIndex last) {
    //     /* "source"
    //      self cantBeIntegerObject: objectPointer.
    //      ^wordMemory segment: ObjectTableSegment
    //          word: ObjectTableStart + objectPointer
    //          bits: firstBitIndex
    //          to: lastBitIndex
    //     */

    //     cantBeIntegerObject(op);
    //     return wordMemory.segment_word_bits_to(cast(ushort)ObjectTable.Segment,
    //                                            ObjectTable.Start + cast(ushort)op,
    //                                            first, last);
    // }


    // // heapChunkOf:byte:put:
    //  int heapChunkOf_byte_put(int objectPointer, int offset, int value) {
    //     /* "source"
    //      ^wordMemory segment: (self segmentBitsOf: objectPointer)
    //          word: ((self locationBitsOf: objectPointer) + (offset//2))
    //          byte: (offset\\2) put: value
    //     */

    //     return wordMemory.segment_word_byte_put(
    //         segmentBitsOf(objectPointer),
    //         locationBitsOf(objectPointer) + (offset / 2), offset % 2, value);
    // }

    // // pointerBitOf:put:
    //  int pointerBitOf_put(int objectPointer, int value) {
    //     /* "source"
    //      ^self ot: objectPointer bits: 9 to: 9 put: value
    //     */

    //     return ot_bits_to_put(objectPointer, 9, 9, value);
    // }

    // // heapChunkOf:word:
    //  short heapChunkOf_word(objectPointer op , short offset) {
    // //     /* "source"
    // //      ^wordMemory segment: (self segmentBitsOf: objectPointer)
    // //          word: ((self locationBitsOf: objectPointer) + offset)
    // //     */
    //     return wordMemory.segment_word(segmentBitsOf(op),
    //                                    locationBitsOf(op) + offset);
    // }

    // // segmentBitsOf:put:
    //  int segmentBitsOf_put(int objectPointer, int value) {
    //     /* "source"
    //      ^self ot: objectPointer bits: 12 to: 15 put: value
    //      */

    //     return ot_bits_to_put(objectPointer, 12, 15, value);
    // }

    // // heapChunkOf:word:put:
    //  int heapChunkOf_word_put(int objectPointer, int offset, int value) {
    //     /* "source"
    //      ^wordMemory segment: (self segmentBitsOf: objectPointer)
    //          word: ((self locationBitsOf: objectPointer) + offset)
    //          put: value
    //     */
    //     return wordMemory.segment_word_put(
    //         segmentBitsOf(objectPointer),
    //         locationBitsOf(objectPointer) + offset, value);
    // }

    // // oddBitOf:
    //  int oddBitOf(int objectPointer) {
    //     /* "source"
    //      ^self ot: objectPointer bits: 8 to: 8
    //      */

    //     return ot_bits_to(objectPointer, 8, 8);
    // }

    // // freeBitOf:
    //  int freeBitOf(int objectPointer) {
    //     /* "source"
    //      ^self ot: objectPointer bits: 10 to: 10
    //     */

    //     return ot_bits_to(objectPointer, 10, 10);
    // }

    // // locationBitsOf:
    //  int locationBitsOf(int objectPointer) {
    //     /* "source"
    //      self cantBeIntegerObject: objectPointer.
    //      ^wordMemory segment: ObjectTableSegment
    //          word: ObjectTableStart + objectPointer + 1
    //     */
    //     cantBeIntegerObject(objectPointer);
    //     return wordMemory.segment_word(ObjectTableSegment,
    //                                    ObjectTableStart + objectPointer + 1);
    // }

    // // ot:
    //  int ot(int objectPointer) {
    //     /* "source"
    //      self cantBeIntegerObject: objectPointer.
    //      ^wordMemory segment: ObjectTableSegment
    //          word: ObjectTableStart + objectPointer
    //     */

    //     cantBeIntegerObject(objectPointer);
    //     return wordMemory.segment_word(ObjectTableSegment,
    //                                    ObjectTableStart + objectPointer);
    // }

    // // freeBitOf:put:
    //  int freeBitOf_put(int objectPointer, int value) {
    //     /* "source"
    //      ^self ot: objectPointer bits: 10 to: 10 put: value
    //     */

    //     return ot_bits_to_put(objectPointer, 10, 10, value);
    // }

    // // classBitsOf:
    //  classPointer classBitsOf(objectPointer op) {
    //     /* "source"
    //      ^self heapChunkOf: objectPointer word: 1
    //      */
    //     return heapChunkOf_word(op, 1);
    // }

    // // classBitsOf:put:
    //  int classBitsOf_put(int objectPointer, int value) {
    //     /* "source"
    //      ^self heapChunkOf: objectPointer word: 1 put: value
    //     */

    //     return heapChunkOf_word_put(objectPointer, 1, value);
    // }

    // // heapChunkOf:byte:
    //  int heapChunkOf_byte(int objectPointer, int offset) {
    //     /* "source"
    //      ^wordMemory segment: (self segmentBitsOf: objectPointer)
    //          word: ((self locationBitsOf: objectPointer) + (offset//2))
    //          byte: (offset\\2)
    //     */

    //     return wordMemory.segment_word_byte(
    //         segmentBitsOf(objectPointer),
    //         locationBitsOf(objectPointer) + offset / 2, offset % 2);
    // }

    // // locationBitsOf:put:
    //  int locationBitsOf_put(int objectPointer, int value) {
    //     /* "source"
    //      self cantBeIntegerObject: objectPointer.
    //      ^wordMemory segment: ObjectTableSegment
    //          word: ObjectTableStart + objectPointer + 1
    //          put: value
    //     */
    //     cantBeIntegerObject(objectPointer);
    //     return wordMemory.segment_word_put(
    //         ObjectTableSegment, ObjectTableStart + objectPointer + 1, value);
    // }

    // // sizeBitsOf:
    //  int sizeBitsOf(int objectPointer) {
    //     /* "source"
    //      ^self heapChunkOf: objectPointer word: 0
    //     */

    //     return heapChunkOf_word(objectPointer, 0);
    // }

    // // oddBitOf:put:
    //  int oddBitOf_put(int objectPointer, int value) {
    //     /* "source"
    //      ^self ot: objectPointer bits: 8 to: 8 put: value
    //     */
    //     return ot_bits_to_put(objectPointer, 8, 8, value);
    // }

    // // ot:put:
    //  int ot_put(int objectPointer, int value) {
    //     /* "source"
    //      self cantBeIntegerObject: objectPointer.
    //      ^wordMemory segment: ObjectTableSegment
    //          word: ObjectTableStart + objectPointer
    //          put: value
    //     */

    //     cantBeIntegerObject(objectPointer);
    //     return wordMemory.segment_word_put(
    //         ObjectTableSegment, ObjectTableStart + objectPointer, value);
    // }

    // private:

    /// Special Register G&R pg. 667
    RealWordMemory wordMemory;

    /// The index of the heap segment currently being used for allocation
    int currentSegment;

}
