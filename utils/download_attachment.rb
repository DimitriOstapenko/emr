1. Firstly, we need to connect to imap and login to the mail account of the user.

def get_messages
      require 'net/imap'
      require 'mail'
      imap = Net::IMAP.new(params[:host], params[:port], params[:ssl])
      imap.login(params[:username], params[:password])
2. Then we need to select the folder from where we will download the attachments.

imap.select(params[:folder])
3. Then we can loop through all the mails in that folder and can save the attachments on our end as depicted below.

  imap.search('ALL').each do |message_id|
         body = imap.fetch(message_id, 'RFC822')[0].attr['RFC822']
         mail = Mail.new(body)
         unless mail.attachments.blank?
            unless File.exists?("public/attachments/#{mail.message_id}")
               Dir.mkdir(File.join("public/attachments", "#{mail.message_id}"), 0700)
           end
           mail.attachments.each do |attachment|
              File.open("public/attachments/#{mail.message_id}/#{attachment.filename}", 'wb') do |file|
              file.write(attachment.body.decoded)
          end
        end
    end
    imap.logout
   imap.disconnect
end
 
=begin

Get attachments, HTML and Text Body
if message.multipart?
  email_html = message.html_part.body.decoded  #parsing of html content of the email
  email_text = message.text_part.body.decoded  # parsing of text content of the email
  email_attachments = []   # an array which can be used to store object records of the attachments..
  message.attachments.each do |attachment|
    file = StringIO.new(attachment.decoded)
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = attachment.filename
    file.content_type = attachment.mime_type
    attachment = Attachment.new    # an attachment model and all the attachments are saved here...
    attachment.attached_file = file
    attachment.save
    email_attachments << attachment   # adding all attachment objects one by one in the array...
  end
else
  email_html = message.body.decoded    # in this case its a plain email so html body is same as text body..
  email_text = message.body.decoded
  email_attachments = []   # no attachments :)
end
Once you have parsed all the attributes from the email ie to, from, email attachments now you can easily pass it to delayed job or something like creating a ticket or whatever you want to do as per you needs ;)

=end

