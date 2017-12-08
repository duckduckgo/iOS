var ABPFilterParser =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony export (immutable) */ __webpack_exports__["parseDomains"] = parseDomains;
/* harmony export (immutable) */ __webpack_exports__["parseOptions"] = parseOptions;
/* harmony export (immutable) */ __webpack_exports__["parseHTMLFilter"] = parseHTMLFilter;
/* harmony export (immutable) */ __webpack_exports__["parseFilter"] = parseFilter;
/* harmony export (immutable) */ __webpack_exports__["parse"] = parse;
/* harmony export (immutable) */ __webpack_exports__["matchesFilter"] = matchesFilter;
/* harmony export (immutable) */ __webpack_exports__["matches"] = matches;
/* harmony export (immutable) */ __webpack_exports__["getFingerprint"] = getFingerprint;
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_bloom_filter_js__ = __webpack_require__(1);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_bloom_filter_js___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_bloom_filter_js__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__badFingerprints_js__ = __webpack_require__(2);



let fs = __webpack_require__(3);

/**
 * bitwise mask of different request types
 */
const elementTypes = {
  SCRIPT: 0o1,
  IMAGE: 0o2,
  STYLESHEET: 0o4,
  OBJECT: 0o10,
  XMLHTTPREQUEST: 0o20,
  OBJECTSUBREQUEST: 0o40,
  SUBDOCUMENT: 0o100,
  DOCUMENT: 0o200,
  OTHER: 0o400,
};
/* harmony export (immutable) */ __webpack_exports__["elementTypes"] = elementTypes;


// Maximum number of cached entries to keep for subsequent lookups
const maxCached = 100;

// Maximum number of URL chars to check in match clauses
const maxUrlChars = 100;

// Exact size for fingerprints, if you change also change fingerprintRegexs
const fingerprintSize = 8;

// Regexes used to create fingerprints
// There's more than one because sometimes a fingerprint is determined to be a bad
// one and would lead to a lot of collisions in the bloom filter). In those cases
// we use the 2nd fingerprint.
let fingerprintRegexs = [
  /.*([./&_\-=a-zA-Z0-9]{8})\$?.*/,
  /([./&_\-=a-zA-Z0-9]{8})\$?.*/,
];

/**
 * Maps element types to type mask.
 */
const elementTypeMaskMap = new Map([
  ['script', elementTypes.SCRIPT],
  ['image', elementTypes.IMAGE],
  ['stylesheet', elementTypes.STYLESHEET],
  ['object', elementTypes.OBJECT],
  ['xmlhttprequest', elementTypes.XMLHTTPREQUEST],
  ['object-subrequest', elementTypes.OBJECTSUBREQUEST],
  ['subdocument', elementTypes.SUBDOCUMENT],
  ['document', elementTypes.DOCUMENT],
  ['other', elementTypes.OTHER]
]);
/* harmony export (immutable) */ __webpack_exports__["elementTypeMaskMap"] = elementTypeMaskMap;


const separatorCharacters = ':?/=^';

/**
 * Parses the domain string using the passed in separator and
 * fills in options.
 */
function parseDomains(input, separator, options) {
  options.domains = options.domains || [];
  options.skipDomains = options.skipDomains || [];
  let domains = input.split(separator);
  options.domains = options.domains.concat(domains.filter((domain) => domain[0] !== '~'));
  options.skipDomains = options.skipDomains.concat(domains
    .filter((domain) => domain[0] === '~')
    .map((domain) => domain.substring(1)));
}

if (!Array.prototype.includes) {
  Array.prototype.includes = function(searchElement /*, fromIndex*/ ) {
    'use strict';
    var O = Object(this);
    var len = parseInt(O.length, 10) || 0;
    if (len === 0) {
      return false;
    }
    var n = parseInt(arguments[1], 10) || 0;
    var k;
    if (n >= 0) {
      k = n;
    } else {
      k = len + n;
      if (k < 0) {k = 0;}
    }
    var currentElement;
    while (k < len) {
      currentElement = O[k];
      if (searchElement === currentElement ||
         (searchElement !== searchElement && currentElement !== currentElement)) { // NaN !== NaN
        return true;
      }
      k++;
    }
    return false;
  };
}


/**
 * Parses options from the passed in input string
 */
function parseOptions(input) {
  let output = {
    binaryOptions: new Set(),
  };
  input.split(',').forEach((option) => {
    option = option.trim();
    if (option.startsWith('domain=')) {
      let domainString = option.split('=')[1].trim();
      parseDomains(domainString, '|', output);
    } else {
      let optionWithoutPrefix = option[0] === '~' ? option.substring(1) : option;
      if (elementTypeMaskMap.has(optionWithoutPrefix)) {
        if (option[0] === '~') {
          output.skipElementTypeMask |= elementTypeMaskMap.get(optionWithoutPrefix);
        } else {
          output.elementTypeMask |= elementTypeMaskMap.get(optionWithoutPrefix);
        }
      }
      output.binaryOptions.add(option);
    }
  });
  return output;
}

/**
 * Finds the first separator character in the input string
 */
function findFirstSeparatorChar(input, startPos) {
  for (let i = startPos; i < input.length; i++) {
    if (separatorCharacters.indexOf(input[i]) !== -1) {
      return i;
    }
  }
  return -1;
}

/**
 * Parses an HTML filter and modifies the passed in parsedFilterData
 * as necessary.
 *
 * @param input: The entire input string to consider
 * @param index: Index of the first hash
 * @param parsedFilterData: The parsedFilterData object to fill
 */
