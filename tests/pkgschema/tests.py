# Copyright (C) 2017 O.S. Systems Software LTDA.
# SPDX-License-Identifier: MIT

import json
import os
import tempfile
import unittest

import pkgschema


def get_fixture_metadata():
    fn = os.path.join(os.path.dirname(__file__), 'fixture-metadata.json')
    with open(fn) as fp:
        return json.load(fp)


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
        metadata = get_fixture_metadata()
        self.assertIsNone(pkgschema.validate_metadata(metadata))

    def test_validate_raises_error_when_metadata_is_invalid(self):
        with self.assertRaises(pkgschema.ValidationError):
            pkgschema.validate_metadata({})

    def test_validate_raises_error_when_filenames_are_invalid(self):
        metadata = get_fixture_metadata()
        metadata['objects'].append(metadata['objects'][0][::-1])
        metadata['objects'][0][0]['filename'] = 'another'
        with self.assertRaises(pkgschema.ValidationError):
            pkgschema.validate_metadata(metadata)


class FilenamesObjectsValidatorTestCase(unittest.TestCase):

    def test_returns_None_if_valid(self):
        objects = get_fixture_metadata()['objects']
        self.assertIsNone(pkgschema.validate_objects_filenames(objects))

    def test_raises_error_if_filename_diverges_across_sets(self):
        obj1 = {'filename': 'foo'}
        obj2 = {'filename': 'bar'}
        objects = [[obj1], [obj2]]
        with self.assertRaises(pkgschema.ValidationError):
            pkgschema.validate_objects_filenames(objects)

    def test_returns_None_if_other_options_are_different(self):
        obj1 = {'filename': 'bar', 'option': 1}
        obj2 = {'filename': 'bar', 'option': 2}
        objects = [[obj1], [obj2]]
        self.assertIsNone(pkgschema.validate_objects_filenames(objects))
