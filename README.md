# updatehub-package-schema [![Build Status](https://travis-ci.org/updatehub/package-schema.svg?branch=master)](https://travis-ci.org/updatehub/package-schema) [![Coverage Status](https://coveralls.io/repos/github/UpdateHub/package-schema/badge.svg?branch=master)](https://coveralls.io/github/UpdateHub/package-schema?branch=master)

UpdateHub package schema validator for Python

## Installing

    pip install updatehub-package-schema

## Usage

Simply call `validate_metadata` with your package metadata as a Python
dict. `validate_metadata` will raise `pkgschema.ValidationError` if
something is wrong with your package, otherwise it will return `None`.

```python
from pkgschema import validate_metadata

metadata = {}  # the package metadata must be a Python dict

validate_metadata(metadata)
```

## License

updatehub-package-schema is released under MIT license.