function parseHTMLFilter(input, index, parsedFilterData) {
  let domainsStr = input.substring(0, index);
  parsedFilterData.options = {};
  if (domainsStr.length > 0) {
    parseDomains(domainsStr, ',', parsedFilterData.options);
  }

  // The XOR parsedFilterData.elementHidingException is in case the rule already
  // was specified as exception handling with a prefixed @@
  parsedFilterData.isException = !!(input[index + 1] === '@' ^
    parsedFilterData.isException);
  if (input[index + 1] === '@') {
    // Skip passed the first # since @# is 2 chars same as ##
    index++;
  }
  parsedFilterData.htmlRuleSelector = input.substring(index + 2);
}

function parseFilter(input, parsedFilterData, bloomFilter, exceptionBloomFilter) {
  input = input.trim();
  parsedFilterData.rawFilter = input;

  // Check for comment or nothing
  if (input.length === 0) {
    return false;
  }

  // Check for comments
  let beginIndex = 0;
  if (input[beginIndex] === '[' || input[beginIndex] === '!') {
    parsedFilterData.isComment = true;
    return false;
  }

  // Check for exception instead of filter
  parsedFilterData.isException = input[beginIndex] === '@' &&
    input[beginIndex + 1] === '@';
  if (parsedFilterData.isException) {
    beginIndex = 2;
  }

  // Check for element hiding rules
  let index = input.indexOf('#', beginIndex);
  if (index !== -1) {
    if (input[index + 1] === '#' || input[index + 1] === '@') {
      parseHTMLFilter(input.substring(beginIndex), index - beginIndex, parsedFilterData);
      // HTML rules cannot be combined with other parsing,
      // other than @@ exception marking.
      return true;
    }
  }

  // Check for options, regex can have options too so check this before regex
  index = input.lastIndexOf('$');
  if (index !== -1) {
    parsedFilterData.options = parseOptions(input.substring(index + 1));
    // Get rid of the trailing options for the rest of the parsing
    input = input.substring(0, index);
  } else {
    parsedFilterData.options = {};
  }

  // Check for a regex
  parsedFilterData.isRegex = input[beginIndex] === '/' &&
    input[input.length - 1] === '/' && beginIndex !== input.length - 1;
  if (parsedFilterData.isRegex) {
      parsedFilterData.data = input.slice(beginIndex + 1, -1);
      return true;
  }

  // Check if there's some kind of anchoring
  if (input[beginIndex] === '|') {
    // Check for an anchored domain name
    if (input[beginIndex + 1] === '|') {
      parsedFilterData.hostAnchored = true;
      let indexOfSep = findFirstSeparatorChar(input, beginIndex + 1);
      if (indexOfSep === -1) {
        indexOfSep = input.length;
      }
      beginIndex += 2;
      parsedFilterData.host = input.substring(beginIndex, indexOfSep);
    } else {
      parsedFilterData.leftAnchored = true;
      beginIndex++;
    }
  }
  if (input[input.length - 1] === '|') {
    parsedFilterData.rightAnchored = true;
    input = input.substring(0, input.length - 1);
  }

  parsedFilterData.data = input.substring(beginIndex) || '*';
  // Use the host bloom filter if the filter is a host anchored filter rule with no other data
  if (exceptionBloomFilter && parsedFilterData.isException) {
    exceptionBloomFilter.add(getFingerprint(parsedFilterData.data));
  } else if (bloomFilter) {
    // To check for duplicates
    //if (bloomFilter.exists(getFingerprint(parsedFilterData.data))) {
      // console.log('duplicate found for data: ' + getFingerprint(parsedFilterData.data));
    //}
    // console.log('parse:', parsedFilterData.data, 'fingerprint:', getFingerprint(parsedFilterData.data));
    bloomFilter.add(getFingerprint(parsedFilterData.data));
  }

  return true;
}

/**
 * Parses the set of filter rules and fills in parserData
 * @param input filter rules
 * @param parserData out parameter which will be filled
 *   with the filters, exceptionFilters and htmlRuleFilters.
 */
function parse(input, parserData) {
  parserData.bloomFilter = parserData.bloomFilter || new __WEBPACK_IMPORTED_MODULE_0_bloom_filter_js__["BloomFilter"]();
  parserData.exceptionBloomFilter = parserData.exceptionBloomFilter || new __WEBPACK_IMPORTED_MODULE_0_bloom_filter_js__["BloomFilter"]();
  parserData.filters = parserData.filters || [];
  parserData.noFingerprintFilters = parserData.noFingerprintFilters || [];
  parserData.exceptionFilters = parserData.exceptionFilters || [];
  parserData.htmlRuleFilters = parserData.htmlRuleFilters || [];
  let startPos = 0;
  let endPos = input.length;
  let newline = '\n';
  while (startPos <= input.length) {
    endPos = input.indexOf(newline, startPos);
    if (endPos === -1) {
      newline = '\r';
      endPos = input.indexOf(newline, startPos);
    }
    if (endPos === -1) {
      endPos = input.length;
    }
    let filter = input.substring(startPos, endPos);
    let parsedFilterData = {};
    if (parseFilter(filter, parsedFilterData, parserData.bloomFilter, parserData.exceptionBloomFilter)) {
      let fingerprint = getFingerprint(parsedFilterData.data);
      if (parsedFilterData.htmlRuleSelector) {
        parserData.htmlRuleFilters.push(parsedFilterData);
      } else if (parsedFilterData.isException) {
        parserData.exceptionFilters.push(parsedFilterData);
      } else if (fingerprint.length > 0) {
        parserData.filters.push(parsedFilterData);
      } else {
        parserData.noFingerprintFilters.push(parsedFilterData);
      }
    }
    startPos = endPos + 1;
  }
}

