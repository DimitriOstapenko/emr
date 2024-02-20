import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import JQuery from 'jquery';
window.$ = window.JQuery = JQuery;

require("@popperjs/core")
import "bootstrap"


// Import the specific modules you may need (Modal, Alert, etc)
import { Tooltip, Popover, Modal, Pagination, Alert } from "bootstrap"

// Import Bootstrap icons
import 'bootstrap-icons/font/bootstrap-icons.css'

// The stylesheet location we created earlier
require("../stylesheets/application.scss")

// If you're using Turbolinks. Otherwise simply use: jQuery(function () {
document.addEventListener("turbolinks:load", () => {
    // Both of these are from the Bootstrap 5 docs
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
        return new Tooltip(tooltipTriggerEl)
    })

    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
    var popoverList = popoverTriggerList.map(function(popoverTriggerEl) {
        return new Popover(popoverTriggerEl)
    })
})

setTimeout(function() {
    $(".alert").fadeTo(800, 0).slideUp(800, function(){
        $(this).remove();
    });
}, 4000);

Rails.start()
Turbolinks.start()
ActiveStorage.start()
