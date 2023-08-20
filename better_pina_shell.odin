//*****************************************************************************
//
//  name:   better_pina_shell - A screen reader shell for Linux that speaks the stdin,
//                              the stdout and the stderr.
//                              Made with in the Odin programming language and still
//                              in development.
//
//  description: A screen reader shell for Linux that speaks with the open source
//               espeak-ng TTS, the stdin, the stdout and the stderr.
//
//              The better_pina_shell is a reimplementation of the fork pina_shell
//              that I made from the lsh (Libstephen Shell) shell, with many
//              improvements.
//
//  #####################
//      Problem HERE
//  #####################
//
//   Currently there is a problem with the unix2.sys_read() system call inside
//   this code. It simply blocks the program, and that behavier is different 
//   from the original C code.
//   But the 2 codes are identical, and I don't know why this is happening.
//   I posted this problem here to see knows why there is a difference in
//   the behavier between the Odin's and C code.
//
//
//  other files used:
//
//              The files: sys/uni2/syscalls_linux.odin and sys/unix2/time_unix.odin
//              are pre release of the core:sys:unix:syscalls_linux.odin and there
//              link are:
//
//
//    Odin - Binding to C 
//    https://odin-lang.org/news/binding-to-c/Odin/
//
//
//    GitHub - Branch "more-os2"
//    https://github.com/jasonKercher/
//
//    Github - 
//    core/sys/unix/syscalls_linux.odin
//    https://github.com/jasonKercher/Odin/blob/more-os2/core/sys/unix/syscalls_linux.odin
//
//    GitHub - [necessary for the syscalls_linux.odin, previous reference ]
//    cOdin/core/sys/unix/time_unix.odin
//    https://github.com/jasonKercher/Odin/blob/more-os2/core/sys/unix/time_unix.odin
//
//
//    Github - new implementation of os2 usage of the new syscalls in more-os2 branch
//    core/os/os2/
//    https://github.com/jasonKercher/Odin/blob/more-os2/core/os/os_linux.odin
//
//
//
//  TTS:    you need to install the espeak-ng TTS for linux. 
//
//  to compile: $ odin build .
//  
//  to run:     $ ./better_pina_shell
//
//  file:   better_pina_shell.c
//
//  author: Original      280 lines Stephen Brennan ( very simples c code Shell )
//          Current C    1120 lines João Carvalho  ( A screen reader shell )
//          Current Odin ???? lines João Carvalho  ( A even better screen reader shell )
//
//  url:    Original - Stephen Brennan - Tutorial - Write a Shell in C
//          https://brennan.io/2015/01/16/write-a-shell-in-c/
//          
//          github - brenns10 / lsh
//          https://github.com/brenns10/lsh
//
//          Current in C:
//          Github  - joaocarvalhoopen - pina_shell
//          https://github.com/joaocarvalhoopen/pina_shell--A-screen-reader-shell-for-Linux
//
//          Current in Odin:
//          Github  - joaocarvalhoopen - better_pina_shell
//          https://github.com/joaocarvalhoopen/better_pina_shell--A-better-screen-reader-shell-for-Linux
//
//  date:   Original:        Thursday,  8 January 2015
//          Current in C:    Saturday,  18 August 2023
//          Current in Odin: Saturday,  20 August 2023
//
//  brief:  Original:         LSH (Libstephen Shell)
//          Current in C :    pina_shell        ( A screen reader shell for Linux )
//          Current in Odin : better_pina_shell ( A screen reader shell for Linux )
//
//
//  License: MIT Open Source License
//
//*****************************************************************************


package main

import "core:fmt"
import "core:strings"
import "core:c"       // Odin - Binding to C types.
import "./sys/unix2"  // Odin - Pre release of core:sys:unix:syscalls_linux.odin
                      // This maps all the Linux system calls.
import "core:runtime"
import "core:os"
import "core:unicode"
import "core:unicode/utf8"


when ODIN_OS == .Darwin {
	foreign import libc "System.framework"
} else  {
	foreign import libc "system:c"
}


@(default_calling_convention="c")
foreign libc {
	// environ: ^^[^]cstring;
    environ: [^]cstring;

    // perror
    perror :: proc "contextless" ( msg: cstring ) ---
}

