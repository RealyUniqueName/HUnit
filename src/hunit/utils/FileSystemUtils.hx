package hunit.utils;

import sys.FileSystem;

using hunit.Utils;


enum ListDir {
    DirsOnly;
    FilesOnly;
    All;
}


/**
* File system tools
*
*/
class FileSystemUtils {


    /**
     * Make canonical path string.
     * Replaces all backslashes with slashes, removes trailing slashes.
     *
     */
    static public function canonicalize (path:String) : String
    {
        path = path.replace('\\', '/').trim();

        if (path.endsWith('/')) {
            var pos = path.length - 2;
            while (path.fastCodeAt(pos) == '/'.code) {
                pos --;
            }
            path = path.substring(0, pos + 1);
        }

        return path;
    }


    /**
    * Add slash to the end of provided directory path
    *
    */
    static public inline function ensureSlash (path:String) : String {
        return (path.charAt(path.length - 1) == '/' ? path : path + '/');
    }//function ensureSlash()


    /**
     * Returns part of the path till the last component
     *
     */
    static public function parentDir (path:String) : String
    {
        var parts : Array<String> = canonicalize(path).split('/');
        parts.pop();

        return parts.join('/');
    }


    /**
    * Get list of files in directory
    *
    */
    static public function listDir (directory:String, pattern:EReg = null, type:ListDir = null, recursive:Bool = false) : Array<String> {
        if( type == null ){
            type = ListDir.All;
        }

        directory = FileSystemUtils.ensureSlash(directory);

        var files : Array<String> = [];
        var dirs  : Array<String> = [directory];
        var dir   : String;

        while( dirs.length > 0 ){
            dir = dirs.shift();
            for(file in FileSystem.readDirectory(dir)){
                if( recursive && FileSystem.isDirectory(dir + file) ){
                    dirs.push( dir + file + '/' );
                }

                if( pattern != null && !pattern.match(file) ){
                    continue;
                }
                switch(type){
                    case FilesOnly if( !FileSystem.isDirectory(dir + file) ):
                        files.push((recursive ? dir.replace(directory, '') : '') + file);
                    case DirsOnly if( FileSystem.isDirectory(dir + file) ):
                        files.push((recursive ? dir.replace(directory, '') : '') + file);
                    case All:
                        files.push((recursive ? dir.replace(directory, '') : '') + file);
                    case _:
                }
            }
        }

        return files;
    }//function listDir()


    /**
    * Create a directory. Recursive by default. Use only forward slashes on all platforms.
    * Return true if directory already exists or was created successfully. False otherwise.
    *
    * @param recursive
    * @param silent     - don't throw exceptions if failed to create dir
    *
    * @throws String - if directory cannot be created and `silent` = false
    */
    static public function mkdir (dir:String, recursive:Bool = true, silent:Bool = false) : Bool {
        try{
            var parts : Array<String> = dir.split('/');
            var full : String = './';
            for(p in parts){
                if( p.length == 0 ) continue;
                full += '$p/';

                if( !FileSystem.exists(full) ){
                    FileSystem.createDirectory(full) ;
                }else if( !FileSystem.isDirectory(full) ){
                    throw '$full is not a directory';
                }
            }

            return true;

        }catch(e:Dynamic){
            if( !silent ){
                throw e;
            }

            return false;
        }
    }//function mkdir()


    /**
    * Delete directory and all its content
    *
    */
    static public function rmdir (dir) : Void {
        if (!FileSystem.exists(dir)) return;
        if (!FileSystem.isDirectory(dir)) return;

        var files = FileSystem.readDirectory(dir);
        dir = ensureSlash(dir);
        for(f in files) {
            if (FileSystem.isDirectory(dir + f)) {
                rmdir(dir + f);
            } else {
                FileSystem.deleteFile(dir + f);
            }
        }

        FileSystem.deleteDirectory(dir);
    }//function rmdir()

}//class FileSystemUtils