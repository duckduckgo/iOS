from binascii import hexlify
from hashlib import sha256
from typing import TypeVar

from fastecdsa import _ecdsa
from .curve import Curve, P256
from .point import Point
from .util import RFC6979, msg_bytes

MsgTypes = TypeVar('MsgTypes', str, bytes, bytearray)


class EcdsaError(Exception):
    def __init__(self, msg):
        self.msg = msg


def sign(msg: MsgTypes, d: int, curve: Curve = P256, hashfunc=sha256, prehashed: bool = False):
    """Sign a message using the elliptic curve digital signature algorithm.

    The elliptic curve signature algorithm is described in full in FIPS 186-4 Section 6. Please
    refer to http://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-4.pdf for more information.

    Args:
        |  msg (str|bytes|bytearray): A message to be signed.
        |  d (int): The ECDSA private key of the signer.
        |  curve (fastecdsa.curve.Curve): The curve to be used to sign the message.
        |  hashfunc (_hashlib.HASH): The hash function used to compress the message.
        |  prehashed (bool): The message being passed has already been hashed by :code:`hashfunc`.
    """
    # generate a deterministic nonce per RFC6979
    rfc6979 = RFC6979(msg, d, curve.q, hashfunc, prehashed=prehashed)
    k = rfc6979.gen_nonce()

    if prehashed:
        hex_digest = hexlify(msg).decode()
    else:
        hex_digest = hashfunc(msg_bytes(msg)).hexdigest()
    r, s = _ecdsa.sign(
        hex_digest,
        str(d),
        str(k),
        str(curve.p),
        str(curve.a),
        str(curve.b),
        str(curve.q),
        str(curve.gx),
        str(curve.gy)
    )
    return int(r), int(s)


def verify(sig: (int, int), msg: MsgTypes, Q: Point, curve: Curve = P256, hashfunc=sha256) -> bool:
    """Verify a message signature using the elliptic curve digital signature algorithm.

    The elliptic curve signature algorithm is described in full in FIPS 186-4 Section 6. Please
    refer to http://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-4.pdf for more information.

    Args:
        |  sig (int, int): The signature for the message.
        |  msg (str|bytes|bytearray): A message to be signed.
        |  Q (fastecdsa.point.Point): The ECDSA public key of the signer.
        |  curve (fastecdsa.curve.Curve): The curve to be used to sign the message.
        |  hashfunc (_hashlib.HASH): The hash function used to compress the message.

    Returns:
        bool: True if the signature is valid, False otherwise.

    Raises:
        fastecdsa.ecdsa.EcdsaError: If the signature or public key are invalid. Invalid signature
            in this case means that it has values less than 1 or greater than the curve order.
    """
    if isinstance(Q, tuple):
        Q = Point(Q[0], Q[1], curve)
    r, s = sig

    # validate Q, r, s (Q should be validated in constructor of Point already but double check)
    if not curve.is_point_on_curve((Q.x, Q.y)):
        raise EcdsaError('Invalid public key, point is not on curve {}'.format(curve.name))
    elif r > curve.q or r < 1:
        raise EcdsaError(
            'Invalid Signature: r is not a positive integer smaller than the curve order')
    elif s > curve.q or s < 1:
        raise EcdsaError(
            'Invalid Signature: s is not a positive integer smaller than the curve order')

    hashed = hashfunc(msg_bytes(msg)).hexdigest()
    return _ecdsa.verify(
        str(r),
        str(s),
        hashed,
        str(Q.x),
        str(Q.y),
        str(curve.p),
        str(curve.a),
        str(curve.b),
        str(curve.q),
        str(curve.gx),
        str(curve.gy)
    )
