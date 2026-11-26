#!/usr/bin/env python3

from argparse import ArgumentParser
from multiprocessing import Process
from os import SEEK_CUR, SEEK_SET
import subprocess
import mmap
import time

def get_blkdev_size(blkdev: str) -> int:
    out = subprocess.check_output(['blockdev', '--getsize64', blkdev]).decode().strip()
    return int(out)

def main():
    parser = ArgumentParser('Write double sprased on a block file to waste thin provisioning')

    parser.add_argument('output_block_file', help='Block file to write to', type=str)
    parser.add_argument('--single_sparse', help='Write sparsed once (for debug)', action='store_true')
    parser.add_argument('--amount', help='Amount of sparsed block to write, if not mentioned all block device is filled', type=int)
    parser.add_argument('--threads', help='Amount of threads to write with', type=int, default=8)
    parser.add_argument('--chunk_size', help='Chunk size to write sparsed, default is the lower LVM chunk size', type=int, default=128 * 1024)
    parser.add_argument('--skip_first', help='Skip first sparse iteration (skipping even blocks)', action='store_true')

    args = parser.parse_args()

    # Get inputs
    dev_size = get_blkdev_size(args.output_block_file)
    max_amount = dev_size // args.chunk_size

    amount = args.amount
    if amount is None:
        amount = max_amount
    else:
        assert amount < max_amount, "Amount is bigger than the max amount"

    print('Blocks amount: ', amount)
    print('Threads amount: ', args.threads)
    print('')

    assert amount % args.threads == 0, "Amount of threads must be divided by the amount of blocks to write"

    amount_per_thread = amount // args.threads

    if not args.skip_first:
        print('Writing to all even blocks')
        write_sparsed_deffered(0, args.output_block_file, args.threads, amount_per_thread, args.chunk_size)

        subprocess.check_call(['sync'])

        if args.single_sparse:
            return

        time.sleep(5) # Wait 5 secs for good measure

    print('Writing to all odd blocks')
    write_sparsed_deffered(1, args.output_block_file, args.threads, amount_per_thread, args.chunk_size)
    subprocess.check_call(['sync'])

def write_sparsed_deffered(start_offset: int, blkdev: str, threads: int, amount_per_thread: int, full_chunk_size: int):
    amount_per_thread_sparsed = amount_per_thread // 2

    processes = []
    offset = start_offset
    for i in range(threads):
        p = Process(target=writer, args=(i, blkdev, offset, amount_per_thread_sparsed, full_chunk_size))
        p.start()
        processes.append(p)

        offset += amount_per_thread

    for p in processes:
        p.join()

def writer(thread_id: int, blkdev: str, start_offset: int, amount: int, chunk_size: int):
    print(f'Starting writer #{thread_id}, start_offset: {start_offset}, chunk_size: {chunk_size}, amount: {amount}')
    page = alloc_aligned_page()
    start_byte = start_offset * chunk_size
    sparsed_chunk_size = chunk_size * 2
    progress_counter = 0
    progress_counter_loops = 0
    try:
        with open(blkdev, 'wb') as out:
            for i in range(amount):
                out.seek(start_byte + (sparsed_chunk_size * i), SEEK_SET)
                out.write(page)
                progress_counter += 1
                if progress_counter == 10000:
                    print(f'Thread #{thread_id} written {progress_counter_loops * 10000}/{amount}')
                    progress_counter_loops += 1
                    progress_counter = 0
    finally:
        page.close()

def alloc_aligned_page():
    SIZE = 4 * 1024
    data = b'\x5a'*SIZE
    buf = mmap.mmap(-1, SIZE, mmap.MAP_SHARED)
    buf.seek(0)
    buf.write(data)
    return buf

if __name__ == '__main__':
    main()