EXIT_FAILURE :: -1
EXIT_SUCCESS :: 0

// Constants
STDIN_FILENO  : int : 0
STDOUT_FILENO : int : 1
STDERR_FILENO : int : 2

// when ODIN_OS == .Linux   do foreign import foo "foo.a"

// Get parent process ID
_get_ppid :: proc() -> int {
	return unix2.sys_getppid()
}


execute_program :: proc ( argv: []string ) -> int {
    // return unix2.sys_execve(name, args)

    parent_pid : int = unix2.sys_fork()

    if parent_pid == 0 {
        // Child process
        fmt.println("Child process!")

        child_pid: int = unix2.sys_getpid()

        fmt.printf("Child process parent_pid - pid: %v\n", parent_pid)
        fmt.printf("Child process - child_pid - pid: %v\n", child_pid)

        // execv() - Parameters.
        // "/bin/sh", "sh", "-c"

        path := strings.clone_to_cstring( "/bin/sh" )

        cargs := make([]cstring, len(argv) + 2 + 1, context.temp_allocator)
        // The first argument is a copy of the program name.
        cargs[0] = strings.clone_to_cstring( "sh" )
        // cargs[0] = strings.clone_to_cstring("/bin/sh")
        cargs[1] = strings.clone_to_cstring( "-c" )

        for i := 0; i < len(argv); i += 1 {
            cargs[i + 2] = strings.clone_to_cstring(argv[i], context.temp_allocator)
            fmt.printf("argv[%v]: %v\n", i, argv[i])
        }

        cargs[ len(cargs) - 1] = nil

        
    /*
        // attr : ^int = nil

        // Use current process's environment if attributes not provided
        env: [^]cstring
        if attr == nil {
            // take this process's current environment
            env = raw_data(export_cstring_environment(context.temp_allocator))
        } else {
            if (len(attr.files) == 0) {
                // TODO: handle attr.files for "popen" style behavior
                unimplemented()
            }

            cenv := make([]cstring, len(attr.env) + 1, context.temp_allocator)
            // The first argument is a copy of the program name.
            for i := 0; i < len(argv); i += 1 {
                cenv[i] = strings.clone_to_cstring(attr.env[i], context.temp_allocator)
            }
            env = &cenv[0]
        }
    */

        

        fmt.println("cargs: %#v", cargs)

		// In child process now (or replacing original)
        // The environ variable is a global variable that is exported by the C library, see up in the file. 
		if res := unix2.sys_execve(path, &cargs[0], environ /* nil /* env */ */ ); res < 0 {
        //if res := unix2.sys_execve(path, &cargs[0], nil /* env */); res < 0 {
			fmt.printf("Error: execl failed\n")
            panic("sys_execve failed to replace process")
		}

  
        return 0
    } else {
        // Parent process
        fmt.printf("Parent process - pid: %v\n", parent_pid)

        return parent_pid
    }
}

// _________________________________________________________________


speak_audio :: proc ( text : string) {

    espeak_ng : string   = "espeak-ng";
    punctuation : string = "--punct";

    // Allocate memory for the new string:
    // length of text + 2 for the double quotes + 1 for the null-terminator
    
    // text_with_quotes: []string = make([]string, 1)
    text_with_quotes : strings.Builder = strings.builder_make() 

    fmt.sbprint(& text_with_quotes, "%v %v \"'%v'\"", espeak_ng, punctuation, text)

    // printf("text_with_quotes: %s\n", text_with_quotes);

    speak_ng_command_args: []string = lsh_split_line( strings.to_string(text_with_quotes) );

    // Print to verify speak_ng_command_args
    // for (int i = 0; i < 2; i++) {
    //     printf("args[%d]: %s\n", i, speak_ng_command_args[i]);
    // }

    dont_gen_pipes_dont_capture_output : bool = false;
    status : int = lsh_execute( speak_ng_command_args, dont_gen_pipes_dont_capture_output );

    strings.builder_destroy( & text_with_quotes );
    delete( speak_ng_command_args );
}

