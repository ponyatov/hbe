module objmemory;

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

class ObjectMemory {
    version (GC_MARK_SWEEP) {
        this(IHardwareAbstractionLayer* halInterface,
                IGCNotification* notification = 0) {
        }
    } else {
        this(IHardwareAbstractionLayer* halInterface) {
        }
    }

    bool loadSnapshot(IFileSystem* fileSystem, const char* imageFileName) {
        return false;
    }

    bool saveSnapshot(IFileSystem* fileSystem, const char* imageFileName) {
        return false;
    }

}
