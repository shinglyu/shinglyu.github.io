/*
 * SimpleModal Confirm Modal Dialog
 * http://simplemodal.com
 *
 * Copyright (c) 2013 Eric Martin - http://ericmmartin.com
 *
 * Licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 */

jQuery(function ($) {
	$('.button_red').click(function (e) {
      sure=confirm("您確定要退選嗎?")
      if(sure==true){
         $(this).parent().parent().fadeOut();
      }

		/*e.preventDefault();

		// example of calling the confirm function
		// you must use a callback function to perform the "yes" action
		confirm("Are you sure?", $(this), function (caller) {
         caller.parent().parent().fadeOut();
		});
      */
	});
});


/*
function confirm(message) {
	$('#confirm').modal({
		closeHTML: "<a href='#' title='Close' class='modal-close'>x</a>",
		position: ["20%",],
		overlayId: 'confirm-overlay',
		containerId: 'confirm-container', 
		onShow: function (dialog) {
			var modal = this;

			$('.message', dialog.data[0]).append(message);

			// if the user clicks "yes"
			$('.yes', dialog.data[0]).click(function () {
				modal.close(); // or $.modal.close();
            return true;
				// call the callback
				//if ($.isFunction(callback)) {
				//	callback.apply(this, caller);
				//}
				// close the dialog
			});
         //modal.close(); // or $.modal.close();
         //return false;
		}
	});
}
*/
