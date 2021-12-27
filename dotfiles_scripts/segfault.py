#!/usr/bin/env python3

# input example: segfault.py "kern   [   11.849879] apc-modbus-hid[6572]: segfault at 0 ip 00007f5ed0ed7dee sp 00007fff22f7faa0 error 4 in libusb-0.1.so.4.4.4[7f5ed0ed5000+4000]"


import argparse
import re

def main():
    parser = argparse.ArgumentParser()
    segfault_line = ' '.join(parser.parse_known_args()[1])

    res = re.match('.+segfault at (.+?) ip (.+?) sp (.+?) error (.+?) in (.+?)\[(.+?)\+', segfault_line, flags=re.DOTALL)
    # print(res.groups())
    access_addr, ip, sp, error, lib, lib_load_addr = res.groups()
    access_addr = int(access_addr, 16)
    ip = int(ip, 16)
    sp = int(sp, 16)
    error = int(error, 10)
    lib_load_addr = int(lib_load_addr, 16)

    # TODO: Parse error + read/write address
    # TODO: Add some guidance how to dissassemble
    print(f'Error at {hex(ip - lib_load_addr)}@{lib}')

if __name__ == '__main__':
    main()
