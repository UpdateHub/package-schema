import json
from collections import OrderedDict

from jsonschema import RefResolver
from jsonschema.compat import urlopen, urlsplit


class OrderedRefResolver(RefResolver):

    def resolve_remote(self, uri):
        '''
        Basically the same code provided by RefResolver, but we use
        OrderedDict as base class to load json documents.
        '''
        scheme = urlsplit(uri).scheme
        if scheme in self.handlers:
            result = self.handlers[scheme](uri)
        elif (
            scheme in [u"http", u"https"] and
            requests and
            getattr(requests.Response, "json", None) is not None
        ):
            if callable(requests.Response.json):
                result = requests.get(uri).json()
            else:
                result = requests.get(uri).json
        else:
            result = json.loads(
                urlopen(uri).read().decode("utf-8"),
                object_pairs_hook=OrderedDict)
        if self.cache_remote:
            self.store[uri] = result
        return result