/**
 * Obtains the domain index of the input filter line
 */
function getDomainIndex(input) {
  let index = input.indexOf(':');
  ++index;
  while (input[index] === '/') {
    index++;
  }
  return index;
}

/**
 * Similar to str1.indexOf(filter, startingPos) but with
 * extra consideration to some ABP filter rules like ^.
 */
function indexOfFilter(input, filter, startingPos) {
  if (filter.length > input.length) {
    return -1;
  }

  let filterParts = filter.split('^');
  let index = startingPos;
  let beginIndex = -1;
  let prefixedSeparatorChar = false;

  for (let f = 0; f < filterParts.length; f++) {
    if (filterParts[f] === '') {
      prefixedSeparatorChar = true;
      continue;
    }

    index = input.indexOf(filterParts[f], index);
    if (index === -1) {
      return -1;
    }
    if (beginIndex === -1) {
      beginIndex = index;
    }

    if (prefixedSeparatorChar) {
      if (separatorCharacters.indexOf(input[index - 1]) === -1) {
        return -1;
      }
    }
    // If we are in an in between filterPart
    if (f + 1 < filterParts.length &&
        // and we have some chars left in the input past the last filter match
        input.length > index + filterParts[f].length) {
      if (separatorCharacters.indexOf(input[index + filterParts[f].length]) === -1) {
        return -1;
      }

    }

    prefixedSeparatorChar = false;
  }
  return beginIndex;
}

function getUrlHost(input) {
  let domainIndexStart = getDomainIndex(input);
  let domainIndexEnd = findFirstSeparatorChar(input, domainIndexStart);
  if (domainIndexEnd === -1) {
    domainIndexEnd = input.length;
  }
  return input.substring(domainIndexStart, domainIndexEnd);
}

function filterDataContainsOption(parsedFilterData, option) {
  return parsedFilterData.options &&
    parsedFilterData.options.binaryOptions &&
    parsedFilterData.options.binaryOptions.has(option);
}

function isThirdPartyHost(baseContextHost, testHost) {
  if (!testHost.endsWith(baseContextHost)) {
    return true;
  }

  let c = testHost[testHost.length - baseContextHost.length - 1];
  return c !== '.' && c !== undefined;
}

// Determines if there's a match based on the options, this doesn't
// mean that the filter rule shoudl be accepted, just that the filter rule
// should be considered given the current context.
// By specifying context params, you can filter out the number of rules which are
// considered.
function matchOptions(parsedFilterData, input, contextParams = {}) {
  if (contextParams.elementTypeMask !== undefined && parsedFilterData.options) {
    if (parsedFilterData.options.elementTypeMask !== undefined &&
        !(parsedFilterData.options.elementTypeMask & contextParams.elementTypeMask)) {
      return false;
    } if (parsedFilterData.options.skipElementTypeMask !== undefined &&
          parsedFilterData.options.skipElementTypeMask & contextParams.elementTypeMask) {
      return false;
    }
  }

  // Domain option check
  if (contextParams.domain !== undefined && parsedFilterData.options) {
    if (parsedFilterData.options.domains || parsedFilterData.options.skipDomains) {
      // Get the domains that should be considered
      let shouldBlockDomains = parsedFilterData.options.domains.filter((domain) =>
        !isThirdPartyHost(domain, contextParams.domain));

      let shouldSkipDomains = parsedFilterData.options.skipDomains.filter((domain) =>
        !isThirdPartyHost(domain, contextParams.domain));
      // Handle cases like: example.com|~foo.example.com should llow for foo.example.com
      // But ~example.com|foo.example.com should block for foo.example.com
      let leftOverBlocking = shouldBlockDomains.filter((shouldBlockDomain) =>
        shouldSkipDomains.every((shouldSkipDomain) =>
          isThirdPartyHost(shouldBlockDomain, shouldSkipDomain)));
      let leftOverSkipping = shouldSkipDomains.filter((shouldSkipDomain) =>
        shouldBlockDomains.every((shouldBlockDomain) =>
          isThirdPartyHost(shouldSkipDomain, shouldBlockDomain)));

      // If we have none left over, then we shouldn't consider this a match
      if (shouldBlockDomains.length === 0 && parsedFilterData.options.domains.length !== 0 ||
          shouldBlockDomains.length > 0 && leftOverBlocking.length === 0 ||
          shouldSkipDomains.length > 0 && leftOverSkipping.length > 0) {
        return false;
      }
    }
  }

  // If we're in the context of third-party site, then consider third-party option checks
  if (contextParams['third-party'] !== undefined) {
    // Is the current rule check for third party only?
    if (filterDataContainsOption(parsedFilterData, 'third-party')) {
      let inputHost = getUrlHost(input);
      let inputHostIsThirdParty = isThirdPartyHost(parsedFilterData.host, inputHost);
      if (inputHostIsThirdParty || !contextParams['third-party']) {
        return false;
      }
    }
  }

  return true;
}

/**
 * Given an individual parsed filter data determines if the input url should block.
 */