speak_audio_char :: proc ( char_value: rune ) {
    str_builder : strings.Builder = strings.builder_make()
    strings.write_rune(& str_builder,  char_value )
    speak_audio( strings.to_string( str_builder ) )
    strings.builder_destroy( & str_builder )
}

join_args_with_space :: proc ( args: []string ) -> string {
    return strings.join( args, " " )
}

lsh_execute :: proc (args : [] string,  flag_with_pipes_active : bool) -> int {
    if len(args[0]) == 0 {
        // An empty command was entered.
        return 1
    }

    switch args[0] {
        case "cd" : return lsh_cd( args )
        case "help" : return lsh_help( args )
        case "exit" : return lsh_exit( args )
        case : return lsh_launch_second(args, flag_with_pipes_active)
    }
}

//  @brief Builtin command: change directory.
//  @param args List of args.  args[0] is "cd".  args[1] is the directory.
//  @return Always returns 1, to continue executing.
lsh_cd :: proc ( args: []string ) -> int {
    if args[1] == "" {
        fmt.eprintf( "pina_shell: expected argument to \"cd\"\n" )
        speak_audio("pina_shell: expected argument to cd")
    } else {
        target_dir_name := strings.clone_to_cstring( args[1] )
        if unix2.sys_chdir( target_dir_name ) != 0 {
            fmt.println(`Error: While changing directory with "cd" command.`)
        }
    }
    return 1
}

// @brief Builtin command: print help.
// @param args List of args.  Not examined.
// @return Always returns 1, to continue executing.
lsh_help :: proc ( args: []string ) -> int {
    fmt.printf("Joao Carvalho - better_pina_shell\n")
    fmt.printf("It's a fork over João Carvalho - pina_shell\n")
    fmt.printf("And that is a fork over Stephen Brennan's LSH Shell\n")
    fmt.printf("Type program names and arguments, and hit enter.\n")
    fmt.printf("The following are built in:\n")

    builtins : []string = {"help", "cd", "exit"}
    for builtin in builtins {
        fmt.printf("  %v\n", builtin)
    }

    fmt.printf("Use the man command for information on other programs.\n");
    return 1;
}

// @brief Builtin command: exit.
// @param args List of args.  Not examined.
// @return Always returns 0, to terminate execution.
lsh_exit :: proc ( args : []string ) -> int {
  return 0
}

lsh_launch_first :: proc (argv: []string ) -> int {

    WIFEXITED__cmacro :: proc (status : i32) -> bool {
        return ((status) & 0xff) == 0
    }

    WIFSIGNALED__cmacro :: proc (status : i32) -> bool {
        return ((status) & 0xff) != 0 
    }

    pid: int
    status: i32

    pid = unix2.sys_fork()
    if pid == 0 {
        // Child process
        
        // TODO: Experiment with this option for the child process.
        // context = runtime.default_context() 

        path := strings.clone_to_cstring( "/bin/sh" )
        
        cargs := make([]cstring, len(argv) + 2 + 1, context.temp_allocator)
        // defer delete(cargs)

        // The first argument is a copy of the program name.
        cargs[0] = strings.clone_to_cstring( "sh" )
        cargs[1] = strings.clone_to_cstring( "-c" )

        for i := 0; i < len(argv); i += 1 {
            cargs[i + 2] = strings.clone_to_cstring(argv[i], context.temp_allocator)
            fmt.printf("argv[%v]: %v\n", i, argv[i])
        }

        cargs[ len(cargs) - 1] = nil

        if res := unix2.sys_execve( path, &cargs[0], environ ); res < 0 {
            delete(cargs)
            fmt.printf("Error: execve failed\n")
            panic("sys_execve failed to replace process")
            // os.exit(EXIT_FAILURE);
        }
        delete(cargs)
        os.exit(EXIT_SUCCESS);
    } else if pid < 0 {
        // Error forking
        fmt.printf("Error: forking failed.\n")
        panic("Forking failed.")
    } else {
        // Parent process
        flag_while_child_is_running : bool = true
        for flag_while_child_is_running {
            unix2.sys_wait4(pid, &status, 0, nil)

            if  WIFEXITED__cmacro(status) || WIFSIGNALED__cmacro(status) {
                flag_while_child_is_running = false
            }
        }
    }

  return 1;
}



