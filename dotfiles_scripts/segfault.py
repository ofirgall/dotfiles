#!/usr/bin/env python3

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
    print(f'Error at {hex(ip - lib_load_addr)}@{lib}')

if __name__ == '__main__':
    main()
