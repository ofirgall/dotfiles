#!/usr/bin/env python3

# input example: segfault.py "kern   [   11.849879] apc-modbus-hid[6572]: segfault at 0 ip 00007f5ed0ed7dee sp 00007fff22f7faa0 error 4 in libusb-0.1.so.4.4.4[7f5ed0ed5000+4000]"


import argparse
import re

# ANSI Colors to avoid using 3rd party package
class bcolors:
    """ ANSI color codes """
    BLACK = "\033[0;30m"
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    BROWN = "\033[0;33m"
    BLUE = "\033[0;34m"
    PURPLE = "\033[0;35m"
    CYAN = "\033[0;36m"
    LIGHT_GRAY = "\033[0;37m"
    DARK_GRAY = "\033[1;30m"
    LIGHT_RED = "\033[1;31m"
    LIGHT_GREEN = "\033[1;32m"
    YELLOW = "\033[1;33m"
    LIGHT_BLUE = "\033[1;34m"
    LIGHT_PURPLE = "\033[1;35m"
    LIGHT_CYAN = "\033[1;36m"
    LIGHT_WHITE = "\033[1;37m"
    BOLD = "\033[1m"
    FAINT = "\033[2m"
    ITALIC = "\033[3m"
    UNDERLINE = "\033[4m"
    BLINK = "\033[5m"
    NEGATIVE = "\033[7m"
    CROSSED = "\033[9m"
    END = "\033[0m"

def translate_error(err):
    """
    Page fault error code bits:

    bit 0 ==    0: no page found       1: protection fault
    bit 1 ==    0: read access         1: write access
    bit 2 ==    0: kernel-mode access  1: user-mode access
    bit 3 ==                           1: use of reserved bit detected
    bit 4 ==                           1: fault was an instruction fetch
    """
    read_write = f'write{bcolors.END} to' if (err & (1 << 1)) else f'read{bcolors.END} from'
    kernel_user = 'user' if (err & (1 << 2)) else 'kernel'

    read_write = f'{bcolors.LIGHT_BLUE}{read_write}'
    kernel_user = f'{bcolors.LIGHT_PURPLE}{kernel_user}{bcolors.END}'

    if err & (1 << 4): # prefetch
        return f'{kernel_user} prefetch'

    return f'{kernel_user} tried to {read_write}'

def main():
    parser = argparse.ArgumentParser()
    segfault_line = ' '.join(parser.parse_known_args()[1])

    res = re.match('.?segfault at (.+?) ip (.+?) sp (.+?) error (.+?) in (.+?)\[(.+?)\+', segfault_line, flags=re.DOTALL)
    # print(res.groups())
    access_addr, ip, sp, error, lib, lib_load_addr = res.groups()
    access_addr = int(access_addr, 16)
    ip = int(ip, 16)
    sp = int(sp, 16)
    error = int(error, 10)
    lib_load_addr = int(lib_load_addr, 16)

    print(f'\nThe {translate_error(error)} {bcolors.LIGHT_RED}{hex(access_addr)}{bcolors.END} at {bcolors.LIGHT_CYAN}{hex(ip - lib_load_addr)}{bcolors.END}@{bcolors.LIGHT_GREEN}{lib}')
    print(f'{bcolors.LIGHT_PURPLE}Note: you can use `addr2line` (if debug symbols exist) or `objdump` to debug the problem.')


if __name__ == '__main__':
    main()
