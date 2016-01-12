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
App.PageAccount = (function(){
	var $contextMenu = null;
	var $accountIcon = null;

	function beforePageShown($doc){
		WL.App.sendActionToNative("showSecondaryPage", {
			title:"Accounts",
			button: "Back",
			enabled: false
		});

        var accounts = getAccounts();
        
        var $template = $('#account-list-template');

        $('#account-list').html(_.template($template.html())({items: accounts}));
	}

	function afterPageShown($doc){
        $contextMenu = $(".context-menu");
		$accountIcon = $(".item-list").find(".item .toggle-icon");
        
        $accountIcon.tap(onAccountClicked);

		$(".item").tap(function(event){
            App.cleanEvent(event);

			$(this).find(".toggle-icon").tap();
		});

		$(".context-button").tap(contextButtonClicked);
    }

	function onAccountClicked(event){
        App.cleanEvent(event);
        
        var $this = $(this);

		var $accountItem = $this.parent(".item");

        $accountIcon.not(this).removeClass("close-icon");
        
        if($this.hasClass('close-icon')) {
            hideContextMenu($contextMenu);
        } else if($contextMenu.is(':visible')) {
            hideContextMenu($contextMenu).then(function(){
                showContextMenu($contextMenu, $accountItem);
            });
        } else {        
            showContextMenu($contextMenu, $accountItem);
        }
        
        $this.toggleClass('close-icon');
	}
    
    function showContextMenu($menu, $item) {
        var promise = $.Deferred();

        $menu.insertAfter($item);
        $menu.slideDown(function(){
            promise.resolve();
        });
        
        return promise;
    }
    
    function hideContextMenu($menu) {
        var promise = $.Deferred();
        
        $menu.slideUp(function(){
            promise.resolve();
        });
        
        return promise;
    }

	function contextButtonClicked(event){
		App.cleanEvent(event);

		$contextMenu.slideUp();
		 
        App.navigateToPage($(this).data('action'));
	}
    
    function getAccounts() {
        var accounts = [];

        for(var i = 0; i < 20; i++) {
            accounts.push({
                number: parseInt(Math.random() * 100000),
                name: (((parseInt(Math.random() * 10) % 2) == 0) ? "Savings" : "Credit") + " Account",
                balance: ((Math.random() * 20000) - 1000).toFixed(2)
            });
        }
        
        return accounts;
    }

	return {
		beforePageShown					: beforePageShown,
		afterPageShown					: afterPageShown
	};
})();
