# Copyright (C) 2017 O.S. Systems Software LTDA.
# SPDX-License-Identifier: MIT

import os
import shutil
import subprocess

import pkg_resources
from setuptools import setup


__version__ = '1.0.0'


setup(
    name='updatehub-package-schema',
    description='UpdateHub package schema validator for Python',
    version=__version__,
    packages=['pkgschema'],
    package_data={
        'pkgschema': ['schemas/*.json'],
    },
    install_requires=[
        'jsonschema>=2.3.0',
        'rfc3987>=1.3',
    ],
    author='O.S. Systems Software LTDA',
    author_email='contato@ossystems.com.br',
    url='http://www.ossystems.com.br',
    license='MIT',
    zip_safe=False,
)
