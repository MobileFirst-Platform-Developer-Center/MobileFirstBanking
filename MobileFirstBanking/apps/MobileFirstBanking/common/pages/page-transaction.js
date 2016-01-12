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
App.PageTransaction = (function(){

	var $transactionItem = null;
    var $transactionDetails = null;

	var canDismiss = false;
    
	function beforePageShown($doc){
		WL.App.sendActionToNative("showSecondaryPage", {
			title:"Last Transactions",
			button: "Back",
			enabled: false
		});
        
        var transactions = getTransactions();
        
        var $template = $('#transaction-list-template');

        $('#transaction-list').html(_.template($template.html())({items: transactions}));
	}

	function afterPageShown($doc){
		$transactionItem = $('.item');
		$transactionDetails = $('.transaction-details');

		$transactionItem.tap(showTransactionDetails);
		$transactionDetails.tap(transactionDetailsToggle);
	}

	function showTransactionDetails(event) {
        App.cleanEvent(event);

		if($(this).find('.transaction-details').length == 0) {
			$transactionDetails.hide();
			$(this).append($transactionDetails);
		}

		$transactionDetails.toggle('slide');
	}

	function transactionDetailsToggle(event) {
        App.cleanEvent(event);

		$(this).toggle('slide');
	}
    
    function getTransactions() {
        var transactions = [];

        var date = new Date();
    
        var transactionType = ['cash', 'credit', 'transfer'];
        var transactionDescription = ['Deposit', 'Credit Card', 'Money Transfer'];

        for(var i = 0; i < 30; i++) {
            var type = parseInt((Math.random() * 100)) % 3;

            date.setDate(date.getDate() - i);

            transactions.push({
                type: transactionType[type],
                amount:  ((Math.random() * 20000) - 1000).toFixed(2) * (type === 1 ? -1 : 1),
                date: date.prettyPrint(),
                description: transactionDescription[type]
            });
        }
        
        return transactions;
    }

	return {
		beforePageShown			: beforePageShown,
		afterPageShown			: afterPageShown
	};
})();
