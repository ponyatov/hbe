/// @file
/// @brief interpreter

module interpreter;
/// @defgroup interpreter interpreter
/// @{

/// Add some helpful methods if defined
version (DEBUGGING_SUPPORT) {
}
/// implement optional @ref primitiveNext
version (IMPLEMENT_PRIMITIVE_NEXT) {
}
/// implement optional @ref primitiveNextPut
version (IMPLEMENT_PRIMITIVE_NEXT_PUT) {
}
/// implement optional @ref primitiveAtEnd
version (IMPLEMENT_PRIMITIVE_AT_END) {
}
/// implement optional @ref primitiveScanCharacters
version (IMPLEMENT_PRIMITIVE_SCANCHARS) {
}

version (GC_MARK_SWEEP) {
    alias INotification = IGCNotification;
} else {
    alias INotification = Object;
}

class Interpreter : INotification {
    version (GC_MARK_SWEEP) {
    }

}

/// @name SmallIntegers

/// p.575/597
enum initializeSmallIntegers {
    MinusOnePointer = 65535,
    ZeroPointer = 1,
    OnePointer = 3,
    TwoPointer = 5,
}

/// @}