function matchesFilter(parsedFilterData, input, contextParams = {}, cachedInputData = {}) {
  if (!matchOptions(parsedFilterData, input, contextParams)) {
    return false;
  }

  // Check for a regex match
  if (parsedFilterData.isRegex) {
    if (!parsedFilterData.regex) {
      parsedFilterData.regex = new RegExp(parsedFilterData.data);
    }
    return parsedFilterData.regex.test(input);
  }

  // Check for both left and right anchored
  if (parsedFilterData.leftAnchored && parsedFilterData.rightAnchored) {
    return parsedFilterData.data === input;
  }

  // Check for right anchored
  if (parsedFilterData.rightAnchored) {
    return input.slice(-parsedFilterData.data.length) === parsedFilterData.data;
  }

  // Check for left anchored
  if (parsedFilterData.leftAnchored) {
    return input.substring(0, parsedFilterData.data.length) === parsedFilterData.data;
  }

  // Check for domain name anchored
  if (parsedFilterData.hostAnchored) {
    if (!cachedInputData.currentHost) {
      cachedInputData.currentHost = getUrlHost(input);
    }

    // domain anchored, first check if we're on the correct domain
    if(!isThirdPartyHost(parsedFilterData.host, cachedInputData.currentHost)) {
        // check wildcard filters
        if (parsedFilterData.rawFilter.match(/\*/)) {
            return wildcardMatch(parsedFilterData, input)
        // or check normal filters
        } else {
            return indexOfFilter(input, parsedFilterData.data) !== -1;
        }
    } else {
        // fails domain anchor check
        return false
    }
  }

  if (!wildcardMatch(parsedFilterData, input)) return false

  return true;
}

function wildcardMatch(parsedFilterData, input) {
  // Wildcard match comparison
  let parts = parsedFilterData.data.split('*');
  let index = 0;
  for (let part of parts) {
    let newIndex = indexOfFilter(input, part, index);
    if (newIndex === -1) {
      return false;
    }
    index = newIndex + part.length;
  }
  return true
}

function discoverMatchingPrefix(array, bloomFilter, str, prefixLen = fingerprintSize) {
  for (var i = 0; i < str.length - prefixLen + 1; i++) {
    let sub = str.substring(i, i + prefixLen);
    if (bloomFilter.exists(sub)) {
      array.push({ badFingerprint: sub, src: str});
      // console.log('bad-fingerprint:', sub, 'for url:', str);
    } else {
      // console.log('good-fingerprint:', sub, 'for url:', str);
    }
  }
}

function hasMatchingFilters(filterList, parsedFilterData, input, contextParams, cachedInputData) {
  const foundFilter = filterList.find(parsedFilterData2 =>
    matchesFilter(parsedFilterData2, input, contextParams, cachedInputData));
  if (foundFilter && cachedInputData.matchedFilters && foundFilter.rawFilter) {

    // increment the count of matches
    // we store an extra object and a count so that in the future
    // other bits of information can be recorded during match time
    if (cachedInputData.matchedFilters[foundFilter.rawFilter]) {
      cachedInputData.matchedFilters[foundFilter.rawFilter].matches += 1;
    } else {
      cachedInputData.matchedFilters[foundFilter.rawFilter]  = { matches: 1 };
    }

    // can't write to local files like this
    //fs.writeFileSync('easylist-matches.json', JSON.stringify(cachedInputData.matchedFilters), 'utf-8');
  }
  return !!foundFilter;
}

/**
 * Using the parserData rules will try to see if the input URL should be blocked or not
 * @param parserData The filter data obtained from a call to parse
 * @param input The input URL
 * @return true if the URL should be blocked
 */
