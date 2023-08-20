# better_pina_shell - A better screen reader shell for Linux
A Odin screen reader shell for Linux that speaks the stdin, the stdout and the stderr. Made with in the Odin programming language and still in development.

## Description: 
A screen reader shell for Linux that speaks with the open source espeak-ng TTS, the stdin, the stdout and the stderr. \br
The better_pina_shell is a reimplementation of the fork pina_shell that I made from the lsh (Libstephen Shell) shell, with many improvements.

## Current problem

``` 
#####################
     Problem HERE
#####################
```
Currently there is a problem with the unix2.sys_read() system call inside this code. It simply blocks the program, and that behavior is different from the original C code. \br
But the 2 codes are identical, and I don't know why this is happening. I posted this problem here to see knows why there is a difference in the behavior between the Odin's and C code.

## Other files used:
The files: ```sys/uni2/syscalls_linux.odin``` and ```sys/unix2/time_unix.odin``` are pre release of the core:sys:unix:syscalls_linux.odin and there link are:

```
Odin - Binding to C 
https://odin-lang.org/news/binding-to-c/Odin/

GitHub - Branch "more-os2"
https://github.com/jasonKercher/

Github -  more-os2 branch
core/sys/unix/syscalls_linux.odin
https://github.com/jasonKercher/Odin/blob/more-os2/core/sys/unix/syscalls_linux.odin

GitHub - [necessary for the syscalls_linux.odin, previous reference ]
cOdin/core/sys/unix/time_unix.odin
https://github.com/jasonKercher/Odin/blob/more-os2/core/sys/unix/time_unix.odin

Github - new implementation of os2 usage of the new syscalls in more-os2 branch
core/os/os2/
https://github.com/jasonKercher/Odin/blob/more-os2/core/os/os_linux.odin
```

## Other

```
TTS:    you need to install the espeak-ng TTS for linux. 

to compile: $ odin build .
  
to run:     $ ./better_pina_shell

file:   better_pina_shell.c

author: Original      280 lines Stephen Brennan ( very simples c code Shell )
        Current C    1120 lines João Carvalho  ( A screen reader shell )
        Current Odin ???? lines João Carvalho  ( A even better screen reader shell )

url:    Original - Stephen Brennan - Tutorial - Write a Shell in C
        https://brennan.io/2015/01/16/write-a-shell-in-c/
          
        github - brenns10 / lsh
        https://github.com/brenns10/lsh

        Current in C:
        Github  - joaocarvalhoopen - pina_shell
        https://github.com/joaocarvalhoopen/pina_shell--A-screen-reader-shell-for-Linux

        Current in Odin:
        Github  - joaocarvalhoopen - better_pina_shell
        https://github.com/joaocarvalhoopen/better_pina_shell--A-better-screen-reader-shell-for-Linux

date:   Original:        Thursday,  8 January 2015
        Current in C:    Saturday,  18 August 2023
        Current in Odin: Saturday,  20 August 2023

brief:  Original:         LSH (Libstephen Shell)
        Current in C :    pina_shell        ( A screen reader shell for Linux )
        Current in Odin : better_pina_shell ( A screen reader shell for Linux )
```

## License
MIT Open Source License

## Best regards
Joao Carvalho

