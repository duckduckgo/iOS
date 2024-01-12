from os import remove
from unittest import TestCase

from fastecdsa.curve import P256
from fastecdsa.keys import export_key, import_key, gen_keypair


class TestAsn1(TestCase):
    def test_generate_and_parse_pem(self):
        d, Q = gen_keypair(P256)
        export_key(d, curve=P256, filepath='p256.key')
        export_key(Q, curve=P256, filepath='p256.pub')

        parsed_d, parsed_Q = import_key('p256.key')
        self.assertEqual(parsed_d, d)
        self.assertEqual(parsed_Q, Q)

        parsed_d, parsed_Q = import_key('p256.pub')
        self.assertTrue(parsed_d is None)
        self.assertEqual(parsed_Q, Q)

        remove('p256.key')
        remove('p256.pub')