![Tests](https://github.com/UpdateHub/package-schema/workflows/CI/badge.svg)
[![PyPI](https://img.shields.io/pypi/v/updatehub-package-schema)](https://pypi.python.org/pypi/package-schema/)

# updatehub-package-schema

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
