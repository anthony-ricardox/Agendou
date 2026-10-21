module AvailabilitiesHelper
  def day_name(wday)
    I18n.t("date.day_names").fetch(wday).capitalize
  end

  def day_options
    I18n.t("date.day_names").map(&:capitalize).each_with_index.to_a
  end
end