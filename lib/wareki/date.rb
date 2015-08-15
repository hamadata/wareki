require 'wareki/common'
module Wareki

  class Date
    attr_reader :jd
    attr_accessor :year, :month, :day, :era_year, :era_name

    def self.jd(d)
      era = Utils.find_era(d)
      era or raise UnsupportedDateRange, "Cannot find era for date #{d.inspect}"
      year, month, day, is_leap = Utils.find_date_ary(d)
      obj = new(era.name, year - era.year + 1, month, day, is_leap)
      obj.__set_jd(d)
      obj
    end

    def self.date(date)
      jd(date.jd)
    end

    def self.imperial(year, month = 1, day = 1, is_leap_month = false)
      new("皇紀", year, month, day, is_leap_month)
    end

    def initialize(era_name, era_year, month = 1, day = 1, is_leap_month = false)
      if era_name != "皇紀" && era_name != "神武天皇即位紀元" && !ERA_BY_NAME[era_name]
        raise ArgumentError, "Undefined era '#{era_name}'"
      end
      @month = month
      @day = day
      @is_leap_month = is_leap_month
      @era_name = era_name
      @era_year = era_year
      if era_name == "皇紀" || era_name == "神武天皇即位紀元"
        @year = era_year + IMPERIAL_START_YEAR
      else
        @year = ERA_BY_NAME[era_name].year + era_year - 1
      end
    end

    def imperial_year
      @year - IMPERIAL_START_YEAR
    end

    def imperial_year=(v)
      @year = v - IMPERIAL_START_YEAR
    end

    def leap_month?
      !!@is_leap_month
    end

    def leap_month=(v)
      @is_leap_month = v
    end

    def jd
      @jd and return @jd
      era = ERA_BY_NAME[era_name]
      oyear = era.year + era_year - 1

      if oyear >= GREGORIAN_START_YEAR
        @jd = ::Date.new(oyear, month, day, ::Date::GREGORIAN).jd
        return @jd
      end

      yobj = YEAR_BY_NUM[oyear] or
        raise UnsupportedDateRange, "Cannot convert to jd #{self.inspect}"
      month_idx = month - 1
      if leap_month? || yobj.leap_month && month > yobj.leap_month
        month_idx += 1
      end
      @jd = yobj.month_starts[month_idx] + day - 1
    end

    def to_date
      ::Date.jd(jd)
    end

    def to_datetime
      to_date.to_datetime
    end

    def __set_jd(v)
      @jd = v
    end
  end
end