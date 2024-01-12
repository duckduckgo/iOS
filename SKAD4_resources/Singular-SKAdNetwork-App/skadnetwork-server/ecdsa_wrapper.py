"""
wrapper for the FastECDSA Library
"""

import base64 as b64
from fastecdsa import curve as fe_curve, keys as fe_keys, ecdsa as fe_ecdsa
from fastecdsa.encoding import der as fe_der, pem as fe_pem
from hashlib import sha256


class ECDSA(object):
    """
    a light wrapper around Anton Kueltz's FastECDSA library
    """
    CURVEP192 = fe_curve.P192
    CURVEP256 = fe_curve.P256
    CURVE = CURVEP256
    SIGRAW = 0   # signature format raw
    SIGB64 = 1   # ...base 64
    SIGHEX = 2   # ...hex
    SIGFMT = SIGB64
    HASH = sha256

    def __init__(self, pem=None):
        if pem is None:
            self._key, self._pubkey = fe_keys.gen_keypair(self.CURVE)
            return
        self._key, self._pubkey = fe_pem.PEMEncoder.decode_private_key(pem.strip())
        if self._pubkey is None:
            self._pubkey = fe_keys.get_public_key(self._key, self.CURVE)

    def __str__(self):
        if self._key is not None:
            return str(self._key)
        return str(self._pubkey)

    def export(self):
        "export the private key or public key, as the case may be, as PEM"
        if self._key is not None:
            return fe_keys.export_key(self._key, curve=self.CURVE)
        return fe_keys.export_key(self._pubkey, curve=self.CURVE)

    @property
    def key(s):
        "alias for export"
        return s.export()

    @property
    def pubkey(s):
        "export the public key only"
        return fe_keys.export_key(s._pubkey, curve=s.CURVE)

    def sign(s, message, sigfmt=None, curve=None):
        "signs `message` and returns a detached signature"
        if sigfmt is None: sigfmt = s.SIGFMT
        if curve is None: curve = s.CURVE
        if s._key is None: return None
        return s._sigencode(fe_ecdsa.sign(message, s._key, curve=curve, hashfunc=s.HASH), sigfmt)

    def _sigencode(s, sigrs, sigfmt=None):
        "encode the (r,s) signature"
        if sigfmt is None: sigfmt = s.SIGFMT
        sigr, sigs = sigrs
        sig = fe_der.DEREncoder.encode_signature(sigr, sigs)
        if   sigfmt == s.SIGRAW: return sig
        elif sigfmt == s.SIGB64: return b64.b64encode(sig)
        elif sigfmt == s.SIGHEX: return sig.hex()
        else:
            raise RuntimeError("unknow signatur format", sigfmt)

    def _sigdecode(s, sig, sigfmt=None):
        "decode the signature into a (r,s) signature"
        if sigfmt is None: sigfmt = s.SIGFMT
        if   sigfmt == s.SIGRAW: sigbytes = sig
        elif sigfmt == s.SIGB64: sigbytes = b64.b64decode(sig)
        elif sigfmt == s.SIGHEX: sigbytes = bytes.fromhex(sig)
        return fe_der.DEREncoder.decode_signature(sigbytes)

    def verify(s, message, sig, sigfmt=None):
        "verifies the message signature (True is correct, False if fails)"
        if sigfmt is None: sigfmt = s.SIGFMT
        sigr, sigs = s._sigdecode(sig, sigfmt)
        try:
            return fe_ecdsa.verify((sigr, sigs), message, s._pubkey, curve=s.CURVE, hashfunc=s.HASH)
        except:
            return False
