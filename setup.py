import os
import shutil
from setuptools import setup


setup(
    name='updatehub-package-schema',
    description='UpdateHub package schema validator for Python',
    version='1.0',
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
