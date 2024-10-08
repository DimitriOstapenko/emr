# app/inputs/weekday_select_input.rb
# frozen_string_literal: true

class WeekdaySelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    @builder.weekday_select(attribute_name, input_options, merged_input_options)
  end
end
