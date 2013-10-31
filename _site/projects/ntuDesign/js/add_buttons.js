         $(document).ready(function() {
            $("body").on('click', '.addButton', function() {
               var tr = $(this).parent().parent().fadeOut("normal", function(){$(this).remove();}).clone();
               
               tr.find('.itemMenu').remove();
               var itemMenuUpDown = ' <td class="itemMenuUpDown"> <button class="button_red"> x</button> <button class="up tight"> ▲</button> <button class="down tight"> ▼</button> </td> ';
               tr.find("td:first").before(itemMenuUpDown);
               
               tr.hide();
               $("#selectedTable tr:last").after(tr);
               tr.fadeIn()

            });

            $("body").on('click', '.button_red', function() {
               var tr = $(this).parent().parent().fadeOut("normal", function(){$(this).remove();}).clone();
               $(this).parent().parent().remove();
               tr.find('.itemMenuUpDown').remove();
               var itemMenu= ' <td class="itemMenu"> <button class="addButton"> 匯入 </button> </td>';
               tr.find("td:first").before(itemMenu);
               
               tr.hide();
               $("#imported tr:last").after(tr);
               tr.fadeIn()
            });

            $("body").on('click', '.up', function() {
               var prev = $(this).parent().parent().prev();
               if (prev.find('td').length>0){
                  var tr = $(this).parent().parent().fadeOut("normal", function(){$(this).remove();}).clone();
                  $(this).parent().parent().remove();
                  tr.hide();
                  prev.before(tr);
                  tr.fadeIn()
               }
            });

            $("body").on('click', '.down', function() {
               var next= $(this).parent().parent().next();
               if (next.find('td').length>0){
                  var tr = $(this).parent().parent().fadeOut("normal", function(){$(this).remove();}).clone();
                  $(this).parent().parent().remove();
                  tr.hide();
                  next.after(tr);
                  tr.fadeIn()
               }
            });
         });
               
