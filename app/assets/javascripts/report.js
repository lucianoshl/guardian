var rClick = function(){
  $('tr.report-line').click(function(){
    window.location.href = '/report/' + $(this).attr('report-id');
  });
};

$(document).ready(rClick)
$(document).on('page:load', rClick);

