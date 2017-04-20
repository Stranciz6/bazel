# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""This tool build tar files from a list of inputs."""

import os
import os.path
import sys
import tarfile
import tempfile

from tools.build_defs.pkg import archive
from third_party.py import gflags

gflags.DEFINE_string('output', None, 'The output file, mandatory')
gflags.MarkFlagAsRequired('output')

gflags.DEFINE_multistring('file', [], 'A file to add to the layer')

gflags.DEFINE_string(
    'mode', None, 'Force the mode on the added files (in octal).')

gflags.DEFINE_multistring('tar', [], 'A tar file to add to the layer')

gflags.DEFINE_multistring('deb', [], 'A debian package to add to the layer')

gflags.DEFINE_multistring(
    'link', [],
    'Add a symlink a inside the layer ponting to b if a:b is specified')
gflags.RegisterValidator(
    'link',
    lambda l: all(value.find(':') > 0 for value in l),
    message='--link value should contains a : separator')

gflags.DEFINE_string(
    'directory', None, 'Directory in which to store the file inside the layer')

gflags.DEFINE_string(
    'compression', None, 'Compression (`gz` or `bz2`), default is none.')

gflags.DEFINE_multistring(
    'modes', None,
    'Specific mode to apply to specific file (from the file argument),'
    ' e.g., path/to/file=0455.')

gflags.DEFINE_multistring('owners', None,
                          'Specify the numeric owners of individual files, '
                          'e.g. path/to/file=0.0.')

gflags.DEFINE_string('owner', '0.0',
                     'Specify the numeric default owner of all files,'
                     ' e.g., 0.0')

gflags.DEFINE_string('owner_name', None,
                     'Specify the owner name of all files, e.g. root.root.')

gflags.DEFINE_multistring('owner_names', None,
                          'Specify the owner names of individual files, e.g. '
                          'path/to/file=root.root.')

FLAGS = gflags.FLAGS


class TarFile(object):
  """A class to generates a Docker layer."""

  class DebError(Exception):
    pass

  def __init__(self, output, directory, compression):
    self.directory = directory
    self.output = output
    self.compression = compression

  def __enter__(self):
    self.tarfile = archive.TarFileWriter(self.output, self.compression)
    return self

  def __exit__(self, t, v, traceback):
    self.tarfile.close()

  def add_file(self, f, destfile, mode=None, ids=None, names=None):
    """Add a file to the tar file.

    Args:
       f: the file to add to the layer
       destfile: the name of the file in the layer
       mode: force to set the specified mode, by
          default the value from the source is taken.
       ids: (uid, gid) for the file to set ownership
       names: (username, groupname) for the file to set ownership.
    `f` will be copied to `self.directory/destfile` in the layer.
    """
    dest = destfile.lstrip('/')  # Remove leading slashes
    if self.directory and self.directory != '/':
      dest = self.directory.lstrip('/') + '/' + dest
    # If mode is unspecified, derive the mode from the file's mode.
    if mode is None:
      mode = 0o755 if os.access(f, os.X_OK) else 0o644
    if ids is None:
      ids = (0, 0)
    if names is None:
      names = ('', '')
    self.tarfile.add_file(
        dest,
        file_content=f,
        mode=mode,
        uid=ids[0],
        gid=ids[1],
        uname=names[0],
        gname=names[1])

  def add_tar(self, tar):
    """Merge a tar file into the destination tar file.

    All files presents in that tar will be added to the output file
    under self.directory/path. No user name nor group name will be
    added to the output.

    Args:
      tar: the tar file to add
    """
    root = None
    if self.directory and self.directory != '/':
      root = self.directory
    self.tarfile.add_tar(tar, numeric=True, root=root)

  def add_link(self, symlink, destination):
    """Add a symbolic link pointing to `destination`.

    Args:
      symlink: the name of the symbolic link to add.
      destination: where the symbolic link point to.
    """
    self.tarfile.add_file(symlink, tarfile.SYMTYPE, link=destination)

  def add_deb(self, deb):
    """Extract a debian package in the output tar.

    All files presents in that debian package will be added to the
    output tar under the same paths. No user name nor group names will
    be added to the output.

    Args:
      deb: the tar file to add

    Raises:
      DebError: if the format of the deb archive is incorrect.
    """
    with archive.SimpleArFile(deb) as arfile:
      current = arfile.next()
      while current and not current.filename.startswith('data.'):
        current = arfile.next()
      if not current:
        raise self.DebError(deb + ' does not contains a data file!')
      tmpfile = tempfile.mkstemp(suffix=os.path.splitext(current.filename)[-1])
      with open(tmpfile[1], 'wb') as f:
        f.write(current.data)
      self.add_tar(tmpfile[1])
      os.remove(tmpfile[1])


def main(unused_argv):
  # Parse modes arguments
  default_mode = None
  if FLAGS.mode:
    # Convert from octal
    default_mode = int(FLAGS.mode, 8)

  mode_map = {}
  if FLAGS.modes:
    for filemode in FLAGS.modes:
      (f, mode) = filemode.split('=', 1)
      if f[0] == '/':
        f = f[1:]
      mode_map[f] = int(mode, 8)

  default_ownername = ('', '')
  if FLAGS.owner_name:
    default_ownername = FLAGS.owner_name.split('.', 1)
  names_map = {}
  if FLAGS.owner_names:
    for file_owner in FLAGS.owner_names:
      (f, owner) = file_owner.split('=', 1)
      (user, group) = owner.split('.', 1)
      if f[0] == '/':
        f = f[1:]
      names_map[f] = (user, group)

  default_ids = FLAGS.owner.split('.', 1)
  default_ids = (int(default_ids[0]), int(default_ids[1]))
  ids_map = {}
  if FLAGS.owners:
    for file_owner in FLAGS.owners:
      (f, owner) = file_owner.split('=', 1)
      (user, group) = owner.split('.', 1)
      if f[0] == '/':
        f = f[1:]
      ids_map[f] = (int(user), int(group))

  # Add objects to the tar file
  with TarFile(FLAGS.output, FLAGS.directory, FLAGS.compression) as output:
    for f in FLAGS.file:
      (inf, tof) = f.split('=', 1)
      mode = default_mode
      ids = default_ids
      names = default_ownername
      map_filename = tof
      if tof[0] == '/':
        map_filename = tof[1:]
      if map_filename in mode_map:
        mode = mode_map[map_filename]
      if map_filename in ids_map:
        ids = ids_map[map_filename]
      if map_filename in names_map:
        names = names_map[map_filename]
      output.add_file(inf, tof, mode, ids, names)
    for tar in FLAGS.tar:
      output.add_tar(tar)
    for deb in FLAGS.deb:
      output.add_deb(deb)
    for link in FLAGS.link:
      l = link.split(':', 1)
      output.add_link(l[0], l[1])


if __name__ == '__main__':
  main(FLAGS(sys.argv))
