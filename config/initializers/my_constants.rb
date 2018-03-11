#
# App constants 
#

DEBUG_FLAG = 0

GROUP_NO = "0078".freeze
AVG_MINS_PER_PATIENT = 10.freeze
CLINIC_NAME = 'Stoney Creek Medical Walk-In Clinic'.freeze
CLINIC_ADDR = '140 Centennial Parkway North, Unit 2A, STONEY CREEK, ON L8E 1H9'.freeze
CLINIC_PHONE = '(905) 561-9255'.freeze
CLINIC_FAX = '(905) 561-4391'.freeze

PATIENT_TYPES = {OHIP: 'O', Transient: 'T', Deceased: 'D', RMB: 'R', 'Self Pay': 'S', 'Waiting For HC': 'W', Imported: 'I'}.freeze

VISIT_STATUSES = { Arrived: 1, Assessed: 2, 'Ready To Bill': 3, Billed: 4, Cancelled: 5, Deleted: 6}.freeze

VISIT_TYPES= {'Walk In': 'WI', 'Primary Care': 'PC', Consultation: 'CT', 'Emergency Room': 'EM', Form: 'FM', 
	      Hospital: 'HP', Message: 'MG', Telephone: 'PH', 'Pre-Operative': 'PO', Secondary: 'SD', WSIB: 'WB'}.freeze

BILLING_FORMAT='EDT'.freeze  # CSV/EDT
