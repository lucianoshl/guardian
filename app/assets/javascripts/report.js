$(document).on('click', 'tr.report-line', function(){
  window.location.href = '/report/' + $(this).attr('report-id');
});