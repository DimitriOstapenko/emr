# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
success = (data) ->
#  $('#status').text 'Success!'
  line1 = data['line1']
#  cardnum = line1.substring(7, 17)
#  ver = line1.substring(61, 63)
#  exp = line1.substring(45, 49)
#  names = line1.substring(18, 44)
#  arr = names.split('/')
#  dob = line1.substring(53, 61)
#  alert 'NAME: ' + arr[0] + ', ' + arr[1] + '\n' + 'HCN: ' + cardnum + '  ' + ver + ' EXP: ' + exp + '\n' + 'DOB: ' + dob
#  $('#findstr').val cardnum
#  window.location = '/patients?findstr=' + cardnum
  $.ajax
    url: '/patients/card'
    data: cardstr: data['line1']
    dataType: 'script'
    type: 'POST'

error = ->
  alert 'Failed'
  $('#status').text 'Failed!'
  $('.line').text ''
  return

$.cardswipe
  success: success
  firstLineOnly: true
  parsers: [ 'generic' ]
  error: error
  debug: true

