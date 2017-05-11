# Copyright (C) 2017 O.S. Systems Software LTDA.
# SPDX-License-Identifier: MIT

import json
import os
import tempfile
import unittest

import pkgschema


class BaseTestCase(unittest.TestCase):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.addCleanup(self.clean)
        self._files = []

    def clean(self):
        while self._files:
            self.remove_file(self._files.pop())

    def create_file(self, content=None):
        if not isinstance(content, bytes):
            content = content.encode()
        _, fn = tempfile.mkstemp()
        self._files.append(fn)
        with open(fn, 'bw') as fp:
            fp.write(content)
        return fn

    def remove_file(self, fn):
        try:
            os.remove(fn)
        except FileNotFoundError:
            pass  # already deleted


class JSONSchemaValidatorTestCase(BaseTestCase):

    def setUp(self):
        self.schema = self.create_file(json.dumps({
            'type': 'object',
            'properties': {
                'test': {
                    'type': 'string',
                }
            },
            'additionalProperties': False,
            'required': ['test']
        }).encode())

    def test_validate_returns_None_when_valid(self):
        obj = {'test': 'ok'}
        self.assertIsNone(pkgschema.validate_schema(self.schema, obj))

    def test_validate_raises_error_when_invalid(self):
        with self.assertRaises(pkgschema.ValidationError):
            pkgschema.validate_schema(self.schema, {})
        with self.assertRaises(pkgschema.ValidationError):
            pkgschema.validate_schema(self.schema, {'test': 1})
        with self.assertRaises(pkgschema.ValidationError):
            pkgschema.validate_schema(self.schema, {'test': 'ok', 'extra': 2})

    def test_exception_string_returns_string(self):
        try:
            pkgschema.validate_schema(self.schema, {})
        except pkgschema.ValidationError as err:
            self.assertIsInstance(str(err), str)


class PackageSchemaValidatorTestCase(BaseTestCase):

    def test_validate_returns_None_when_valid(self):
        fn = os.path.join(os.path.dirname(__file__), 'fixture-metadata.json')
        with open(fn) as fp:
            obj = json.load(fp)
        self.assertIsNone(pkgschema.validate_metadata(obj))

    def test_validate_raises_error_when_invalid(self):
        with self.assertRaises(pkgschema.ValidationError):
            pkgschema.validate_metadata({})