// get_rune_vec_from_string :: proc (s : string) -> [dynamic]rune {
//     // A dynamic array of runes.
//     rune_vec : [dynamic]rune = make( [dynamic]rune, 0 )
//     for r, _ in s {
//         append( &rune_vec, r )
//     }
//     return rune_vec
// }

// is_whitespace :: proc ( rune_char : rune ) -> bool {
//     switch rune_char {
//     case ' ', '\t', '\r', '\n', '\a':
//         return true
//     case:
//         return false
//     }
// }

// rune_slice_to_string :: proc (rune_slice : []rune) -> string {
//     str_builder : strings.Builder = strings.builder_make_none()
//     for r, _ in rune_slice {
//         strings.write_rune( & str_builder, r)
//     }
//     return strings.to_string( str_builder )
// }

// Constants
LSH_TOK_BUFSIZE : int = 64
LSH_TOK_DELIM : string =  " \t\r\n\a"

lsh_split_line :: proc ( line : string ) -> []string {
    bufsize : int = LSH_TOK_BUFSIZE
    position : int = 0
    
    // char **tokens = malloc(bufsize * sizeof(char*));
    // if (!tokens) {
    //     fprintf(stderr, "lsh: allocation error\n");
    //     exit(EXIT_FAILURE);
    // }


    tokens : []string = make([]string, bufsize)
    
    // rune_vec : [dynamic]rune = get_rune_vec_from_string( line )
    rune_vec : []rune = utf8.string_to_runes( line )

    // char *start = line, *end = line;
    start : int = 0
    end   : int = 0
    for end < len(rune_vec) {
        // Skip whitespace
        for end < len(rune_vec) && unicode.is_white_space( rune_vec[end] ) {
            end += 1
        }
        start = end;

        // Handle quoted strings
        if rune_vec[ end ] == '"' {
            start += 1  // move past the starting quote
            end *= 1
            for end < len(rune_vec) && rune_vec[ end ] != '"' {
                end += 1
            }
            if end < len(rune_vec) {
                //str_tmp : string = rune_slice_to_string( rune_vec[start : end - start ] )
                str_tmp : string = utf8.runes_to_string( rune_vec[start : end - start ] )
                tokens[ position ] = str_tmp
                end += 1  // skip the ending quote
            } else {
                // str_tmp : string = rune_slice_to_string( rune_vec[ start : ] )
                str_tmp : string = utf8.runes_to_string( rune_vec[ start : ] )
                tokens[position] = str_tmp  // unmatched quote, copy the rest
            }
        } else {
            // Find the next delimiter
            for    (end < len(rune_vec) 
                &&  !unicode.is_white_space( rune_vec[end] )     
                && rune_vec[end] != '"') {
                end += 1;
            }
            // str_tmp : string = rune_slice_to_string( rune_vec[start : end - start ] )
            str_tmp : string = utf8.runes_to_string( rune_vec[start : end - start ] )
            tokens[ position ] = str_tmp
        }

        position += 1
    }
    tokens[position] = "";
    return tokens;
}

// #################################################################
// #################################################################



