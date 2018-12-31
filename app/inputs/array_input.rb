class ArrayInput < SimpleForm::Inputs::StringInput
  def input
    #override the attribute name for arrays to allow rails to handle array forms
    input_html_options.merge!({:name => "#{self.object_name}[#{attribute_name}][]"})
    @builder.text_field(attribute_name, input_html_options)
  end
end
