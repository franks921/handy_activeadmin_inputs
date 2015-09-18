class AttachmentInput < Formtastic::Inputs::FileInput

  def image_html_options
    {class: 'attachment-input__image', alt: nil}.merge(options[:image_html] || {})
  end

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

    def attachment_image
      builder.object.send(method)
    end

    def attachment_present?
      attachment_image.present?
    end

    def remove_attachment_html
      return if !attachment_present?
      
      for_id = "#{@object.class.to_s.underscore}_remove_#{method}"
      
      builder.template.content_tag(:label, for: for_id, class: 'attachment-input__remove') do
        [builder.check_box("remove_#{method}", {}, 1, 0), 'Unlink attachment?'].join.html_safe
      end
    end
    
    def preview_html
      return if builder.object.new_record? || !attachment_present?
      
      original     = attachment_image
      thumb        = original.url(options[:cw_version])
      content_type = MIME::Types[original.content_type].first.extensions.first
      css          = "attachment-input__#{options.has_key?(:cw_version) ? 'image' : 'document'}"
      
      builder.template.link_to(original.url, target: '_blank', class: css) do
        html = [
          builder.template.content_tag(:span, content_type.upcase, class: 'content-type'),
          builder.template.content_tag(:span, template.number_to_human_size(attachment_image.size.to_s.downcase), class: 'file-size')
        ]
        if options.has_key?(:cw_version)
          html << builder.template.image_tag(thumb, image_html_options)
        else
          html << builder.template.content_tag(:i, nil, class: "fa fa-ct-#{content_type}")
        end
        html.join.html_safe
      end
    end

end
