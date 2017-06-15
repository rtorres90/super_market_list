$("#new_item").click(function(event){
   event.preventDefault();
   let item_template = $("#item_template");
   item_template.clone().show().attr('id', '').appendTo("#item_list");
});

$('body').ready(update_total());

function save_item(button){
   event.preventDefault();
   let item_container = $(button).parent();
   let item_name = item_container.find(".item_name").val();
   let item_quantity = item_container.find(".item_quantity").val();
   let item_price = item_container.find(".item_price").val();
   $(button).hide();
   console.log("Saving "+ item_name);
}

function activate_save_button(input) {
   event.preventDefault();
   let item_container = $(input).parent();
   item_container.find(".save_button").show();
}

function update_total(){
   let total = 0;
   $('.item').each(function(){
      total += parseInt($(this).find('.item_quantity').val()) * parseInt($(this).find('.item_price').val()); 
   });
   console.log(total);
   $("#total").html(total);
}