lsh_launch_second :: proc (argv: []string, flag_with_pipes_active: bool = false ) -> int {

    WIFEXITED__cmacro :: proc (status : i32) -> bool {
        return ((status) & 0xff) == 0
    }

    WIFSIGNALED__cmacro :: proc (status : i32) -> bool {
        return ((status) & 0xff) != 0 
    }

    pid: int
    // status: i32

    pipe_fd__std_out: [2]int
    pipe_fd__std_err: [2]int

    if flag_with_pipes_active {
        if unix2.sys_pipe( & pipe_fd__std_out ) < 0 /* == -1 */ ||  unix2.sys_pipe( & pipe_fd__std_err ) < 0 /* == -1 */  {
            // perror("pipe")
            fmt.printf("Error: creation of pipes failed.\n")
            os.exit( EXIT_FAILURE )
        }
    }

    pid = unix2.sys_fork()

    if (pid == 0) {
        // Child process

        context = runtime.default_context()

        if flag_with_pipes_active {
            // std_out
            unix2.sys_close( pipe_fd__std_out[0] );
            res : int
            if res = unix2.sys_dup2( pipe_fd__std_out[1], STDOUT_FILENO ); res == -1 {
                perror("dup2 - stdout.")
                fmt.printf("Error while first  sys_dup2[%v]\n", res)             
                os.exit( EXIT_FAILURE )
            }
            // res := unix2.sys_dup2( pipe_fd__std_out[1], int( os.stdout ) )
            perror("dup2 - stdout.")
            fmt.printf("res := unix2.sys_dup2() stdout  [%v]\n", res)             
            unix2.sys_close( pipe_fd__std_out[1] );



            // std_err
            unix2.sys_close( pipe_fd__std_err[0] );            
            res_2 : int
            if res_2 = unix2.sys_dup2( pipe_fd__std_err[1], STDERR_FILENO ); res_2 == -1 {
                perror("dup2 - stdout.")
                fmt.printf("Error while second  sys_dup2[%v]\n", res)             
                os.exit( EXIT_FAILURE )
            }
            // res_2 := unix2.sys_dup2( pipe_fd__std_err[1], int( os.stderr ) )
            perror("dup2 - stderr.")
            fmt.printf("res_2 := unix2.sys_dup2() stderr  [%v]\n", res_2) 
            unix2.sys_close( pipe_fd__std_err[1] )
        }

        // command_tmp : string = join_args_with_space(args)
        // command : cstring = string.clone_to_cstring( command_tmp )

        path := strings.clone_to_cstring( "/bin/sh" )
        
        cargs := make([]cstring, len(argv) + 2 + 1, context.temp_allocator)
        // defer delete(cargs)

        // The first argument is a copy of the program name.
        cargs[0] = strings.clone_to_cstring( "sh" )
        cargs[1] = strings.clone_to_cstring( "-c" )

        for i := 0; i < len(argv); i += 1 {
            cargs[i + 2] = strings.clone_to_cstring(argv[i], context.temp_allocator)
            fmt.printf("argv[%v]: %v\n", i, argv[i])
        }

        cargs[ len(cargs) - 1] = nil

        if res := unix2.sys_execve( path, &cargs[0], environ ); res == -1 /* < 0 */ {
            delete(cargs)
            fmt.printf("Error: execve failed\n")
            panic("sys_execve failed to replace process")
            // os.exit(EXIT_FAILURE);
        }
        delete(cargs)
        // os.exit(EXIT_SUCCESS);
    } else if pid < 0 {
        // Error forking
        fmt.printf("Error: forking failed.\n")
        panic("Forking failed.")
    } else {
        // Parent process

        if flag_with_pipes_active {
            
            unix2.sys_close( pipe_fd__std_out[1] );
            unix2.sys_close( pipe_fd__std_err[1] );

            // std_out
            buffer__std_out : [1024 * 20]u8
            bytes_read__std_out : int
        
            buffer__std_out_str : string 

            fmt.printf("Parent AFTER fork(), but before FOR stdout.\n")

            // #####################
            //     Problem HERE
            // #####################

            // std_out
            for {
                fmt.printf("BEFORE unix2.sys_read() \n")
                bytes_read__std_out = unix2.sys_read( pipe_fd__std_out[0], 
                                                      rawptr(& buffer__std_out[0]),
                                                      len(buffer__std_out) - 2 /* 1 */ )

                perror("after first read\n")
                fmt.printf("bytes_read__std_out: %v\n", bytes_read__std_out)
                if  bytes_read__std_out <= 0 do break
                buffer__std_out[ bytes_read__std_out - 1 ] = 0    // '\0' Null Character
                buffer__std_out_str = strings.clone_from_bytes( buffer__std_out[ : bytes_read__std_out] )
                fmt.printf("Parent read std out:\n%v", buffer__std_out_str )
            
                // debug
                // flag_one_pass

                // perror("after first read\n")

                break
            }

            // for (bytes_read__std_out = unix2.sys_read( pipe_fd__std_out[0], buffer__std_out, len(buffer__std_out) -  1) ) > 0 {
            //     buffer__std_out[bytes_read__std_out] = '\0';
            //     fmt.printf("Parent read std out:\n%v", buffer__std_out);
            // }


            // IMPORTANT: The following code has a small error because it could
            //            read in many takes and so it should append to the bufer
            //            and not starting from zero every time.

            fmt.printf("Parent AFTER fork(), but AFTER FOR stdout, before FOR stderr.\n")


            // std_err
            buffer__std_err : [1024 * 20]u8
            bytes_read__std_err : int;

            buffer__std_err_str : string 

            // std_err
            for {
                bytes_read__std_err = unix2.sys_read(pipe_fd__std_err[0], &buffer__std_err[0], len(buffer__std_err) - 1)
                if  bytes_read__std_out <= 0 do break
                buffer__std_err[ bytes_read__std_err ] = 0    // '\0' Null Character
                buffer__std_err_str = strings.clone_from_bytes( buffer__std_err[ : bytes_read__std_err] )
                fmt.printf("Parent read std err:\n%v", buffer__std_err_str ) 
            }

            fmt.printf("Parent AFTER fork(), but AFTER FOR stdout, AFTER FOR stderr.\n")


            // Descomentar este comentário, só o coloquei para testar o código acima sem close.
            unix2.sys_close( pipe_fd__std_out[0] );
            unix2.sys_close( pipe_fd__std_err[0] );
        

            // std_out
            builder_replaced__std_out: strings.Builder = strings.builder_make_len( 1024 )
            // defer strings.builder_destroy( & builder_replaced__std_out )

            strings.write_string( & builder_replaced__std_out, "stdout: \n")
            strings.write_string( & builder_replaced__std_out, buffer__std_out_str )
            str_tmp_out_1 := strings.to_string( builder_replaced__std_out )
            str_tmp_out_1, _ = strings.replace_all( str_tmp_out_1, " ", " space " )
            str_tmp_out_1, _ = strings.replace_all( str_tmp_out_1, "\t", " tab " )
            str_tmp_out_1, _ = strings.replace_all( str_tmp_out_1, "\n", " newline " )

            string_replaced__std_out := strings.to_string( builder_replaced__std_out )


            // std_err
            builder_replaced__std_err: strings.Builder = strings.builder_make_len( 1024 )
            // defer strings.builder_destroy( & builder_replaced__std_err )

            strings.write_string( & builder_replaced__std_err, "stdout: \n")
            strings.write_string( & builder_replaced__std_err, buffer__std_err_str )
            str_tmp_err_1 := strings.to_string( builder_replaced__std_out )
            str_tmp_err_1, _ = strings.replace_all( str_tmp_err_1, " ", " space " )
            str_tmp_err_1, _ = strings.replace_all( str_tmp_err_1, "\t", " tab " )
            str_tmp_err_1, _ = strings.replace_all( str_tmp_err_1, "\n", " newline " )

            string_replaced__std_err := strings.to_string( builder_replaced__std_out )

            // fmt.printf( "%v", string_replaced__std_out );
            // fmt.printf( "%v", string_replaced__std_err );

            // Executes other child forked process the espeak-ng to speak the
            // stdout (ouput) and stdin (input) of the commando executable process.
            // The father captured the child process.
            
            speak_audio( string_replaced__std_out );

            speak_audio( string_replaced__std_err );

            // Close the replaced string builders.
            strings.builder_destroy( & builder_replaced__std_out )
            strings.builder_destroy( & builder_replaced__std_err )

            os.exit(EXIT_SUCCESS)
        }

        // Parent process
        status: i32
        flag_while_child_is_running : bool = true
        for flag_while_child_is_running {
            unix2.sys_wait4(pid, & status, 0, nil)

            if  WIFEXITED__cmacro(status) || WIFSIGNALED__cmacro(status) {
                flag_while_child_is_running = false
            }
        }
    }

  return 1;
}




