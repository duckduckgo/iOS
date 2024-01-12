from binascii import unhexlify
from json import JSONDecodeError, loads
from sys import version_info
from unittest import SkipTest, TestCase, skipIf
from urllib.error import URLError
from urllib.request import urlopen

from fastecdsa.curve import (
    P224, P256, P384, P521,
    brainpoolP224r1, brainpoolP256r1, brainpoolP320r1, brainpoolP384r1, brainpoolP512r1,
    secp256k1
)
from fastecdsa.ecdsa import verify
from fastecdsa.encoding.der import DEREncoder
from fastecdsa.encoding.sec1 import SEC1Encoder

try:
    from hashlib import sha224, sha256, sha384, sha3_224, sha3_256, sha3_384, sha3_512, sha512
except ImportError:
    pass


@skipIf(version_info.minor < 6, "Test requires sha3 (added in python3.6) to run")
class TestWycheproofEcdsaVerify(TestCase):
    @staticmethod
    def _get_tests(url):
        try:
            test_raw = urlopen(url).read()
            test_json = loads(test_raw)
            return test_json["testGroups"]
        except (JSONDecodeError, URLError) as error:
            SkipTest("Skipping tests, could not download / parse data from {}\nError: {}".format(url, error))

    def _test_runner(self, tests, curve, hashfunc):
        for test_group in tests:
            keybytes = unhexlify(test_group["key"]["uncompressed"])
            public_key = SEC1Encoder.decode_public_key(keybytes, curve)

            for test in test_group["tests"]:
                try:
                    message = unhexlify(test["msg"])
                    sigbytes = unhexlify(test["sig"])
                    signature = DEREncoder.decode_signature(sigbytes)
                    expected = test["result"] == "valid"

                    result = verify(signature, message, public_key, curve, hashfunc)
                    self.assertEqual(result, expected, test)
                except:
                    self.assertFalse(test["result"] == "valid", test)

    def test_brainpool224r1_sha224(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_brainpoolP224r1_sha224_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, brainpoolP224r1, sha224)

    def test_brainpoolP256r1_sha256(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_brainpoolP256r1_sha256_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, brainpoolP256r1, sha256)

    def test_brainpoolP320r1_sha384(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_brainpoolP320r1_sha384_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, brainpoolP320r1, sha384)

    def test_brainpoolP384r1_sha384(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_brainpoolP384r1_sha384_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, brainpoolP384r1, sha384)

    def test_brainpoolP512r1_sha512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_brainpoolP512r1_sha512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, brainpoolP512r1, sha512)

    def test_p224_sha224(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp224r1_sha224_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P224, sha224)

    def test_p224_sha256(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp224r1_sha256_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P224, sha256)

    def test_p224_sha3_224(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp224r1_sha3_224_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P224, sha3_224)

    def test_p224_sha3_256(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp224r1_sha3_256_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P224, sha3_256)

    def test_p224_sha3_512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp224r1_sha3_512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P224, sha3_512)

    def test_p224_sha512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp224r1_sha512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P224, sha512)

    def test_secp256k1_sha256(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp256k1_sha256_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, secp256k1, sha256)

    def test_secp256k1_sha3_256(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp256k1_sha3_256_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, secp256k1, sha3_256)

    def test_secp256k1_sha3_512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp256k1_sha3_512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, secp256k1, sha3_512)

    def test_secp256k1_sha512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp256k1_sha512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, secp256k1, sha512)

    def test_p256_sha256(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp256r1_sha256_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P256, sha256)

    def test_p256_sha3_256(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp256r1_sha3_256_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P256, sha3_256)

    def test_p256_sha3_512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp256r1_sha3_512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P256, sha3_512)

    def test_p256_sha512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp256r1_sha512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P256, sha512)

    def test_p384_sha384(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp384r1_sha384_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P384, sha384)

    def test_p384_sha3_384(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp384r1_sha3_384_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P384, sha3_384)

    def test_p384_sha3_512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp384r1_sha3_512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P384, sha3_512)

    def test_p384_sha512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp384r1_sha512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P384, sha512)

    def test_p521_sha3_512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp521r1_sha3_512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P521, sha3_512)

    def test_p521_sha512(self):
        url = "https://raw.githubusercontent.com/google/wycheproof/master/testvectors/ecdsa_secp521r1_sha512_test.json"
        tests = self._get_tests(url)
        self._test_runner(tests, P521, sha512)
