$("#new_item").click(function (event) {
    event.preventDefault();
    let item_template = $("#item_template");
    item_template.clone().show().attr('id', '').appendTo("#item_list");
});

$('body').ready(update_total());

function save_item(item_element) {
    event.preventDefault();
    let list_id = $('#list_id').val();
    let item_container = $(item_element).parent().parent();
    let item_id = item_container.find(".item_id").val();
    let item_id_element = item_container.find(".item_id");
    let item_name = item_container.find(".item_name").val();
    let item_quantity = item_container.find(".item_quantity").val();
    let item_price = item_container.find(".item_price").val();

    $.ajax({
        url: '/lists/save_item/',
        type: 'POST',
        data: {
            list_id: list_id,
            item_id: item_id,
            item_name: item_name,
            item_quantity: item_quantity,
            item_price: item_price
        },

        success: function (data) {
            if (item_id == '0') {
                response = JSON.parse(data);
                new_id = response['item_id'];
                item_id_element.val(new_id);
                console.log("New item saved!");
            } else {
                console.log("Item updated!");
            }


        }
    });
}

function update_total() {
    let total = 0;
    $('.item').each(function () {
        item_total = parseInt($(this).find('.item_quantity').val()) * parseInt($(this).find('.item_price').val());
        $(this).find('.item_total').val(item_total);
        total += item_total;
    });
    $("#expenses").html(total);
    let budget = parseInt($("#budget").val());
    $("#left").html(budget - total);
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
    beforeSend: function (xhr, settings) {
        if (!csrfSafeMethod(settings.type) && !this.crossDomain) {
            xhr.setRequestHeader("X-CSRFToken", csrftoken);
        }
    }
});