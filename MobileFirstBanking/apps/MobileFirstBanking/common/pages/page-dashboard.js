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
App.PageDashboard = (function() {

    function lastLoginDate() {
        var date = new Date();
        date.setDate(date.getDate() - 1);

        return date.prettyPrint();
    }

    function beforePageShown($doc) {

        WL.App.sendActionToNative('showDashboard', {});

        $('#last-login').html(lastLoginDate());
    }

    function afterPageShown($doc) {
        WL.App.addActionReceiver('MainMenuPageActionReceiver', actionReceiver);

        $('.button-dashboard').tap(dashboardButtonClicked);
    }

    function dashboardButtonClicked(event) {
        App.cleanEvent(event);

        var action = $(this).data('action');

        if (action === 'Logout') {
            return App.logout();
        }

        menuButtonClicked({
            buttonId: action
        });
    }

    function actionReceiver(received) {
        if (received.action === 'nativeButtonClicked') {
            menuButtonClicked(received.data);
        }
    }

    function menuButtonClicked(data) {

        if (data.buttonId === 'Logout') {
            return App.logout();
        }

        App.navigateToPage(data.buttonId);
    }


    return {
        beforePageShown: beforePageShown,
        afterPageShown: afterPageShown
    };
})();