/**
 * Automatically import the template, based on the default template of the original sw-precache plugin.
 *
 * Because the template is manually imported, once the project is generated, it does not support automatic upgrades with new versions of sw-precache.
 * Download the basic template from the Lavas website to get the latest template and replace it.
 *
 */

/* eslint-disable */

'use strict';

var precacheConfig = <%= precacheConfig %>;
var cacheName = 'sw-precache-<%= version %>-<%= cacheId %>-' + (self.registration ? self.registration.scope : '');
var firstRegister = 1; // By default, 1 indicates the first installation of SW, and 0 indicates an SW update.

<% if (handleFetch) { %>
var ignoreUrlParametersMatching = [<%= ignoreUrlParametersMatching %>];
<% } %>

var addDirectoryIndex = function (originalUrl, index) {
    var url = new URL(originalUrl);
    if (url.pathname.slice(-1) === '/') {
        url.pathname += index;
    }
    return url.toString();
};

var cleanResponse = function (originalResponse) {
    // If there is no redirect response, no action is required.
    if (!originalResponse.redirected) {
        return Promise.resolve(originalResponse);
    }

    // Firefox 50 and below do not support the Response.body stream, so we need to read the entire body and return it as a blob.
    var bodyPromise = 'body' in originalResponse ?
        Promise.resolve(originalResponse.body) :
        originalResponse.blob();

    return bodyPromise.then(function (body) {
        // new Response() supports both stream and Blob.
        return new Response(body, {
            headers: originalResponse.headers,
            status: originalResponse.status,
            statusText: originalResponse.statusText
        });
    });
};

var createCacheKey = function (originalUrl, paramName, paramValue,
    dontCacheBustUrlsMatching) {

    // Create a new URL object to avoid affecting the original URL.
    var url = new URL(originalUrl);

    // If the dontCacheBustUrlsMatching is not set or does not match, append the value to url.search
    if (!dontCacheBustUrlsMatching ||
        !(url.pathname.match(dontCacheBustUrlsMatching))) {
        url.search += (url.search ? '&' : '') +
            encodeURIComponent(paramName) + '=' + encodeURIComponent(paramValue);
    }

    return url.toString();
};

var isPathWhitelisted = function (whitelist, absoluteUrlString) {
    // If the whitelist is an empty array, then everything is considered to be in the whitelist.
    if (whitelist.length === 0) {
        return true;
    }

    // Otherwise, match each regex one by one and return the result.
    var path = (new URL(absoluteUrlString)).pathname;
    return whitelist.some(function (whitelistedPathRegex) {
        return path.match(whitelistedPathRegex);
    });
};

var stripIgnoredUrlParameters = function (originalUrl,
    ignoreUrlParametersMatching) {
    var url = new URL(originalUrl);
    // Remove the hash; View https://github.com/GoogleChrome/sw-precache/issues/290
    url.hash = '';

    url.search = url.search.slice(1) // If it contains '?'
        .split('&') // Split into an array in the form of "key=value"
        .map(function (kv) {
            return kv.split('='); // Split each "key=value" into [key, value]
        })
        .filter(function (kv) {
            return ignoreUrlParametersMatching.every(function (ignoredRegex) {
                return !ignoredRegex.test(kv[0]); // If the key does not match any ignore parameter regex, return true
            });
        })
        .map(function (kv) {
            return kv.join('='); // Convert the [key, value] format back into a "key=value" string.
        })
        .join('&'); // Concatenate all parameters "key=value" with '&'.

    return url.toString();
};


var addDirectoryIndex = function (originalUrl, index) {
    var url = new URL(originalUrl);
    if (url.pathname.slice(-1) === '/') {
        url.pathname += index;
    }
    return url.toString();
};

var hashParamName = '_sw-precache';
var urlsToCacheKeys = new Map(
    precacheConfig.map(function (item) {
        var relativeUrl = item[0];
        var hash = item[1];
        var absoluteUrl = new URL(relativeUrl, self.location);
        var cacheKey = createCacheKey(absoluteUrl, hashParamName, hash, <%= dontCacheBustUrlsMatching %>);
        return [absoluteUrl.toString(), cacheKey];
    })
);

function setOfCachedUrls(cache) {
    return cache.keys().then(function (requests) {
        // If there is no data cached in the original cacheName, it is considered the first installation by default; otherwise, it is considered an SW update.
        if (requests && requests.length > 0) {
            firstRegister = 0; // SW update
        }
        return requests.map(function (request) {
            return request.url;
        });
    }).then(function (urls) {
        return new Set(urls);
    });
}

