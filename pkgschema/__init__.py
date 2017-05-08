# Copyright (C) 2017 O.S. Systems Software LTDA.
# This software is released under the MIT License

import json
import os

from jsonschema import Draft4Validator, FormatChecker, RefResolver


SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), 'schemas')


def validate_schema(schema_fn, obj):
    base_uri = 'file://{}/'.format(SCHEMAS_DIR)
    with open(os.path.join(SCHEMAS_DIR, schema_fn)) as fp:
        schema = json.load(fp)
    resolver = RefResolver(base_uri, schema)
    format_checker = FormatChecker(formats=['uri'])
    validator = Draft4Validator(
        schema, resolver=resolver, format_checker=format_checker)
    return validator.validate(obj)


def validate_metadata(metadata):
    """Validates a package metadata against package schema.

    Returns None if valid, else raises ValidationError.
    """
    return validate_schema('metadata.json', metadata)
