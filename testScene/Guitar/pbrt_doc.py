#!/usr/bin/env python3

import argparse
import os
import shutil
import subprocess
import sys

COMMAND_TEMPLATE = '{exe} {scenefile} --outfile {outfile} {options}'
COMMENT_CHAR = '# '
DEFAULT_EXE = 'pbrt_rgb'
OUTPUT_EXTENSION = '.png'


def _folder_exists(path_to_folder):
    exists = os.path.exists(path_to_folder)
    is_dir = os.path.isdir(path_to_folder)
    return exists and is_dir


def _find_version_num(path_to_folder, base_filename):
    """
    Search folder for files that start with `base_filename` and find the highest
    version number. Assumes that the folder exists.
    """
    try:
        file_suffixes = [os.path.splitext(f.replace(base_filename, ''))[0]
                         for f in os.listdir(path_to_folder) if base_filename in f]
        file_nums = [int(s) for s in file_suffixes if s.isdigit()]
    except ValueError as e:
        print('Something went wrong when looking for the current version number.'
              'Did you rename files in the ooutput folder or generate them without this script?')
        print(str(e))
        sys.exit()
    if len(file_nums) > 0:
        return max(file_nums)
    else:
        return 0


def _copy_scenefile_with_comment(source, comment, destination):
    """
    Copy file to folder and add the comment at the top
    """
    if comment:
        with open(source, 'r') as f:
            old_file = f.read()
        # in the unlikely event of the comment containing newlines...
        # maybe when reading comment from a file or smthg
        comment_lines = comment.split('\n')
        with open(destination, 'w') as f:
            for line in comment_lines:
                f.write(COMMENT_CHAR + line + '\n')
            f.write(old_file)
    else:
        shutil.copy(source, destination)


def _cleanup(scenefile):
    if os.path.exists(scenefile):
        os.remove(scenefile)


def main(args):
    input_scenefile = os.path.expanduser(args.scene_file)
    args.ext = os.path.splitext(args.scene_file)
    args.scene_file = args.ext[0]
    args.ext = args.ext[1]
    args.output_folder = os.path.expanduser(args.output_folder)
    args.pbrt_exe = os.path.expanduser(args.pbrt_exe)
    args.suffix = ''.join(args.suffix.split())

    if not args.output_folder:
        args.output_folder = args.scene_file

    if _folder_exists(args.output_folder):
        if not args.suffix:
            args.suffix = str(_find_version_num(args.output_folder, args.scene_file) + 1)
    else:
        # create folder and start version at one
        os.mkdir(args.output_folder)
        args.suffix = str(1)

    # parse the given options
    template = '--{}'
    options = [template.format(opt) for opt in args.options.split()]

    # assemble scenefile destination
    args.scenefile_out = os.path.join(args.output_folder,
                                      args.scene_file + args.suffix + args.ext)
    # safety check if scenefile already exists
    if os.path.exists(args.scenefile_out):
        print(args.scenefile_out + ' already exists. Overwrite?')
        answer = input('Y/N')
        if answer.lower() != 'y':
            sys.exit()

    # assemble command for pbrt invocation
    args.outfile = os.path.join(args.output_folder,
                                args.scene_file + args.suffix + OUTPUT_EXTENSION)
    command = COMMAND_TEMPLATE.format(exe=args.pbrt_exe,
                                      scenefile=input_scenefile,
                                      outfile=args.outfile,
                                      options=' '.join(options))
    # copy the scene file and add comment if given
    _copy_scenefile_with_comment(input_scenefile, args.comment, args.scenefile_out)

    # execute command
    print("Calling: " + command)
    subprocess.call(command, shell=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('scene_file', type=str, help='Input file for pbrt executable')
    parser.add_argument('-f', '--output_folder', type=str, default='',
                        help='Folder for pbrt output')
    parser.add_argument('-s', '--suffix', type=str, default='',
                        help='Append this to output files instead of number')
    parser.add_argument('-c', '--comment', type=str, default='',
                        help='Add this comment on top of the scene file copy')
    parser.add_argument('-e', '--pbrt_exe', type=str, default=DEFAULT_EXE,
                        help='executable to use')
    parser.add_argument('-o', '--options', type=str, default='',
                        help='Options to pass to the pbrt exe, '
                             'separated by spaces and WITHOUT leading dashes')
    args = parser.parse_args()

    try:
        main(args)
    except KeyboardInterrupt:
        # delete the copied scenefile if aborting manually to avoid orphaned files
        _cleanup(args.scenefile_out)
