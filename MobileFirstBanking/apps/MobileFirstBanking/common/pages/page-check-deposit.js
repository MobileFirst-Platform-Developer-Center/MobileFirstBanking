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
App.PageCheckDeposit = (function() {

    var $depositFront = null;
    var $depositBack = null;
    var $depositConfirm = null;

    var $checkFront = null;
    var $checkBack = null;
    var $checkDepositButton = null;

    function beforePageShown($doc) {

        WL.App.sendActionToNative("showSecondaryPage", {
            title: "Deposit check",
            button: "Back",
            enabled: false
        });

        $checkFront = $('#check-front-image');
        $checkBack = $('#check-back-image');
        $checkDepositButton = $('#check-deposit-button');

        $depositFront = $("#check-front");
        $depositBack = $("#check-back");
        $depositConfirm = $("#deposit-confirm");
    }

    function afterPageShown($doc) {
        WL.App.sendActionToNative("showSecondaryPage", {
            title: "Deposit check",
            button: "Back",
            enabled: true
        });


        $(".check-photo").tap(checkPhotoClicked);
        $(".check-image-wrapper").tap(checkPhotoClicked);

        $checkDepositButton.tap(buttonDepositCheckClicked);
        
        // METRIC COLLECTION
        AppAnalytics.checkDepositStep('Step 1: Deposit Started');
    }


    function checkPhotoClicked(event) {
        App.cleanEvent(event);

        var isEmulator = (device.model.indexOf("x86") > -1) ? true : false;

        var cameraOptions = {
            quality: 50,
            destinationType: Camera.DestinationType.DATA_URL,
            encodingType: Camera.EncodingType.PNG,
            targetWidth: 300,
            targetHeight: 170,
            sourceType: isEmulator ? Camera.PictureSourceType.PHOTOLIBRARY : Camera.PictureSourceType.CAMERA
        };


        var id = $(this).attr('id');

        if (id === 'check-front-photo') {
            navigator.camera.getPicture(checkFrontSuccess, cameraFail, cameraOptions);
        } else if (id === 'check-back-photo') {
            navigator.camera.getPicture(checkBackSuccess, cameraFail, cameraOptions);
        }
    }

    function cameraIsOpen() {
        App.internalAppInvocation = true;
    }

    function checkFrontSuccess(imgData) {
        cameraIsOpen();


        $("#check-front-photo").attr("src", "data:image/jpeg;base64," + imgData);
        $checkFront.attr("src", "data:image/jpeg;base64," + imgData);

        $depositFront.hide();
        $depositBack.show();

        setTimeout(checkIfDepositPossible, 0);

        // METRIC COLLECTION
        AppAnalytics.checkDepositStep('Step 2: Front side photo');
    }

    function checkBackSuccess(imgData) {
        cameraIsOpen();

        $("#check-back-photo").attr("src", "data:image/jpeg;base64," + imgData);
        $checkBack.attr("src", "data:image/jpeg;base64," + imgData);

        checkIfDepositPossible();

        // METRIC COLLECTION
        AppAnalytics.checkDepositStep('Step 3: Back side photo');

    }

    function cameraFail(err) {
        cameraIsOpen();
    }

    function checkIfDepositPossible() {

        if ($checkFront.attr("src").length > 100 && $checkBack.attr("src").length > 100) {
            $checkDepositButton.prop("disabled", false);

            $depositFront.hide();
            $depositBack.hide();
            $depositConfirm.show();
        }
    }

    function buttonDepositCheckClicked(event) {

        App.cleanEvent(event);
        WL.SimpleDialog.show("Uploading", "Your check photos will be uploaded to the server in the background. You will be notified once upload is complete", [{
            text: "OK",
            handler: function() {
                WL.App.sendActionToNative("startActivityViewSpinner");
                App.back();
            }
        }], {});

        // METRIC COLLECTION
        AppAnalytics.checkDepositStep('Step 4: Confirm');

        setTimeout(depositComplete, 10000);
    }

    function depositComplete() {

        WL.App.sendActionToNative("stopActivityViewSpinner");
        WL.SimpleDialog.show("Deposit success", "Your check was successfully deposited to your account.", [{
            text: "OK",
            handler: null
        }], {});
    }

    return {
        beforePageShown: beforePageShown,
        afterPageShown: afterPageShown
    };
})();