// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$('tr.village-line').click(function(){
	window.location.href = '/village/' + $(this).attr('village-id');
});