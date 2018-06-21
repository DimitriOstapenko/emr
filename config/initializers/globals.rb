#
# App constants 
#

DEBUG_FLAG = 0

# General

GROUP_NO = "0078".freeze
AVG_MINS_PER_PATIENT = 10.freeze
CLINIC_NAME = 'Stoney Creek Medical Walk-In Clinic'.freeze
CLINIC_ADDR = '140 Centennial Parkway North, Unit 2A, STONEY CREEK, ON L8E 1H9'.freeze
CLINIC_PHONE = '(905) 561-9255'.freeze
CLINIC_FAX = '(905) 561-4391'.freeze
TRUE_FALSE = {True: 1,False: 0}.freeze

# Patients

PATIENT_TYPES = {OHIP: 'O', Transient: 'T', Deceased: 'D', RMB: 'R', 'Self Pay': 'S', 'Waiting For HC': 'W', Clinic: 'C'}.freeze
SEXES  = {Male: 'M',Female: 'F',Unknown: 'X'}.freeze
DIGSEXES = {'M' => 1, 'F' => 2}.freeze
PROVINCES = {ON: 'ON', AB: 'AB', BC: 'BC', MB: 'MB', NB: 'NB', NL: 'NL', NS: 'NS', NT: 'NT', NU: 'NU', PE: 'PE', QC: 'QC', SK: 'SK', YT: 'YT'}

# Visits

VISIT_STATUSES = { Arrived: 1, Assessed: 2,  'Ready To Bill': 3, Billed: 4, Paid: 5, Cancelled: 6, Error: 7}.freeze
ASSESSED = VISIT_STATUSES[:Assessed]
READY = VISIT_STATUSES[:'Ready To Bill']
BILLED = VISIT_STATUSES[:Billed]
PAID = VISIT_STATUSES[:Paid]
CANCELLED = VISIT_STATUSES[:Cancelled]
ERROR = VISIT_STATUSES[:Error]

VISIT_TYPES= {'Walk In': 'WI', 'Primary Care': 'PC', Consultation: 'CT', 'Emergency Room': 'EM', Form: 'FM', 
	      Hospital: 'HP', Message: 'MG', Telephone: 'PH', 'Pre-Operative': 'PO', Secondary: 'SD', WSIB: 'WB'}.freeze
u = {}
(1..10).each {|k| u[k]=k}
UNITS  = u.freeze
d = {}
%w(10 20 30 40).each {|k| d[k]=k}
DURATIONS = d.freeze 

# Procedures
 
PROC_TYPES = {HCP: 1, '3RD': 2}.freeze

# Billing

CABMDURL = 'https://api.cab.md/claims?apiKey=e679b103-f74d-4b2d-bb60-5f05ad4f9de1'
BILLING_FORMAT='CABMD'.freeze  # CSV/EDT/CABMD
#BILLING_STATUSES = { "No Claim Yet": 1, "Claim Generated": 2, Invoiced: 3, Deleted: 4, Paid: 5, 'Written Off': 6}.freeze
BILLING_TYPES = {HCP: 1, RMB: 2, Invoice: 3, Cash: 4, WCB: 5, PRV: 6}.freeze
HCP_BILLING = BILLING_TYPES[:HCP]
RMB_BILLING = BILLING_TYPES[:RMB]
CASH_BILLING = BILLING_TYPES[:Cash]
WCB_BILLING = BILLING_TYPES[:WCB]
PRV_BILLING = BILLING_TYPES[:PRV]

# Reports

#TIMEFRAMES   = {Day: 1, Month: 2, Year: 3}.freeze
REPORT_TYPES = {Daily: 1, Monthly: 2, Yearly: 3, 'Date Range': 4, 'All Time': 5}.freeze
DAILY = REPORT_TYPES[:Daily]
MONTHLY = REPORT_TYPES[:Monthly]
YEARLY = REPORT_TYPES[:Yearly]

# Charts
CHARTS_PATH = Rails.root.join('charts').freeze

# Export files:
EXPORT_PATH = Rails.root.join('export').freeze
