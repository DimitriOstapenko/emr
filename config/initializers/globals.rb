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
YES_NO = [['Yes', true], ['No', false]].freeze

# Patients
# PATIENT_TYPES = {OHIP: 'O', RMB: 'R', 'Self Pay': 'S', IFH: 'I', Transient: 'T', 'Waiting For HC': 'W', Deceased: 'D'}.freeze
PATIENT_TYPES = {HCP: 'O', RMB: 'R', WCB: 'W', 'CSH': 'S', IFH: 'I', DEC: 'D'}.freeze
HCP_PATIENT = PATIENT_TYPES[:HCP].freeze
RMB_PATIENT = PATIENT_TYPES[:RMB].freeze
WCB_PATIENT = PATIENT_TYPES[:WCB].freeze
CASH_PATIENT = PATIENT_TYPES[:CSH].freeze
IFH_PATIENT = PATIENT_TYPES[:IFH].freeze
DECEASED_PATIENT = PATIENT_TYPES[:DEC].freeze

SEXES  = {Male: 'M',Female: 'F',Unknown: 'X'}.freeze
DIGSEXES = {'M' => 1, 'F' => 2}.freeze
PROVINCES = {ON: 'ON', AB: 'AB', BC: 'BC', MB: 'MB', NB: 'NB', NL: 'NL', NS: 'NS', NT: 'NT', NU: 'NU', PE: 'PE', QC: 'QC', SK: 'SK', YT: 'YT'}

# Visits
VISIT_STATUSES = { Arrived: 1, Assessed: 2,  'Ready To Bill': 3, Billed: 4, Paid: 5, Cancelled: 6, Error: 7}.freeze
ARRIVED = VISIT_STATUSES[:Arrived].freeze
ASSESSED = VISIT_STATUSES[:Assessed].freeze
READY = VISIT_STATUSES[:'Ready To Bill'].freeze
BILLED = VISIT_STATUSES[:Billed].freeze
PAID = VISIT_STATUSES[:Paid].freeze
CANCELLED = VISIT_STATUSES[:Cancelled].freeze
ERROR = VISIT_STATUSES[:Error].freeze

VISIT_TYPES= {'Walk In': 'WI', 'Primary Care': 'PC', Consultation: 'CT', 'Emergency Room': 'EM', Form: 'FM', WCB: 'WB'}.freeze
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
BILLING_TYPES = {HCP: 1, RMB: 2, WCB: 3, CSH: 4, PRV: 6, IFH: 7, DEC: 0}.freeze
HCP_BILLING = BILLING_TYPES[:HCP]
RMB_BILLING = BILLING_TYPES[:RMB]
CASH_BILLING = BILLING_TYPES[:CSH]
WCB_BILLING = BILLING_TYPES[:WCB]
PRV_BILLING = BILLING_TYPES[:PRV]
IFH_BILLING = BILLING_TYPES[:IFH]

# Reports
REPORTS_PATH = Rails.root.join('reports').freeze
REPORT_TYPES = {Daily: 1, Monthly: 2, Yearly: 3, 'Date Range': 4, 'All Time': 5}.freeze
DAILY = REPORT_TYPES[:Daily]
MONTHLY = REPORT_TYPES[:Monthly]
YEARLY = REPORT_TYPES[:Yearly]

# Charts
CHARTS_PATH = Rails.root.join('charts').freeze

# Export files:
EXPORT_PATH = Rails.root.join('export').freeze

# EDT files:
EDT_PATH = Rails.root.join('EDT').freeze
EDT_FILE_TYPES = {Claim: 1, Batch: 2, Remit: 3, Error: 4}.freeze

# Pay Stubs:
PAYSTUBS_PATH = Rails.root.join('paystubs').freeze


