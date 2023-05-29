#!/usr/bin/env python3

fields = [
    'name',
    'con-bounces',
    'contentions',
    'waittime-min',
    'waittime-max',
    'waittime-total',
    'waittime-avg',
    'acq-bounces',
    'acquisitions',
    'holdtime-min',
    'holdtime-max',
    'holdtime-total',
    'holdtime-avg',
]

from argparse import ArgumentParser
from prettytable import PrettyTable, prettytable


def line_to_tuple(line: str):
    name, line = line.split(':  ')
    values = [float(value) for value in line.split()]
    values.insert(0, name.strip())

    return values

def main():
    parser = ArgumentParser()
    parser.add_argument('file')
    parser.add_argument('sort_by', choices=fields)

    args = parser.parse_args()
    sort_by_index = fields.index(args.sort_by)

    with open(args.file, 'r') as f:
        content = [line_to_tuple(line) for line in f.readlines()]

    content = sorted(content, key=lambda lock:lock[sort_by_index], reverse=True)
    table = PrettyTable()
    table.field_names = fields
    table.add_rows(content)
    table.del_column('con-bounces')
    table.hrules = prettytable.ALL
    table.set_style(prettytable.SINGLE_BORDER)

    print(table)

if __name__ == '__main__':
    main()
