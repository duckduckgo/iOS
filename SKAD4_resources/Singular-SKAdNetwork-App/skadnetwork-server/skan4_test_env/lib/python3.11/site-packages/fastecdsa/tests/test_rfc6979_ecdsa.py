from hashlib import sha1, sha224, sha256, sha384, sha512
from re import findall, DOTALL
from urllib.request import urlopen
from unittest import TestCase

from ..curve import P192, P224, P256, P384, P521
from ..ecdsa import sign
from ..util import RFC6979


class TestRFC6979ECDSA(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rfc6979_text = urlopen('https://tools.ietf.org/rfc/rfc6979.txt').read().decode()
        cls.hash_lookup = {
            '1': sha1,
            '224': sha224,
            '256': sha256,
            '384': sha384,
            '512': sha512
        }

    def test_p192_rfc6979_ecdsa(self):
        curve_tests = findall(r'curve: NIST P-192(.*)curve: NIST P-224', self.rfc6979_text, flags=DOTALL)[0]

        q = int(findall(r'q = ([0-9A-F]*)', curve_tests)[0], 16)
        x = int(findall(r'x = ([0-9A-F]*)', curve_tests)[0], 16)

        test_regex = r'With SHA-(\d+), message = "([a-zA-Z]*)":\n' \
                     r'\s*k = ([0-9A-F]*)\n' \
                     r'\s*r = ([0-9A-F]*)\n' \
                     r'\s*s = ([0-9A-F]*)\n'

        for test in findall(test_regex, curve_tests):
            h = self.hash_lookup[test[0]]
            msg = test[1]
            k = int(test[2], 16)
            r = int(test[3], 16)
            s = int(test[4], 16)

            self.assertEqual(k, RFC6979(msg, x, q, h).gen_nonce())
            self.assertEqual((r, s), sign(msg, x, curve=P192, hashfunc=h))

    def test_p224_rfc6979_ecdsa(self):
        curve_tests = findall(r'curve: NIST P-224(.*)curve: NIST P-256', self.rfc6979_text, flags=DOTALL)[0]

        q = int(findall(r'q = ([0-9A-F]*)', curve_tests)[0], 16)
        x = int(findall(r'x = ([0-9A-F]*)', curve_tests)[0], 16)

        test_regex = r'With SHA-(\d+), message = "([a-zA-Z]*)":\n' \
                     r'\s*k = ([0-9A-F]*)\n' \
                     r'\s*r = ([0-9A-F]*)\n' \
                     r'\s*s = ([0-9A-F]*)\n'

        for test in findall(test_regex, curve_tests):
            h = self.hash_lookup[test[0]]
            msg = test[1]
            k = int(test[2], 16)
            r = int(test[3], 16)
            s = int(test[4], 16)

            self.assertEqual(k, RFC6979(msg, x, q, h).gen_nonce())
            self.assertEqual((r, s), sign(msg, x, curve=P224, hashfunc=h))

    def test_p256_rfc6979_ecdsa(self):
        curve_tests = findall(r'curve: NIST P-256(.*)curve: NIST P-384', self.rfc6979_text, flags=DOTALL)[0]

        q = int(findall(r'q = ([0-9A-F]*)', curve_tests)[0], 16)
        x = int(findall(r'x = ([0-9A-F]*)', curve_tests)[0], 16)

        test_regex = r'With SHA-(\d+), message = "([a-zA-Z]*)":\n' \
                     r'\s*k = ([0-9A-F]*)\n' \
                     r'\s*r = ([0-9A-F]*)\n' \
                     r'\s*s = ([0-9A-F]*)\n'

        for test in findall(test_regex, curve_tests):
            h = self.hash_lookup[test[0]]
            msg = test[1]
            k = int(test[2], 16)
            r = int(test[3], 16)
            s = int(test[4], 16)

            self.assertEqual(k, RFC6979(msg, x, q, h).gen_nonce())
            self.assertEqual((r, s), sign(msg, x, curve=P256, hashfunc=h))

    def test_p384_rfc6979_ecdsa(self):
        curve_tests = findall(r'curve: NIST P-384(.*)curve: NIST P-521', self.rfc6979_text, flags=DOTALL)[0]

        q_parts = findall(r'q = ([0-9A-F]*)\n\s*([0-9A-F]*)', curve_tests)[0]
        q = int(q_parts[0] + q_parts[1], 16)
        x_parts = findall(r'x = ([0-9A-F]*)\n\s*([0-9A-F]*)', curve_tests)[0]
        x = int(x_parts[0] + x_parts[1], 16)

        test_regex = r'With SHA-(\d+), message = "([a-zA-Z]*)":\n' \
                     r'\s*k = ([0-9A-F]*)\n\s*([0-9A-F]*)\n' \
                     r'\s*r = ([0-9A-F]*)\n\s*([0-9A-F]*)\n' \
                     r'\s*s = ([0-9A-F]*)\n\s*([0-9A-F]*)\n'

        for test in findall(test_regex, curve_tests):
            h = self.hash_lookup[test[0]]
            msg = test[1]
            k = int(test[2] + test[3], 16)
            r = int(test[4] + test[5], 16)
            s = int(test[6] + test[7], 16)

            self.assertEqual(k, RFC6979(msg, x, q, h).gen_nonce())
            self.assertEqual((r, s), sign(msg, x, curve=P384, hashfunc=h))

    def test_p521_rfc6979_ecdsa(self):
        curve_tests = findall(r'curve: NIST P-521(.*)curve: NIST K-163', self.rfc6979_text, flags=DOTALL)[0]

        q_parts = findall(r'q = ([0-9A-F]*)\n\s*([0-9A-F]*)\n\s*([0-9A-F]*)', curve_tests)[0]
        q = int(q_parts[0] + q_parts[1] + q_parts[2], 16)
        x_parts = findall(r'x = ([0-9A-F]*)\n\s*([0-9A-F]*)\n\s*([0-9A-F]*)', curve_tests)[0]
        x = int(x_parts[0] + x_parts[1] + x_parts[2], 16)

        test_regex = r'With SHA-(\d+), message = "([a-zA-Z]*)":\n' \
                     r'\s*k = ([0-9A-F]*)\n\s*([0-9A-F]*)\n\s*([0-9A-F]*)\n' \
                     r'\s*r = ([0-9A-F]*)\n\s*([0-9A-F]*)\n\s*([0-9A-F]*)\n' \
                     r'\s*s = ([0-9A-F]*)\n\s*([0-9A-F]*)\n\s*([0-9A-F]*)\n'

        for test in findall(test_regex, curve_tests):
            h = self.hash_lookup[test[0]]
            msg = test[1]
            k = int(test[2] + test[3] + test[4], 16)
            r = int(test[5] + test[6] + test[7], 16)
            s = int(test[8] + test[9] + test[10], 16)

            self.assertEqual(k, RFC6979(msg, x, q, h).gen_nonce())
            self.assertEqual((r, s), sign(msg, x, curve=P521, hashfunc=h))