self.addEventListener('install', function (event) {
    event.waitUntil(
        caches.open(cacheName).then(function (cache) {
            return setOfCachedUrls(cache).then(function (cachedUrls) {
                return Promise.all(
                    Array.from(urlsToCacheKeys.values()).map(function (cacheKey) {
                        // If cacheKey is not found in the cache, add it.
                        if (!cachedUrls.has(cacheKey)) {
                            var request = new Request(cacheKey, { credentials: 'same-origin' });
                            return fetch(request).then(function (response) {
                                // Only proceed if the response returns 200; otherwise, throw an error directly.
                                if (!response.ok) {
                                    throw new Error('Request for ' + cacheKey + ' returned a ' +
                                        'response with status ' + response.status);
                                }

                                return cleanResponse(response).then(function (responseToCache) {
                                    return cache.put(cacheKey, responseToCache);
                                });
                            });
                        }
                    })
                );
            });
        })
            .then(function () {
            <% if (skipWaiting) { %>
            // Force the SW state installing -> activate
            return self.skipWaiting();
            <% } %>
        })
    );
});

self.addEventListener('activate', function (event) {
    var setOfExpectedUrls = new Set(urlsToCacheKeys.values());

    event.waitUntil(
        caches.open(cacheName).then(function (cache) {
            return cache.keys().then(function (existingRequests) {
                return Promise.all(
                    existingRequests.map(function (existingRequest) {
                        // Delete the content with the same key in the original cache.
                        if (!setOfExpectedUrls.has(existingRequest.url)) {
                            return cache.delete(existingRequest);
                        }
                    })
                );
            });
        }).then(function () {
            <% if (clientsClaim) { %>
            return self.clients.claim();
            <% } %>
        }).then(function () {
                // If it is the first installation of the SW, no update message is sent (whether it is the first installation is determined by checking if there is cached information in the specified cacheName)
                // Else, it means the content has been updated, and the page needs to be notified to reload for the update.
                if (!firstRegister) {
                    return self.clients.matchAll()
                        .then(function (clients) {
                            if (clients && clients.length) {
                                clients.forEach(function (client) {
                                    client.postMessage('sw.update');
                                })
                            }
                        })
                }
            })
    );
});


<% if (handleFetch) { %>
    self.addEventListener('fetch', function (event) {
        if (event.request.method === 'GET') {

            // Whether to use event.respondWith() needs to be determined step by step.
            // This also facilitates specialized processing in the later stage.
            var shouldRespond;

            // First, remove the configured ignore parameters and hash.
            // Check whether the cache key contains the request; if it does, set shouldRespond to true.
            var url = stripIgnoredUrlParameters(event.request.url, ignoreUrlParametersMatching);
            shouldRespond = urlsToCacheKeys.has(url);

            // If shouldRespond is false, append "index.html" to the URL by default.
            // (Or the value of directoryIndex you configured yourself in the config file); continue searching the cache list.
            var directoryIndex = '<%= directoryIndex %>';
            if (!shouldRespond && directoryIndex) {
                url = addDirectoryIndex(url, directoryIndex);
                shouldRespond = urlsToCacheKeys.has(url);
            }

            // If shouldRespond is still false, check if it is a navigation
            // request. If so, determine whether it can match the navigateFallbackWhitelist regex.
            var navigateFallback = '<%= navigateFallback %>';
            if (!shouldRespond &&
                navigateFallback &&
                (event.request.mode === 'navigate') &&
                isPathWhitelisted(<%= navigateFallbackWhitelist %>, event.request.url)
            ) {
                url = new URL(navigateFallback, self.location).toString();
                shouldRespond = urlsToCacheKeys.has(url);
            }

            // If shouldRespond is set to true,
            // event.respondWith() matches the cache and returns the result; if no match is found, it directly makes a request.
            if (shouldRespond) {
                event.respondWith(
                    caches.open(cacheName).then(function (cache) {
                        return cache.match(urlsToCacheKeys.get(url)).then(function (response) {
                            if (response) {
                                return response;
                            }
                            throw Error('The cached response that was expected is missing.');
                        });
                    }).catch(function (e) {
                        // If an exception error is caught, directly return the fetch() request resource.
                        console.warn('Couldn\'t serve response for "%s" from cache: %O', event.request.url, e);
                        return fetch(event.request);
                    })
                );
            }
        }
    });


<% if (swToolboxCode) { %>
// *** Start of auto-included sw-toolbox code. ***
<%= swToolboxCode %>
// *** End of auto-included sw-toolbox code. ***
<% } %>

<% if (runtimeCaching) { %>
// Runtime cache configuration converted to toolbox code.
<%= runtimeCaching %>
<% } %>
<% } %>

<% if (importScripts) { %>
    importScripts(<%= importScripts %>);
<% } %>

/* eslint-enable */
