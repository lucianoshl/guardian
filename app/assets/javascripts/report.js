$(document).on('tr.report-line', function(){
  window.location.href = '/report/' + $(this).attr('report-id');
});