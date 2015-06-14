# coding: utf-8
module StationsHelper
  def get_dayofweek_kana_from_date(date)
    case date - date.beginning_of_week
    when 0.day then
      return "月"
    when 1.day then
      return "火"
    when 2.day then
      return "水"
    when 3.day then
      return "木"
    when 4.day then
      return "金"
    when 5.day then
      return "土"
    when 6.day then
      return "日"
    else
      return nil
    end
  end
  
  
  
  def get_dayofweek_eng_from_date(date)
    case date - date.beginning_of_week
    when 0.day then
      return "mon"
    when 1.day then
      return "tue"
    when 2.day then
      return "wed"
    when 3.day then
      return "thu"
    when 4.day then
      return "fri"
    when 5.day then
      return "sut"
    when 6.day then
      return "sun"
    else
      return nil
    end
  end
end