// ****************************************************************

main :: proc() {
    fmt.println("Hello, World!");
    
    fmt.println("_get_ppid: %v", _get_ppid() )


    name_program_to_execute: string = "espeak-ng"


    // argv: []string = make([]string, 3)
    // argv[0] = "espeak-ng"
    // argv[1] = "--punct"
    // argv[2] = "hello"

    //    argv[3] = ">"
//    argv[4] = "bla_out.xt"


//    argv: []string = make([]string, 1)
//    argv[0] = "espeak-ng --punct 'Hello Mr Pedro Pina!'"

    // argv: []string = make([]string, 1)
    // argv[0] = "espeak-ng --punct 'Hello word!'"


    // argv[0] = "/usr/bin/espeak-ng hello"


    // argv: []string = make([]string, 1)
    // argv[0] = "ls -la > bla_out_2.txt"




/*
    espeak-ng --ponct hello

    argv[0] = "espeak-ng"
    argv[1] = "--punct"
    argv[2] = "hello"
*/

    // IMPORTANT: Functions WELL!
//    execute_program( argv )

    // IMPORTANT: Functions WELL!
    //            And the parent process waits for the child process to finish.
//    res : int = lsh_launch_first( argv )
//    fmt.println("res: %v", res)

    // IMPORTANT: Functions WELL!
    
    // argv_2: []string = make([]string, 1)
    // argv_2[0] = "espeak-ng --punct 'Hello Pina!'"
    // flag_with_pipes_active : bool = true

    // argv_2: []string = make([]string, 3)
    // argv_2[0] = "espeak-ng --punct 'Hello Mr Pedro Pina!'"
    // argv_2[1] = ";"
    // argv_2[2] = "^C"
    // flag_with_pipes_active : bool = true
    //
    // res_int := lsh_launch_second( argv_2, flag_with_pipes_active )
    // fmt.println("res_int: %v", res_int)



    // #####################
    //       Problem HERE
    // #####################

    argv_2: []string = make( []string, 1 )
    argv_2[0] = "ls -la"
    // argv_2[1] = "^D"
    // argv_2[1] = ";"
    // argv_2[2] = "^C"


    // IMPORTANT :
    // flag_with_pipes_active = false - Works well.
    // flag_with_pipes_active = true  - Doesn't Work, it blocks on the first unix2.sys_read(),
    //                                  and that is different from the behavier in the C program.
    flag_with_pipes_active : bool = true
    
    res_int := lsh_launch_second( argv_2, flag_with_pipes_active )
    fmt.println("res_int: %v", res_int)



    // for true {
    // 	fmt.println("_get_ppid: %v", _get_ppid() )
    // 	unix2.sleep(1)
    // }
}


