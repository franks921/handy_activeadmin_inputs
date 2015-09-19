class AttachmentInput < Formtastic::Inputs::FileInput

  def to_html
    input_wrapping do
      [
        label_html,
        preview_html,
        builder.file_field(method, input_html_options),
        remove_attachment_html
      ].join.html_safe
    end
  end

  protected

    def attachment_file
      builder.object.send(method)
    end
    
    def attachment_content_type
      MIME::Types[attachment_file.content_type].first.extensions.first
    end

    def attachment_present?
      attachment_file.present?
    end

    def remove_attachment_html
      return if !attachment_present?
      
      builder.template.content_tag(:label, for: "#{@object.class.to_s.underscore}_remove_#{method}", class: 'attachment-input__remove') do
        [builder.check_box("remove_#{method}", {}, 1, 0), 'Remove attachment?'].join.html_safe
      end
    end
    
    def preview_html
      return if builder.object.new_record? || !attachment_present?
      
      link_options = {
        target: '_blank',
        class: "attachment-input__#{options.has_key?(:cw_version) ? 'image' : 'document'}"
      }
      
      builder.template.link_to(attachment_file.url, link_options) do
        [attachment_content_type_html, attachment_size_html, attachment_icon_html].join.html_safe
      end
    end

    def attachment_icon_html
      if options.has_key?(:cw_version)
        builder.template.image_tag(attachment_file.url(options[:cw_version]), {class: 'attachment-input__image', alt: nil})
      else
        builder.template.content_tag(:i, nil, class: "fa fa-ct-#{attachment_content_type}")
      end
    end

    def attachment_content_type_html
      builder.template.content_tag(:span, attachment_content_type.upcase, class: 'content-type')
    end

    def attachment_size_html
      builder.template.content_tag(:span, template.number_to_human_size(attachment_file.size.to_s.downcase), class: 'file-size')
    end

end
