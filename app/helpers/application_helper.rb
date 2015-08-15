module ApplicationHelper
  def scaled_list_for_name(name)
    (1..8).map {|i| asset_path("#{name}.x#{i}.png") }.map(&:inspect).join(',')
  end
end
