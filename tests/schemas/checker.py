#!/usr/bin/env python

# Copyright (C) 2017 O.S. Systems Software LTDA.
# This software is released under the MIT License

import json
import os
from collections import OrderedDict

from jsonschema import exceptions, Draft4Validator, FormatChecker

from refresolver import OrderedRefResolver


ROOT_DIR = os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCHEMAS_DIR = os.path.join(ROOT_DIR, 'pkgschema', 'schemas')
FIXTURES_DIR = os.path.join(ROOT_DIR, 'tests/schemas/fixtures')


def load(document):
    with open(document) as fp:
        return json.load(fp, object_pairs_hook=OrderedDict)


def validate_schema(schema):
    try:
        Draft4Validator.check_schema(schema)
    except exceptions.SchemaError as err:
        return err.message


def validate_document(schema, document, expected, error=None):
    base_uri = 'file://{}/'.format(SCHEMAS_DIR)
    resolver = OrderedRefResolver(base_uri, schema)
    format_checker = FormatChecker(formats=['uri'])
    validator = Draft4Validator(
        schema, resolver=resolver, format_checker=format_checker)
    msg = None
    try:
        validator.validate(document)
        result = 'VALID'
        msg = 'Document is valid'
    except exceptions.ValidationError as err:
        result = 'INVALID'
        msg = '{}: {}'.format('/'.join(err.schema_path), err.message)

    if result == 'VALID' and expected == 'VALID':
        return None

    if result != expected or msg != error:
        return msg


def main(schema, document, expected, error=None):
    with open('/tmp/efu', 'w') as fp:
        fp.write(os.getcwd())
        fp.write('\n')
        fp.write(ROOT_DIR)
    schema = load(os.path.join(SCHEMAS_DIR, schema))
    schema_result = validate_schema(schema)
    if schema_result is not None:
        print(schema_result)
        return 1

    document = load(os.path.join(FIXTURES_DIR, document))
    document_result = validate_document(schema, document, expected, error)
    if document_result is not None:
        print(document_result)
        return 1
    return 0


if __name__ == '__main__':
    import sys
    sys.exit(main(*sys.argv[1:]))
