#!/usr/bin/env python3

from argparse import ArgumentParser

def main():
    parser = ArgumentParser()
    parser.add_argument('size', type=int, help='output file size')
    parser.add_argument('chunk_size', type=int)
    parser.add_argument('output', type=str)

    args = parser.parse_args()

    gen(args.size, args.chunk_size, args.output)

def gen(size: int, chunk_size: int, output: str):
    if (size % chunk_size) != 0:
        raise ValueError(f'size={size} must be divided by chunk_size={chunk_size}')

    amount_of_chunks = size // chunk_size

    print(f'size = {size} | chunk_size = {chunk_size} | amount_of_chunks = {amount_of_chunks}')

    with open(output, 'wb') as f:
        # 256mb ram with 128k chunks took 16.120
        for chunk_index in range(amount_of_chunks):
            chunk_index = chunk_index % 0xff
            chunk_data = bytes([chunk_index+1 for _ in range(chunk_size)])
            f.write(chunk_data)

if __name__ == '__main__':
    main()
