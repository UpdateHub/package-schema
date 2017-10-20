# Copyright (C) 2017 O.S. Systems Software LTDA.
# SPDX-License-Identifier: MIT

import json
import os

from jsonschema import Draft4Validator, FormatChecker, RefResolver, exceptions


SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), 'schemas')


class ValidationError(exceptions.ValidationError):

    def __init__(self, err):
        self._err = err

    def __str__(self):
        return str(self._err)


def validate_schema(schema_fn, obj):
    base_uri = 'file://{}/'.format(SCHEMAS_DIR)
    with open(os.path.join(SCHEMAS_DIR, schema_fn)) as fp:
        schema = json.load(fp)
    resolver = RefResolver(base_uri, schema)
    format_checker = FormatChecker(formats=['uri'])
    validator = Draft4Validator(
        schema, resolver=resolver, format_checker=format_checker)
    try:
        validator.validate(obj)
    except exceptions.ValidationError as err:
        raise ValidationError(err)


def validate_objects_filenames(objects):
    sets = [[obj['filename'] for obj in sets] for sets in objects]
    for set_ in sets:
        if set_ != sets[0]:
            error = 'Objects filenames are different between sets'
            raise ValidationError(error)


def validate_metadata(metadata):
    """Validates a package metadata against package schema.

    Returns None if valid, else raises ValidationError.
    """
    validate_schema('metadata.json', metadata)
    validate_objects_filenames(metadata['objects'])
