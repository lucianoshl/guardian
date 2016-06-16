// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$('tr.report-line').click(function(){
  window.location.href = '/report/' + $(this).attr('report-id');
});