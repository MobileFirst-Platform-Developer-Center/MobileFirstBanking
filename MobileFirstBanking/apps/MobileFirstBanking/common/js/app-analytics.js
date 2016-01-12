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
var AppAnalytics = (function (WL) {
    'use strict';

    var pageVisitCount = 0;
    var appStartTime = new Date();
    
    function logUserReturning(user) {
        WL.Analytics.log({userReturning: user.userID}, 'UserReturning');
    }
    
    function logUserNew(user) {
        WL.Analytics.log({userNew: user.userID}, 'UserNew');
    }

    function logout(page) {
        var sessionTime = ((new Date()).getTime() - appStartTime) / 1000 / 60;

		WL.Analytics.log({sessionTime: parseFloat(sessionTime.toFixed(2))}, 'SessionTime');

		WL.Analytics.log({numberOfPages: pageVisitCount}, 'NumberOfPages');

        WL.Analytics.log({closedOnPage : page}, 'ClosedOnPage');

        setTimeout(function () {
            WL.Analytics.send();
        }, 300);
    }

    function pageNavigation(sourcePage, destinationPage) {
        WL.Analytics.log({fromPage: sourcePage, toPage: destinationPage}, 'PageTransition');
        pageVisitCount++;
    }

    function pageVisit(page) {
        WL.Analytics.log({pageVisit: page}, 'PageVisit');
    }

    function appointmentStep(step) {
        WL.Analytics.log({makeAppointment : step}, 'MakeAppointment');
    }

    function checkDepositStep(step) {
        WL.Analytics.log({checkDeposit: step}, 'CheckDeposit');
    }

    function transferStep(step) {
        WL.Analytics.log({transferFunds : step}, 'TransferFunds');
    }

    function findATMLocation(locationName) {
        WL.Analytics.log({findATMLocation : locationName}, 'FindATMLocation');
    }

    return {
        logUserReturning: logUserReturning,
        logUserNew: logUserNew,
        logout: logout,
        pageVisit: pageVisit,
        pageNavigation: pageNavigation,
        appointmentStep: appointmentStep,
        checkDepositStep: checkDepositStep,
        transferStep: transferStep,
        findATMLocation: findATMLocation
    };
})(WL);