function matches(parserData, input, contextParams = {}, cachedInputData = { }) {
  cachedInputData.bloomNegativeCount = cachedInputData.bloomNegativeCount || 0;
  cachedInputData.bloomPositiveCount = cachedInputData.bloomPositiveCount || 0;
  cachedInputData.notMatchCount = cachedInputData.notMatchCount || 0;
  cachedInputData.badFingerprints = cachedInputData.badFingerprints || [];
  cachedInputData.matchedFilters = cachedInputData.matchedFilters || {};

  cachedInputData.bloomFalsePositiveCount = cachedInputData.bloomFalsePositiveCount || 0;
  let hasMatchingNoFingerprintFilters;
  let cleanedInput = input.replace(/^https?:\/\//, '');
  if (cleanedInput.length > maxUrlChars) {
    cleanedInput = cleanedInput.substring(0, maxUrlChars);
  }
  if (parserData.bloomFilter) {
    if (!parserData.bloomFilter.substringExists(cleanedInput, fingerprintSize)) {
      cachedInputData.bloomNegativeCount++;
      cachedInputData.notMatchCount++;
      // console.log('early return because of bloom filter check!');
      hasMatchingNoFingerprintFilters =
        hasMatchingFilters(parserData.noFingerprintFilters, parserData, input, contextParams, cachedInputData);

      if (!hasMatchingNoFingerprintFilters) {
        return false;
      }
    }
    // console.log('looked for url in bloom filter and it said yes:', cleaned);
  }
  cachedInputData.bloomPositiveCount++;

  // console.log('not early return: ', input);
  delete cachedInputData.currentHost;
  cachedInputData.misses = cachedInputData.misses || new Set();
  cachedInputData.missList = cachedInputData.missList || [];
  if (cachedInputData.missList.length > maxCached) {
    cachedInputData.misses.delete(cachedInputData.missList[0]);
    cachedInputData.missList = cachedInputData.missList.splice(1);
  }
  if (cachedInputData.misses.has(input)) {
    cachedInputData.notMatchCount++;
    // console.log('positive match for input: ', input);
    return false;
  }

  if (hasMatchingFilters(parserData.filters, parserData, input, contextParams, cachedInputData) ||
      hasMatchingNoFingerprintFilters === true || hasMatchingNoFingerprintFilters === undefined &&
      hasMatchingFilters(parserData.noFingerprintFilters, parserData, input, contextParams, cachedInputData)) {
    // Check for exceptions only when there's a match because matches are
    // rare compared to the volume of checks
    let exceptionBloomFilterMiss = parserData.exceptionBloomFilter && !parserData.exceptionBloomFilter.substringExists(cleanedInput, fingerprintSize);
    if (!exceptionBloomFilterMiss && hasMatchingFilters(parserData.exceptionFilters, parserData, input, contextParams, cachedInputData)) {
      cachedInputData.notMatchCount++;
      return false;
    }
    return true;
  }

  // The bloom filter had a false positive, se we checked for nothing! :'(
  // This is probably (but not always) an indication that the fingerprint selection should be tweaked!
  cachedInputData.missList.push(input);
  cachedInputData.misses.add(input);
  cachedInputData.notMatchCount++;
  cachedInputData.bloomFalsePositiveCount++;
  discoverMatchingPrefix(cachedInputData.badFingerprints, parserData.bloomFilter, cleanedInput);
  // console.log('positive match for input: ', input);
  return false;
}

/**
 * Obtains a fingerprint for the specified filter
 */
function getFingerprint(str) {
  for (var i = 0; i < fingerprintRegexs.length; i++) {
    let fingerprintRegex = fingerprintRegexs[i];
    let result = fingerprintRegex.exec(str);
    fingerprintRegex.lastIndex = 0;

    if (result &&
        !__WEBPACK_IMPORTED_MODULE_1__badFingerprints_js__["a" /* badFingerprints */].includes(result[1]) &&
        !__WEBPACK_IMPORTED_MODULE_1__badFingerprints_js__["b" /* badSubstrings */].find(badSubstring => result[1].includes(badSubstring))) {
      return result[1];
    }
    if (result) {
      // console.log('checking again for str:', str, 'result:', result[1]);
    } else {
      // console.log('checking again for str, no result');
    }
  }
  // This is pretty ugly but getting fingerprints is assumed to be used only when preprocessing and
  // in a live environment.
  if (str.length > 8) {
    // Remove first and last char
    return getFingerprint(str.slice(1, -1));
  }
  // console.warn('Warning: Could not determine a good fingerprint for:', str);
  return '';
}


/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

var __WEBPACK_AMD_DEFINE_FACTORY__, __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;(function (global, factory) {
  if (true) {
    !(__WEBPACK_AMD_DEFINE_ARRAY__ = [exports], __WEBPACK_AMD_DEFINE_FACTORY__ = (factory),
				__WEBPACK_AMD_DEFINE_RESULT__ = (typeof __WEBPACK_AMD_DEFINE_FACTORY__ === 'function' ?
				(__WEBPACK_AMD_DEFINE_FACTORY__.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__)) : __WEBPACK_AMD_DEFINE_FACTORY__),
				__WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
  } else if (typeof exports !== 'undefined') {
    factory(exports);
  } else {
    var mod = {
      exports: {}
    };
    factory(mod.exports);
    global.main = mod.exports;
  }
})(this, function (exports) {
  'use strict';

  Object.defineProperty(exports, '__esModule', {
    value: true
  });

  var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

  function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

  var toCharCodeArray = function toCharCodeArray(str) {
    return str.split('').map(function (c) {
      return c.charCodeAt(0);
    });
  };

  exports.toCharCodeArray = toCharCodeArray;
  /**
   * Returns a function that generates a Rabin fingerprint hash function
   * @param p The prime to use as a base for the Rabin fingerprint algorithm
   */
  var simpleHashFn = function simpleHashFn(p) {
    return function (arrayValues, lastHash, lastCharCode) {
      return lastHash ?
      // See the abracadabra example: https://en.wikipedia.org/wiki/Rabin%E2%80%93Karp_algorithm
      (lastHash - lastCharCode * Math.pow(p, arrayValues.length - 1)) * p + arrayValues[arrayValues.length - 1] : arrayValues.reduce(function (total, x, i) {
        return total + x * Math.pow(p, arrayValues.length - i - 1);
      }, 0);
    };
  };

  exports.simpleHashFn = simpleHashFn;
  /*
   * Sets the specific bit location
   */
  var setBit = function setBit(buffer, bitLocation) {
    return buffer[bitLocation / 8 | 0] |= 1 << bitLocation % 8;
  };

  exports.setBit = setBit;
  /**
   * Returns true if the specified bit location is set
   */
  var isBitSet = function isBitSet(buffer, bitLocation) {
    return !!(buffer[bitLocation / 8 | 0] & 1 << bitLocation % 8);
  };

  exports.isBitSet = isBitSet;

  var BloomFilter = (function () {
    /**
     * Constructs a new BloomFilter instance.
     * If you'd like to initialize with a specific size just call BloomFilter.from(Array.from(Uint8Array(size).values()))
     * Note that there is purposely no remove call because adding that would introduce false negatives.
     *
     * @param bitsPerElement Used along with estimatedNumberOfElements to figure out the size of the BloomFilter
     *   By using 10 bits per element you'll have roughly 1% chance of false positives.
     * @param estimatedNumberOfElements Used along with bitsPerElementto figure out the size of the BloomFilter
     * @param hashFns An array of hash functions to use. These can be custom but they should be of the form
     *   (arrayValues, lastHash, lastCharCode) where the last 2 parameters are optional and are used to make
     *   a rolling hash to save computation.
     */

    function BloomFilter(bitsPerElement, estimatedNumberOfElements, hashFns) {
      if (bitsPerElement === undefined) bitsPerElement = 10;
      if (estimatedNumberOfElements === undefined) estimatedNumberOfElements = 50000;

      _classCallCheck(this, BloomFilter);

      if (bitsPerElement.constructor === Uint8Array) {
        // Re-order params
        this.buffer = bitsPerElement;
        if (estimatedNumberOfElements.constructor === Array) {
          hashFns = estimatedNumberOfElements;
        }
        // Calculate new buffer size
        this.bufferBitSize = this.buffer.length * 8;
      } else if (bitsPerElement.constructor === Array) {
        // Re-order params
        var arrayLike = bitsPerElement;
        if (estimatedNumberOfElements.constructor === Array) {
          hashFns = estimatedNumberOfElements;
        }
        // Calculate new buffer size
        this.bufferBitSize = arrayLike.length * 8;
        this.buffer = new Uint8Array(arrayLike);
      } else {
        // Calculate the needed buffer size in bytes
        this.bufferBitSize = bitsPerElement * estimatedNumberOfElements;
        this.buffer = new Uint8Array(Math.ceil(this.bufferBitSize / 8));
      }
      this.hashFns = hashFns || [simpleHashFn(11), simpleHashFn(17), simpleHashFn(23)];
      this.setBit = setBit.bind(this, this.buffer);
      this.isBitSet = isBitSet.bind(this, this.buffer);
    }

    _createClass(BloomFilter, [{
      key: 'toJSON',

      /**
       * Serializing the current BloomFilter into a JSON friendly format.
       * You would typically pass the result into JSON.stringify.
       * Note that BloomFilter.from only works if the hash functions are the same.
       */
      value: function toJSON() {
        return Array.from(this.buffer.values());
      }
    }, {
      key: 'print',

      /**
       * Print the buffer, mostly used for debugging only
       */
      value: function print() {
        console.log(this.buffer);
      }
    }, {
      key: 'getLocationsForCharCodes',

      /**
       * Given a string gets all the locations to check/set in the buffer
       * for that string.
       * @param charCodes An array of the char codes to use for the hash
       */
      value: function getLocationsForCharCodes(charCodes) {
        var _this = this;

        return this.hashFns.map(function (h) {
          return h(charCodes) % _this.bufferBitSize;
        });
      }
    }, {
      key: 'getHashesForCharCodes',

      /**
       * Obtains the hashes for the specified charCodes
       * See "Rabin fingerprint" in https://en.wikipedia.org/wiki/Rabin%E2%80%93Karp_algorithm for more information.
       *
       * @param charCodes An array of the char codes to use for the hash
       * @param lastHashes If specified, it will pass the last hash to the hashing
       * function for a faster computation.  Must be called with lastCharCode.
       * @param lastCharCode if specified, it will pass the last char code
       *  to the hashing function for a faster computation. Must be called with lastHashes.
       */
      value: function getHashesForCharCodes(charCodes, lastHashes, lastCharCode) {
        var _this2 = this;

        return this.hashFns.map(function (h, i) {
          return h(charCodes, lastHashes ? lastHashes[i] : undefined, lastCharCode, _this2.bufferBitSize);
        });
      }
    }, {
      key: 'add',

      /**
       * Adds he specified string to the set
       */
      value: function add(data) {
        if (data.constructor !== Array) {
          data = toCharCodeArray(data);
        }

        this.getLocationsForCharCodes(data).forEach(this.setBit);
      }
    }, {
      key: 'exists',

      /**
       * Checks whether an element probably exists in the set, or definitely doesn't.
       * @param str Either a string to check for existance or an array of the string's char codes
       *   The main reason why you'd want to pass in a char code array is because passing a string
       *   will use JS directly to get the char codes which is very inneficient compared to calling
       *   into C++ code to get it and then making the call.
       *
       * Returns true if the element probably exists in the set
       * Returns false if the element definitely does not exist in the set
       */
      value: function exists(data) {
        if (data.constructor !== Array) {
          data = toCharCodeArray(data);
        }
        return this.getLocationsForCharCodes(data).every(this.isBitSet);
      }
    }, {
      key: 'substringExists',

      /**
       * Checks if any substring of length substringLenght probably exists or definitely doesn't
       * If false is returned then no substring of the specified string of the specified lengthis in the bloom filter
       * @param data The substring or char array to check substrings on.
       */
      value: function substringExists(data, substringLength) {
        var _this3 = this;

        if (data.constructor !== Uint8Array) {
          if (data.constructor !== Array) {
            data = toCharCodeArray(data);
          }
          data = new Uint8Array(data);
        }

        var lastHashes = undefined,
            lastCharCode = undefined;
        for (var i = 0; i < data.length - substringLength + 1; i++) {

          lastHashes = this.getHashesForCharCodes(data.subarray(i, i + substringLength), lastHashes, lastCharCode);
          if (lastHashes.map(function (x) {
            return x % _this3.bufferBitSize;
          }).every(this.isBitSet)) {
            return true;
          }
          lastCharCode = data[i];
        }
        return false;
      }
    }], [{
      key: 'from',

      /**
       * Construct a Bloom filter from a previous array of data
       * Note that the hash functions must be the same!
       */
      value: function from(arrayLike, hashFns) {
        return new BloomFilter(arrayLike, hashFns);
      }
    }]);

    return BloomFilter;
  })();

  exports.BloomFilter = BloomFilter;
});
//# sourceMappingURL=main.js.map

/***/ }),
/* 2 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
const badFingerprints = [
    "/walmart",
    "redirect",
    "/microso",
    "/jquery.",
    "/library",
    "/account",
    "/common/",
    "/generat",
    "homepage",
    "social/j",
    "googlead",
    "tag/js/g",
    "analytic",
    "oublecli",
    "provider",
    "gpt/puba",
    "js?callb",
    "recommen",
    "&callbac",
    "ubads.g.",
    "gampad/a",
    "w.google",
    "google.c",
    "pagead/e",
    "pagead/j",
    "pagead/g",
    "ahoo.com",
    "zz/combo",
    "content/",
    "desktop-",
    "content-",
    ".yimg.co",
    "img.com/",
    "content_",
    "/overlay",
    "assets/s",
    "/themes/",
    "/header-",
    "rq/darla",
    "default/",
    "build/js",
    "/public/",
    "controll",
    "interest",
    "plugin/a",
    "dserver.",
    "gallery-",
    "platform",
    "resource",
    "default_",
    "template",
    "streams/",
    "assets/p",
    "styleshe",
    "reative/",
    "delivera",
    "300x250.",
    "js/beaco",
    "/footer-",
    "facebook",
    "timg.com",
    "d.double",
    "pagead/i",
    "external",
    "iframe_a",
    "instream",
    "com/js/a",
    "oogleuse",
    "gadgets/",
    "gallery/",
    "yfpadobj",
    "com/lib/",
    "/global-",
    "/global/",
    "componen",
    "/process",
    "frontpag",
    "amazon.c",
    "/images/",
    "/images-",
    "adsystem",
    "microsof",
    "/jquery-",
    ".com/lib",
    "library/",
    "common/r",
    "generate",
    "/Common/",
    "/product",
    "/static/",
    ".com/js/",
    "/homepag",
    "/social/",
    ".googlea",
    "/pagead/",
    "/tag/js/",
    "/googlea",
    "g.double",
    ".doublec",
    "doublecl",
    "search.c",
    "/provide",
    "/gpt/pub",
    ".js?call",
    "callback",
    "pubads.g",
    "/gampad/",
    "ww.googl",
    "oogle.co",
    "_300x250",
    "300x250_",
    "-300x250",
    "yahoo.co",
    "ttp://l.",
    "/zz/comb",
    "/content",
    "/ads/ads",
    "/ads-min",
    "l.yimg.c",
    "yimg.com",
    "-content",
    "/generic",
    "overlay/",
    "/assets/",
    "overlay.",
    "/media/t",
    "/media/p",
    "/css/ski",
    "common/a",
    "/toolbar",
    "/rq/darl",
    "/default",
    "/common_",
    "/desktop",
    "/build/j",
    "/plugin/",
    "-iframe-",
    "overlay-",
    ".adserve",
    "adserver",
    "/gallery",
    "_platfor",
    "/resourc",
    "/storage",
    "-source/",
    "/templat",
    "-templat",
    "/streams",
    "/video-a",
    "/stylesh",
    "/secure/",
    "/creativ",
    "creative",
    "/deliver",
    "/beacon/",
    "/js/beac",
    "/search/",
    "/search-",
    "/search_",
    "common/i",
    "/preview",
    "/google.",
    "/faceboo",
    "/static.",
    "ytimg.co",
    "/pubads.",
    "/iframe_",
    "/doublec",
    "ad.doubl",
    "/ad_data",
    "/externa",
    "accounts",
    "/instrea",
    "googleus",
    ".com/gad",
    "/gadgets",
    "-gallery",
    "/yfpadob",
    "/compone",
    "/control",
    "/recomme",
    "/frontpa",
    "/analyti",
    "/amazon.",
    "mazon.co",
    "images-a",
    "images/G",
    "images/I",
    "//images",
    "/redirec",
    "-adsyste",
    "edirect.",
    "icrosoft",
    "ommon/re",
    "omepage/",
    "oogleads",
    "ag/js/gp",
    "nalytics",
    "ubleclic",
    "pt/pubad",
    "s?callba",
    "allback=",
    "omepage_",
    "ecommend",
    "bads.g.d",
    "ampad/ad",
    ".google.",
    "ogle.com",
    "agead/ex",
    "agead/js",
    "agead/ga",
    "hoo.com/",
    "z/combo?",
    "ontent/s",
    "ontent_i",
    "ontent-a",
    "q/darla/",
    "ontent/b",
    "ontent/a",
    "ontrolle",
    "ontent/i",
    "server.y",
    "latform_",
    "emplate-",
    "emplates",
    "tyleshee",
    "mg.com/a",
    "s/beacon",
    "xternal_",
    "ogleuser",
    "ccounts/",
    "fpadobje",
    "omponent",
    "emplate/",
    "rontpage",
    "azon.com",
    "mmon/res",
    "ogleadse",
    "g/js/gpt",
    "ads.g.do",
    "bleclick",
    "/beacon.",
    "t/pubads",
    "?callbac",
    "commenda",
    "mpad/ads",
    "gle.com/",
    "gead/exp",
    "gead/js/",
    "gead/gad",
    "mg.com/z",
    "mg.com/r",
    "ntent/ad",
    "ntroller",
    "erver.ya",
    "ylesheet",
    "gleuserc",
    "padobjec",
    "mponent/",
    "g.com/a/",
    "zon.com/",
    "gleadser",
    "ds.g.dou",
    "leclick.",
    "/pubads_",
    "ommendat",
    "pad/ads?",
    "le.com/a",
    "ead/expa",
    "ead/gadg",
    "g.com/zz",
    "g.com/rq",
    "rver.yah",
    "ead/js/l",
    "leclick/",
    "leuserco",
    "adobject",
    ".com/a/1",
    "leadserv",
    "s.g.doub",
    "eclick.n",
    "pubads_i",
    "mmendati",
    "ad/ads?g",
    "e.com/ad",
    "ad/expan",
    "ad/gadge",
    ".com/zz/",
    ".com/rq/",
    "ver.yaho",
    "ad/js/li",
    "ad/ads?a",
    "eusercon",
    "dobject.",
    "eadservi",
    ".g.doubl",
    "click.ne",
    "ubads_im",
    "mendatio",
    "d/ads?gd",
    ".com/ads",
    "d/expans",
    "d/gadget",
    "com/zz/c",
    "com/rq/d",
    "er.yahoo",
    "d/js/lid",
    "d/ads?ad",
    "usercont",
    "object.j",
    "adservic",
    "lick.net",
    "bads_imp",
    "endation",
    "/ads?gdf",
    "com/ads/",
    "/expansi",
    "om/zz/co",
    "om/rq/da",
    "r.yahoo.",
    "/js/lida",
    "/ads?ad_",
    "serconte",
    "bject.js",
    "dservice",
    "ick.net/",
    "ads_impl",
    "ndations",
    "ads?gdfp",
    "expansio",
    "m/zz/com",
    "m/rq/dar",
    ".yahoo.c",
    "js/lidar",
    "ads?ad_r",
    "erconten",
    "services",
    "ck.net/p",
    "ds_impl_",
    "ck.net/g",
    "ds?gdfp_",
    "xpansion",
    "oo.com/a",
    "s/lidar.",
    "ds?ad_ru",
    "rcontent",
    "ervices.",
    "partner.",
    "k.net/ga",
    "s?gdfp_r",
    "pansion_",
    "o.com/a?",
    "/lidar.j",
    "s?ad_rul",
    "content.",
    "rvices.c",
    "artner.g",
    ".net/gam",
    "?gdfp_re",
    "ansion_e",
    "lidar.js",
    "?ad_rule",
    "ontent.c",
    "vices.co",
    "rtner.go",
    "net/gamp",
    "gdfp_req",
    "pagead2.",
    "nsion_em",
    "ad_rule=",
    "ntent.co",
    "ices.com",
    "tner.goo",
    "et/gampa",
    "dfp_req=",
    "agead2.g",
    "sion_emb",
    "tent.com",
    "ces.com/",
    "ner.goog",
    "t/gampad",
    "fp_req=1",
    "gead2.go",
    "ion_embe",
    "er.googl",
    "p_req=1&",
    "ead2.goo",
    "on_embed",
    "r.google",
    "ad2.goog",
    "n_embed.",
    "es.com/g",
    "d2.googl",
    "_embed.j",
    "s.com/gp",
    "2.google",
    "embed.js",
    ".com/gpt",
    ".googles",
    "com/gpt/",
    "googlesy",
    "om/gpt/p",
    "ooglesyn",
    "m/gpt/pu",
    "oglesynd",
    "glesyndi",
    "lesyndic",
    "esyndica",
    "syndicat",
    "yndicati",
    "ndicatio",
    "dication",
    "ication.",
    "cation.c",
    "ation.co",
    "tion.com",
    "ion.com/",
    "on.com/p",
    "n.com/pa",
    ".com/pag",
    "com/page",
    "om/pagea",
    "m/pagead"
]
/* harmony export (immutable) */ __webpack_exports__["a"] = badFingerprints;

