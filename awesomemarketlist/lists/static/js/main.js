$("#new_item").click(function(event){
   event.preventDefault();
   let item_template = $("#item_template")
   item_template.clone().show().appendTo("#item_list").text('dfksdf')
});