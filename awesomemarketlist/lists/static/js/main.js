$("#new_item").click(function(event){
   event.preventDefault();
   let item_template = $("#item_template");
   item_template.clone().show().attr('id', '').appendTo("#item_list");
});

$('body').ready(update_total());

function save_item(button){
   event.preventDefault();
   let list_id = $('#list_id').val();
   let item_container = $(button).parent();
   let item_id = item_container.find(".item_id").val();
   let item_name = item_container.find(".item_name").val();
   let item_quantity = item_container.find(".item_quantity").val();
   let item_price = item_container.find(".item_price").val();
   $(button).hide();
   
   $.ajax({
        url : '/lists/save_item/',
        type : 'POST',
        data : {
           list_id: list_id,
           item_id: item_id,
           item_name : item_name, 
           item_quantity: item_quantity,
           item_price: item_price
        },

        success : function(data){
            console.log(data);
        }
    });
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

// You need these methods to add the CSRF token using jQuery
function getCookie(name) {
    var cookieValue = null;
    if (document.cookie && document.cookie != '') {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
            var cookie = jQuery.trim(cookies[i]);
            // Does this cookie string begin with the name we want?
            if (cookie.substring(0, name.length + 1) == (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

var csrftoken = getCookie('csrftoken');

function csrfSafeMethod(method) {
    // these HTTP methods do not require CSRF protection
    return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}
$.ajaxSetup({
    beforeSend: function(xhr, settings) {
        if (!csrfSafeMethod(settings.type) && !this.crossDomain) {
            xhr.setRequestHeader("X-CSRFToken", csrftoken);
        }
    }
});