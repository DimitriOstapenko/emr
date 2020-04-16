// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap
//= require rails-ujs
//= require turbolinks
//= require_tree .
// require bootstrap-datepicker
//= require jquery.cardswipe.min.js 
//= require select2
//= require popper
// require bootstrap-sprockets  // causes drop-downs to dissapear
//
//= require pagination-keys.js
//= require tooltip.js
//= require dropzone


function set_sm_modal() {
  document.getElementById('mymodal').className='modal-dialog modal-sm';
}

function set_md_modal() {
  document.getElementById('mymodal').className='modal-dialog modal-md';
}

function set_lg_modal() {
  document.getElementById('mymodal').className='modal-dialog modal-lg';
}

$(document).on('turbolinks:load', function(){
    $(".alert-alert").delay(2000).slideUp(500, function(){
          $(".alert").alert('close');
      });
    });
