module AvailabilitiesHelper
  DAY_NAMES = %w[Domingo Segunda-feira Terça-feira Quarta-feira Quinta-feira Sexta-feira Sábado].freeze

  def day_name(wday)
    DAY_NAMES.fetch(wday)
  end

  def day_options
    DAY_NAMES.each_with_index.to_a
  end
end