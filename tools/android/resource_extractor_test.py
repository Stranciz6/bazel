# Copyright 2016 The Bazel Authors. All rights reserved.
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

"""Tests for resource_extractor."""

import StringIO
import unittest
import zipfile

from tools.android import resource_extractor


class ResourceExtractorTest(unittest.TestCase):
  """Unit tests for resource_extractor.py."""

  def testJarWithEverything(self):
    input_jar = zipfile.ZipFile(StringIO.StringIO(), "w")

    for path in (
        # Should not be included
        "foo.aidl",
        "tmp/foo.aidl",
        "tmp/foo.java",
        "tmp/foo.java.swp",
        "tmp/foo.class",
        "tmp/flags.xml",
        "tilde~",
        "tmp/flags.xml~",
        ".gitignore",
        "tmp/.gitignore",
        "META-INF/",
        "tmp/META-INF/",
        "META-INF/MANIFEST.MF",
        "tmp/META-INF/services/foo",
        "bar/",
        "CVS/bar/",
        "tmp/CVS/bar/",
        ".svn/CVS/bar/",
        "tmp/.svn/CVS/bar/",
        # Should be included
        "bar/a",
        "a/b",
        "c",
        "a/not_package.html",
        "not_CVS/include",
        "META-INF/services/foo"):
      input_jar.writestr(path, "")
    output_zip = zipfile.ZipFile(StringIO.StringIO(), "w")
    resource_extractor.ExtractResources(input_jar, output_zip)
    self.assertItemsEqual(("c", "a/b", "bar/a", "a/not_package.html",
                           "not_CVS/include", "META-INF/services/foo"),
                          output_zip.namelist())


if __name__ == "__main__":
  unittest.main()
