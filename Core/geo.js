
(function() {
    function inject(scriptText) {
        const script = document.createElement('script');
        script.textContent = scriptText;
        (document.head || document.documentElement).appendChild(script);
        (document.head || document.documentElement).removeChild(script);
    }

    function findClosest(lat, lon) {
        /* https://stackoverflow.com/questions/18883601/function-to-calculate-distance-between-two-coordinates */
        function deg2rad(deg) {
            return deg * (Math.PI / 180)
        }
        function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
            var R = 6371; /* Radius of the earth in km */
            var dLat = deg2rad(lat2 - lat1);
            var dLon = deg2rad(lon2 - lon1);
            var a =
                Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2)
                ;
            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            var d = R * c; /* Distance in km */
            return d;
        }

        let closest = null;
        let closestDistance = null;

        cityData.forEach(item => {
            const distance = getDistanceFromLatLonInKm(lat, lon, item.latitude, item.longitude);

            if (closestDistance === null || distance < closestDistance) {
                closestDistance = distance;
                closest = item;
            }
        });

        const country = countryData.find(item => item.country_code === closest.country_code);

        console.log('closest city is', closest.city, closestDistance, 'km away');
        console.log('current country is', country.country);

        return {
            country: {
                name: country.country,
                latitude: country.latitude,
                longitude: country.longitude,
                accuracy: getDistanceFromLatLonInKm(lat, lon, country.latitude, country.longitude)
            },
            city: {
                name: closest.city,
                latitude: closest.latitude,
                longitude: closest.longitude,
                accuracy: closestDistance
            }
        };
    }

    function wrapGeo() {
        if (!navigator.geolocation) {
            return;
        }

        let approximateLocation = null;
        let closestCache = null;

        const getCurrentPosition = Reflect.getOwnPropertyDescriptor(Reflect.getPrototypeOf(navigator.geolocation), 'getCurrentPosition').value;

        Object.defineProperty(Geolocation.prototype, 'getCurrentPosition', {
            configurable: true,
            value: async (success, failure) => {
                console.trace('getCurrentPosition called');

                if (approximateLocation === null) {
                    approximateLocation = await askUser();
                }

                return getCurrentPosition.call(navigator.geolocation, (position) => {
                    let coords = position.coords;

                    if (approximateLocation === 'precise') {
                        success({
                            timestamp: position.timestamp,
                            coords,
                        });
                    } else if (approximateLocation === 'city' || approximateLocation === 'country') {
                        if (!closestCache) {
                            closestCache = findClosest(position.coords.latitude, position.coords.longitude);
                        }

                        const point = (approximateLocation === 'city') ? closestCache.city : closestCache.country;

                        success({
                            timestamp: position.timestamp,
                            coords: {
                                latitude: point.latitude,
                                longitude: point.longitude,
                                accuracy: Math.round(point.accuracy) * 1000
                            },
                        });
                    } else {
                        failure({code: 1, message: 'Denied.'});
                    }
                }, failure);
            }
        });
    }

    inject(`(function(){
        const countryData = ${JSON.stringify(countryData)};
        const cityData = ${JSON.stringify(cityData)};
        ${findClosest.toString()};
        ${wrapGeo.toString()};
        ${askUser.toString()};
        wrapGeo();
    })()`);
})()
