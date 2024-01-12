import sys
import time
import uuid

from flask import Flask, request, jsonify
from ecdsa_wrapper import ECDSA

app = Flask(__name__)

# This script simulates the signing operation that should be implemented by the Ad Network in their API. 

# noinspection PyBroadException
try:
    # The key.pem should be in the same directory as this server script
    ECDSA_PRIVATE = open('key.pem').read()
except Exception:
    print("Please create a key.pem file with your private key")
    sys.exit(-1)

ADNET_ID = u'hke973vluw.skadnetwork'
CAMPAIGN_ID = u'1'  # Should be between 1-100
TARGET_ITUNES_ID = u'663592361' # The app ID of the app you want to advertise
SOURCE_IDENTIFIER = u'1'  # A number between 1-9999
FIDELITY_TYPE = '1'  # 1 for StoreKit-rendered ads (clicks)
SIGNATURE_SEPARATOR = u'\u2063'  # This separator is required to generate a valid signature
SKADNETWORK_1_VERSION = u'1.0'
SKADNETWORK_2_VERSION = u'2.0'
SKADNETWORK_22_VERSION = u'2.2'
SKADNETWORK_3_VERSION = u'3.0'
SKADNETWORK_4_VERSION = u'4.0'


@app.route('/get-ad-impression', methods=['GET'])
def get_skadnetwork_parameters():
    skadnet_version = request.args.get('skadnetwork_version')
    source_app_id = request.args.get('source_app_id')
    nonce = str(uuid.uuid4())
    timestamp = str(int(time.time()*1000))

    sigfmt = ECDSA.SIGB64
    curve = ECDSA.CURVEP256

    # In SKAdNetwork Version '1.0' we use less parameters to generate a signature
    if skadnet_version == SKADNETWORK_1_VERSION:
        fields = [
            ADNET_ID,
            CAMPAIGN_ID,
            TARGET_ITUNES_ID,
            nonce,
            timestamp,
        ]
    elif skadnet_version == SKADNETWORK_2_VERSION:
        fields = [
            skadnet_version,
            ADNET_ID,
            CAMPAIGN_ID,
            TARGET_ITUNES_ID,
            nonce,
            source_app_id,
            timestamp,
        ]
    elif skadnet_version == SKADNETWORK_22_VERSION or skadnet_version == SKADNETWORK_3_VERSION:
    # https://developer.apple.com/documentation/storekit/skadnetwork/generating_the_signature_to_validate_storekit-rendered_ads/combining_parameters_to_generate_signatures_for_skadnetwork_2_2_and_3?language=objc
        fields = [
            skadnet_version,
            ADNET_ID,
            CAMPAIGN_ID,
            TARGET_ITUNES_ID,
            nonce,
            source_app_id,
            FIDELITY_TYPE,
            timestamp,
        ]
    elif skadnet_version == SKADNETWORK_4_VERSION:
    # https://developer.apple.com/documentation/storekit/skadnetwork/generating_the_signature_to_validate_storekit-rendered_ads
        fields = [
            skadnet_version,
            ADNET_ID,
            SOURCE_IDENTIFIER,
            TARGET_ITUNES_ID,
            nonce,
            source_app_id,
            FIDELITY_TYPE,
            timestamp,
        ]
    else:
        return jsonify({'error': 'unsupported protocol version'}), 400

    message = SIGNATURE_SEPARATOR.join(fields)
    ecdsa = ECDSA(ECDSA_PRIVATE)
    signature = ecdsa.sign(message, sigfmt=sigfmt, curve=curve).decode('utf8')

    return jsonify({
        'signature': signature,
        'campaignId': CAMPAIGN_ID,
        'adNetworkId': ADNET_ID,
        'nonce': nonce,
        'timestamp': timestamp,
        'sourceAppId': source_app_id,
        'id': TARGET_ITUNES_ID,
        'adNetworkVersion': skadnet_version,
        'sourceIdentifier': SOURCE_IDENTIFIER,
    })


if __name__ == '__main__':
    app.run('0.0.0.0', port=8000)
