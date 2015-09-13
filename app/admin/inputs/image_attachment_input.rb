# Use with ActiveAdmin, CarrierWave and Formtastic
# f.input :cover, as: :attachment, version: :small, hint: 'Recommened 400x400 pixels. JPG, PNG'

class ImageAttachmentInput < Formtastic::Inputs::FileInput

  def image_html_options
    {class: 'attachment-input__image', alt: nil}.merge(options[:image_html] || {})
  end

  def to_html
    input_wrapping do
      [
        label_html,
        image_html,
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
        [builder.check_box("remove_#{method}", {}, 1, 0), "Delete #{method}?"].join.html_safe
      end
    end

    def image_html
      return if builder.object.new_record? || !attachment_present?

      thumb    = attachment_image.url(options[:version])
      original = attachment_image.url
      
      builder.template.link_to(original, target: '_blank') do
        builder.template.image_tag(thumb, image_html_options).html_safe
      end
    end

end
