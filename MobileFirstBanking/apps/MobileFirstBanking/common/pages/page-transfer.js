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
App.PageTransfer = (function() {
    function beforePageShown($doc) {
        WL.App.sendActionToNative("showSecondaryPage", {
            title: "Transfer Funds",
            button: "Back",
            enabled: false
        });
    }

    function afterPageShown($doc) {
        $doc.on('tap', '#transfer-button', buttonTransferClicked);
        $doc.on('tap', '#cancel-button', buttonCancelClicked);

        // METRIC COLLECTION
        AppAnalytics.transferStep('Step 1: Transfer Started');
    }

    function buttonCancelClicked(event) {
        App.cleanEvent(event);
        // METRIC COLLECTION
        AppAnalytics.transferStep('Transfer Cancelled');
        App.back();
    }

    function buttonTransferClicked(event) {
        App.cleanEvent(event);
        // METRIC COLLECTION
        AppAnalytics.transferStep('Step 2: Submit');
        App.showBusy();
        setTimeout(getTransferPin, 2000);
    }

    function getTransferPin() {
        App.internalAppInvocation = true;
        WL.App.sendActionToNative("getTransferPin");

        // METRIC COLLECTION
        AppAnalytics.transferStep('Step 3: Authorization');
        App.hideBusy();
    }

    function onTransferPinValidationComplete(success) {
        if (success) {
            App.showBusy();
            setTimeout(finishTransferSuccess, 2000);
        } else {
            finishTransferFailure();
        }
    }

    function finishTransferSuccess() {
        App.hideBusy();

        // METRIC COLLECTION
        AppAnalytics.transferStep('Step 4: Transfer Success');

        WL.SimpleDialog.show("Funds transfer", "Your transaction was successfully completed.", [{
            text: "OK",
            handler: function() {
                App.back()
            }
        }], {});
    }

    function finishTransferFailure() {
        App.hideBusy();
        
        // METRIC COLLECTION
        AppAnalytics.transferStep('Transfer Failed');

        WL.SimpleDialog.show("Funds transfer", "Your transaction was not complete. Please check your PIN code and try again.", [{
            text: "OK",
            handler: function() {}
        }], {});
    }

    return {
        beforePageShown: beforePageShown,
        afterPageShown: afterPageShown,
        onTransferPinValidationComplete: onTransferPinValidationComplete
    };
})();