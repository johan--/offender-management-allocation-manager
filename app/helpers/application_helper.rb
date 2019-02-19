module ApplicationHelper
  def replace_param(name, value)
    uri = URI.parse(request.original_url)

    query = Rack::Utils.parse_query(uri.query)
    query[name] = value

    uri.query = Rack::Utils.build_query(query)
    uri.to_s
  end

  def format_date(date_obj)
    return '' if date_obj.nil?

    date_obj.strftime('%d/%m/%Y')
  end

  def pom_level(level)
    {
      'PO' => 'Prison POM',
      'PRO' => 'Probation POM'
    }[level]
  end

  def override_reason_contains(override, val)
    override.override_reasons.present? && override.override_reasons.include?(val)
  end
end