/*

References:

Odin - Binding to C 
https://odin-lang.org/news/binding-to-c/Odin/


GitHub - Branch "more-os2"
https://github.com/jasonKercher/

Github - 
core/sys/unix/syscalls_linux.odin
https://github.com/jasonKercher/Odin/blob/more-os2/core/sys/unix/syscalls_linux.odin

GitHub - [necessary for the syscalls_linux.odin, previous reference ]
cOdin/core/sys/unix/time_unix.odin
https://github.com/jasonKercher/Odin/blob/more-os2/core/sys/unix/time_unix.odin


Github - new implementation of os2 usage of the new syscalls in more-os2 branch
core/os/os2/
https://github.com/jasonKercher/Odin/blob/more-os2/core/os/os_linux.odin





In order to see the difference, here is a line of code executing a ls -l -R -a

    with execl(3):

      execl("/bin/ls", "ls", "-l", "-R", "-a", NULL);

    with execv(3):

      char* arr[] = {"ls", "-l", "-R", "-a", NULL};
      execv("/bin/ls", arr);

The char(*)[] sent to execv will be passed to /bin/ls as argv (in int main(int argc, char **argv))






*/



/*

import "core:fmt"
import "core:c"

when ODIN_OS == .Windows do foreign import foo "foo.lib"
when ODIN_OS == .Linux   do foreign import foo "foo.a"

foreign foo {
    foo_add_int    :: proc(a, b: c.int)    -> c.int ---
    foo_add_double :: proc(a, b: c.double) -> c.double ---
}

main :: proc() {
    fmt.println(foo_add_int(2, 2))
    fmt.println(foo_add_double(2.71828, 3.14159))
}

*/


