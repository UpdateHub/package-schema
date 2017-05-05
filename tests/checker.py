#!/usr/bin/env python

# Copyright (C) 2017 O.S. Systems Software LTDA.
# This software is released under the MIT License

import json
import os
from collections import OrderedDict

from jsonschema import exceptions, Draft4Validator, FormatChecker

from refresolver import OrderedRefResolver


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load(document):
    with open(document) as fp:
        return json.load(fp, object_pairs_hook=OrderedDict)


def validate_schema(schema):
    try:
        Draft4Validator.check_schema(schema)
    except exceptions.SchemaError as err:
        return err.message


def validate_document(schema, document, expected, error=None):
    base_uri = 'file://{}/'.format(os.path.abspath('schemas'))
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
    os.chdir(BASE_DIR)
    schema = load(os.path.join('schemas', schema))
    schema_result = validate_schema(schema)
    if schema_result is not None:
        print(schema_result)
        return 1

    document = load(os.path.join('tests', 'fixtures', document))
    document_result = validate_document(schema, document, expected, error)
    if document_result is not None:
        print(document_result)
        return 1
    return 0


if __name__ == '__main__':
    import sys
    sys.exit(main(*sys.argv[1:]))
