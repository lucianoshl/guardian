$(document).on('click', 'tr.village-line', function(){
  window.location.href = '/village/' + $(this).attr('village-id');
});