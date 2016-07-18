// This is a manife$.AdminLTE.tree(".sidebar")st file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets

//= require nprogress
//= require nprogress-turbolinks

//= require Chart.bundle.min
//= require jquery-ui/draggable
//= require turbolinks
//= require jquery.slimscroll
//= require app
//= require_tree .

$(document).ready(function() {
  $.AdminLTE.layout.activate();
});

$(document).on('page:load', function() {
  var o;
  o = $.AdminLTE.options;
  if (o.sidebarPushMenu) {
    $.AdminLTE.pushMenu.activate(o.sidebarToggleSelector);
  }
  $.AdminLTE.layout.activate();
  $.AdminLTE.tree(".sidebar");
});