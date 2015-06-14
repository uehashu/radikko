# coding: utf-8
module StationsHelper
  def get_dayofweek_kana_from_date(date)
    case date.cwday
    when 1 then
      return "月"
    when 2 then
      return "火"
    when 3 then
      return "水"
    when 4 then
      return "木"
    when 5 then
      return "金"
    when 6 then
      return "土"
    when 7 then
      return "日"
    else
      return nil
    end
  end
  
  
  
  def get_dayofweek_eng_from_date(date)
    case date.cwday
    when 1 then
      return "mon"
    when 2 then
      return "tue"
    when 3 then
      return "wed"
    when 4 then
      return "thu"
    when 5 then
      return "fri"
    when 6 then
      return "sut"
    when 7 then
      return "sun"
    else
      return nil
    end
  end
end
