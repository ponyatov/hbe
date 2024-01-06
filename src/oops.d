/// @file
/// @brief Well known oops for various objects in an image

module oops;
/// @defgroup oops oops
/// @brief Well known oops for various objects in an image
///
///  dbanay - first oops 2..52 are special oops... see this from SystemTracer:
/// <pre>
///  If using GC make sure these are roots
///  specialObjects _
///       "1:" (Array with: nil with: false with: true with: (Smalltalk associationAt: #Processor))
///      , "5:" (Array with: Symbol table with: SmallInteger with: String with: Array)
///      , "9:" (Array with: (Smalltalk associationAt: #Smalltalk) with: Float
///                  with: MethodContext with: BlockContext)
///      , "13:" (Array with: Point with: LargePositiveInteger with: DisplayBitmap with: Message)
///      , "17:" (Array with: CompiledMethod with: #unusedOop18 with: Semaphore with: Character)
///      , "21:" (Array with: #doesNotUnderstand: with: #cannotReturn:
///                  with: #monitor: with: Smalltalk specialSelectors)
///      , "25:" (Array with: Character characterTable with: #mustBeBoolean).
///  specialObjects size = 26 ifFalse: [self error: 'try again!!'].
/// </pre>
/// @{

/// @name initializeGuaranteedPointers
/// p.576/598
/// @{

enum UndefinedObject {
    NilPointer = 2,
}

enum Booleans {
    FalsePointer = 4,
    TruePointer = 6,
}

enum Root {
    SchedulerAssociationPointer = 8, //
    // SmalltalkPointer = 25286, // SystemDictionary
}

enum Classes {
    // ClassSmallInteger = 12,
    ClassStringPointer = 14,
    ClassArrayPointer = 16,
    ClassMethodContextPointer = 22,
    ClassBlockContextPointer = 24,
    ClassPointPointer = 26,
    ClassLargePositiveIntegerPointer = 28,
    ClassMessagePointer = 32,
    ClassCharacterPointer = 40, //
    // ClassCompiledMethod = 34,
    // ClassSymbolPointer = 56,
    // ClassFloatPointer = 20,
    // ClassSemaphorePointer = 38,
    // ClassDisplayScreenPointer = 834,
    // ClassUndefinedObject = 25728,
}

enum Selectors {
    DoesNotUnderstandSelector = 42,
    CannotReturnSelector = 44,
    MustBeBooleanSelector = 52,
}

enum Tables {
    SpecialSelectorsPointer = 48,
    CharacterTablePointer = 50,
}

/// @}

/// @}
