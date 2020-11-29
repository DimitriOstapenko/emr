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
//= require zoho.js

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

function get_patient ( ohip_num ) {
        var request = "/patients/get?findstr=" + ohip_num;
        var aj = $.ajax({
        url: request,
        type: 'get',
        data: $(this).serialize()
    }).done(function (data) {
      var patient = data.patient;
      var user = data.user;
      $('#note').hide();
      if (patient && patient.last_visit_date) { // Patient in DB and has record
        var ok_icon = '<font size=4><i class="glyphicon glyphicon-ok"></i></font> ';
	if (user) {
	  var last_login = (typeof user.last_sign_in_at === 'undefined') ? '' : " <br> Last login: " + user.last_sign_in_at;
          result = ok_icon + "Registered patient found:<br>" + patient.lname +', '+ patient.fname + '; login email: ' + user.email + last_login
          $("#login_button").show();
	} else {	
          result = ok_icon + "Unregistered clinic patient:<br>" + patient.lname +', '+ patient.fname + ' born ' + patient.dob + " <br> Last visit: " + patient.last_visit_date;
          $("#register_button").show();
	}
        $("#results").html(result);
      } else if (patient.lname) { // successful HCV lookup
          result = "New patient: " + patient.lname +', ' + patient.fname + ' born '  + patient.dob;
          $("#register_button").show();
          $("#results").html(result);
      } else
        result = 'Invalid card number: ' +  patient.notes;
        $("#results").html(result);
    }).fail(function (data) {
        console.log('AJAX request has FAILED');
        $("#register_button").show();
    });
}

