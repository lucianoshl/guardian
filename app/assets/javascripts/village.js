var villageClick = function(){
  $('tr.village-line').click(function(){
    window.location.href = '/village/' + $(this).attr('village-id');
  });
};

$(document).ready(villageClick)
$(document).on('page:load', villageClick);

