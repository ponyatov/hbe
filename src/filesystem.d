module filesystem;

/// @defgroup file file
/// @brief file i/o

/// @ingroup file
interface IFileSystem {
    /// @brief create new item
    /// @param in `string` name
    /// @returns `int` handle
    int create(string name);

    /// @brief open existing item (mark in use)
    /// @param in `string` name
    /// @returns `int` handle
    int open(string name);

    /// @brief close item (clear in use)
    /// @param in file hanle
    int close(int file_handle);

    /// @brief rename item
    bool rename(string old_name, string new_name);
    /// @brief delete item
    bool del(string file_name);

}

/// @ingroup file
/// @brief File specific operations
interface IFile : IFileSystem {

    /// @name r/w position control
    int seek(int file_handle, int position);
    int tell(int file_handle);
    int read(int file_handle, char* buffer, int bytes);
    int write(int file_handle, const char* buffer, int bytes);

    /// @name size manipulations
    bool truncate(int file_handle, int length);
    int size(int file_handle);
    bool flush(int file_handle);

}

/// @ingroup file
/// @brief Directory specific operations
interface IDir : IFileSystem {
}