const badSubstrings = ['com', 'net', 'http', 'image', 'www', 'img', '.js', 'oogl', 'min.', 'que', 'synd', 'dicat', 'templ', 'tube', 'page', 'home', 'mepa', 'mplat', 'tati', 'user', 'aws', 'omp', 'icros', 'espon', 'org', 'nalyti', 'acebo', 'lead', 'con', 'count', 'vers', 'pres', 'aff', 'atio', 'tent', 'ative', 'en_', 'fr_', 'es_', 'ha1', 'ha2', 'live', 'odu', 'esh', 'adm', 'crip', 'ect', 'tics', 'edia', 'ini', 'yala', 'ana', 'rac', 'trol', 'tern', 'card', 'yah', 'tion', 'erv', '.co', 'lug', 'eat', 'ugi', 'ates', 'loud', 'ner', 'earc', 'atd', 'fro', 'ruct', 'sour', 'news', 'ddr', 'htm', 'fram', 'dar', 'flas', 'lay', 'orig', 'uble', 'om/', 'ext', 'link', '.png', 'com/', 'tri', 'but', 'vity', 'spri'];
/* harmony export (immutable) */ __webpack_exports__["b"] = badSubstrings;



/***/ }),
/* 3 */
/***/ (function(module, exports) {



/***/ })
/******/ ]);