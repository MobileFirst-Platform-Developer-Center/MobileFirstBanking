/*
 *  © Copyright 2015 IBM Corp.
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
App.PageFindATM = (function() {
    var isGoogleMapsAPILoaded = false;
    var busyIndicator = null;
    var infoWindows = [];
    var mapCanvas = null;
    var loadingTimeout = null;

    var map = null;

    function beforePageShown($doc) {
        WL.App.sendActionToNative("showSecondaryPage", {
            title: "Find ATM",
            button: "Back",
            enabled: false
        });
    }

    function afterPageShown() {
        mapCanvas = $('#map-canvas')[0];

        if (!busyIndicator) busyIndicator = new WL.BusyIndicator();
        busyIndicator.show();

        if (isGoogleMapsAPILoaded) {
            onGoogleMapsReady();
        } else {
            var script = document.createElement('script');
            script.type = 'text/javascript';
            script.src = 'http://maps.googleapis.com/maps/api/js?v=3.exp&sensor=true&callback=App.PageFindATM.onGoogleMapsReady';
            document.body.appendChild(script);
            loadingTimeout = setTimeout(googleMapsLoadingTimeout, 10000);
        }
    }

    function googleMapsLoadingTimeout() {
        clearTimeout(loadingTimeout);
        loadingTimeout = true;
        busyIndicator.hide();
        WL.SimpleDialog.show(
            "Error loading maps",
            "Could not load maps. Please check your internet connection and try again later.", [{
                text: "OK",
                handler: App.back
            }], {});
    }

    function onGoogleMapsReady() {

        if (loadingTimeout === true) return;
        clearTimeout(loadingTimeout);

        isGoogleMapsAPILoaded = true;
        var coordinates = {
            latitude: 36.120700,
            longitude: -115.169628
        };

        try {
            showMap(coordinates);
        } catch (e) {
            console.error(e);
        }

    }

    function showMap(location) {
        var latitude = location.latitude;
        var longitude = location.longitude;

        var mapOptions = {
            zoom: 13,
            center: new google.maps.LatLng(latitude, longitude),
            zoomControlOptions: {
                position: google.maps.ControlPosition.LEFT_BOTTOM,
                style: google.maps.ZoomControlStyle.LARGE
            }
        };


        map = new google.maps.Map(mapCanvas, mapOptions);

        google.maps.event.addListener(map, 'tilesloaded', function(evt) {
            google.maps.event.clearListeners(map);
            busyIndicator.hide();

            WL.App.sendActionToNative('showSecondaryPage', {
                title: 'Find ATM',
                button: 'Back',
                enabled: true
            });
        });

        infoWindows = [];

        var locations = getLocations();

        for (var i = 0; i < locations.length; i++) {
            var place = locations[i];

            var marker = new google.maps.Marker({
                map: map,
                position: {
                    lat: place.geometry.location.lat,
                    lng: place.geometry.location.lng
                },
                animation: google.maps.Animation.DROP,
                icon: '../images/app-map-marker.png'
            });

            

            marker.address = place.address;
            marker.atmID = place.id;

            var infoWindow = new google.maps.InfoWindow({
                content: place.address.street + ', ' + place.address.city + ', ' + place.address.state,
                maxWidth: 200
            });
            
            infoWindow.atmID = place.id;

            infoWindows.push(infoWindow);

            google.maps.event.addListener(marker, 'click', mapMarkerClicked);
        }

    }

    function mapMarkerClicked() {

        var targetInfoWindow = null;

        for (var id in infoWindows) {
            var win = infoWindows[id];
            win.close();

            if (win.atmID === this.atmID) {
                targetInfoWindow = win;
            }
        }

        if (targetInfoWindow != null) {
            targetInfoWindow.open(map, this);
            
            // METRIC COLLECTION
            AppAnalytics.findATMLocation(this.atmID + ' - ' + this.address.city + ', ' + this.address.state);
        }

    }

    function getLocations() {
        return [{
            "id": "NAL3456",
            "address": {
                "street": "2412 E Desert Inn Rd",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.130143,
                    "lng": -115.1181
                }
            }
        }, {
            "id": "NAL6751",
            "address": {
                "street": "2430 E Flamingo Rd",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.115088,
                    "lng": -115.118125
                }
            }
        }, {
            "id": "NAL9880",
            "address": {
                "street": "129 Fremont St",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.170614,
                    "lng": -115.144702
                }
            }
        }, {
            "id": "NAL8731",
            "address": {
                "street": "4780 S Maryland Pkwy",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.102964,
                    "lng": -115.136572
                }
            }
        }, {
            "id": "NAL1053",
            "address": {
                "street": "300 S Fourth St",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.166884,
                    "lng": -115.14395
                }
            }
        }, {
            "id": "NAL4009",
            "address": {
                "street": "2585 S Nellis Blvd",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.143048,
                    "lng": -115.065881
                }
            }
        }, {
            "id": "NAL6480",
            "address": {
                "street": "3805 E Flamingo Rd",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.115033,
                    "lng": -115.091627
                }
            }
        }, {
            "id": "NAL4331",
            "address": {
                "street": "3200 S Las Vegas Blvd G-5",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.127424,
                    "lng": -115.170815
                }
            }
        }, {
            "id": "NAL6186",
            "address": {
                "street": "591 N Eastern Ave #110",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.173637,
                    "lng": -115.116721
                }
            }
        }, {
            "id": "NAL2009",
            "address": {
                "street": "2233 Paradise Rd",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.143971,
                    "lng": -115.154371
                }
            }
        }, {
            "id": "NAL2409",
            "address": {
                "street": "145 E Harmon Ave",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.107589,
                    "lng": -115.166615
                }
            }
        }, {
            "id": "NAL2419",
            "address": {
                "street": "840 S Rancho Dr",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.161719,
                    "lng": -115.173133
                }
            }
        }, {
            "id": "NAL2967",
            "address": {
                "street": "855 S Grand Central Pkwy",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.163675,
                    "lng": -115.157212
                }
            }
        }, {
            "id": "NAL9867",
            "address": {
                "street": "2000 S Las Vegas Blvd",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.14732,
                    "lng": -115.155234
                }
            }
        }, {
            "id": "NAL9768",
            "address": {
                "street": "3300 Las Vegas Blvd S",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.126703,
                    "lng": -115.169448
                }
            }
        }, {
            "id": "NAL8037",
            "address": {
                "street": "5715 S Eastern Ave",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.085725,
                    "lng": -115.119514
                }
            }
        }, {
            "id": "NAL7736",
            "address": {
                "street": "4001 S Maryland Pkwy",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.116634,
                    "lng": -115.139187
                }
            }
        }, {
            "id": "NAL5561",
            "address": {
                "street": "3475 S Las Vegas Blvd",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.119834,
                    "lng": -115.172168
                }
            }
        }, {
            "id": "NAL5449",
            "address": {
                "street": "3755 Spring Mountain Road",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "geometry": {
                "location": {
                    "lat": 36.125948,
                    "lng": -115.189491
                }
            }
        }, {
            "id": "NAL8860",
            "address": {
                "street": "3150 Paradise Rd",
                "city": "Las Vegas",
                "state": "NV",
                "country": "United States"
            },
            "formatted_address": ", Las Vegas, NV, United States",
            "geometry": {
                "location": {
                    "lat": 36.131291,
                    "lng": -115.152772
                }
            }
        }];
    }


    return {
        beforePageShown: beforePageShown,
        afterPageShown: afterPageShown,
        onGoogleMapsReady: onGoogleMapsReady
    };
})();