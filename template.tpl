___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "konsent Consent Manager",
  "categories": ["UTILITY"],
  "brand": {
    "id": "brand_konsent",
    "displayName": "konsent"
  },
  "description": "Loads the konsent consent banner and blocks tracking until visitors consent. Paste the Site Key from your konsent dashboard. Set this tag to fire on Consent Initialization so it runs before other tags.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "publicKey",
    "displayName": "Site key",
    "simpleValueType": true,
    "help": "The Site Key from your konsent dashboard. It looks like <strong>ck_live_...</strong>",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "apiBase",
    "displayName": "API base URL",
    "simpleValueType": true,
    "defaultValue": "https://konsent.sigilandclover.com/backend",
    "help": "Leave this as the default unless you self-host konsent, in which case point it at your own deployment."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// konsent loader (GTM custom template).
//
// Injects the hosted konsent loader with the site's public key as a field. The
// loader owns the banner, category blocking, consent proof, geo and i18n; this
// template only places the one script tag. The key and API base are passed as
// query params on the loader URL, which the loader reads (data-* attributes cannot
// be set from a sandboxed template, so it accepts ?key=&api= as well).

const injectScript = require('injectScript');
const encodeUriComponent = require('encodeUriComponent');
const makeString = require('makeString');

const key = makeString(data.publicKey).trim();
if (!key) {
  // No site key: nothing to load. Fail so the tag is not reported as successful.
  data.gtmOnFailure();
  return;
}

// Normalise the API base: a string, trimmed, with any trailing slashes removed.
let apiBase = makeString(data.apiBase || 'https://konsent.sigilandclover.com/backend').trim();
while (apiBase.length > 0 && apiBase.charAt(apiBase.length - 1) === '/') {
  apiBase = apiBase.substring(0, apiBase.length - 1);
}

const url = apiBase + '/loader/konsent.js?key=' + encodeUriComponent(key) + '&api=' + encodeUriComponent(apiBase);

// The URL is the cache token, so the same loader is injected at most once.
injectScript(url, data.gtmOnSuccess, data.gtmOnFailure, url);


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://konsent.sigilandclover.com/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Injects the loader when a site key is set
  code: |-
    const mockData = {
      publicKey: 'ck_live_test123',
      apiBase: 'https://konsent.sigilandclover.com/backend'
    };
    let injectedUrl;
    mock('injectScript', (url, onSuccess) => {
      injectedUrl = url;
      onSuccess();
    });

    runCode(mockData);

    assertThat(injectedUrl).isStrictEqualTo(
      'https://konsent.sigilandclover.com/backend/loader/konsent.js?key=ck_live_test123&api=https%3A%2F%2Fkonsent.sigilandclover.com%2Fbackend'
    );
    assertApi('gtmOnSuccess').wasCalled();
- name: Trims a trailing slash on the API base
  code: |-
    const mockData = {
      publicKey: 'ck_live_test123',
      apiBase: 'https://konsent.sigilandclover.com/backend/'
    };
    let injectedUrl;
    mock('injectScript', (url, onSuccess) => {
      injectedUrl = url;
      onSuccess();
    });

    runCode(mockData);

    assertThat(injectedUrl).isStrictEqualTo(
      'https://konsent.sigilandclover.com/backend/loader/konsent.js?key=ck_live_test123&api=https%3A%2F%2Fkonsent.sigilandclover.com%2Fbackend'
    );
- name: Fails when no site key is set
  code: |-
    const mockData = { publicKey: '', apiBase: 'https://konsent.sigilandclover.com/backend' };
    let injected = false;
    mock('injectScript', () => {
      injected = true;
    });

    runCode(mockData);

    assertThat(injected).isEqualTo(false);
    assertApi('gtmOnFailure').wasCalled();


___NOTES___

Created for konsent, a hosted consent-management platform. This tag injects the
konsent loader; the loader runs the consent banner and blocks tracking until a
visitor consents. Fire it on the Consent Initialization trigger so it runs before
other tags. Self-hosters change the API base URL field and edit the inject_script
permission to allow their own host.
