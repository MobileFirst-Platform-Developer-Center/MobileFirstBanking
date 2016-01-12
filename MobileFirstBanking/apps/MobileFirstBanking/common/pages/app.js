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
var App = (function() {
    var $doc = null;
    var $body = null;

    var navigationStack = [];

    var busyIndicator = null;

    var pendingAppointmentConfirmation = false;

    var pagesMap = {
        'PageDashboard': 'page-dashboard.html',
        'PageAccount': 'page-account.html',
        'PageTransaction': 'page-transaction.html',
        'PageTransfer': 'page-transfer.html',
        'PageCheckDeposit': 'page-check-deposit.html',
        'PageFindATM': 'page-find-atm.html',
        'PageAppointment': 'page-appointment.html',
        'PageAppointmentDetails': 'page-appointment-details.html'
    };

    function init() {

        WL.Client.connect();
        
        // check if the user has used this app before
        isUserNew({userID: deviceID}).then(function(isNew) {
            if(isNew) {
                // METRIC COLLECTION
                AppAnalytics.logUserNew(this);
            } else {
                // METRIC COLLECTION
                AppAnalytics.logUserReturning(this);
            }
        });

        busyIndicator = new WL.BusyIndicator();

        $doc = $(document);
        $body = $('body');

        $body.pagecontainer({
            defaults: true
        });

        $doc.on('pagecontainerbeforeshow', onPageContainerBeforeShow);
        $doc.on('pagecontainershow', onPageContainerShow);

        $doc.on('pause', function(e) {

            if (!App.internalAppInvocation) {
                logout(e);
            }

            App.internalAppInvocation = false;
        });

        $body.pagecontainer('change', 'pages/page-dashboard.html', {
            changeHash: false
        });


        navigationStack.push('page-dashboard.html');
        WL.App.addActionReceiver('AppActionReceiver', actionReceiver);
    }

    function actionReceiver(received) {

        if (received.action === 'nativeBackButtonClicked') {
            App.back();
            WL.App.sendActionToNative('hideMenu', {});
        } else if (received.action === 'nativeButtonClicked') {
            if (received.data.buttonId === 'AppointmentDetails') {
                pendingAppointmentConfirmation = true;
            }
        } else if (received.action === 'transferPinValidationSuccess') {
            App.PageTransfer.onTransferPinValidationComplete(true);

        } else if (received.action === 'transferPinValidationFailure') {
            App.PageTransfer.onTransferPinValidationComplete(true);
        }

    }

    function onPageContainerBeforeShow(event, ui) {
        App.cleanEvent(event);
        var pageUrl = event.target.baseURI;

        var pageId = getPageIdFromPageUrl(pageUrl);
        App[pageId].beforePageShown($doc);
    }

    function onPageContainerShow(event, ui) {
        App.cleanEvent(event);
        var currentPageId = $body.pagecontainer('getActivePage').attr('id');

        App[currentPageId].afterPageShown($doc);

        // METRIC COLLECTION
        AppAnalytics.pageVisit(currentPageId);

        if (pendingAppointmentConfirmation) {
            pendingAppointmentConfirmation = false;
            App.navigateToPage('PageAppointmentDetails');
        }
    }

    function navigateToPage(page) {
        App.showBusy();

        setTimeout(function() {
            App.hideBusy();
            App.navigate(pagesMap[page]);
        }, 300);
    }

    function navigate(page) {
        // METRIC COLLECTION
        AppAnalytics.pageNavigation(getCurrentPageId(), getPageIdFromPageUrl(page));

        var navigationPath = navigationStack.length;

        if (page === 'page-dashboard.html') {
            navigationStack = [];
            WL.App.sendActionToNative('showDashboard', {});
        } else {
            var lastIndex = navigationStack.length - 1;

            if (lastIndex <= 0) {
                navigationStack.push(getCurrentPageHtmlFileName());
            } else if (navigationStack[lastIndex] !== page) {
                navigationStack.push(page);
            }
        }

        if (navigationPath !== navigationStack.length) {
            $body.pagecontainer('change', page, {
                changeHash: false,
                transition: 'slide'
            });
        }
    }

    function getPageIdFromPageUrl(pageUrl) {
        for (var pageId in pagesMap) {
            var pageHtmlFile = pagesMap[pageId];
            if (pageUrl.indexOf(pageHtmlFile) > -1)
                return pageId;
        }
        return null;
    }

    function getCurrentPageHtmlFileName() {
        return pagesMap[getCurrentPageId()];
    }

    function getCurrentPageId() {
        return $body.pagecontainer('getActivePage').attr('id');
    }

    function back(event) {
        App.cleanEvent(event);

        var currentPageId = getCurrentPageId();

        if (navigationStack.length == 0) {
            WL.SimpleDialog.show('MobileFirst Banking', 'Are you sure you want to log out?', [{
                text: 'Yes',
                handler: App.logout
            }, {
                text: 'Cancel',
                handler: null
            }]);
        } else {
            App.showBusy();
            navigationStack.pop();

            setTimeout(function() {
                App.hideBusy();

                $body.pagecontainer('change', navigationStack[navigationStack.length - 1], {
                    changeHash: false,
                    transition: 'slide',
                    reverse: true
                });

            }, 300);
        }
    }

    function cleanEvent(event) {
        if (typeof(event) === 'undefined') return;

        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
    }

    function showBusy() {
        busyIndicator.show();
    }

    function hideBusy() {
        busyIndicator.hide();
    }

    function logout(event) {
        // METRIC COLLECTION
        AppAnalytics.logout(getCurrentPageId());

        App.cleanEvent(event);
        App.showBusy();

        setTimeout(function() {
            App.hideBusy();

            WL.App.sendActionToNative('LogoutButtonClicked');
        }, 100);
    }
    
    function isUserNew(user) {
        var $deferred = $.Deferred();
        
        // JSONStore use collection definition
        var collection = {
            users : {
                searchFields: {userID : 'string'}
            }
        };

		WL.JSONStore.init(collection).then(function () {
			return WL.JSONStore.get('users').find(user);
		}).then(function (result) {
			if(result.length == 0){
                return WL.JSONStore.get('users').add(user);
			}
            // user has already used this app
			$deferred.resolveWith(user, [false]);
		}).then(function () {
            // user has never used this app
            $deferred.resolveWith(user, [true]);
		}).fail(function (error) {
            // error performing JSONStore Operations
            $deferred.rejectWith(this, [error]);
		});
            
        return $deferred;
    }

    return {
        init: init,
        back: back,
        internalAppInvocation: false,
        navigateToPage: navigateToPage,
        cleanEvent: cleanEvent,
        showBusy: showBusy,
        hideBusy: hideBusy,
        logout: logout,
        navigate: navigate
    };
}());