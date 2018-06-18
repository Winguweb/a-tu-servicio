module LayoutHelper

  def body_id
    if content_for?(:body_id)
      content_for(:body_id)
    else
      "#{controller.controller_name}-#{controller.action_name}"
    end
  end

  def body_class
    class_name = controller.controller_name
    if content_for?(:body_class)
      class_name = "#{class_name} #{content_for(:body_class)}"
    end

    class_name
  end
end
